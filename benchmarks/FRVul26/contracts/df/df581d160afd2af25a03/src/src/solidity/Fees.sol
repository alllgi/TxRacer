/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;

// Estimate cost for L1-L2 message handler.
uint256 constant DEPOSIT_FEE_GAS = 20000;
uint256 constant DEPLOYMENT_FEE_GAS = 100000;

// We don't have a solid way to gauge block gas price
// (block.basefee cannot be used).
uint256 constant DEFAULT_WEI_PER_GAS = 5 * 10**9;

abstract contract Fees {
    // Effectively no minimum fee on testnet.
    uint256 immutable MIN_FEE = (block.chainid == 1) ? 10**12 : 1;
    uint256 constant MAX_FEE = 10**16;

    function estimateDepositFee() internal pure returns (uint256) {
        return DEPOSIT_FEE_GAS * DEFAULT_WEI_PER_GAS;
    }

    function estimateEnrollmentFee() internal pure returns (uint256) {
        return DEPLOYMENT_FEE_GAS * DEFAULT_WEI_PER_GAS;
    }

    function checkFee(uint256 feeWei) internal view {
        require(feeWei >= MIN_FEE, "INSUFFICIENT_FEE_VALUE");
        require(feeWei <= MAX_FEE, "FEE_VALUE_TOO_HIGH");
    }
}
