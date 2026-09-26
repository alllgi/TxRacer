// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "@openzeppelin/contracts@4.9.6/access/Ownable.sol";
import "@openzeppelin/contracts@4.9.6/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.6/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/IVerifier.sol";

contract ShiroToken is ERC20, Ownable {
    using SafeERC20 for IERC20;

    IVerifier verifier;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public constant ZERO_ADDRESS = address(0);
    address public constant DEAD_ADDRESS = address(0xdead);

    bool public limitsEnabled;
    bool public cooldownEnabled;
    bool public launched;

    mapping(address => uint256) private _holderLastTransferBlock;
    mapping(address => bool) public isExcludedFromLimits;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public routers;
    mapping(address => bool) public isBot;

    event Launch();
    event SetLimitsEnabled(bool value);
    event SetCooldownEnabled(bool value);
    event WithdrawStuckTokens(address token, uint256 amount);
    event ExcludeFromLimits(address indexed account, bool value);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetRouter(address indexed pair, bool indexed value);
    event SetBots(address indexed account, bool value);

    error AlreadyLaunched();
    error NoTokens();
    error WithdrawFailed();
    error AMMAlreadySet();
    error RouterAlreadySet();
    error BotDetected();
    error TransferDelay();
    error NotAuthorized();

    constructor(
        string memory name_,
        string memory symbol_,
        address _verifier,
        address _uniswapV2Router,
        address _uniswapV3Router,
        address _uniswapUniversalRouter,
        address[] memory uniswapAddresses
    ) ERC20(name_, symbol_) {
        verifier = IVerifier(_verifier);
        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);

        _setRouter(_uniswapV2Router, true);
        _setRouter(_uniswapV3Router, true);
        _setRouter(_uniswapUniversalRouter, true);

        _excludeFromLimits(msg.sender, true);
        _excludeFromLimits(tx.origin, true);
        _excludeFromLimits(address(this), true);
        _excludeFromLimits(DEAD_ADDRESS, true);

        for (uint256 i = 0; i < uniswapAddresses.length; i++) {
            _excludeFromLimits(uniswapAddresses[i], true);
        }

        _mint(address(this), 1_000_000_000_000_000 ether);
    }

    receive() external payable {}

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function launch() external payable onlyOwner {
        require(!launched, AlreadyLaunched());

        IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(
            uniswapV2Router.factory()
        );

        address wethAddress = uniswapV2Router.WETH();

        address uniswapV2Pair = uniswapV2Factory.getPair(
            address(this),
            wethAddress
        );

        if (uniswapV2Pair == ZERO_ADDRESS) {
            uniswapV2Pair = uniswapV2Factory.createPair(
                address(this),
                wethAddress
            );
        }

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            tx.origin,
            block.timestamp
        );

        limitsEnabled = true;
        cooldownEnabled = true;
        launched = true;
        emit Launch();
    }

    function setLimitsEnabled(bool value) external onlyOwner {
        limitsEnabled = value;
        emit SetLimitsEnabled(value);
    }

    function setCooldownEnabled(bool value) external onlyOwner {
        cooldownEnabled = value;
        emit SetCooldownEnabled(limitsEnabled);
    }

    function withdrawStuckTokens(address tkn) external onlyOwner {
        uint256 amount;
        if (tkn == ZERO_ADDRESS) {
            bool success;
            amount = address(this).balance;
            require(amount > 0, NoTokens());
            (success, ) = msg.sender.call{value: amount}("");
            require(success, WithdrawFailed());
        } else {
            amount = IERC20(tkn).balanceOf(address(this));
            require(amount > 0, NoTokens());
            IERC20(tkn).safeTransfer(msg.sender, amount);
        }
        emit WithdrawStuckTokens(tkn, amount);
    }

    function excludeFromLimits(address[] calldata accounts, bool value)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _excludeFromLimits(accounts[i], value);
        }
    }

    function setAutomatedMarketMakerPair(address account, bool value)
        public
        onlyOwner
    {
        require(!automatedMarketMakerPairs[account], AMMAlreadySet());
        _setAutomatedMarketMakerPair(account, value);
    }

    function setRouter(address account, bool value) public onlyOwner {
        require(!routers[account], RouterAlreadySet());
        _setRouter(account, value);
    }

    function setBots(address[] calldata accounts, bool value) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (
                (!automatedMarketMakerPairs[accounts[i]]) &&
                (!routers[accounts[i]]) &&
                (accounts[i] != address(uniswapV2Router)) &&
                (accounts[i] != address(this)) &&
                (!isExcludedFromLimits[accounts[i]])
            ) _setBots(accounts[i], value);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        address origin = tx.origin;
        if (
            ((isExcludedFromLimits[from] || isExcludedFromLimits[to])) ||
            (isExcludedFromLimits[origin])
        ) {
            super._transfer(from, to, amount);
            return;
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsEnabled) {
            address sender = msg.sender;
            require(!isBot[from], BotDetected());
            require(sender == from || !isBot[sender], BotDetected());
            require(
                origin == from || origin == sender || !isBot[origin],
                BotDetected()
            );

            bool isBuy = automatedMarketMakerPairs[from] &&
                !isExcludedFromLimits[to];
            bool isSell = automatedMarketMakerPairs[to] &&
                !isExcludedFromLimits[from];
            if (isBuy) {
                require((verifier.verify(from, to)), NotAuthorized());
            } else if (!isSell && !isExcludedFromLimits[to]) {
                require((verifier.verify(from, to)), NotAuthorized());
            }

            if (cooldownEnabled) {
                if (!routers[to] && !automatedMarketMakerPairs[to]) {
                    require(
                        _holderLastTransferBlock[origin] < block.number &&
                            _holderLastTransferBlock[to] < block.number,
                        TransferDelay()
                    );
                    _holderLastTransferBlock[to] = block.number;
                    _holderLastTransferBlock[origin] = block.number;
                }
            }
        }

        super._transfer(from, to, amount);
    }

    function _excludeFromLimits(address account, bool value) internal virtual {
        isExcludedFromLimits[account] = value;
        emit ExcludeFromLimits(account, value);
    }

    function _setBots(address account, bool value) internal virtual {
        isBot[account] = value;
        emit SetBots(account, value);
    }

    function _setAutomatedMarketMakerPair(address account, bool value)
        internal
        virtual
    {
        automatedMarketMakerPairs[account] = value;
        emit SetAutomatedMarketMakerPair(account, value);
    }

    function _setRouter(address account, bool value) internal virtual {
        routers[account] = value;
        emit SetRouter(account, value);
    }
}
