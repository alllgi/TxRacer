// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IIntentManagerValidator.sol";

/**
 * @title IntentManagerValidator
 * @dev Contract for validating intent manager permissions using OpenZeppelin AccessControl
 * This contract is not upgradeable and uses role-based access control
 */
contract IntentManagerValidator is AccessControl, IIntentManagerValidator {
    /// @dev Role identifier for intent managers
    bytes32 public constant INTENT_MANAGER_ROLE = keccak256("INTENT_MANAGER_ROLE");

    /**
     * @dev Constructor that sets up the initial admin
     * @param admin The address that will have the DEFAULT_ADMIN_ROLE
     */
    constructor(address admin) {
        if (admin == address(0)) {
            revert("IntentManagerValidator: admin cannot be zero address");
        }
        
        // Grant the admin role to the specified address
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /**
     * @inheritdoc IIntentManagerValidator
     */
    function validateIntentManager(address caller) external view override returns (bool isValid) {
        return hasRole(INTENT_MANAGER_ROLE, caller);
    }
}
