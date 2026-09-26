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
pragma solidity ^0.8.20;

import "starkware/solidity/libraries/Addresses.sol";
import "src/solidity/Fees.sol";
import "src/solidity/LegacyBridge.sol";

contract StarknetEthBridge is LegacyBridge {
    using Addresses for address;

    function identify() external pure override returns (string memory) {
        return "StarkWare_StarknetEthBridge_2.0_4";
    }

    function acceptDeposit(
        address, /*token*/
        uint256 amount
    ) internal override returns (uint256) {
        // Make sure msg.value is enough to cover amount. The remaining value is fee.
        require(msg.value >= amount, "INSUFFICIENT_VALUE");
        uint256 fee = msg.value - amount;
        Fees.checkFee(fee);
        // The msg.value was already credited to this contract. Fee will be passed to Starknet.
        require(address(this).balance - fee <= getMaxTotalBalance(ETH), "MAX_BALANCE_EXCEEDED");
        return fee;
    }

    function transferOutFunds(
        address, /*token*/
        uint256 amount,
        address recipient
    ) internal override {
        recipient.performEthTransfer(amount);
    }
}
