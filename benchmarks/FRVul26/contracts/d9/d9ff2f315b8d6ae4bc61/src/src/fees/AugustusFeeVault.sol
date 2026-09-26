// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Contracts
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";

// Interfaces
import { IAugustusFeeVault } from "../interfaces/IAugustusFeeVault.sol";
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

// Libraries
import { ERC20Utils } from "../libraries/ERC20Utils.sol";

/// @title Augstus Fee Vault
/// @notice Allows partners to collect fees stored in the vault, and allows augustus contracts to register fees
contract AugustusFeeVault is IAugustusFeeVault, Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////
                                LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                                VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @dev A mapping of augustus contract addresses to their approval status
    mapping(address augustus => bool approved) public augustusContracts;

    // @dev Mapping of fee tokens to stored fee amounts
    mapping(address account => mapping(IERC20 token => uint256 amount)) public fees;

    // @dev Mapping of fee tokens to allocated fee amounts
    mapping(IERC20 token => uint256 amount) public allocatedFees;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address[] memory _augustusContracts, address owner) Ownable(owner) {
        // Set augustus verifier contracts
        for (uint256 i = 0; i < _augustusContracts.length; i++) {
            augustusContracts[_augustusContracts[i]] = true;
            emit AugustusApprovalSet(_augustusContracts[i], true);
        }
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @dev Modifier to check if the caller is an approved augustus contract
    modifier onlyApprovedAugustus() {
        if (!augustusContracts[msg.sender]) {
            revert UnauthorizedCaller();
        }
        _;
    }

    /// @dev Verifies that the withdraw amount is not zero
    modifier validAmount(uint256 amount) {
        // Check if amount is zero
        if (amount == 0) {
            revert InvalidWithdrawAmount();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAugustusFeeVault
    function withdrawSomeERC20(
        IERC20 token,
        uint256 amount,
        address recipient
    )
        public
        validAmount(amount)
        whenNotPaused
        returns (bool success)
    {
        /// Check recipient
        recipient = _checkRecipient(recipient);

        // Update fees mapping
        _updateFees(token, msg.sender, amount);

        // Transfer tokens to recipient
        token.safeTransfer(recipient, amount);

        // Return success
        return true;
    }

    /// @inheritdoc IAugustusFeeVault
    function getUnallocatedFees(IERC20 token) public view returns (uint256 unallocatedFees) {
        // Get the allocated fees for the given token
        uint256 allocatedFee = allocatedFees[token];

        // Get the balance of the given token
        uint256 balance = token.getBalance(address(this));

        // If the balance is bigger than the allocated fee, then the unallocated fees should
        // be equal to the balance minus the allocated fee
        if (balance > allocatedFee) {
            // Set the unallocated fees to the balance minus the allocated fee
            unallocatedFees = balance - allocatedFee;
        }
    }

    /*///////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAugustusFeeVault
    function batchWithdrawSomeERC20(
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    )
        external
        whenNotPaused
        returns (bool success)
    {
        // Check if the length of the tokens and amounts arrays are the same
        if (tokens.length != amounts.length) {
            revert InvalidParameterLength();
        }

        // Loop through the tokens and amounts arrays
        for (uint256 i; i < tokens.length; ++i) {
            // Collect fees for the given token
            if (!withdrawSomeERC20(tokens[i], amounts[i], recipient)) {
                // Revert if collect fails
                revert BatchCollectFailed();
            }
        }

        // Return success
        return true;
    }

    /// @inheritdoc IAugustusFeeVault
    function withdrawAllERC20(IERC20 token, address recipient) public whenNotPaused returns (bool success) {
        // Check recipient
        recipient = _checkRecipient(recipient);

        // Get the total fees for msg.sender in the given token
        uint256 totalBalance = fees[msg.sender][token];

        // Make sure the amount is not zero
        if (totalBalance == 0) {
            revert InvalidWithdrawAmount();
        }

        // Update fees mapping
        _updateFees(token, msg.sender, totalBalance);

        // Transfer tokens to recipient
        token.safeTransfer(recipient, totalBalance);

        // Return success
        return true;
    }

    /// @inheritdoc IAugustusFeeVault
    function batchWithdrawAllERC20(
        IERC20[] calldata tokens,
        address recipient
    )
        external
        whenNotPaused
        returns (bool success)
    {
        // Loop through the tokens array
        for (uint256 i; i < tokens.length; ++i) {
            // Collect all fees for the given token
            if (!withdrawAllERC20(tokens[i], recipient)) {
                // Revert if withdrawAllERC20 fails
                revert BatchCollectFailed();
            }
        }

        // Return success
        return true;
    }

    /// @inheritdoc IAugustusFeeVault
    function registerFees(FeeRegistration memory feeData) external onlyApprovedAugustus {
        // Get the addresses, tokens, and feeAmounts from the feeData struct
        address[] memory addresses = feeData.addresses;
        IERC20 token = feeData.token;
        uint256[] memory feeAmounts = feeData.fees;

        // Make sure the length of the addresses and feeAmounts arrays are the same
        if (addresses.length != feeAmounts.length) {
            revert InvalidParameterLength();
        }

        // Loop through the addresses and fees arrays
        for (uint256 i; i < addresses.length; ++i) {
            // Register the fees for the given address and token if the fee and address are not zero
            if (feeAmounts[i] != 0 && addresses[i] != address(0)) {
                _registerFee(addresses[i], token, feeAmounts[i]);
            }
        }
    }

    /// @inheritdoc IAugustusFeeVault
    function setAugustusApproval(address augustus, bool approved) external onlyOwner {
        // Set the approval status for the given augustus contract
        augustusContracts[augustus] = approved;
        // Emit an event
        emit AugustusApprovalSet(augustus, approved);
    }

    /// @inheritdoc IAugustusFeeVault
    function setContractPauseState(bool _isPaused) external onlyOwner {
        // Set the pause state
        if (_isPaused) {
            _pause();
        } else {
            _unpause();
        }
    }

    /// @inheritdoc IAugustusFeeVault
    function getBalance(IERC20 token, address partner) external view returns (uint256 feeBalance) {
        // Get the fees for the given token and partner
        return fees[partner][token];
    }

    /// @inheritdoc IAugustusFeeVault
    function batchGetBalance(
        IERC20[] calldata tokens,
        address partner
    )
        external
        view
        returns (uint256[] memory feeBalances)
    {
        // Initialize the feeBalances array
        feeBalances = new uint256[](tokens.length);

        // Loop through the tokens array
        for (uint256 i; i < tokens.length; ++i) {
            // Get the fees for the given token and partner
            feeBalances[i] = fees[partner][tokens[i]];
        }
    }

    /*//////////////////////////////////////////////////////////////
                                PRIVATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Register fees for a given account and token
    /// @param account The account to register the fees for
    /// @param token The token to register the fees for
    /// @param fee The amount of fees to register
    function _registerFee(address account, IERC20 token, uint256 fee) private {
        // Get the unallocated fees for the given token
        uint256 unallocatedFees = getUnallocatedFees(token);

        // Make sure the fee is not bigger than the unallocated fees
        if (fee > unallocatedFees) {
            // If it is, set the fee to the unallocated fees
            fee = unallocatedFees;
        }

        // Update the fees mapping
        fees[account][token] += fee;

        // Update the allocated fees mapping
        allocatedFees[token] += fee;
    }

    /// @notice Update fees and allocatedFees for a given token and claimer
    /// @param token The token to update the fees for
    /// @param claimer The address to withdraw the fees for
    /// @param withdrawAmount The amount of fees to withdraw
    function _updateFees(IERC20 token, address claimer, uint256 withdrawAmount) private {
        // get the fees for the claimer
        uint256 feesForClaimer = fees[claimer][token];

        // revert if withdraw amount is bigger than the fees for the claimer
        if (withdrawAmount > feesForClaimer) {
            revert InvalidWithdrawAmount();
        }

        // update the allocated fees
        allocatedFees[token] -= withdrawAmount;

        // update the fees for the claimer
        fees[claimer][token] -= withdrawAmount;
    }

    /// @notice Check if recipient is zero address and set it to msg sender if it is, otherwise return recipient
    /// @param recipient The recipient address
    /// @return recipient The updated recipient address
    function _checkRecipient(address recipient) private view returns (address) {
        // Allow arbitrary recipient unless it is zero address
        if (recipient == address(0)) {
            recipient = msg.sender;
        }

        // Return recipient
        return recipient;
    }

    /*//////////////////////////////////////////////////////////////
                                RECEIVE
    //////////////////////////////////////////////////////////////*/

    /// @notice Reverts if the caller is one of the following:
    //         - an externally-owned account
    //         - a contract in construction
    //         - an address where a contract will be created
    //         - an address where a contract lived, but was destroyed
    receive() external payable {
        address addr = msg.sender;
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }
}
