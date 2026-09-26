// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/interfaces/IVersionFacet.sol

pragma solidity 0.8.22;

/// @title IVersionFacet
/// @notice Returns the current implementation version
interface IVersionFacet {
    /// @notice Returns the current implementation version
    function version() external pure returns (string memory);
}

// File: src/facets/VersionFacet.sol

pragma solidity 0.8.22;

// Interfaces


/// @title VersionFacet
contract VersionFacet is IVersionFacet {
    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IVersionFacet
    function version() external pure returns (string memory) {
        return "6.2.0";
    }
}
