// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: starkware/solidity/interfaces/Identity.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

interface Identity {
    /*
      Allows a caller to ensure that the provided address is of the expected type and version.
    */
    function identify() external pure returns (string memory);
}

// File: third_party/open_zeppelin/utils/Strings.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: starkware/solidity/libraries/AccessControl.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

// Based on OpenZeppelin Contract (access/AccessControl.sol)
// StarkWare modification (storage slot, change to library).

pragma solidity ^0.8.0;



/*
  Library module that allows using contracts to implement role-based access
  control mechanisms. This is a lightweight version that doesn't allow enumerating role
  members except through off-chain means by accessing the contract event logs. Some
  applications may benefit from on-chain enumerability, for those cases see
  {AccessControlEnumerable}.
 
  Roles are referred to by their `bytes32` identifier. These should be exposed
  in the external API and be unique. The best way to achieve this is by
  using `public constant` hash digests:
 
  ```
  bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
  ```
 
  Roles can be used to represent a set of permissions. To restrict access to a
  function call, use {hasRole}:
 
  ```
  function foo() public {
      require(hasRole(MY_ROLE, msg.sender));
      ...
  }
  ```
 
  Roles can be granted and revoked dynamically via the {grantRole} and
  {revokeRole} functions. Each role has an associated admin role, and only
  accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 
  By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
  that only accounts with this role will be able to grant or revoke other
  roles. More complex role relationships can be created by using
  {_setRoleAdmin}.
 
  WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
  grant and revoke this role. Extra precautions should be taken to secure
  accounts that have been granted it.
 
  OpenZeppelin implementation changed as following:
  1. Converted to library.
  2. Storage valiable {_roles} moved outside of linear storage,
     to avoid potential storage conflicts or corruption.
  3. Removed ERC165 support.
*/
library AccessControl {
    /*
      Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     
      `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
      {RoleAdminChanged} not being emitted signaling this.
     
      Available since v3.1.
    */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /*
      Emitted when `account` is granted `role`.
     
      `sender` is the account that originated the contract call, an admin role
      bearer except when using {AccessControl-_setupRole}.
    */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /*
      Emitted when `account` is revoked `role`.
     
      `sender` is the account that originated the contract call:
        - if using `revokeRole`, it is the admin role bearer
        - if using `renounceRole`, it is the role bearer (i.e. `account`).
    */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    // Context interface functions.
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure returns (bytes calldata) {
        return msg.data;
    }

    // The storage variable `_roles` is located away from the contract linear area (low storage addresses)
    // to prevent potential collision/corruption in upgrade scenario.
    // Slot = Web3.keccak(text="AccesControl_Storage_Slot").
    bytes32 constant rolesSlot = 0x53e43b954ba190a7e49386f1f78b01dcd9f628db23f432fa029a7dfd6d98e8fb;

    function _roles() private pure returns (mapping(bytes32 => RoleData) storage roles) {
        assembly {
            roles.slot := rolesSlot
        }
    }

    bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;

    /*
      Modifier that checks that an account has a specific role. Reverts
      with a standardized message including the required role.
      
      The format of the revert reason is given by the following regular expression:
      
      /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
      
      Available since v4.1.
    */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /*
      Returns `true` if `account` has been granted `role`.
    */
    function hasRole(bytes32 role, address account) internal view returns (bool) {
        return _roles()[role].members[account];
    }

    /*
      Revert with a standard message if `_msgSender()` is missing `role`.
      Overriding this function changes the behavior of the {onlyRole} modifier.
     
      Format of the revert message is described in {_checkRole}.
     
      Available since v4.6.
    */
    function _checkRole(bytes32 role) internal view {
        _checkRole(role, _msgSender());
    }

    /*
      Revert with a standard message if `account` is missing `role`.
     
      The format of the revert reason is given by the following regular expression:
     
       /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/.
    */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /*
      Returns the admin role that controls `role`. See {grantRole} and
      {revokeRole}.
     
      To change a role's admin, use {_setRoleAdmin}.
    */
    function getRoleAdmin(bytes32 role) internal view returns (bytes32) {
        return _roles()[role].adminRole;
    }

    /*
      Grants `role` to `account`.
     
      If `account` had not been already granted `role`, emits a {RoleGranted}
      event.
     
      Requirements:
     
      - the caller must have ``role``'s admin role.
     
      May emit a {RoleGranted} event.
    */
    function grantRole(bytes32 role, address account) internal onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /*
      Revokes `role` from `account`.
     
      If `account` had been granted `role`, emits a {RoleRevoked} event.
     
      Requirements:
     
      - the caller must have ``role``'s admin role.
     
      * May emit a {RoleRevoked} event.
    */
    function revokeRole(bytes32 role, address account) internal onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /*
      Revokes `role` from the calling account.
     
      Roles are often managed via {grantRole} and {revokeRole}: this function's
      purpose is to provide a mechanism for accounts to lose their privileges
      if they are compromised (such as when a trusted device is misplaced).
     
      If the calling account had been revoked `role`, emits a {RoleRevoked}
      event.
     
      Requirements:
     
      - the caller must be `account`.
     
      May emit a {RoleRevoked} event.
    */
    function renounceRole(bytes32 role, address account) internal {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /*
      Grants `role` to `account`.
     
      If `account` had not been already granted `role`, emits a {RoleGranted}
      event. Note that unlike {grantRole}, this function doesn't perform any
      checks on the calling account.
     
      May emit a {RoleGranted} event.
     
      [WARNING]virtual
      ====
      This function should only be called from the constructor when setting
      up the initial roles for the system.
     
      Using this function in any other way is effectively circumventing the admin
      system imposed by {AccessControl}.
      ====
     
      NOTE: This function is deprecated in favor of {_grantRole}.
    */
    function _setupRole(bytes32 role, address account) internal {
        _grantRole(role, account);
    }

    /*
      Sets `adminRole` as ``role``'s admin role.
     
      Emits a {RoleAdminChanged} event.
    */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles()[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /*
      Grants `role` to `account`.
     
      Internal function without access restriction.
     
      May emit a {RoleGranted} event.
    */
    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles()[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /*
      Revokes `role` from `account`.
     
      Internal function without access restriction.
     
      May emit a {RoleRevoked} event.
    */
    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles()[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: starkware/solidity/libraries/RolesLib.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;



// int.from_bytes(Web3.keccak(text="ROLE_APP_GOVERNOR"), "big") & MASK_250 .
bytes32 constant APP_GOVERNOR = bytes32(
    uint256(0xd2ead78c620e94b02d0a996e99298c59ddccfa1d8a0149080ac3a20de06068)
);

// int.from_bytes(Web3.keccak(text="ROLE_APP_ROLE_ADMIN"), "big") & MASK_250 .
bytes32 constant APP_ROLE_ADMIN = bytes32(
    uint256(0x03e615638e0b79444a70f8c695bf8f2a47033bf1cf95691ec3130f64939cee99)
);

// int.from_bytes(Web3.keccak(text="ROLE_GOVERNANCE_ADMIN"), "big") & MASK_250 .
bytes32 constant GOVERNANCE_ADMIN = bytes32(
    uint256(0x03711c9d994faf6055172091cb841fd4831aa743e6f3315163b06a122c841846)
);

// int.from_bytes(Web3.keccak(text="ROLE_OPERATOR"), "big") & MASK_250 .
bytes32 constant OPERATOR = bytes32(
    uint256(0x023edb77f7c8cc9e38e8afe78954f703aeeda7fffe014eeb6e56ea84e62f6da7)
);

// int.from_bytes(Web3.keccak(text="ROLE_SECURITY_ADMIN"), "big") & MASK_250 .
bytes32 constant SECURITY_ADMIN = bytes32(
    uint256(0x026bd110619d11cfdfc28e281df893bc24828e89177318e9dbd860cdaedeb6b3)
);

// int.from_bytes(Web3.keccak(text="ROLE_SECURITY_AGENT"), "big") & MASK_250 .
bytes32 constant SECURITY_AGENT = bytes32(
    uint256(0x037693ba312785932d430dccf0f56ffedd0aa7c0f8b6da2cc4530c2717689b96)
);

// int.from_bytes(Web3.keccak(text="ROLE_TOKEN_ADMIN"), "big") & MASK_250 .
bytes32 constant TOKEN_ADMIN = bytes32(
    uint256(0x0128d63adbf6b09002c26caf55c47e2f26635807e3ef1b027218aa74c8d61a3e)
);

// int.from_bytes(Web3.keccak(text="ROLE_UPGRADE_GOVERNOR"), "big") & MASK_250 .
bytes32 constant UPGRADE_GOVERNOR = bytes32(
    uint256(0x0251e864ca2a080f55bce5da2452e8cfcafdbc951a3e7fff5023d558452ec228)
);

/*
  Role                |   Role Admin
  ----------------------------------------
  GOVERNANCE_ADMIN    |   GOVERNANCE_ADMIN
  UPGRADE_GOVERNOR    |   GOVERNANCE_ADMIN
  APP_ROLE_ADMIN      |   GOVERNANCE_ADMIN
  APP_GOVERNOR        |   APP_ROLE_ADMIN
  OPERATOR            |   APP_ROLE_ADMIN
  TOKEN_ADMIN         |   APP_ROLE_ADMIN
  SECURITY_ADMIN      |   SECURITY_ADMIN
  SECURITY_AGENT      |   SECURITY_ADMIN .
*/
library RolesLib {
    // INITIALIZERS.
    function governanceRolesInitialized() internal view returns (bool) {
        return AccessControl.getRoleAdmin(GOVERNANCE_ADMIN) != bytes32(0x00);
    }

    function securityRolesInitialized() internal view returns (bool) {
        return AccessControl.getRoleAdmin(SECURITY_ADMIN) != bytes32(0x00);
    }

    function initialize() internal {
        address provisional = AccessControl._msgSender();
        initialize(provisional, provisional);
    }

    function initialize(address provisionalGovernor, address provisionalSecAdmin) internal {
        if (governanceRolesInitialized()) {
            // Support Proxied contract initialization.
            // In case the Proxy already initialized the roles,
            // init will succeed IFF the provisionalGovernor is already `GovernanceAdmin`.
            require(
                AccessControl.hasRole(GOVERNANCE_ADMIN, provisionalGovernor),
                "ROLES_ALREADY_INITIALIZED"
            );
        } else {
            initGovernanceRoles(provisionalGovernor);
        }

        if (securityRolesInitialized()) {
            // If SecurityAdmin initialized,
            // then provisionalSecAdmin must already be a `SecurityAdmin`.
            // If it's not initilized - initialize it.
            require(
                AccessControl.hasRole(SECURITY_ADMIN, provisionalSecAdmin),
                "SECURITY_ROLES_ALREADY_INITIALIZED"
            );
        } else {
            initSecurityRoles(provisionalSecAdmin);
        }
    }

    function initSecurityRoles(address provisionalSecAdmin) private {
        AccessControl._setRoleAdmin(SECURITY_ADMIN, SECURITY_ADMIN);
        AccessControl._setRoleAdmin(SECURITY_AGENT, SECURITY_ADMIN);
        AccessControl._grantRole(SECURITY_ADMIN, provisionalSecAdmin);
    }

    function initGovernanceRoles(address provisionalGovernor) private {
        AccessControl._grantRole(GOVERNANCE_ADMIN, provisionalGovernor);
        AccessControl._setRoleAdmin(APP_GOVERNOR, APP_ROLE_ADMIN);
        AccessControl._setRoleAdmin(APP_ROLE_ADMIN, GOVERNANCE_ADMIN);
        AccessControl._setRoleAdmin(GOVERNANCE_ADMIN, GOVERNANCE_ADMIN);
        AccessControl._setRoleAdmin(OPERATOR, APP_ROLE_ADMIN);
        AccessControl._setRoleAdmin(TOKEN_ADMIN, APP_ROLE_ADMIN);
        AccessControl._setRoleAdmin(UPGRADE_GOVERNOR, GOVERNANCE_ADMIN);
    }
}

// File: starkware/solidity/components/Roles.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;



abstract contract Roles {
    // This flag dermine if the GOVERNANCE_ADMIN role can be renounced.
    bool immutable fullyRenouncable;

    constructor(bool renounceable) {
        fullyRenouncable = renounceable;
        RolesLib.initialize();
    }

    // MODIFIERS.
    modifier onlyAppGovernor() {
        require(isAppGovernor(AccessControl._msgSender()), "ONLY_APP_GOVERNOR");
        _;
    }

    modifier onlyOperator() {
        require(isOperator(AccessControl._msgSender()), "ONLY_OPERATOR");
        _;
    }

    modifier onlySecurityAdmin() {
        require(isSecurityAdmin(AccessControl._msgSender()), "ONLY_SECURITY_ADMIN");
        _;
    }

    modifier onlySecurityAgent() {
        require(isSecurityAgent(AccessControl._msgSender()), "ONLY_SECURITY_AGENT");
        _;
    }

    modifier onlyTokenAdmin() {
        require(isTokenAdmin(AccessControl._msgSender()), "ONLY_TOKEN_ADMIN");
        _;
    }

    modifier onlyUpgradeGovernor() {
        require(isUpgradeGovernor(AccessControl._msgSender()), "ONLY_UPGRADE_GOVERNOR");
        _;
    }

    modifier notSelf(address account) {
        require(account != AccessControl._msgSender(), "CANNOT_PERFORM_ON_SELF");
        _;
    }

    // Is holding role.
    function isAppGovernor(address account) public view returns (bool) {
        return AccessControl.hasRole(APP_GOVERNOR, account);
    }

    function isAppRoleAdmin(address account) public view returns (bool) {
        return AccessControl.hasRole(APP_ROLE_ADMIN, account);
    }

    function isGovernanceAdmin(address account) public view returns (bool) {
        return AccessControl.hasRole(GOVERNANCE_ADMIN, account);
    }

    function isOperator(address account) public view returns (bool) {
        return AccessControl.hasRole(OPERATOR, account);
    }

    function isSecurityAdmin(address account) public view returns (bool) {
        return AccessControl.hasRole(SECURITY_ADMIN, account);
    }

    function isSecurityAgent(address account) public view returns (bool) {
        return AccessControl.hasRole(SECURITY_AGENT, account);
    }

    function isTokenAdmin(address account) public view returns (bool) {
        return AccessControl.hasRole(TOKEN_ADMIN, account);
    }

    function isUpgradeGovernor(address account) public view returns (bool) {
        return AccessControl.hasRole(UPGRADE_GOVERNOR, account);
    }

    // Register Role.
    function registerAppGovernor(address account) external {
        AccessControl.grantRole(APP_GOVERNOR, account);
    }

    function registerAppRoleAdmin(address account) external {
        AccessControl.grantRole(APP_ROLE_ADMIN, account);
    }

    function registerGovernanceAdmin(address account) external {
        AccessControl.grantRole(GOVERNANCE_ADMIN, account);
    }

    function registerOperator(address account) external {
        AccessControl.grantRole(OPERATOR, account);
    }

    function registerSecurityAdmin(address account) external {
        AccessControl.grantRole(SECURITY_ADMIN, account);
    }

    function registerSecurityAgent(address account) external {
        AccessControl.grantRole(SECURITY_AGENT, account);
    }

    function registerTokenAdmin(address account) external {
        AccessControl.grantRole(TOKEN_ADMIN, account);
    }

    function registerUpgradeGovernor(address account) external {
        AccessControl.grantRole(UPGRADE_GOVERNOR, account);
    }

    // Revoke Role.
    function revokeAppGovernor(address account) external {
        AccessControl.revokeRole(APP_GOVERNOR, account);
    }

    function revokeAppRoleAdmin(address account) external notSelf(account) {
        AccessControl.revokeRole(APP_ROLE_ADMIN, account);
    }

    function revokeGovernanceAdmin(address account) external notSelf(account) {
        AccessControl.revokeRole(GOVERNANCE_ADMIN, account);
    }

    function revokeOperator(address account) external {
        AccessControl.revokeRole(OPERATOR, account);
    }

    function revokeSecurityAdmin(address account) external notSelf(account) {
        AccessControl.revokeRole(SECURITY_ADMIN, account);
    }

    function revokeSecurityAgent(address account) external {
        AccessControl.revokeRole(SECURITY_AGENT, account);
    }

    function revokeTokenAdmin(address account) external {
        AccessControl.revokeRole(TOKEN_ADMIN, account);
    }

    function revokeUpgradeGovernor(address account) external {
        AccessControl.revokeRole(UPGRADE_GOVERNOR, account);
    }

    // Renounce Role.
    function renounceRole(bytes32 role, address account) external {
        if (role == GOVERNANCE_ADMIN && !fullyRenouncable) {
            revert("CANNOT_RENOUNCE_GOVERNANCE_ADMIN");
        }
        AccessControl.renounceRole(role, account);
    }
}

// File: starkware/solidity/libraries/Addresses.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

/*
  Common Utility Libraries.
  I. Addresses (extending address).
*/
library Addresses {
    /*
      Note: isContract function has some known limitation.
      See https://github.com/OpenZeppelin/
      openzeppelin-contracts/blob/master/contracts/utils/Address.sol.
    */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function performEthTransfer(address recipient, uint256 amount) internal {
        if (amount == 0) return;
        (bool success, ) = recipient.call{value: amount}(""); // NOLINT: low-level-calls.
        require(success, "ETH_TRANSFER_FAILED");
    }

    /*
      Safe wrapper around ERC20/ERC721 calls.
      This is required because many deployed ERC20 contracts don't return a value.
      See https://github.com/ethereum/solidity/issues/4116.
    */
    function safeTokenContractCall(address tokenAddress, bytes memory callData) internal {
        require(isContract(tokenAddress), "BAD_TOKEN_ADDRESS");
        // NOLINTNEXTLINE: low-level-calls.
        (bool success, bytes memory returndata) = tokenAddress.call(callData);
        require(success, string(returndata));

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "TOKEN_OPERATION_FAILED");
        }
    }
}

// File: starkware/solidity/interfaces/BlockDirectCall.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

/*
  This contract provides means to block direct call of an external function.
  A derived contract (e.g. MainDispatcherBase) should decorate sensitive functions with the
  notCalledDirectly modifier, thereby preventing it from being called directly, and allowing only
  calling using delegate_call.
*/
abstract contract BlockDirectCall {
    address immutable this_;

    constructor() {
        this_ = address(this);
    }

    modifier notCalledDirectly() {
        require(this_ != address(this), "DIRECT_CALL_DISALLOWED");
        _;
    }
}

// File: starkware/solidity/interfaces/ContractInitializer.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

/**
  Interface for contract initialization.
  The functions it exposes are the app specific parts of the contract initialization,
  and are called by the ProxySupport contract that implement the generic part of behind-proxy
  initialization.
*/
abstract contract ContractInitializer {
    /*
      The number of sub-contracts that the proxied contract consists of.
    */
    function numOfSubContracts() internal pure virtual returns (uint256);

    /*
      Indicates if the proxied contract has already been initialized.
      Used to prevent re-init.
    */
    function isInitialized() internal view virtual returns (bool);

    /*
      Validates the init data that is passed into the proxied contract.
    */
    function validateInitData(bytes calldata data) internal view virtual;

    /*
      For a proxied contract that consists of sub-contracts, this function processes
      the sub-contract addresses, e.g. validates them, stores them etc.
    */
    function processSubContractAddresses(bytes calldata subContractAddresses) internal virtual;

    /*
      This function applies the logic of initializing the proxied contract state,
      e.g. setting root values etc.
    */
    function initializeContractState(bytes calldata data) internal virtual;
}

// File: starkware/solidity/interfaces/ProxySupport.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;







/**
  This contract contains the code commonly needed for a contract to be deployed behind
  an upgradability proxy.
  It perform the required semantics of the proxy pattern,
  but in a generic manner.
*/
abstract contract ProxySupport is BlockDirectCall, ContractInitializer, Roles(true) {
    using Addresses for address;

    // The two function below (isFrozen & initialize) needed to bind to the Proxy.
    function isFrozen() external view virtual returns (bool) {
        return false;
    }

    /*
      The initialize() function serves as an alternative constructor for a proxied deployment.

      Flow and notes:
      1. This function cannot be called directly on the deployed contract, but only via
         delegate call.
      2. If an EIC is provided - init is passed onto EIC and the standard init flow is skipped.
         This true for both first intialization or a later one.
      3. The data passed to this function is as follows:
         [sub_contracts addresses, eic address, initData].

         When calling on an initialized contract (no EIC scenario), initData.length must be 0.
    */
    function initialize(bytes calldata data) external notCalledDirectly {
        uint256 eicOffset = 32 * numOfSubContracts();
        uint256 expectedBaseSize = eicOffset + 32;
        require(data.length >= expectedBaseSize, "INIT_DATA_TOO_SMALL");
        address eicAddress = abi.decode(data[eicOffset:expectedBaseSize], (address));

        bytes calldata subContractAddresses = data[:eicOffset];

        processSubContractAddresses(subContractAddresses);

        bytes calldata initData = data[expectedBaseSize:];

        // EIC Provided - Pass initData to EIC and the skip standard init flow.
        if (eicAddress != address(0x0)) {
            callExternalInitializer(eicAddress, initData);
            return;
        }

        if (isInitialized()) {
            require(initData.length == 0, "UNEXPECTED_INIT_DATA");
        } else {
            // Contract was not initialized yet.
            validateInitData(initData);
            initializeContractState(initData);
            RolesLib.initialize();
        }
    }

    function callExternalInitializer(address externalInitializerAddr, bytes calldata eicData)
        private
    {
        require(externalInitializerAddr.isContract(), "EIC_NOT_A_CONTRACT");

        // NOLINTNEXTLINE: low-level-calls, controlled-delegatecall.
        (bool success, bytes memory returndata) = externalInitializerAddr.delegatecall(
            abi.encodeWithSelector(this.initialize.selector, eicData)
        );
        require(success, string(returndata));
        require(returndata.length == 0, string(returndata));
    }
}

// File: starkware/solidity/libraries/NamedStorage.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

/*
  Library to provide basic storage, in storage location out of the low linear address space.

  New types of storage variables should be added here upon need.
*/
library NamedStorage {
    function bytes32ToBoolMapping(string memory tag_)
        internal
        pure
        returns (mapping(bytes32 => bool) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable.slot := location
        }
    }

    function bytes32ToUint256Mapping(string memory tag_)
        internal
        pure
        returns (mapping(bytes32 => uint256) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable.slot := location
        }
    }

    function addressToUint256Mapping(string memory tag_)
        internal
        pure
        returns (mapping(address => uint256) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable.slot := location
        }
    }

    function bytes32ToAddressMapping(string memory tag_)
        internal
        pure
        returns (mapping(bytes32 => address) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable.slot := location
        }
    }

    function uintToAddressMapping(string memory tag_)
        internal
        pure
        returns (mapping(uint256 => address) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable.slot := location
        }
    }

    function addressToAddressMapping(string memory tag_)
        internal
        pure
        returns (mapping(address => address) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable.slot := location
        }
    }

    function addressToAddressListMapping(string memory tag_)
        internal
        pure
        returns (mapping(address => address[]) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable.slot := location
        }
    }

    function addressToBoolMapping(string memory tag_)
        internal
        pure
        returns (mapping(address => bool) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable.slot := location
        }
    }

    function getUintValue(string memory tag_) internal view returns (uint256 retVal) {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            retVal := sload(slot)
        }
    }

    function setUintValue(string memory tag_, uint256 value) internal {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            sstore(slot, value)
        }
    }

    function setUintValueOnce(string memory tag_, uint256 value) internal {
        require(getUintValue(tag_) == 0, "ALREADY_SET");
        setUintValue(tag_, value);
    }

    function getAddressValue(string memory tag_) internal view returns (address retVal) {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            retVal := sload(slot)
        }
    }

    function setAddressValue(string memory tag_, address value) internal {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            sstore(slot, value)
        }
    }

    function setAddressValueOnce(string memory tag_, address value) internal {
        require(getAddressValue(tag_) == address(0x0), "ALREADY_SET");
        setAddressValue(tag_, value);
    }

    function getBoolValue(string memory tag_) internal view returns (bool retVal) {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            retVal := sload(slot)
        }
    }

    function setBoolValue(string memory tag_, bool value) internal {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            sstore(slot, value)
        }
    }
}

