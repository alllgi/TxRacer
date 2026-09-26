// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol';

contract Shifu is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    uint256 private constant TOTAL_SUPPLY = 100_000_000_000 * 10 ** 18;

    /// @notice Mint the total supply to multi-sig treasury for disbursement
    constructor(
        string memory _name,
        string memory _symbol,
        address _treasury
    ) ERC20(_name, _symbol) ERC20Permit(_name) Ownable(_msgSender()) {
        _mint(_treasury, TOTAL_SUPPLY);
    }
}