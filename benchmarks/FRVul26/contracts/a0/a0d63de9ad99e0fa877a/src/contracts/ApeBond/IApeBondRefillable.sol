// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "./IApeBond.sol";

interface IApeBondRefillable is IApeBond {
    function refillPayoutToken(uint256 _refillAmount) external;
}