// File: starkware/solidity/tokens/ERC20/IERC20.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

/**
  Interface of the ERC20 standard as defined in the EIP. Does not include
  the optional functions; to access them see {ERC20Detailed}.
*/
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: starkware/solidity/libraries/Transfers.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;




library Transfers {
    using Addresses for address;

    /*
      Transfers funds from sender to this contract.
    */
    function transferIn(
        address token,
        address sender,
        uint256 amount
    ) internal {
        if (amount == 0) return;
        IERC20 erc20Token = IERC20(token);
        uint256 balanceBefore = erc20Token.balanceOf(address(this));
        uint256 expectedAfter = balanceBefore + amount;
        require(expectedAfter >= balanceBefore, "OVERFLOW");

        bytes memory callData = abi.encodeWithSelector(
            erc20Token.transferFrom.selector,
            sender,
            address(this),
            amount
        );
        token.safeTokenContractCall(callData);

        uint256 balanceAfter = erc20Token.balanceOf(address(this));
        require(balanceAfter == expectedAfter, "INCORRECT_AMOUNT_TRANSFERRED");
    }

    /*
      Transfers funds from this contract to recipient.
    */
    function transferOut(
        address token,
        address recipient,
        uint256 amount
    ) internal {
        // Make sure we don't accidentally burn funds.
        require(recipient != address(0x0), "INVALID_RECIPIENT");
        if (amount == 0) return;
        IERC20 erc20Token = IERC20(token);
        uint256 balanceBefore = erc20Token.balanceOf(address(this));
        uint256 expectedAfter = balanceBefore - amount;
        require(expectedAfter <= balanceBefore, "UNDERFLOW");

        bytes memory callData = abi.encodeWithSelector(
            erc20Token.transfer.selector,
            recipient,
            amount
        );
        token.safeTokenContractCall(callData);

        uint256 balanceAfter = erc20Token.balanceOf(address(this));
        require(balanceAfter == expectedAfter, "INCORRECT_AMOUNT_TRANSFERRED");
    }
}

