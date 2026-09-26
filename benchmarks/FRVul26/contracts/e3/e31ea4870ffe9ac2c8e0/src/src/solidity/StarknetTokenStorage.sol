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

import "starkware/solidity/libraries/NamedStorage.sol";
import "starkware/starknet/solidity/IStarknetMessaging.sol";

abstract contract StarknetTokenStorage {
    // Named storage slot tags.
    string internal constant BRIDGED_TOKEN_TAG = "STARKNET_ERC20_TOKEN_BRIDGE_TOKEN_ADDRESS";
    string internal constant L2_BRIDGE_TAG = "STARKNET_TOKEN_BRIDGE_L2_TOKEN_CONTRACT";
    string internal constant MANAGER_TAG = "STARKNET_TOKEN_BRIDGE_MANAGER_SLOT_TAG";
    string internal constant MESSAGING_CONTRACT_TAG = "STARKNET_TOKEN_BRIDGE_MESSAGING_CONTRACT";
    string internal constant DEPOSITOR_ADDRESSES_TAG = "STARKNET_TOKEN_BRIDGE_DEPOSITOR_ADDRESSES";

    enum TokenStatus {
        Unknown,
        Pending,
        Active,
        Deactivated
    }

    struct TokenSettings {
        TokenStatus tokenStatus;
        bytes32 deploymentMsgHash;
        uint256 pendingDeploymentExpiration;
        uint256 maxTotalBalance;
        bool withdrawalLimitApplied;
    }

    // Slot = Web3.keccak(text="TokenSettings_Storage_Slot").
    bytes32 constant tokenSettingsSlot =
        0xc59c20aaa96597268f595db30ec21108a505370e3266ed3a6515637f16b8b689;

    function tokenSettings()
        internal
        pure
        returns (mapping(address => TokenSettings) storage _tokenSettings)
    {
        assembly {
            _tokenSettings.slot := tokenSettingsSlot
        }
    }

    // Storage Getters.
    function manager() internal view returns (address) {
        return NamedStorage.getAddressValue(MANAGER_TAG);
    }

    function l2TokenBridge() internal view returns (uint256) {
        return NamedStorage.getUintValue(L2_BRIDGE_TAG);
    }

    function messagingContract() internal view returns (IStarknetMessaging) {
        return IStarknetMessaging(NamedStorage.getAddressValue(MESSAGING_CONTRACT_TAG));
    }

    // Storage Setters.
    function setManager(address contract_) internal {
        NamedStorage.setAddressValueOnce(MANAGER_TAG, contract_);
    }

    function l2TokenBridge(uint256 value) internal {
        NamedStorage.setUintValueOnce(L2_BRIDGE_TAG, value);
    }

    function messagingContract(address contract_) internal {
        NamedStorage.setAddressValueOnce(MESSAGING_CONTRACT_TAG, contract_);
    }
}
