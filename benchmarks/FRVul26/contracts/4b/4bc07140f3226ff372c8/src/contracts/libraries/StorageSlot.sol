// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title StorageSlot
/// @notice Provide functions to easily read and write different type of
/// values at specific slots in storage.
library StorageSlot {
    /// @notice Enable to set a uint256 value at a specific slot in storage.
    /// @param slot Slot to be written in.
    /// @param value Value to be written in the slot.
    function setUint256(bytes32 slot, uint256 value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    /// @notice Enable to get a uint256 value at a specific slot in storage.
    /// @param slot Slot to get value from.
    function getUint256(bytes32 slot) internal view returns (uint256 value) {
        assembly {
            value := sload(slot)
        }
    }

    /// @notice Enable to set an address value at a specific slot in storage.
    /// @param slot Slot to be written in.
    /// @param value Value to be written in the slot.
    function setAddress(bytes32 slot, address value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    /// @notice Enable to get a address value at a specific slot in storage.
    /// @param slot Slot to get value from.
    function getAddress(bytes32 slot) internal view returns (address value) {
        assembly {
            value := sload(slot)
        }
    }

    /// @notice Enable to set a bool value at a specific slot in storage.
    /// @param slot Slot to be written in.
    /// @param value Value to be written in the slot.
    function setBool(bytes32 slot, bool value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    /// @notice Enable to get a bool value at a specific slot in storage.
    /// @param slot Slot to get value from.
    function getBool(bytes32 slot) internal view returns (bool value) {
        assembly {
            value := sload(slot)
        }
    }
}
