// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/*
  ______                       _______                             __ 
 /      \                     |       \                           |  \
|  ▓▓▓▓▓▓\  ______    ______  | ▓▓▓▓▓▓▓\  ______   _______    ____| ▓▓
| ▓▓__| ▓▓ /      \  /      \ | ▓▓__/ ▓▓ /      \ |       \  /      ▓▓
| ▓▓    ▓▓|  ▓▓▓▓▓▓\|  ▓▓▓▓▓▓\| ▓▓    ▓▓|  ▓▓▓▓▓▓\| ▓▓▓▓▓▓▓\|  ▓▓▓▓▓▓▓
| ▓▓▓▓▓▓▓▓| ▓▓  | ▓▓| ▓▓    ▓▓| ▓▓▓▓▓▓▓\| ▓▓  | ▓▓| ▓▓  | ▓▓| ▓▓  | ▓▓
| ▓▓  | ▓▓| ▓▓__/ ▓▓| ▓▓▓▓▓▓▓▓| ▓▓__/ ▓▓| ▓▓__/ ▓▓| ▓▓  | ▓▓| ▓▓__| ▓▓
| ▓▓  | ▓▓| ▓▓    ▓▓ \▓▓     \| ▓▓    ▓▓ \▓▓    ▓▓| ▓▓  | ▓▓ \▓▓    ▓▓
 \▓▓   \▓▓| ▓▓▓▓▓▓▓   \▓▓▓▓▓▓▓ \▓▓▓▓▓▓▓   \▓▓▓▓▓▓  \▓▓   \▓▓  \▓▓▓▓▓▓▓
          | ▓▓                                                        
          | ▓▓                                                        
           \▓▓                                                         
 * App:             https://Ape.Bond
 * Medium:          https://ApeBond.medium.com
 * Twitter:         https://twitter.com/ApeBond
 * Telegram:        https://t.me/ape_bond
 * Announcements:   https://t.me/ApeBond_news
 * Discord:         https://ApeBond.click/discord
 * Reddit:          https://ApeBond.click/reddit
 * Instagram:       https://instagram.com/ape.bond
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title ApeBondAccessControlUpgradeable
 * @notice This contract manages the ownership and role based access for ApeBond contracts
 */
contract ApeBondAccessControlUpgradeable is OwnableUpgradeable, AccessControlEnumerableUpgradeable {
    /* ======== STATE ======== */

    /// @notice Operations role, used to adjust specific settings on the bond
    bytes32 public constant OPERATIONS_ROLE = keccak256("OPERATIONS_ROLE");

    /// @notice Discount manager role, used to manage discounts
    bytes32 public constant DISCOUNT_MANAGER_ROLE = keccak256("DISCOUNT_MANAGER_ROLE");

    /* ======== INITIALIZATION ======== */

    function __ApeBondAccessControlUpgradeable__init(
        address _initialOwner,
        address _discountManager,
        address[] calldata _bondOperations
    ) internal onlyInitializing {
        __Ownable_init();
        _transferOwnership(_initialOwner);
        _grantRole(DISCOUNT_MANAGER_ROLE, _discountManager);
        _grantOperationsRole(_bondOperations);
    }

    /* ======== MODIFIERS ======== */

    modifier onlyOwnerOrRole(bytes32 role1) {
        require(msg.sender == owner() || hasRole(role1, msg.sender), "Caller is not owner or has required role");
        _;
    }

    modifier onlyOwnerOrRoles(bytes32 role1, bytes32 role2) {
        require(
            msg.sender == owner() || hasRole(role1, msg.sender) || hasRole(role2, msg.sender),
            "Caller is not owner or has required role"
        );
        _;
    }

    /* ======== onlyOwner FUNCTIONS ======== */

    /**
     * @notice Grant the ability to operate the bond
     * @param _bondOperations Array of addresses to whitelist as bond operations
     */
    function grantOperationsRole(address[] calldata _bondOperations) external onlyOwner {
        _grantOperationsRole(_bondOperations);
    }

    function _grantOperationsRole(address[] calldata _bondOperations) private {
        for (uint i = 0; i < _bondOperations.length; i++) {
            _grantRole(OPERATIONS_ROLE, _bondOperations[i]);
        }
    }

    /**
     * @notice Revoke the ability to operate bond
     * @param _bondOperations Array of addresses to revoke as bond operations
     */
    function revokeOperationsRole(address[] calldata _bondOperations) external onlyOwner {
        for (uint i = 0; i < _bondOperations.length; i++) {
            _revokeRole(OPERATIONS_ROLE, _bondOperations[i]);
        }
    }

    /**
     * @notice Grant the ability to manage discounts
     * @param _discountManager Address to grant discount manager role to
     */
    function grantDiscountManagerRole(address _discountManager) external onlyOwner {
        _grantRole(DISCOUNT_MANAGER_ROLE, _discountManager);
    }

    /**
     * @notice Revoke the ability to manage discounts
     * @param _discountManager Address to revoke discount manager role from
     */
    function revokeDiscountManagerRole(address _discountManager) external onlyOwner {
        _revokeRole(DISCOUNT_MANAGER_ROLE, _discountManager);
    }

    /**
     * @notice Grant a role
     * @param role The role to grant
     * @param account The address to grant the role to
     */
    function grantRole(
        bytes32 role,
        address account
    ) public override(AccessControlUpgradeable, IAccessControlUpgradeable) onlyOwner {
        _grantRole(role, account);
    }
}
