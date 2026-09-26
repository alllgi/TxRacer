// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IAdmin } from "../interfaces/IAdmin.sol";

// Contracts
import { AugustusStorage } from "../storage/AugustusStorage.sol";

// Vendor
import { LibDiamond } from "../vendor/libraries/LibDiamond.sol";

/// @title AdminFacet
/// @notice A facet for executing admin functions
contract AdminFacet is AugustusStorage, IAdmin {
    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Enforce that the caller is the contract owner
    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAdmin
    function setFeeWallet(address payable _feeWallet) external onlyOwner {
        // Make sure the fee wallet is not the zero address
        if (_feeWallet == address(0)) revert InvalidWalletAddress();
        // Set the fee wallet
        feeWallet = _feeWallet;
        // Emit an event
        emit FeeWalletUpdated(_feeWallet);
    }

    /// @inheritdoc IAdmin
    function setFeeWalletDelegate(address payable _feeWalletDelegate) external onlyOwner {
        // Make sure the fee wallet is not the zero address
        if (_feeWalletDelegate == address(0)) revert InvalidWalletAddress();
        // Set the fee wallet
        feeWalletDelegate = _feeWalletDelegate;
        // Emit an event
        emit FeeWalletDelegateUpdated(_feeWalletDelegate);
    }

    /// @inheritdoc IAdmin
    function setTokenBlacklisting(IERC20 token, bool isBlacklisted) public onlyOwner {
        // Set the blacklisting status
        blacklistedTokens[token] = isBlacklisted;
        // Emit an event
        emit TokenBlacklistUpdated(token, isBlacklisted);
    }

    /// @inheritdoc IAdmin
    function batchSetTokenBlacklisting(IERC20[] calldata tokens, bool isBlacklisted) external onlyOwner {
        // Loop through the tokens
        for (uint256 i = 0; i < tokens.length; i++) {
            // Set the blacklisting status
            setTokenBlacklisting(tokens[i], isBlacklisted);
        }
    }

    /// @inheritdoc IAdmin
    function setContractPauseState(bool _isPaused) external onlyOwner {
        // Set the pause state
        paused = _isPaused;
        // Emit an event
        emit ContractPauseStateUpdated(_isPaused);
    }
}