// File: starkware/solidity/tokens/ERC20/IERC20Metadata.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;



/**
  Interface for the optional metadata functions from the ERC20 standard.
*/
interface IERC20Metadata is IERC20 {
    /**
      Returns the name of the token.
    */
    function name() external view returns (string memory);

    /**
      Returns the symbol of the token.
    */
    function symbol() external view returns (string memory);

    /**
      Returns the decimals places of the token.
    */
    function decimals() external view returns (uint8);
}

// File: starkware/starknet/solidity/IStarknetMessagingEvents.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

interface IStarknetMessagingEvents {
    // This event needs to be compatible with the one defined in Output.sol.
    event LogMessageToL1(uint256 indexed fromAddress, address indexed toAddress, uint256[] payload);

    // An event that is raised when a message is sent from L1 to L2.
    event LogMessageToL2(
        address indexed fromAddress,
        uint256 indexed toAddress,
        uint256 indexed selector,
        uint256[] payload,
        uint256 nonce,
        uint256 fee
    );

    // An event that is raised when a message from L2 to L1 is consumed.
    event ConsumedMessageToL1(
        uint256 indexed fromAddress,
        address indexed toAddress,
        uint256[] payload
    );

    // An event that is raised when a message from L1 to L2 is consumed.
    event ConsumedMessageToL2(
        address indexed fromAddress,
        uint256 indexed toAddress,
        uint256 indexed selector,
        uint256[] payload,
        uint256 nonce
    );

    // An event that is raised when a message from L1 to L2 Cancellation is started.
    event MessageToL2CancellationStarted(
        address indexed fromAddress,
        uint256 indexed toAddress,
        uint256 indexed selector,
        uint256[] payload,
        uint256 nonce
    );

    // An event that is raised when a message from L1 to L2 is canceled.
    event MessageToL2Canceled(
        address indexed fromAddress,
        uint256 indexed toAddress,
        uint256 indexed selector,
        uint256[] payload,
        uint256 nonce
    );
}

// File: starkware/starknet/solidity/IStarknetMessaging.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;



