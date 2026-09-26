// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAA {
    struct Intent {
        uint256 intentId;
        uint256 ensureMinimumWETH;
        bytes params;
    }

    function initialize(address admin) external;

    function initialize(address operator, address admin, uint256 outerGas) external;

    function handleIntent(Intent calldata intent, bytes32[] calldata) external;
}
