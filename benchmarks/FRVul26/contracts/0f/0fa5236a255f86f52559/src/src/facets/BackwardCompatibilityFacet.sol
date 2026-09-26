// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IBackwardCompatibility } from "../interfaces/IBackwardCompatibility.sol";

/// @title BackwardCompatibilityFacet
contract BackwardCompatibilityFacet is IBackwardCompatibility {
    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBackwardCompatibility
    function getTokenTransferProxy() external view override returns (address tokenTransferProxy) {
        // Return the address of the tokenTransferProxy contract (AugustusV6 Diamond)
        return address(this);
    }
}