interface IStarknetMessaging is IStarknetMessagingEvents {
    /**
      Returns the max fee (in Wei) that StarkNet will accept per single message.
    */
    function getMaxL1MsgFee() external pure returns (uint256);

    /**
      Returns the msg_fee + 1 for the message with the given 'msgHash',
      or 0 if no message with such a hash is pending.
    */
    function l1ToL2Messages(bytes32 msgHash) external view returns (uint256);

    /**
      Sends a message to an L2 contract.
      This function is payable, the payed amount is the message fee.

      Returns the hash of the message and the nonce of the message.
    */
    function sendMessageToL2(
        uint256 toAddress,
        uint256 selector,
        uint256[] calldata payload
    ) external payable returns (bytes32, uint256);

    /**
      Consumes a message that was sent from an L2 contract.

      Returns the hash of the message.
    */
    function consumeMessageFromL2(uint256 fromAddress, uint256[] calldata payload)
        external
        returns (bytes32);

    /**
      Starts the cancellation of an L1 to L2 message.
      A message can be canceled messageCancellationDelay() seconds after this function is called.

      Note: This function may only be called for a message that is currently pending and the caller
      must be the sender of the that message.
    */
    function startL1ToL2MessageCancellation(
        uint256 toAddress,
        uint256 selector,
        uint256[] calldata payload,
        uint256 nonce
    ) external returns (bytes32);

    /**
      Cancels an L1 to L2 message, this function should be called at least
      messageCancellationDelay() seconds after the call to startL1ToL2MessageCancellation().
      A message may only be cancelled by its sender.
      If the message is missing, the call will revert.

      Note that the message fee is not refunded.
    */
    function cancelL1ToL2Message(
        uint256 toAddress,
        uint256 selector,
        uint256[] calldata payload,
        uint256 nonce
    ) external returns (bytes32);
}

// File: src/solidity/Fees.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

// Estimate cost for L1-L2 message handler.
uint256 constant DEPOSIT_FEE_GAS = 20000;
uint256 constant DEPLOYMENT_FEE_GAS = 100000;

// We don't have a solid way to gauge block gas price
// (block.basefee cannot be used).
uint256 constant DEFAULT_WEI_PER_GAS = 5 * 10**9;

abstract contract Fees {
    // Effectively no minimum fee on testnet.
    uint256 immutable MIN_FEE = (block.chainid == 1) ? 10**12 : 1;
    uint256 constant MAX_FEE = 10**16;

    function estimateDepositFee() internal pure returns (uint256) {
        return DEPOSIT_FEE_GAS * DEFAULT_WEI_PER_GAS;
    }

    function estimateEnrollmentFee() internal pure returns (uint256) {
        return DEPLOYMENT_FEE_GAS * DEFAULT_WEI_PER_GAS;
    }

    function checkFee(uint256 feeWei) internal view {
        require(feeWei >= MIN_FEE, "INSUFFICIENT_FEE_VALUE");
        require(feeWei <= MAX_FEE, "FEE_VALUE_TOO_HIGH");
    }
}

// File: src/solidity/IStarkgateBridge.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

interface IStarkgateBridge {
    /**
       Enrolls a token in the Starknet Token Bridge system.
    */
    function enrollToken(address token) external payable;

    /**
      Deactivates token bridging.
      Deactivated token does not accept deposits.
     */
    function deactivate(address token) external;
}

// File: src/solidity/IStarkgateManager.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

interface IStarkgateManager {
    /**
      Returns the address of the Starkgate Registry contract.
    */
    function getRegistry() external view returns (address);

    /**
      Adds an existing bridge to the Starkgate system for a specific token.
     */
    function addExistingBridge(address token, address bridge) external;

    /**
      Deactivates bridging of a specific token.
      A deactivated token is blocked for deposits and cannot be re-deployed.     
      */
    function deactivateToken(address token) external;

    /**
      Block a specific token from being used in the StarkGate.
      A blocked token cannot be deployed.
      */
    function blockToken(address token) external;

    /**
      Enrolls a token bridge for a specific token.
     */
    function enrollTokenBridge(address token) external payable;
}

// File: src/solidity/IStarkgateRegistry.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

interface IStarkgateRegistry {
    /**
      Returns the bridge that handles the given token.
    */
    function getBridge(address token) external view returns (address);

    /**
      Add a mapping between a token and the bridge handling it.
    */
    function enlistToken(address token, address bridge) external;

    /**
      Block a specific token from being used in the StarkGate.
      A blocked token cannot be deployed.
      */
    function blockToken(address token) external;

    /**
      Retrieves a list of bridge addresses that have facilitated withdrawals 
      for the specified token.
     */
    function getWithdrawalBridges(address token) external view returns (address[] memory bridges);

    /**
      Using this function a bridge removes enlisting of its token from the registry.
      The bridge must implement `isServicingToken(address token)` (see `IStarkgateService`).
     */
    function selfRemove(address token) external;
}

// File: src/solidity/IStarkgateService.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

interface IStarkgateService {
    /**
    Checks whether the calling contract is providing a service for the specified token.
    Returns True if the calling contract is providing a service for the token, otherwise false.
   */
    function isServicingToken(address token) external view returns (bool);
}

// File: src/solidity/StarkgateConstants.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.20;

// Starknet L1 handler selectors.
uint256 constant HANDLE_DEPOSIT_SELECTOR = 1285101517810983806491589552491143496277809242732141897358598292095611420389;
uint256 constant HANDLE_TOKEN_DEPOSIT_SELECTOR = 774397379524139446221206168840917193112228400237242521560346153613428128537;

uint256 constant HANDLE_DEPOSIT_WITH_MESSAGE_SELECTOR = 247015267890530308727663503380700973440961674638638362173641612402089762826;

uint256 constant HANDLE_TOKEN_DEPLOYMENT_SELECTOR = 1737780302748468118210503507461757847859991634169290761669750067796330642876;

uint256 constant TRANSFER_FROM_STARKNET = 0;
uint256 constant UINT256_PART_SIZE_BITS = 128;
uint256 constant UINT256_PART_SIZE = 2**UINT256_PART_SIZE_BITS;
uint256 constant MAX_PENDING_DURATION = 5 days;
address constant BLOCKED_TOKEN = address(0x1);

// Cairo felt252 value (short string) of 'ETH'
address constant ETH = address(0x455448);

// File: src/solidity/StarkgateManager.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.20;











contract StarkgateManager is Identity, IStarkgateManager, ProxySupport {
    using Addresses for address;
    // Named storage slot tags.
    string internal constant REGISTRY_TAG = "STARKGATE_MANAGER_REGISTRY_SLOT_TAG";
    string internal constant BRIDGE_TAG = "STARKGATE_MANAGER_BRIDGE_SLOT_TAG";
    event TokenEnrolled(address indexed token, address indexed sender);
    event ExistingBridgeAdded(address indexed token, address indexed bridge);
    event TokenDeactivated(address indexed token, address indexed sender);
    event TokenBlocked(address indexed token, address indexed sender);

    function getRegistry() external view returns (address) {
        return registry();
    }

    // Storage Getters.
    // TODO : add doc.
    function registry() internal view returns (address) {
        return NamedStorage.getAddressValue(REGISTRY_TAG);
    }

    function bridge() internal view returns (address) {
        return NamedStorage.getAddressValue(BRIDGE_TAG);
    }

    // Storage Setters.
    function setRegistry(address contract_) internal {
        NamedStorage.setAddressValueOnce(REGISTRY_TAG, contract_);
    }

    function setBridge(address contract_) internal {
        NamedStorage.setAddressValueOnce(BRIDGE_TAG, contract_);
    }

    function identify() external pure override returns (string memory) {
        return "StarkWare_StarkgateManager_2.0_1";
    }

    /*
      Initializes the contract.
    */
    function initializeContractState(bytes calldata data) internal override {
        (address registry_, address bridge_) = abi.decode(data, (address, address));
        setRegistry(registry_);
        setBridge(bridge_);
    }

    function isInitialized() internal view override returns (bool) {
        return registry() != address(0);
    }

    function numOfSubContracts() internal pure override returns (uint256) {
        return 0;
    }

    /*
      No processing needed, as there are no sub-contracts to this contract.
    */
    function processSubContractAddresses(bytes calldata subContractAddresses) internal override {}

    function validateInitData(bytes calldata data) internal view virtual override {
        require(data.length == 64, "ILLEGAL_DATA_SIZE");
        (address registry_, address bridge_) = abi.decode(data, (address, address));
        require(registry_.isContract(), "INVALID_REGISTRY_CONTRACT_ADDRESS");
        require(bridge_.isContract(), "INVALID_BRIDGE_CONTRACT_ADDRESS");
    }

    function addExistingBridge(address token, address bridge_) external onlyTokenAdmin {
        require(bridge() != bridge_, "CANNOT_ADD_MAIN_MULTI_BRIDGE_AS_EXISTING");
        IStarkgateRegistry(registry()).enlistToken(token, bridge_);
        emit ExistingBridgeAdded(token, bridge_);
    }

    /**
      Deactivates bridging of a specific token.
      A deactivated token is blocked for deposits and cannot be re-deployed.
      Note: Only serviced tokens can be deactivated. In order to block an unserviced tokens
      see 'blockToken'.
    */
    function deactivateToken(address token) external onlyTokenAdmin {
        IStarkgateRegistry registryContract = IStarkgateRegistry(registry());
        address current_bridge = registryContract.getBridge(token);

        require(current_bridge != address(0), "TOKEN_NOT_ENROLLED");
        if (current_bridge == BLOCKED_TOKEN) {
            string memory revertMsg = registryContract.getWithdrawalBridges(token).length == 0
                ? "TOKEN_ALREADY_BLOCKED"
                : "TOKEN_ALREADY_DEACTIVATED";
            revert(revertMsg);
        }
        emit TokenDeactivated(token, msg.sender);
        registryContract.blockToken(token);
        if (current_bridge == bridge()) {
            IStarkgateBridge(bridge()).deactivate(token);
        }
    }

    /**
      Block token from being bridged.
      A blocked token cannot be deployed.
      Note: Only an unserviced token can be blocked. In order to deactivate a serviced tokens
        see 'deactivateToken'.
    */
    function blockToken(address token) external onlyTokenAdmin {
        IStarkgateRegistry registryContract = IStarkgateRegistry(registry());
        address current_bridge = registryContract.getBridge(token);
        if (current_bridge == address(0)) {
            emit TokenBlocked(token, msg.sender);
            registryContract.blockToken(token);
        } else if (current_bridge == BLOCKED_TOKEN) {
            string memory revertMsg = registryContract.getWithdrawalBridges(token).length == 0
                ? "TOKEN_ALREADY_BLOCKED"
                : "CANNOT_BLOCK_DEACTIVATED_TOKEN";
            revert(revertMsg);
        } else {
            revert("CANNOT_BLOCK_TOKEN_IN_SERVICE");
        }
    }

    function enrollTokenBridge(address token) external payable {
        IStarkgateRegistry registryContract = IStarkgateRegistry(registry());
        require(registryContract.getBridge(token) != BLOCKED_TOKEN, "CANNOT_DEPLOY_BRIDGE");
        emit TokenEnrolled(token, msg.sender);
        registryContract.enlistToken(token, bridge());
        IStarkgateBridge(bridge()).enrollToken{value: msg.value}(token);
    }
}

