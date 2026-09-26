// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev Synthetic rebasing token that mimics stETH transfer behavior.
/// Internally tracks balances as shares. A nominal token transfer can credit
/// the receiver with less due to share rounding, as with stETH.
contract DummyRebasingToken is ERC20 {
    uint8 private _decimals;

    uint256 public totalShares;
    uint256 public totalPooledEther;
    mapping(address => uint256) public sharesOf;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /// @dev Sets the total pooled ether. Changing it after minting simulates a rebase.
    function setTotalPooledEther(uint256 _totalPooledEther) external {
        totalPooledEther = _totalPooledEther;
    }

    /// @dev Mint shares so that token-denominated balance equals `amount`
    /// at the current exchange rate.
    function mint(address recipient, uint256 amount) external {
        uint256 sharesToMint;
        if (totalShares == 0 || totalPooledEther == 0) {
            sharesToMint = amount;
            totalPooledEther += amount;
        } else {
            sharesToMint = (amount * totalShares) / totalPooledEther;
            totalPooledEther += amount;
        }
        totalShares += sharesToMint;
        sharesOf[recipient] += sharesToMint;
        _mint(recipient, amount);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        if (totalShares == 0) return 0;
        return (sharesOf[account] * totalPooledEther) / totalShares;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return totalPooledEther;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transferShares(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transferShares(from, to, amount);
        return true;
    }

    function _transferShares(address from, address to, uint256 amount) private {
        uint256 sharesToTransfer = (amount * totalShares) / totalPooledEther;
        require(sharesToTransfer > 0, "Transfer amount too small");
        require(sharesOf[from] >= sharesToTransfer, "Insufficient shares");

        sharesOf[from] -= sharesToTransfer;
        sharesOf[to] += sharesToTransfer;

        uint256 tokensTransferred = (sharesToTransfer * totalPooledEther) / totalShares;
        emit Transfer(from, to, tokensTransferred);
    }
}
