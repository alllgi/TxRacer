// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../structs/XSwapFee.sol";

interface IFeeOracle {
    function getFee(
        uint256 amount,
        address feeToken,
        address spender,
        bytes calldata additionalData
    ) external view returns (XSwapFee memory);
}
