// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/// @title Commands
/// @notice Commands are used to specify how tokens are transferred
library Commands {
    bytes1 internal constant SIMPLE_TRANSFER = 0x00; // simple transfer with standard transferFrom
    bytes1 internal constant PERMIT2_TRANSFER = 0x01; // transfer using Permit2.transfer
    bytes1 internal constant CALL_PERMIT_THEN_TRANSFER = 0x02; // call permit then standard transferFrom
    bytes1 internal constant CALL_PERMIT2_THEN_TRANSFER = 0x03; // call Permit2.permit then Permit2.transfer
    bytes1 internal constant NATIVE_TRANSFER = 0x04; // wrap/unwrap native token and transfer
    bytes1 internal constant TRANSFER_TO_CONTRACT = 0x07; // transfer to bebop contract
    bytes1 internal constant TRANSFER_FROM_CONTRACT = 0x08; // transfer from bebop contract
}
