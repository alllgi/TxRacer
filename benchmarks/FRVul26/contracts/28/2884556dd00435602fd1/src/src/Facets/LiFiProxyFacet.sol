// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AggregatorProxy} from "src/Helpers/AggregatorProxy.sol";

contract LiFiProxyFacet is AggregatorProxy {
    constructor(address _liFi) AggregatorProxy(_liFi) {}

    function callLiFi(uint256 fromTokenWithFee, uint256 fromAmt, uint256 toTokenWithFee, bytes calldata callData)
        external
        payable
    {
        _callAggregator(fromTokenWithFee, fromAmt, toTokenWithFee, callData);
    }
}
