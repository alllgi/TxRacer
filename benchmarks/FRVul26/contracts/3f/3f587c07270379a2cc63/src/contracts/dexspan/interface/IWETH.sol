// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

abstract contract IWETH is IERC20Upgradeable {
    function deposit() external payable virtual;

    function withdraw(uint256 amount) external virtual;
}
