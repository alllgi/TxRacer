/*
  Copyright 2019-2023 StarkWare Industries Ltd.

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

uint256 constant DEPOSIT_FEE_GAS = 20000;
uint256 constant DEPLOYMENT_FEE_GAS = 100000;
uint256 constant DEFAULT_WEI_PER_GAS = 5 * 10**9;
uint256 constant MIN_FEE = 10**12;
uint256 constant MAX_FEE = 10**16;

library Fees {
    function estimateDepositFee() internal pure returns (uint256) {
        return DEPOSIT_FEE_GAS * DEFAULT_WEI_PER_GAS;
    }

    function estimateEnrollmentFee() internal pure returns (uint256) {
        return DEPLOYMENT_FEE_GAS * DEFAULT_WEI_PER_GAS;
    }

    function checkDepositFee(uint256 feeWei) internal pure {
        checkFee(feeWei, estimateDepositFee());
    }

    function checkEnrollmentFee(uint256 feeWei) internal pure {
        checkFee(feeWei, estimateEnrollmentFee());
    }

    function checkFee(
        uint256 feeWei,
        uint256 /* feeEstimate */
    ) internal pure {
        require(feeWei >= MIN_FEE, "INSUFFICIENT_FEE_VALUE");
        require(feeWei <= MAX_FEE, "FEE_VALUE_TOO_HIGH");
    }
}
