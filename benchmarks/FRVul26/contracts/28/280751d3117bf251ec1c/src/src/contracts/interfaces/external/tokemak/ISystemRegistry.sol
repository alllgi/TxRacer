// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;

import { IAutopoolRegistry } from "src/contracts/interfaces/external/tokemak/IAutopoolRegistry.sol";

/*
 * Lighter version of the Tokemak ISystemRegistry interface.
 * A more extensive version can be found in the core project:
 * v2-core/src/interfaces/vault/ISystemRegistry.sol
 */
interface ISystemRegistry {
    /// @notice Get the AutopoolRegistry for this system
    /// @return registry instance of the registry for this system
    function autoPoolRegistry() external view returns (IAutopoolRegistry registry);

    /// @notice Vault factory lookup by type
    /// @return vaultFactory instance of the vault factory for this vault type
    function getLMPVaultFactoryByType(bytes32 vaultType) external view returns (address vaultFactory);

    /// @notice Get the access Controller for this system
    /// @return controller instance of the access controller for this system
    function accessController() external view returns (address controller);
}
