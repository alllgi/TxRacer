// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {AccessControlDefaultAdminRules} from "openzeppelin-contracts/contracts/access/extensions/AccessControlDefaultAdminRules.sol";
import {Errors} from "./libraries/Errors.sol";

/**
 * @title  DineroERC20
 * @notice A standard ERC20 token with minting and burning, with access control.
 * @author dinero.protocol
 */
abstract contract DineroERC20 is ERC20, AccessControlDefaultAdminRules {
    // Roles

    /**
     * @dev Bytes32 constant representing the role to mint new tokens.
     */
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @dev Bytes32 constant representing the role to burn (destroy) tokens.
     */
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /**
     * @notice Constructor to initialize the DineroERC20 contract.
     * @param  _name          string   Token name.
     * @param  _symbol        string   Token symbol.
     * @param  _admin         address  Admin address.
     * @param  _initialDelay  uint48   Delay required to schedule the acceptance
     *                                 of an access control transfer started.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _admin,
        uint48 _initialDelay
    )
        AccessControlDefaultAdminRules(_initialDelay, _admin)
        ERC20(_name, _symbol, 18)
    {
        if (bytes(_name).length == 0) revert Errors.EmptyString();
        if (bytes(_symbol).length == 0) revert Errors.EmptyString();
    }

    /**
     * @notice Mints tokens to an address.
     * @dev    Only callable by minters.
     * @param  _to      address  Address to mint tokens to.
     * @param  _amount  uint256  Amount of tokens to mint.
     */
    function mint(address _to, uint256 _amount) external onlyRole(MINTER_ROLE) {
        if (_to == address(0)) revert Errors.ZeroAddress();
        if (_amount == 0) revert Errors.ZeroAmount();

        _mint(_to, _amount);
    }

    /**
     * @notice Burns tokens from an address.
     * @dev    Only callable by burners.
     * @param  _from    address  Address to burn tokens from.
     * @param  _amount  uint256  Amount of tokens to burn.
     */
    function burn(
        address _from,
        uint256 _amount
    ) external onlyRole(BURNER_ROLE) {
        if (_from == address(0)) revert Errors.ZeroAddress();
        if (_amount == 0) revert Errors.ZeroAmount();

        _burn(_from, _amount);
    }
}
