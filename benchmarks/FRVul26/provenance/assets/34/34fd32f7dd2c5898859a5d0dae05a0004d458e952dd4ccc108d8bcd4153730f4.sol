// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract MockSignatureVerifier {
    function submit(
        bytes32 _submissionId,
        bytes memory _signatures,
        uint8 _excessConfirmations
    ) external {}
}
