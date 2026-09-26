// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

interface IWNativeRelayer {
    function owner() external view returns (address);
    function withdraw(uint256 _amount) external;
    function setCallerOk(address[] calldata whitelistedCallers, bool isOk) external;
}
