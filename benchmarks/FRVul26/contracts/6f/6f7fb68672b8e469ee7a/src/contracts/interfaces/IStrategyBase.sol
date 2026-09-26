// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice StrategyBase interface
interface IStrategyBase {
    function depositCalldata(uint256 _amount) external view returns (address, bytes memory);

    function addressToApprove() external view returns (address);

    function withdraw(uint256 _amount) external returns (uint256);

    function nav() external view returns (uint256);

    function yieldToUnderlying(uint256 amount) external view returns (uint256);

    function underlyingToYield(uint256 amount) external view returns (uint256);

    function yieldBalance() external view returns (uint256);

    function poolingManager() external view returns (address);

    function underlyingToken() external view returns (address);

    function yieldToken() external view returns (address);

    function bridge() external view returns (address);
}