// File: src/solidity/StarknetTokenStorage.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.20;




abstract contract StarknetTokenStorage {
    // Named storage slot tags.
    string internal constant BRIDGED_TOKEN_TAG = "STARKNET_ERC20_TOKEN_BRIDGE_TOKEN_ADDRESS";
    string internal constant L2_BRIDGE_TAG = "STARKNET_TOKEN_BRIDGE_L2_TOKEN_CONTRACT";
    string internal constant MANAGER_TAG = "STARKNET_TOKEN_BRIDGE_MANAGER_SLOT_TAG";
    string internal constant MESSAGING_CONTRACT_TAG = "STARKNET_TOKEN_BRIDGE_MESSAGING_CONTRACT";
    string internal constant DEPOSITOR_ADDRESSES_TAG = "STARKNET_TOKEN_BRIDGE_DEPOSITOR_ADDRESSES";

    enum TokenStatus {
        Unknown,
        Pending,
        Active,
        Deactivated
    }

    struct TokenSettings {
        TokenStatus tokenStatus;
        bytes32 deploymentMsgHash;
        uint256 pendingDeploymentExpiration;
        uint256 maxTotalBalance;
        bool withdrawalLimitApplied;
    }

    // Slot = Web3.keccak(text="TokenSettings_Storage_Slot").
    bytes32 constant tokenSettingsSlot =
        0xc59c20aaa96597268f595db30ec21108a505370e3266ed3a6515637f16b8b689;

    function tokenSettings()
        internal
        pure
        returns (mapping(address => TokenSettings) storage _tokenSettings)
    {
        assembly {
            _tokenSettings.slot := tokenSettingsSlot
        }
    }

    // Storage Getters.
    function manager() internal view returns (address) {
        return NamedStorage.getAddressValue(MANAGER_TAG);
    }

    function l2TokenBridge() internal view returns (uint256) {
        return NamedStorage.getUintValue(L2_BRIDGE_TAG);
    }

    function messagingContract() internal view returns (IStarknetMessaging) {
        return IStarknetMessaging(NamedStorage.getAddressValue(MESSAGING_CONTRACT_TAG));
    }

    // Storage Setters.
    function setManager(address contract_) internal {
        NamedStorage.setAddressValueOnce(MANAGER_TAG, contract_);
    }

    function l2TokenBridge(uint256 value) internal {
        NamedStorage.setUintValueOnce(L2_BRIDGE_TAG, value);
    }

    function messagingContract(address contract_) internal {
        NamedStorage.setAddressValueOnce(MESSAGING_CONTRACT_TAG, contract_);
    }
}

// File: src/solidity/WithdrawalLimit.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;





/**
    A library to provide withdrawal limit functionality.
 */
library WithdrawalLimit {
    uint256 constant DEFAULT_WITHDRAW_LIMIT_PCT = 5;
    string internal constant WITHDRAW_LIMIT_PCT_TAG = "WITHDRAWL_LIMIT_WITHDRAW_LIMIT_PCT_SLOT_TAG";
    string internal constant INTRADAY_QUOTA_TAG = "WITHDRAWL_LIMIT_INTRADAY_QUOTA_SLOT_TAG";

    function getWithdrawLimitPct() internal view returns (uint256) {
        return NamedStorage.getUintValue(WITHDRAW_LIMIT_PCT_TAG);
    }

    function setWithdrawLimitPct(uint256 value) internal {
        NamedStorage.setUintValue(WITHDRAW_LIMIT_PCT_TAG, value);
    }

    // Returns the key for the intraday allowance mapping.
    function withdrawQuotaKey(address token) internal view returns (bytes32) {
        uint256 day = block.timestamp / 86400;
        return keccak256(abi.encode(token, day));
    }

    /**
        Calculates the intraday allowance for a given token.
        The allowance is calculated as a percentage of the current balance.
     */
    function calculateIntradayAllowance(address token) internal view returns (uint256) {
        uint256 currentBalance;
        // If the token is Eth and not an ERC20 - calculate balance accordingly.
        if (token == ETH) {
            currentBalance = address(this).balance;
        } else {
            currentBalance = IERC20(token).balanceOf(address(this));
        }
        uint256 withdrawLimitPct = getWithdrawLimitPct();
        return (currentBalance * withdrawLimitPct) / 100;
    }

    /**
        Returns the intraday quota mapping.
     */
    function intradayQuota() internal pure returns (mapping(bytes32 => uint256) storage) {
        return NamedStorage.bytes32ToUint256Mapping(INTRADAY_QUOTA_TAG);
    }

    // The offset is used to distinguish between an unset value and a value of 0.
    uint256 constant OFFSET = 1;

    function isWithdrawQuotaInitialized(address token) private view returns (bool) {
        return intradayQuota()[withdrawQuotaKey(token)] != 0;
    }

    function getIntradayQuota(address token) internal view returns (uint256) {
        return intradayQuota()[withdrawQuotaKey(token)] - OFFSET;
    }

    function setIntradayQuota(address token, uint256 value) private {
        intradayQuota()[withdrawQuotaKey(token)] = value + OFFSET;
    }

    /**
        Returns the remaining amount of withdrawal allowed for this day.
        If the daily allowance was not yet set, it is calculated and returned.
     */
    function getRemainingIntradayAllowance(address token) internal view returns (uint256) {
        if (!isWithdrawQuotaInitialized(token)) {
            return calculateIntradayAllowance(token);
        }
        return getIntradayQuota(token);
    }

    /**
        Consumes the intraday allowance for a given token.
        If the allowance was not yet calculated, it is calculated and consumed.
     */
    function consumeWithdrawQuota(address token, uint256 amount) internal {
        uint256 intradayAllowance = getRemainingIntradayAllowance(token);
        require(intradayAllowance >= amount, "EXCEEDS_GLOBAL_WITHDRAW_LIMIT");
        setIntradayQuota(token, intradayAllowance - amount);
    }
}

// File: starkware/cairo/eth/CairoConstants.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;

library CairoConstants {
    uint256 public constant FIELD_PRIME =
        0x800000000000011000000000000000000000000000000000000000000000001;
}

// File: src/solidity/utils/Felt252.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;



/**
 * @dev String to felt functions.
 *
 * These functions convert string to felt (felt252) uint value.
 * The felt value is the Starknet short string representation.
 *
 * As felt value is bound by the field prime, it limits the length of the represented string.
 * For felt252 the limit is 31 characters.
 *
 * `safeToFelt()` converts to felt as many as 31 characters of the string.
 * i.e. for a long string: safeToFelt(string) == toFelt(string[:31]).
 *
 * When `toFelt()` accepts a long string - it fails and the call revert.
 */
