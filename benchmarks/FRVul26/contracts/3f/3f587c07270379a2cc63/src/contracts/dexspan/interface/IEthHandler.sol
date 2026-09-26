// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEthHandler {
    function withdraw(address WETH, uint256) external;
}
