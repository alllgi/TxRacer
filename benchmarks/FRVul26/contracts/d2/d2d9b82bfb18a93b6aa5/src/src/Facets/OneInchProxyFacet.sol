// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AggregatorProxy} from "src/Helpers/AggregatorProxy.sol";

contract OneInchProxyFacet is AggregatorProxy {
    constructor(address _oneInch) AggregatorProxy(_oneInch) {}

    function callOneInch(uint256 fromTokenWithFee, uint256 fromAmt, uint256 toTokenWithFee, bytes calldata callData)
        external
        payable
    {
        _callAggregator(fromTokenWithFee, fromAmt, toTokenWithFee, callData);
    }
}
