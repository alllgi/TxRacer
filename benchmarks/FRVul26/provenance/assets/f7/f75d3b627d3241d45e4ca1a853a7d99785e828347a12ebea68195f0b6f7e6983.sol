// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../libraries/TokenLib.sol";

contract MockTokenLib {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) external {
        TokenLib.safeTransfer(token, to, value);
    }

    function trySafeTransfer(
        address token,
        address to,
        uint256 value
    ) external returns (bool success) {
        return TokenLib.trySafeTransfer(token, to, value);
    }
}