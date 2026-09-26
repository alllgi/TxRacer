// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IIntentHelper {
    struct Call {
        address target;
        uint256 value;
        bytes data;
        int256 gas;
    }

    // Keep it mutable
    function parse(bytes calldata params) external returns (uint256 taxPoint, Call[] memory calls);
}
