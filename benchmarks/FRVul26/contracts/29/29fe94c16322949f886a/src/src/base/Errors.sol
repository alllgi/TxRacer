// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// Signature Errors
error OrderInvalidSigner();
error InvalidEIP721Signature();
error InvalidEIP1271Signature();
error InvalidETHSIGNSignature();
error InvalidSignatureType();
error InvalidSignatureLength();
error InvalidSignatureValueS();
error InvalidSignatureValueV();


// Validation Errors
error ZeroNonce();
error InvalidNonce();
error OrderExpired();
error OrdersLengthsMismatch();
error TokensLengthsMismatch();
error CommandsLengthsMismatch();
error InvalidPermit2Commands();
error InvalidCommand();
error InvalidCommandsLength();
error InvalidFlags();
error PartialFillNotSupported();
error UpdatedMakerAmountsTooLow();
error ZeroMakerAmount();
error MakerAmountsLengthsMismatch();

error NotEnoughNativeToken();
error WrongWrappedTokenAddress();
error FailedToSendNativeToken();

error InvalidSender();
error ManyToManyNotSupported();

error InvalidPendingTransfersLength();
error InvalidPermit2TransfersLength();

// Partner Errors
error PartnerAlreadyRegistered();
error PartnerFeeTooHigh();
error NullBeneficiary();



