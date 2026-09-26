// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

/// @title IAdmin
/// @notice Interface for interacting with the AdminFacet contract, which controls the AugustusStorage variables
/// all functions are callable only by the contract owner set by the ownership facet
interface IAdmin {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error emitted when the fee wallet is the zero address
    error InvalidWalletAddress();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a token blacklist status is updated
    /// @param token The token that was updated
    /// @param isBlacklisted The new blacklisting status
    event TokenBlacklistUpdated(IERC20 indexed token, bool isBlacklisted);

    /// @notice Emitted when the fee wallet is updated
    /// @param feeWallet The new fee wallet
    event FeeWalletUpdated(address indexed feeWallet);

    /// @notice Emitted when the fee wallet delegate is updated
    /// @param feeWalletDelegate The new second fee wallet
    event FeeWalletDelegateUpdated(address indexed feeWalletDelegate);

    /// @notice Emitted when the contract is paused
    event ContractPauseStateUpdated(bool isPaused);

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Set the fee wallet address
    /// @param _feeWallet The new fee wallet
    function setFeeWallet(address payable _feeWallet) external;

    /// @notice Set the second fee wallet address
    /// @param _feeWalletDelegate The new second fee wallet
    function setFeeWalletDelegate(address payable _feeWalletDelegate) external;

    /// @notice Set the fee blacklisted status of a token
    /// @param token The token to set the blacklisting status of
    /// @param isBlacklisted The new blacklisting status
    function setTokenBlacklisting(IERC20 token, bool isBlacklisted) external;

    /// @notice Batch set the fee blacklisted status of tokens
    /// @param tokens The tokens to set the blacklisting status of
    /// @param isBlacklisted The new blacklisting status
    function batchSetTokenBlacklisting(IERC20[] calldata tokens, bool isBlacklisted) external;

    /// @notice Set the contract pause state
    /// @param _isPaused The new pause state
    function setContractPauseState(bool _isPaused) external;
}
