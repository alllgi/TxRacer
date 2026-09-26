// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.26;

import "@openzeppelin/contracts@4.9.6/access/Ownable.sol";
import "@openzeppelin/contracts@4.9.6/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.6/token/ERC20/utils/SafeERC20.sol";

contract AnyoneProtocolToken is ERC20, Ownable {
    using SafeERC20 for IERC20;

    address public constant ZERO_ADDRESS = address(0);

    bool public launched;

    uint256 public launchBlock;
    uint256 public launchTime;

    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public isBot;
    mapping(address => bool) public isExcludedFromLimits;

    event Launch();
    event WithdrawStuckTokens(address token, uint256 amount);
    event ExcludeFromLimits(address indexed account, bool value);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor(address _owner) ERC20("ANyONe Protocol", "ANYONE") {
        address sender = _msgSender();

        _excludeFromLimits(sender, true);
        _excludeFromLimits(_owner, true);
        _excludeFromLimits(ZERO_ADDRESS, true);
        _excludeFromLimits(address(this), true);
        _excludeFromLimits(0x61fFE014bA17989E743c5F6cB21bF9697530B21e, true); // Uniswap V3 QuoterV2

        _mint(_owner, 100_000_000 ether);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Trigger the launch of the token
     */
    function launch(address uniswapV3Pair) public payable onlyOwner {
        require(!launched, "AnyoneProtocolToken: Already launched.");
        require(
            uniswapV3Pair != ZERO_ADDRESS,
            "AnyoneProtocolToken: Address 0."
        );
        _setAutomatedMarketMakerPair(uniswapV3Pair, true);
        launched = true;
        launchBlock = block.number;
        launchTime = block.timestamp;
        emit Launch();
    }

    /**
     * @dev Withdraw any amount of native or ERC20 tokens from the contract
     * excluding self token
     */
    function withdrawStuckTokens(address tkn) public onlyOwner {
        require(
            tkn != address(this),
            "AnyoneProtocolToken: Cannot withdraw self"
        );
        address sender = _msgSender();
        uint256 amount;
        if (tkn == ZERO_ADDRESS) {
            bool success;
            amount = address(this).balance;
            require(amount > 0, "AnyoneProtocolToken: No native tokens");
            (success, ) = address(sender).call{value: amount}("");
            require(
                success,
                "AnyoneProtocolToken: Failed to withdraw native tokens"
            );
        } else {
            amount = IERC20(tkn).balanceOf(address(this));
            require(amount > 0, "AnyoneProtocolToken: No tokens");
            IERC20(tkn).safeTransfer(sender, amount);
        }
        emit WithdrawStuckTokens(tkn, amount);
    }

    /**
     * @dev Exclude (or not) accounts from limits
     */
    function excludeFromLimits(address[] calldata accounts, bool value)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _excludeFromLimits(accounts[i], value);
        }
    }

    /**
     * @dev Set account as an AMM for Uniswap
     *
     * NOTE The effect of this function cannot be reverted
     */
    function setAutomatedMarketMakerPair(address account, bool value)
        public
        onlyOwner
    {
        require(
            !automatedMarketMakerPairs[account],
            "AnyoneProtocolToken: AMM Pair already set."
        );
        require(account != ZERO_ADDRESS, "AnyoneProtocolToken: Address 0.");
        _setAutomatedMarketMakerPair(account, value);
    }

    /**
     * @dev Set accounts (or not) as bots
     */
    function setBots(address[] calldata accounts, bool value) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (
                (!automatedMarketMakerPairs[accounts[i]]) &&
                (accounts[i] != address(this)) &&
                (accounts[i] != ZERO_ADDRESS)
            ) _setBots(accounts[i], value);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal virtual override {
        address sender = _msgSender();
        require(!isBot[from], "AnyoneProtocolToken: Bot detected.");
        require(
            sender == from || !isBot[sender],
            "AnyoneProtocolToken: Bot detected."
        );
        require(
            tx.origin == from || tx.origin == sender || !isBot[tx.origin],
            "AnyoneProtocolToken: Bot detected."
        );
        require(
            launched || isExcludedFromLimits[from] || isExcludedFromLimits[to],
            "AnyoneProtocolToken: Not launched."
        );
    }

    function _excludeFromLimits(address account, bool value) internal virtual {
        isExcludedFromLimits[account] = value;
        emit ExcludeFromLimits(account, value);
    }

    function _setBots(address account, bool value) internal virtual {
        isBot[account] = value;
    }

    function _setAutomatedMarketMakerPair(address account, bool value)
        internal
        virtual
    {
        automatedMarketMakerPairs[account] = value;
        emit SetAutomatedMarketMakerPair(account, value);
    }
}
