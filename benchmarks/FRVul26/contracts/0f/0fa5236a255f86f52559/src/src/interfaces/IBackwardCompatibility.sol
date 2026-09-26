// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title IBackwardCompatibility
/// @notice Returns the address of the TokenTransferProxy contract
interface IBackwardCompatibility {
    /// @notice Returns the address of the TokenTransferProxy contract
    /// In version 6 of the Augustus protocol, the TokenTransferProxy contract is deprecated.
    /// The Diamond contract now directly handles token approvals. However, for backward compatibility
    /// and to support integrations that still use getTokenTransferProxy() for obtaining the TokenTransferProxy
    /// contract address, this method remains operational. It facilitates smoother migration to the updated
    /// protocol design.
    function getTokenTransferProxy() external view returns (address tokenTransferProxy);
}
