// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title  Errors
 * @notice Library containing various commonly used error definitions.
 * @author dinero.protocol
 */
library Errors {
    /**
     * @dev Zero address specified.
     */
    error ZeroAddress();

    /**
     * @dev Zero amount specified.
     */
    error ZeroAmount();

    /**
     * @dev Empty string.
     */
    error EmptyString();

    /**
     * @dev Unauthorized access.
     */
    error Unauthorized();

    /**
     * @dev Locked.
     */
    error Locked();

    /**
     * @dev No rewards available.
     */
    error NoRewards();

    /**
     * @dev Mismatched array lengths.
     */
    error MismatchedArrayLengths();

    /**
     * @dev Empty array.
     */
    error EmptyArray();

    /**
     * @dev Invalid epoch.
     */
    error InvalidEpoch();

    /**
     * @dev Insufficient balance.
     */
    error InsufficientBalance();

    /**
     * @dev Already redeemed.
     */
    error AlreadyRedeemed();

    /**
     * @dev Invalid duration.
     */
    error InvalidDuration();
}
