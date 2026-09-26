// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibReentrancyGuard} from "../Libraries/LibReentrancyGuard.sol";

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    modifier nonReentrant() {
        LibReentrancyGuard.ReentrancyStorage storage s = LibReentrancyGuard.reentrancyStorage();
        if (s.status == _ENTERED) revert LibReentrancyGuard.ReentrancyError();
        s.status = _ENTERED;
        _;
        s.status = _NOT_ENTERED;
    }
}
