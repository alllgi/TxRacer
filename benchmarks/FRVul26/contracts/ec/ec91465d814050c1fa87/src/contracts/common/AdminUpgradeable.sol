// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

abstract contract AdminUpgradeable is Initializable, AccessControlEnumerableUpgradeable {
    uint256 public constant MAINNET_CHAINID = 1;
    uint256 public constant PENDING_PERIOD = 3 days;

    mapping(address => uint256) public adminAddedAt;

    function __Admin_init(address[] calldata admins) internal onlyInitializing {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __Admin_init_unchained();

        for (uint256 i = 0; i < admins.length; ++i) {
            _addAdmin(admins[i]);
            adminAddedAt[admins[i]] = block.timestamp - PENDING_PERIOD;
        }
    }

    function __Admin_init_unchained() internal onlyInitializing {
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Admin: not admin");
        _;
    }

    function isAdmin(address account) public view virtual returns (bool) {
        return
            hasRole(DEFAULT_ADMIN_ROLE, account) &&
            (block.chainid != MAINNET_CHAINID ||
                (adminAddedAt[account] > 0 &&
                    block.timestamp >= adminAddedAt[account] + PENDING_PERIOD));
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function removeAdmin(address account) public onlyAdmin {
        uint256 count = getRoleMemberCount(DEFAULT_ADMIN_ROLE);
        require(count > 1, "Admin: no enough admin");

        _revokeRole(DEFAULT_ADMIN_ROLE, account);
        delete adminAddedAt[account];

        for (uint256 i = 0; i < count - 1; ++i) {
            if (isAdmin(getRoleMember(DEFAULT_ADMIN_ROLE, i))) {
                return;
            }
        }
        revert("Admin: no valid remove");
    }

    function _addAdmin(address account) internal virtual {
        require(account != address(0), "Admin: Invalid admin");
        if (adminAddedAt[account] > 0) {
            return;
        }
        _grantRole(DEFAULT_ADMIN_ROLE, account);
        adminAddedAt[account] = block.timestamp;
    }
}
