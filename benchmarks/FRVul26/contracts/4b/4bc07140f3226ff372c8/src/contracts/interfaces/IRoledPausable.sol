// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title RoledPausable
/// @notice Provide logic to pause a contract and grant au pauser role.
/// In case of a pauser update, current pauser provide the address of the potential new
/// pauser. Potential new pauser then has to accept the role.
/// @dev Contract uses hard coded slot values for variable to prevent storage clashes when upgrading.
interface IRoledPausable {
    /// @notice Emitted when current pauser starts the update process.
    /// @param currentPauser Address of the current pauser proposing new one.
    /// @param pendingPauser Address of the potential new pauser.
    event PauserProposed(address indexed currentPauser, address indexed pendingPauser);
    /// @notice Emitted when pending pauser accepts pauser role.
    /// @param newPauser Address of the new pauser.
    event PauserUpdated(address indexed newPauser);
    /// @notice Emitted when contract is paused.
    event Paused();
    /// @notice Emitted when contract is unpaused.
    event Unpaused();

    /// @notice Thrown when a pausable function is called while the contract is paused.
    error ContractIsPaused();
    /// @notice Thrown when function is only meant to be called by current pauser.
    error OnlyPauser();
    /// @notice Thrown when function is only meant to be called by pending pauser.
    error OnlyPendingPauser();

    /// @notice Start pauser role update process by providing new pauser address.
    /// @dev Only callable by current pauser.
    /// @param newPauser Address of the potential new pauser.
    function updatePauser(address newPauser) external;

    /// @notice Let pending pauser accept pauser role.
    /// @dev Only callable by pending pauser.
    function acceptPauser() external;

    /// @notice Let pauser pause the contract.
    /// @dev Only callable by current pauser.
    function pause() external;

    /// @notice Let pauser unpause the contract.
    /// @dev Only callable by current pauser.
    function unpause() external;

    /// @notice Get pause state.
    /// @dev Return true if paused and false if not paused.
    function paused() external view returns (bool value);

    /// @notice Get pauser address.
    function pauser() external view returns (address value);

    /// @notice Get pending pauser address.
    function pendingPauser() external view returns (address value);
}
