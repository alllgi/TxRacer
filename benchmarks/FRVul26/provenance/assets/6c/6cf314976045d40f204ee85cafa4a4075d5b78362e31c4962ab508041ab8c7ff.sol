// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev ERC20 token that charges a fixed 10% tax on every transfer.
contract MockTaxableToken is ERC20 {
    uint256 public constant TAX_BPS = 1000;
    uint256 public constant BPS_DENOMINATOR = 10_000;

    uint8 private _decimals;
    address public immutable taxCollector;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address taxCollector_
    ) ERC20(name_, symbol_) {
        require(taxCollector_ != address(0), "tax collector is zero");
        _decimals = decimals_;
        taxCollector = taxCollector_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 taxAmount = (amount * TAX_BPS) / BPS_DENOMINATOR;
        uint256 receiveAmount = amount - taxAmount;

        if (receiveAmount > 0) {
            super._transfer(from, to, receiveAmount);
        }

        if (taxAmount > 0) {
            super._transfer(from, taxCollector, taxAmount);
        }
    }
}