library Felt252 {
    uint256 constant MAX_SHORT_STRING_LENGTH = 31;

    /**
      Convert a string to felt uint value.
      Reverts if the string is longer than 31 characters.
     */
    function toFelt(string memory shortString) internal pure returns (uint256) {
        uint256 length = strlen(shortString);
        return strToFelt(shortString, length);
    }

    /**
      Safely convert a string to felt uint value.
      For a string up to 31 characters, behaves identically ot `toFelt`.
      For longer strings, it returns the felt representation of the first 31 characters.
     */
    function safeToFelt(string memory string_) internal pure returns (uint256) {
        uint256 len = min(MAX_SHORT_STRING_LENGTH, strlen(string_));
        return strToFelt(string_, len);
    }

    function strToFelt(string memory string_, uint256 length) private pure returns (uint256) {
        require(length <= MAX_SHORT_STRING_LENGTH, "STRING_TOO_LONG");
        uint256 asUint;

        // As we process only short strings (<=31 chars),
        // we can look no further than the first 32 bytes of the string.
        // We convert first 32 bytes of the string to a uint.
        assembly {
            asUint := mload(add(string_, 32))
        }

        // We shift left the unused bits, so we don't get lsb zero padding.
        // The shift is 8 bits for every unused characters (of the looked at 32 bytes).
        uint256 felt252 = asUint >> (8 * (32 - length));
        return felt252;
    }

    /**
      Returns string length.
     */
    function strlen(string memory string_) private pure returns (uint256) {
        bytes memory bytes_;
        assembly {
            bytes_ := string_
        }
        return bytes_.length;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library UintFelt252 {
    function isValidL2Address(uint256 l2Address) internal pure returns (bool) {
        return (l2Address != 0 && isFelt(l2Address));
    }

    function isFelt(uint256 maybeFelt) internal pure returns (bool) {
        return (maybeFelt < CairoConstants.FIELD_PRIME);
    }
}

// File: src/solidity/StarknetTokenBridge.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.20;




















contract StarknetTokenBridge is
    IStarkgateBridge,
    IStarkgateService,
    Identity,
    Fees,
    StarknetTokenStorage,
    ProxySupport
{
    using Addresses for address;
    using Felt252 for string;
    using UintFelt252 for uint256;

    event TokenEnrollmentInitiated(address token, bytes32 deploymentMsgHash);
    event TokenDeactivated(address token);

    event DepositWithMessage(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256[] message,
        uint256 nonce,
        uint256 fee
    );
    event DepositWithMessageCancelRequest(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256[] message,
        uint256 nonce
    );
    event DepositWithMessageReclaimed(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256[] message,
        uint256 nonce
    );
    event Withdrawal(address indexed recipient, address indexed token, uint256 amount);
    event SetL2TokenBridge(uint256 value);
    event SetMaxTotalBalance(address indexed token, uint256 value);
    event Deposit(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256 nonce,
        uint256 fee
    );
    event DepositCancelRequest(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256 nonce
    );
    event DepositReclaimed(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256 nonce
    );
    event WithdrawalLimitEnabled(address indexed sender, address indexed token);
    event WithdrawalLimitDisabled(address indexed sender, address indexed token);
    uint256 constant N_DEPOSIT_PAYLOAD_ARGS = 5;
    uint256 constant DEPOSIT_MESSAGE_FIXED_SIZE = 1;

    function identify() external pure virtual returns (string memory) {
        return "StarkWare_StarknetTokenBridge_2.0_5";
    }

    function validateInitData(bytes calldata data) internal view virtual override {
        require(data.length == 64, "ILLEGAL_DATA_SIZE");
        (address manager_, address messagingContract_) = abi.decode(data, (address, address));
        require(messagingContract_.isContract(), "INVALID_MESSAGING_CONTRACT_ADDRESS");
        require(manager_.isContract(), "INVALID_MANAGER_CONTRACT_ADDRESS");
    }

    /*
      Gets the addresses of bridgedToken & messagingContract from the ProxySupport initialize(),
      and sets the storage slot accordingly.
    */
    function initializeContractState(bytes calldata data) internal override {
        (address manager_, address messagingContract_) = abi.decode(data, (address, address));
        messagingContract(messagingContract_);
        setManager(manager_);
        WithdrawalLimit.setWithdrawLimitPct(WithdrawalLimit.DEFAULT_WITHDRAW_LIMIT_PCT);
    }

    function isInitialized() internal view virtual override returns (bool) {
        return address(messagingContract()) != address(0);
    }

    /*
      No processing needed, as there are no sub-contracts to this contract.
    */
    function processSubContractAddresses(bytes calldata subContractAddresses) internal override {}

    function numOfSubContracts() internal pure override returns (uint256) {
        return 0;
    }

    modifier onlyManager() {
        require(manager() == msg.sender, "ONLY_MANAGER");
        _;
    }

    modifier skipUnlessPending(address token) {
        if (tokenSettings()[token].tokenStatus != TokenStatus.Pending) return;
        _;
    }

    modifier onlyServicingToken(address token) {
        require(isServicingToken(token), "TOKEN_NOT_SERVICED");
        _;
    }

    function estimateDepositFeeWei() external pure returns (uint256) {
        return Fees.estimateDepositFee();
    }

    function estimateEnrollmentFeeWei() external pure returns (uint256) {
        return Fees.estimateEnrollmentFee();
    }

    // Virtual functions.
    function acceptDeposit(address token, uint256 amount) internal virtual returns (uint256) {
        Fees.checkFee(msg.value);
        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        require(currentBalance + amount <= getMaxTotalBalance(token), "MAX_BALANCE_EXCEEDED");
        Transfers.transferIn(token, msg.sender, amount);
        return msg.value;
    }

    function transferOutFunds(
        address token,
        uint256 amount,
        address recipient
    ) internal virtual {
        Transfers.transferOut(token, recipient, amount);
    }

    /**
        Initiates the enrollment of a token into the system.
        This function is used to initiate the enrollment process of a token.
        The token is marked as 'Pending' because the success of the deployment is uncertain at this stage.
        The deployment message's existence is checked, indicating that deployment has been attempted.
        The success of the deployment is determined at a later stage during the application's lifecycle.
        Only the manager, who initiates the deployment, can call this function.

        @param token The address of the token contract to be enrolled.
        No return value, but it updates the token's status to 'Pending' and records the deployment message and expiration time.
        Emits a `TokenEnrollmentInitiated` event when the enrollment is initiated.
        Throws an error if the sender is not the manager or if the deployment message does not exist.
     */
    function enrollToken(address token) external payable virtual onlyManager {
        require(
            tokenSettings()[token].tokenStatus == TokenStatus.Unknown,
            "TOKEN_ALREADY_ENROLLED"
        );
        // send message.
        bytes32 deploymentMsgHash = sendDeployMessage(token);

        require(
            messagingContract().l1ToL2Messages(deploymentMsgHash) > 0,
            "DEPLOYMENT_MESSAGE_NOT_EXIST"
        );
        tokenSettings()[token].tokenStatus = TokenStatus.Pending;
        tokenSettings()[token].deploymentMsgHash = deploymentMsgHash;
        tokenSettings()[token].pendingDeploymentExpiration = block.timestamp + MAX_PENDING_DURATION;
        emit TokenEnrollmentInitiated(token, deploymentMsgHash);
    }

    function getStatus(address token) external view returns (TokenStatus) {
        return tokenSettings()[token].tokenStatus;
    }

    function isServicingToken(address token) public view returns (bool) {
        TokenStatus status = tokenSettings()[token].tokenStatus;
        return (status == TokenStatus.Pending || status == TokenStatus.Active);
    }

    /**
        Returns the remaining amount of withdrawal allowed for this day.
        If the daily allowance was not yet set, it is calculated and returned.
        If the withdraw limit is not enabled for that token - the uint256.max is returned.
     */
    function getRemainingIntradayAllowance(address token) external view returns (uint256) {
        return
            tokenSettings()[token].withdrawalLimitApplied
                ? WithdrawalLimit.getRemainingIntradayAllowance(token)
                : type(uint256).max;
    }

    /**
        Deactivates a token in the system.
        This function is used to deactivate a token that was previously enrolled.
        Only the manager, who initiated the enrollment, can call this function.

        @param token The address of the token contract to be deactivated.
        No return value, but it updates the token's status to 'Deactivated'.
        Emits a `TokenDeactivated` event when the deactivation is successful.
        Throws an error if the token is not enrolled or if the sender is not the manager.

     */
    function deactivate(address token) external virtual onlyManager {
        require(tokenSettings()[token].tokenStatus != TokenStatus.Unknown, "UNKNOWN_TOKEN");
        tokenSettings()[token].tokenStatus = TokenStatus.Deactivated;
        emit TokenDeactivated(token);
    }

    /**
        Checks token deployment status.
        Relies on Starknet clearing L1-L2 message upon successful completion of deployment.
        Processing: Check the l1-l2 deployment message. Set status to `active` If consumed.
        If not consumed after the expected duration, it returns the status to unknown.
     */
    function checkDeploymentStatus(address token) public skipUnlessPending(token) {
        TokenSettings storage settings = tokenSettings()[token];
        bytes32 msgHash = settings.deploymentMsgHash;

        if (messagingContract().l1ToL2Messages(msgHash) == 0) {
            settings.tokenStatus = TokenStatus.Active;
        } else if (block.timestamp > settings.pendingDeploymentExpiration) {
            delete tokenSettings()[token];
            address registry = IStarkgateManager(manager()).getRegistry();
            IStarkgateRegistry(registry).selfRemove(token);
        }
    }

    function depositWithMessage(
        address token,
        uint256 amount,
        uint256 l2Recipient,
        uint256[] calldata message
    ) external payable onlyServicingToken(token) {
        uint256 fee = acceptDeposit(token, amount);
        uint256 nonce = sendDepositMessage(
            token,
            amount,
            l2Recipient,
            message,
            HANDLE_DEPOSIT_WITH_MESSAGE_SELECTOR,
            fee
        );
        emitDepositEvent(
            token,
            amount,
            l2Recipient,
            message,
            HANDLE_DEPOSIT_WITH_MESSAGE_SELECTOR,
            nonce,
            fee
        );

        // Piggy-back the deposit tx to check and update the status of token bridge deployment.
        checkDeploymentStatus(token);
    }

    function deposit(
        address token,
        uint256 amount,
        uint256 l2Recipient
    ) external payable onlyServicingToken(token) {
        uint256[] memory noMessage = new uint256[](0);
        uint256 fee = acceptDeposit(token, amount);
        uint256 nonce = sendDepositMessage(
            token,
            amount,
            l2Recipient,
            noMessage,
            HANDLE_TOKEN_DEPOSIT_SELECTOR,
            fee
        );
        emitDepositEvent(
            token,
            amount,
            l2Recipient,
            noMessage,
            HANDLE_TOKEN_DEPOSIT_SELECTOR,
            nonce,
            fee
        );

        // Piggy-back the deposit tx to check and update the status of token bridge deployment.
        checkDeploymentStatus(token);
    }

    function emitDepositEvent(
        address token,
        uint256 amount,
        uint256 l2Recipient,
        uint256[] memory message,
        uint256 selector,
        uint256 nonce,
        uint256 fee
    ) internal {
        if (selector == HANDLE_TOKEN_DEPOSIT_SELECTOR) {
            emit Deposit(msg.sender, token, amount, l2Recipient, nonce, fee);
        } else {
            require(selector == HANDLE_DEPOSIT_WITH_MESSAGE_SELECTOR, "UNKNOWN_SELECTOR");
            emit DepositWithMessage(msg.sender, token, amount, l2Recipient, message, nonce, fee);
        }
    }

    function setL2TokenBridge(uint256 l2TokenBridge_) external onlyAppGovernor {
        require(isInitialized(), "CONTRACT_NOT_INITIALIZED");
        require(l2TokenBridge_.isValidL2Address(), "L2_ADDRESS_OUT_OF_RANGE");
        l2TokenBridge(l2TokenBridge_);
        emit SetL2TokenBridge(l2TokenBridge_);
    }

    /**
        Set withdrawal limit for a token.
     */
    function enableWithdrawalLimit(address token) external onlySecurityAgent {
        tokenSettings()[token].withdrawalLimitApplied = true;
        emit WithdrawalLimitEnabled(msg.sender, token);
    }

    /**
        Unset withdrawal limit for a token.
     */
    function disableWithdrawalLimit(address token) external onlySecurityAdmin {
        tokenSettings()[token].withdrawalLimitApplied = false;
        emit WithdrawalLimitDisabled(msg.sender, token);
    }

    /**
       Set the maximum allowed balance of the bridge.
       Note: It is possible to set a lower value than the current total balance.
       In this case, deposits will not be possible, until enough withdrawls are done, such that the
       total balance is below the limit.
     */
    function setMaxTotalBalance(address token, uint256 maxTotalBalance_) external onlyAppGovernor {
        require(maxTotalBalance_ != 0, "INVALID_MAX_TOTAL_BALANCE");
        emit SetMaxTotalBalance(token, maxTotalBalance_);
        tokenSettings()[token].maxTotalBalance = maxTotalBalance_;
    }

    // Returns the maximal allowed balance of the bridge
    // If the value is 0, it means that there is no limit.
    function getMaxTotalBalance(address token) public view returns (uint256) {
        uint256 maxTotalBalance = tokenSettings()[token].maxTotalBalance;
        return maxTotalBalance == 0 ? type(uint256).max : maxTotalBalance;
    }

    // The max depsoit limitation is deprecated.
    // For Backward compatibility, we return maxUint256, which means no limitation.
    function maxDeposit() external pure returns (uint256) {
        return type(uint256).max;
    }

    function deployMessagePayload(address token) private view returns (uint256[] memory) {
        IERC20Metadata erc20 = IERC20Metadata(token);
        uint256[] memory payload = new uint256[](4);
        payload[0] = uint256(uint160(token));
        payload[1] = erc20.name().safeToFelt();
        payload[2] = erc20.symbol().safeToFelt();
        payload[3] = uint256(erc20.decimals());
        return payload;
    }

    function depositMessagePayload(
        address token,
        uint256 amount,
        uint256 l2Recipient,
        bool withMessage,
        uint256[] memory message
    ) private view returns (uint256[] memory) {
        uint256 MESSAGE_OFFSET = withMessage
            ? N_DEPOSIT_PAYLOAD_ARGS + DEPOSIT_MESSAGE_FIXED_SIZE
            : N_DEPOSIT_PAYLOAD_ARGS;
        uint256[] memory payload = new uint256[](MESSAGE_OFFSET + message.length);
        payload[0] = uint256(uint160(token));
        payload[1] = uint256(uint160(msg.sender));
        payload[2] = l2Recipient;
        payload[3] = amount & (UINT256_PART_SIZE - 1);
        payload[4] = amount >> UINT256_PART_SIZE_BITS;
        if (withMessage) {
            payload[MESSAGE_OFFSET - 1] = message.length;
            for (uint256 i = 0; i < message.length; i++) {
                require(message[i].isFelt(), "INVALID_MESSAGE_DATA");
                payload[i + MESSAGE_OFFSET] = message[i];
            }
        }
        return payload;
    }

    function depositMessagePayload(
        address token,
        uint256 amount,
        uint256 l2Recipient
    ) private view returns (uint256[] memory) {
        uint256[] memory noMessage = new uint256[](0);
        return
            depositMessagePayload(
                token,
                amount,
                l2Recipient,
                false, /*without message*/
                noMessage
            );
    }

    function sendDeployMessage(address token) internal returns (bytes32) {
        require(l2TokenBridge() != 0, "L2_BRIDGE_NOT_SET");
        Fees.checkFee(msg.value);

        (bytes32 deploymentMsgHash, ) = messagingContract().sendMessageToL2{value: msg.value}(
            l2TokenBridge(),
            HANDLE_TOKEN_DEPLOYMENT_SELECTOR,
            deployMessagePayload(token)
        );
        return deploymentMsgHash;
    }

    function sendDepositMessage(
        address token,
        uint256 amount,
        uint256 l2Recipient,
        uint256[] memory message,
        uint256 selector,
        uint256 fee
    ) internal returns (uint256) {
        require(l2TokenBridge() != 0, "L2_BRIDGE_NOT_SET");
        require(amount > 0, "ZERO_DEPOSIT");
        require(l2Recipient.isValidL2Address(), "L2_ADDRESS_OUT_OF_RANGE");

        bool isWithMsg = selector == HANDLE_DEPOSIT_WITH_MESSAGE_SELECTOR;
        (, uint256 nonce) = messagingContract().sendMessageToL2{value: fee}(
            l2TokenBridge(),
            selector,
            depositMessagePayload(token, amount, l2Recipient, isWithMsg, message)
        );

        // The function exclusively supports two specific selectors, and any attempt to use an unknown
        // selector will result in a transaction failure.
        return nonce;
    }

    function consumeMessage(
        address token,
        uint256 amount,
        address recipient
    ) internal virtual {
        require(l2TokenBridge() != 0, "L2_BRIDGE_NOT_SET");
        uint256[] memory payload = new uint256[](5);
        payload[0] = TRANSFER_FROM_STARKNET;
        payload[1] = uint256(uint160(recipient));
        payload[2] = uint256(uint160(token));
        payload[3] = amount & (UINT256_PART_SIZE - 1);
        payload[4] = amount >> UINT256_PART_SIZE_BITS;
        messagingContract().consumeMessageFromL2(l2TokenBridge(), payload);
    }

    function withdraw(
        address token,
        uint256 amount,
        address recipient
    ) public {
        // Make sure we don't accidentally burn funds.
        require(recipient != address(0x0), "INVALID_RECIPIENT");

        // The call to consumeMessage will succeed only if a matching L2->L1 message
        // exists and is ready for consumption.
        consumeMessage(token, amount, recipient);
        // Check if the withdrawal limit is enabled for that token.
        if (tokenSettings()[token].withdrawalLimitApplied) {
            // If the withdrawal limit is enabled, consume the quota.
            WithdrawalLimit.consumeWithdrawQuota(token, amount);
        }
        transferOutFunds(token, amount, recipient);
        emit Withdrawal(recipient, token, amount);
    }

    function withdraw(address token, uint256 amount) external {
        withdraw(token, amount, msg.sender);
    }

    /*
      A deposit cancellation requires two steps:
      1. The depositor should send a depositCancelRequest request with deposit details & nonce.
      2. After a predetermined time (cancellation delay), the depositor can claim back the funds by
         calling depositReclaim (using the same arguments).

      Note: As long as the depositReclaim was not performed, the deposit may be processed, even if
            the cancellation delay time has already passed. Only the depositor is allowed to cancel
            a deposit, and only before depositReclaim was performed.
    */
    function depositCancelRequest(
        address token,
        uint256 amount,
        uint256 l2Recipient,
        uint256 nonce
    ) external {
        messagingContract().startL1ToL2MessageCancellation(
            l2TokenBridge(),
            HANDLE_TOKEN_DEPOSIT_SELECTOR,
            depositMessagePayload(token, amount, l2Recipient),
            nonce
        );

        emit DepositCancelRequest(msg.sender, token, amount, l2Recipient, nonce);
    }

    /*
        See: depositCancelRequest docstring.
    */
    function depositWithMessageCancelRequest(
        address token,
        uint256 amount,
        uint256 l2Recipient,
        uint256[] calldata message,
        uint256 nonce
    ) external {
        messagingContract().startL1ToL2MessageCancellation(
            l2TokenBridge(),
            HANDLE_DEPOSIT_WITH_MESSAGE_SELECTOR,
            depositMessagePayload(
                token,
                amount,
                l2Recipient,
                true, /*with message*/
                message
            ),
            nonce
        );

        emit DepositWithMessageCancelRequest(
            msg.sender,
            token,
            amount,
            l2Recipient,
            message,
            nonce
        );
    }

    function depositWithMessageReclaim(
        address token,
        uint256 amount,
        uint256 l2Recipient,
        uint256[] calldata message,
        uint256 nonce
    ) external {
        messagingContract().cancelL1ToL2Message(
            l2TokenBridge(),
            HANDLE_DEPOSIT_WITH_MESSAGE_SELECTOR,
            depositMessagePayload(
                token,
                amount,
                l2Recipient,
                true, /*with message*/
                message
            ),
            nonce
        );

        transferOutFunds(token, amount, msg.sender);
        emit DepositWithMessageReclaimed(msg.sender, token, amount, l2Recipient, message, nonce);
    }

    function depositReclaim(
        address token,
        uint256 amount,
        uint256 l2Recipient,
        uint256 nonce
    ) external {
        messagingContract().cancelL1ToL2Message(
            l2TokenBridge(),
            HANDLE_TOKEN_DEPOSIT_SELECTOR,
            depositMessagePayload(token, amount, l2Recipient),
            nonce
        );

        transferOutFunds(token, amount, msg.sender);
        emit DepositReclaimed(msg.sender, token, amount, l2Recipient, nonce);
    }
}

// File: starkware/solidity/components/OverrideLegacyProxyGovernance.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.0;



struct GovernanceInfoStruct {
    mapping(address => bool) effectiveGovernors;
    address candidateGovernor;
    bool initialized;
}

// PROXY_GOVERNANCE_TAG = "StarkEx.Proxy.2019.GovernorsInformation"
// LEGACY_PROXY_GOVERNOR_SLOT = Web3.solidityKeccak(["string", "uint256"], [PROXY_GOVERNANCE_TAG, 0]) .
bytes32 constant LEGACY_PROXY_GOVERNOR_SLOT = 0x45f38e273862f8834bd2fe7a449988f63de55a7a5b685dea46ccedeb69cf0e26;

/**
  This contract allows the governance admin (which is the top of the `Roles` heirarchy),
  to override the proxy governance.
*/
abstract contract OverrideLegacyProxyGovernance {
    event LogNewGovernorAccepted(address acceptedGovernor);
    event LogRemovedGovernor(address removedGovernor);

    modifier GovernanceAdminOnly() {
        require(
            AccessControl.hasRole(GOVERNANCE_ADMIN, AccessControl._msgSender()),
            "GOVERNANCE_ADMIN_ONLY"
        );
        _;
    }

    function legacyProxyGovInfo() private pure returns (GovernanceInfoStruct storage gov) {
        bytes32 location = LEGACY_PROXY_GOVERNOR_SLOT;
        assembly {
            gov.slot := location
        }
    }

    /*
      Assigns `account` as proxy governor and clears pending govneror candidate.
    */
    function assignLegacyProxyGovernor(address account) external GovernanceAdminOnly {
        GovernanceInfoStruct storage legacyProxyGov = legacyProxyGovInfo();
        legacyProxyGov.effectiveGovernors[account] = true;
        delete legacyProxyGov.candidateGovernor;
        emit LogNewGovernorAccepted(account);
    }

    /*
      Removes `account` from proxy governor role and clears pending govneror candidate.
    */
    function removeLegacyProxyGovernor(address account) external GovernanceAdminOnly {
        GovernanceInfoStruct storage legacyProxyGov = legacyProxyGovInfo();
        legacyProxyGov.effectiveGovernors[account] = false;
        delete legacyProxyGov.candidateGovernor;
        emit LogRemovedGovernor(account);
    }
}

// File: src/solidity/LegacyBridge.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.20;





/*
  Common implementation for the Upgraded legacy bridges, contains all the legacy relevant
  code except for the handling of Eth transfers (vs. ERC20).
*/
abstract contract LegacyBridge is StarknetTokenBridge, OverrideLegacyProxyGovernance {
    /* Legacy events */
    event LogDepositCancelRequest(
        address indexed sender,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256 nonce
    );
    event LogDepositReclaimed(
        address indexed sender,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256 nonce
    );
    event LogDeposit(
        address indexed sender,
        uint256 amount,
        uint256 indexed l2Recipient,
        uint256 nonce,
        uint256 fee
    );

    function bridgedToken() internal view returns (address) {
        return NamedStorage.getAddressValue(BRIDGED_TOKEN_TAG);
    }

    function depositors() internal pure returns (mapping(uint256 => address) storage) {
        return NamedStorage.uintToAddressMapping(DEPOSITOR_ADDRESSES_TAG);
    }

    modifier onlyDepositor(uint256 nonce) {
        require(depositors()[nonce] == msg.sender, "ONLY_DEPOSITOR");
        _;
    }

    /*
      Upgraded legacy bridge does not support token enrollment.
    */
    function enrollToken(
        address /*token*/
    ) external payable virtual override {
        revert("UNSUPPORTED");
    }

    /// Support Legacy ABI.
    /*
      Deposit, using the old version ABI.
      Note - The actual L1-L2 message sent to the l2-bridge is of the new format.
    */
    function deposit(uint256 amount, uint256 l2Recipient) external payable {
        uint256[] memory noMessage = new uint256[](0);
        address token = bridgedToken();
        uint256 fee = acceptDeposit(token, amount);
        uint256 nonce = sendDepositMessage(
            token,
            amount,
            l2Recipient,
            noMessage,
            HANDLE_TOKEN_DEPOSIT_SELECTOR,
            fee
        );
        emitDepositEvent(
            token,
            amount,
            l2Recipient,
            noMessage,
            HANDLE_TOKEN_DEPOSIT_SELECTOR,
            nonce,
            fee
        );
        // Emits a deposit event of the old ABI, emitted in addition to the new one.
        emit LogDeposit(msg.sender, amount, l2Recipient, nonce, fee);
    }

    function maxTotalBalance() external view returns (uint256) {
        return getMaxTotalBalance(bridgedToken());
    }

    function withdraw(uint256 amount, address recipient) external {
        withdraw(bridgedToken(), amount, recipient);
    }

    function withdraw(uint256 amount) external {
        withdraw(bridgedToken(), amount, msg.sender);
    }

    /*
      This comsume message override the base implementation from StarknetTokenBridge,
      and supports withdraw of both the new format and the legacy format.
    */
    function consumeMessage(
        address token,
        uint256 amount,
        address recipient
    ) internal virtual override {
        require(l2TokenBridge() != 0, "L2_BRIDGE_NOT_SET");
        uint256 u_recipient = uint256(uint160(recipient));
        uint256 amount_low = amount & (UINT256_PART_SIZE - 1);
        uint256 amount_high = amount >> UINT256_PART_SIZE_BITS;

        // Compose the new format of L2-L1 consumption.
        uint256[] memory payload = new uint256[](5);
        payload[0] = TRANSFER_FROM_STARKNET;
        payload[1] = u_recipient;
        payload[2] = uint256(uint160(token));
        payload[3] = amount_low;
        payload[4] = amount_high;
        // Contain failure of comsumption (e.g. no message to consume).
        try messagingContract().consumeMessageFromL2(l2TokenBridge(), payload) {} catch Error(
            string memory
        ) {
            // Upon failure with the new format,
            // compose the old format,
            // in case the withdrawal was initiated on a bridge with an older version.
            payload = new uint256[](4);
            payload[0] = TRANSFER_FROM_STARKNET;
            payload[1] = u_recipient;
            payload[2] = amount_low;
            payload[3] = amount_high;
            messagingContract().consumeMessageFromL2(l2TokenBridge(), payload);

            // The old msg format is valid only for the legacy bridged token.
            // Since the withdraw flow can be token-explicit with any token,
            // we must enforce that the token is identical to the legacy token.
            require(bridgedToken() == token, "NOT_LEGACY_BRIDGED_TOKEN");
        }
    }

    // The old version of depositCancelRequest (renamed to avoid confusion).
    // Supports cancellation of deposits that were made before the L1 bridge was upgraded.
    function legacyDepositCancelRequest(
        uint256 amount,
        uint256 l2Recipient,
        uint256 nonce
    ) external onlyDepositor(nonce) {
        messagingContract().startL1ToL2MessageCancellation(
            l2TokenBridge(),
            HANDLE_DEPOSIT_SELECTOR,
            legacyDepositMessagePayload(amount, l2Recipient),
            nonce
        );
        emit LogDepositCancelRequest(msg.sender, amount, l2Recipient, nonce);
    }

    // The old version of depositReclaim (renamed to avoid confusion).
    // Supports reclaim of deposits that were made before the L1 bridge was upgraded.
    function legacyDepositReclaim(
        uint256 amount,
        uint256 l2Recipient,
        uint256 nonce
    ) external onlyDepositor(nonce) {
        messagingContract().cancelL1ToL2Message(
            l2TokenBridge(),
            HANDLE_DEPOSIT_SELECTOR,
            legacyDepositMessagePayload(amount, l2Recipient),
            nonce
        );

        transferOutFunds(bridgedToken(), amount, msg.sender);
        emit LogDepositReclaimed(msg.sender, amount, l2Recipient, nonce);
    }

    // Construct the deposit l1-l2 message payload of the older version.
    // (renamed to avoid confusion).
    function legacyDepositMessagePayload(uint256 amount, uint256 l2Recipient)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory payload = new uint256[](3);
        payload[0] = l2Recipient;
        payload[1] = amount & (UINT256_PART_SIZE - 1);
        payload[2] = amount >> UINT256_PART_SIZE_BITS;
        return payload;
    }
}

// File: src/solidity/StarknetERC20Bridge.sol

/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.8.20;



contract StarknetERC20Bridge is LegacyBridge {
    function identify() external pure override returns (string memory) {
        return "StarkWare_StarknetERC20Bridge_2.0_5";
    }
}
