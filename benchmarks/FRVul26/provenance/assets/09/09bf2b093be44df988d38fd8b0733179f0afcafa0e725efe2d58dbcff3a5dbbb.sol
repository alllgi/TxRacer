// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title IVersionFacet
/// @notice Returns the current implementation version
interface IVersionFacet {
    /// @notice Returns the current implementation version
    function version() external pure returns (string memory);
}
