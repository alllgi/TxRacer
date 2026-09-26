// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../DLN/DlnSource.sol";

contract MockFeeCollectorForDlnSource {
    function withdrawCollectedFees(
        DlnSource _dlnSource,
        address[] calldata _tokens
    ) external {
        _dlnSource.withdrawCollectedFees(_tokens);
    }
}
