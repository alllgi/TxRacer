// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

/**
 * @title IIntentManagerValidator
 * @dev Interface for validating intent manager permissions
 */
interface IIntentManagerValidator {
    /**
     * @dev Validates if the provided address has the required intent manager rights
     * @param caller The address to validate (typically msg.sender from DlnSource)
     * @return isValid True if the caller has valid intent manager rights, false otherwise
     */
    function validateIntentManager(address caller) external view returns (bool isValid);
}

