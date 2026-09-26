// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISuperBridge {
    function bridge(
        address receiver_,
        uint256 amount_,
        uint256 msgGasLimit_,
        address connector_,
        bytes calldata execPayload_,
        bytes calldata options_
    ) external payable;
}
