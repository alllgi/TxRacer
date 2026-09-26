// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/*
 * Lighter version of the Tokemak IAutopoolRegistry interface.
 * A more extensive version can be found in the core project:
 * v2-core/src/interfaces/vault/IAutopoolRegistry.sol
 */
interface IAutopoolRegistry {
    /// @notice Checks if an address is a valid vault
    /// @param vaultAddress Vault address to be added
    function isVault(address vaultAddress) external view returns (bool);
}
