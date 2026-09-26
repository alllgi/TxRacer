// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BitgetToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        address vault
    ) ERC20(name, symbol) {
        _mint(vault, 2e9 * 1e18);
    }
}
