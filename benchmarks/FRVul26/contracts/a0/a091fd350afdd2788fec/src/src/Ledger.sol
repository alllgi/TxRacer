// SPDX-License-Identifier: MIT

/**
 * Ledger Ai  |  Improve Governance, Reduce Risk, and Strengthen Outcomes
 * Ticker: $LEDGER
 * TG: @LedgerAI_Aura
 * X: x.com/LedgerAI_Aura
 * Web: http://ledgerai.co/
 */

pragma solidity 0.8.23;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUniswapV2Router02} from "./IUniswapV2Router02.sol";
import {IUniswapV3Router} from "./IUniswapV3Router.sol";
import {IUniswapV2Factory} from "./IUniswapV2Factory.sol";
import {IUniswapV3Factory} from "./IUniswapV3Factory.sol";

contract Ledger is ERC20, Ownable {
    using SafeERC20 for IERC20;

    struct Tax {
        uint256 operationsBuyFee;
        uint256 operationsSellFee;
        uint256 marketingBuyFee;
        uint256 marketingSellFee;
        uint256 totalBuyFee;
        uint256 totalSellFee;
    }

    Tax private TAX_STRUCTURE_1 = Tax(90, 90, 10, 10, 100, 100); // 10% BUY/SELL TAX
    Tax private TAX_STRUCTURE_2 = Tax(45, 45, 5, 5, 50, 50); // 5% BUY/SELL TAX
    Tax private TAX_STRUCTURE_3 = Tax(36, 36, 4, 4, 40, 40); // 4% BUY/SELL TAX
    Tax private TAX_STRUCTURE_4 = Tax(0, 45, 0, 5, 0, 50); // 0% BUY TAX, 5% SELL TAX
    Tax private TAX_STRUCTURE_5 = Tax(9, 9, 1, 1, 10, 10); // 1% BUY/SELL TAX
    Tax private TAX_STRUCTURE_FINAL = Tax(0, 0, 0, 0, 0, 0); // NO TAX
    Tax public CURRENT_TAX_STRUCTURE = TAX_STRUCTURE_1;

    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;

    IUniswapV2Router02 public immutable uniswapV2Router;
    IUniswapV3Router public immutable uniswapV3Router;
    address public uniswapV2Pair;
    address public uniswapV3Pair;
    bool private v3LPProtectionEnabled;

    bool private swapping;
    uint256 public swapTokensAtAmount;
    address public operationsAddress;
    address public marketingAddress;

    uint256 public tradingActiveBlock = 0;
    mapping(address => bool) public markedAsSniper;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;

    uint256 public tokensForOperations;
    uint256 public tokensForMarketing;

    bool public oncePerBlockEnabled = true;
    uint256 private lastSwapBlock;
    uint256 public maxSwapsPerBlock = 1;
    uint256 private swapsThisBlock = 0;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event EnabledTrading();
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdatedOperationsAddress(address indexed newWallet);
    event UpdatedMarketingAddress(address indexed newWallet);
    event MaxTransactionExclusion(address _address, bool excluded);
    event OwnerForcedSwapBack(uint256 timestamp);
    event TransferForeignToken(address token, uint256 amount);
    event UpdatedTaxStructure(uint8 structure);

    constructor(
        address _operationsWallet,
        address _marketingWallet
    ) payable ERC20("Ledger Ai", "LEDGER") Ownable(msg.sender) {
        uint256 totalSupply = 3_141_592_654 * 1e18;

        maxBuyAmount = (totalSupply * 2) / 100; // 2%
        maxSellAmount = (totalSupply * 1) / 100; // 1%
        swapTokensAtAmount = (totalSupply * 5) / 10000; // 0.05 %

        operationsAddress = address(_operationsWallet);
        marketingAddress = address(_marketingWallet);

        // initialize V2 router
        uniswapV2Router = IUniswapV2Router02(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
        );

        // initialize V3 router
        uniswapV3Router = IUniswapV3Router(
            address(0xE592427A0AEce92De3Edee1F18E0157C05861564)
        );

        v3LPProtectionEnabled = true;

        excludeFromFees(msg.sender, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        excludeFromFees(address(operationsAddress), true);
        excludeFromFees(address(marketingAddress), true);

        uint256 opsSupply = (totalSupply * 75) / 100;
        uint256 lpSupply = totalSupply - opsSupply;

        _mint(msg.sender, opsSupply);
        _mint(address(this), lpSupply);
    }

    receive() external payable {}

    fallback() external payable {}

    function updateTaxStructure(uint8 _structure) external onlyOwner {
        require(
            _structure > 0 && _structure <= 5,
            "Invalid Tax Structure: Value must be 1, 2, or 3"
        );
        if (_structure == 1) {
            CURRENT_TAX_STRUCTURE = TAX_STRUCTURE_1;
        } else if (_structure == 2) {
            CURRENT_TAX_STRUCTURE = TAX_STRUCTURE_2;
        } else if (_structure == 3) {
            CURRENT_TAX_STRUCTURE = TAX_STRUCTURE_3;
        } else if (_structure == 4) {
            CURRENT_TAX_STRUCTURE = TAX_STRUCTURE_4;
        } else if (_structure == 5) {
            CURRENT_TAX_STRUCTURE = TAX_STRUCTURE_5;
        }
        emit UpdatedTaxStructure(_structure);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) external onlyOwner {
        require(
            pair != uniswapV2Pair,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount must be greater than 0");

        if (!tradingActive) {
            require(
                _isExcludedFromFees[from] || _isExcludedFromFees[to],
                "Trading is not active."
            );
        } else {
            require(!markedAsSniper[from], "Snipers cannot transfer tokens");
        }

        if (v3LPProtectionEnabled) {
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                require(
                    from != address(uniswapV3Pair) &&
                        to != address(uniswapV3Pair),
                    "V3 Pool is currently protected, transfers are disabled"
                );
            }
        }

        if (limitsInEffect) {
            if (
                to != address(0xdead) &&
                !_isExcludedFromFees[from] &&
                !_isExcludedFromFees[to]
            ) {
                //when buy
                if (automatedMarketMakerPairs[from]) {
                    require(
                        amount <= maxBuyAmount,
                        "Buy transfer amount exceeds the max buy."
                    );
                }
                //when sell
                else if (automatedMarketMakerPairs[to]) {
                    require(
                        amount <= maxSellAmount,
                        "Sell transfer amount exceeds the max sell."
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap && swapEnabled && !swapping && automatedMarketMakerPairs[to]
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = true;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            Tax memory tax = CURRENT_TAX_STRUCTURE;
            // on sell

            if (automatedMarketMakerPairs[to] && tax.totalSellFee > 0) {
                fees = (amount * tax.totalSellFee) / 1000;
                tokensForOperations +=
                    (fees * tax.operationsSellFee) /
                    tax.totalSellFee;

                tokensForMarketing +=
                    (fees * tax.marketingSellFee) /
                    tax.totalSellFee;
            }
            // on buy
            else if (automatedMarketMakerPairs[from] && tax.totalBuyFee > 0) {
                fees = (amount * tax.totalBuyFee) / 1000;
                tokensForOperations +=
                    (fees * tax.operationsBuyFee) /
                    tax.totalBuyFee;

                tokensForMarketing +=
                    (fees * tax.marketingBuyFee) /
                    tax.totalBuyFee;
            }

            if (fees > 0) {
                super._update(from, address(this), fees);
            }

            amount -= fees;
        }

        super._update(from, to, amount);
    }

    function getExpectedEthForTokens(
        uint256 tokenAmount
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uint256[] memory amounts = uniswapV2Router.getAmountsOut(
            tokenAmount,
            path
        );
        return amounts[1];
    }

    function swapTokensForEth(
        uint256 tokenAmount,
        uint256 minOutputAmount
    ) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            minOutputAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        if (block.number != lastSwapBlock) {
            lastSwapBlock = block.number;
            swapsThisBlock = 0;
        }

        if (oncePerBlockEnabled && swapsThisBlock >= maxSwapsPerBlock) {
            return;
        }

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForOperations + tokensForMarketing;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > swapTokensAtAmount * 4) {
            contractBalance = swapTokensAtAmount * 4;
        }

        // Calculate the minimum output amount (e.g., 95% of expected output)
        uint256 expectedEthOutput = getExpectedEthForTokens(contractBalance);
        uint256 minOutputAmount = (expectedEthOutput * 95) / 100; // 5% slippage tolerance

        swapTokensForEth(contractBalance, minOutputAmount);

        uint256 ethBalance = address(this).balance;
        uint256 ethForOperations = (ethBalance * tokensForOperations) /
            totalTokensToSwap;

        tokensForOperations = 0;
        tokensForMarketing = 0;

        swapsThisBlock += 1;

        Address.sendValue(payable(operationsAddress), ethForOperations);
        Address.sendValue(payable(marketingAddress), address(this).balance);
    }

    function transferForeignToken(
        address _token,
        address _to
    ) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");
        require(_to != address(0), "_to address cannot be 0");
        require(_token != address(this), "Can't withdraw LedgerAI token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
        return true;
    }

    function setOperationsAddress(
        address _operationsAddress
    ) external onlyOwner {
        require(
            _operationsAddress != address(0),
            "_operationsAddress address cannot be 0"
        );
        operationsAddress = payable(_operationsAddress);
        emit UpdatedOperationsAddress(_operationsAddress);
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        require(
            _marketingAddress != address(0),
            "_marketingAddress address cannot be 0"
        );
        marketingAddress = payable(_marketingAddress);
        emit UpdatedMarketingAddress(_marketingAddress);
    }

    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function restoreLimits() external onlyOwner {
        limitsInEffect = true;
    }

    function flagSniper(address wallet) external onlyOwner {
        require(!markedAsSniper[wallet], "Wallet is already flagged.");
        markedAsSniper[wallet] = true;
    }

    function massFlagSnipers(address[] calldata wallets) external onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            markedAsSniper[wallets[i]] = true;
        }
    }

    function unflagSniper(address wallet) external onlyOwner {
        require(markedAsSniper[wallet], "Wallet is already not marked.");
        markedAsSniper[wallet] = false;
    }

    function massUnflagSnipers(address[] calldata wallets) external onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            markedAsSniper[wallets[i]] = false;
        }
    }

    function recoverETH() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(success, "Failed to recover ETH");
    }

    function prepareLaunch() external onlyOwner {
        require(!tradingActive, "Trading is already active, cannot relaunch.");

        // Check if V2 pair exists, if not create it
        address calculatedV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .getPair(address(this), uniswapV2Router.WETH());

        if (calculatedV2Pair == address(0)) {
            // create pair
            uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), uniswapV2Router.WETH());
        } else {
            uniswapV2Pair = calculatedV2Pair;
        }

        // Check if V3 pool exists, if not create it
        address calculatedV3Pair = IUniswapV3Factory(uniswapV3Router.factory())
            .getPool(
                address(this),
                uniswapV2Router.WETH(),
                10000 // fee tier
            );

        if (calculatedV3Pair == address(0)) {
            uniswapV3Pair = IUniswapV3Factory(uniswapV3Router.factory())
                .createPool(address(this), uniswapV2Router.WETH(), 10000);
        } else {
            uniswapV3Pair = calculatedV3Pair;
        }

        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        excludeFromFees(address(uniswapV2Router), true);

        require(
            address(this).balance > 0,
            "Must have ETH on contract to launch"
        );
        require(
            balanceOf(address(this)) > 0,
            "Must have Tokens on contract to launch"
        );

        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV3Router), type(uint256).max);

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );
    }

    function enableTrading() external onlyOwner {
        require(!tradingActive, "Cannot reenable trading");
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
        emit EnabledTrading();
    }

    function prepareForMigration() external onlyOwner {
        limitsInEffect = false;
        swapTokensAtAmount = totalSupply();
        CURRENT_TAX_STRUCTURE = TAX_STRUCTURE_FINAL;
        maxBuyAmount = totalSupply();
        maxSellAmount = totalSupply();
        if (balanceOf(address(this)) > 0) {
            super._update(address(this), msg.sender, balanceOf(address(this)));
        }
    }

    function disableV3LPProtection() external onlyOwner {
        require(
            v3LPProtectionEnabled,
            "V3 LP Protection already disabled forever!"
        );
        v3LPProtectionEnabled = false;
    }

    function setSwapRestrictions(
        bool _enabled,
        uint256 _maxSwaps
    ) external onlyOwner {
        require(_maxSwaps > 0, "Max swaps per block must be greater than 0");
        oncePerBlockEnabled = _enabled;
        maxSwapsPerBlock = _maxSwaps;
    }
}
