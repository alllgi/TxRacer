// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IRoledPausable} from "../interfaces/IRoledPausable.sol";
import {StorageSlot} from "./StorageSlot.sol";

abstract contract RoledPausable is IRoledPausable {
    using StorageSlot for bytes32;

    /// Hard coded slot numbers for contract variables.
    bytes32 internal constant PAUSED_SLOT = keccak256("RoledPausable.paused");
    bytes32 internal constant PAUSER_SLOT = keccak256("RoledPausable.pauser");
    bytes32 internal constant PENDING_PAUSER_SLOT = keccak256("RoledPausable.pendingPauser");

    /// @notice msg.sender has the pauser role by default.
    constructor() {
        _setPauser(msg.sender);
    }

    /// @notice Check if contract is paused and revert if so.
    /// @dev Meant to be used in inheritor contract.
    modifier whenNotPaused() {
        if (paused()) revert ContractIsPaused();
        _;
    }

    /// @inheritdoc IRoledPausable
    function updatePauser(address newPauser) external {
        _onlyPauser();
        PENDING_PAUSER_SLOT.setAddress(newPauser);
        emit PauserProposed(msg.sender, newPauser);
    }

    /// @inheritdoc IRoledPausable
    function acceptPauser() external {
        if (msg.sender != pendingPauser()) revert OnlyPendingPauser();
        _setPauser(msg.sender);
        PENDING_PAUSER_SLOT.setAddress(address(0));
    }

    /// @inheritdoc IRoledPausable
    function pause() external virtual {
        _onlyPauser();
        PAUSED_SLOT.setBool(true);
        emit Paused();
    }

    /// @inheritdoc IRoledPausable
    function unpause() external virtual {
        _onlyPauser();
        PAUSED_SLOT.setBool(false);
        emit Unpaused();
    }

    /// @inheritdoc IRoledPausable
    function paused() public view returns (bool value) {
        value = PAUSED_SLOT.getBool();
    }

    /// @inheritdoc IRoledPausable
    function pauser() public view returns (address value) {
        value = PAUSER_SLOT.getAddress();
    }

    /// @inheritdoc IRoledPausable
    function pendingPauser() public view returns (address value) {
        value = PENDING_PAUSER_SLOT.getAddress();
    }

    /// @notice Update pauser value in storage.
    /// @param _pauser New pauser address value.
    function _setPauser(address _pauser) internal {
        PAUSER_SLOT.setAddress(_pauser);
        emit PauserUpdated(_pauser);
    }

    /// @notice Check if caller is pauser and revert if not.
    /// @dev Meant to be used in inheritor contract.
    function _onlyPauser() internal view {
        if (msg.sender != pauser()) revert OnlyPauser();
    }
}
