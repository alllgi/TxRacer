// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Starknet bridge interface
interface IStarknetBridgeV2 {
    function deposit(address token, uint256 amount, uint256 l2Recipient) external payable;
    function withdraw(address token, uint256 amount) external;
    function withdraw(address token, uint256 amount, address receiver) external;
    function depositCancelRequest(address token, uint256 amount, uint256 l2Recipient, uint256 nonce) external;
    function depositReclaim(address token, uint256 amount, uint256 l2Recipient, uint256 nonce) external;
}
