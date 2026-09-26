// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

library RouterErrors {
    error ReturnAmountIsNotEnough(uint256 result, uint256 minReturn);
    error InvalidMsgValue();
    error ERC20TransferFailed();
    error Permit2TransferFromFailed();
    error ApproveFailed();
    error TaxTokenDetected();
    error NativeAssetTransferFailed();
}
