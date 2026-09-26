// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title Chainflip Receiver Interface
/// @dev The ICFReceiver interface is the interface required to receive tokens and
/// cross-chain calls from the Chainflip Protocol.
interface ICFReceiver {
    /// @notice Called by Chainflip protocol when receiving tokens on destination chain.
    /// Contains the logic that will run the payload calldata content.
    /// @param sourceChain Source chain according to the Chainflip Protocol's nomenclature.
    /// @param sourceAddress Source address on the source chain.
    /// @param payload Value provided by Squid containing the calldata that will be ran on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt).
    /// @param token Address of the ERC20 token received. 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    /// in case of native token.
    /// @param amount Amount of ERC20 token received. This will match msg.value for native tokens.
    function cfReceive(
        uint32 sourceChain,
        bytes calldata sourceAddress,
        bytes calldata payload,
        address token,
        uint256 amount
    ) external payable;
}
