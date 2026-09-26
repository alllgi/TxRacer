// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Storage
import { AugustusStorage } from "../storage/AugustusStorage.sol";

/// @title PauseUtils
/// @notice Provides a modifier to check if the contract is paused
abstract contract PauseUtils is AugustusStorage {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error emitted when the contract is paused
    error ContractPaused();

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    // Check if the contract is paused, if it is, revert
    modifier whenNotPaused() {
        if (paused) {
            revert ContractPaused();
        }
        _;
    }
}
