// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./interfaces/IERC721A.sol";
import "./interfaces/ITeamFinanceLocker.sol";
import "./interfaces/ITokenWhitelist.sol";

/// This token was incubated and launched by PROOF: https://proofplatform.io/projects. The smart contract is audited by SourceHat: https://sourcehat.com/

contract Token is ITokenWhitelist, Initializable, ERC20Upgradeable, OwnableUpgradeable {
    
    struct UserInfo {
        bool isFeeExempt;
        bool isTxLimitExempt;
        bool isWhitelisted;
    }

    IUniswapV2Router02 public uniswapV2Router;
    address public pair;

    address payable public mainWallet;
    address payable public secondaryWallet;

    IERC721A public proofPassNFT;

    bool public isWhitelistActive;
    uint256 public whitelistEndTime;
    uint256 public whitelistDuration;
    uint256 public launchedAt;

    uint256 public maxTxAmount;
    uint256 public maxWallet;
    uint256 public initMaxWallet;
    bool public checkMaxHoldings = true;
    bool public maxWalletChanged;

    uint256 public swapping;
    bool public swapEnabled;
    uint256 public swapTokensAtAmount;

    FeeInfo public feeTokens;
    FeeInfo public buyFees;
    FeeInfo public sellFees;

    uint256 public restingBuyTotal;
    uint256 public restingSellTotal;

    bool public buyTaxesSettled;
    bool public sellTaxesSettled;

    bool public proofFeeReduced;
    bool public proofFeeRemoved;

    bool public cancelled;

    uint256 public lockID;
    uint256 public lpLockDuration;

    mapping (address => UserInfo) public userInfo;
    mapping (uint256 => uint256) public swapThrottle;
    uint256 public maxSwapsPerBlock;

    IDataStore public immutable DATA_STORE;
    DataStoreAddressResponse public addresses;
    DataStoreLimitsResponse public limits;

    event SwapAndLiquify(uint256 tokensAutoLiq, uint256 ethAutoLiq);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event TokenCancelled(uint256 returnedETH);

    constructor(IDataStore dataStore) {
        DATA_STORE = dataStore;
        _disableInitializers();
    }
    
    function initialize(bytes calldata params) initializer public payable lockTheSwap {
        TokenInfo memory token = abi.decode(params, (TokenInfo));
        __ERC20_init(token.name, token.symbol);
        __Ownable_init(token.owner);

        DataStoreLimitsResponse memory _limits = DATA_STORE.getLimits();
        limits = _limits;
        
        (token.buyFees.proof, token.sellFees.proof) = (2,2);
        _validateFees(token.buyFees, token.sellFees);
        restingBuyTotal = token.buyFees.total;
        restingSellTotal = token.sellFees.total;

        token.buyFees.main = 15 - token.buyFees.proof - token.buyFees.secondary - token.buyFees.liquidity;
        token.buyFees.total = 15;
        token.sellFees.main = 20 - token.sellFees.proof - token.sellFees.secondary - token.sellFees.liquidity;
        token.sellFees.total = 20;

        buyFees = token.buyFees;
        sellFees = token.sellFees;

        // set addresses
        mainWallet = payable(token.mainWallet);
        secondaryWallet = payable(token.secondaryWallet);

        DataStoreAddressResponse memory _addresses = DATA_STORE.getPlatformAddresses();
        addresses = _addresses;

        proofPassNFT = IERC721A(_addresses.proofPassNFT);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_addresses.router);
        uniswapV2Router = _uniswapV2Router;

        pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set basic data

        lpLockDuration = token.lpLockDuration;
        swapTokensAtAmount = token.totalSupply * _limits.swapTokensAtAmount / _limits.denominator; // 125 / 100000

        maxTxAmount = token.totalSupply * _limits.initMaxTx / _limits.denominator;
        initMaxWallet = token.initMaxWallet;
        maxWallet = token.totalSupply * token.initMaxWallet / 100000; // 100 = .1%
        maxSwapsPerBlock = 4;

        userInfo[address(this)] = UserInfo(true, true, true);
        userInfo[pair].isTxLimitExempt = true;
        userInfo[pair].isWhitelisted = true;

        whitelistDuration = token.whitelistDuration;
        _setWhitelisted(token.whitelist);

        uint256 amountToPair = token.totalSupply * token.percentToLP / 100;
        super._update(address(0), address(this), amountToPair); // mint to contract for liquidity
        super._update(address(0), owner(), token.totalSupply - amountToPair); // mint to owner
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        addLiquidity(amountToPair, msg.value, address(this));
    }

    function launch(uint256 bundleBuyAmount) external payable onlyOwner lockTheSwap {
        if (launchedAt != 0 || cancelled) {
            revert InvalidConfiguration();
        }

        // enable trading
        checkMaxHoldings = true;
        swapEnabled = true;
        whitelistEndTime = block.timestamp + whitelistDuration;
        isWhitelistActive = true;
        launchedAt = block.timestamp;

        if (bundleBuyAmount != 0) {
            //execute bundle buy
            address[] memory path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = address(this);
            uniswapV2Router.swapExactETHForTokens{ value: bundleBuyAmount }(
                0, 
                path, 
                msg.sender, 
                block.timestamp
            );
        }

        // add NFT snapshot
        uint256 len = proofPassNFT.totalSupply() + 1;
        for (uint256 i = 1; i < len; ) {
            userInfo[proofPassNFT.ownerOf(i)].isWhitelisted = true;
            unchecked { ++i; }
        }

        // lock liquidity
        uint256 lpBalance = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(addresses.locker, lpBalance);
        
        lockID = ITeamFinanceLocker(addresses.locker).lockToken{value: address(this).balance}(pair, msg.sender, lpBalance, block.timestamp + lpLockDuration, false, address(0));
    }

    function cancel() external onlyOwner lockTheSwap {
        if (launchedAt != 0) {
            revert InvalidConfiguration();
        }

        IERC20(pair).approve(address(uniswapV2Router), IERC20(pair).balanceOf(address(this)));
        (uint256 ethAmt) = uniswapV2Router.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            IERC20(pair).balanceOf(address(this)),
            0, // liq pool should be untouchable
            0, // liq pool should be untouchable
            msg.sender,
            block.timestamp
        );
        emit TokenCancelled(ethAmt);
        
        cancelled = true;

        // send the tokens and eth back to the owner
        uint256 bal = address(this).balance;
        if (bal > 0) {
            address(msg.sender).call{value: bal}("");
        }
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (swapping == 2 || from == owner() || to == owner() || 
          from == address(this) || to == address(this) || amount == 0) {
            super._update(from, to, amount);
            return;
        }

        if (launchedAt == 0) {
            revert TradingNotEnabled();
        }

        UserInfo storage sender = userInfo[from];
        UserInfo storage recipient = userInfo[to];

        if (isWhitelistActive) {
            if (block.timestamp < whitelistEndTime) {
                if (!sender.isWhitelisted || !recipient.isWhitelisted)
                {
                    revert NotWhitelisted();
                }
            } else {
                isWhitelistActive = false;
            }
        }

        //start at anywhere from 0.1% to 0.5%, increase by 0.1%, every 10 blocks, until it reaches 1%
        if (!maxWalletChanged) {
            uint256 secondsPassed = block.timestamp - launchedAt;
            uint256 percentage = initMaxWallet + (100 * (secondsPassed / 120));
            if (percentage > 950) {
                percentage = 1000;
                maxWalletChanged = true;
            }
            uint256 newMax = totalSupply() * percentage / 100000;
            if (newMax != maxWallet) {
                maxWallet = newMax;
            }
        }

        if (checkMaxHoldings) {
            if (!recipient.isTxLimitExempt && amount + balanceOf(to) > maxWallet) {
                revert ExceedsMaxWalletAmount();
            }
        }

        uint256 total = feeTokens.total;
        bool canSwap = total >= swapTokensAtAmount;

        if (
            canSwap &&
            swapEnabled &&
            from != pair &&
            swapThrottle[block.number] < maxSwapsPerBlock
        ) {
            ++swapThrottle[block.number];
            processFees(total, swapTokensAtAmount);
        }
        
        if (!sender.isFeeExempt && !recipient.isFeeExempt) {

            FeeInfo storage _buyFees = buyFees;
            FeeInfo storage _sellFees = sellFees;

            if (!proofFeeRemoved) {
                uint256 secondsPassed = block.timestamp - launchedAt;
                if (!proofFeeReduced && secondsPassed > 1 days) {
                    uint256 totalBuy = _buyFees.total - _buyFees.proof;
                    if (totalBuy == 0) {
                        _buyFees.total = 0;
                        _buyFees.proof = 0;
                    } else {
                        buyFees.main = _buyFees.main + 1; //move proof fee to main fee, total doesn't change
                        _buyFees.proof = 1; //decrementing proof fee by 1%
                    }
                    uint256 totalSell = _sellFees.total - _sellFees.proof;
                    if (totalSell == 0) {
                        _sellFees.total = 0;
                        _sellFees.proof = 0;
                    } else {
                        _sellFees.main = _sellFees.main + 1; //same as the buy fee logic
                        _sellFees.proof = 1;
                    }
                    proofFeeReduced = true;
                } else if (secondsPassed > 31 days) {
                    //move proof fee to main fee
                    _buyFees.main += _buyFees.proof; 
                    _sellFees.main += _sellFees.proof; 
                    _buyFees.proof = 0;
                    _sellFees.proof = 0;
                    proofFeeRemoved = true;
                } else {
                    if (!buyTaxesSettled) {
                        uint256 restingTotal = restingBuyTotal;
                        uint256 feeTotal = restingTotal;
                        if (secondsPassed < 1801) {
                            //fee starts at 15%, decreases by 1% every 2 minutes until we reach the restingTotal.
                            feeTotal = 15 - (secondsPassed / 120);
                        }
                        if (feeTotal <= restingTotal) {
                            _buyFees.total = restingTotal;
                            _buyFees.main = restingTotal - _buyFees.liquidity - _buyFees.secondary - _buyFees.proof;
                            buyTaxesSettled = true;
                        } else if (feeTotal != _buyFees.total) {
                            _buyFees.total = feeTotal;
                            //extra fees get sent to the main wallet
                            _buyFees.main = feeTotal - _buyFees.liquidity - _buyFees.secondary - _buyFees.proof;
                        }
                    }
                    if (!sellTaxesSettled) {
                        uint256 restingTotal = restingSellTotal;
                        uint256 feeTotal = restingTotal;
                        if (secondsPassed < 2401) {
                            feeTotal = 20 - (secondsPassed / 120);
                        }
                        if (feeTotal <= restingTotal) {
                            _sellFees.total = restingTotal;
                            _sellFees.main = restingTotal - _sellFees.liquidity - _sellFees.secondary - _sellFees.proof;
                            sellTaxesSettled = true;
                        } else if (feeTotal != _sellFees.total) {
                            _sellFees.total = feeTotal;
                            _sellFees.main = feeTotal - _sellFees.liquidity - _sellFees.secondary - _sellFees.proof;
                        }
                    }
                }
            }

            uint256 fees;
            if (to == pair) { //sell
                fees = _calculateFees(_sellFees, amount);
            } else if (from == pair) { //buy
                fees = _calculateFees(_buyFees, amount);
            }
            if (fees > 0) {
                amount -= fees;
                super._update(from, address(this), fees);
            }
        }

        super._update(from, to, amount);

    }

    function _calculateFees(FeeInfo memory feeRate, uint256 amount) internal returns (uint256 fees) {
        if (feeRate.total != 0) {
            fees = amount * feeRate.total / 100;
            
            FeeInfo storage _feeTokens = feeTokens;
            _feeTokens.main += fees * feeRate.main / feeRate.total;
            _feeTokens.secondary += fees * feeRate.secondary / feeRate.total;
            _feeTokens.liquidity += fees * feeRate.liquidity / feeRate.total;
            _feeTokens.proof += fees * feeRate.proof / feeRate.total;
            _feeTokens.total += fees;
        }
    }

    function processFees(uint256 total, uint256 amountToSwap) internal lockTheSwap {
        FeeInfo storage _feeTokens = feeTokens;

        FeeInfo memory swapTokens;
        swapTokens.main = amountToSwap * _feeTokens.main / total;
        swapTokens.secondary = amountToSwap * _feeTokens.secondary / total;
        swapTokens.liquidity = amountToSwap * _feeTokens.liquidity / total;
        swapTokens.proof = amountToSwap * _feeTokens.proof / total;

        uint256 amountToPair = swapTokens.liquidity / 2;

        swapTokens.total = amountToSwap - amountToPair;

        uint256 ethBalance = swapTokensForETH(swapTokens.total);

        FeeInfo memory ethSplit;

        ethSplit.main = ethBalance * swapTokens.main / swapTokens.total;
        if (ethSplit.main > 0) {
           address(mainWallet).call{value: ethSplit.main}("");
        }

        ethSplit.secondary = ethBalance * swapTokens.secondary / swapTokens.total;
        if (ethSplit.secondary > 0) {
            address(secondaryWallet).call{value: ethSplit.secondary}("");
        }

        ethSplit.proof = ethBalance * swapTokens.proof / swapTokens.total;
        if (ethSplit.proof > 0) {
            uint256 revenueSplit = ethSplit.proof / 2;
            address(addresses.proofStaking).call{value: revenueSplit}("");
            address(addresses.proofWallet).call{value: ethSplit.proof - revenueSplit}("");
        }

        uint256 amountPaired;
        ethSplit.liquidity = address(this).balance;
        if (amountToPair > 0 && ethSplit.liquidity > 0) {
            amountPaired = addLiquidity(amountToPair, ethSplit.liquidity, address(0xdead));
            emit SwapAndLiquify(amountToPair, ethSplit.liquidity);
        }

        uint256 liquidityAdjustment = swapTokens.liquidity - (amountToPair - amountPaired);

        _feeTokens.main -= swapTokens.main;
        _feeTokens.secondary -= swapTokens.secondary;
        _feeTokens.liquidity -= liquidityAdjustment;
        _feeTokens.proof -= swapTokens.proof;
        _feeTokens.total -= swapTokens.main + swapTokens.secondary + swapTokens.proof + liquidityAdjustment;
    }

    function swapTokensForETH(uint256 tokenAmount) internal returns (uint256 ethBalance) {
        uint256 ethBalBefore = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        ethBalance = address(this).balance - ethBalBefore;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount, address recipient) private returns (uint256) {
        (uint256 amountA,,) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            recipient,
            block.timestamp
        );
        return amountA;
    }

    function changeFees(
        uint256 liquidityBuy,
        uint256 mainBuy,
        uint256 secondaryBuy,
        uint256 liquiditySell,
        uint256 mainSell,
        uint256 secondarySell
    ) external onlyOwner {
        if (!buyTaxesSettled || !sellTaxesSettled) {
            revert InvalidConfiguration();
        }
        FeeInfo memory _buyFees;
        _buyFees.liquidity = liquidityBuy;
        _buyFees.main = mainBuy;
        _buyFees.secondary = secondaryBuy;

        FeeInfo memory _sellFees;
        _sellFees.liquidity = liquiditySell;
        _sellFees.main = mainSell;
        _sellFees.secondary = secondarySell;

        (_buyFees.proof, _sellFees.proof) = launchedAt != 0 ? _calculateProofFee() : (2,2);
        _validateFees(_buyFees, _sellFees);
        buyFees = _buyFees;
        sellFees = _sellFees;
    }

    function _calculateProofFee() internal returns (uint256, uint256) {
        uint256 secondsPassed = block.timestamp - launchedAt;
        if (secondsPassed > 31 days) {
            proofFeeRemoved = true;
            return (0,0);
        } else if (secondsPassed > 1 days) {
            proofFeeReduced = true;
            return (1,1);
        } else {
            return (2,2);
        }
    }

    function _validateFees(FeeInfo memory _buyFees, FeeInfo memory _sellFees) internal view {
        _buyFees.total = _buyFees.liquidity + _buyFees.main + _buyFees.secondary;
        if (_buyFees.total == 0) {
            _buyFees.proof = 0;
        } else {
             _buyFees.total += _buyFees.proof;
        }

        _sellFees.total = _sellFees.liquidity + _sellFees.main + _sellFees.secondary;
        if (_sellFees.total == 0) {
            _sellFees.proof = 0;
        } else {
            _sellFees.total += _sellFees.proof;
        }

        if (_buyFees.total > limits.maxBuyFee || _sellFees.total > limits.maxSellFee) {
            revert InvalidConfiguration();
        }

    }

    function setCheckMaxHoldingsEnabled(bool _enabled) external onlyOwner{
        checkMaxHoldings = _enabled;
    }

    function setFeeExempt(address account, bool value) public onlyOwner {
        userInfo[account].isFeeExempt = value;
    }

    function setFeeExempt(address[] memory accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i; i < len; i++) {
            userInfo[accounts[i]].isFeeExempt = true;
        }
    }

    function setMainWallet(address newWallet) external onlyOwner {
        mainWallet = payable(newWallet);
    }

    function setSecondaryWallet(address newWallet) external onlyOwner {
        secondaryWallet = payable(newWallet);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAtAmount(uint256 amount) external onlyOwner {
        swapTokensAtAmount = amount;
    }

    function setMaxSwapsPerBlock(uint256 _maxSwaps) external onlyOwner {
        maxSwapsPerBlock = _maxSwaps;
    }

    function _setWhitelisted(address[] memory accounts) internal {
        uint256 len = accounts.length;
        for (uint256 i; i < len; i++) {
            userInfo[accounts[i]].isWhitelisted = true;
        }
    }

    function withdrawStuckTokens() external onlyOwner {
        super._update(address(this), _msgSender(), balanceOf(address(this)) - feeTokens.total);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return totalSupply() - balanceOf(address(0xdead));
    }

    modifier lockTheSwap() {
        swapping = 2;
        _;
        swapping = 1;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function version() public pure returns (uint8) {
        return 3;
    }

    receive() external payable {}
 
}