// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: @openzeppelin/contracts-upgradeable-v4/access/IAccessControlUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/AddressUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable-v4/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/math/MathUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/math/SignedMathUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMathUpgradeable {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/StringsUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;




/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMathUpgradeable.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/introspection/IERC165Upgradeable.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/introspection/ERC165Upgradeable.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable-v4/access/AccessControlUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;







/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(account),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable-v4/token/ERC20/extensions/IERC20PermitUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts-upgradeable-v4/token/ERC20/IERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: @openzeppelin/contracts-upgradeable-v4/token/ERC20/extensions/IERC20MetadataUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts-upgradeable-v4/token/ERC20/ERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;






/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/cryptography/ECDSAUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;



/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}

// File: @openzeppelin/contracts-upgradeable-v4/interfaces/IERC5267Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.0;

interface IERC5267Upgradeable {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/cryptography/EIP712Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.8;





/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the `_domainSeparatorV4` function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712Upgradeable is Initializable, IERC5267Upgradeable {
    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// @custom:oz-renamed-from _HASHED_NAME
    bytes32 private _hashedName;
    /// @custom:oz-renamed-from _HASHED_VERSION
    bytes32 private _hashedVersion;

    string private _name;
    string private _version;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        _name = name;
        _version = version;

        // Reset prior values in storage if upgrading
        _hashedName = 0;
        _hashedVersion = 0;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator();
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash(), block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {EIP-5267}.
     *
     * _Available since v4.9._
     */
    function eip712Domain()
        public
        view
        virtual
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        // If the hashed name and version in storage are non-zero, the contract hasn't been properly initialized
        // and the EIP712 domain is not reliable, as it will be missing name and version.
        require(_hashedName == 0 && _hashedVersion == 0, "EIP712: Uninitialized");

        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712Name() internal virtual view returns (string memory) {
        return _name;
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712Version() internal virtual view returns (string memory) {
        return _version;
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: In previous versions this function was virtual. In this version you should override `_EIP712Name` instead.
     */
    function _EIP712NameHash() internal view returns (bytes32) {
        string memory name = _EIP712Name();
        if (bytes(name).length > 0) {
            return keccak256(bytes(name));
        } else {
            // If the name is empty, the contract may have been upgraded without initializing the new storage.
            // We return the name hash in storage if non-zero, otherwise we assume the name is empty by design.
            bytes32 hashedName = _hashedName;
            if (hashedName != 0) {
                return hashedName;
            } else {
                return keccak256("");
            }
        }
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: In previous versions this function was virtual. In this version you should override `_EIP712Version` instead.
     */
    function _EIP712VersionHash() internal view returns (bytes32) {
        string memory version = _EIP712Version();
        if (bytes(version).length > 0) {
            return keccak256(bytes(version));
        } else {
            // If the version is empty, the contract may have been upgraded without initializing the new storage.
            // We return the version hash in storage if non-zero, otherwise we assume the version is empty by design.
            bytes32 hashedVersion = _hashedVersion;
            if (hashedVersion != 0) {
                return hashedVersion;
            } else {
                return keccak256("");
            }
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/CountersUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts-upgradeable-v4/token/ERC20/extensions/ERC20PermitUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 51
 */
abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    /**
     * @dev In previous versions `_PERMIT_TYPEHASH` was declared as `immutable`.
     * However, to ensure consistency with the upgradeable transpiler, we will continue
     * to reserve a slot.
     * @custom:oz-renamed-from _PERMIT_TYPEHASH
     */
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    function __ERC20Permit_init(string memory name) internal onlyInitializing {
        __EIP712_init_unchained(name, "1");
    }

    function __ERC20Permit_init_unchained(string memory) internal onlyInitializing {}

    /**
     * @inheritdoc IERC20PermitUpgradeable
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSAUpgradeable.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC20PermitUpgradeable
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @inheritdoc IERC20PermitUpgradeable
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        CountersUpgradeable.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable-v4/token/ERC20/utils/SafeERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20Upgradeable token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && AddressUpgradeable.isContract(address(token));
    }
}

// File: @openzeppelin/contracts-upgradeable-v4/utils/structs/EnumerableSetUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File: contracts/v2/interfaces/IFxFractionalTokenV2.sol

pragma solidity ^0.8.0;

interface IFxFractionalTokenV2 {
  /**********
   * Errors *
   **********/

  /// @dev Thrown when caller is not treasury contract.
  error ErrorCallerIsNotTreasury();

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the net asset value for the token, multiplied by 1e18.
  function nav() external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Mint some token to someone.
  /// @param to The address of recipient.
  /// @param amount The amount of token to mint.
  function mint(address to, uint256 amount) external;

  /// @notice Burn some token from someone.
  /// @param from The address of owner to burn.
  /// @param amount The amount of token to burn.
  function burn(address from, uint256 amount) external;
}

// File: contracts/v2/interfaces/IFxMarketV2.sol

pragma solidity ^0.8.0;

interface IFxMarketV2 {
  /**********
   * Events *
   **********/

  /// @notice Emitted when fToken is minted.
  /// @param owner The address of base token owner.
  /// @param recipient The address of receiver for fToken or xToken.
  /// @param baseTokenIn The amount of base token deposited.
  /// @param fTokenOut The amount of fToken minted.
  /// @param mintFee The amount of mint fee charged.
  event MintFToken(
    address indexed owner,
    address indexed recipient,
    uint256 baseTokenIn,
    uint256 fTokenOut,
    uint256 mintFee
  );

  /// @notice Emitted when xToken is minted.
  /// @param owner The address of base token owner.
  /// @param recipient The address of receiver for fToken or xToken.
  /// @param baseTokenIn The amount of base token deposited.
  /// @param xTokenOut The amount of xToken minted.
  /// @param bonus The amount of base token as bonus.
  /// @param mintFee The amount of mint fee charged.
  event MintXToken(
    address indexed owner,
    address indexed recipient,
    uint256 baseTokenIn,
    uint256 xTokenOut,
    uint256 bonus,
    uint256 mintFee
  );

  /// @notice Emitted when someone redeem base token with fToken or xToken.
  /// @param owner The address of fToken and xToken owner.
  /// @param recipient The address of receiver for base token.
  /// @param fTokenBurned The amount of fToken burned.
  /// @param baseTokenOut The amount of base token redeemed.
  /// @param bonus The amount of base token as bonus.
  /// @param redeemFee The amount of redeem fee charged.
  event RedeemFToken(
    address indexed owner,
    address indexed recipient,
    uint256 fTokenBurned,
    uint256 baseTokenOut,
    uint256 bonus,
    uint256 redeemFee
  );

  /// @notice Emitted when someone redeem base token with fToken or xToken.
  /// @param owner The address of fToken and xToken owner.
  /// @param recipient The address of receiver for base token.
  /// @param xTokenBurned The amount of xToken burned.
  /// @param baseTokenOut The amount of base token redeemed.
  /// @param redeemFee The amount of redeem fee charged.
  event RedeemXToken(
    address indexed owner,
    address indexed recipient,
    uint256 xTokenBurned,
    uint256 baseTokenOut,
    uint256 redeemFee
  );

  /// @notice Emitted when the fee ratio for minting fToken is updated.
  /// @param defaultFeeRatio The new default fee ratio, multipled by 1e18.
  /// @param extraFeeRatio The new extra fee ratio, multipled by 1e18.
  event UpdateMintFeeRatioFToken(uint256 defaultFeeRatio, int256 extraFeeRatio);

  /// @notice Emitted when the fee ratio for minting xToken is updated.
  /// @param defaultFeeRatio The new default fee ratio, multipled by 1e18.
  /// @param extraFeeRatio The new extra fee ratio, multipled by 1e18.
  event UpdateMintFeeRatioXToken(uint256 defaultFeeRatio, int256 extraFeeRatio);

  /// @notice Emitted when the fee ratio for redeeming fToken is updated.
  /// @param defaultFeeRatio The new default fee ratio, multipled by 1e18.
  /// @param extraFeeRatio The new extra fee ratio, multipled by 1e18.
  event UpdateRedeemFeeRatioFToken(uint256 defaultFeeRatio, int256 extraFeeRatio);

  /// @notice Emitted when the fee ratio for redeeming xToken is updated.
  /// @param defaultFeeRatio The new default fee ratio, multipled by 1e18.
  /// @param extraFeeRatio The new extra fee ratio, multipled by 1e18.
  event UpdateRedeemFeeRatioXToken(uint256 defaultFeeRatio, int256 extraFeeRatio);

  /// @notice Emitted when the stability ratio is updated.
  /// @param oldRatio The previous collateral ratio to enter stability mode, multiplied by 1e18.
  /// @param newRatio The current collateral ratio to enter stability mode, multiplied by 1e18.
  event UpdateStabilityRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when the platform contract is updated.
  /// @param oldPlatform The address of previous platform contract.
  /// @param newPlatform The address of current platform contract.
  event UpdatePlatform(address indexed oldPlatform, address indexed newPlatform);

  /// @notice Emitted when the  reserve pool contract is updated.
  /// @param oldReservePool The address of previous reserve pool contract.
  /// @param newReservePool The address of current reserve pool contract.
  event UpdateReservePool(address indexed oldReservePool, address indexed newReservePool);

  /// @notice Emitted when the RebalancePoolRegistry contract is updated.
  /// @param oldRegistry The address of previous RebalancePoolRegistry contract.
  /// @param newRegistry The address of current RebalancePoolRegistry contract.
  event UpdateRebalancePoolRegistry(address indexed oldRegistry, address indexed newRegistry);

  /// @notice Pause or unpause mint.
  /// @param oldStatus The previous status for mint.
  /// @param newStatus The current status for mint.
  event UpdateMintStatus(bool oldStatus, bool newStatus);

  /// @notice Pause or unpause redeem.
  /// @param oldStatus The previous status for redeem.
  /// @param newStatus The current status for redeem.
  event UpdateRedeemStatus(bool oldStatus, bool newStatus);

  /// @notice Pause or unpause fToken mint in stability mode.
  /// @param oldStatus The previous status for mint.
  /// @param newStatus The current status for mint.
  event UpdateFTokenMintStatusInStabilityMode(bool oldStatus, bool newStatus);

  /// @notice Pause or unpause xToken redeem in stability mode.
  /// @param oldStatus The previous status for redeem.
  /// @param newStatus The current status for redeem.
  event UpdateXTokenRedeemStatusInStabilityMode(bool oldStatus, bool newStatus);

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the caller if not fUSD contract.
  error ErrorCallerNotFUSD();

  /// @dev Thrown when token mint is paused.
  error ErrorMintPaused();

  /// @dev Thrown when fToken mint is paused in stability mode.
  error ErrorFTokenMintPausedInStabilityMode();

  /// @dev Thrown when mint with zero amount base token.
  error ErrorMintZeroAmount();

  /// @dev Thrown when the amount of fToken is not enough.
  error ErrorInsufficientFTokenOutput();

  /// @dev Thrown when the amount of xToken is not enough.
  error ErrorInsufficientXTokenOutput();

  /// @dev Thrown when token redeem is paused.
  error ErrorRedeemPaused();

  /// @dev Thrown when xToken redeem is paused in stability mode.
  error ErrorXTokenRedeemPausedInStabilityMode();

  /// @dev Thrown when redeem with zero amount fToken or xToken.
  error ErrorRedeemZeroAmount();

  /// @dev Thrown when the amount of base token is not enough.
  error ErrorInsufficientBaseOutput();

  /// @dev Thrown when the stability ratio is too large.
  error ErrorStabilityRatioTooLarge();

  /// @dev Thrown when the default fee is too large.
  error ErrorDefaultFeeTooLarge();

  /// @dev Thrown when the delta fee is too small.
  error ErrorDeltaFeeTooSmall();

  /// @dev Thrown when the sum of default fee and delta fee is too large.
  error ErrorTotalFeeTooLarge();

  /// @dev Thrown when the given address is zero.
  error ErrorZeroAddress();

  /*************************
   * Public View Functions *
   *************************/

  /// @notice The address of Treasury contract.
  function treasury() external view returns (address);

  /// @notice Return the address of base token.
  function baseToken() external view returns (address);

  /// @notice Return the address fractional base token.
  function fToken() external view returns (address);

  /// @notice Return the address leveraged base token.
  function xToken() external view returns (address);

  /// @notice Return the address of fxUSD token.
  function fxUSD() external view returns (address);

  /// @notice Return the collateral ratio to enter stability mode, multiplied by 1e18.
  function stabilityRatio() external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Mint some fToken with some base token.
  /// @param baseIn The amount of wrapped value of base token supplied, use `uint256(-1)` to supply all base token.
  /// @param recipient The address of receiver for fToken.
  /// @param minFTokenMinted The minimum amount of fToken should be received.
  /// @return fTokenMinted The amount of fToken should be received.
  function mintFToken(
    uint256 baseIn,
    address recipient,
    uint256 minFTokenMinted
  ) external returns (uint256 fTokenMinted);

  /// @notice Mint some xToken with some base token.
  /// @param baseIn The amount of wrapped value of base token supplied, use `uint256(-1)` to supply all base token.
  /// @param recipient The address of receiver for xToken.
  /// @param minXTokenMinted The minimum amount of xToken should be received.
  /// @return xTokenMinted The amount of xToken should be received.
  /// @return bonus The amount of wrapped value of base token as bonus.
  function mintXToken(
    uint256 baseIn,
    address recipient,
    uint256 minXTokenMinted
  ) external returns (uint256 xTokenMinted, uint256 bonus);

  /// @notice Redeem base token with fToken.
  /// @param fTokenIn the amount of fToken to redeem, use `uint256(-1)` to redeem all fToken.
  /// @param recipient The address of receiver for base token.
  /// @param minBaseOut The minimum amount of wrapped value of base token should be received.
  /// @return baseOut The amount of wrapped value of base token should be received.
  /// @return bonus The amount of wrapped value of base token as bonus.
  function redeemFToken(
    uint256 fTokenIn,
    address recipient,
    uint256 minBaseOut
  ) external returns (uint256 baseOut, uint256 bonus);

  /// @notice Redeem base token with xToken.
  /// @param xTokenIn the amount of xToken to redeem, use `uint256(-1)` to redeem all xToken.
  /// @param recipient The address of receiver for base token.
  /// @param minBaseOut The minimum amount of wrapped value of base token should be received.
  /// @return baseOut The amount of wrapped value of base token should be received.
  function redeemXToken(
    uint256 xTokenIn,
    address recipient,
    uint256 minBaseOut
  ) external returns (uint256 baseOut);
}

// File: contracts/v2/interfaces/IFxTreasuryV2.sol

pragma solidity ^0.8.0;

interface IFxTreasuryV2 {
  /**********
   * Events *
   **********/

  /// @notice Emitted when the platform contract is updated.
  /// @param oldPlatform The address of previous platform contract.
  /// @param newPlatform The address of current platform contract.
  event UpdatePlatform(address indexed oldPlatform, address indexed newPlatform);

  /// @notice Emitted when the RebalancePoolSplitter contract is updated.
  /// @param oldRebalancePoolSplitter The address of previous RebalancePoolSplitter contract.
  /// @param newRebalancePoolSplitter The address of current RebalancePoolSplitter.
  event UpdateRebalancePoolSplitter(address indexed oldRebalancePoolSplitter, address indexed newRebalancePoolSplitter);

  /// @notice Emitted when the price oracle contract is updated.
  /// @param oldPriceOracle The address of previous price oracle.
  /// @param newPriceOracle The address of current price oracle.
  event UpdatePriceOracle(address indexed oldPriceOracle, address indexed newPriceOracle);

  /// @notice Emitted when the strategy contract is updated.
  /// @param oldStrategy The address of previous strategy.
  /// @param newStrategy The address of current strategy.
  event UpdateStrategy(address indexed oldStrategy, address indexed newStrategy);

  /// @notice Emitted when the base token cap is updated.
  /// @param oldBaseTokenCap The value of previous base token cap.
  /// @param newBaseTokenCap The value of current base token cap.
  event UpdateBaseTokenCap(uint256 oldBaseTokenCap, uint256 newBaseTokenCap);

  /// @notice Emitted when the EMA sample interval is updated.
  /// @param oldSampleInterval The value of previous EMA sample interval.
  /// @param newSampleInterval The value of current EMA sample interval.
  event UpdateEMASampleInterval(uint256 oldSampleInterval, uint256 newSampleInterval);

  /// @notice Emitted when the reference price is updated.
  /// @param oldPrice The value of previous reference price.
  /// @param newPrice The value of current reference price.
  event Settle(uint256 oldPrice, uint256 newPrice);

  /// @notice Emitted when the ratio for rebalance pool is updated.
  /// @param oldRatio The value of the previous ratio, multiplied by 1e9.
  /// @param newRatio The value of the current ratio, multiplied by 1e9.
  event UpdateRebalancePoolRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when the ratio for harvester is updated.
  /// @param oldRatio The value of the previous ratio, multiplied by 1e9.
  /// @param newRatio The value of the current ratio, multiplied by 1e9.
  event UpdateHarvesterRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when someone harvest pending stETH rewards.
  /// @param caller The address of caller.
  /// @param totalRewards The amount of total harvested rewards.
  /// @param rebalancePoolRewards The amount of harvested rewards distributed to stability pool.
  /// @param harvestBounty The amount of harvested rewards distributed to caller as harvest bounty.
  event Harvest(address indexed caller, uint256 totalRewards, uint256 rebalancePoolRewards, uint256 harvestBounty);

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the collateral ratio is smaller than 100%.
  error ErrorCollateralRatioTooSmall();

  /// @dev Thrown when mint exceed total capacity.
  error ErrorExceedTotalCap();

  /// @dev Thrown when the oracle price is invalid.
  error ErrorInvalidOraclePrice();

  /// @dev Thrown when the twap price is invalid.
  error ErrorInvalidTwapPrice();

  /// @dev Thrown when initialize protocol twice.
  error ErrorProtocolInitialized();

  /// @dev Thrown when the initial amount of base token is not enough.
  error ErrorInsufficientInitialBaseToken();

  /// @dev Thrown when current is under collateral.
  error ErrorUnderCollateral();

  /// @dev Thrown when the sample internal for EMA is too small.
  error ErrorEMASampleIntervalTooSmall();

  /// @dev Thrown when the expense ratio exceeds `MAX_REBALANCE_POOL_RATIO`.
  error ErrorRebalancePoolRatioTooLarge();

  /// @dev Thrown when the harvester ratio exceeds `MAX_HARVESTER_RATIO`.
  error ErrorHarvesterRatioTooLarge();

  /// @dev Thrown when the given address is zero.
  error ErrorZeroAddress();

  /*********
   * Enums *
   *********/

  enum Action {
    None,
    MintFToken,
    MintXToken,
    RedeemFToken,
    RedeemXToken
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the address of price oracle contract.
  function priceOracle() external view returns (address);

  /// @notice Return the address of base token.
  function baseToken() external view returns (address);

  /// @notice Return the address fractional base token.
  function fToken() external view returns (address);

  /// @notice Return the address leveraged base token.
  function xToken() external view returns (address);

  /// @notice The reference base token price.
  function referenceBaseTokenPrice() external view returns (uint256);

  /// @notice The current base token price.
  function currentBaseTokenPrice() external view returns (uint256);

  /// @notice Return whether the price is valid.
  function isBaseTokenPriceValid() external view returns (bool);

  /// @notice Return the total amount of underlying value of base token deposited.
  function totalBaseToken() external view returns (uint256);

  /// @notice Return the address of strategy contract.
  function strategy() external view returns (address);

  /// @notice Return the total amount of base token managed by strategy.
  function strategyUnderlying() external view returns (uint256);

  /// @notice Return the current collateral ratio of fToken, multiplied by 1e18.
  function collateralRatio() external view returns (uint256);

  /// @notice Return whether the system is under collateral.
  function isUnderCollateral() external view returns (bool);

  /// @notice Compute the amount of base token needed to reach the new collateral ratio.
  /// @param newCollateralRatio The target collateral ratio, multiplied by 1e18.
  /// @return maxBaseIn The amount of underlying value of base token needed.
  /// @return maxFTokenMintable The amount of fToken can be minted.
  function maxMintableFToken(uint256 newCollateralRatio)
    external
    view
    returns (uint256 maxBaseIn, uint256 maxFTokenMintable);

  /// @notice Compute the amount of base token needed to reach the new collateral ratio.
  /// @param newCollateralRatio The target collateral ratio, multiplied by 1e18.
  /// @return maxBaseIn The amount of underlying value of base token needed.
  /// @return maxXTokenMintable The amount of xToken can be minted.
  function maxMintableXToken(uint256 newCollateralRatio)
    external
    view
    returns (uint256 maxBaseIn, uint256 maxXTokenMintable);

  /// @notice Compute the amount of fToken needed to reach the new collateral ratio.
  /// @param newCollateralRatio The target collateral ratio, multiplied by 1e18.
  /// @return maxBaseOut The amount of underlying value of base token redeemed.
  /// @return maxFTokenRedeemable The amount of fToken needed.
  function maxRedeemableFToken(uint256 newCollateralRatio)
    external
    view
    returns (uint256 maxBaseOut, uint256 maxFTokenRedeemable);

  /// @notice Compute the amount of xToken needed to reach the new collateral ratio.
  /// @param newCollateralRatio The target collateral ratio, multiplied by 1e18.
  /// @return maxBaseOut The amount of underlying value of base token redeemed.
  /// @return maxXTokenRedeemable The amount of xToken needed.
  function maxRedeemableXToken(uint256 newCollateralRatio)
    external
    view
    returns (uint256 maxBaseOut, uint256 maxXTokenRedeemable);

  /// @notice Return the exponential moving average of the leverage ratio.
  function leverageRatio() external view returns (uint256);

  /// @notice Convert underlying token amount to wrapped token amount.
  /// @param amount The underlying token amount.
  function getWrapppedValue(uint256 amount) external view returns (uint256);

  /// @notice Convert wrapped token amount to underlying token amount.
  /// @param amount The wrapped token amount.
  function getUnderlyingValue(uint256 amount) external view returns (uint256);

  /// @notice Return the fee ratio distributed to rebalance pool, multiplied by 1e9.
  function getRebalancePoolRatio() external view returns (uint256);

  /// @notice Return the fee ratio distributed to harvester, multiplied by 1e9.
  function getHarvesterRatio() external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Initialize the protocol.
  /// @param baseIn The amount of underlying value of the base token used to initialize.
  function initializeProtocol(uint256 baseIn) external returns (uint256 fTokenOut, uint256 xTokenOut);

  /// @notice Mint fToken with some base token.
  /// @param baseIn The amount of underlying value of base token deposited.
  /// @param recipient The address of receiver.
  /// @return fTokenOut The amount of fToken minted.
  function mintFToken(uint256 baseIn, address recipient) external returns (uint256 fTokenOut);

  /// @notice Mint xToken with some base token.
  /// @param baseIn The amount of underlying value of base token deposited.
  /// @param recipient The address of receiver.
  /// @return xTokenOut The amount of xToken minted.
  function mintXToken(uint256 baseIn, address recipient) external returns (uint256 xTokenOut);

  /// @notice Redeem fToken and xToken to base token.
  /// @param fTokenIn The amount of fToken to redeem.
  /// @param xTokenIn The amount of xToken to redeem.
  /// @param owner The owner of the fToken or xToken.
  /// @param baseOut The amount of underlying value of base token redeemed.
  function redeem(
    uint256 fTokenIn,
    uint256 xTokenIn,
    address owner
  ) external returns (uint256 baseOut);

  /// @notice Settle the nav of base token, fToken and xToken.
  function settle() external;

  /// @notice Transfer some base token to strategy contract.
  /// @param amount The amount of token to transfer.
  function transferToStrategy(uint256 amount) external;

  /// @notice Notify base token profit from strategy contract.
  /// @param amount The amount of base token.
  function notifyStrategyProfit(uint256 amount) external;

  /// @notice Harvest pending rewards to stability pool.
  function harvest() external;
}

// File: contracts/v2/interfaces/IFxUSD.sol

pragma solidity ^0.8.0;

interface IFxUSD {
  /**********
   * Events *
   **********/

  /// @notice Emitted when a new market is added.
  /// @param baseToken The address of base token of the market.
  /// @param mintCap The mint capacity of the market.
  event AddMarket(address indexed baseToken, uint256 mintCap);

  /// @notice Emitted when the mint capacity is updated.
  /// @param baseToken The address of base token of the market.
  /// @param oldCap The value of previous mint capacity.
  /// @param newCap The value of current mint capacity.
  event UpdateMintCap(address indexed baseToken, uint256 oldCap, uint256 newCap);

  /// @notice Emitted when a new rebalance pool is added.
  /// @param baseToken The address of base token of the market.
  /// @param pool The address of the rebalance pool.
  event AddRebalancePool(address indexed baseToken, address indexed pool);

  /// @notice Emitted when a new rebalance pool is removed.
  /// @param baseToken The address of base token of the market.
  /// @param pool The address of the rebalance pool.
  event RemoveRebalancePool(address indexed baseToken, address indexed pool);

  /// @notice Emitted when someone wrap fToken as fxUSD.
  /// @param baseToken The address of base token of the market.
  /// @param owner The address of fToken owner.
  /// @param receiver The address of fxUSD recipient.
  /// @param amount The amount of fxUSD minted.
  event Wrap(address indexed baseToken, address indexed owner, address indexed receiver, uint256 amount);

  /// @notice Emitted when someone unwrap fxUSD as fToken.
  /// @param baseToken The address of base token of the market.
  /// @param owner The address of fxUSD owner.
  /// @param receiver The address of base token recipient.
  /// @param amount The amount of fxUSD burned.
  event Unwrap(address indexed baseToken, address indexed owner, address indexed receiver, uint256 amount);

  /**********
   * Errors *
   **********/

  /// @dev Thrown when someone tries to interact with unsupported market.
  error ErrorUnsupportedMarket();

  /// @dev Thrown when someone tries to interact with unsupported rebalance pool.
  error ErrorUnsupportedRebalancePool();

  /// @dev Thrown when someone tries to interact with market in stability mode.
  error ErrorMarketInStabilityMode();

  /// @dev Thrown when someone tries to interact with market has invalid price.
  error ErrorMarketWithInvalidPrice();

  /// @dev Thrown when someone tries to add a supported market.
  error ErrorMarketAlreadySupported();

  /// @dev Thrown when the total supply of fToken exceed mint capacity.
  error ErrorExceedMintCap();

  /// @dev Thrown when the amount of fToken is not enough for redeem.
  error ErrorInsufficientLiquidity();

  /// @dev Thrown when current is under collateral.
  error ErrorUnderCollateral();

  /// @dev Thrown when the length of two arrays is mismatch.
  error ErrorLengthMismatch();

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the list of supported markets.
  function getMarkets() external view returns (address[] memory);

  /// @notice Return the list of supported rebalance pools.
  function getRebalancePools() external view returns (address[] memory);

  /// @notice Return the nav of fxUSD.
  function nav() external view returns (uint256);

  /// @notice Return whether the system is under collateral.
  function isUnderCollateral() external view returns (bool);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Wrap fToken to fxUSD.
  /// @param baseToken The address of corresponding base token.
  /// @param amount The amount of fToken to wrap.
  /// @param receiver The address of fxUSD recipient.
  function wrap(
    address baseToken,
    uint256 amount,
    address receiver
  ) external;

  /// @notice Unwrap fxUSD to fToken.
  /// @param baseToken The address of corresponding base token.
  /// @param amount The amount of fxUSD to unwrap.
  /// @param receiver The address of fToken recipient.
  function unwrap(
    address baseToken,
    uint256 amount,
    address receiver
  ) external;

  /// @notice Wrap fToken from rebalance pool to fxUSD.
  /// @param pool The address of rebalance pool.
  /// @param amount The amount of fToken to wrap.
  /// @param receiver The address of fxUSD recipient.
  function wrapFrom(
    address pool,
    uint256 amount,
    address receiver
  ) external;

  /// @notice Mint fxUSD with base token.
  /// @param baseToken The address of the base token.
  /// @param amountIn The amount of base token to use.
  /// @param receiver The address of fxUSD recipient.
  /// @param minOut The minimum amount of fxUSD should receive.
  /// @return amountOut The amount of fxUSD received by the receiver.
  function mint(
    address baseToken,
    uint256 amountIn,
    address receiver,
    uint256 minOut
  ) external returns (uint256 amountOut);

  /// @notice Deposit fxUSD to rebalance pool.
  /// @param pool The address of rebalance pool.
  /// @param amount The amount of fxUSD to use.
  /// @param receiver The address of rebalance pool share recipient.
  function earn(
    address pool,
    uint256 amount,
    address receiver
  ) external;

  /// @notice Mint fxUSD with base token and deposit to rebalance pool.
  /// @param pool The address of rebalance pool.
  /// @param amountIn The amount of base token to use.
  /// @param receiver The address of rebalance pool recipient.
  /// @param minOut The minimum amount of rebalance pool shares should receive.
  /// @return amountOut The amount of rebalance pool shares received by the receiver.
  function mintAndEarn(
    address pool,
    uint256 amountIn,
    address receiver,
    uint256 minOut
  ) external returns (uint256 amountOut);

  /// @notice Redeem fxUSD to base token.
  /// @param baseToken The address of the base token.
  /// @param amountIn The amount of fxUSD to redeem.
  /// @param receiver The address of base token recipient.
  /// @param minOut The minimum amount of base token should receive.
  /// @return amountOut The amount of base token received by the receiver.
  /// @return bonusOut The amount of bonus base token received by the receiver.
  function redeem(
    address baseToken,
    uint256 amountIn,
    address receiver,
    uint256 minOut
  ) external returns (uint256 amountOut, uint256 bonusOut);

  /// @notice Redeem fToken from rebalance pool to base token.
  /// @param amountIn The amount of fxUSD to redeem.
  /// @param receiver The address of base token recipient.
  /// @param minOut The minimum amount of base token should receive.
  /// @return amountOut The amount of base token received by the receiver.
  /// @return bonusOut The amount of bonus base token received by the receiver.
  function redeemFrom(
    address pool,
    uint256 amountIn,
    address receiver,
    uint256 minOut
  ) external returns (uint256 amountOut, uint256 bonusOut);

  /// @notice Redeem fxUSD to base token optimally.
  /// @param amountIn The amount of fxUSD to redeem.
  /// @param receiver The address of base token recipient.
  /// @param minOuts The list of minimum amount of base token should receive.
  /// @return baseTokens The list of base token received by the receiver.
  /// @return amountOuts The list of amount of base token received by the receiver.
  /// @return bonusOuts The list of amount of bonus base token received by the receiver.
  function autoRedeem(
    uint256 amountIn,
    address receiver,
    uint256[] memory minOuts
  )
    external
    returns (
      address[] memory baseTokens,
      uint256[] memory amountOuts,
      uint256[] memory bonusOuts
    );
}

// File: contracts/v2/interfaces/IFxBoostableRebalancePool.sol

pragma solidity ^0.8.0;

interface IFxBoostableRebalancePool {
  /**********
   * Events *
   **********/

  /// @notice Emitted when user deposit asset into this contract.
  /// @param owner The address of asset owner.
  /// @param reciever The address of receiver of the asset in this contract.
  /// @param amount The amount of asset deposited.
  event Deposit(address indexed owner, address indexed reciever, uint256 amount);

  /// @notice Emitted when the amount of deposited asset changed due to liquidation or deposit or unlock.
  /// @param owner The address of asset owner.
  /// @param newDeposit The new amount of deposited asset.
  /// @param loss The amount of asset used by liquidation.
  event UserDepositChange(address indexed owner, uint256 newDeposit, uint256 loss);

  /// @notice Emitted when user withdraw asset.
  /// @param owner The address of asset owner.
  /// @param reciever The address of receiver of the asset.
  /// @param amount The amount of token to withdraw.
  event Withdraw(address indexed owner, address indexed reciever, uint256 amount);

  /// @notice Emitted when liquidation happens.
  /// @param liquidated The amount of asset liquidated.
  /// @param baseGained The amount of base token gained.
  event Liquidate(uint256 liquidated, uint256 baseGained);

  /// @notice Emitted when the address of reward wrapper is updated.
  /// @param oldWrapper The address of previous reward wrapper.
  /// @param newWrapper The address of current reward wrapper.
  event UpdateWrapper(address indexed oldWrapper, address indexed newWrapper);

  /// @notice Emitted when the liquidatable collateral ratio is updated.
  /// @param oldRatio The previous liquidatable collateral ratio.
  /// @param newRatio The current liquidatable collateral ratio.
  event UpdateLiquidatableCollateralRatio(uint256 oldRatio, uint256 newRatio);

  /**********
   * Errors *
   **********/

  /// @dev Thrown then the src token mismatched.
  error ErrorWrapperSrcMismatch();

  /// @dev Thrown then the dst token mismatched.
  error ErrorWrapperDstMismatch();

  /// @dev Thrown when the deposited amount is zero.
  error DepositZeroAmount();

  /// @dev Thrown when the withdrawn amount is zero.
  error WithdrawZeroAmount();

  /// @dev Thrown the cannot liquidate.
  error CannotLiquidate();

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the address of treasury contract.
  function treasury() external view returns (address);

  /// @notice Return the address of market contract.
  function market() external view returns (address);

  /// @notice Return the address of base token.
  function baseToken() external view returns (address);

  /// @notice Return the address of underlying token of this contract.
  function asset() external view returns (address);

  /// @notice Return the total amount of asset deposited to this contract.
  function totalSupply() external view returns (uint256);

  /// @notice Return the amount of deposited asset for some specific user.
  /// @param account The address of user to query.
  function balanceOf(address account) external view returns (uint256);

  /// @notice Return the current boost ratio for some specific user.
  /// @param account The address of user to query, multiplied by 1e18.
  function getBoostRatio(address account) external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Deposit some asset to this contract.
  /// @dev Use `amount=uint256(-1)` if you want to deposit all asset held.
  /// @param amount The amount of asset to deposit.
  /// @param receiver The address of recipient for the deposited asset.
  function deposit(uint256 amount, address receiver) external;

  /// @notice Withdraw asset from this contract.
  function withdraw(uint256 amount, address receiver) external;

  /// @notice Liquidate asset for base token.
  /// @param maxAmount The maximum amount of asset to liquidate.
  /// @param minBaseOut The minimum amount of base token should receive.
  /// @return liquidated The amount of asset liquidated.
  /// @return baseOut The amount of base token received.
  function liquidate(uint256 maxAmount, uint256 minBaseOut) external returns (uint256 liquidated, uint256 baseOut);
}

// File: contracts/v2/interfaces/IFxShareableRebalancePool.sol

pragma solidity ^0.8.0;



interface IFxShareableRebalancePool is IFxBoostableRebalancePool {
  /**********
   * Events *
   **********/

  /// @notice Emitted when one user share votes to another user.
  /// @param owner The address of votes owner.
  /// @param staker The address of staker to share votes.
  event ShareVote(address indexed owner, address indexed staker);

  /// @notice Emitted when the owner cancel sharing to some staker.
  /// @param owner The address of votes owner.
  /// @param staker The address of staker to cancel votes share.
  event CancelShareVote(address indexed owner, address indexed staker);

  /// @notice Emitted when staker accept the vote sharing.
  /// @param staker The address of the staker.
  /// @param oldOwner The address of the previous vote sharing owner.
  /// @param newOwner The address of the current vote sharing owner.
  event AcceptSharedVote(address indexed staker, address indexed oldOwner, address indexed newOwner);

  /**********
   * Errors *
   **********/

  /// @dev Thrown when caller shares votes to self.
  error ErrorSelfSharingIsNotAllowed();

  /// @dev Thrown when a staker with shared votes try to share its votes to others.
  error ErrorCascadedSharingIsNotAllowed();

  /// @dev Thrown when staker try to accept non-allowed vote sharing.
  error ErrorVoteShareNotAllowed();

  /// @dev Thrown when staker try to reject a non-existed vote sharing.
  error ErrorNoAcceptedSharedVote();

  /// @dev Thrown when the staker has ability to share ve balance.
  error ErrorVoteOwnerCannotStake();

  /// @dev Thrown when staker try to accept twice.
  error ErrorRepeatAcceptSharedVote();

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the owner of votes of some staker.
  /// @param account The address of user to query.
  function getStakerVoteOwner(address account) external view returns (address);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Withdraw asset from this contract on behalf of someone
  function withdrawFrom(
    address owner,
    uint256 amount,
    address receiver
  ) external;

  /// @notice Owner changes the vote sharing state for some user.
  /// @param staker The address of user to change.
  function toggleVoteSharing(address staker) external;

  /// @notice Staker accepts the vote sharing.
  /// @param newOwner The address of the owner of the votes.
  function acceptSharedVote(address newOwner) external;

  /// @notice Staker reject the current vote sharing.
  function rejectSharedVote() external;
}

// File: contracts/interfaces/IFxUSDRegeneracy.sol

pragma solidity ^0.8.0;

interface IFxUSDRegeneracy {
  /**********
   * Events *
   **********/
  
  /// @notice Emitted when rebalance/liquidate with stable token.
  /// @param amountStable The amount of stable token used.
  /// @param amountFxUSD The corresponding amount of fxUSD.
  event RebalanceWithStable(uint256 amountStable, uint256 amountFxUSD);
  
  /// @notice Emitted when buyback fxUSD with stable reserve.
  /// @param amountStable the amount of stable token used.
  /// @param amountFxUSD The amount of fxUSD bought.
  /// @param bonusFxUSD The amount of fxUSD as bonus for caller.
  event Buyback(uint256 amountStable, uint256 amountFxUSD, uint256 bonusFxUSD);

  /*************************
   * Public View Functions *
   *************************/

  /// @notice The address of `PoolManager` contract.
  function poolManager() external view returns (address);

  /// @notice The address of stable token.
  function stableToken() external view returns (address);

  /// @notice The address of `PegKeeper` contract.
  function pegKeeper() external view returns (address);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Mint fxUSD token someone.
  function mint(address to, uint256 amount) external;

  /// @notice Burn fxUSD from someone.
  function burn(address from, uint256 amount) external;

  /// @notice Hook for rebalance/liquidate with stable token.
  /// @param amountStableToken The amount of stable token.
  /// @param amountFxUSD The amount of fxUSD.
  function onRebalanceWithStable(uint256 amountStableToken, uint256 amountFxUSD) external;

  /// @notice Buyback fxUSD with stable token.
  /// @param amountIn the amount of stable token to use.
  /// @param receiver The address of bonus receiver.
  /// @param data The hook data to PegKeeper.
  /// @return amountOut The amount of fxUSD swapped.
  /// @return bonusOut The amount of bonus fxUSD.
  function buyback(
    uint256 amountIn,
    address receiver,
    bytes calldata data
  ) external returns (uint256 amountOut, uint256 bonusOut);
}

// File: contracts/interfaces/IPegKeeper.sol

pragma solidity ^0.8.0;

interface IPegKeeper {
  /**********
   * Events *
   **********/

  /// @notice Emitted when the converter contract is updated.
  /// @param oldConverter The address of previous converter contract.
  /// @param newConverter The address of current converter contract.
  event UpdateConverter(address indexed oldConverter, address indexed newConverter);

  /// @notice Emitted when the curve pool contract is updated.
  /// @param oldPool The address of previous curve pool contract.
  /// @param newPool The address of current curve pool contract.
  event UpdateCurvePool(address indexed oldPool, address indexed newPool);

  /// @notice Emitted when the price threshold is updated.
  /// @param oldThreshold The value of previous price threshold
  /// @param newThreshold The value of current price threshold
  event UpdatePriceThreshold(uint256 oldThreshold, uint256 newThreshold);

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return whether borrow for fxUSD is allowed.
  function isBorrowAllowed() external view returns (bool);

  /// @notice Return whether funding costs is enabled.
  function isFundingEnabled() external view returns (bool);
  
  /// @notice Return the price of fxUSD, multiplied by 1e18
  function getFxUSDPrice() external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Buyback fxUSD with stable reserve in FxUSDSave.
  /// @param amountIn the amount of stable token to use.
  /// @param data The hook data to `onSwap`.
  /// @return amountOut The amount of fxUSD swapped.
  /// @return bonusOut The amount of bonus fxUSD.
  function buyback(uint256 amountIn, bytes calldata data) external returns (uint256 amountOut, uint256 bonusOut);

  /// @notice Stabilize the fxUSD price in curve pool.
  /// @param srcToken The address of source token (fxUSD or stable token).
  /// @param amountIn the amount of source token to use.
  /// @param data The hook data to `onSwap`.
  /// @return amountOut The amount of target token swapped.
  /// @return bonusOut The amount of bonus token.
  function stabilize(
    address srcToken,
    uint256 amountIn,
    bytes calldata data
  ) external returns (uint256 amountOut, uint256 bonusOut);

  /// @notice Swap callback from `buyback` and `stabilize`.
  /// @param srcToken The address of source token.
  /// @param srcToken The address of target token.
  /// @param amountIn the amount of source token to use.
  /// @param data The callback data.
  /// @return amountOut The amount of target token swapped.
  function onSwap(
    address srcToken,
    address targetToken,
    uint256 amountIn,
    bytes calldata data
  ) external returns (uint256 amountOut);
}

// File: contracts/libraries/Math.sol

pragma solidity ^0.8.26;

library Math {
  enum Rounding {
    Up,
    Down
  }

  /// @dev Internal return the value of min(a, b).
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  /// @dev Internal return the value of max(a, b).
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? a : b;
  }

  /// @dev Internal return the value of a * b / c, with rounding.
  function mulDiv(uint256 a, uint256 b, uint256 c, Rounding rounding) internal pure returns (uint256) {
    return rounding == Rounding.Down ? mulDivDown(a, b, c) : mulDivUp(a, b, c);
  }

  /// @dev Internal return the value of ceil(a * b / c).
  function mulDivUp(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
    return (a * b + c - 1) / c;
  }

  /// @dev Internal return the value of floor(a * b / c).
  function mulDivDown(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
    return (a * b) / c;
  }
}

// File: contracts/core/FxUSDRegeneracy.sol

pragma solidity ^0.8.26;

















/// @dev It has the same storage layout with `https://github.com/AladdinDAO/aladdin-v3-contracts/contracts/f(x)/v2/FxUSD.sol`.
contract FxUSDRegeneracy is AccessControlUpgradeable, ERC20PermitUpgradeable, IFxUSD, IFxUSDRegeneracy {
  using SafeERC20Upgradeable for IERC20Upgradeable;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

  /**********
   * Errors *
   **********/

  error ErrorCallerNotPoolManager();

  error ErrorCallerNotPegKeeper();

  error ErrorExceedStableReserve();

  error ErrorInsufficientOutput();

  error ErrorInsufficientBuyBack();

  /*************
   * Constants *
   *************/

  /// @notice The role for migrator.
  bytes32 public constant MIGRATOR_ROLE = keccak256("MIGRATOR_ROLE");

  /// @dev The precision used to compute nav.
  uint256 private constant PRECISION = 1e18;

  /***********
   * Structs *
   ***********/

  /// @param fToken The address of Fractional Token.
  /// @param treasury The address of treasury contract.
  /// @param market The address of market contract.
  /// @param mintCap The maximum amount of fToken can be minted.
  /// @param managed The amount of fToken managed in this contract.
  struct FxMarketStruct {
    address fToken;
    address treasury;
    address market;
    uint256 mintCap;
    uint256 managed;
  }

  /// @dev The struct for stable token reserve.
  /// @param owned The number of stable coins owned in this contract.
  /// @param managed The amount of fxUSD managed under this stable coin.
  /// @param enabled Whether this stable coin is enabled, currently always true
  /// @param decimals The decimal for the stable coin.
  /// @param reserved Reserved slots for future usage.
  struct StableReserveStruct {
    uint96 owned;
    uint96 managed;
    uint8 decimals;
  }

  /***********************
   * Immutable Variables *
   ***********************/

  /// @inheritdoc IFxUSDRegeneracy
  address public immutable poolManager;

  /// @inheritdoc IFxUSDRegeneracy
  address public immutable stableToken;

  /// @inheritdoc IFxUSDRegeneracy
  address public immutable pegKeeper;

  /*********************
   * Storage Variables *
   *********************/

  /// @notice Mapping from base token address to metadata.
  mapping(address => FxMarketStruct) public markets;

  /// @dev The list of supported base tokens.
  EnumerableSetUpgradeable.AddressSet private supportedTokens;

  /// @dev The list of supported rebalance pools.
  EnumerableSetUpgradeable.AddressSet private supportedPools;

  /// @notice The total supply for legacy 2.0 pools.
  uint256 public legacyTotalSupply;

  /// @notice The reserve struct for stable token.
  StableReserveStruct public stableReserve;

  /*************
   * Modifiers *
   *************/

  modifier onlySupportedMarket(address _baseToken) {
    _checkBaseToken(_baseToken);
    _;
  }

  modifier onlySupportedPool(address _pool) {
    if (!supportedPools.contains(_pool)) revert ErrorUnsupportedRebalancePool();
    _;
  }

  modifier onlyMintableMarket(address _baseToken, bool isMint) {
    _checkMarketMintable(_baseToken, isMint);
    _;
  }

  modifier onlyPoolManager() {
    if (_msgSender() != poolManager) revert ErrorCallerNotPoolManager();
    _;
  }

  modifier onlyPegKeeper() {
    if (_msgSender() != pegKeeper) revert ErrorCallerNotPegKeeper();
    _;
  }

  /***************
   * Constructor *
   ***************/

  constructor(address _poolManager, address _stableToken, address _pegKeeper) {
    poolManager = _poolManager;
    stableToken = _stableToken;
    pegKeeper = _pegKeeper;
  }

  function initialize(string memory _name, string memory _symbol) external initializer {
    __Context_init();
    __ERC165_init();
    __AccessControl_init();
    __ERC20_init(_name, _symbol);
    __ERC20Permit_init(_name);

    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function initializeV2() external reinitializer(2) {
    stableReserve.decimals = FxUSDRegeneracy(stableToken).decimals();
    legacyTotalSupply = totalSupply();
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IFxUSD
  function getMarkets() external view override returns (address[] memory _tokens) {
    uint256 _numMarkets = supportedTokens.length();
    _tokens = new address[](_numMarkets);
    for (uint256 i = 0; i < _numMarkets; ++i) {
      _tokens[i] = supportedTokens.at(i);
    }
  }

  /// @inheritdoc IFxUSD
  function getRebalancePools() external view override returns (address[] memory _pools) {
    uint256 _numPools = supportedPools.length();
    _pools = new address[](_numPools);
    for (uint256 i = 0; i < _numPools; ++i) {
      _pools[i] = supportedPools.at(i);
    }
  }

  /// @inheritdoc IFxUSD
  function nav() external view override returns (uint256 _nav) {
    uint256 _numMarkets = supportedTokens.length();
    uint256 _supply = legacyTotalSupply;
    if (_supply == 0) return PRECISION;

    for (uint256 i = 0; i < _numMarkets; i++) {
      address _baseToken = supportedTokens.at(i);
      address _fToken = markets[_baseToken].fToken;
      uint256 _fnav = IFxFractionalTokenV2(_fToken).nav();
      _nav += _fnav * markets[_baseToken].managed;
    }
    _nav /= _supply;
  }

  /// @inheritdoc IFxUSD
  function isUnderCollateral() public view override returns (bool) {
    uint256 _numMarkets = supportedTokens.length();
    for (uint256 i = 0; i < _numMarkets; i++) {
      address _baseToken = supportedTokens.at(i);
      address _treasury = markets[_baseToken].treasury;
      if (IFxTreasuryV2(_treasury).isUnderCollateral()) return true;
    }
    return false;
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IFxUSD
  function wrap(
    address _baseToken,
    uint256 _amount,
    address _receiver
  ) external override onlySupportedMarket(_baseToken) onlyMintableMarket(_baseToken, false) {
    if (isUnderCollateral()) revert ErrorUnderCollateral();

    address _fToken = markets[_baseToken].fToken;
    IERC20Upgradeable(_fToken).safeTransferFrom(_msgSender(), address(this), _amount);

    _mintShares(_baseToken, _receiver, _amount);

    emit Wrap(_baseToken, _msgSender(), _receiver, _amount);
  }

  /// @inheritdoc IFxUSD
  function unwrap(
    address _baseToken,
    uint256 _amount,
    address _receiver
  ) external onlyRole(MIGRATOR_ROLE) onlySupportedMarket(_baseToken) {
    if (isUnderCollateral()) revert ErrorUnderCollateral();

    _burnShares(_baseToken, _msgSender(), _amount);

    address _fToken = markets[_baseToken].fToken;
    IERC20Upgradeable(_fToken).safeTransfer(_receiver, _amount);

    emit Unwrap(_baseToken, _msgSender(), _receiver, _amount);
  }

  /// @inheritdoc IFxUSD
  function wrapFrom(address _pool, uint256 _amount, address _receiver) external override onlySupportedPool(_pool) {
    if (isUnderCollateral()) revert ErrorUnderCollateral();

    address _baseToken = IFxShareableRebalancePool(_pool).baseToken();
    _checkBaseToken(_baseToken);
    _checkMarketMintable(_baseToken, false);

    IFxShareableRebalancePool(_pool).withdrawFrom(_msgSender(), _amount, address(this));
    _mintShares(_baseToken, _receiver, _amount);

    emit Wrap(_baseToken, _msgSender(), _receiver, _amount);
  }

  /// @inheritdoc IFxUSD
  function mint(address, uint256, address, uint256) external virtual override returns (uint256) {
    revert("mint paused");
  }

  /// @inheritdoc IFxUSD
  function earn(address, uint256, address) external virtual override {
    revert("earn paused");
  }

  /// @inheritdoc IFxUSD
  function mintAndEarn(address, uint256, address, uint256) external virtual override returns (uint256) {
    revert("mint and earn paused");
  }

  /// @inheritdoc IFxUSD
  function redeem(
    address _baseToken,
    uint256 _amountIn,
    address _receiver,
    uint256 _minOut
  ) external override onlySupportedMarket(_baseToken) returns (uint256 _amountOut, uint256 _bonusOut) {
    if (isUnderCollateral()) revert ErrorUnderCollateral();

    address _market = markets[_baseToken].market;
    address _fToken = markets[_baseToken].fToken;

    uint256 _balance = IERC20Upgradeable(_fToken).balanceOf(address(this));
    (_amountOut, _bonusOut) = IFxMarketV2(_market).redeemFToken(_amountIn, _receiver, _minOut);
    // the real amount of fToken redeemed
    _amountIn = _balance - IERC20Upgradeable(_fToken).balanceOf(address(this));

    _burnShares(_baseToken, _msgSender(), _amountIn);
    emit Unwrap(_baseToken, _msgSender(), _receiver, _amountIn);
  }

  /// @inheritdoc IFxUSD
  function redeemFrom(
    address _pool,
    uint256 _amountIn,
    address _receiver,
    uint256 _minOut
  ) external override onlySupportedPool(_pool) returns (uint256 _amountOut, uint256 _bonusOut) {
    address _baseToken = IFxShareableRebalancePool(_pool).baseToken();
    address _market = markets[_baseToken].market;
    address _fToken = markets[_baseToken].fToken;

    // calculate the actual amount of fToken withdrawn from rebalance pool.
    _amountOut = IERC20Upgradeable(_fToken).balanceOf(address(this));
    IFxShareableRebalancePool(_pool).withdrawFrom(_msgSender(), _amountIn, address(this));
    _amountOut = IERC20Upgradeable(_fToken).balanceOf(address(this)) - _amountOut;

    // redeem fToken as base token
    // assume all fToken will be redeem for simplicity
    (_amountOut, _bonusOut) = IFxMarketV2(_market).redeemFToken(_amountOut, _receiver, _minOut);
  }

  /// @inheritdoc IFxUSD
  function autoRedeem(
    uint256 _amountIn,
    address _receiver,
    uint256[] memory _minOuts
  )
    external
    override
    returns (address[] memory _baseTokens, uint256[] memory _amountOuts, uint256[] memory _bonusOuts)
  {
    uint256 _numMarkets = supportedTokens.length();
    if (_minOuts.length != _numMarkets) revert ErrorLengthMismatch();

    _baseTokens = new address[](_numMarkets);
    _amountOuts = new uint256[](_numMarkets);
    _bonusOuts = new uint256[](_numMarkets);
    uint256[] memory _supplies = new uint256[](_numMarkets);

    bool _isUnderCollateral = false;
    for (uint256 i = 0; i < _numMarkets; i++) {
      _baseTokens[i] = supportedTokens.at(i);
      _supplies[i] = markets[_baseTokens[i]].managed;
      address _treasury = markets[_baseTokens[i]].treasury;
      if (IFxTreasuryV2(_treasury).isUnderCollateral()) _isUnderCollateral = true;
    }

    uint256 _supply = legacyTotalSupply;
    if (_amountIn > _supply) revert("redeem exceed supply");
    unchecked {
      legacyTotalSupply = _supply - _amountIn;
    }
    _burn(_msgSender(), _amountIn);

    if (_isUnderCollateral) {
      // redeem proportionally
      for (uint256 i = 0; i < _numMarkets; i++) {
        _amountOuts[i] = (_supplies[i] * _amountIn) / _supply;
      }
    } else {
      // redeem by sorted fToken amounts
      while (_amountIn > 0) {
        unchecked {
          uint256 maxSupply = _supplies[0];
          uint256 maxIndex = 0;
          for (uint256 i = 1; i < _numMarkets; i++) {
            if (_supplies[i] > maxSupply) {
              maxSupply = _supplies[i];
              maxIndex = i;
            }
          }
          if (_amountIn > maxSupply) _amountOuts[maxIndex] = maxSupply;
          else _amountOuts[maxIndex] = _amountIn;
          _supplies[maxIndex] -= _amountOuts[maxIndex];
          _amountIn -= _amountOuts[maxIndex];
        }
      }
    }

    for (uint256 i = 0; i < _numMarkets; i++) {
      if (_amountOuts[i] == 0) continue;
      emit Unwrap(_baseTokens[i], _msgSender(), _receiver, _amountOuts[i]);

      markets[_baseTokens[i]].managed -= _amountOuts[i];
      address _market = markets[_baseTokens[i]].market;
      (_amountOuts[i], _bonusOuts[i]) = IFxMarketV2(_market).redeemFToken(_amountOuts[i], _receiver, _minOuts[i]);
    }
  }

  /// @inheritdoc IFxUSDRegeneracy
  function mint(address to, uint256 amount) external onlyPoolManager {
    _mint(to, amount);
  }

  /// @inheritdoc IFxUSDRegeneracy
  function burn(address from, uint256 amount) external onlyPoolManager {
    _burn(from, amount);
  }

  /// @inheritdoc IFxUSDRegeneracy
  function onRebalanceWithStable(uint256 amountStableToken, uint256 amountFxUSD) external onlyPoolManager {
    stableReserve.owned += uint96(amountStableToken);
    stableReserve.managed += uint96(amountFxUSD);

    emit RebalanceWithStable(amountStableToken, amountFxUSD);
  }

  /// @inheritdoc IFxUSDRegeneracy
  function buyback(
    uint256 amountIn,
    address receiver,
    bytes calldata data
  ) external onlyPegKeeper returns (uint256 amountOut, uint256 bonusOut) {
    StableReserveStruct memory cachedStableReserve = stableReserve;
    if (amountIn > cachedStableReserve.owned) revert ErrorExceedStableReserve();

    // rounding up
    uint256 expectedFxUSD = Math.mulDivUp(amountIn, cachedStableReserve.managed, cachedStableReserve.owned);

    // convert USDC to fxUSD
    IERC20Upgradeable(stableToken).safeTransfer(pegKeeper, amountIn);
    uint256 actualOut = balanceOf(address(this));
    amountOut = IPegKeeper(pegKeeper).onSwap(stableToken, address(this), amountIn, data);
    actualOut = balanceOf(address(this)) - actualOut;

    // check actual fxUSD swapped in case peg keeper is hacked.
    if (amountOut > actualOut) revert ErrorInsufficientOutput();

    // check fxUSD swapped can cover debts
    if (amountOut < expectedFxUSD) revert ErrorInsufficientBuyBack();
    bonusOut = amountOut - expectedFxUSD;

    _burn(address(this), expectedFxUSD);
    unchecked {
      cachedStableReserve.owned -= uint96(amountIn);
      if (cachedStableReserve.managed > expectedFxUSD) {
        cachedStableReserve.managed -= uint96(expectedFxUSD);
      } else {
        cachedStableReserve.managed = 0;
      }
      stableReserve = cachedStableReserve;
    }

    if (bonusOut > 0) {
      _transfer(address(this), receiver, bonusOut);
    }

    emit Buyback(amountIn, amountOut, bonusOut);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to check base token.
  /// @param _baseToken The address of the base token.
  function _checkBaseToken(address _baseToken) private view {
    if (!supportedTokens.contains(_baseToken)) revert ErrorUnsupportedMarket();
  }

  /// @dev Internal function to check market.
  /// @param _baseToken The address of the base token.
  /// @param _checkCollateralRatio Whether to check collateral ratio.
  function _checkMarketMintable(address _baseToken, bool _checkCollateralRatio) private view {
    address _treasury = markets[_baseToken].treasury;
    if (_checkCollateralRatio) {
      uint256 _collateralRatio = IFxTreasuryV2(_treasury).collateralRatio();
      uint256 _stabilityRatio = IFxMarketV2(markets[_baseToken].market).stabilityRatio();
      // not allow to mint when collateral ratio <= stability ratio
      if (_collateralRatio <= _stabilityRatio) revert ErrorMarketInStabilityMode();
    }
    // not allow to mint when price is invalid
    if (!IFxTreasuryV2(_treasury).isBaseTokenPriceValid()) revert ErrorMarketWithInvalidPrice();
  }

  /// @dev Internal function to mint fxUSD.
  /// @param _baseToken The address of the base token.
  /// @param _receiver The address of fxUSD recipient.
  /// @param _amount The amount of fxUSD to mint.
  function _mintShares(address _baseToken, address _receiver, uint256 _amount) private {
    unchecked {
      markets[_baseToken].managed += _amount;
      legacyTotalSupply += _amount;
    }

    _mint(_receiver, _amount);
  }

  /// @dev Internal function to burn fxUSD.
  /// @param _baseToken The address of the base token.
  /// @param _owner The address of fxUSD owner.
  /// @param _amount The amount of fxUSD to burn.
  function _burnShares(address _baseToken, address _owner, uint256 _amount) private {
    uint256 _managed = markets[_baseToken].managed;
    if (_amount > _managed) revert ErrorInsufficientLiquidity();
    unchecked {
      markets[_baseToken].managed -= _amount;
      legacyTotalSupply -= _amount;
    }

    _burn(_owner, _amount);
  }
}

// File: @openzeppelin/contracts-upgradeable-v4/security/ReentrancyGuardUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;




/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165Upgradeable is Initializable, IERC165 {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;






/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControl, ERC165Upgradeable {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;


    /// @custom:storage-location erc7201:openzeppelin.storage.AccessControl
    struct AccessControlStorage {
        mapping(bytes32 role => RoleData) _roles;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessControl")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AccessControlStorageLocation = 0x02dd7bc7dec4dceedda775e58dd541e08a116c6c53815c0bd028192f7b626800;

    function _getAccessControlStorage() private pure returns (AccessControlStorage storage $) {
        assembly {
            $.slot := AccessControlStorageLocation
        }
    }

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        return $._roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        return $._roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        AccessControlStorage storage $ = _getAccessControlStorage();
        bytes32 previousAdminRole = getRoleAdmin(role);
        $._roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        if (!hasRole(role, account)) {
            $._roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        if (hasRole(role, account)) {
            $._roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;







/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20, IERC20Metadata, IERC20Errors {
    /// @custom:storage-location erc7201:openzeppelin.storage.ERC20
    struct ERC20Storage {
        mapping(address account => uint256) _balances;

        mapping(address account => mapping(address spender => uint256)) _allowances;

        uint256 _totalSupply;

        string _name;
        string _symbol;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC20")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20StorageLocation = 0x52c63247e1f47db19d5ce0460030c497f067ca4cebf71ba98eeadabe20bace00;

    function _getERC20Storage() private pure returns (ERC20Storage storage $) {
        assembly {
            $.slot := ERC20StorageLocation
        }
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC20Storage storage $ = _getERC20Storage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        ERC20Storage storage $ = _getERC20Storage();
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            $._totalSupply += value;
        } else {
            uint256 fromBalance = $._balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                $._balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                $._totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                $._balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        ERC20Storage storage $ = _getERC20Storage();
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        $._allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// File: @openzeppelin/contracts/utils/math/SignedMath.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;




/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// File: @openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;



/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}

// File: @openzeppelin/contracts/interfaces/IERC5267.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}

// File: @openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;





/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 */
abstract contract EIP712Upgradeable is Initializable, IERC5267 {
    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// @custom:storage-location erc7201:openzeppelin.storage.EIP712
    struct EIP712Storage {
        /// @custom:oz-renamed-from _HASHED_NAME
        bytes32 _hashedName;
        /// @custom:oz-renamed-from _HASHED_VERSION
        bytes32 _hashedVersion;

        string _name;
        string _version;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.EIP712")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant EIP712StorageLocation = 0xa16a46d94261c7517cc8ff89f61c0ce93598e3c849801011dee649a6a557d100;

    function _getEIP712Storage() private pure returns (EIP712Storage storage $) {
        assembly {
            $.slot := EIP712StorageLocation
        }
    }

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        EIP712Storage storage $ = _getEIP712Storage();
        $._name = name;
        $._version = version;

        // Reset prior values in storage if upgrading
        $._hashedName = 0;
        $._hashedVersion = 0;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator();
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash(), block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        EIP712Storage storage $ = _getEIP712Storage();
        // If the hashed name and version in storage are non-zero, the contract hasn't been properly initialized
        // and the EIP712 domain is not reliable, as it will be missing name and version.
        require($._hashedName == 0 && $._hashedVersion == 0, "EIP712: Uninitialized");

        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712Name() internal view virtual returns (string memory) {
        EIP712Storage storage $ = _getEIP712Storage();
        return $._name;
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712Version() internal view virtual returns (string memory) {
        EIP712Storage storage $ = _getEIP712Storage();
        return $._version;
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: In previous versions this function was virtual. In this version you should override `_EIP712Name` instead.
     */
    function _EIP712NameHash() internal view returns (bytes32) {
        EIP712Storage storage $ = _getEIP712Storage();
        string memory name = _EIP712Name();
        if (bytes(name).length > 0) {
            return keccak256(bytes(name));
        } else {
            // If the name is empty, the contract may have been upgraded without initializing the new storage.
            // We return the name hash in storage if non-zero, otherwise we assume the name is empty by design.
            bytes32 hashedName = $._hashedName;
            if (hashedName != 0) {
                return hashedName;
            } else {
                return keccak256("");
            }
        }
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: In previous versions this function was virtual. In this version you should override `_EIP712Version` instead.
     */
    function _EIP712VersionHash() internal view returns (bytes32) {
        EIP712Storage storage $ = _getEIP712Storage();
        string memory version = _EIP712Version();
        if (bytes(version).length > 0) {
            return keccak256(bytes(version));
        } else {
            // If the version is empty, the contract may have been upgraded without initializing the new storage.
            // We return the version hash in storage if non-zero, otherwise we assume the version is empty by design.
            bytes32 hashedVersion = $._hashedVersion;
            if (hashedVersion != 0) {
                return hashedVersion;
            } else {
                return keccak256("");
            }
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/NoncesUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Nonces.sol)
pragma solidity ^0.8.20;


/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract NoncesUpgradeable is Initializable {
    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    /// @custom:storage-location erc7201:openzeppelin.storage.Nonces
    struct NoncesStorage {
        mapping(address account => uint256) _nonces;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Nonces")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant NoncesStorageLocation = 0x5ab42ced628888259c08ac98db1eb0cf702fc1501344311d8b100cd1bfe4bb00;

    function _getNoncesStorage() private pure returns (NoncesStorage storage $) {
        assembly {
            $.slot := NoncesStorageLocation
        }
    }

    function __Nonces_init() internal onlyInitializing {
    }

    function __Nonces_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        NoncesStorage storage $ = _getNoncesStorage();
        return $._nonces[owner];
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        NoncesStorage storage $ = _getNoncesStorage();
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return $._nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.20;








/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20Permit, EIP712Upgradeable, NoncesUpgradeable {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    function __ERC20Permit_init(string memory name) internal onlyInitializing {
        __EIP712_init_unchained(name, "1");
    }

    function __ERC20Permit_init_unchained(string memory) internal onlyInitializing {}

    /**
     * @inheritdoc IERC20Permit
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    function nonces(address owner) public view virtual override(IERC20Permit, NoncesUpgradeable) returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.20;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.20;











/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721, IERC721Metadata, IERC721Errors {
    using Strings for uint256;

    /// @custom:storage-location erc7201:openzeppelin.storage.ERC721
    struct ERC721Storage {
        // Token name
        string _name;

        // Token symbol
        string _symbol;

        mapping(uint256 tokenId => address) _owners;

        mapping(address owner => uint256) _balances;

        mapping(uint256 tokenId => address) _tokenApprovals;

        mapping(address owner => mapping(address operator => bool)) _operatorApprovals;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721StorageLocation = 0x80bb2b638cc20bc4d0a60d66940f3ab4a00c1d7b313497ca82fb0b4ab0079300;

    function _getERC721Storage() private pure returns (ERC721Storage storage $) {
        assembly {
            $.slot := ERC721StorageLocation
        }
    }

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC721Storage storage $ = _getERC721Storage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        ERC721Storage storage $ = _getERC721Storage();
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return $._balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, _msgSender());
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if `spender` does not have approval from the provided `owner` for the given token or for all its assets
     * the `spender` for the specific `tokenId`.
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(address account, uint128 value) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        unchecked {
            $._balances[account] += value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                $._balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                $._balances[to] += 1;
            }
        }

        $._owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }

    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking that contract recipients
     * are aware of the ERC721 standard to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by `from`.
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
     * emitted in the context of transfers.
     */
    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        // Avoid reading the owner unless necessary
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        $._tokenApprovals[tokenId] = to;
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Requirements:
     * - operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        $._operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    /// @custom:storage-location erc7201:openzeppelin.storage.ReentrancyGuard
    struct ReentrancyGuardStorage {
        uint256 _status;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ReentrancyGuardStorageLocation = 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    function _getReentrancyGuardStorage() private pure returns (ReentrancyGuardStorage storage $) {
        assembly {
            $.slot := ReentrancyGuardStorageLocation
        }
    }

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if ($._status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        $._status = ENTERED;
    }

    function _nonReentrantAfter() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        return $._status == ENTERED;
    }
}

// File: @openzeppelin/contracts-v4/utils/Context.sol

// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts-v4/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts-v4/interfaces/IERC1967.sol

// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC1967.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 *
 * _Available since v4.8.3._
 */
interface IERC1967 {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
}

// File: @openzeppelin/contracts-v4/interfaces/draft-IERC1822.sol

// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// File: @openzeppelin/contracts-v4/proxy/Proxy.sol

// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// File: @openzeppelin/contracts-v4/proxy/beacon/IBeacon.sol

// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// File: @openzeppelin/contracts-v4/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts-v4/utils/StorageSlot.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}

// File: @openzeppelin/contracts-v4/proxy/ERC1967/ERC1967Upgrade.sol

// OpenZeppelin Contracts (last updated v4.9.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;







/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 */
abstract contract ERC1967Upgrade is IERC1967 {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// File: @openzeppelin/contracts-v4/proxy/ERC1967/ERC1967Proxy.sol

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;




/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

// File: @openzeppelin/contracts-v4/proxy/transparent/TransparentUpgradeableProxy.sol

// OpenZeppelin Contracts (last updated v4.9.0) (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for {TransparentUpgradeableProxy}. In order to implement transparency, {TransparentUpgradeableProxy}
 * does not implement this interface directly, and some of its functions are implemented by an internal dispatch
 * mechanism. The compiler is unaware that these functions are implemented by {TransparentUpgradeableProxy} and will not
 * include them in the ABI so this interface must be used to interact with it.
 */
interface ITransparentUpgradeableProxy is IERC1967 {
    function admin() external view returns (address);

    function implementation() external view returns (address);

    function changeAdmin(address) external;

    function upgradeTo(address) external;

    function upgradeToAndCall(address, bytes memory) external payable;
}

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 *
 * NOTE: The real interface of this proxy is that defined in `ITransparentUpgradeableProxy`. This contract does not
 * inherit from that interface, and instead the admin functions are implicitly implemented using a custom dispatch
 * mechanism in `_fallback`. Consequently, the compiler will not produce an ABI for this contract. This is necessary to
 * fully implement transparency without decoding reverts caused by selector clashes between the proxy and the
 * implementation.
 *
 * WARNING: It is not recommended to extend this contract to add additional external functions. If you do so, the compiler
 * will not check that there are no selector conflicts, due to the note above. A selector clash between any new function
 * and the functions declared in {ITransparentUpgradeableProxy} will be resolved in favor of the new one. This could
 * render the admin operations inaccessible, which could prevent upgradeability. Transparency may also be compromised.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(address _logic, address admin_, bytes memory _data) payable ERC1967Proxy(_logic, _data) {
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     *
     * CAUTION: This modifier is deprecated, as it could cause issues if the modified function has arguments, and the
     * implementation provides a function with the same selector.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev If caller is the admin process the call internally, otherwise transparently fallback to the proxy behavior
     */
    function _fallback() internal virtual override {
        if (msg.sender == _getAdmin()) {
            bytes memory ret;
            bytes4 selector = msg.sig;
            if (selector == ITransparentUpgradeableProxy.upgradeTo.selector) {
                ret = _dispatchUpgradeTo();
            } else if (selector == ITransparentUpgradeableProxy.upgradeToAndCall.selector) {
                ret = _dispatchUpgradeToAndCall();
            } else if (selector == ITransparentUpgradeableProxy.changeAdmin.selector) {
                ret = _dispatchChangeAdmin();
            } else if (selector == ITransparentUpgradeableProxy.admin.selector) {
                ret = _dispatchAdmin();
            } else if (selector == ITransparentUpgradeableProxy.implementation.selector) {
                ret = _dispatchImplementation();
            } else {
                revert("TransparentUpgradeableProxy: admin cannot fallback to proxy target");
            }
            assembly {
                return(add(ret, 0x20), mload(ret))
            }
        } else {
            super._fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function _dispatchAdmin() private returns (bytes memory) {
        _requireZeroValue();

        address admin = _getAdmin();
        return abi.encode(admin);
    }

    /**
     * @dev Returns the current implementation.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function _dispatchImplementation() private returns (bytes memory) {
        _requireZeroValue();

        address implementation = _implementation();
        return abi.encode(implementation);
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _dispatchChangeAdmin() private returns (bytes memory) {
        _requireZeroValue();

        address newAdmin = abi.decode(msg.data[4:], (address));
        _changeAdmin(newAdmin);

        return "";
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     */
    function _dispatchUpgradeTo() private returns (bytes memory) {
        _requireZeroValue();

        address newImplementation = abi.decode(msg.data[4:], (address));
        _upgradeToAndCall(newImplementation, bytes(""), false);

        return "";
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     */
    function _dispatchUpgradeToAndCall() private returns (bytes memory) {
        (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));
        _upgradeToAndCall(newImplementation, data, true);

        return "";
    }

    /**
     * @dev Returns the current admin.
     *
     * CAUTION: This function is deprecated. Use {ERC1967Upgrade-_getAdmin} instead.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev To keep this contract fully transparent, all `ifAdmin` functions must be payable. This helper is here to
     * emulate some proxy functions being non-payable while still allowing value to pass through.
     */
    function _requireZeroValue() private {
        require(msg.value == 0);
    }
}

// File: @openzeppelin/contracts-v4/proxy/transparent/ProxyAdmin.sol

// OpenZeppelin Contracts (last updated v4.8.3) (proxy/transparent/ProxyAdmin.sol)

pragma solidity ^0.8.0;




/**
 * @dev This is an auxiliary contract meant to be assigned as the admin of a {TransparentUpgradeableProxy}. For an
 * explanation of why you would want to use this see the documentation for {TransparentUpgradeableProxy}.
 */
contract ProxyAdmin is Ownable {
    /**
     * @dev Returns the current implementation of `proxy`.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function getProxyImplementation(ITransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    /**
     * @dev Returns the current admin of `proxy`.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function getProxyAdmin(ITransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("admin()")) == 0xf851a440
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    /**
     * @dev Changes the admin of `proxy` to `newAdmin`.
     *
     * Requirements:
     *
     * - This contract must be the current admin of `proxy`.
     */
    function changeProxyAdmin(ITransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrades `proxy` to `implementation`. See {TransparentUpgradeableProxy-upgradeTo}.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function upgrade(ITransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {
        proxy.upgradeTo(implementation);
    }

    /**
     * @dev Upgrades `proxy` to `implementation` and calls a function on the new implementation. See
     * {TransparentUpgradeableProxy-upgradeToAndCall}.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function upgradeAndCall(
        ITransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/access/Ownable2Step.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;



/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;






/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeCast.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
}

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File: contracts/common/EIP2535/interfaces/IDiamond.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
/******************************************************************************/

interface IDiamond {
  enum FacetCutAction {
    Add,
    Replace,
    Remove
  }
  // Add=0, Replace=1, Remove=2

  struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
  }

  event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// File: contracts/common/EIP2535/interfaces/IDiamondCut.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
/******************************************************************************/



interface IDiamondCut is IDiamond {
  /// @notice Add/replace/remove any number of functions and optionally execute
  ///         a function with delegatecall
  /// @param _diamondCut Contains the facet addresses and function selectors
  /// @param _init The address of the contract or facet to execute _calldata
  /// @param _calldata A function call, including function selector and arguments
  ///                  _calldata is executed with delegatecall on _init
  function diamondCut(
    FacetCut[] calldata _diamondCut,
    address _init,
    bytes calldata _calldata
  ) external;
}

// File: contracts/common/EIP2535/libraries/LibDiamond.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
/******************************************************************************/



// solhint-disable avoid-low-level-calls
// solhint-disable no-inline-assembly

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

error NoSelectorsGivenToAdd();
error NotContractOwner(address _user, address _contractOwner);
error NoSelectorsProvidedForFacetForCut(address _facetAddress);
error CannotAddSelectorsToZeroAddress(bytes4[] _selectors);
error NoBytecodeAtAddress(address _contractAddress, string _message);
error IncorrectFacetCutAction(uint8 _action);
error CannotAddFunctionToDiamondThatAlreadyExists(bytes4 _selector);
error CannotReplaceFunctionsFromFacetWithZeroAddress(bytes4[] _selectors);
error CannotReplaceImmutableFunction(bytes4 _selector);
error CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(bytes4 _selector);
error CannotReplaceFunctionThatDoesNotExists(bytes4 _selector);
error RemoveFacetAddressMustBeZeroAddress(address _facetAddress);
error CannotRemoveFunctionThatDoesNotExist(bytes4 _selector);
error CannotRemoveImmutableFunction(bytes4 _selector);
error InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);

library LibDiamond {
  bytes32 internal constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

  struct FacetAddressAndSelectorPosition {
    address facetAddress;
    uint16 selectorPosition;
  }

  struct DiamondStorage {
    // function selector => facet address and selector position in selectors array
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
    mapping(bytes4 => bool) supportedInterfaces;
    // owner of the contract
    address contractOwner;
  }

  function diamondStorage() internal pure returns (DiamondStorage storage ds) {
    bytes32 position = DIAMOND_STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
  }

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function setContractOwner(address _newOwner) internal {
    DiamondStorage storage ds = diamondStorage();
    address previousOwner = ds.contractOwner;
    ds.contractOwner = _newOwner;
    emit OwnershipTransferred(previousOwner, _newOwner);
  }

  function contractOwner() internal view returns (address contractOwner_) {
    contractOwner_ = diamondStorage().contractOwner;
  }

  function enforceIsContractOwner() internal view {
    if (msg.sender != diamondStorage().contractOwner) {
      revert NotContractOwner(msg.sender, diamondStorage().contractOwner);
    }
  }

  event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

  // Internal function version of diamondCut
  function diamondCut(
    IDiamondCut.FacetCut[] memory _diamondCut,
    address _init,
    bytes memory _calldata
  ) internal {
    for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
      bytes4[] memory functionSelectors = _diamondCut[facetIndex].functionSelectors;
      address facetAddress = _diamondCut[facetIndex].facetAddress;
      if (functionSelectors.length == 0) {
        revert NoSelectorsProvidedForFacetForCut(facetAddress);
      }
      IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
      if (action == IDiamond.FacetCutAction.Add) {
        addFunctions(facetAddress, functionSelectors);
      } else if (action == IDiamond.FacetCutAction.Replace) {
        replaceFunctions(facetAddress, functionSelectors);
      } else if (action == IDiamond.FacetCutAction.Remove) {
        removeFunctions(facetAddress, functionSelectors);
      } else {
        revert IncorrectFacetCutAction(uint8(action));
      }
    }
    emit DiamondCut(_diamondCut, _init, _calldata);
    initializeDiamondCut(_init, _calldata);
  }

  function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
    if (_facetAddress == address(0)) {
      revert CannotAddSelectorsToZeroAddress(_functionSelectors);
    }
    DiamondStorage storage ds = diamondStorage();
    uint16 selectorCount = uint16(ds.selectors.length);
    enforceHasContractCode(_facetAddress, "LibDiamondCut: Add facet has no code");
    for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
      bytes4 selector = _functionSelectors[selectorIndex];
      address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
      if (oldFacetAddress != address(0)) {
        revert CannotAddFunctionToDiamondThatAlreadyExists(selector);
      }
      ds.facetAddressAndSelectorPosition[selector] = FacetAddressAndSelectorPosition(_facetAddress, selectorCount);
      ds.selectors.push(selector);
      selectorCount++;
    }
  }

  function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
    DiamondStorage storage ds = diamondStorage();
    if (_facetAddress == address(0)) {
      revert CannotReplaceFunctionsFromFacetWithZeroAddress(_functionSelectors);
    }
    enforceHasContractCode(_facetAddress, "LibDiamondCut: Replace facet has no code");
    for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
      bytes4 selector = _functionSelectors[selectorIndex];
      address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
      // can't replace immutable functions -- functions defined directly in the diamond in this case
      if (oldFacetAddress == address(this)) {
        revert CannotReplaceImmutableFunction(selector);
      }
      if (oldFacetAddress == _facetAddress) {
        revert CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(selector);
      }
      if (oldFacetAddress == address(0)) {
        revert CannotReplaceFunctionThatDoesNotExists(selector);
      }
      // replace old facet address
      ds.facetAddressAndSelectorPosition[selector].facetAddress = _facetAddress;
    }
  }

  function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
    DiamondStorage storage ds = diamondStorage();
    uint256 selectorCount = ds.selectors.length;
    if (_facetAddress != address(0)) {
      revert RemoveFacetAddressMustBeZeroAddress(_facetAddress);
    }
    for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
      bytes4 selector = _functionSelectors[selectorIndex];
      FacetAddressAndSelectorPosition memory oldFacetAddressAndSelectorPosition = ds.facetAddressAndSelectorPosition[
        selector
      ];
      if (oldFacetAddressAndSelectorPosition.facetAddress == address(0)) {
        revert CannotRemoveFunctionThatDoesNotExist(selector);
      }

      // can't remove immutable functions -- functions defined directly in the diamond
      if (oldFacetAddressAndSelectorPosition.facetAddress == address(this)) {
        revert CannotRemoveImmutableFunction(selector);
      }
      // replace selector with last selector
      selectorCount--;
      if (oldFacetAddressAndSelectorPosition.selectorPosition != selectorCount) {
        bytes4 lastSelector = ds.selectors[selectorCount];
        ds.selectors[oldFacetAddressAndSelectorPosition.selectorPosition] = lastSelector;
        ds.facetAddressAndSelectorPosition[lastSelector].selectorPosition = oldFacetAddressAndSelectorPosition
          .selectorPosition;
      }
      // delete last selector
      ds.selectors.pop();
      delete ds.facetAddressAndSelectorPosition[selector];
    }
  }

  function initializeDiamondCut(address _init, bytes memory _calldata) internal {
    if (_init == address(0)) {
      return;
    }
    enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
    (bool success, bytes memory error) = _init.delegatecall(_calldata);
    if (!success) {
      if (error.length > 0) {
        // bubble up error
        /// @solidity memory-safe-assembly
        assembly {
          let returndata_size := mload(error)
          revert(add(32, error), returndata_size)
        }
      } else {
        revert InitializationFunctionReverted(_init, _calldata);
      }
    }
  }

  function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
    uint256 contractSize;
    assembly {
      contractSize := extcodesize(_contract)
    }
    if (contractSize == 0) {
      revert NoBytecodeAtAddress(_contract, _errorMessage);
    }
  }
}

// File: contracts/common/EIP2535/interfaces/IDiamondLoupe.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
/******************************************************************************/

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
  /// These functions are expected to be called frequently
  /// by tools.

  struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
  }

  /// @notice Gets all facet addresses and their four byte function selectors.
  /// @return facets_ Facet
  function facets() external view returns (Facet[] memory facets_);

  /// @notice Gets all the function selectors supported by a specific facet.
  /// @param _facet The facet address.
  /// @return facetFunctionSelectors_
  function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

  /// @notice Get all the facet addresses used by a diamond.
  /// @return facetAddresses_
  function facetAddresses() external view returns (address[] memory facetAddresses_);

  /// @notice Gets the facet that supports the given selector.
  /// @dev If facet is not found return address(0).
  /// @param _functionSelector The function selector.
  /// @return facetAddress_ The facet address.
  function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}

// File: contracts/common/EIP2535/interfaces/IERC173.sol

pragma solidity ^0.8.0;

/// @title ERC-173 Contract Ownership Standard
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
/* is ERC165 */
interface IERC173 {
  /// @dev This emits when ownership of a contract changes.
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @notice Get the address of the owner
  /// @return owner_ The address of the owner.
  function owner() external view returns (address owner_);

  /// @notice Set the address of the new owner of the contract
  /// @dev Set _newOwner to address(0) to renounce any ownership.
  /// @param _newOwner The address of the new owner of the contract
  function transferOwnership(address _newOwner) external;
}

// File: contracts/common/EIP2535/interfaces/IERC165.sol

pragma solidity ^0.8.0;

interface IERC165 {
  /// @notice Query if a contract implements an interface
  /// @param interfaceId The interface identifier, as specified in ERC-165
  /// @dev Interface identification is specified in ERC-165. This function
  ///  uses less than 30,000 gas.
  /// @return `true` if the contract implements `interfaceID` and
  ///  `interfaceID` is not 0xffffffff, `false` otherwise
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts/common/EIP2535/Diamond.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
*
* Implementation of a diamond.
/******************************************************************************/







// solhint-disable no-complex-fallback
// solhint-disable no-inline-assembly
// solhint-disable no-empty-blocks

// When no function exists for function called
error FunctionNotFound(bytes4 _functionSelector);

// This is used in diamond constructor
// more arguments are added to this struct
// this avoids stack too deep errors
struct DiamondArgs {
  address owner;
  address init;
  bytes initCalldata;
}

contract Diamond {
  constructor(IDiamondCut.FacetCut[] memory _diamondCut, DiamondArgs memory _args) payable {
    LibDiamond.setContractOwner(_args.owner);
    LibDiamond.diamondCut(_diamondCut, _args.init, _args.initCalldata);

    // Code can be added here to perform actions and set state variables.
  }

  // Find facet for function that is called and execute the
  // function if a facet is found and return any value.
  fallback() external payable {
    LibDiamond.DiamondStorage storage ds;
    bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
    // get diamond storage
    assembly {
      ds.slot := position
    }
    // get facet from function selector
    address facet = ds.facetAddressAndSelectorPosition[msg.sig].facetAddress;
    if (facet == address(0)) {
      revert FunctionNotFound(msg.sig);
    }
    // Execute external function from facet using delegatecall and return any value.
    assembly {
      // copy function selector and any arguments
      calldatacopy(0, 0, calldatasize())
      // execute function call using the facet
      let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
      // get any return value
      returndatacopy(0, 0, returndatasize())
      // return any return value or error back to the caller
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  receive() external payable {}
}

// File: contracts/common/EIP2535/facets/DiamondCutFacet.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
/******************************************************************************/




// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

contract DiamondCutFacet is IDiamondCut {
  /// @notice Add/replace/remove any number of functions and optionally execute
  ///         a function with delegatecall
  /// @param _diamondCut Contains the facet addresses and function selectors
  /// @param _init The address of the contract or facet to execute _calldata
  /// @param _calldata A function call, including function selector and arguments
  ///                  _calldata is executed with delegatecall on _init
  function diamondCut(
    FacetCut[] calldata _diamondCut,
    address _init,
    bytes calldata _calldata
  ) external override {
    LibDiamond.enforceIsContractOwner();
    LibDiamond.diamondCut(_diamondCut, _init, _calldata);
  }
}

// File: contracts/common/EIP2535/facets/DiamondLoupeFacet.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
/******************************************************************************/

// The functions in DiamondLoupeFacet MUST be added to a diamond.
// The EIP-2535 Diamond standard requires these functions.





// solhint-disable no-inline-assembly

contract DiamondLoupeFacet is IDiamondLoupe, IERC165 {
  // Diamond Loupe Functions
  ////////////////////////////////////////////////////////////////////
  /// These functions are expected to be called frequently by tools.
  //
  // struct Facet {
  //     address facetAddress;
  //     bytes4[] functionSelectors;
  // }
  /// @notice Gets all facets and their selectors.
  /// @return facets_ Facet
  function facets() external view override returns (Facet[] memory facets_) {
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    uint256 selectorCount = ds.selectors.length;
    // create an array set to the maximum size possible
    facets_ = new Facet[](selectorCount);
    // create an array for counting the number of selectors for each facet
    uint16[] memory numFacetSelectors = new uint16[](selectorCount);
    // total number of facets
    uint256 numFacets;
    // loop through function selectors
    for (uint256 selectorIndex; selectorIndex < selectorCount; selectorIndex++) {
      bytes4 selector = ds.selectors[selectorIndex];
      address facetAddress_ = ds.facetAddressAndSelectorPosition[selector].facetAddress;
      bool continueLoop = false;
      // find the functionSelectors array for selector and add selector to it
      for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
        if (facets_[facetIndex].facetAddress == facetAddress_) {
          facets_[facetIndex].functionSelectors[numFacetSelectors[facetIndex]] = selector;
          numFacetSelectors[facetIndex]++;
          continueLoop = true;
          break;
        }
      }
      // if functionSelectors array exists for selector then continue loop
      if (continueLoop) {
        continueLoop = false;
        continue;
      }
      // create a new functionSelectors array for selector
      facets_[numFacets].facetAddress = facetAddress_;
      facets_[numFacets].functionSelectors = new bytes4[](selectorCount);
      facets_[numFacets].functionSelectors[0] = selector;
      numFacetSelectors[numFacets] = 1;
      numFacets++;
    }
    for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
      uint256 numSelectors = numFacetSelectors[facetIndex];
      bytes4[] memory selectors = facets_[facetIndex].functionSelectors;
      // setting the number of selectors
      assembly {
        mstore(selectors, numSelectors)
      }
    }
    // setting the number of facets
    assembly {
      mstore(facets_, numFacets)
    }
  }

  /// @notice Gets all the function selectors supported by a specific facet.
  /// @param _facet The facet address.
  /// @return _facetFunctionSelectors The selectors associated with a facet address.
  function facetFunctionSelectors(address _facet)
    external
    view
    override
    returns (bytes4[] memory _facetFunctionSelectors)
  {
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    uint256 selectorCount = ds.selectors.length;
    uint256 numSelectors;
    _facetFunctionSelectors = new bytes4[](selectorCount);
    // loop through function selectors
    for (uint256 selectorIndex; selectorIndex < selectorCount; selectorIndex++) {
      bytes4 selector = ds.selectors[selectorIndex];
      address facetAddress_ = ds.facetAddressAndSelectorPosition[selector].facetAddress;
      if (_facet == facetAddress_) {
        _facetFunctionSelectors[numSelectors] = selector;
        numSelectors++;
      }
    }
    // Set the number of selectors in the array
    assembly {
      mstore(_facetFunctionSelectors, numSelectors)
    }
  }

  /// @notice Get all the facet addresses used by a diamond.
  /// @return facetAddresses_
  function facetAddresses() external view override returns (address[] memory facetAddresses_) {
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    uint256 selectorCount = ds.selectors.length;
    // create an array set to the maximum size possible
    facetAddresses_ = new address[](selectorCount);
    uint256 numFacets;
    // loop through function selectors
    for (uint256 selectorIndex; selectorIndex < selectorCount; selectorIndex++) {
      bytes4 selector = ds.selectors[selectorIndex];
      address facetAddress_ = ds.facetAddressAndSelectorPosition[selector].facetAddress;
      bool continueLoop = false;
      // see if we have collected the address already and break out of loop if we have
      for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
        if (facetAddress_ == facetAddresses_[facetIndex]) {
          continueLoop = true;
          break;
        }
      }
      // continue loop if we already have the address
      if (continueLoop) {
        continueLoop = false;
        continue;
      }
      // include address
      facetAddresses_[numFacets] = facetAddress_;
      numFacets++;
    }
    // Set the number of facet addresses in the array
    assembly {
      mstore(facetAddresses_, numFacets)
    }
  }

  /// @notice Gets the facet address that supports the given selector.
  /// @dev If facet is not found return address(0).
  /// @param _functionSelector The function selector.
  /// @return facetAddress_ The facet address.
  function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_) {
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    facetAddress_ = ds.facetAddressAndSelectorPosition[_functionSelector].facetAddress;
  }

  // This implements ERC-165.
  function supportsInterface(bytes4 _interfaceId) external view override returns (bool) {
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    return ds.supportedInterfaces[_interfaceId];
  }
}

// File: contracts/common/EIP2535/facets/OwnershipFacet.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
/******************************************************************************/




contract OwnershipFacet is IERC173 {
  function transferOwnership(address _newOwner) external override {
    LibDiamond.enforceIsContractOwner();
    LibDiamond.setContractOwner(_newOwner);
  }

  function owner() external view override returns (address owner_) {
    owner_ = LibDiamond.contractOwner();
  }
}

// File: contracts/common/EIP2535/upgradeInitializers/DiamondInit.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
*
* Contract used to initialize state variables during deployment or upgrade
/******************************************************************************/







// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

// Adding parameters to the `init` or other functions you add here can make a single deployed
// DiamondInit contract reusable accross upgrades, and can be used for multiple diamonds.

contract DiamondInit {
  // You can add parameters to this function in order to pass in
  // data to set your own state variables
  function init() external {
    // adding ERC165 data
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    ds.supportedInterfaces[type(IERC165).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
    ds.supportedInterfaces[type(IERC173).interfaceId] = true;

    // add your own state variables
    // EIP-2535 specifies that the `diamondCut` function takes two optional
    // arguments: address _init and bytes calldata _calldata
    // These arguments are used to execute an arbitrary function using delegatecall
    // in order to set state variables in the diamond during deployment or an upgrade
    // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface
  }
}

// File: contracts/common/EIP2535/upgradeInitializers/DiamondMultiInit.sol

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* EIP-2535 Diamonds
*
* Contract used to initialize state variables during deployment or upgrade
/******************************************************************************/



error AddressAndCalldataLengthDoNotMatch(uint256 _addressesLength, uint256 _calldataLength);

contract DiamondMultiInit {
  // This function is provided in the third parameter of the `diamondCut` function.
  // The `diamondCut` function executes this function to execute multiple initializer functions for a single upgrade.

  function multiInit(address[] calldata _addresses, bytes[] calldata _calldata) external {
    if (_addresses.length != _calldata.length) {
      revert AddressAndCalldataLengthDoNotMatch(_addresses.length, _calldata.length);
    }
    for (uint256 i; i < _addresses.length; i++) {
      LibDiamond.initializeDiamondCut(_addresses[i], _calldata[i]);
    }
  }
}

// File: contracts/common/ERC3156/IERC3156FlashBorrower.sol

pragma solidity ^0.8.0;

interface IERC3156FlashBorrower {
  /**
   * @dev Receive a flash loan.
   * @param initiator The initiator of the loan.
   * @param token The loan currency.
   * @param amount The amount of tokens lent.
   * @param fee The additional amount of tokens to repay.
   * @param data Arbitrary data structure, intended to contain user-defined parameters.
   * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
   */
  function onFlashLoan(
    address initiator,
    address token,
    uint256 amount,
    uint256 fee,
    bytes calldata data
  ) external returns (bytes32);
}

// File: contracts/common/ERC3156/IERC3156FlashLender.sol

pragma solidity ^0.8.0;



interface IERC3156FlashLender {
  /**
   * @dev The amount of currency available to be lent.
   * @param token The loan currency.
   * @return The amount of `token` that can be borrowed.
   */
  function maxFlashLoan(address token) external view returns (uint256);

  /**
   * @dev The fee to be charged for a given loan.
   * @param token The loan currency.
   * @param amount The amount of tokens lent.
   * @return The amount of `token` to be charged for the loan, on top of the returned principal.
   */
  function flashFee(address token, uint256 amount) external view returns (uint256);

  /**
   * @dev Initiate a flash loan.
   * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
   * @param token The loan currency.
   * @param amount The amount of tokens lent.
   * @param data Arbitrary data structure, intended to contain user-defined parameters.
   */
  function flashLoan(
    IERC3156FlashBorrower receiver,
    address token,
    uint256 amount,
    bytes calldata data
  ) external returns (bool);
}

// File: contracts/common/codec/WordCodec.sol

pragma solidity ^0.8.0;

// solhint-disable no-inline-assembly

/// @dev A subset copied from the following contracts:
///
/// + `balancer-labs/v2-solidity-utils/contracts/helpers/WordCodec.sol`
/// + `balancer-labs/v2-solidity-utils/contracts/helpers/WordCodecHelpers.sol`
library WordCodec {
  /// @dev Inserts an unsigned integer of bitLength, shifted by an offset, into a 256 bit word,
  /// replacing the old value. Returns the new word.
  function insertUint(
    bytes32 word,
    uint256 value,
    uint256 offset,
    uint256 bitLength
  ) internal pure returns (bytes32 result) {
    // Equivalent to:
    // uint256 mask = (1 << bitLength) - 1;
    // bytes32 clearedWord = bytes32(uint256(word) & ~(mask << offset));
    // result = clearedWord | bytes32(value << offset);
    assembly {
      let mask := sub(shl(bitLength, 1), 1)
      let clearedWord := and(word, not(shl(offset, mask)))
      result := or(clearedWord, shl(offset, value))
    }
  }

  /// @dev Decodes and returns an unsigned integer with `bitLength` bits, shifted by an offset, from a 256 bit word.
  function decodeUint(
    bytes32 word,
    uint256 offset,
    uint256 bitLength
  ) internal pure returns (uint256 result) {
    // Equivalent to:
    // result = uint256(word >> offset) & ((1 << bitLength) - 1);
    assembly {
      result := and(shr(offset, word), sub(shl(bitLength, 1), 1))
    }
  }

  /// @dev Inserts a signed integer shifted by an offset into a 256 bit word, replacing the old value. Returns
  /// the new word.
  ///
  /// Assumes `value` can be represented using `bitLength` bits.
  function insertInt(
    bytes32 word,
    int256 value,
    uint256 offset,
    uint256 bitLength
  ) internal pure returns (bytes32) {
    unchecked {
      uint256 mask = (1 << bitLength) - 1;
      bytes32 clearedWord = bytes32(uint256(word) & ~(mask << offset));
      // Integer values need masking to remove the upper bits of negative values.
      return clearedWord | bytes32((uint256(value) & mask) << offset);
    }
  }

  /// @dev Decodes and returns a signed integer with `bitLength` bits, shifted by an offset, from a 256 bit word.
  function decodeInt(
    bytes32 word,
    uint256 offset,
    uint256 bitLength
  ) internal pure returns (int256 result) {
    unchecked {
      int256 maxInt = int256((1 << (bitLength - 1)) - 1);
      uint256 mask = (1 << bitLength) - 1;

      int256 value = int256(uint256(word >> offset) & mask);
      // In case the decoded value is greater than the max positive integer that can be represented with bitLength
      // bits, we know it was originally a negative integer. Therefore, we mask it to restore the sign in the 256 bit
      // representation.
      //
      // Equivalent to:
      // result = value > maxInt ? (value | int256(~mask)) : value;
      assembly {
        result := or(mul(gt(value, maxInt), not(mask)), value)
      }
    }
  }

  /// @dev Decodes and returns a boolean shifted by an offset from a 256 bit word.
  function decodeBool(bytes32 word, uint256 offset) internal pure returns (bool result) {
    // Equivalent to:
    // result = (uint256(word >> offset) & 1) == 1;
    assembly {
      result := and(shr(offset, word), 1)
    }
  }

  /// @dev Inserts a boolean value shifted by an offset into a 256 bit word, replacing the old value. Returns the new
  /// word.
  function insertBool(
    bytes32 word,
    bool value,
    uint256 offset
  ) internal pure returns (bytes32 result) {
    // Equivalent to:
    // bytes32 clearedWord = bytes32(uint256(word) & ~(1 << offset));
    // bytes32 referenceInsertBool = clearedWord | bytes32(uint256(value ? 1 : 0) << offset);
    assembly {
      let clearedWord := and(word, not(shl(offset, 1)))
      result := or(clearedWord, shl(offset, value))
    }
  }

  function clearWordAtPosition(
    bytes32 word,
    uint256 offset,
    uint256 bitLength
  ) internal pure returns (bytes32 clearedWord) {
    unchecked {
      uint256 mask = (1 << bitLength) - 1;
      clearedWord = bytes32(uint256(word) & ~(mask << offset));
    }
  }
}

// File: contracts/common/rewards/distributor/IMultipleRewardDistributor.sol

pragma solidity ^0.8.0;

interface IMultipleRewardDistributor {
  /**********
   * Events *
   **********/

  /// @notice Emitted when new reward token is registered.
  ///
  /// @param token The address of reward token.
  /// @param distributor The address of reward distributor.
  event RegisterRewardToken(address indexed token, address indexed distributor);

  /// @notice Emitted when the reward distributor is updated.
  ///
  /// @param token The address of reward token.
  /// @param oldDistributor The address of previous reward distributor.
  /// @param newDistributor The address of current reward distributor.
  event UpdateRewardDistributor(address indexed token, address indexed oldDistributor, address indexed newDistributor);

  /// @notice Emitted when a reward token is unregistered.
  ///
  /// @param token The address of reward token.
  event UnregisterRewardToken(address indexed token);

  /// @notice Emitted when a reward token is deposited.
  ///
  /// @param token The address of reward token.
  /// @param amount The amount of reward token deposited.
  event DepositReward(address indexed token, uint256 amount);

  /**********
   * Errors *
   **********/

  /// @dev Thrown when caller access an unactive reward token.
  error NotActiveRewardToken();

  /// @dev Thrown when the address of reward distributor is `address(0)`.
  error RewardDistributorIsZero();

  /// @dev Thrown when caller is not reward distributor.
  error NotRewardDistributor();

  /// @dev Thrown when caller try to register an existing reward token.
  error DuplicatedRewardToken();

  /// @dev Thrown when caller try to unregister a reward with pending rewards.
  error RewardDistributionNotFinished();

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the address of reward distributor.
  ///
  /// @param token The address of reward token.
  function distributors(address token) external view returns (address);

  /// @notice Return the list of active reward tokens.
  function getActiveRewardTokens() external view returns (address[] memory);

  /// @notice Return the list of historical reward tokens.
  function getHistoricalRewardTokens() external view returns (address[] memory);

  /// @notice Return the amount of pending distributed rewards in current period.
  ///
  /// @param token The address of reward token.
  /// @return distributable The amount of reward token can be distributed in current period.
  /// @return undistributed The amount of reward token still locked in current period.
  function pendingRewards(address token) external view returns (uint256 distributable, uint256 undistributed);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Deposit new rewards to this contract.
  ///
  /// @param token The address of reward token.
  /// @param amount The amount of new rewards.
  function depositReward(address token, uint256 amount) external;
}

// File: contracts/common/rewards/distributor/IRewardDistributor.sol

pragma solidity ^0.8.0;

interface IRewardDistributor {
  /**********
   * Events *
   **********/

  /// @notice Emitted when a reward token is deposited.
  ///
  /// @param amount The amount of reward token deposited.
  event DepositReward(uint256 amount);

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the address of reward token.
  function rewardToken() external view returns (address);

  /// @notice Return the amount of pending distributed rewards in current period.
  /// @return distributable The amount of reward token can be distributed in current period.
  /// @return undistributed The amount of reward token still locked in current period.
  function pendingRewards() external view returns (uint256 distributable, uint256 undistributed);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Deposit new rewards to this contract.
  ///
  /// @param amount The amount of new rewards.
  function depositReward(uint256 amount) external;
}

// File: contracts/common/rewards/distributor/LinearReward.sol

pragma solidity ^0.8.0;



// solhint-disable not-rely-on-time

library LinearReward {
  using SafeCast for uint256;

  /// @dev Compiler will pack this into single `uint256`.
  /// Usually, we assume the amount of rewards won't exceed `uint96.max`.
  /// In such case, the rate won't exceed `uint80.max`, since `periodLength` is at least `86400`.
  /// Also `uint40.max` is enough for timestamp, which is about 30000 years.
  struct RewardData {
    // The amount of rewards pending to distribute.
    uint96 queued;
    // The current reward rate per second.
    uint80 rate;
    // The last timestamp when the reward is distributed.
    uint40 lastUpdate;
    // The timestamp when this period will finish.
    uint40 finishAt;
  }

  /// @dev Add new rewards to current one. It is possible that the rewards will not distribute immediately.
  /// The rewards will be only distributed when current period is end or the current increase or
  /// decrease no more than 10%.
  ///
  /// @param _data The struct of reward data, will be modified inplace.
  /// @param _periodLength The length of a period, caller should make sure it is at least `86400`.
  /// @param _amount The amount of new rewards to distribute.
  function increase(
    RewardData memory _data,
    uint256 _periodLength,
    uint256 _amount
  ) internal view {
    _amount = _amount + _data.queued;
    _data.queued = 0;

    if (block.timestamp >= _data.finishAt) {
      // period finished, distribute to next period
      _data.rate = (_amount / _periodLength).toUint80();
      _data.queued = uint96(_amount - (_data.rate * _periodLength)); // keep rounding error
      _data.lastUpdate = uint40(block.timestamp);
      _data.finishAt = uint40(block.timestamp + _periodLength);
    } else {
      uint256 _elapsed = block.timestamp - (_data.finishAt - _periodLength);
      uint256 _distributed = uint256(_data.rate) * _elapsed;
      if (_distributed * 9 <= _amount * 10) {
        // APR increase or drop no more than 10%, distribute
        _amount = _amount + uint256(_data.rate) * (_data.finishAt - _data.lastUpdate);
        _data.rate = (_amount / _periodLength).toUint80();
        _data.queued = uint96(_amount - (_data.rate * _periodLength)); // keep rounding error
        _data.lastUpdate = uint40(block.timestamp);
        _data.finishAt = uint40(block.timestamp + _periodLength);
        _data.lastUpdate = uint40(block.timestamp);
      } else {
        // APR drop more than 10%, wait for more rewards
        _data.queued = _amount.toUint96();
      }
    }
  }

  /// @dev Return the amount of pending distributed rewards in current period.
  ///
  /// @param _data The struct of reward data.
  function pending(RewardData memory _data) internal view returns (uint256, uint256) {
    uint256 _elapsed;
    uint256 _left;
    if (block.timestamp > _data.finishAt) {
      // finishAt >= lastUpdate will happen, if `_notifyReward` is not called during current period.
      _elapsed = _data.finishAt >= _data.lastUpdate ? _data.finishAt - _data.lastUpdate : 0;
    } else {
      unchecked {
        _elapsed = block.timestamp - _data.lastUpdate;
        _left = uint256(_data.finishAt) - block.timestamp;
      }
    }

    return (uint256(_data.rate) * _elapsed, uint256(_data.rate) * _left);
  }
}

// File: contracts/common/rewards/distributor/LinearMultipleRewardDistributor.sol

pragma solidity ^0.8.0;









// solhint-disable no-empty-blocks
// solhint-disable not-rely-on-time

abstract contract LinearMultipleRewardDistributor is AccessControlUpgradeable, IMultipleRewardDistributor {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  using LinearReward for LinearReward.RewardData;

  /*************
   * Constants *
   *************/

  /// @notice The role used to manage rewards.
  bytes32 public constant REWARD_MANAGER_ROLE = keccak256("REWARD_MANAGER_ROLE");

  /// @notice The length of reward period in seconds.
  /// @dev If the value is zero, the reward will be distributed immediately.
  /// @dev It is either zero or at least 1 day (which is 86400).
  uint40 public immutable periodLength;

  /*************
   * Variables *
   *************/

  /// @inheritdoc IMultipleRewardDistributor
  mapping(address => address) public override distributors;

  /// @notice Mapping from reward token address to linear distribution reward data.
  mapping(address => LinearReward.RewardData) public rewardData;

  /// @dev The list of active reward tokens.
  EnumerableSet.AddressSet internal activeRewardTokens;

  /// @dev The list of historical reward tokens.
  EnumerableSet.AddressSet private historicalRewardTokens;

  /// @dev reserved slots.
  uint256[46] private __gap;

  /***************
   * Constructor *
   ***************/

  constructor(uint40 _periodLength) {
    require(_periodLength == 0 || (_periodLength >= 1 days && _periodLength <= 28 days), "invalid period length");

    periodLength = _periodLength;
  }

  // solhint-disable-next-line func-name-mixedcase
  function __LinearMultipleRewardDistributor_init() internal onlyInitializing {}

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IMultipleRewardDistributor
  function getActiveRewardTokens() public view override returns (address[] memory _rewardTokens) {
    uint256 _length = activeRewardTokens.length();
    _rewardTokens = new address[](_length);

    for (uint256 i = 0; i < _length; i++) {
      _rewardTokens[i] = activeRewardTokens.at(i);
    }
  }

  /// @inheritdoc IMultipleRewardDistributor
  function getHistoricalRewardTokens() public view override returns (address[] memory _rewardTokens) {
    uint256 _length = historicalRewardTokens.length();
    _rewardTokens = new address[](_length);

    for (uint256 i = 0; i < _length; i++) {
      _rewardTokens[i] = historicalRewardTokens.at(i);
    }
  }

  /// @inheritdoc IMultipleRewardDistributor
  function pendingRewards(address _token) external view override returns (uint256, uint256) {
    return rewardData[_token].pending();
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IMultipleRewardDistributor
  function depositReward(address _token, uint256 _amount) external override {
    address _distributor = _msgSender();
    if (!activeRewardTokens.contains(_token)) revert NotActiveRewardToken();
    if (distributors[_token] != _distributor) revert NotRewardDistributor();

    if (_amount > 0) {
      IERC20(_token).safeTransferFrom(_distributor, address(this), _amount);
    }

    _distributePendingReward();

    _notifyReward(_token, _amount);

    emit DepositReward(_token, _amount);
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Register a new reward token.
  /// @dev Make sure no fee on transfer token is added as reward token.
  ///
  /// @param _token The address of reward token.
  /// @param _distributor The address of reward distributor.
  function registerRewardToken(address _token, address _distributor) external onlyRole(REWARD_MANAGER_ROLE) {
    if (_distributor == address(0)) revert RewardDistributorIsZero();
    if (activeRewardTokens.contains(_token)) revert DuplicatedRewardToken();

    activeRewardTokens.add(_token);
    distributors[_token] = _distributor;
    historicalRewardTokens.remove(_token);

    emit RegisterRewardToken(_token, _distributor);
  }

  /// @notice Update the distributor for reward token.
  ///
  /// @param _token The address of reward token.
  /// @param _newDistributor The address of new reward distributor.
  function updateRewardDistributor(address _token, address _newDistributor) external onlyRole(REWARD_MANAGER_ROLE) {
    if (_newDistributor == address(0)) revert RewardDistributorIsZero();
    if (!activeRewardTokens.contains(_token)) revert NotActiveRewardToken();

    address _oldDistributor = distributors[_token];
    distributors[_token] = _newDistributor;

    emit UpdateRewardDistributor(_token, _oldDistributor, _newDistributor);
  }

  /// @notice Unregister an existing reward token.
  ///
  /// @param _token The address of reward token.
  function unregisterRewardToken(address _token) external onlyRole(REWARD_MANAGER_ROLE) {
    if (!activeRewardTokens.contains(_token)) revert NotActiveRewardToken();

    LinearReward.RewardData memory _data = rewardData[_token];
    unchecked {
      (uint256 _distributable, uint256 _undistributed) = _data.pending();
      if (_data.queued < periodLength) _data.queued = 0; // ignore round error
      if (_data.queued + _distributable + _undistributed > 0) revert RewardDistributionNotFinished();
    }

    activeRewardTokens.remove(_token);
    distributors[_token] = address(0);
    historicalRewardTokens.add(_token);

    emit UnregisterRewardToken(_token);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to notify new rewards.
  ///
  /// @param _token The address of token.
  /// @param _amount The amount of new rewards.
  function _notifyReward(address _token, uint256 _amount) internal {
    if (periodLength == 0) {
      _accumulateReward(_token, _amount);
    } else {
      LinearReward.RewardData memory _data = rewardData[_token];
      _data.increase(periodLength, _amount);
      rewardData[_token] = _data;
    }
  }

  /// @dev Internal function to distribute all pending reward tokens.
  function _distributePendingReward() internal {
    if (periodLength == 0 || activeRewardTokens.length() == 0) return;

    address[] memory _activeRewardTokens = getActiveRewardTokens();
    for (uint256 i = 0; i < _activeRewardTokens.length; i++) {
      address _token = _activeRewardTokens[i];
      (uint256 _pending, ) = rewardData[_token].pending();
      rewardData[_token].lastUpdate = uint40(block.timestamp);

      if (_pending > 0) {
        _accumulateReward(_token, _pending);
      }
    }
  }

  /// @dev Internal function to accumulate distributed rewards.
  ///
  /// @param _token The address of token.
  /// @param _amount The amount of rewards to accumulate.
  function _accumulateReward(address _token, uint256 _amount) internal virtual;
}

// File: contracts/common/rewards/distributor/LinearRewardDistributor.sol

pragma solidity ^0.8.0;








// solhint-disable no-empty-blocks
// solhint-disable not-rely-on-time

abstract contract LinearRewardDistributor is AccessControlUpgradeable, IRewardDistributor {
  using SafeERC20 for IERC20;

  using LinearReward for LinearReward.RewardData;

  /*************
   * Constants *
   *************/

  /// @notice The role used to deposit rewards.
  bytes32 public constant REWARD_DEPOSITOR_ROLE = keccak256("REWARD_DEPOSITOR_ROLE");

  /// @notice The length of reward period in seconds.
  /// @dev If the value is zero, the reward will be distributed immediately.
  /// It is either zero or at least 1 day (which is 86400).
  uint40 public immutable periodLength;

  /*************
   * Variables *
   *************/

  /// @notice The linear distribution reward data.
  LinearReward.RewardData public rewardData;

  /// @inheritdoc IRewardDistributor
  address public override rewardToken;

  /// @dev reserved slots.
  uint256[48] private __gap;

  /***************
   * Constructor *
   ***************/

  constructor(uint40 _periodLength) {
    require(_periodLength == 0 || (_periodLength >= 1 days && _periodLength <= 28 days), "invalid period length");

    periodLength = _periodLength;
  }

  // solhint-disable-next-line func-name-mixedcase
  function __LinearRewardDistributor_init(address _rewardToken) internal onlyInitializing {
    rewardToken = _rewardToken;
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IRewardDistributor
  function pendingRewards() public view override returns (uint256, uint256) {
    return rewardData.pending();
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IRewardDistributor
  function depositReward(uint256 _amount) external override onlyRole(REWARD_DEPOSITOR_ROLE) {
    if (_amount > 0) {
      IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
    }

    _distributePendingReward();

    _notifyReward(_amount);

    _afterRewardDeposit(_amount);

    emit DepositReward(_amount);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to notify new rewards.
  ///
  /// @param _amount The amount of new rewards.
  function _notifyReward(uint256 _amount) internal {
    if (periodLength == 0) {
      _accumulateReward(_amount);
    } else {
      LinearReward.RewardData memory _data = rewardData;
      _data.increase(periodLength, _amount);
      rewardData = _data;
    }
  }

  /// @dev Internal function to distribute all pending reward tokens.
  function _distributePendingReward() internal {
    if (periodLength == 0) return;

    (uint256 _pending, ) = rewardData.pending();
    rewardData.lastUpdate = uint40(block.timestamp);

    if (_pending > 0) {
      _accumulateReward(_pending);
    }
  }

  /// @dev Internal function to accumulate distributed rewards.
  ///
  /// @param _amount The amount of rewards to accumulate.
  function _accumulateReward(uint256 _amount) internal virtual;

  /// @dev The hook for the deposited rewards.
  /// @param _amount The amount of rewards deposited.
  function _afterRewardDeposit(uint256 _amount) internal virtual {}
}

// File: contracts/common/utils/PermissionedSwap.sol

pragma solidity ^0.8.0;





// solhint-disable avoid-low-level-calls
// solhint-disable no-inline-assembly

abstract contract PermissionedSwap is AccessControlUpgradeable {
  using SafeERC20 for IERC20;

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the amount of output token is not enough.
  error InsufficientOutputToken();

  /*************
   * Constants *
   *************/

  /// @notice The role for permissioned trader.
  bytes32 public constant PERMISSIONED_TRADER_ROLE = keccak256("PERMISSIONED_TRADER_ROLE");

  /// @notice The role for permissioned trading router.
  bytes32 public constant PERMISSIONED_ROUTER_ROLE = keccak256("PERMISSIONED_ROUTER_ROLE");

  /***********
   * Structs *
   ***********/

  /// @notice The struct for trading parameters.
  ///
  /// @param router The address of trading router.
  /// @param data The calldata passing to the router contract.
  /// @param minOut The minimum amount of output token should receive.
  struct TradingParameter {
    address router;
    bytes data;
    uint256 minOut;
  }

  /*************
   * Variables *
   *************/

  /// @dev reserved slots.
  uint256[50] private __gap;

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Withdraw base token to someone else.
  /// @dev This should be only used when we are retiring this contract.
  /// @param baseToken The address of base token.
  function withdraw(address baseToken, address recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
    uint256 amountIn = IERC20(baseToken).balanceOf(address(this));
    IERC20(baseToken).safeTransfer(recipient, amountIn);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to convert token with routes.
  /// @param srcToken The address of source token.
  /// @param dstToken The address of destination token.
  /// @param amountIn The amount of input token.
  /// @param params The token converting parameters.
  /// @return amountOut The amount of output token received.
  function _doTrade(
    address srcToken,
    address dstToken,
    uint256 amountIn,
    TradingParameter memory params
  ) internal virtual onlyRole(PERMISSIONED_TRADER_ROLE) returns (uint256 amountOut) {
    if (srcToken == dstToken) return amountIn;

    // router should be permissioned
    _checkRole(PERMISSIONED_ROUTER_ROLE, params.router);

    // approve to router
    IERC20(srcToken).forceApprove(params.router, amountIn);

    // do trading
    amountOut = IERC20(dstToken).balanceOf(address(this));
    (bool success, ) = params.router.call(params.data);
    if (!success) {
      // below lines will propagate inner error up
      assembly {
        let ptr := mload(0x40)
        let size := returndatasize()
        returndatacopy(ptr, 0, size)
        revert(ptr, size)
      }
    }

    amountOut = IERC20(dstToken).balanceOf(address(this)) - amountOut;
    if (amountOut < params.minOut) {
      revert InsufficientOutputToken();
    }
  }
}

// File: contracts/interfaces/IPool.sol

pragma solidity ^0.8.0;

interface IPool {
  /**********
   * Events *
   **********/
  
  /// @notice Emitted when price oracle is updated.
  /// @param oldOracle The previous address of price oracle.
  /// @param newOracle The current address of price oracle.
  event UpdatePriceOracle(address oldOracle, address newOracle);
  
  /// @notice Emitted when borrow status is updated.
  /// @param status The updated borrow status.
  event UpdateBorrowStatus(bool status);

  /// @notice Emitted when redeem status is updated.
  /// @param status The updated redeem status.
  event UpdateRedeemStatus(bool status);
  
  /// @notice Emitted when debt ratio range is updated.
  /// @param minDebtRatio The current value of minimum debt ratio, multiplied by 1e18.
  /// @param maxDebtRatio The current value of maximum debt ratio, multiplied by 1e18.
  event UpdateDebtRatioRange(uint256 minDebtRatio, uint256 maxDebtRatio);
  
  /// @notice Emitted when max redeem ratio per tick is updated.
  /// @param ratio The current value of max redeem ratio per tick, multiplied by 1e9.
  event UpdateMaxRedeemRatioPerTick(uint256 ratio);
  
  /// @notice Emitted when the rebalance ratio is updated.
  /// @param debtRatio The current value of rebalance debt ratio, multiplied by 1e18.
  /// @param bonusRatio The current value of rebalance bonus ratio, multiplied by 1e9.
  event UpdateRebalanceRatios(uint256 debtRatio, uint256 bonusRatio);

  /// @notice Emitted when the liquidate ratio is updated.
  /// @param debtRatio The current value of liquidate debt ratio, multiplied by 1e18.
  /// @param bonusRatio The current value of liquidate bonus ratio, multiplied by 1e9.
  event UpdateLiquidateRatios(uint256 debtRatio, uint256 bonusRatio);
  
  /// @notice Emitted when position is updated.
  /// @param position The index of this position.
  /// @param tick The index of tick, this position belongs to.
  /// @param collShares The amount of collateral shares in this position.
  /// @param debtShares The amount of debt shares in this position.
  /// @param price The price used for this operation.
  event PositionSnapshot(uint256 position, int16 tick, uint256 collShares, uint256 debtShares, uint256 price);
  
  /// @notice Emitted when tick moved due to rebalance, liquidate or redeem.
  /// @param oldTick The index of the previous tick.
  /// @param newTick The index of the current tick.
  /// @param collShares The amount of collateral shares added to new tick.
  /// @param debtShares The amount of debt shares added to new tick.
  /// @param price The price used for this operation.
  event TickMovement(int16 oldTick, int16 newTick, uint256 collShares, uint256 debtShares, uint256 price);

  /// @notice Emitted when debt index increase.
  event DebtIndexSnapshot(uint256 index);
  
  /// @notice Emitted when collateral index increase.
  event CollateralIndexSnapshot(uint256 index);

  /***********
   * Structs *
   ***********/

  /// @dev The result for liquidation.
  /// @param rawColls The amount of collateral tokens liquidated.
  /// @param rawDebts The amount of debt tokens liquidated.
  /// @param bonusRawColls The amount of bonus collateral tokens given.
  /// @param bonusFromReserve The amount of bonus collateral tokens coming from reserve pool.
  struct LiquidateResult {
    uint256 rawColls;
    uint256 rawDebts;
    uint256 bonusRawColls;
    uint256 bonusFromReserve;
  }

  /// @dev The result for rebalance.
  /// @param rawColls The amount of collateral tokens rebalanced.
  /// @param rawDebts The amount of debt tokens rebalanced.
  /// @param bonusRawColls The amount of bonus collateral tokens given.
  struct RebalanceResult {
    uint256 rawColls;
    uint256 rawDebts;
    uint256 bonusRawColls;
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @notice The address of fxUSD.
  function fxUSD() external view returns (address);

  /// @notice The address of `PoolManager` contract.
  function poolManager() external view returns (address);

  /// @notice The address of `PegKeeper` contract.
  function pegKeeper() external view returns (address);

  /// @notice The address of collateral token.
  function collateralToken() external view returns (address);

  /// @notice The address of price oracle.
  function priceOracle() external view returns (address);
  
  /// @notice Return whether borrow is paused.
  function isBorrowPaused() external view returns (bool);

  /// @notice Return whether redeem is paused.
  function isRedeemPaused() external view returns (bool);
  
  /// @notice Return the current top tick with debts.
  function getTopTick() external view returns (int16);

  /// @notice Return the next position id.
  function getNextPositionId() external view returns (uint32);

  /// @notice Return the next tick tree node id.
  function getNextTreeNodeId() external view returns (uint48);

  /// @notice Return the debt ratio range.
  /// @param minDebtRatio The minimum required debt ratio, multiplied by 1e18.
  /// @param maxDebtRatio The minimum allowed debt ratio, multiplied by 1e18.
  function getDebtRatioRange() external view returns (uint256 minDebtRatio, uint256 maxDebtRatio);

  /// @notice Return the maximum redeem percentage per tick, multiplied by 1e9.
  function getMaxRedeemRatioPerTick() external view returns (uint256);

  /// @notice Get `debtRatio` and `bonusRatio` for rebalance.
  /// @return debtRatio The minimum debt ratio to start rebalance, multiplied by 1e18.
  /// @return bonusRatio The bonus ratio during rebalance, multiplied by 1e9.
  function getRebalanceRatios() external view returns (uint256 debtRatio, uint256 bonusRatio);

  /// @notice Get `debtRatio` and `bonusRatio` for liquidate.
  /// @return debtRatio The minimum debt ratio to start liquidate, multiplied by 1e18.
  /// @return bonusRatio The bonus ratio during liquidate, multiplied by 1e9.
  function getLiquidateRatios() external view returns (uint256 debtRatio, uint256 bonusRatio);

  /// @notice Get debt and collateral index.
  /// @return debtIndex The index for debt shares.
  /// @return collIndex The index for collateral shares.
  function getDebtAndCollateralIndex() external view returns (uint256 debtIndex, uint256 collIndex);

  /// @notice Get debt and collateral shares.
  /// @return debtShares The total number of debt shares.
  /// @return collShares The total number of collateral shares.
  function getDebtAndCollateralShares() external view returns (uint256 debtShares, uint256 collShares);

  /// @notice Return the details of the given position.
  /// @param tokenId The id of position to query.
  /// @return rawColls The amount of collateral tokens supplied in this position.
  /// @return rawDebts The amount of debt tokens borrowed in this position.
  function getPosition(uint256 tokenId) external view returns (uint256 rawColls, uint256 rawDebts);

  /// @notice Return the debt ratio of the given position.
  /// @param tokenId The id of position to query.
  /// @return debtRatio The debt ratio of this position.
  function getPositionDebtRatio(uint256 tokenId) external view returns (uint256 debtRatio);

  /// @notice The total amount of raw collateral tokens.
  function getTotalRawCollaterals() external view returns (uint256);

  /// @notice The total amount of raw debt tokens.
  function getTotalRawDebts() external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Open a new position or operate on an old position.
  /// @param positionId The id of the position. If `positionId=0`, it means we need to open a new position.
  /// @param newRawColl The amount of collateral token to supply (positive value) or withdraw (negative value).
  /// @param newRawColl The amount of debt token to borrow (positive value) or repay (negative value).
  /// @param owner The address of position owner.
  /// @return actualPositionId The id of this position.
  /// @return actualRawColl The actual amount of collateral tokens supplied (positive value) or withdrawn (negative value).
  /// @return actualRawDebt The actual amount of debt tokens borrowed (positive value) or repay (negative value).
  function operate(
    uint256 positionId,
    int256 newRawColl,
    int256 newRawDebt,
    address owner
  ) external returns (uint256 actualPositionId, int256 actualRawColl, int256 actualRawDebt, uint256 protocolFees);

  /// @notice Redeem debt tokens to get collateral tokens.
  /// @param rawDebts The amount of debt tokens to redeem.
  /// @return rawColls The amount of collateral tokens to redeemed.
  function redeem(uint256 rawDebts) external returns (uint256 rawColls);

  /// @notice Rebalance all positions in the given tick.
  /// @param tick The id of tick to rebalance.
  /// @param maxRawDebts The maximum amount of debt tokens to rebalance.
  /// @return result The result of rebalance.
  function rebalance(int16 tick, uint256 maxRawDebts) external returns (RebalanceResult memory result);

  /// @notice Rebalance the given position.
  /// @param positionId The id of position to rebalance.
  /// @param maxRawDebts The maximum amount of debt tokens to rebalance.
  /// @return result The result of rebalance.
  function rebalance(uint32 positionId, uint256 maxRawDebts) external returns (RebalanceResult memory result);

  /// @notice Liquidate the given position.
  /// @param positionId The id of position to liquidate.
  /// @param maxRawDebts The maximum amount of debt tokens to liquidate.
  /// @param reservedRawColls The amount of collateral tokens in reserve pool.
  /// @return result The result of liquidate.
  function liquidate(
    uint256 positionId,
    uint256 maxRawDebts,
    uint256 reservedRawColls
  ) external returns (LiquidateResult memory result);
}

// File: contracts/interfaces/IProtocolFees.sol

pragma solidity ^0.8.0;

interface IProtocolFees {
  /**********
   * Events *
   **********/

  /// @notice Emitted when the reserve pool contract is updated.
  /// @param oldReservePool The address of previous reserve pool.
  /// @param newReservePool The address of current reserve pool.
  event UpdateReservePool(address indexed oldReservePool, address indexed newReservePool);

  /// @notice Emitted when the treasury contract is updated.
  /// @param oldTreasury The address of previous treasury contract.
  /// @param newTreasury The address of current treasury contract.
  event UpdateTreasury(address indexed oldTreasury, address indexed newTreasury);

  /// @notice Emitted when the revenue pool contract is updated.
  /// @param oldPool The address of previous revenue pool contract.
  /// @param newPool The address of current revenue pool contract.
  event UpdateRevenuePool(address indexed oldPool, address indexed newPool);

  /// @notice Emitted when the ratio for treasury is updated.
  /// @param oldRatio The value of the previous ratio, multiplied by 1e9.
  /// @param newRatio The value of the current ratio, multiplied by 1e9.
  event UpdateRewardsExpenseRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when the ratio for treasury is updated.
  /// @param oldRatio The value of the previous ratio, multiplied by 1e9.
  /// @param newRatio The value of the current ratio, multiplied by 1e9.
  event UpdateFundingExpenseRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when the ratio for treasury is updated.
  /// @param oldRatio The value of the previous ratio, multiplied by 1e9.
  /// @param newRatio The value of the current ratio, multiplied by 1e9.
  event UpdateLiquidationExpenseRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when the ratio for harvester is updated.
  /// @param oldRatio The value of the previous ratio, multiplied by 1e9.
  /// @param newRatio The value of the current ratio, multiplied by 1e9.
  event UpdateHarvesterRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when the flash loan fee ratio is updated.
  /// @param oldRatio The value of the previous ratio, multiplied by 1e9.
  /// @param newRatio The value of the current ratio, multiplied by 1e9.
  event UpdateFlashLoanFeeRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when the redeem fee ratio is updated.
  /// @param oldRatio The value of the previous ratio, multiplied by 1e9.
  /// @param newRatio The value of the current ratio, multiplied by 1e9.
  event UpdateRedeemFeeRatio(uint256 oldRatio, uint256 newRatio);

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the fee ratio distributed as protocol revenue in funding costs, multiplied by 1e9.
  function getFundingExpenseRatio() external view returns (uint256);

  /// @notice Return the fee ratio distributed as protocol revenue in general rewards, multiplied by 1e9.
  function getRewardsExpenseRatio() external view returns (uint256);

  /// @notice Return the fee ratio distributed as protocol revenue in liquidation/rebalance, multiplied by 1e9.
  function getLiquidationExpenseRatio() external view returns (uint256);

  /// @notice Return the fee ratio distributed to fxBASE in funding costs, multiplied by 1e9.
  function getFundingFxSaveRatio() external view returns (uint256);

  /// @notice Return the fee ratio distributed to fxBASE in general rewards, multiplied by 1e9.
  function getRewardsFxSaveRatio() external view returns (uint256);

  /// @notice Return the fee ratio distributed ad harvester bounty, multiplied by 1e9.
  function getHarvesterRatio() external view returns (uint256);

  /// @notice Return the flash loan fee ratio, multiplied by 1e9.
  function getFlashLoanFeeRatio() external view returns (uint256);

  /// @notice Return the redeem fee ratio, multiplied by 1e9.
  function getRedeemFeeRatio() external view returns (uint256);

  /// @notice Return the address of reserve pool.
  function reservePool() external view returns (address);

  /// @notice Return the address of protocol treasury.
  function treasury() external view returns (address);

  /// @notice Return the address of protocol revenue pool.
  function revenuePool() external view returns (address);

  /// @notice Return the amount of protocol fees accumulated by the given pool.
  function accumulatedPoolFees(address pool) external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Withdraw accumulated pool fee for the given pool lists.
  /// @param pools The list of pool addresses to withdraw.
  function withdrawAccumulatedPoolFee(address[] memory pools) external;
}

// File: contracts/core/ProtocolFees.sol

pragma solidity ^0.8.26;











abstract contract ProtocolFees is AccessControlUpgradeable, IProtocolFees {
  using SafeERC20 for IERC20;
  using WordCodec for bytes32;

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the given address is zero.
  error ErrorZeroAddress();

  /// @dev Thrown when the expense ratio exceeds `MAX_EXPENSE_RATIO`.
  error ErrorExpenseRatioTooLarge();

  /// @dev Thrown when the harvester ratio exceeds `MAX_HARVESTER_RATIO`.
  error ErrorHarvesterRatioTooLarge();

  /// @dev Thrown when the flash loan fee ratio exceeds `MAX_FLASH_LOAN_FEE_RATIO`.
  error ErrorFlashLoanFeeRatioTooLarge();

  /// @dev Thrown when the redeem fee ratio exceeds `MAX_REDEEM_FEE_RATIO`.
  error ErrorRedeemFeeRatioTooLarge();

  /*************
   * Constants *
   *************/

  /// @dev The maximum expense ratio.
  uint256 private constant MAX_EXPENSE_RATIO = 5e8; // 50%

  /// @dev The maximum harvester ratio.
  uint256 private constant MAX_HARVESTER_RATIO = 2e8; // 20%

  /// @dev The maximum flash loan fee ratio.
  uint256 private constant MAX_FLASH_LOAN_FEE_RATIO = 1e8; // 10%

  /// @dev The maximum redeem fee ratio.
  uint256 private constant MAX_REDEEM_FEE_RATIO = 1e8; // 10%

  /// @dev The offset of general expense ratio in `_miscData`.
  uint256 private constant REWARDS_EXPENSE_RATIO_OFFSET = 0;

  /// @dev The offset of harvester ratio in `_miscData`.
  uint256 private constant HARVESTER_RATIO_OFFSET = 30;

  /// @dev The offset of flash loan ratio in `_miscData`.
  uint256 private constant FLASH_LOAN_RATIO_OFFSET = 60;

  /// @dev The offset of redeem fee ratio in `_miscData`.
  uint256 private constant REDEEM_FEE_RATIO_OFFSET = 90;

  /// @dev The offset of funding expense ratio in `_miscData`.
  uint256 private constant FUNDING_EXPENSE_RATIO_OFFSET = 120;

  /// @dev The offset of liquidation expense ratio in `_miscData`.
  uint256 private constant LIQUIDATION_EXPENSE_RATIO_OFFSET = 150;

  /// @dev The precision used to compute fees.
  uint256 internal constant FEE_PRECISION = 1e9;

  /*************
   * Variables *
   *************/

  /// @dev `_miscData` is a storage slot that can be used to store unrelated pieces of information.
  /// All pools store the *expense ratio*, *harvester ratio* and *withdraw fee percentage*, but
  /// the `miscData`can be extended to store more pieces of information.
  ///
  /// The *expense ratio* is stored in the first most significant 32 bits, and the *harvester ratio* is
  /// stored in the next most significant 32 bits, and the *withdraw fee percentage* is stored in the
  /// next most significant 32 bits, leaving the remaining 160 bits free to store any other information
  /// derived pools might need.
  ///
  /// - The *expense ratio* and *harvester ratio* are charged each time when harvester harvest the pool revenue.
  /// - The *withdraw fee percentage* is charged each time when user try to withdraw assets from the pool.
  ///
  /// [ rewards expense ratio | harvester ratio | flash loan ratio | redeem ratio | funding expense ratio | liquidation expense ratio | available ]
  /// [        30 bits        |     30 bits     |     30  bits     |   30  bits   |        30 bits        |          30 bits          |  76 bits  ]
  /// [ MSB                                                                                                                                   LSB ]
  bytes32 internal _miscData;

  /// @inheritdoc IProtocolFees
  address public treasury;

  /// @inheritdoc IProtocolFees
  /// @dev Hold fees including open, close, redeem, liquidation and rebalance.
  address public revenuePool;

  /// @inheritdoc IProtocolFees
  address public reservePool;

  /// @inheritdoc IProtocolFees
  mapping(address => uint256) public accumulatedPoolFees;

  /***************
   * Constructor *
   ***************/

  function __ProtocolFees_init(
    uint256 _expenseRatio,
    uint256 _harvesterRatio,
    uint256 _flashLoanFeeRatio,
    address _treasury,
    address _revenuePool,
    address _reservePool
  ) internal onlyInitializing {
    _updateFundingExpenseRatio(_expenseRatio);
    _updateRewardsExpenseRatio(_expenseRatio);
    _updateLiquidationExpenseRatio(_expenseRatio);
    _updateHarvesterRatio(_harvesterRatio);
    _updateFlashLoanFeeRatio(_flashLoanFeeRatio);
    _updateTreasury(_treasury);
    _updateRevenuePool(_revenuePool);
    _updateReservePool(_reservePool);
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IProtocolFees
  function getFundingExpenseRatio() public view returns (uint256) {
    return _miscData.decodeUint(FUNDING_EXPENSE_RATIO_OFFSET, 30);
  }

  /// @inheritdoc IProtocolFees
  function getRewardsExpenseRatio() public view returns (uint256) {
    return _miscData.decodeUint(REWARDS_EXPENSE_RATIO_OFFSET, 30);
  }

  /// @inheritdoc IProtocolFees
  function getLiquidationExpenseRatio() public view returns (uint256) {
    return _miscData.decodeUint(LIQUIDATION_EXPENSE_RATIO_OFFSET, 30);
  }

  /// @inheritdoc IProtocolFees
  function getHarvesterRatio() public view returns (uint256) {
    return _miscData.decodeUint(HARVESTER_RATIO_OFFSET, 30);
  }

  /// @inheritdoc IProtocolFees
  function getFundingFxSaveRatio() external view returns (uint256) {
    return FEE_PRECISION - getFundingExpenseRatio() - getHarvesterRatio();
  }

  /// @inheritdoc IProtocolFees
  function getRewardsFxSaveRatio() external view returns (uint256) {
    return FEE_PRECISION - getRewardsExpenseRatio() - getHarvesterRatio();
  }

  /// @inheritdoc IProtocolFees
  function getFlashLoanFeeRatio() public view returns (uint256) {
    return _miscData.decodeUint(FLASH_LOAN_RATIO_OFFSET, 30);
  }

  /// @inheritdoc IProtocolFees
  function getRedeemFeeRatio() public view returns (uint256) {
    return _miscData.decodeUint(REDEEM_FEE_RATIO_OFFSET, 30);
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IProtocolFees
  function withdrawAccumulatedPoolFee(address[] memory pools) external {
    for (uint256 i = 0; i < pools.length; ++i) {
      _takeAccumulatedPoolFee(pools[i]);
    }
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Change address of reserve pool contract.
  /// @param _newReservePool The new address of reserve pool contract.
  function updateReservePool(address _newReservePool) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateReservePool(_newReservePool);
  }

  /// @notice Change address of treasury contract.
  /// @param _newTreasury The new address of treasury contract.
  function updateTreasury(address _newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateTreasury(_newTreasury);
  }

  /// @notice Change address of revenue pool contract.
  /// @param _newPool The new address of revenue pool contract.
  function updateRevenuePool(address _newPool) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateRevenuePool(_newPool);
  }

  /// @notice Update the fee ratio distributed to treasury.
  /// @param newRewardsRatio The new ratio for rewards to update, multiplied by 1e9.
  /// @param newFundingRatio The new ratio for funding to update, multiplied by 1e9.
  /// @param newLiquidationRatio The new ratio for liquidation/rebalance to update, multiplied by 1e9.
  function updateExpenseRatio(
    uint32 newRewardsRatio,
    uint32 newFundingRatio,
    uint32 newLiquidationRatio
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateRewardsExpenseRatio(newRewardsRatio);
    _updateFundingExpenseRatio(newFundingRatio);
    _updateLiquidationExpenseRatio(newLiquidationRatio);
  }

  /// @notice Update the fee ratio distributed to harvester.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function updateHarvesterRatio(uint32 newRatio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateHarvesterRatio(newRatio);
  }

  /// @notice Update the flash loan fee ratio.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function updateFlashLoanFeeRatio(uint32 newRatio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateFlashLoanFeeRatio(newRatio);
  }

  /// @notice Update the redeem fee ratio.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function updateRedeemFeeRatio(uint32 newRatio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateRedeemFeeRatio(newRatio);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to change address of treasury contract.
  /// @param _newTreasury The new address of treasury contract.
  function _updateTreasury(address _newTreasury) private {
    if (_newTreasury == address(0)) revert ErrorZeroAddress();

    address _oldTreasury = treasury;
    treasury = _newTreasury;

    emit UpdateTreasury(_oldTreasury, _newTreasury);
  }

  /// @dev Internal function to change address of revenue pool contract.
  /// @param _newPool The new address of revenue pool contract.
  function _updateRevenuePool(address _newPool) private {
    if (_newPool == address(0)) revert ErrorZeroAddress();

    address _oldPool = revenuePool;
    revenuePool = _newPool;

    emit UpdateRevenuePool(_oldPool, _newPool);
  }

  /// @dev Internal function to change the address of reserve pool contract.
  /// @param newReservePool The new address of reserve pool contract.
  function _updateReservePool(address newReservePool) private {
    if (newReservePool == address(0)) revert ErrorZeroAddress();

    address oldReservePool = reservePool;
    reservePool = newReservePool;

    emit UpdateReservePool(oldReservePool, newReservePool);
  }

  /// @dev Internal function to update the fee ratio distributed to treasury.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function _updateRewardsExpenseRatio(uint256 newRatio) private {
    if (uint256(newRatio) > MAX_EXPENSE_RATIO) {
      revert ErrorExpenseRatioTooLarge();
    }

    bytes32 _data = _miscData;
    uint256 _oldRatio = _miscData.decodeUint(REWARDS_EXPENSE_RATIO_OFFSET, 30);
    _miscData = _data.insertUint(newRatio, REWARDS_EXPENSE_RATIO_OFFSET, 30);

    emit UpdateRewardsExpenseRatio(_oldRatio, newRatio);
  }

  /// @dev Internal function to update the fee ratio distributed to treasury.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function _updateLiquidationExpenseRatio(uint256 newRatio) private {
    if (uint256(newRatio) > MAX_EXPENSE_RATIO) {
      revert ErrorExpenseRatioTooLarge();
    }

    bytes32 _data = _miscData;
    uint256 _oldRatio = _miscData.decodeUint(LIQUIDATION_EXPENSE_RATIO_OFFSET, 30);
    _miscData = _data.insertUint(newRatio, LIQUIDATION_EXPENSE_RATIO_OFFSET, 30);

    emit UpdateLiquidationExpenseRatio(_oldRatio, newRatio);
  }

  /// @dev Internal function to update the fee ratio distributed to treasury.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function _updateFundingExpenseRatio(uint256 newRatio) private {
    if (uint256(newRatio) > MAX_EXPENSE_RATIO) {
      revert ErrorExpenseRatioTooLarge();
    }

    bytes32 _data = _miscData;
    uint256 _oldRatio = _miscData.decodeUint(FUNDING_EXPENSE_RATIO_OFFSET, 30);
    _miscData = _data.insertUint(newRatio, FUNDING_EXPENSE_RATIO_OFFSET, 30);

    emit UpdateFundingExpenseRatio(_oldRatio, newRatio);
  }

  /// @dev Internal function to update the fee ratio distributed to harvester.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function _updateHarvesterRatio(uint256 newRatio) private {
    if (uint256(newRatio) > MAX_HARVESTER_RATIO) {
      revert ErrorHarvesterRatioTooLarge();
    }

    bytes32 _data = _miscData;
    uint256 _oldRatio = _miscData.decodeUint(HARVESTER_RATIO_OFFSET, 30);
    _miscData = _data.insertUint(newRatio, HARVESTER_RATIO_OFFSET, 30);

    emit UpdateHarvesterRatio(_oldRatio, newRatio);
  }

  /// @dev Internal function to update the flash loan fee ratio.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function _updateFlashLoanFeeRatio(uint256 newRatio) private {
    if (uint256(newRatio) > MAX_FLASH_LOAN_FEE_RATIO) {
      revert ErrorFlashLoanFeeRatioTooLarge();
    }

    bytes32 _data = _miscData;
    uint256 _oldRatio = _miscData.decodeUint(FLASH_LOAN_RATIO_OFFSET, 30);
    _miscData = _data.insertUint(newRatio, FLASH_LOAN_RATIO_OFFSET, 30);

    emit UpdateFlashLoanFeeRatio(_oldRatio, newRatio);
  }

  /// @dev Internal function to update the redeem fee ratio.
  /// @param newRatio The new ratio to update, multiplied by 1e9.
  function _updateRedeemFeeRatio(uint256 newRatio) private {
    if (uint256(newRatio) > MAX_REDEEM_FEE_RATIO) {
      revert ErrorRedeemFeeRatioTooLarge();
    }

    bytes32 _data = _miscData;
    uint256 _oldRatio = _miscData.decodeUint(REDEEM_FEE_RATIO_OFFSET, 30);
    _miscData = _data.insertUint(newRatio, REDEEM_FEE_RATIO_OFFSET, 30);

    emit UpdateRedeemFeeRatio(_oldRatio, newRatio);
  }

  /// @dev Internal function to accumulate protocol fee for the given pool.
  /// @param pool The address of pool.
  /// @param amount The amount of protocol fee.
  function _accumulatePoolFee(address pool, uint256 amount) internal {
    if (amount > 0) {
      accumulatedPoolFees[pool] += amount;
    }
  }

  /// @dev Internal function to withdraw accumulated protocol fee for the given pool.
  /// @param pool The address of pool.
  function _takeAccumulatedPoolFee(address pool) internal returns (uint256 fees) {
    fees = accumulatedPoolFees[pool];
    if (fees > 0) {
      address collateralToken = IPool(pool).collateralToken();
      IERC20(collateralToken).safeTransfer(revenuePool, fees);

      accumulatedPoolFees[pool] = 0;
    }
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   */
  uint256[45] private __gap;
}

// File: contracts/core/FlashLoans.sol

pragma solidity ^0.8.25;











contract FlashLoans is ProtocolFees, ReentrancyGuardUpgradeable, IERC3156FlashLender {
  using SafeERC20 for IERC20;

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the returned balance after flash loan is not enough.
  error ErrorInsufficientFlashLoanReturn();

  /// @dev Thrown when the returned value of `ERC3156Callback` is wrong.
  error ErrorERC3156CallbackFailed();

  /*************
   * Constants *
   *************/

  /// @dev The correct value of the return value of `ERC3156FlashBorrower.onFlashLoan`.
  bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

  /*************
   * Variables *
   *************/

  /// @dev Slots for future use.
  uint256[50] private _gap;

  /***************
   * Constructor *
   ***************/

  function __FlashLoans_init() internal onlyInitializing {}

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IERC3156FlashLender
  function maxFlashLoan(address token) external view override returns (uint256) {
    return IERC20(token).balanceOf(address(this));
  }

  /// @inheritdoc IERC3156FlashLender
  function flashFee(address /*token*/, uint256 amount) public view returns (uint256) {
    return (amount * getFlashLoanFeeRatio()) / FEE_PRECISION;
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IERC3156FlashLender
  function flashLoan(
    IERC3156FlashBorrower receiver,
    address token,
    uint256 amount,
    bytes calldata data
  ) external nonReentrant returns (bool) {
    // save the current balance
    uint256 prevBalance = IERC20(token).balanceOf(address(this));
    uint256 fee = flashFee(token, amount);

    // transfer token to receiver
    IERC20(token).safeTransfer(address(receiver), amount);

    // invoke the recipient's callback
    if (receiver.onFlashLoan(_msgSender(), token, amount, fee, data) != CALLBACK_SUCCESS) {
      revert ErrorERC3156CallbackFailed();
    }

    // ensure that the tokens + fee have been deposited back to the network
    uint256 returnedAmount = IERC20(token).balanceOf(address(this)) - prevBalance;
    if (returnedAmount < amount + fee) {
      revert ErrorInsufficientFlashLoanReturn();
    }

    if (fee > 0) {
      IERC20(token).safeTransfer(treasury, fee);
    }

    return true;
  }
}

// File: contracts/interfaces/Chainlink/AggregatorV3Interface.sol

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function latestAnswer() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: contracts/interfaces/IPoolManager.sol

pragma solidity ^0.8.0;

interface IPoolManager {
  /**********
   * Events *
   **********/
  
  /// @notice Register a new pool.
  /// @param pool The address of fx pool.
  event RegisterPool(address indexed pool);

  /// @notice Emitted when the reward splitter contract is updated.
  /// @param pool The address of fx pool.
  /// @param oldSplitter The address of previous reward splitter contract.
  /// @param newSplitter The address of current reward splitter contract.
  event UpdateRewardSplitter(address indexed pool, address indexed oldSplitter, address indexed newSplitter);

  /// @notice Emitted when the threshold for permissionless liquidate/rebalance is updated.
  /// @param oldThreshold The value of previous threshold.
  /// @param newThreshold The value of current threshold.
  event UpdatePermissionedLiquidationThreshold(uint256 oldThreshold, uint256 newThreshold);

  /// @notice Emitted when token rate is updated.
  /// @param scalar The token scalar to reach 18 decimals.
  /// @param provider The address of token rate provider.
  event UpdateTokenRate(address indexed token, uint256 scalar, address provider);

  /// @notice Emitted when pool capacity is updated.
  /// @param pool The address of fx pool.
  /// @param collateralCapacity The capacity for collateral token.
  /// @param debtCapacity The capacity for debt token.
  event UpdatePoolCapacity(address indexed pool, uint256 collateralCapacity, uint256 debtCapacity);

  /// @notice Emitted when position is updated.
  /// @param pool The address of pool where the position belongs to.
  /// @param position The id of the position.
  /// @param deltaColls The amount of collateral token changes.
  /// @param deltaDebts The amount of debt token changes.
  /// @param protocolFees The amount of protocol fees charges.
  event Operate(
    address indexed pool,
    uint256 indexed position,
    int256 deltaColls,
    int256 deltaDebts,
    uint256 protocolFees
  );
  
  /// @notice Emitted when redeem happened.
  /// @param pool The address of pool redeemed.
  /// @param colls The amount of collateral tokens redeemed.
  /// @param debts The amount of debt tokens redeemed.
  /// @param protocolFees The amount of protocol fees charges.
  event Redeem(address indexed pool, uint256 colls, uint256 debts, uint256 protocolFees);

  /// @notice Emitted when rebalance for a tick happened.
  /// @param pool The address of pool rebalanced.
  /// @param tick The index of tick rebalanced.
  /// @param colls The amount of collateral tokens rebalanced.
  /// @param fxUSDDebts The amount of fxUSD rebalanced.
  /// @param stableDebts The amount of stable token (a.k.a USDC) rebalanced.
  event RebalanceTick(address indexed pool, int16 indexed tick, uint256 colls, uint256 fxUSDDebts, uint256 stableDebts);

  /// @notice Emitted when rebalance for a position happened.
  /// @param pool The address of pool rebalanced.
  /// @param position The index of position rebalanced.
  /// @param colls The amount of collateral tokens rebalanced.
  /// @param fxUSDDebts The amount of fxUSD rebalanced.
  /// @param stableDebts The amount of stable token (a.k.a USDC) rebalanced.
  event RebalancePosition(address indexed pool, uint256 indexed position, uint256 colls, uint256 fxUSDDebts, uint256 stableDebts);

  /// @notice Emitted when liquidate for a position happened.
  /// @param pool The address of pool liquidated.
  /// @param position The index of position liquidated.
  /// @param colls The amount of collateral tokens liquidated.
  /// @param fxUSDDebts The amount of fxUSD liquidated.
  /// @param stableDebts The amount of stable token (a.k.a USDC) liquidated.
  event LiquidatePosition(address indexed pool, uint256 indexed position, uint256 colls, uint256 fxUSDDebts, uint256 stableDebts);

  /// @notice Emitted when someone harvest pending rewards.
  /// @param caller The address of caller.
  /// @param amountRewards The amount of total harvested rewards.
  /// @param amountFunding The amount of total harvested funding.
  /// @param performanceFee The amount of harvested rewards distributed to protocol revenue.
  /// @param harvestBounty The amount of harvested rewards distributed to caller as harvest bounty.
  event Harvest(
    address indexed caller,
    address indexed pool,
    uint256 amountRewards,
    uint256 amountFunding,
    uint256 performanceFee,
    uint256 harvestBounty
  );

  /*************************
   * Public View Functions *
   *************************/
  
  /// @notice The address of fxUSD.
  function fxUSD() external view returns (address);

  /// @notice The address of FxUSDSave.
  function fxBASE() external view returns (address);

  /// @notice The address of `PegKeeper`.
  function pegKeeper() external view returns (address);

  /// @notice The address of reward splitter.
  function rewardSplitter(address pool) external view returns (address);

  /****************************
   * Public Mutated Functions *
   ****************************/
  
  /// @notice Open a new position or operate on an old position.
  /// @param pool The address of pool to operate.
  /// @param positionId The id of the position. If `positionId=0`, it means we need to open a new position.
  /// @param newColl The amount of collateral token to supply (positive value) or withdraw (negative value).
  /// @param newDebt The amount of debt token to borrow (positive value) or repay (negative value).
  /// @return actualPositionId The id of this position.
  function operate(
    address pool,
    uint256 positionId,
    int256 newColl,
    int256 newDebt
  ) external returns (uint256 actualPositionId);

  /// @notice Redeem debt tokens to get collateral tokens.
  /// @param pool The address of pool to redeem.
  /// @param debts The amount of debt tokens to redeem.
  /// @param minColls The minimum amount of collateral tokens should redeem.
  /// @return colls The amount of collateral tokens redeemed.
  function redeem(address pool, uint256 debts, uint256 minColls) external returns (uint256 colls);

  /// @notice Rebalance all positions in the given tick.
  /// @param pool The address of pool to rebalance.
  /// @param receiver The address of recipient for rebalanced tokens.
  /// @param tick The index of tick to rebalance.
  /// @param maxFxUSD The maximum amount of fxUSD to rebalance.
  /// @param maxStable The maximum amount of stable token (a.k.a USDC) to rebalance.
  /// @return colls The amount of collateral tokens rebalanced.
  /// @return fxUSDUsed The amount of fxUSD used to rebalance.
  /// @return stableUsed The amount of stable token used to rebalance.
  function rebalance(
    address pool,
    address receiver,
    int16 tick,
    uint256 maxFxUSD,
    uint256 maxStable
  ) external returns (uint256 colls, uint256 fxUSDUsed, uint256 stableUsed);

  /// @notice Rebalance a given position.
  /// @param pool The address of pool to rebalance.
  /// @param receiver The address of recipient for rebalanced tokens.
  /// @param positionId The id of position to rebalance.
  /// @param maxFxUSD The maximum amount of fxUSD to rebalance.
  /// @param maxStable The maximum amount of stable token (a.k.a USDC) to rebalance.
  /// @return colls The amount of collateral tokens rebalanced.
  /// @return fxUSDUsed The amount of fxUSD used to rebalance.
  /// @return stableUsed The amount of stable token used to rebalance.
  function rebalance(
    address pool,
    address receiver,
    uint32 positionId,
    uint256 maxFxUSD,
    uint256 maxStable
  ) external returns (uint256 colls, uint256 fxUSDUsed, uint256 stableUsed);

  /// @notice Liquidate a given position.
  /// @param pool The address of pool to liquidate.
  /// @param receiver The address of recipient for liquidated tokens.
  /// @param positionId The id of position to liquidate.
  /// @param maxFxUSD The maximum amount of fxUSD to liquidate.
  /// @param maxStable The maximum amount of stable token (a.k.a USDC) to liquidate.
  /// @return colls The amount of collateral tokens liquidated.
  /// @return fxUSDUsed The amount of fxUSD used to liquidate.
  /// @return stableUsed The amount of stable token used to liquidate.
  function liquidate(
    address pool,
    address receiver,
    uint32 positionId,
    uint256 maxFxUSD,
    uint256 maxStable
  ) external returns (uint256 colls, uint256 fxUSDUsed, uint256 stableUsed);

  /// @notice Harvest pending rewards of the given pool.
  /// @param pool The address of pool to harvest.
  /// @return amountRewards The amount of rewards harvested.
  /// @return amountFunding The amount of funding harvested.
  function harvest(address pool) external returns (uint256 amountRewards, uint256 amountFunding);
}

// File: contracts/interfaces/IFxUSDBasePool.sol

pragma solidity ^0.8.0;

interface IFxUSDBasePool {
  /**********
   * Events *
   **********/

  /// @notice Emitted when the stable depeg price is updated.
  /// @param oldPrice The value of previous depeg price, multiplied by 1e18.
  /// @param newPrice The value of current depeg price, multiplied by 1e18.
  event UpdateStableDepegPrice(uint256 oldPrice, uint256 newPrice);

  /// @notice Emitted when the redeem cool down period is updated.
  /// @param oldPeriod The value of previous redeem cool down period.
  /// @param newPeriod The value of current redeem cool down period.
  event UpdateRedeemCoolDownPeriod(uint256 oldPeriod, uint256 newPeriod);

  /// @notice Emitted when deposit tokens.
  /// @param caller The address of caller.
  /// @param receiver The address of pool share recipient.
  /// @param tokenIn The address of input token.
  /// @param amountDeposited The amount of input tokens.
  /// @param amountSharesOut The amount of pool shares minted.
  event Deposit(
    address indexed caller,
    address indexed receiver,
    address indexed tokenIn,
    uint256 amountDeposited,
    uint256 amountSharesOut
  );
  
  /// @notice Emitted when users request redeem.
  /// @param caller The address of caller.
  /// @param shares The amount of shares to redeem.
  /// @param unlockAt The timestamp when this share can be redeemed.
  event RequestRedeem(address indexed caller, uint256 shares, uint256 unlockAt);

  /// @notice Emitted when redeem pool shares.
  /// @param caller The address of caller.
  /// @param receiver The address of pool share recipient.
  /// @param amountSharesToRedeem The amount of pool shares burned.
  /// @param amountYieldTokenOut The amount of yield tokens redeemed.
  /// @param amountStableTokenOut The amount of stable tokens redeemed.
  event Redeem(
    address indexed caller,
    address indexed receiver,
    uint256 amountSharesToRedeem,
    uint256 amountYieldTokenOut,
    uint256 amountStableTokenOut
  );

  /// @notice Emitted when rebalance or liquidate.
  /// @param caller The address of caller.
  /// @param tokenIn The address of input token.
  /// @param amountTokenIn The amount of input token used.
  /// @param amountCollateral The amount of collateral token rebalanced.
  /// @param amountYieldToken The amount of yield token used.
  /// @param amountStableToken The amount of stable token used.
  event Rebalance(
    address indexed caller,
    address indexed tokenIn,
    uint256 amountTokenIn,
    uint256 amountCollateral,
    uint256 amountYieldToken,
    uint256 amountStableToken
  );

  /// @notice Emitted when arbitrage in curve pool.
  /// @param caller The address of caller.
  /// @param tokenIn The address of input token.
  /// @param amountIn The amount of input token used.
  /// @param amountOut The amount of output token swapped.
  /// @param bonusOut The amount of bonus token.
  event Arbitrage(
    address indexed caller,
    address indexed tokenIn,
    uint256 amountIn,
    uint256 amountOut,
    uint256 bonusOut
  );

  /*************************
   * Public View Functions *
   *************************/

  /// @notice The address of yield token.
  function yieldToken() external view returns (address);

  /// @notice The address of stable token.
  function stableToken() external view returns (address);

  /// @notice The total amount of yield token managed in this contract
  function totalYieldToken() external view returns (uint256);

  /// @notice The total amount of stable token managed in this contract
  function totalStableToken() external view returns (uint256);

  /// @notice The net asset value, multiplied by 1e18.
  function nav() external view returns (uint256);

  /// @notice Return the stable token price, multiplied by 1e18.
  function getStableTokenPrice() external view returns (uint256);

  /// @notice Return the stable token price with scaling to 18 decimals, multiplied by 1e18.
  function getStableTokenPriceWithScale() external view returns (uint256);

  /// @notice Preview the result of deposit.
  /// @param tokenIn The address of input token.
  /// @param amount The amount of input tokens to deposit.
  /// @return amountSharesOut The amount of pool shares should receive.
  function previewDeposit(address tokenIn, uint256 amount) external view returns (uint256 amountSharesOut);

  /// @notice Preview the result of redeem.
  /// @param amountSharesToRedeem The amount of pool shares to redeem.
  /// @return amountYieldOut The amount of yield token should receive.
  /// @return amountStableOut The amount of stable token should receive.
  function previewRedeem(
    uint256 amountSharesToRedeem
  ) external view returns (uint256 amountYieldOut, uint256 amountStableOut);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Deposit token.
  /// @param receiver The address of pool shares recipient.
  /// @param tokenIn The address of input token.
  /// @param amountTokenToDeposit The amount of input tokens to deposit.
  /// @param minSharesOut The minimum amount of pool shares should receive.
  /// @return amountSharesOut The amount of pool shares received.
  function deposit(
    address receiver,
    address tokenIn,
    uint256 amountTokenToDeposit,
    uint256 minSharesOut
  ) external returns (uint256 amountSharesOut);

  /// @notice Request redeem.
  /// @param shares The amount of shares to request.
  function requestRedeem(uint256 shares) external;

  /// @notice Redeem pool shares.
  /// @param receiver The address of token recipient.
  /// @param shares The amount of pool shares to redeem.
  /// @return amountYieldOut The amount of yield token should received.
  /// @return amountStableOut The amount of stable token should received.
  function redeem(address receiver, uint256 shares) external returns (uint256 amountYieldOut, uint256 amountStableOut);

  /// @notice Rebalance all positions in the given tick.
  /// @param pool The address of pool to rebalance.
  /// @param tick The index of tick to rebalance.
  /// @param tokenIn The address of token to rebalance.
  /// @param maxAmount The maximum amount of input token to rebalance.
  /// @param minBaseOut The minimum amount of collateral tokens should receive.
  /// @return tokenUsed The amount of input token used to rebalance.
  /// @return baseOut The amount of collateral tokens rebalanced.
  function rebalance(
    address pool,
    int16 tick,
    address tokenIn,
    uint256 maxAmount,
    uint256 minBaseOut
  ) external returns (uint256 tokenUsed, uint256 baseOut);

  /// @notice Rebalance the give position.
  /// @param pool The address of pool to rebalance.
  /// @param position The index of position to rebalance.
  /// @param tokenIn The address of token to rebalance.
  /// @param maxAmount The maximum amount of input token to rebalance.
  /// @param minBaseOut The minimum amount of collateral tokens should receive.
  /// @return tokenUsed The amount of input token used to rebalance.
  /// @return baseOut The amount of collateral tokens rebalanced.
  function rebalance(
    address pool,
    uint32 position,
    address tokenIn,
    uint256 maxAmount,
    uint256 minBaseOut
  ) external returns (uint256 tokenUsed, uint256 baseOut);

  /// @notice Liquidate the give position.
  /// @param pool The address of pool to rebalance.
  /// @param position The index of position to rebalance.
  /// @param tokenIn The address of token to rebalance.
  /// @param maxAmount The maximum amount of input token to rebalance.
  /// @param minBaseOut The minimum amount of collateral tokens should receive.
  /// @return tokenUsed The amount of input token used to rebalance.
  /// @return baseOut The amount of collateral tokens rebalanced.
  function liquidate(
    address pool,
    uint32 position,
    address tokenIn,
    uint256 maxAmount,
    uint256 minBaseOut
  ) external returns (uint256 tokenUsed, uint256 baseOut);

  /// @notice Arbitrage between yield token and stable token.
  /// @param srcToken The address of source token.
  /// @param amountIn The amount of source token to use.
  /// @param receiver The address of bonus receiver.
  /// @param data The hook data to `onSwap`.
  /// @return amountOut The amount of target token swapped.
  /// @return bonusOut The amount of bonus token.
  function arbitrage(
    address srcToken,
    uint256 amountIn,
    address receiver,
    bytes calldata data
  ) external returns (uint256 amountOut, uint256 bonusOut);
}

// File: contracts/fund/AssetManagement.sol

pragma solidity ^0.8.26;



abstract contract AssetManagement is AccessControlUpgradeable {
  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   */
  uint256[50] private __gap;
}

// File: contracts/core/FxUSDBasePool.sol

pragma solidity ^0.8.25;



















contract FxUSDBasePool is
  ERC20PermitUpgradeable,
  AccessControlUpgradeable,
  ReentrancyGuardUpgradeable,
  AssetManagement,
  IFxUSDBasePool
{
  using SafeERC20 for IERC20;

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the deposited amount is zero.
  error ErrDepositZeroAmount();

  /// @dev Thrown when the minted shares are not enough.
  error ErrInsufficientSharesOut();

  /// @dev Thrown the input token in invalid.
  error ErrInvalidTokenIn();

  /// @dev Thrown when the redeemed shares is zero.
  error ErrRedeemZeroShares();

  error ErrorCallerNotPegKeeper();

  error ErrorStableTokenDepeg();

  error ErrorSwapExceedBalance();

  error ErrorInsufficientOutput();

  error ErrorInsufficientArbitrage();

  error ErrorRedeemCoolDownPeriodTooLarge();

  error ErrorRedeemMoreThanBalance();

  error ErrorRedeemLockedShares();

  error ErrorInsufficientFreeBalance();

  /*************
   * Constants *
   *************/

  /// @dev The exchange rate precision.
  uint256 internal constant PRECISION = 1e18;

  /***********************
   * Immutable Variables *
   ***********************/

  /// @notice The address of `PoolManager` contract.
  address public immutable poolManager;

  /// @notice The address of `PegKeeper` contract.
  address public immutable pegKeeper;

  /// @inheritdoc IFxUSDBasePool
  /// @dev This is also the address of FxUSD token.
  address public immutable yieldToken;

  /// @inheritdoc IFxUSDBasePool
  /// @dev The address of USDC token.
  address public immutable stableToken;

  uint256 private immutable stableTokenScale;

  /// @notice The Chainlink USDC/USD price feed.
  /// @dev The encoding is below.
  /// ```text
  /// |  32 bits  | 64 bits |  160 bits  |
  /// | heartbeat |  scale  | price_feed |
  /// |low                          high |
  /// ```
  bytes32 public immutable Chainlink_USDC_USD_Spot;

  /***********
   * Structs *
   ***********/

  struct RebalanceMemoryVar {
    uint256 stablePrice;
    uint256 totalYieldToken;
    uint256 totalStableToken;
    uint256 yieldTokenToUse;
    uint256 stableTokenToUse;
    uint256 colls;
    uint256 yieldTokenUsed;
    uint256 stableTokenUsed;
  }

  struct RedeemRequest {
    uint128 amount;
    uint128 unlockAt;
  }

  /*************
   * Variables *
   *************/

  /// @inheritdoc IFxUSDBasePool
  uint256 public totalYieldToken;

  /// @inheritdoc IFxUSDBasePool
  uint256 public totalStableToken;

  /// @notice The depeg price for stable token.
  uint256 public stableDepegPrice;

  /// @notice Mapping from user address to redeem request.
  mapping(address => RedeemRequest) public redeemRequests;

  /// @notice The number of seconds of cool down before redeem from this pool.
  uint256 public redeemCoolDownPeriod;

  /*************
   * Modifiers *
   *************/

  modifier onlyValidToken(address token) {
    if (token != stableToken && token != yieldToken) {
      revert ErrInvalidTokenIn();
    }
    _;
  }

  modifier onlyPegKeeper() {
    if (_msgSender() != pegKeeper) revert ErrorCallerNotPegKeeper();
    _;
  }

  /***************
   * Constructor *
   ***************/

  constructor(
    address _poolManager,
    address _pegKeeper,
    address _yieldToken,
    address _stableToken,
    bytes32 _Chainlink_USDC_USD_Spot
  ) {
    poolManager = _poolManager;
    pegKeeper = _pegKeeper;
    yieldToken = _yieldToken;
    stableToken = _stableToken;
    Chainlink_USDC_USD_Spot = _Chainlink_USDC_USD_Spot;

    stableTokenScale = 10 ** (18 - IERC20Metadata(_stableToken).decimals());
  }

  function initialize(
    address admin,
    string memory _name,
    string memory _symbol,
    uint256 _stableDepegPrice,
    uint256 _redeemCoolDownPeriod
  ) external initializer {
    __Context_init();
    __ERC165_init();
    __AccessControl_init();
    __ReentrancyGuard_init();

    __ERC20_init(_name, _symbol);
    __ERC20Permit_init(_name);

    _grantRole(DEFAULT_ADMIN_ROLE, admin);

    _updateStableDepegPrice(_stableDepegPrice);
    _updateRedeemCoolDownPeriod(_redeemCoolDownPeriod);

    // approve
    IERC20(yieldToken).forceApprove(poolManager, type(uint256).max);
    IERC20(stableToken).forceApprove(poolManager, type(uint256).max);
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IFxUSDBasePool
  function previewDeposit(
    address tokenIn,
    uint256 amountTokenToDeposit
  ) public view override onlyValidToken(tokenIn) returns (uint256 amountSharesOut) {
    uint256 price = getStableTokenPriceWithScale();
    uint256 amountUSD = amountTokenToDeposit;
    if (tokenIn == stableToken) {
      amountUSD = (amountUSD * price) / PRECISION;
    }

    uint256 _totalSupply = totalSupply();
    if (_totalSupply == 0) {
      amountSharesOut = amountUSD;
    } else {
      uint256 totalUSD = totalYieldToken + (totalStableToken * price) / PRECISION;
      amountSharesOut = (amountUSD * _totalSupply) / totalUSD;
    }
  }

  /// @inheritdoc IFxUSDBasePool
  function previewRedeem(
    uint256 amountSharesToRedeem
  ) external view returns (uint256 amountYieldOut, uint256 amountStableOut) {
    uint256 cachedTotalYieldToken = totalYieldToken;
    uint256 cachedTotalStableToken = totalStableToken;
    uint256 cachedTotalSupply = totalSupply();
    amountYieldOut = (amountSharesToRedeem * cachedTotalYieldToken) / cachedTotalSupply;
    amountStableOut = (amountSharesToRedeem * cachedTotalStableToken) / cachedTotalSupply;
  }

  /// @inheritdoc IFxUSDBasePool
  function nav() external view returns (uint256) {
    uint256 _totalSupply = totalSupply();
    if (_totalSupply == 0) {
      return PRECISION;
    } else {
      uint256 stablePrice = getStableTokenPriceWithScale();
      uint256 yieldPrice = IPegKeeper(pegKeeper).getFxUSDPrice();
      return (totalYieldToken * yieldPrice + totalStableToken * stablePrice) / _totalSupply;
    }
  }

  /// @inheritdoc IFxUSDBasePool
  function getStableTokenPrice() public view returns (uint256) {
    bytes32 encoding = Chainlink_USDC_USD_Spot;
    address aggregator;
    uint256 scale;
    uint256 heartbeat;
    assembly {
      aggregator := shr(96, encoding)
      scale := and(shr(32, encoding), 0xffffffffffffffff)
      heartbeat := and(encoding, 0xffffffff)
    }
    (, int256 answer, , uint256 updatedAt, ) = AggregatorV3Interface(aggregator).latestRoundData();
    if (answer < 0) revert("invalid");
    if (block.timestamp - updatedAt > heartbeat) revert("expired");
    return uint256(answer) * scale;
  }

  /// @inheritdoc IFxUSDBasePool
  function getStableTokenPriceWithScale() public view returns (uint256) {
    return getStableTokenPrice() * stableTokenScale;
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IFxUSDBasePool
  function deposit(
    address receiver,
    address tokenIn,
    uint256 amountTokenToDeposit,
    uint256 minSharesOut
  ) external override nonReentrant onlyValidToken(tokenIn) returns (uint256 amountSharesOut) {
    if (amountTokenToDeposit == 0) revert ErrDepositZeroAmount();

    // we are very sure every token is normal token, so no fot check here.
    IERC20(tokenIn).safeTransferFrom(_msgSender(), address(this), amountTokenToDeposit);

    amountSharesOut = _deposit(tokenIn, amountTokenToDeposit);
    if (amountSharesOut < minSharesOut) revert ErrInsufficientSharesOut();

    _mint(receiver, amountSharesOut);

    emit Deposit(_msgSender(), receiver, tokenIn, amountTokenToDeposit, amountSharesOut);
  }

  /// @inheritdoc IFxUSDBasePool
  function requestRedeem(uint256 shares) external {
    address caller = _msgSender();
    uint256 balance = balanceOf(caller);
    RedeemRequest memory request = redeemRequests[caller];
    if (request.amount + shares > balance) revert ErrorRedeemMoreThanBalance();
    request.amount += uint128(shares);
    request.unlockAt = uint128(block.timestamp + redeemCoolDownPeriod);
    redeemRequests[caller] = request;

    emit RequestRedeem(caller, shares, request.unlockAt);
  }

  /// @inheritdoc IFxUSDBasePool
  function redeem(
    address receiver,
    uint256 amountSharesToRedeem
  ) external nonReentrant returns (uint256 amountYieldOut, uint256 amountStableOut) {
    address caller = _msgSender();
    RedeemRequest memory request = redeemRequests[caller];
    if (request.unlockAt > block.timestamp) revert ErrorRedeemLockedShares();
    if (request.amount < amountSharesToRedeem) {
      amountSharesToRedeem = request.amount;
    }
    if (amountSharesToRedeem == 0) revert ErrRedeemZeroShares();
    request.amount -= uint128(amountSharesToRedeem);
    redeemRequests[caller] = request;

    uint256 cachedTotalYieldToken = totalYieldToken;
    uint256 cachedTotalStableToken = totalStableToken;
    uint256 cachedTotalSupply = totalSupply();

    amountYieldOut = (amountSharesToRedeem * cachedTotalYieldToken) / cachedTotalSupply;
    amountStableOut = (amountSharesToRedeem * cachedTotalStableToken) / cachedTotalSupply;

    _burn(caller, amountSharesToRedeem);

    if (amountYieldOut > 0) {
      IERC20(yieldToken).safeTransfer(receiver, amountYieldOut);
      unchecked {
        totalYieldToken = cachedTotalYieldToken - amountYieldOut;
      }
    }
    if (amountStableOut > 0) {
      IERC20(stableToken).safeTransfer(receiver, amountStableOut);
      unchecked {
        totalStableToken = cachedTotalStableToken - amountStableOut;
      }
    }

    emit Redeem(caller, receiver, amountSharesToRedeem, amountYieldOut, amountStableOut);
  }

  /// @inheritdoc IFxUSDBasePool
  function rebalance(
    address pool,
    int16 tickId,
    address tokenIn,
    uint256 maxAmount,
    uint256 minCollOut
  ) external onlyValidToken(tokenIn) nonReentrant returns (uint256 tokenUsed, uint256 colls) {
    RebalanceMemoryVar memory op = _beforeRebalanceOrLiquidate(tokenIn, maxAmount);
    (op.colls, op.yieldTokenUsed, op.stableTokenUsed) = IPoolManager(poolManager).rebalance(
      pool,
      _msgSender(),
      tickId,
      op.yieldTokenToUse,
      op.stableTokenToUse
    );
    tokenUsed = _afterRebalanceOrLiquidate(tokenIn, minCollOut, op);
    colls = op.colls;
  }

  /// @inheritdoc IFxUSDBasePool
  function rebalance(
    address pool,
    uint32 positionId,
    address tokenIn,
    uint256 maxAmount,
    uint256 minCollOut
  ) external onlyValidToken(tokenIn) nonReentrant returns (uint256 tokenUsed, uint256 colls) {
    RebalanceMemoryVar memory op = _beforeRebalanceOrLiquidate(tokenIn, maxAmount);
    (op.colls, op.yieldTokenUsed, op.stableTokenUsed) = IPoolManager(poolManager).rebalance(
      pool,
      _msgSender(),
      positionId,
      op.yieldTokenToUse,
      op.stableTokenToUse
    );
    tokenUsed = _afterRebalanceOrLiquidate(tokenIn, minCollOut, op);
    colls = op.colls;
  }

  /// @inheritdoc IFxUSDBasePool
  function liquidate(
    address pool,
    uint32 positionId,
    address tokenIn,
    uint256 maxAmount,
    uint256 minCollOut
  ) external onlyValidToken(tokenIn) nonReentrant returns (uint256 tokenUsed, uint256 colls) {
    RebalanceMemoryVar memory op = _beforeRebalanceOrLiquidate(tokenIn, maxAmount);
    (op.colls, op.yieldTokenUsed, op.stableTokenUsed) = IPoolManager(poolManager).liquidate(
      pool,
      _msgSender(),
      positionId,
      op.yieldTokenToUse,
      op.stableTokenToUse
    );
    tokenUsed = _afterRebalanceOrLiquidate(tokenIn, minCollOut, op);
    colls = op.colls;
  }

  /// @inheritdoc IFxUSDBasePool
  function arbitrage(
    address srcToken,
    uint256 amountIn,
    address receiver,
    bytes calldata data
  ) external onlyValidToken(srcToken) onlyPegKeeper nonReentrant returns (uint256 amountOut, uint256 bonusOut) {
    address dstToken;
    uint256 expectedOut;
    uint256 cachedTotalYieldToken = totalYieldToken;
    uint256 cachedTotalStableToken = totalStableToken;
    {
      uint256 price = getStableTokenPrice();
      uint256 scaledPrice = price * stableTokenScale;
      if (srcToken == yieldToken) {
        // check if usdc depeg
        if (price < stableDepegPrice) revert ErrorStableTokenDepeg();
        if (amountIn > cachedTotalYieldToken) revert ErrorSwapExceedBalance();
        dstToken = stableToken;
        unchecked {
          // rounding up
          expectedOut = Math.mulDivUp(amountIn, PRECISION, scaledPrice);
          cachedTotalYieldToken -= amountIn;
          cachedTotalStableToken += expectedOut;
        }
      } else {
        if (amountIn > cachedTotalStableToken) revert ErrorSwapExceedBalance();
        dstToken = yieldToken;
        unchecked {
          // rounding up
          expectedOut = Math.mulDivUp(amountIn, scaledPrice, PRECISION);
          cachedTotalStableToken -= amountIn;
          cachedTotalYieldToken += expectedOut;
        }
      }
    }
    IERC20(srcToken).safeTransfer(pegKeeper, amountIn);
    uint256 actualOut = IERC20(dstToken).balanceOf(address(this));
    amountOut = IPegKeeper(pegKeeper).onSwap(srcToken, dstToken, amountIn, data);
    actualOut = IERC20(dstToken).balanceOf(address(this)) - actualOut;
    // check actual fxUSD swapped in case peg keeper is hacked.
    if (amountOut > actualOut) revert ErrorInsufficientOutput();
    // check swapped token has no loss
    if (amountOut < expectedOut) revert ErrorInsufficientArbitrage();

    totalYieldToken = cachedTotalYieldToken;
    totalStableToken = cachedTotalStableToken;
    bonusOut = amountOut - expectedOut;
    if (bonusOut > 0) {
      IERC20(dstToken).safeTransfer(receiver, bonusOut);
    }

    emit Arbitrage(_msgSender(), srcToken, amountIn, amountOut, bonusOut);
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Update depeg price for stable token.
  /// @param newPrice The new depeg price of stable token, multiplied by 1e18
  function updateStableDepegPrice(uint256 newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateStableDepegPrice(newPrice);
  }

  /// @notice Update redeem cool down period.
  /// @param newPeriod The new redeem cool down period, in seconds.
  function updateRedeemCoolDownPeriod(uint256 newPeriod) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateRedeemCoolDownPeriod(newPeriod);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @inheritdoc ERC20Upgradeable
  function _update(address from, address to, uint256 value) internal virtual override {
    // make sure from don't transfer more than free balance
    if (from != address(0) && to != address(0)) {
      uint256 leftover = balanceOf(from) - redeemRequests[from].amount;
      if (value > leftover) revert ErrorInsufficientFreeBalance();
    }

    super._update(from, to, value);
  }

  /// @dev Internal function to update depeg price for stable token.
  /// @param newPrice The new depeg price of stable token, multiplied by 1e18
  function _updateStableDepegPrice(uint256 newPrice) internal {
    uint256 oldPrice = stableDepegPrice;
    stableDepegPrice = newPrice;

    emit UpdateStableDepegPrice(oldPrice, newPrice);
  }

  /// @dev Internal function to update redeem cool down period.
  /// @param newPeriod The new redeem cool down period, in seconds.
  function _updateRedeemCoolDownPeriod(uint256 newPeriod) internal {
    if (newPeriod > 7 days) revert ErrorRedeemCoolDownPeriodTooLarge();

    uint256 oldPeriod = redeemCoolDownPeriod;
    redeemCoolDownPeriod = newPeriod;

    emit UpdateRedeemCoolDownPeriod(oldPeriod, newPeriod);
  }

  /// @dev mint shares based on the deposited base tokens
  /// @param tokenIn base token address used to mint shares
  /// @param amountDeposited amount of base tokens deposited
  /// @return amountSharesOut amount of shares minted
  function _deposit(address tokenIn, uint256 amountDeposited) internal virtual returns (uint256 amountSharesOut) {
    uint256 price = getStableTokenPriceWithScale();
    if (price < stableDepegPrice * stableTokenScale) revert ErrorStableTokenDepeg();

    uint256 amountUSD = amountDeposited;
    if (tokenIn == stableToken) {
      amountUSD = (amountUSD * price) / PRECISION;
    }

    uint256 cachedTotalYieldToken = totalYieldToken;
    uint256 cachedTotalStableToken = totalStableToken;
    uint256 totalUSD = cachedTotalYieldToken + (cachedTotalStableToken * price) / PRECISION;
    uint256 cachedTotalSupply = totalSupply();
    if (cachedTotalSupply == 0) {
      amountSharesOut = amountUSD;
    } else {
      amountSharesOut = (amountUSD * cachedTotalSupply) / totalUSD;
    }

    if (tokenIn == stableToken) {
      totalStableToken = cachedTotalStableToken + amountDeposited;
    } else {
      totalYieldToken = cachedTotalYieldToken + amountDeposited;
    }
  }

  /// @dev Internal hook function to prepare before rebalance or liquidate.
  /// @param tokenIn The address of input token.
  /// @param maxAmount The maximum amount of input tokens.
  function _beforeRebalanceOrLiquidate(
    address tokenIn,
    uint256 maxAmount
  ) internal view returns (RebalanceMemoryVar memory op) {
    op.stablePrice = getStableTokenPriceWithScale();
    op.totalYieldToken = totalYieldToken;
    op.totalStableToken = totalStableToken;

    uint256 amountYieldToken = op.totalYieldToken;
    uint256 amountStableToken;
    // we always, try use fxUSD first then USDC
    if (tokenIn == yieldToken) {
      // user pays fxUSD
      if (maxAmount < amountYieldToken) amountYieldToken = maxAmount;
      else {
        amountStableToken = ((maxAmount - amountYieldToken) * PRECISION) / op.stablePrice;
      }
    } else {
      // user pays USDC
      uint256 maxAmountInUSD = (maxAmount * op.stablePrice) / PRECISION;
      if (maxAmountInUSD < amountYieldToken) amountYieldToken = maxAmountInUSD;
      else {
        amountStableToken = ((maxAmountInUSD - amountYieldToken) * PRECISION) / op.stablePrice;
      }
    }

    if (amountStableToken > op.totalStableToken) {
      amountStableToken = op.totalStableToken;
    }

    op.yieldTokenToUse = amountYieldToken;
    op.stableTokenToUse = amountStableToken;
  }

  /// @dev Internal hook function after rebalance or liquidate.
  /// @param tokenIn The address of input token.
  /// @param minCollOut The minimum expected collateral tokens.
  /// @param op The memory variable for rebalance or liquidate.
  /// @return tokenUsed The amount of input token used.
  function _afterRebalanceOrLiquidate(
    address tokenIn,
    uint256 minCollOut,
    RebalanceMemoryVar memory op
  ) internal returns (uint256 tokenUsed) {
    if (op.colls < minCollOut) revert ErrorInsufficientOutput();

    op.totalYieldToken -= op.yieldTokenUsed;
    op.totalStableToken -= op.stableTokenUsed;

    uint256 amountUSD = op.yieldTokenUsed + (op.stableTokenUsed * op.stablePrice) / PRECISION;
    if (tokenIn == yieldToken) {
      tokenUsed = amountUSD;
      op.totalYieldToken += tokenUsed;
    } else {
      // rounding up
      tokenUsed = Math.mulDivUp(amountUSD, PRECISION, op.stablePrice);
      op.totalStableToken += tokenUsed;
    }

    totalYieldToken = op.totalYieldToken;
    totalStableToken = op.totalStableToken;

    // transfer token from caller, the collateral is already transferred to caller.
    IERC20(tokenIn).safeTransferFrom(_msgSender(), address(this), tokenUsed);

    emit Rebalance(_msgSender(), tokenIn, tokenUsed, op.colls, op.yieldTokenUsed, op.stableTokenUsed);
  }
}

// File: contracts/helpers/interfaces/IMultiPathConverter.sol

pragma solidity ^0.8.0;

interface IMultiPathConverter {
  function queryConvert(
    uint256 _amount,
    uint256 _encoding,
    uint256[] calldata _routes
  ) external returns (uint256 amountOut);

  function convert(
    address _tokenIn,
    uint256 _amount,
    uint256 _encoding,
    uint256[] calldata _routes
  ) external payable returns (uint256 amountOut);
}

// File: contracts/interfaces/Curve/ICurveStableSwapNG.sol

pragma solidity ^0.8.0;

interface ICurveStableSwapNG {
  /*************************
   * Public View Functions *
   *************************/

  function coins(uint256 index) external view returns (address);

  function last_price(uint256 index) external view returns (uint256);

  function ema_price(uint256 index) external view returns (uint256);

  /// @notice Returns the AMM State price of token
  /// @dev if i = 0, it will return the state price of coin[1].
  /// @param i index of state price (0 for coin[1], 1 for coin[2], ...)
  /// @return uint256 The state price quoted by the AMM for coin[i+1]
  function get_p(uint256 i) external view returns (uint256);

  function price_oracle(uint256 index) external view returns (uint256);

  function D_oracle() external view returns (uint256);

  function A() external view returns (uint256);

  function A_precise() external view returns (uint256);

  /// @notice Calculate the current input dx given output dy
  /// @dev Index values can be found via the `coins` public getter method
  /// @param i Index value for the coin to send
  /// @param j Index value of the coin to receive
  /// @param dy Amount of `j` being received after exchange
  /// @return Amount of `i` predicted
  function get_dx(
    int128 i,
    int128 j,
    uint256 dy
  ) external view returns (uint256);

  /// @notice Calculate the current output dy given input dx
  /// @dev Index values can be found via the `coins` public getter method
  /// @param i Index value for the coin to send
  /// @param j Index value of the coin to receive
  /// @param dx Amount of `i` being exchanged
  /// @return Amount of `j` predicted
  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  /// @notice Calculate the amount received when withdrawing a single coin
  /// @param burn_amount Amount of LP tokens to burn in the withdrawal
  /// @param i Index value of the coin to withdraw
  /// @return Amount of coin received
  function calc_withdraw_one_coin(uint256 burn_amount, int128 i) external view returns (uint256);

  /// @notice The current virtual price of the pool LP token
  /// @dev Useful for calculating profits.
  ///      The method may be vulnerable to donation-style attacks if implementation
  ///      contains rebasing tokens. For integrators, caution is advised.
  /// @return LP token virtual price normalized to 1e18
  function get_virtual_price() external view returns (uint256);

  /// @notice Calculate addition or reduction in token supply from a deposit or withdrawal
  /// @param amounts Amount of each coin being deposited
  /// @param is_deposit set True for deposits, False for withdrawals
  /// @return Expected amount of LP tokens received
  function calc_token_amount(uint256[] calldata amounts, bool is_deposit) external view returns (uint256);

  /// @notice Get the current balance of a coin within the
  ///         pool, less the accrued admin fees
  /// @param i Index value for the coin to query balance of
  /// @return Token balance
  function balances(uint256 i) external view returns (uint256);

  function get_balances() external view returns (uint256[] memory);

  function stored_rates() external view returns (uint256[] memory);

  /// @notice Return the fee for swapping between `i` and `j`
  /// @param i Index value for the coin to send
  /// @param j Index value of the coin to receive
  /// @return Swap fee expressed as an integer with 1e10 precision
  function dynamic_fee(int128 i, int128 j) external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Perform an exchange between two coins
  /// @dev Index values can be found via the `coins` public getter method
  /// @param i Index value for the coin to send
  /// @param j Index value of the coin to receive
  /// @param dx Amount of `i` being exchanged
  /// @param min_dy Minimum amount of `j` to receive
  /// @return Actual amount of `j` received
  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  /// @notice Perform an exchange between two coins
  /// @dev Index values can be found via the `coins` public getter method
  /// @param i Index value for the coin to send
  /// @param j Index value of the coin to receive
  /// @param dx Amount of `i` being exchanged
  /// @param min_dy Minimum amount of `j` to receive
  /// @param receiver Address that receives `j`
  /// @return Actual amount of `j` received
  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy,
    address receiver
  ) external returns (uint256);

  /// @notice Perform an exchange between two coins without transferring token in
  /// @dev The contract swaps tokens based on a change in balance of coin[i]. The
  ///      dx = ERC20(coin[i]).balanceOf(self) - self.stored_balances[i]. Users of
  ///      this method are dex aggregators, arbitrageurs, or other users who do not
  ///      wish to grant approvals to the contract: they would instead send tokens
  ///      directly to the contract and call `exchange_received`.
  ///      Note: This is disabled if pool contains rebasing tokens.
  /// @param i Index value for the coin to send
  /// @param j Index value of the coin to receive
  /// @param dx Amount of `i` being exchanged
  /// @param min_dy Minimum amount of `j` to receive
  /// @return Actual amount of `j` received
  function exchange_received(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  /// @notice Perform an exchange between two coins without transferring token in
  /// @dev The contract swaps tokens based on a change in balance of coin[i]. The
  ///      dx = ERC20(coin[i]).balanceOf(self) - self.stored_balances[i]. Users of
  ///      this method are dex aggregators, arbitrageurs, or other users who do not
  ///      wish to grant approvals to the contract: they would instead send tokens
  ///      directly to the contract and call `exchange_received`.
  ///      Note: This is disabled if pool contains rebasing tokens.
  /// @param i Index value for the coin to send
  /// @param j Index value of the coin to receive
  /// @param dx Amount of `i` being exchanged
  /// @param min_dy Minimum amount of `j` to receive
  /// @param receiver Address that receives `j`
  /// @return Actual amount of `j` received
  function exchange_received(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy,
    address receiver
  ) external returns (uint256);

  /// @notice Deposit coins into the pool
  /// @param amounts List of amounts of coins to deposit
  /// @param min_mint_amount Minimum amount of LP tokens to mint from the deposit
  /// @return Amount of LP tokens received by depositing
  function add_liquidity(uint256[] calldata amounts, uint256 min_mint_amount) external returns (uint256);

  /// @notice Deposit coins into the pool
  /// @param amounts List of amounts of coins to deposit
  /// @param min_mint_amount Minimum amount of LP tokens to mint from the deposit
  /// @param receiver Address that owns the minted LP tokens
  /// @return Amount of LP tokens received by depositing
  function add_liquidity(
    uint256[] calldata amounts,
    uint256 min_mint_amount,
    address receiver
  ) external returns (uint256);

  /// @notice Withdraw a single coin from the pool
  /// @param burn_amount Amount of LP tokens to burn in the withdrawal
  /// @param i Index value of the coin to withdraw
  /// @param min_received Minimum amount of coin to receive
  /// @return Amount of coin received
  function remove_liquidity_one_coin(
    uint256 burn_amount,
    int128 i,
    uint256 min_received
  ) external returns (uint256);

  /// @notice Withdraw a single coin from the pool
  /// @param burn_amount Amount of LP tokens to burn in the withdrawal
  /// @param i Index value of the coin to withdraw
  /// @param min_received Minimum amount of coin to receive
  /// @param receiver Address that receives the withdrawn coins
  /// @return Amount of coin received
  function remove_liquidity_one_coin(
    uint256 burn_amount,
    int128 i,
    uint256 min_received,
    address receiver
  ) external returns (uint256);

  /// @notice Withdraw coins from the pool in an imbalanced amount
  /// @param amounts List of amounts of underlying coins to withdraw
  /// @param max_burn_amount Maximum amount of LP token to burn in the withdrawal
  /// @return Actual amount of the LP token burned in the withdrawal
  function remove_liquidity_imbalance(uint256[] calldata amounts, uint256 max_burn_amount) external returns (uint256);

  /// @notice Withdraw coins from the pool in an imbalanced amount
  /// @param amounts List of amounts of underlying coins to withdraw
  /// @param max_burn_amount Maximum amount of LP token to burn in the withdrawal
  /// @param receiver Address that receives the withdrawn coins
  /// @return Actual amount of the LP token burned in the withdrawal
  function remove_liquidity_imbalance(
    uint256[] calldata amounts,
    uint256 max_burn_amount,
    address receiver
  ) external returns (uint256);

  /// @notice Withdraw coins from the pool
  /// @dev Withdrawal amounts are based on current deposit ratios
  /// @param burn_amount Quantity of LP tokens to burn in the withdrawal
  /// @param min_amounts Minimum amounts of underlying coins to receive
  /// @return List of amounts of coins that were withdrawn
  function remove_liquidity(uint256 burn_amount, uint256[] calldata min_amounts) external returns (uint256[] memory);

  /// @notice Withdraw coins from the pool
  /// @dev Withdrawal amounts are based on current deposit ratios
  /// @param burn_amount Quantity of LP tokens to burn in the withdrawal
  /// @param min_amounts Minimum amounts of underlying coins to receive
  /// @param receiver Address that receives the withdrawn coins
  /// @return List of amounts of coins that were withdrawn
  function remove_liquidity(
    uint256 burn_amount,
    uint256[] calldata min_amounts,
    address receiver
  ) external returns (uint256[] memory);

  /// @notice Withdraw coins from the pool
  /// @dev Withdrawal amounts are based on current deposit ratios
  /// @param burn_amount Quantity of LP tokens to burn in the withdrawal
  /// @param min_amounts Minimum amounts of underlying coins to receive
  /// @param receiver Address that receives the withdrawn coins
  /// @return List of amounts of coins that were withdrawn
  function remove_liquidity(
    uint256 burn_amount,
    uint256[] calldata min_amounts,
    address receiver,
    bool claim_admin_fees
  ) external returns (uint256[] memory);

  /// @notice Claim admin fees. Callable by anyone.
  function withdraw_admin_fees() external;
}

// File: contracts/core/PegKeeper.sol

pragma solidity ^0.8.26;












contract PegKeeper is AccessControlUpgradeable, IPegKeeper {
  using SafeERC20 for IERC20;

  /**********
   * Errors *
   **********/

  error ErrorNotInCallbackContext();

  error ErrorZeroAddress();

  error ErrorInsufficientOutput();

  /*************
   * Constants *
   *************/

  /// @dev The precision used to compute nav.
  uint256 private constant PRECISION = 1e18;

  /// @notice The role for buyback.
  bytes32 public constant BUYBACK_ROLE = keccak256("BUYBACK_ROLE");

  /// @notice The role for stabilize.
  bytes32 public constant STABILIZE_ROLE = keccak256("STABILIZE_ROLE");

  /// @dev contexts for buyback and stabilize callback
  uint8 private constant CONTEXT_NO_CONTEXT = 1;
  uint8 private constant CONTEXT_BUYBACK = 2;
  uint8 private constant CONTEXT_STABILIZE = 3;

  /***********************
   * Immutable Variables *
   ***********************/

  /// @notice The address of fxUSD.
  address public immutable fxUSD;

  /// @notice The address of stable token.
  address public immutable stable;

  /// @notice The address of FxUSDBasePool.
  address public immutable fxBASE;

  /*********************
   * Storage Variables *
   *********************/

  /// @dev The context for buyback and stabilize callback.
  uint8 private context;

  /// @notice The address of MultiPathConverter.
  address public converter;

  /// @notice The curve pool for stable and fxUSD
  address public curvePool;

  /// @notice The fxUSD depeg price threshold.
  uint256 public priceThreshold;

  /*************
   * Modifiers *
   *************/

  modifier setContext(uint8 c) {
    context = c;
    _;
    context = CONTEXT_NO_CONTEXT;
  }

  /***************
   * Constructor *
   ***************/

  constructor(address _fxBASE) {
    fxBASE = _fxBASE;
    fxUSD = IFxUSDBasePool(_fxBASE).yieldToken();
    stable = IFxUSDBasePool(_fxBASE).stableToken();
  }

  function initialize(address admin, address _converter, address _curvePool) external initializer {
    __Context_init();
    __ERC165_init();
    __AccessControl_init();

    _grantRole(DEFAULT_ADMIN_ROLE, admin);

    _updateConverter(_converter);
    _updateCurvePool(_curvePool);
    _updatePriceThreshold(995000000000000000); // 0.995

    context = CONTEXT_NO_CONTEXT;
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IPegKeeper
  function isBorrowAllowed() external view returns (bool) {
    return _getFxUSDEmaPrice() >= priceThreshold;
  }

  /// @inheritdoc IPegKeeper
  function isFundingEnabled() external view returns (bool) {
    return _getFxUSDEmaPrice() < priceThreshold;
  }

  /// @inheritdoc IPegKeeper
  function getFxUSDPrice() external view returns (uint256) {
    return _getFxUSDEmaPrice();
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IPegKeeper
  function buyback(
    uint256 amountIn,
    bytes calldata data
  ) external onlyRole(BUYBACK_ROLE) setContext(CONTEXT_BUYBACK) returns (uint256 amountOut, uint256 bonus) {
    (amountOut, bonus) = IFxUSDRegeneracy(fxUSD).buyback(amountIn, _msgSender(), data);
  }

  /// @inheritdoc IPegKeeper
  function stabilize(
    address srcToken,
    uint256 amountIn,
    bytes calldata data
  ) external onlyRole(STABILIZE_ROLE) setContext(CONTEXT_STABILIZE) returns (uint256 amountOut, uint256 bonus) {
    (amountOut, bonus) = IFxUSDBasePool(fxBASE).arbitrage(srcToken, amountIn, _msgSender(), data);
  }

  /// @inheritdoc IPegKeeper
  /// @dev This function will be called in `buyback`, `stabilize`.
  function onSwap(
    address srcToken,
    address targetToken,
    uint256 amountIn,
    bytes calldata data
  ) external returns (uint256 amountOut) {
    // check callback validity
    if (context == CONTEXT_NO_CONTEXT) revert ErrorNotInCallbackContext();

    amountOut = _doSwap(srcToken, amountIn, data);
    IERC20(targetToken).safeTransfer(_msgSender(), amountOut);
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Update the address of converter.
  /// @param newConverter The address of converter.
  function updateConverter(address newConverter) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateConverter(newConverter);
  }

  /// @notice Update the address of curve pool.
  /// @param newPool The address of curve pool.
  function updateCurvePool(address newPool) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateCurvePool(newPool);
  }

  /// @notice Update the value of depeg price threshold.
  /// @param newThreshold The value of new price threshold.
  function updatePriceThreshold(uint256 newThreshold) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updatePriceThreshold(newThreshold);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to update the address of converter.
  /// @param newConverter The address of converter.
  function _updateConverter(address newConverter) internal {
    if (newConverter == address(0)) revert ErrorZeroAddress();

    address oldConverter = converter;
    converter = newConverter;

    emit UpdateConverter(oldConverter, newConverter);
  }

  /// @dev Internal function to update the address of curve pool.
  /// @param newPool The address of curve pool.
  function _updateCurvePool(address newPool) internal {
    if (newPool == address(0)) revert ErrorZeroAddress();

    address oldPool = curvePool;
    curvePool = newPool;

    emit UpdateCurvePool(oldPool, newPool);
  }

  /// @dev Internal function to update the value of depeg price threshold.
  /// @param newThreshold The value of new price threshold.
  function _updatePriceThreshold(uint256 newThreshold) internal {
    uint256 oldThreshold = priceThreshold;
    priceThreshold = newThreshold;

    emit UpdatePriceThreshold(oldThreshold, newThreshold);
  }

  /// @dev Internal function to do swap.
  /// @param srcToken The address of source token.
  /// @param amountIn The amount of token to use.
  /// @param data The callback data.
  /// @return amountOut The amount of token swapped.
  function _doSwap(address srcToken, uint256 amountIn, bytes calldata data) internal returns (uint256 amountOut) {
    IERC20(srcToken).forceApprove(converter, amountIn);

    (uint256 minOut, uint256 encoding, uint256[] memory routes) = abi.decode(data, (uint256, uint256, uint256[]));
    amountOut = IMultiPathConverter(converter).convert(srcToken, amountIn, encoding, routes);
    if (amountOut < minOut) revert ErrorInsufficientOutput();
  }

  /// @dev Internal function to get curve ema price for fxUSD.
  /// @return price The value of ema price, multiplied by 1e18.
  function _getFxUSDEmaPrice() internal view returns (uint256 price) {
    address cachedCurvePool = curvePool; // gas saving
    address firstCoin = ICurveStableSwapNG(cachedCurvePool).coins(0);
    price = ICurveStableSwapNG(cachedCurvePool).price_oracle(0);
    if (firstCoin == fxUSD) {
      price = (PRECISION * PRECISION) / price;
    }
  }
}

// File: contracts/interfaces/IReservePool.sol

pragma solidity ^0.8.0;

interface IReservePool {
  /// @notice Emitted when the market request bonus.
  /// @param token The address of the token requested.
  /// @param receiver The address of token receiver.
  /// @param bonus The amount of bonus token.
  event RequestBonus(address indexed token, address indexed receiver, uint256 bonus);

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the balance of token in this contract.
  function getBalance(address token) external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Request bonus token from Reserve Pool.
  /// @param token The address of token to request.
  /// @param receiver The address recipient for the bonus token.
  /// @param bonus The amount of bonus token to send.
  function requestBonus(address token, address receiver, uint256 bonus) external;

  /// @notice Withdraw dust assets in this contract.
  /// @param token The address of token to withdraw.
  /// @param amount The amount of token to withdraw.
  /// @param recipient The address of token receiver.
  function withdrawFund(address token, uint256 amount, address recipient) external;
}

// File: contracts/interfaces/IRewardSplitter.sol

pragma solidity ^0.8.0;

interface IRewardSplitter {
  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Split token to different RebalancePool.
  /// @param token The address of token to split.
  function split(address token) external;

  /// @notice Deposit new rewards to this contract.
  ///
  /// @param token The address of reward token.
  /// @param amount The amount of new rewards.
  function depositReward(address token, uint256 amount) external;
}

// File: contracts/rate-provider/interfaces/IRateProvider.sol

pragma solidity ^0.8.0;

interface IRateProvider {
  /// @notice Return the exchange rate from wrapped token to underlying rate,
  /// multiplied by 1e18.
  function getRate() external view returns (uint256);
}

// File: contracts/core/PoolManager.sol

pragma solidity ^0.8.26;



















contract PoolManager is ProtocolFees, FlashLoans, AssetManagement, IPoolManager {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;
  using WordCodec for bytes32;

  /**********
   * Errors *
   **********/

  error ErrorCollateralExceedCapacity();

  error ErrorDebtExceedCapacity();

  error ErrorPoolNotRegistered();

  error ErrorInvalidPool();

  error ErrorCallerNotFxUSDSave();

  error ErrorRedeemExceedBalance();

  error ErrorInsufficientRedeemedCollateral();

  /*************
   * Constants *
   *************/

  /// @dev The precision for token rate.
  uint256 internal constant PRECISION = 1e18;

  /// @dev The precision for token rate.
  int256 internal constant PRECISION_I256 = 1e18;

  bytes32 private constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  /***********************
   * Immutable Variables *
   ***********************/

  /// @inheritdoc IPoolManager
  address public immutable fxUSD;

  /// @inheritdoc IPoolManager
  address public immutable fxBASE;

  /// @inheritdoc IPoolManager
  address public immutable pegKeeper;

  /***********
   * Structs *
   ***********/

  /// @dev The struct for pool information.
  /// @param collateralData The data for collateral.
  ///   ```text
  ///   * Field                     Bits    Index       Comments
  ///   * collateral capacity       85      0           The maximum allowed amount of collateral tokens.
  ///   * collateral balance        85      85          The amount of collateral tokens deposited.
  ///   * raw collateral balance    86      170         The amount of raw collateral tokens (without token rate) managed in pool.
  ///   ```
  /// @param debtData The data for debt.
  ///   ```text
  ///   * Field             Bits    Index       Comments
  ///   * debt capacity     96      0           The maximum allowed amount of debt tokens.
  ///   * debt balance      96      96          The amount of debt tokens borrowed.
  ///   * reserved          64      192         Reserved data.
  ///   ```
  struct PoolStruct {
    bytes32 collateralData;
    bytes32 debtData;
  }

  /// @dev The struct for token rate information.
  /// @param scalar The token scalar to reach 18 decimals.
  /// @param rateProvider The address of token rate provider.
  struct TokenRate {
    uint96 scalar;
    address rateProvider;
  }

  /// @dev Memory variables for liquidate or rebalance.
  /// @param stablePrice The USD price of stable token (with scalar).
  /// @param scalingFactor The scaling factor for collateral token.
  /// @param collateralToken The address of collateral token.
  /// @param rawColls The amount of raw collateral tokens liquidated or rebalanced, including bonus.
  /// @param bonusRawColls The amount of raw collateral tokens used as bonus.
  /// @param rawDebts The amount of raw debt tokens liquidated or rebalanced.
  struct LiquidateOrRebalanceMemoryVar {
    uint256 stablePrice;
    uint256 scalingFactor;
    address collateralToken;
    uint256 rawColls;
    uint256 bonusRawColls;
    uint256 rawDebts;
  }

  /*********************
   * Storage Variables *
   *********************/

  /// @dev The list of registered pools.
  EnumerableSet.AddressSet private pools;

  /// @notice Mapping to pool address to pool struct.
  mapping(address => PoolStruct) private poolInfo;

  /// @notice Mapping from pool address to rewards splitter.
  mapping(address => address) public rewardSplitter;

  /// @notice Mapping from token address to token rate struct.
  mapping(address => TokenRate) public tokenRates;

  /// @notice The threshold for permissioned liquidate or rebalance.
  uint256 public permissionedLiquidationThreshold;

  /*************
   * Modifiers *
   *************/

  modifier onlyRegisteredPool(address pool) {
    if (!pools.contains(pool)) revert ErrorPoolNotRegistered();
    _;
  }

  modifier onlyFxUSDSave() {
    if (_msgSender() != fxBASE) {
      // allow permissonless rebalance or liquidate when insufficient fxUSD/USDC in fxBASE.
      uint256 totalYieldToken = IFxUSDBasePool(fxBASE).totalYieldToken();
      uint256 totalStableToken = IFxUSDBasePool(fxBASE).totalStableToken();
      uint256 price = IFxUSDBasePool(fxBASE).getStableTokenPriceWithScale();
      if (totalYieldToken + (totalStableToken * price) / PRECISION >= permissionedLiquidationThreshold) {
        revert ErrorCallerNotFxUSDSave();
      }
    }
    _;
  }

  /***************
   * Constructor *
   ***************/

  constructor(address _fxUSD, address _fxBASE, address _pegKeeper) {
    fxUSD = _fxUSD;
    fxBASE = _fxBASE;
    pegKeeper = _pegKeeper;
  }

  function initialize(
    address admin,
    uint256 _expenseRatio,
    uint256 _harvesterRatio,
    uint256 _flashLoanFeeRatio,
    address _treasury,
    address _revenuePool,
    address _reservePool
  ) external initializer {
    __Context_init();
    __AccessControl_init();
    __ERC165_init();

    _grantRole(DEFAULT_ADMIN_ROLE, admin);

    __ProtocolFees_init(_expenseRatio, _harvesterRatio, _flashLoanFeeRatio, _treasury, _revenuePool, _reservePool);
    __FlashLoans_init();

    // default 10000 fxUSD
    _updateThreshold(10000 ether);
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the pool information.
  /// @param pool The address of pool to query.
  /// @return collateralCapacity The maximum allowed amount of collateral tokens.
  /// @return collateralBalance The amount of collateral tokens deposited.
  /// @return debtCapacity The maximum allowed amount of debt tokens.
  /// @return debtBalance The amount of debt tokens borrowed.
  function getPoolInfo(
    address pool
  )
    external
    view
    returns (uint256 collateralCapacity, uint256 collateralBalance, uint256 debtCapacity, uint256 debtBalance)
  {
    bytes32 data = poolInfo[pool].collateralData;
    collateralCapacity = data.decodeUint(0, 85);
    collateralBalance = data.decodeUint(85, 85);
    data = poolInfo[pool].debtData;
    debtCapacity = data.decodeUint(0, 96);
    debtBalance = data.decodeUint(96, 96);
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IPoolManager
  function operate(
    address pool,
    uint256 positionId,
    int256 newColl,
    int256 newDebt
  ) external onlyRegisteredPool(pool) onlyRole(OPERATOR_ROLE) nonReentrant returns (uint256) {
    address collateralToken = IPool(pool).collateralToken();
    uint256 scalingFactor = _getTokenScalingFactor(collateralToken);

    int256 newRawColl = newColl;
    if (newRawColl != type(int256).min) {
      newRawColl = _scaleUp(newRawColl, scalingFactor);
    }

    uint256 rawProtocolFees;
    // the `newRawColl` is the result without `protocolFees`
    (positionId, newRawColl, newDebt, rawProtocolFees) = IPool(pool).operate(
      positionId,
      newRawColl,
      newDebt,
      _msgSender()
    );

    newColl = _scaleDown(newRawColl, scalingFactor);
    uint256 protocolFees = _scaleDown(rawProtocolFees, scalingFactor);
    _accumulatePoolFee(pool, protocolFees);
    _changePoolDebts(pool, newDebt);
    if (newRawColl > 0) {
      _changePoolCollateral(pool, newColl, newRawColl);
      IERC20(collateralToken).safeTransferFrom(_msgSender(), address(this), uint256(newColl) + protocolFees);
    } else if (newRawColl < 0) {
      _changePoolCollateral(pool, newColl - int256(protocolFees), newRawColl - int256(rawProtocolFees));
      IERC20(collateralToken).safeTransfer(_msgSender(), uint256(-newColl));
    }

    if (newDebt > 0) {
      IFxUSDRegeneracy(fxUSD).mint(_msgSender(), uint256(newDebt));
    } else if (newDebt < 0) {
      IFxUSDRegeneracy(fxUSD).burn(_msgSender(), uint256(-newDebt));
    }

    emit Operate(pool, positionId, newColl, newDebt, protocolFees);

    return positionId;
  }

  /// @inheritdoc IPoolManager
  function redeem(
    address pool,
    uint256 debts,
    uint256 minColls
  ) external onlyRegisteredPool(pool) nonReentrant returns (uint256 colls) {
    if (debts > IERC20(fxUSD).balanceOf(_msgSender())) {
      revert ErrorRedeemExceedBalance();
    }

    uint256 rawColls = IPool(pool).redeem(debts);

    address collateralToken = IPool(pool).collateralToken();
    uint256 scalingFactor = _getTokenScalingFactor(collateralToken);
    colls = _scaleDown(rawColls, scalingFactor);

    _changePoolCollateral(pool, -int256(colls), -int256(rawColls));
    _changePoolDebts(pool, -int256(debts));

    uint256 protocolFees = (colls * getRedeemFeeRatio()) / FEE_PRECISION;
    _accumulatePoolFee(pool, protocolFees);
    colls -= protocolFees;
    if (colls < minColls) revert ErrorInsufficientRedeemedCollateral();

    IERC20(collateralToken).safeTransfer(_msgSender(), colls);
    IFxUSDRegeneracy(fxUSD).burn(_msgSender(), debts);

    emit Redeem(pool, colls, debts, protocolFees);
  }

  /// @inheritdoc IPoolManager
  function rebalance(
    address pool,
    address receiver,
    int16 tick,
    uint256 maxFxUSD,
    uint256 maxStable
  )
    external
    onlyRegisteredPool(pool)
    nonReentrant
    onlyFxUSDSave
    returns (uint256 colls, uint256 fxUSDUsed, uint256 stableUsed)
  {
    LiquidateOrRebalanceMemoryVar memory op = _beforeRebalanceOrLiquidate(pool);
    IPool.RebalanceResult memory result = IPool(pool).rebalance(tick, maxFxUSD + _scaleUp(maxStable, op.stablePrice));
    op.rawColls = result.rawColls + result.bonusRawColls;
    op.bonusRawColls = result.bonusRawColls;
    op.rawDebts = result.rawDebts;
    (colls, fxUSDUsed, stableUsed) = _afterRebalanceOrLiquidate(pool, maxFxUSD, op, receiver);

    emit RebalanceTick(pool, tick, colls, fxUSDUsed, stableUsed);
  }

  /// @inheritdoc IPoolManager
  function rebalance(
    address pool,
    address receiver,
    uint32 position,
    uint256 maxFxUSD,
    uint256 maxStable
  )
    external
    onlyRegisteredPool(pool)
    nonReentrant
    onlyFxUSDSave
    returns (uint256 colls, uint256 fxUSDUsed, uint256 stableUsed)
  {
    LiquidateOrRebalanceMemoryVar memory op = _beforeRebalanceOrLiquidate(pool);
    IPool.RebalanceResult memory result = IPool(pool).rebalance(
      position,
      maxFxUSD + _scaleUp(maxStable, op.stablePrice)
    );
    op.rawColls = result.rawColls + result.bonusRawColls;
    op.bonusRawColls = result.bonusRawColls;
    op.rawDebts = result.rawDebts;
    (colls, fxUSDUsed, stableUsed) = _afterRebalanceOrLiquidate(pool, maxFxUSD, op, receiver);

    emit RebalancePosition(pool, position, colls, fxUSDUsed, stableUsed);
  }

  /// @inheritdoc IPoolManager
  function liquidate(
    address pool,
    address receiver,
    uint32 position,
    uint256 maxFxUSD,
    uint256 maxStable
  )
    external
    onlyRegisteredPool(pool)
    nonReentrant
    onlyFxUSDSave
    returns (uint256 colls, uint256 fxUSDUsed, uint256 stableUsed)
  {
    LiquidateOrRebalanceMemoryVar memory op = _beforeRebalanceOrLiquidate(pool);
    {
      IPool.LiquidateResult memory result;
      uint256 reservedRawColls = IReservePool(reservePool).getBalance(op.collateralToken);
      reservedRawColls = _scaleUp(reservedRawColls, op.scalingFactor);
      result = IPool(pool).liquidate(position, maxFxUSD + _scaleUp(maxStable, op.stablePrice), reservedRawColls);
      op.rawColls = result.rawColls + result.bonusRawColls;
      op.bonusRawColls = result.bonusRawColls;
      op.rawDebts = result.rawDebts;

      // take bonus from reserve pool
      uint256 bonusFromReserve = result.bonusFromReserve;
      if (bonusFromReserve > 0) {
        bonusFromReserve = _scaleDown(result.bonusFromReserve, op.scalingFactor);
        IReservePool(reservePool).requestBonus(IPool(pool).collateralToken(), address(this), bonusFromReserve);

        // increase pool reserve first
        _changePoolCollateral(pool, int256(bonusFromReserve), int256(result.bonusFromReserve));
      }
    }

    (colls, fxUSDUsed, stableUsed) = _afterRebalanceOrLiquidate(pool, maxFxUSD, op, receiver);

    emit LiquidatePosition(pool, position, colls, fxUSDUsed, stableUsed);
  }

  /// @inheritdoc IPoolManager
  function harvest(
    address pool
  ) external onlyRegisteredPool(pool) nonReentrant returns (uint256 amountRewards, uint256 amountFunding) {
    address collateralToken = IPool(pool).collateralToken();
    uint256 scalingFactor = _getTokenScalingFactor(collateralToken);

    uint256 collateralRecorded;
    uint256 rawCollateralRecorded;
    {
      bytes32 data = poolInfo[pool].collateralData;
      collateralRecorded = data.decodeUint(85, 85);
      rawCollateralRecorded = data.decodeUint(170, 86);
    }
    uint256 performanceFee;
    uint256 harvestBounty;
    uint256 pendingRewards;
    // compute funding
    uint256 rawCollateral = IPool(pool).getTotalRawCollaterals();
    if (rawCollateralRecorded > rawCollateral) {
      unchecked {
        amountFunding = _scaleDown(rawCollateralRecorded - rawCollateral, scalingFactor);
        _changePoolCollateral(pool, -int256(amountFunding), -int256(rawCollateralRecorded - rawCollateral));

        performanceFee = (getFundingExpenseRatio() * amountFunding) / FEE_PRECISION;
        harvestBounty = (getHarvesterRatio() * amountFunding) / FEE_PRECISION;
        pendingRewards = amountFunding - harvestBounty - performanceFee;
      }
    }
    // compute rewards
    rawCollateral = _scaleUp(collateralRecorded, scalingFactor);
    if (rawCollateral > rawCollateralRecorded) {
      unchecked {
        amountRewards = _scaleDown(rawCollateral - rawCollateralRecorded, scalingFactor);
        _changePoolCollateral(pool, -int256(amountRewards), -int256(rawCollateral - rawCollateralRecorded));

        uint256 performanceFeeRewards = (getRewardsExpenseRatio() * amountRewards) / FEE_PRECISION;
        uint256 harvestBountyRewards = (getHarvesterRatio() * amountRewards) / FEE_PRECISION;
        pendingRewards += amountRewards - harvestBountyRewards - performanceFeeRewards;
        performanceFee += performanceFeeRewards;
        harvestBounty += harvestBountyRewards;
      }
    }

    // transfer performance fee to treasury
    if (performanceFee > 0) {
      IERC20(collateralToken).safeTransfer(treasury, performanceFee);
    }
    // transfer various fees to revenue pool
    _takeAccumulatedPoolFee(pool);
    // transfer harvest bounty
    if (harvestBounty > 0) {
      IERC20(collateralToken).safeTransfer(_msgSender(), harvestBounty);
    }
    // transfer rewards for fxBASE
    if (pendingRewards > 0) {
      address splitter = rewardSplitter[pool];
      IERC20(collateralToken).safeTransfer(splitter, pendingRewards);
      IRewardSplitter(splitter).split(collateralToken);
    }

    emit Harvest(_msgSender(), pool, amountRewards, amountFunding, performanceFee, harvestBounty);
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Register a new pool with reward splitter.
  /// @param pool The address of pool.
  /// @param splitter The address of reward splitter.
  function registerPool(
    address pool,
    address splitter,
    uint96 collateralCapacity,
    uint96 debtCapacity
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (fxUSD != IPool(pool).fxUSD()) revert ErrorInvalidPool();

    if (pools.add(pool)) {
      emit RegisterPool(pool);

      _updateRewardSplitter(pool, splitter);
      _updatePoolCapacity(pool, collateralCapacity, debtCapacity);
    }
  }

  /// @notice Update rate provider for the given token.
  /// @param token The address of the token.
  /// @param provider The address of corresponding rate provider.
  function updateRateProvider(address token, address provider) external onlyRole(DEFAULT_ADMIN_ROLE) {
    uint256 scale = 10 ** (18 - IERC20Metadata(token).decimals());
    tokenRates[token] = TokenRate(uint96(scale), provider);

    emit UpdateTokenRate(token, scale, provider);
  }

  /// @notice Update the address of reward splitter for the given pool.
  /// @param pool The address of the pool.
  /// @param newSplitter The address of reward splitter.
  function updateRewardSplitter(
    address pool,
    address newSplitter
  ) external onlyRole(DEFAULT_ADMIN_ROLE) onlyRegisteredPool(pool) {
    _updateRewardSplitter(pool, newSplitter);
  }

  /// @notice Update the pool capacity.
  /// @param pool The address of fx pool.
  /// @param collateralCapacity The capacity for collateral token.
  /// @param debtCapacity The capacity for debt token.
  function updatePoolCapacity(
    address pool,
    uint96 collateralCapacity,
    uint96 debtCapacity
  ) external onlyRole(DEFAULT_ADMIN_ROLE) onlyRegisteredPool(pool) {
    _updatePoolCapacity(pool, collateralCapacity, debtCapacity);
  }

  /// @notice Update threshold for permissionless liquidation.
  /// @param newThreshold The value of new threshold.
  function updateThreshold(uint256 newThreshold) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateThreshold(newThreshold);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to update the address of reward splitter for the given pool.
  /// @param pool The address of the pool.
  /// @param newSplitter The address of reward splitter.
  function _updateRewardSplitter(address pool, address newSplitter) internal {
    address oldSplitter = rewardSplitter[pool];
    rewardSplitter[pool] = newSplitter;

    emit UpdateRewardSplitter(pool, oldSplitter, newSplitter);
  }

  /// @dev Internal function to update the pool capacity.
  /// @param pool The address of fx pool.
  /// @param collateralCapacity The capacity for collateral token.
  /// @param debtCapacity The capacity for debt token.
  function _updatePoolCapacity(address pool, uint96 collateralCapacity, uint96 debtCapacity) internal {
    poolInfo[pool].collateralData = poolInfo[pool].collateralData.insertUint(collateralCapacity, 0, 96);
    poolInfo[pool].debtData = poolInfo[pool].debtData.insertUint(debtCapacity, 0, 96);

    emit UpdatePoolCapacity(pool, collateralCapacity, debtCapacity);
  }

  /// @dev Internal function to update threshold for permissionless liquidation.
  /// @param newThreshold The value of new threshold.
  function _updateThreshold(uint256 newThreshold) internal {
    uint256 oldThreshold = permissionedLiquidationThreshold;
    permissionedLiquidationThreshold = newThreshold;

    emit UpdatePermissionedLiquidationThreshold(oldThreshold, newThreshold);
  }

  /// @dev Internal function to scaler up for `uint256`.
  function _scaleUp(uint256 value, uint256 scale) internal pure returns (uint256) {
    return (value * scale) / PRECISION;
  }

  /// @dev Internal function to scaler up for `int256`.
  function _scaleUp(int256 value, uint256 scale) internal pure returns (int256) {
    return (value * int256(scale)) / PRECISION_I256;
  }

  /// @dev Internal function to scaler down for `uint256`, rounding down.
  function _scaleDown(uint256 value, uint256 scale) internal pure returns (uint256) {
    return (value * PRECISION) / scale;
  }

  /// @dev Internal function to scaler down for `uint256`, rounding up.
  function _scaleDownRoundingUp(uint256 value, uint256 scale) internal pure returns (uint256) {
    return (value * PRECISION + scale - 1) / scale;
  }

  /// @dev Internal function to scaler down for `int256`.
  function _scaleDown(int256 value, uint256 scale) internal pure returns (int256) {
    return (value * PRECISION_I256) / int256(scale);
  }

  /// @dev Internal function to prepare variables before rebalance or liquidate.
  /// @param pool The address of pool to liquidate or rebalance.
  function _beforeRebalanceOrLiquidate(address pool) internal view returns (LiquidateOrRebalanceMemoryVar memory op) {
    op.stablePrice = IFxUSDBasePool(fxBASE).getStableTokenPriceWithScale();
    op.collateralToken = IPool(pool).collateralToken();
    op.scalingFactor = _getTokenScalingFactor(op.collateralToken);
  }

  /// @dev Internal function to do actions after rebalance or liquidate.
  /// @param pool The address of pool to liquidate or rebalance.
  /// @param maxFxUSD The maximum amount of fxUSD can be used.
  /// @param op The memory helper variable.
  /// @param receiver The address collateral token receiver.
  /// @return colls The actual amount of collateral token rebalanced or liquidated.
  /// @return fxUSDUsed The amount of fxUSD used.
  /// @return stableUsed The amount of stable token (a.k.a USDC) used.
  function _afterRebalanceOrLiquidate(
    address pool,
    uint256 maxFxUSD,
    LiquidateOrRebalanceMemoryVar memory op,
    address receiver
  ) internal returns (uint256 colls, uint256 fxUSDUsed, uint256 stableUsed) {
    colls = _scaleDown(op.rawColls, op.scalingFactor);
    _changePoolCollateral(pool, -int256(colls), -int256(op.rawColls));
    _changePoolDebts(pool, -int256(op.rawDebts));

    // burn fxUSD or transfer USDC
    fxUSDUsed = op.rawDebts;
    if (fxUSDUsed > maxFxUSD) {
      // rounding up here
      stableUsed = _scaleDownRoundingUp(fxUSDUsed - maxFxUSD, op.stablePrice);
      fxUSDUsed = maxFxUSD;
    }
    if (fxUSDUsed > 0) {
      IFxUSDRegeneracy(fxUSD).burn(_msgSender(), fxUSDUsed);
    }
    if (stableUsed > 0) {
      IERC20(IFxUSDBasePool(fxBASE).stableToken()).safeTransferFrom(_msgSender(), fxUSD, stableUsed);
      IFxUSDRegeneracy(fxUSD).onRebalanceWithStable(stableUsed, op.rawDebts - maxFxUSD);
    }

    // transfer collateral
    uint256 protocolRevenue = (_scaleDown(op.bonusRawColls, op.scalingFactor) * getLiquidationExpenseRatio()) /
      FEE_PRECISION;
    _accumulatePoolFee(pool, protocolRevenue);
    unchecked {
      colls -= protocolRevenue;
    }
    IERC20(op.collateralToken).safeTransfer(receiver, colls);
  }

  /// @dev Internal function to update collateral balance.
  function _changePoolCollateral(address pool, int256 delta, int256 rawDelta) internal {
    bytes32 data = poolInfo[pool].collateralData;
    uint256 capacity = data.decodeUint(0, 85);
    uint256 balance = uint256(int256(data.decodeUint(85, 85)) + delta);
    if (balance > capacity) revert ErrorCollateralExceedCapacity();
    data = data.insertUint(balance, 85, 85);
    balance = uint256(int256(data.decodeUint(170, 86)) + rawDelta);
    poolInfo[pool].collateralData = data.insertUint(balance, 170, 86);
  }

  /// @dev Internal function to update debt balance.
  function _changePoolDebts(address pool, int256 delta) internal {
    bytes32 data = poolInfo[pool].debtData;
    uint256 capacity = data.decodeUint(0, 96);
    uint256 balance = uint256(int256(data.decodeUint(96, 96)) + delta);
    if (balance > capacity) revert ErrorDebtExceedCapacity();
    poolInfo[pool].debtData = data.insertUint(balance, 96, 96);
  }

  /// @dev Internal function to get token scaling factor.
  function _getTokenScalingFactor(address token) internal view returns (uint256 value) {
    TokenRate memory rate = tokenRates[token];
    value = rate.scalar;
    unchecked {
      if (rate.rateProvider != address(0)) {
        value *= IRateProvider(rate.rateProvider).getRate();
      } else {
        value *= PRECISION;
      }
    }
  }
}

// File: contracts/core/ReservePool.sol

pragma solidity ^0.8.25;
pragma abicoder v2;









contract ReservePool is AccessControl, IReservePool {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  /**********
   * Errors *
   **********/

  /// @dev Thrown the bonus ratio is too large.
  error ErrorRatioTooLarge();

  /// @dev Thrown when add an already added rebalance pool.
  error ErrorRebalancePoolAlreadyAdded();

  /// @dev Thrown when remove an unknown rebalance pool.
  error ErrorRebalancePoolNotAdded();

  /// @dev Thrown when the caller is not `FxOmniVault`.
  error ErrorCallerNotPoolManager();

  /*************
   * Constants *
   *************/

  /// @dev The address of `PoolManager` contract.
  address public immutable poolManager;

  /*************
   * Variables *
   *************/

  /***************
   * Constructor *
   ***************/

  constructor(address admin, address _poolManager) {
    poolManager = _poolManager;

    _grantRole(DEFAULT_ADMIN_ROLE, admin);
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IReservePool
  function getBalance(address token) external view returns (uint256) {
    return _getBalance(token);
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  // solhint-disable-next-line no-empty-blocks
  receive() external payable {}

  /// @inheritdoc IReservePool
  function requestBonus(address _token, address _recipient, uint256 _bonus) external {
    if (_msgSender() != poolManager) revert ErrorCallerNotPoolManager();

    uint256 _balance = _getBalance(_token);

    if (_bonus > _balance) {
      _bonus = _balance;
    }
    if (_bonus > 0) {
      _transferToken(_token, _recipient, _bonus);

      emit RequestBonus(_token, _recipient, _bonus);
    }
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Withdraw dust assets in this contract.
  /// @param _token The address of token to withdraw.
  /// @param _recipient The address of token receiver.
  function withdrawFund(address _token, uint256 amount, address _recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _transferToken(_token, _recipient, amount);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to return the balance of the token in this contract.
  /// @param _token The address of token to query.
  function _getBalance(address _token) internal view returns (uint256) {
    if (_token == address(0)) {
      return address(this).balance;
    } else {
      return IERC20(_token).balanceOf(address(this));
    }
  }

  /// @dev Internal function to transfer ETH or ERC20 tokens to some `_receiver`.
  ///
  /// @param _token The address of token to transfer, user `_token=address(0)` if transfer ETH.
  /// @param _receiver The address of token receiver.
  /// @param _amount The amount of token to transfer.
  function _transferToken(address _token, address _receiver, uint256 _amount) internal {
    if (_token == address(0)) {
      Address.sendValue(payable(_receiver), _amount);
    } else {
      IERC20(_token).safeTransfer(_receiver, _amount);
    }
  }
}

// File: contracts/interfaces/Aave/IAaveV3Pool.sol

pragma solidity ^0.8.0;

interface IAaveV3Pool {
  struct ReserveConfigurationMap {
    //bit 0-15: LTV
    //bit 16-31: Liq. threshold
    //bit 32-47: Liq. bonus
    //bit 48-55: Decimals
    //bit 56: reserve is active
    //bit 57: reserve is frozen
    //bit 58: borrowing is enabled
    //bit 59: DEPRECATED: stable rate borrowing enabled
    //bit 60: asset is paused
    //bit 61: borrowing in isolation mode is enabled
    //bit 62: siloed borrowing enabled
    //bit 63: flashloaning enabled
    //bit 64-79: reserve factor
    //bit 80-115: borrow cap in whole tokens, borrowCap == 0 => no cap
    //bit 116-151: supply cap in whole tokens, supplyCap == 0 => no cap
    //bit 152-167: liquidation protocol fee
    //bit 168-175: DEPRECATED: eMode category
    //bit 176-211: unbacked mint cap in whole tokens, unbackedMintCap == 0 => minting disabled
    //bit 212-251: debt ceiling for isolation mode with (ReserveConfiguration::DEBT_CEILING_DECIMALS) decimals
    //bit 252: virtual accounting is enabled for the reserve
    //bit 253-255 unused

    uint256 data;
  }

  /**
   * This exists specifically to maintain the `getReserveData()` interface, since the new, internal
   * `ReserveData` struct includes the reserve's `virtualUnderlyingBalance`.
   */
  struct ReserveDataLegacy {
    //stores the reserve configuration
    ReserveConfigurationMap configuration;
    //the liquidity index. Expressed in ray
    uint128 liquidityIndex;
    //the current supply rate. Expressed in ray
    uint128 currentLiquidityRate;
    //variable borrow index. Expressed in ray
    uint128 variableBorrowIndex;
    //the current variable borrow rate. Expressed in ray
    uint128 currentVariableBorrowRate;
    // DEPRECATED on v3.2.0
    uint128 currentStableBorrowRate;
    //timestamp of last update
    uint40 lastUpdateTimestamp;
    //the id of the reserve. Represents the position in the list of the active reserves
    uint16 id;
    //aToken address
    address aTokenAddress;
    // DEPRECATED on v3.2.0
    address stableDebtTokenAddress;
    //variableDebtToken address
    address variableDebtTokenAddress;
    //address of the interest rate strategy
    address interestRateStrategyAddress;
    //the current treasury balance, scaled
    uint128 accruedToTreasury;
    //the outstanding unbacked aTokens minted through the bridging feature
    uint128 unbacked;
    //the outstanding debt borrowed against this asset in isolation mode
    uint128 isolationModeTotalDebt;
  }

  /**
   * @notice Returns the state and configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state and configuration data of the reserve
   */
  function getReserveData(address asset) external view returns (ReserveDataLegacy memory);

  /**
   * @notice Returns the normalized variable debt per unit of asset
   * @dev WARNING: This function is intended to be used primarily by the protocol itself to get a
   * "dynamic" variable index based on time, current stored index and virtual rate at the current
   * moment (approx. a borrower would get if opening a position). This means that is always used in
   * combination with variable debt supply/balances.
   * If using this function externally, consider that is possible to have an increasing normalized
   * variable debt that is not equivalent to how the variable debt index would be updated in storage
   * (e.g. only updates with non-zero variable debt supply)
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve normalized variable debt
   */
  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);
}

// File: contracts/interfaces/IAaveFundingPool.sol

pragma solidity ^0.8.0;



interface IAaveFundingPool is IPool {
  /**********
   * Events *
   **********/

  /// @notice Emitted when interest snapshot is taken.
  /// @param borrowIndex The borrow index, multiplied by 1e27.
  /// @param timestamp The timestamp when this snapshot is taken.
  event SnapshotAaveBorrowIndex(uint256 borrowIndex, uint256 timestamp);

  /// @notice Emitted when the open fee ratio related parameters are updated.
  /// @param ratio The open ratio value, multiplied by 1e9.
  /// @param step The open ratio step value, multiplied by 1e18.
  event UpdateOpenRatio(uint256 ratio, uint256 step);

  /// @notice Emitted when the open fee ratio is updated.
  /// @param oldRatio The value of previous close fee ratio, multiplied by 1e9.
  /// @param newRatio The value of current close fee ratio, multiplied by 1e9.
  event UpdateCloseFeeRatio(uint256 oldRatio, uint256 newRatio);

  /// @notice Emitted when the funding fee ratio is updated.
  /// @param oldRatio The value of previous funding fee ratio, multiplied by 1e9.
  /// @param newRatio The value of current funding fee ratio, multiplied by 1e9.
  event UpdateFundingRatio(uint256 oldRatio, uint256 newRatio);

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the value of funding ratio, multiplied by 1e9.
  function getFundingRatio() external view returns (uint256);
}

// File: contracts/price-oracle/interfaces/IPriceOracle.sol

pragma solidity ^0.8.0;

interface IPriceOracle {
  /**********
   * Events *
   **********/

  /// @notice Emitted when the value of maximum price deviation is updated.
  /// @param oldValue The value of the previous maximum price deviation.
  /// @param newValue The value of the current maximum price deviation.
  event UpdateMaxPriceDeviation(uint256 oldValue, uint256 newValue);

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the oracle price with 18 decimal places.
  /// @return anchorPrice The anchor price for this asset, multiplied by 1e18. It should be hard to manipulate,
  ///         like time-weighted average price or chainlink spot price.
  /// @return minPrice The minimum oracle price among all available price sources (including twap), multiplied by 1e18.
  /// @return maxPrice The maximum oracle price among all available price sources (including twap), multiplied by 1e18.
  function getPrice() external view returns (uint256 anchorPrice, uint256 minPrice, uint256 maxPrice);
}

// File: contracts/libraries/BitMath.sol

pragma solidity ^0.8.0;

/// @title BitMath
/// @dev This library provides functionality for computing bit properties of an unsigned integer
///
/// copy from: https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/BitMath.sol
library BitMath {
    /// @notice Returns the index of the most significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    /// @param x the value for which to compute the most significant bit, must be greater than 0
    /// @return r the index of the most significant bit
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }

    /// @notice Returns the index of the least significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    /// @param x the value for which to compute the least significant bit, must be greater than 0
    /// @return r the index of the least significant bit
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        r = 255;
        if (x & type(uint128).max > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & type(uint64).max > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & type(uint32).max > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & type(uint16).max > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & type(uint8).max > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}

// File: contracts/libraries/TickBitmap.sol

pragma solidity ^0.8.26;



library TickBitmap {
  function position(int16 tick) private pure returns (int8 wordPos, uint8 bitPos) {
    assembly {
      wordPos := shr(8, tick)
      bitPos := and(tick, 255)
    }
  }

  function flipTick(mapping(int8 => uint256) storage self, int16 tick) internal {
    (int8 wordPos, uint8 bitPos) = position(tick);
    uint256 mask = 1 << bitPos;
    self[wordPos] ^= mask;
  }

  function isBitSet(mapping(int8 => uint256) storage self, int16 tick) internal view returns (bool) {
    (int8 wordPos, uint8 bitPos) = position(tick);
    uint256 mask = 1 << bitPos;
    return (self[wordPos] & mask) > 0;
  }

  /// @notice Returns the next initialized tick contained in the same word (or adjacent word) as the tick that is
  /// to the left (less than or equal to).
  function nextDebtPositionWithinOneWord(
    mapping(int8 => uint256) storage self,
    int16 tick
  ) internal view returns (int16 next, bool hasDebt) {
    unchecked {
      // start from the word of the next tick, since the current tick state doesn't matter
      (int8 wordPos, uint8 bitPos) = position(tick);
      // all the 1s at or to the right of the current bitPos
      uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
      uint256 masked = self[wordPos] & mask;

      // if there are no initialized ticks to the left of the current tick, return leftmost in the word
      hasDebt = masked != 0;
      // overflow/underflow is possible, but prevented externally by limiting tick
      next = hasDebt
        ? (tick - int16(uint16(bitPos - BitMath.mostSignificantBit(masked))))
        : (tick - int16(uint16(bitPos)));
    }
  }
}

// File: contracts/libraries/TickMath.sol

pragma solidity ^0.8.26;

/// @title library that calculates number "tick" and "ratioX96" from this: ratioX96 = (1.0015^tick) * 2^96
/// @notice this library is used in Fluid Vault protocol for optimiziation.
/// @dev "tick" supports between -32767 and 32767. "ratioX96" supports between 37075072 and 169307877264527972847801929085841449095838922544595
///
/// @dev Copy from https://github.com/Instadapp/fluid-contracts-public/blob/main/contracts/libraries/tickMath.sol
library TickMath {
    /// The minimum tick that can be passed in getRatioAtTick. 1.0015**-32767
    int24 internal constant MIN_TICK = -32767;
    /// The maximum tick that can be passed in getRatioAtTick. 1.0015**32767
    int24 internal constant MAX_TICK = 32767;

    uint256 internal constant FACTOR00 = 0x100000000000000000000000000000000;
    uint256 internal constant FACTOR01 = 0xff9dd7de423466c20352b1246ce4856f; // 2^128/1.0015**1 = 339772707859149738855091969477551883631
    uint256 internal constant FACTOR02 = 0xff3bd55f4488ad277531fa1c725a66d0; // 2^128/1.0015**2 = 339263812140938331358054887146831636176
    uint256 internal constant FACTOR03 = 0xfe78410fd6498b73cb96a6917f853259; // 2^128/1.0015**4 = 338248306163758188337119769319392490073
    uint256 internal constant FACTOR04 = 0xfcf2d9987c9be178ad5bfeffaa123273; // 2^128/1.0015**8 = 336226404141693512316971918999264834163
    uint256 internal constant FACTOR05 = 0xf9ef02c4529258b057769680fc6601b3; // 2^128/1.0015**16 = 332218786018727629051611634067491389875
    uint256 internal constant FACTOR06 = 0xf402d288133a85a17784a411f7aba082; // 2^128/1.0015**32 = 324346285652234375371948336458280706178
    uint256 internal constant FACTOR07 = 0xe895615b5beb6386553757b0352bda90; // 2^128/1.0015**64 = 309156521885964218294057947947195947664
    uint256 internal constant FACTOR08 = 0xd34f17a00ffa00a8309940a15930391a; // 2^128/1.0015**128 = 280877777739312896540849703637713172762 
    uint256 internal constant FACTOR09 = 0xae6b7961714e20548d88ea5123f9a0ff; // 2^128/1.0015**256 = 231843708922198649176471782639349113087
    uint256 internal constant FACTOR10 = 0x76d6461f27082d74e0feed3b388c0ca1; // 2^128/1.0015**512 = 157961477267171621126394973980180876449
    uint256 internal constant FACTOR11 = 0x372a3bfe0745d8b6b19d985d9a8b85bb; // 2^128/1.0015**1024 = 73326833024599564193373530205717235131
    uint256 internal constant FACTOR12 = 0x0be32cbee48979763cf7247dd7bb539d; // 2^128/1.0015**2048 = 15801066890623697521348224657638773661
    uint256 internal constant FACTOR13 = 0x8d4f70c9ff4924dac37612d1e2921e;   // 2^128/1.0015**4096 = 733725103481409245883800626999235102
    uint256 internal constant FACTOR14 = 0x4e009ae5519380809a02ca7aec77;     // 2^128/1.0015**8192 = 1582075887005588088019997442108535
    uint256 internal constant FACTOR15 = 0x17c45e641b6e95dee056ff10;         // 2^128/1.0015**16384 = 7355550435635883087458926352

    /// The minimum value that can be returned from getRatioAtTick. Equivalent to getRatioAtTick(MIN_TICK). ~ Equivalent to `(1 << 96) * (1.0015**-32767)`
    uint256 internal constant MIN_RATIOX96 = 37075072;
    /// The maximum value that can be returned from getRatioAtTick. Equivalent to getRatioAtTick(MAX_TICK).
    /// ~ Equivalent to `(1 << 96) * (1.0015**32767)`, rounding etc. leading to minor difference
    uint256 internal constant MAX_RATIOX96 = 169307877264527972847801929085841449095838922544595;

    uint256 internal constant ZERO_TICK_SCALED_RATIO = 0x1000000000000000000000000; // 1 << 96 // 79228162514264337593543950336
    uint256 internal constant _1E26 = 1e26;

    /// @notice ratioX96 = (1.0015^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return ratioX96 ratio = (debt amount/collateral amount)
    function getRatioAtTick(int tick) internal pure returns (uint256 ratioX96) {
        assembly {
            let absTick_ := sub(xor(tick, sar(255, tick)), sar(255, tick))

            if gt(absTick_, MAX_TICK) {
                revert(0, 0)
            }
            let factor_ := FACTOR00
            if and(absTick_, 0x1) {
                factor_ := FACTOR01
            }
            if and(absTick_, 0x2) {
                factor_ := shr(128, mul(factor_, FACTOR02))
            }
            if and(absTick_, 0x4) {
                factor_ := shr(128, mul(factor_, FACTOR03))
            }
            if and(absTick_, 0x8) {
                factor_ := shr(128, mul(factor_, FACTOR04))
            }
            if and(absTick_, 0x10) {
                factor_ := shr(128, mul(factor_, FACTOR05))
            }
            if and(absTick_, 0x20) {
                factor_ := shr(128, mul(factor_, FACTOR06))
            }
            if and(absTick_, 0x40) {
                factor_ := shr(128, mul(factor_, FACTOR07))
            }
            if and(absTick_, 0x80) {
                factor_ := shr(128, mul(factor_, FACTOR08))
            }
            if and(absTick_, 0x100) {
                factor_ := shr(128, mul(factor_, FACTOR09))
            }
            if and(absTick_, 0x200) {
                factor_ := shr(128, mul(factor_, FACTOR10))
            }
            if and(absTick_, 0x400) {
                factor_ := shr(128, mul(factor_, FACTOR11))
            }
            if and(absTick_, 0x800) {
                factor_ := shr(128, mul(factor_, FACTOR12))
            }
            if and(absTick_, 0x1000) {
                factor_ := shr(128, mul(factor_, FACTOR13))
            }
            if and(absTick_, 0x2000) {
                factor_ := shr(128, mul(factor_, FACTOR14))
            }
            if and(absTick_, 0x4000) {
                factor_ := shr(128, mul(factor_, FACTOR15))
            }

            let precision_ := 0
            if iszero(and(tick, 0x8000000000000000000000000000000000000000000000000000000000000000)) {
                factor_ := div(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, factor_)
                // we round up in the division so getTickAtRatio of the output price is always consistent
                if mod(factor_, 0x100000000) {
                    precision_ := 1
                }
            }
            ratioX96 := add(shr(32, factor_), precision_)
        }
    }

    /// @notice ratioX96 = (1.0015^tick) * 2^96
    /// @dev Throws if ratioX96 > max ratio || ratioX96 < min ratio
    /// @param ratioX96 The input ratio; ratio = (debt amount/collateral amount)
    /// @return tick The output tick for the above formula. Returns in round down form. if tick is 123.23 then 123, if tick is -123.23 then returns -124
    /// @return perfectRatioX96 perfect ratio for the above tick
    function getTickAtRatio(uint256 ratioX96) internal pure returns (int tick, uint perfectRatioX96) {
        assembly {
            if or(gt(ratioX96, MAX_RATIOX96), lt(ratioX96, MIN_RATIOX96)) {
                revert(0, 0)
            }

            let cond := lt(ratioX96, ZERO_TICK_SCALED_RATIO)
            let factor_

            if iszero(cond) {
                // if ratioX96 >= ZERO_TICK_SCALED_RATIO
                factor_ := div(mul(ratioX96, _1E26), ZERO_TICK_SCALED_RATIO)
            }
            if cond {
                // ratioX96 < ZERO_TICK_SCALED_RATIO
                factor_ := div(mul(ZERO_TICK_SCALED_RATIO, _1E26), ratioX96)
            }

            // put in https://www.wolframalpha.com/ whole equation: (1.0015^tick) * 2^96 * 10^26 / 79228162514264337593543950336

            // for tick = 16384
            // ratioX96 = (1.0015^16384) * 2^96 = 3665252098134783297721995888537077351735
            // 3665252098134783297721995888537077351735 * 10^26 / 79228162514264337593543950336 =
            // 4626198540796508716348404308345255985.06131964639489434655721
            if iszero(lt(factor_, 4626198540796508716348404308345255985)) {
                tick := or(tick, 0x4000)
                factor_ := div(mul(factor_, _1E26), 4626198540796508716348404308345255985)
            }
            // for tick = 8192
            // ratioX96 = (1.0015^8192) * 2^96 = 17040868196391020479062776466509865
            // 17040868196391020479062776466509865 * 10^26 / 79228162514264337593543950336 =
            // 21508599537851153911767490449162.3037648642153898377655505172
            if iszero(lt(factor_, 21508599537851153911767490449162)) {
                tick := or(tick, 0x2000)
                factor_ := div(mul(factor_, _1E26), 21508599537851153911767490449162)
            }
            // for tick = 4096
            // ratioX96 = (1.0015^4096) * 2^96 = 36743933851015821532611831851150
            // 36743933851015821532611831851150 * 10^26 / 79228162514264337593543950336 =
            // 46377364670549310883002866648.9777607649742626173648716941385
            if iszero(lt(factor_, 46377364670549310883002866649)) {
                tick := or(tick, 0x1000)
                factor_ := div(mul(factor_, _1E26), 46377364670549310883002866649)
            }
            // for tick = 2048
            // ratioX96 = (1.0015^2048) * 2^96 = 1706210527034005899209104452335
            // 1706210527034005899209104452335 * 10^26 / 79228162514264337593543950336 =
            // 2153540449365864845468344760.06357108484096046743300420319322
            if iszero(lt(factor_, 2153540449365864845468344760)) {
                tick := or(tick, 0x800)
                factor_ := div(mul(factor_, _1E26), 2153540449365864845468344760)
            }
            // for tick = 1024
            // ratioX96 = (1.0015^1024) * 2^96 = 367668226692760093024536487236
            // 367668226692760093024536487236 * 10^26 / 79228162514264337593543950336 =
            // 464062544207767844008185024.950588990554136265212906454481127
            if iszero(lt(factor_, 464062544207767844008185025)) {
                tick := or(tick, 0x400)
                factor_ := div(mul(factor_, _1E26), 464062544207767844008185025)
            }
            // for tick = 512
            // ratioX96 = (1.0015^512) * 2^96 = 170674186729409605620119663668
            // 170674186729409605620119663668 * 10^26 / 79228162514264337593543950336 =
            // 215421109505955298802281577.031879604792139232258508172947569
            if iszero(lt(factor_, 215421109505955298802281577)) {
                tick := or(tick, 0x200)
                factor_ := div(mul(factor_, _1E26), 215421109505955298802281577)
            }
            // for tick = 256
            // ratioX96 = (1.0015^256) * 2^96 = 116285004205991934861656513301
            // 116285004205991934861656513301 * 10^26 / 79228162514264337593543950336 =
            // 146772309890508740607270614.667650899656438875541505058062410
            if iszero(lt(factor_, 146772309890508740607270615)) {
                tick := or(tick, 0x100)
                factor_ := div(mul(factor_, _1E26), 146772309890508740607270615)
            }
            // for tick = 128
            // ratioX96 = (1.0015^128) * 2^96 = 95984619659632141743747099590
            // 95984619659632141743747099590 * 10^26 / 79228162514264337593543950336 =
            // 121149622323187099817270416.157248837742741760456796835775887
            if iszero(lt(factor_, 121149622323187099817270416)) {
                tick := or(tick, 0x80)
                factor_ := div(mul(factor_, _1E26), 121149622323187099817270416)
            }
            // for tick = 64
            // ratioX96 = (1.0015^64) * 2^96 = 87204845308406958006717891124
            // 87204845308406958006717891124 * 10^26 / 79228162514264337593543950336 =
            // 110067989135437147685980801.568068573422377364214113968609839
            if iszero(lt(factor_, 110067989135437147685980801)) {
                tick := or(tick, 0x40)
                factor_ := div(mul(factor_, _1E26), 110067989135437147685980801)
            }
            // for tick = 32
            // ratioX96 = (1.0015^32) * 2^96 = 83120873769022354029916374475
            // 83120873769022354029916374475 * 10^26 / 79228162514264337593543950336 =
            // 104913292358707887270979599.831816586773651266562785765558183
            if iszero(lt(factor_, 104913292358707887270979600)) {
                tick := or(tick, 0x20)
                factor_ := div(mul(factor_, _1E26), 104913292358707887270979600)
            }
            // for tick = 16
            // ratioX96 = (1.0015^16) * 2^96 = 81151180492336368327184716176
            // 81151180492336368327184716176 * 10^26 / 79228162514264337593543950336 =
            // 102427189924701091191840927.762844039579442328381455567932128
            if iszero(lt(factor_, 102427189924701091191840928)) {
                tick := or(tick, 0x10)
                factor_ := div(mul(factor_, _1E26), 102427189924701091191840928)
            }
            // for tick = 8
            // ratioX96 = (1.0015^8) * 2^96 = 80183906840906820640659903620
            // 80183906840906820640659903620 * 10^26 / 79228162514264337593543950336 =
            // 101206318935480056907421312.890625
            if iszero(lt(factor_, 101206318935480056907421313)) {
                tick := or(tick, 0x8)
                factor_ := div(mul(factor_, _1E26), 101206318935480056907421313)
            }
            // for tick = 4
            // ratioX96 = (1.0015^4) * 2^96 = 79704602139525152702959747603
            // 79704602139525152702959747603 * 10^26 / 79228162514264337593543950336 =
            // 100601351350506250000000000
            if iszero(lt(factor_, 100601351350506250000000000)) {
                tick := or(tick, 0x4)
                factor_ := div(mul(factor_, _1E26), 100601351350506250000000000)
            }
            // for tick = 2
            // ratioX96 = (1.0015^2) * 2^96 = 79466025265172787701084167660
            // 79466025265172787701084167660 * 10^26 / 79228162514264337593543950336 =
            // 100300225000000000000000000
            if iszero(lt(factor_, 100300225000000000000000000)) {
                tick := or(tick, 0x2)
                factor_ := div(mul(factor_, _1E26), 100300225000000000000000000)
            }
            // for tick = 1
            // ratioX96 = (1.0015^1) * 2^96 = 79347004758035734099934266261
            // 79347004758035734099934266261 * 10^26 / 79228162514264337593543950336 =
            // 100150000000000000000000000
            if iszero(lt(factor_, 100150000000000000000000000)) {
                tick := or(tick, 0x1)
                factor_ := div(mul(factor_, _1E26), 100150000000000000000000000)
            }
            if iszero(cond) {
                // if ratioX96 >= ZERO_TICK_SCALED_RATIO
                perfectRatioX96 := div(mul(ratioX96, _1E26), factor_)
            }
            if cond {
                // ratioX96 < ZERO_TICK_SCALED_RATIO
                tick := not(tick)
                perfectRatioX96 := div(mul(ratioX96, factor_), 100150000000000000000000000)
            }
            // perfect ratio should always be <= ratioX96
            // not sure if it can ever be bigger but better to have extra checks
            if gt(perfectRatioX96, ratioX96) {
                revert(0, 0)
            }
        }
    }
}

// File: contracts/core/pool/PoolConstant.sol

pragma solidity ^0.8.26;



abstract contract PoolConstant is IPool {
  /*************
   * Constants *
   *************/

  /// @dev The value of minimum collateral.
  int256 internal constant MIN_COLLATERAL = 1e9;

  /// @dev The value of minimum debts.
  int256 internal constant MIN_DEBT = 1e9;

  /// @dev The precision used for various calculation.
  uint256 internal constant PRECISION = 1e18;

  /// @dev The precision used for fee ratio calculation.
  uint256 internal constant FEE_PRECISION = 1e9;

  /// @dev bit operation related constants
  uint256 internal constant E60 = 2 ** 60; // 2^60
  uint256 internal constant E96 = 2 ** 96; // 2^96

  uint256 internal constant X60 = 0xfffffffffffffff; // 2^60 - 1
  uint256 internal constant X96 = 0xffffffffffffffffffffffff; // 2^96 - 1

  /***********************
   * Immutable Variables *
   ***********************/

  /// @inheritdoc IPool
  address public immutable fxUSD;

  /// @inheritdoc IPool
  address public immutable poolManager;

  /// @inheritdoc IPool
  address public immutable pegKeeper;
}

// File: contracts/core/pool/PoolErrors.sol

pragma solidity ^0.8.26;

abstract contract PoolErrors {
  /**********
   * Errors *
   **********/
  
  /// @dev Thrown when the given address is zero.
  error ErrorZeroAddress();

  /// @dev Thrown when the given value exceeds maximum value.
  error ErrorValueTooLarge();
  
  /// @dev Thrown when the caller is not pool manager.
  error ErrorCallerNotPoolManager();
  
  /// @dev Thrown when the debt amount is too small.
  error ErrorDebtTooSmall();

  /// @dev Thrown when the collateral amount is too small.
  error ErrorCollateralTooSmall();
  
  /// @dev Thrown when both collateral amount and debt amount are zero.
  error ErrorNoSupplyAndNoBorrow();
  
  /// @dev Thrown when borrow is paused.
  error ErrorBorrowPaused();

  /// @dev Thrown when redeem is paused.
  error ErrorRedeemPaused();
  
  /// @dev Thrown when the caller is not position owner during withdraw or borrow.
  error ErrorNotPositionOwner();
  
  /// @dev Thrown when withdraw more than supplied.
  error ErrorWithdrawExceedSupply();
  
  /// @dev Thrown when the debt ratio is too small.
  error ErrorDebtRatioTooSmall();

  /// @dev Thrown when the debt ratio is too large.
  error ErrorDebtRatioTooLarge();
  
  /// @dev Thrown when pool is under collateral.
  error ErrorPoolUnderCollateral();
  
  /// @dev Thrown when the current debt ratio <= rebalance debt ratio.
  error ErrorRebalanceDebtRatioNotReached();

  /// @dev Thrown when the current debt ratio <= liquidate debt ratio.
  error ErrorLiquidateDebtRatioNotReached();

  /// @dev Thrown when the current debt ratio > liquidate debt ratio.
  error ErrorPositionInLiquidationMode();

  error ErrorRebalanceOnLiquidatableTick();

  error ErrorRebalanceOnLiquidatablePosition();

  error ErrorInsufficientCollateralToLiquidate();

  error ErrorOverflow();

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to check value not too large.
  /// @param value The value to check.
  /// @param upperBound The upper bound for the given value.
  function _checkValueTooLarge(uint256 value, uint256 upperBound) internal pure {
    if (value > upperBound) revert ErrorValueTooLarge();
  }

  function _checkAddressNotZero(address value) internal pure {
    if (value == address(0)) revert ErrorZeroAddress();
  }
}

// File: contracts/core/pool/PoolStorage.sol

pragma solidity ^0.8.26;










abstract contract PoolStorage is ERC721Upgradeable, AccessControlUpgradeable, PoolConstant, PoolErrors {
  using WordCodec for bytes32;

  /*************
   * Constants *
   *************/

  /// @dev Below are offsets of each variables in `miscData`.
  uint256 private constant BORROW_FLAG_OFFSET = 0;
  uint256 private constant REDEEM_FLAG_OFFSET = 1;
  uint256 private constant TOP_TICK_OFFSET = 2;
  uint256 private constant NEXT_POSITION_OFFSET = 18;
  uint256 private constant NEXT_NODE_OFFSET = 50;
  uint256 private constant MIN_DEBT_RATIO_OFFSET = 98;
  uint256 private constant MAX_DEBT_RATIO_OFFSET = 158;
  uint256 private constant MAX_REDEEM_RATIO_OFFSET = 218;

  /// @dev Below are offsets of each variables in `rebalanceRatioData`.
  uint256 private constant REBALANCE_DEBT_RATIO_OFFSET = 0;
  uint256 private constant REBALANCE_BONUS_RATIO_OFFSET = 60;
  uint256 private constant LIQUIDATE_DEBT_RATIO_OFFSET = 90;
  uint256 private constant LIQUIDATE_BONUS_RATIO_OFFSET = 150;

  /// @dev Below are offsets of each variables in `indexData`.
  uint256 private constant DEBT_INDEX_OFFSET = 0;
  uint256 private constant COLLATERAL_INDEX_OFFSET = 128;

  /// @dev Below are offsets of each variables in `sharesData`.
  uint256 private constant DEBT_SHARES_OFFSET = 0;
  uint256 private constant COLLATERAL_SHARES_OFFSET = 128;

  /***********
   * Structs *
   ***********/

  /// @dev if nodeId = 0, tick is not used and this position only has collateral
  ///
  /// @param tick The tick this position belongs to at the beginning.
  /// @param nodeId The tree node id this position belongs to at the beginning.
  /// @param colls The collateral shares this position has.
  /// @param debts The debt shares this position has.
  struct PositionInfo {
    int16 tick;
    uint48 nodeId;
    // `uint96` is enough, since we use `86` bits in `PoolManager`.
    uint96 colls;
    // `uint96` is enough, since we use `96` bits in `PoolManager`.
    uint96 debts;
  }

  /// @dev The compiler will pack it into two `uint256`.
  /// @param metadata The metadata for tree node.
  ///   ```text
  ///   * Field           Bits    Index       Comments
  ///   * parent          48      0           The index for parent tree node.
  ///   * tick            16      48          The original tick for this tree node.
  ///   * coll ratio      64      64          The remained coll share ratio base on parent node, the value is real ratio * 2^60.
  ///   * debt ratio      64      128         The remained debt share ratio base on parent node, the value is real ratio * 2^60.
  ///   ```
  /// @param value The value for tree node
  ///   ```text
  ///   * Field           Bits    Index       Comments
  ///   * coll share      128     0           The original total coll share before rebalance or redeem.
  ///   * debt share      128     128         The original total debt share before rebalance or redeem.
  ///   ```
  struct TickTreeNode {
    bytes32 metadata;
    bytes32 value;
  }

  /*********************
   * Storage Variables *
   *********************/

  /// @inheritdoc IPool
  address public collateralToken;

  /// @inheritdoc IPool
  address public priceOracle;

  /// @dev `miscData` is a storage slot that can be used to store unrelated pieces of information.
  ///
  /// - The *borrow flag* indicates whether borrow fxUSD is allowed, 1 means paused.
  /// - The *redeem flag* indicates whether redeem fxUSD is allowed, 1 means paused.
  /// - The *top tick* is the largest tick with debts.
  /// - The *next position* is the next unassigned position id.
  /// - The *next node* is the next unassigned tree node id.
  /// - The *min debt ratio* is the minimum allowed debt ratio, multiplied by 1e18.
  /// - The *max debt ratio* is the maximum allowed debt ratio, multiplied by 1e18.
  /// - The *max redeem ratio* is the maximum allowed redeem ratio per tick, multiplied by 1e9.
  ///
  /// [ borrow flag | redeem flag | top tick | next position | next node | min debt ratio | max debt ratio | max redeem ratio | reserved ]
  /// [    1 bit    |    1 bit    | 16  bits |    32 bits    |  48 bits  |    60  bits    |    60  bits    |      30 bits     |  8 bits  ]
  /// [ MSB                                                                                                                          LSB ]
  bytes32 private miscData;

  /// @dev `rebalanceRatioData` is a storage slot used to store rebalance and liquidate information.
  ///
  /// - The *rebalance debt ratio* is the min debt ratio to start rebalance, multiplied by 1e18.
  /// - The *rebalance bonus ratio* is the bonus ratio during rebalance, multiplied by 1e9.
  /// - The *liquidate debt ratio* is the min debt ratio to start liquidate, multiplied by 1e18.
  /// - The *liquidate bonus ratio* is the bonus ratio during liquidate, multiplied by 1e9.
  ///
  /// [ rebalance debt ratio | rebalance bonus ratio | liquidate debt ratio | liquidate bonus ratio | reserved ]
  /// [       60  bits       |        30 bits        |       60  bits       |        30 bits        | 76  bits ]
  /// [ MSB                                                                                                LSB ]
  bytes32 private rebalanceRatioData;

  /// @dev `indexData` is a storage slot used to store debt/collateral index.
  ///
  /// - The *debt index* is the index for each debt shares, only increasing, starting from 2^96, max 2^128-1.
  /// - The *collateral index* is the index for each collateral shares, only increasing, starting from 2^96, max 2^128-1
  ///
  /// [ debt index | collateral index ]
  /// [  128 bits  |     128 bits     ]
  /// [ MSB                       LSB ]
  bytes32 private indexData;

  /// @dev `sharesData` is a storage slot used to store debt/collateral shares.
  ///
  /// - The *debt shares* is the total debt shares. The actual number of total debts
  ///   is `<debt shares> * <debt index>`.
  /// - The *collateral shares* is the total collateral shares. The actual number of
  ///   total collateral is `<collateral shares> / <collateral index>`.
  ///
  /// [ debt shares | collateral shares ]
  /// [  128  bits  |     128  bits     ]
  /// [ MSB                         LSB ]
  bytes32 private sharesData;

  /// @dev Mapping from position id to position information.
  mapping(uint256 => PositionInfo) public positionData;

  /// @dev Mapping from position id to position metadata.
  /// [ open timestamp | reserved ]
  /// [    40  bits    | 216 bits ]
  /// [ MSB                   LSB ]
  mapping(uint256 => bytes32) public positionMetadata;

  /// @dev The bitmap for ticks with debts.
  mapping(int8 => uint256) public tickBitmap;

  /// @dev Mapping from tick to tree node id.
  mapping(int256 => uint48) public tickData;

  /// @dev Mapping from tree node id to tree node data.
  mapping(uint256 => TickTreeNode) public tickTreeData;

  /***************
   * Constructor *
   ***************/

  function __PoolStorage_init(address _collateralToken, address _priceOracle) internal onlyInitializing {
    _checkAddressNotZero(_collateralToken);

    collateralToken = _collateralToken;
    _updatePriceOracle(_priceOracle);
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc AccessControlUpgradeable
  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(AccessControlUpgradeable, ERC721Upgradeable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  /// @inheritdoc IPool
  function isBorrowPaused() external view returns (bool) {
    return _isBorrowPaused();
  }

  /// @inheritdoc IPool
  function isRedeemPaused() external view returns (bool) {
    return _isRedeemPaused();
  }

  /// @inheritdoc IPool
  function getTopTick() external view returns (int16) {
    return _getTopTick();
  }

  /// @inheritdoc IPool
  function getNextPositionId() external view returns (uint32) {
    return _getNextPositionId();
  }

  /// @inheritdoc IPool
  function getNextTreeNodeId() external view returns (uint48) {
    return _getNextTreeNodeId();
  }

  /// @inheritdoc IPool
  function getDebtRatioRange() external view returns (uint256, uint256) {
    return _getDebtRatioRange();
  }

  /// @inheritdoc IPool
  function getMaxRedeemRatioPerTick() external view returns (uint256) {
    return _getMaxRedeemRatioPerTick();
  }

  /// @inheritdoc IPool
  function getRebalanceRatios() external view returns (uint256, uint256) {
    return _getRebalanceRatios();
  }

  /// @inheritdoc IPool
  function getLiquidateRatios() external view returns (uint256, uint256) {
    return _getLiquidateRatios();
  }

  /// @inheritdoc IPool
  function getDebtAndCollateralIndex() external view returns (uint256, uint256) {
    return _getDebtAndCollateralIndex();
  }

  /// @inheritdoc IPool
  function getDebtAndCollateralShares() external view returns (uint256, uint256) {
    return _getDebtAndCollateralShares();
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to update price oracle.
  /// @param newOracle The address of new price oracle;
  function _updatePriceOracle(address newOracle) internal {
    _checkAddressNotZero(newOracle);

    address oldOracle = priceOracle;
    priceOracle = newOracle;

    emit UpdatePriceOracle(oldOracle, newOracle);
  }

  /*************************************
   * Internal Functions For `miscData` *
   *************************************/

  /// @dev Internal function to get the borrow pause status.
  function _isBorrowPaused() internal view returns (bool) {
    return miscData.decodeBool(BORROW_FLAG_OFFSET);
  }

  /// @dev Internal function to update borrow pause status.
  /// @param status The status to update.
  function _updateBorrowStatus(bool status) internal {
    miscData = miscData.insertBool(status, BORROW_FLAG_OFFSET);

    emit UpdateBorrowStatus(status);
  }

  /// @dev Internal function to get the redeem pause status.
  function _isRedeemPaused() internal view returns (bool) {
    return miscData.decodeBool(REDEEM_FLAG_OFFSET);
  }

  /// @dev Internal function to update redeem pause status.
  /// @param status The status to update.
  function _updateRedeemStatus(bool status) internal {
    miscData = miscData.insertBool(status, REDEEM_FLAG_OFFSET);

    emit UpdateRedeemStatus(status);
  }

  /// @dev Internal function to get the value of top tick.
  function _getTopTick() internal view returns (int16) {
    return int16(miscData.decodeInt(TOP_TICK_OFFSET, 16));
  }

  /// @dev Internal function to update the top tick.
  /// @param tick The new top tick.
  function _updateTopTick(int16 tick) internal {
    miscData = miscData.insertInt(tick, TOP_TICK_OFFSET, 16);
  }

  /// @dev Internal function to get next available position id.
  function _getNextPositionId() internal view returns (uint32) {
    return uint32(miscData.decodeUint(NEXT_POSITION_OFFSET, 32));
  }

  /// @dev Internal function to update next available position id.
  /// @param id The position id to update.
  function _updateNextPositionId(uint32 id) internal {
    miscData = miscData.insertUint(id, NEXT_POSITION_OFFSET, 32);
  }

  /// @dev Internal function to get next available tree node id.
  function _getNextTreeNodeId() internal view returns (uint48) {
    return uint48(miscData.decodeUint(NEXT_NODE_OFFSET, 48));
  }

  /// @dev Internal function to update next available tree node id.
  /// @param id The tree node id to update.
  function _updateNextTreeNodeId(uint48 id) internal {
    miscData = miscData.insertUint(id, NEXT_NODE_OFFSET, 48);
  }

  /// @dev Internal function to get `minDebtRatio` and `maxDebtRatio`, both multiplied by 1e18.
  function _getDebtRatioRange() internal view returns (uint256 minDebtRatio, uint256 maxDebtRatio) {
    bytes32 data = miscData;
    minDebtRatio = data.decodeUint(MIN_DEBT_RATIO_OFFSET, 60);
    maxDebtRatio = data.decodeUint(MAX_DEBT_RATIO_OFFSET, 60);
  }

  /// @dev Internal function to update debt ratio range.
  /// @param minDebtRatio The minimum allowed debt ratio to update, multiplied by 1e18.
  /// @param maxDebtRatio The maximum allowed debt ratio to update, multiplied by 1e18.
  function _updateDebtRatioRange(uint256 minDebtRatio, uint256 maxDebtRatio) internal {
    _checkValueTooLarge(minDebtRatio, maxDebtRatio);
    _checkValueTooLarge(maxDebtRatio, PRECISION);

    bytes32 data = miscData;
    data = data.insertUint(minDebtRatio, MIN_DEBT_RATIO_OFFSET, 60);
    miscData = data.insertUint(maxDebtRatio, MAX_DEBT_RATIO_OFFSET, 60);

    emit UpdateDebtRatioRange(minDebtRatio, maxDebtRatio);
  }

  /// @dev Internal function to get the `maxRedeemRatioPerTick`.
  function _getMaxRedeemRatioPerTick() internal view returns (uint256) {
    return miscData.decodeUint(MAX_REDEEM_RATIO_OFFSET, 30);
  }

  /// @dev Internal function to update maximum redeem ratio per tick.
  /// @param ratio The ratio to update, multiplied by 1e9.
  function _updateMaxRedeemRatioPerTick(uint256 ratio) internal {
    _checkValueTooLarge(ratio, FEE_PRECISION);

    miscData = miscData.insertUint(ratio, MAX_REDEEM_RATIO_OFFSET, 30);

    emit UpdateMaxRedeemRatioPerTick(ratio);
  }

  /***********************************************
   * Internal Functions For `rebalanceRatioData` *
   ***********************************************/

  /// @dev Internal function to get `debtRatio` and `bonusRatio` for rebalance.
  /// @return debtRatio The minimum debt ratio to start rebalance, multiplied by 1e18.
  /// @return bonusRatio The bonus ratio during rebalance, multiplied by 1e9.
  function _getRebalanceRatios() internal view returns (uint256 debtRatio, uint256 bonusRatio) {
    bytes32 data = rebalanceRatioData;
    debtRatio = data.decodeUint(REBALANCE_DEBT_RATIO_OFFSET, 60);
    bonusRatio = data.decodeUint(REBALANCE_BONUS_RATIO_OFFSET, 30);
  }

  /// @dev Internal function to update ratio for rebalance.
  /// @param debtRatio The minimum debt ratio to start rebalance, multiplied by 1e18.
  /// @param bonusRatio The bonus ratio during rebalance, multiplied by 1e9.
  function _updateRebalanceRatios(uint256 debtRatio, uint256 bonusRatio) internal {
    _checkValueTooLarge(debtRatio, PRECISION);
    _checkValueTooLarge(bonusRatio, FEE_PRECISION);

    bytes32 data = rebalanceRatioData;
    data = data.insertUint(debtRatio, REBALANCE_DEBT_RATIO_OFFSET, 60);
    rebalanceRatioData = data.insertUint(bonusRatio, REBALANCE_BONUS_RATIO_OFFSET, 30);

    emit UpdateRebalanceRatios(debtRatio, bonusRatio);
  }

  /// @dev Internal function to get `debtRatio` and `bonusRatio` for liquidate.
  /// @return debtRatio The minimum debt ratio to start liquidate, multiplied by 1e18.
  /// @return bonusRatio The bonus ratio during liquidate, multiplied by 1e9.
  function _getLiquidateRatios() internal view returns (uint256 debtRatio, uint256 bonusRatio) {
    bytes32 data = rebalanceRatioData;
    debtRatio = data.decodeUint(LIQUIDATE_DEBT_RATIO_OFFSET, 60);
    bonusRatio = data.decodeUint(LIQUIDATE_BONUS_RATIO_OFFSET, 30);
  }

  /// @dev Internal function to update ratio for liquidate.
  /// @param debtRatio The minimum debt ratio to start liquidate, multiplied by 1e18.
  /// @param bonusRatio The bonus ratio during liquidate, multiplied by 1e9.
  function _updateLiquidateRatios(uint256 debtRatio, uint256 bonusRatio) internal {
    _checkValueTooLarge(debtRatio, PRECISION);
    _checkValueTooLarge(bonusRatio, FEE_PRECISION);

    bytes32 data = rebalanceRatioData;
    data = data.insertUint(debtRatio, LIQUIDATE_DEBT_RATIO_OFFSET, 60);
    rebalanceRatioData = data.insertUint(bonusRatio, LIQUIDATE_BONUS_RATIO_OFFSET, 30);

    emit UpdateLiquidateRatios(debtRatio, bonusRatio);
  }

  /**************************************
   * Internal Functions For `indexData` *
   **************************************/

  /// @dev Internal function to get debt and collateral index.
  /// @return debtIndex The index for debt shares.
  /// @return collIndex The index for collateral shares.
  function _getDebtAndCollateralIndex() internal view returns (uint256 debtIndex, uint256 collIndex) {
    bytes32 data = indexData;
    debtIndex = data.decodeUint(DEBT_INDEX_OFFSET, 128);
    collIndex = data.decodeUint(COLLATERAL_INDEX_OFFSET, 128);
  }

  /// @dev Internal function to update debt index.
  /// @param index The debt index to update.
  function _updateDebtIndex(uint256 index) internal {
    indexData = indexData.insertUint(index, DEBT_INDEX_OFFSET, 128);

    emit DebtIndexSnapshot(index);
  }

  /// @dev Internal function to update collateral index.
  /// @param index The collateral index to update.
  function _updateCollateralIndex(uint256 index) internal {
    indexData = indexData.insertUint(index, COLLATERAL_INDEX_OFFSET, 128);

    emit CollateralIndexSnapshot(index);
  }

  /**************************************
   * Internal Functions For `sharesData` *
   **************************************/

  /// @dev Internal function to get debt and collateral shares.
  /// @return debtShares The total number of debt shares.
  /// @return collShares The total number of collateral shares.
  function _getDebtAndCollateralShares() internal view returns (uint256 debtShares, uint256 collShares) {
    bytes32 data = sharesData;
    debtShares = data.decodeUint(DEBT_SHARES_OFFSET, 128);
    collShares = data.decodeUint(COLLATERAL_SHARES_OFFSET, 128);
  }

  /// @dev Internal function to update debt and collateral shares.
  /// @param debtShares The debt shares to update.
  /// @param collShares The collateral shares to update.
  function _updateDebtAndCollateralShares(uint256 debtShares, uint256 collShares) internal {
    bytes32 data = sharesData;
    data = data.insertUint(debtShares, DEBT_SHARES_OFFSET, 128);
    sharesData = data.insertUint(collShares, COLLATERAL_SHARES_OFFSET, 128);
  }

  /// @dev Internal function to update debt shares.
  /// @param shares The debt shares to update.
  function _updateDebtShares(uint256 shares) internal {
    sharesData = sharesData.insertUint(shares, DEBT_SHARES_OFFSET, 128);
  }

  /// @dev Internal function to update collateral shares.
  /// @param shares The collateral shares to update.
  function _updateCollateralShares(uint256 shares) internal {
    sharesData = sharesData.insertUint(shares, COLLATERAL_SHARES_OFFSET, 128);
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   */
  uint256[40] private __gap;
}

// File: contracts/core/pool/TickLogic.sol

pragma solidity ^0.8.26;






abstract contract TickLogic is PoolStorage {
  using TickBitmap for mapping(int8 => uint256);
  using WordCodec for bytes32;

  /*************
   * Constants *
   *************/

  /// @dev Below are offsets of each variables in `TickTreeNode.metadata`.
  uint256 private constant PARENT_OFFSET = 0;
  uint256 private constant TICK_OFFSET = 48;
  uint256 private constant COLL_RATIO_OFFSET = 64;
  uint256 private constant DEBT_RATIO_OFFSET = 128;

  /// @dev Below are offsets of each variables in `TickTreeNode.value`.
  uint256 internal constant COLL_SHARE_OFFSET = 0;
  uint256 internal constant DEBT_SHARE_OFFSET = 128;

  /***************
   * Constructor *
   ***************/

  function __TickLogic_init() internal onlyInitializing {
    _updateNextTreeNodeId(1);
    _updateTopTick(type(int16).min);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to get the root of the given tree node.
  /// @param node The id of the given tree node.
  /// @return root The root node id.
  /// @return collRatio The actual collateral ratio of the given node, multiplied by 2^60.
  /// @return debtRatio The actual debt ratio of the given node, multiplied by 2^60.
  function _getRootNode(uint256 node) internal view returns (uint256 root, uint256 collRatio, uint256 debtRatio) {
    collRatio = E60;
    debtRatio = E60;
    while (true) {
      bytes32 metadata = tickTreeData[node].metadata;
      uint256 parent = metadata.decodeUint(PARENT_OFFSET, 48);
      collRatio = (collRatio * metadata.decodeUint(COLL_RATIO_OFFSET, 64)) >> 60;
      debtRatio = (debtRatio * metadata.decodeUint(DEBT_RATIO_OFFSET, 64)) >> 60;
      if (parent == 0) break;
      node = parent;
    }
    root = node;
  }

  /// @dev Internal function to get the root of the given tree node and compress path.
  /// @param node The id of the given tree node.
  /// @return root The root node id.
  /// @return collRatio The actual collateral ratio of the given node, multiplied by 2^60.
  /// @return debtRatio The actual debt ratio of the given node, multiplied by 2^60.
  function _getRootNodeAndCompress(uint256 node) internal returns (uint256 root, uint256 collRatio, uint256 debtRatio) {
    // @note We can change it to non-recursive version to avoid stack overflow. Normally, the depth should be `log(n)`,
    // where `n` is the total number of tree nodes. So we don't need to worry much about this.
    bytes32 metadata = tickTreeData[node].metadata;
    uint256 parent = metadata.decodeUint(PARENT_OFFSET, 48);
    collRatio = metadata.decodeUint(COLL_RATIO_OFFSET, 64);
    debtRatio = metadata.decodeUint(DEBT_RATIO_OFFSET, 64);
    if (parent == 0) {
      root = node;
    } else {
      uint256 collRatioCompressed;
      uint256 debtRatioCompressed;
      (root, collRatioCompressed, debtRatioCompressed) = _getRootNodeAndCompress(parent);
      collRatio = (collRatio * collRatioCompressed) >> 60;
      debtRatio = (debtRatio * debtRatioCompressed) >> 60;
      metadata = metadata.insertUint(root, PARENT_OFFSET, 48);
      metadata = metadata.insertUint(collRatio, COLL_RATIO_OFFSET, 64);
      metadata = metadata.insertUint(debtRatio, DEBT_RATIO_OFFSET, 64);
      tickTreeData[node].metadata = metadata;
    }
  }

  /// @dev Internal function to create a new tree node.
  /// @param tick The tick where this tree node belongs to.
  /// @return node The created tree node id.
  function _newTickTreeNode(int16 tick) internal returns (uint48 node) {
    unchecked {
      node = _getNextTreeNodeId();
      _updateNextTreeNodeId(node + 1);
    }
    tickData[tick] = node;

    bytes32 metadata = bytes32(0);
    metadata = metadata.insertInt(tick, TICK_OFFSET, 16); // set tick
    metadata = metadata.insertUint(E60, COLL_RATIO_OFFSET, 64); // set coll ratio
    metadata = metadata.insertUint(E60, DEBT_RATIO_OFFSET, 64); // set debt ratio
    tickTreeData[node].metadata = metadata;
  }

  /// @dev Internal function to find first tick such that `TickMath.getRatioAtTick(tick) >= debts/colls`.
  /// @param colls The collateral shares.
  /// @param debts The debt shares.
  /// @return tick The value of found first tick.
  function _getTick(uint256 colls, uint256 debts) internal pure returns (int256 tick) {
    uint256 ratio = (debts * TickMath.ZERO_TICK_SCALED_RATIO) / colls;
    uint256 ratioAtTick;
    (tick, ratioAtTick) = TickMath.getTickAtRatio(ratio);
    if (ratio != ratioAtTick) {
      tick++;
      ratio = (ratioAtTick * 10015) / 10000;
    }
  }

  /// @dev Internal function to retrieve or create a tree node.
  /// @param tick The tick where this tree node belongs to.
  /// @return node The tree node id.
  function _getOrCreateTickNode(int256 tick) internal returns (uint48 node) {
    node = tickData[tick];
    if (node == 0) {
      node = _newTickTreeNode(int16(tick));
    }
  }

  /// @dev Internal function to add position collaterals and debts to some tick.
  /// @param colls The collateral shares.
  /// @param debts The debt shares.
  /// @param checkDebts Whether we should check the value of `debts`.
  /// @return tick The tick where this position belongs to.
  /// @return node The corresponding tree node id for this tick.
  function _addPositionToTick(
    uint256 colls,
    uint256 debts,
    bool checkDebts
  ) internal returns (int256 tick, uint48 node) {
    if (debts > 0) {
      if (checkDebts && int256(debts) < MIN_DEBT) {
        revert ErrorDebtTooSmall();
      }

      tick = _getTick(colls, debts);
      node = _getOrCreateTickNode(tick);
      bytes32 value = tickTreeData[node].value;
      uint256 newColls = value.decodeUint(COLL_SHARE_OFFSET, 128) + colls;
      uint256 newDebts = value.decodeUint(DEBT_SHARE_OFFSET, 128) + debts;
      value = value.insertUint(newColls, COLL_SHARE_OFFSET, 128);
      value = value.insertUint(newDebts, DEBT_SHARE_OFFSET, 128);
      tickTreeData[node].value = value;

      if (newDebts == debts) {
        tickBitmap.flipTick(int16(tick));
      }

      // update top tick
      if (tick > _getTopTick()) {
        _updateTopTick(int16(tick));
      }
    }
  }

  /// @dev Internal function to remove position from tick.
  /// @param position The position struct to remove.
  function _removePositionFromTick(PositionInfo memory position) internal {
    if (position.nodeId == 0) return;

    bytes32 value = tickTreeData[position.nodeId].value;
    uint256 newColls = value.decodeUint(COLL_SHARE_OFFSET, 128) - position.colls;
    uint256 newDebts = value.decodeUint(DEBT_SHARE_OFFSET, 128) - position.debts;
    value = value.insertUint(newColls, COLL_SHARE_OFFSET, 128);
    value = value.insertUint(newDebts, DEBT_SHARE_OFFSET, 128);
    tickTreeData[position.nodeId].value = value;

    if (newDebts == 0) {
      int16 tick = int16(tickTreeData[position.nodeId].metadata.decodeInt(TICK_OFFSET, 16));
      tickBitmap.flipTick(tick);

      // top tick gone, update it to new one
      int16 topTick = _getTopTick();
      if (topTick == tick) {
        _resetTopTick(topTick);
      }
    }
  }

  /// @dev Internal function to liquidate a tick.
  ///      The caller make sure `max(liquidatedColl, liquidatedDebt) > 0`.
  ///
  /// @param tick The id of tick to liquidate.
  /// @param liquidatedColl The amount of collateral shares liquidated.
  /// @param liquidatedDebt The amount of debt shares liquidated.
  function _liquidateTick(int16 tick, uint256 liquidatedColl, uint256 liquidatedDebt, uint256 price) internal {
    uint48 node = tickData[tick];
    // create new tree node for this tick
    _newTickTreeNode(tick);
    // clear bitmap first, and it will be updated later if needed.
    tickBitmap.flipTick(tick);

    bytes32 value = tickTreeData[node].value;
    bytes32 metadata = tickTreeData[node].metadata;
    uint256 tickColl = value.decodeUint(COLL_SHARE_OFFSET, 128);
    uint256 tickDebt = value.decodeUint(DEBT_SHARE_OFFSET, 128);
    uint256 tickCollAfter = tickColl - liquidatedColl;
    uint256 tickDebtAfter = tickDebt - liquidatedDebt;
    uint256 collRatio = (tickCollAfter * E60) / tickColl;
    uint256 debtRatio = (tickDebtAfter * E60) / tickDebt;

    // update metadata
    metadata = metadata.insertUint(collRatio, COLL_RATIO_OFFSET, 64);
    metadata = metadata.insertUint(debtRatio, DEBT_RATIO_OFFSET, 64);

    int256 newTick = type(int256).min;
    if (tickDebtAfter > 0) {
      // partial liquidated, move funds to another tick
      uint48 parentNode;
      (newTick, parentNode) = _addPositionToTick(tickCollAfter, tickDebtAfter, false);
      metadata = metadata.insertUint(parentNode, PARENT_OFFSET, 48);
    }
    emit TickMovement(tick, int16(newTick), tickCollAfter, tickDebtAfter, price);

    // top tick liquidated, update it to new one
    int16 topTick = _getTopTick();
    if (topTick == tick && newTick != int256(tick)) {
      _resetTopTick(topTick);
    }
    tickTreeData[node].metadata = metadata;
  }

  /// @dev Internal function to reset top tick.
  /// @param oldTopTick The previous value of top tick.
  function _resetTopTick(int16 oldTopTick) internal {
    while (oldTopTick > type(int16).min) {
      bool hasDebt;
      (oldTopTick, hasDebt) = tickBitmap.nextDebtPositionWithinOneWord(oldTopTick - 1);
      if (hasDebt) break;
    }
    _updateTopTick(oldTopTick);
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   */
  uint256[50] private __gap;
}

// File: contracts/core/pool/PositionLogic.sol

pragma solidity ^0.8.26;








abstract contract PositionLogic is TickLogic {
  using WordCodec for bytes32;

  /***************
   * Constructor *
   ***************/

  function __PositionLogic_init() internal onlyInitializing {
    _updateNextPositionId(1);
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IPool
  function getPosition(uint256 tokenId) public view returns (uint256 rawColls, uint256 rawDebts) {
    // compute actual shares
    PositionInfo memory position = positionData[tokenId];
    rawColls = position.colls;
    rawDebts = position.debts;
    if (position.nodeId > 0) {
      (, uint256 collRatio, uint256 debtRatio) = _getRootNode(position.nodeId);
      rawColls = (rawColls * collRatio) >> 60;
      rawDebts = (rawDebts * debtRatio) >> 60;
    }

    // convert shares to actual amount
    (uint256 debtIndex, uint256 collIndex) = _getDebtAndCollateralIndex();
    rawColls = _convertToRawColl(rawColls, collIndex, Math.Rounding.Down);
    rawDebts = _convertToRawDebt(rawDebts, debtIndex, Math.Rounding.Down);
  }

  /// @inheritdoc IPool
  function getPositionDebtRatio(uint256 tokenId) external view returns (uint256 debtRatio) {
    (uint256 rawColls, uint256 rawDebts) = getPosition(tokenId);
    // price precision and ratio precision are both 1e18, use anchor price here
    (uint256 price, , ) = IPriceOracle(priceOracle).getPrice();
    if (rawColls == 0) return 0;
    return (rawDebts * PRECISION * PRECISION) / (price * rawColls);
  }

  /// @inheritdoc IPool
  function getTotalRawCollaterals() external view returns (uint256) {
    (, uint256 totalColls) = _getDebtAndCollateralShares();
    (, uint256 collIndex) = _getDebtAndCollateralIndex();
    return _convertToRawColl(totalColls, collIndex, Math.Rounding.Down);
  }

  /// @inheritdoc IPool
  function getTotalRawDebts() external view returns (uint256) {
    (uint256 totalDebts, ) = _getDebtAndCollateralShares();
    (uint256 debtIndex, ) = _getDebtAndCollateralIndex();
    return _convertToRawDebt(totalDebts, debtIndex, Math.Rounding.Down);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to mint a new position.
  /// @param owner The address of position owner.
  /// @return positionId The id of the position.
  function _mintPosition(address owner) internal returns (uint32 positionId) {
    unchecked {
      positionId = _getNextPositionId();
      _updateNextPositionId(positionId + 1);
    }

    positionMetadata[positionId] = bytes32(0).insertUint(block.timestamp, 0, 40);
    _mint(owner, positionId);
  }

  /// @dev Internal function to get and update position.
  /// @param tokenId The id of the position.
  /// @return position The position struct.
  function _getAndUpdatePosition(uint256 tokenId) internal returns (PositionInfo memory position) {
    position = positionData[tokenId];
    if (position.nodeId > 0) {
      (uint256 root, uint256 collRatio, uint256 debtRatio) = _getRootNodeAndCompress(position.nodeId);
      position.colls = uint96((position.colls * collRatio) >> 60);
      position.debts = uint96((position.debts * debtRatio) >> 60);
      position.nodeId = uint32(root);
      positionData[tokenId] = position;
    }
  }

  /// @dev Internal function to convert raw collateral amounts to collateral shares.
  function _convertToCollShares(
    uint256 raw,
    uint256 index,
    Math.Rounding rounding
  ) internal pure returns (uint256 shares) {
    shares = Math.mulDiv(raw, index, E96, rounding);
  }

  /// @dev Internal function to convert raw debt amounts to debt shares.
  function _convertToDebtShares(
    uint256 raw,
    uint256 index,
    Math.Rounding rounding
  ) internal pure returns (uint256 shares) {
    shares = Math.mulDiv(raw, E96, index, rounding);
  }

  /// @dev Internal function to convert raw collateral shares to collateral amounts.
  function _convertToRawColl(
    uint256 shares,
    uint256 index,
    Math.Rounding rounding
  ) internal pure returns (uint256 raw) {
    raw = Math.mulDiv(shares, E96, index, rounding);
  }

  /// @dev Internal function to convert raw debt shares to debt amounts.
  function _convertToRawDebt(
    uint256 shares,
    uint256 index,
    Math.Rounding rounding
  ) internal pure returns (uint256 raw) {
    raw = Math.mulDiv(shares, index, E96, rounding);
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   */
  uint256[50] private __gap;
}

// File: contracts/core/pool/BasePool.sol

pragma solidity ^0.8.26;












abstract contract BasePool is TickLogic, PositionLogic {
  using TickBitmap for mapping(int8 => uint256);
  using WordCodec for bytes32;

  /***********
   * Structs *
   ***********/

  struct OperationMemoryVar {
    int256 tick;
    uint48 node;
    uint256 positionColl;
    uint256 positionDebt;
    int256 newColl;
    int256 newDebt;
    uint256 collIndex;
    uint256 debtIndex;
    uint256 globalColl;
    uint256 globalDebt;
    uint256 price;
  }

  /*************
   * Modifiers *
   *************/

  modifier onlyPoolManager() {
    if (_msgSender() != poolManager) {
      revert ErrorCallerNotPoolManager();
    }
    _;
  }

  /***************
   * Constructor *
   ***************/

  constructor(address _poolManager) {
    _checkAddressNotZero(_poolManager);

    poolManager = _poolManager;
    fxUSD = IPoolManager(_poolManager).fxUSD();
    pegKeeper = IPoolManager(_poolManager).pegKeeper();
  }

  function __BasePool_init() internal onlyInitializing {
    _updateDebtIndex(E96);
    _updateCollateralIndex(E96);
    _updateDebtRatioRange(500000000000000000, 857142857142857142); // 1/2 ~ 6/7
    _updateMaxRedeemRatioPerTick(200000000); // 20%
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IPool
  function operate(
    uint256 positionId,
    int256 newRawColl,
    int256 newRawDebt,
    address owner
  ) external onlyPoolManager returns (uint256, int256, int256, uint256) {
    if (newRawColl == 0 && newRawDebt == 0) revert ErrorNoSupplyAndNoBorrow();
    if (newRawColl != 0 && (newRawColl > -MIN_COLLATERAL && newRawColl < MIN_COLLATERAL)) {
      revert ErrorCollateralTooSmall();
    }
    if (newRawDebt != 0 && (newRawDebt > -MIN_DEBT && newRawDebt < MIN_DEBT)) {
      revert ErrorDebtTooSmall();
    }
    if (newRawDebt > 0 && (_isBorrowPaused() || !IPegKeeper(pegKeeper).isBorrowAllowed())) {
      revert ErrorBorrowPaused();
    }

    OperationMemoryVar memory op;
    // price precision and ratio precision are both 1e18, use min price here
    (, op.price, ) = IPriceOracle(priceOracle).getPrice();
    (op.globalDebt, op.globalColl) = _getDebtAndCollateralShares();
    (op.collIndex, op.debtIndex) = _updateCollAndDebtIndex();
    if (positionId == 0) {
      positionId = _mintPosition(owner);
    } else {
      // make sure position is owned and check owner only in case of withdraw or borrow
      if (ownerOf(positionId) != owner && (newRawColl < 0 || newRawDebt > 0)) {
        revert ErrorNotPositionOwner();
      }
      PositionInfo memory position = _getAndUpdatePosition(positionId);
      // temporarily remove position from tick tree for simplicity
      _removePositionFromTick(position);
      op.tick = position.tick;
      op.node = position.nodeId;
      op.positionDebt = position.debts;
      op.positionColl = position.colls;

      // cannot withdraw or borrow when the position is above liquidation ratio
      if (newRawColl < 0 || newRawDebt > 0) {
        uint256 rawColls = _convertToRawColl(op.positionColl, op.collIndex, Math.Rounding.Down);
        uint256 rawDebts = _convertToRawDebt(op.positionDebt, op.debtIndex, Math.Rounding.Down);
        (uint256 debtRatio, ) = _getLiquidateRatios();
        if (rawDebts * PRECISION * PRECISION > debtRatio * rawColls * op.price) revert ErrorPositionInLiquidationMode();
      }
    }

    uint256 protocolFees;
    // supply or withdraw
    if (newRawColl > 0) {
      protocolFees = _deductProtocolFees(newRawColl);
      newRawColl -= int256(protocolFees);
      op.newColl = int256(_convertToCollShares(uint256(newRawColl), op.collIndex, Math.Rounding.Down));
      op.positionColl += uint256(op.newColl);
      op.globalColl += uint256(op.newColl);
    } else if (newRawColl < 0) {
      if (newRawColl == type(int256).min) {
        // this is max withdraw
        newRawColl = -int256(_convertToRawColl(op.positionColl, op.collIndex, Math.Rounding.Down));
        op.newColl = -int256(op.positionColl);
      } else {
        // this is partial withdraw, rounding up removing extra wei from collateral
        op.newColl = -int256(_convertToCollShares(uint256(-newRawColl), op.collIndex, Math.Rounding.Up));
        if (uint256(-op.newColl) > op.positionColl) revert ErrorWithdrawExceedSupply();
      }
      unchecked {
        op.positionColl -= uint256(-op.newColl);
        op.globalColl -= uint256(-op.newColl);
      }
      protocolFees = _deductProtocolFees(newRawColl);
      newRawColl += int256(protocolFees);
    }

    // borrow or repay
    if (newRawDebt > 0) {
      // rounding up adding extra wei in debt
      op.newDebt = int256(_convertToDebtShares(uint256(newRawDebt), op.debtIndex, Math.Rounding.Up));
      op.positionDebt += uint256(op.newDebt);
      op.globalDebt += uint256(op.newDebt);
    } else if (newRawDebt < 0) {
      if (newRawDebt == type(int256).min) {
        // this is max repay, rounding up amount that will be transferred in to pay back full debt:
        // subtracting -1 of negative debtAmount newDebt_ for safe rounding (increasing payback)
        newRawDebt = -int256(_convertToRawDebt(op.positionDebt, op.debtIndex, Math.Rounding.Up));
        op.newDebt = -int256(op.positionDebt);
      } else {
        // this is partial repay, safe rounding up negative amount to rounding reduce payback
        op.newDebt = -int256(_convertToDebtShares(uint256(-newRawDebt), op.debtIndex, Math.Rounding.Up));
      }
      op.positionDebt -= uint256(-op.newDebt);
      op.globalDebt -= uint256(-op.newDebt);
    }

    // final debt ratio check
    {
      // check position debt ratio is between `minDebtRatio` and `maxDebtRatio`.
      uint256 rawColls = _convertToRawColl(op.positionColl, op.collIndex, Math.Rounding.Down);
      uint256 rawDebts = _convertToRawDebt(op.positionDebt, op.debtIndex, Math.Rounding.Down);
      (uint256 minDebtRatio, uint256 maxDebtRatio) = _getDebtRatioRange();
      if (rawDebts * PRECISION * PRECISION > maxDebtRatio * rawColls * op.price) revert ErrorDebtRatioTooLarge();
      if (rawDebts * PRECISION * PRECISION < minDebtRatio * rawColls * op.price) revert ErrorDebtRatioTooSmall();
    }

    // update position state to storage
    (op.tick, op.node) = _addPositionToTick(op.positionColl, op.positionDebt, true);

    if (op.positionColl > type(uint96).max) revert ErrorOverflow();
    if (op.positionDebt > type(uint96).max) revert ErrorOverflow();
    positionData[positionId] = PositionInfo(int16(op.tick), op.node, uint96(op.positionColl), uint96(op.positionDebt));

    // update global state to storage
    _updateDebtAndCollateralShares(op.globalDebt, op.globalColl);

    emit PositionSnapshot(positionId, int16(op.tick), op.positionColl, op.positionDebt, op.price);

    return (positionId, newRawColl, newRawDebt, protocolFees);
  }

  /// @inheritdoc IPool
  function redeem(uint256 rawDebts) external onlyPoolManager returns (uint256 rawColls) {
    if (_isRedeemPaused()) revert ErrorRedeemPaused();

    (uint256 cachedCollIndex, uint256 cachedDebtIndex) = _updateCollAndDebtIndex();
    (uint256 cachedTotalDebts, uint256 cachedTotalColls) = _getDebtAndCollateralShares();
    (, , uint256 price) = IPriceOracle(priceOracle).getPrice(); // use max price
    // check global debt ratio, if global debt ratio >= 1, disable redeem
    {
      uint256 totalRawColls = _convertToRawColl(cachedTotalColls, cachedCollIndex, Math.Rounding.Down);
      uint256 totalRawDebts = _convertToRawDebt(cachedTotalDebts, cachedDebtIndex, Math.Rounding.Down);
      if (totalRawDebts * PRECISION >= totalRawColls * price) revert ErrorPoolUnderCollateral();
    }

    int16 tick = _getTopTick();
    bool hasDebt = true;
    uint256 debtShare = _convertToDebtShares(rawDebts, cachedDebtIndex, Math.Rounding.Down);
    while (debtShare > 0) {
      if (!hasDebt) {
        (tick, hasDebt) = tickBitmap.nextDebtPositionWithinOneWord(tick - 1);
      } else {
        uint256 node = tickData[tick];
        bytes32 value = tickTreeData[node].value;
        uint256 tickDebtShare = value.decodeUint(DEBT_SHARE_OFFSET, 128);
        // skip bad debt
        {
          uint256 tickCollShare = value.decodeUint(COLL_SHARE_OFFSET, 128);
          if (
            _convertToRawDebt(tickDebtShare, cachedDebtIndex, Math.Rounding.Down) * PRECISION >
            _convertToRawColl(tickCollShare, cachedCollIndex, Math.Rounding.Down) * price
          ) {
            hasDebt = false;
            tick = tick;
            continue;
          }
        }

        // redeem at most `maxRedeemRatioPerTick`
        uint256 debtShareToRedeem = (tickDebtShare * _getMaxRedeemRatioPerTick()) / FEE_PRECISION;
        if (debtShareToRedeem > debtShare) debtShareToRedeem = debtShare;
        uint256 rawCollRedeemed = (_convertToRawDebt(debtShareToRedeem, cachedDebtIndex, Math.Rounding.Down) *
          PRECISION) / price;
        uint256 collShareRedeemed = _convertToCollShares(rawCollRedeemed, cachedCollIndex, Math.Rounding.Down);
        _liquidateTick(tick, collShareRedeemed, debtShareToRedeem, price);
        debtShare -= debtShareToRedeem;
        rawColls += rawCollRedeemed;

        cachedTotalColls -= collShareRedeemed;
        cachedTotalDebts -= debtShareToRedeem;

        (tick, hasDebt) = tickBitmap.nextDebtPositionWithinOneWord(tick - 1);
      }
      if (tick == type(int16).min) break;
    }
    _updateDebtAndCollateralShares(cachedTotalDebts, cachedTotalColls);
  }

  /// @inheritdoc IPool
  function rebalance(int16 tick, uint256 maxRawDebts) external onlyPoolManager returns (RebalanceResult memory result) {
    (uint256 cachedCollIndex, uint256 cachedDebtIndex) = _updateCollAndDebtIndex();
    (, uint256 price, ) = IPriceOracle(priceOracle).getPrice(); // use min price
    uint256 node = tickData[tick];
    bytes32 value = tickTreeData[node].value;
    uint256 tickRawColl = _convertToRawColl(
      value.decodeUint(COLL_SHARE_OFFSET, 128),
      cachedCollIndex,
      Math.Rounding.Down
    );
    uint256 tickRawDebt = _convertToRawDebt(
      value.decodeUint(DEBT_SHARE_OFFSET, 128),
      cachedDebtIndex,
      Math.Rounding.Down
    );
    (uint256 rebalanceDebtRatio, uint256 rebalanceBonusRatio) = _getRebalanceRatios();
    (uint256 liquidateDebtRatio, ) = _getLiquidateRatios();
    // rebalance only debt ratio >= `rebalanceDebtRatio` and ratio < `liquidateDebtRatio`
    if (tickRawDebt * PRECISION * PRECISION < rebalanceDebtRatio * tickRawColl * price) {
      revert ErrorRebalanceDebtRatioNotReached();
    }
    if (tickRawDebt * PRECISION * PRECISION >= liquidateDebtRatio * tickRawColl * price) {
      revert ErrorRebalanceOnLiquidatableTick();
    }

    // compute debts to rebalance to make debt ratio to `rebalanceDebtRatio`
    result.rawDebts = _getRawDebtToRebalance(tickRawColl, tickRawDebt, price, rebalanceDebtRatio, rebalanceBonusRatio);
    if (maxRawDebts < result.rawDebts) result.rawDebts = maxRawDebts;

    uint256 debtShareToRebalance = _convertToDebtShares(result.rawDebts, cachedDebtIndex, Math.Rounding.Down);
    result.rawColls = (result.rawDebts * PRECISION) / price;
    result.bonusRawColls = (result.rawColls * rebalanceBonusRatio) / FEE_PRECISION;
    if (result.bonusRawColls > tickRawColl - result.rawColls) {
      result.bonusRawColls = tickRawColl - result.rawColls;
    }
    uint256 collShareToRebalance = _convertToCollShares(
      result.rawColls + result.bonusRawColls,
      cachedCollIndex,
      Math.Rounding.Down
    );

    _liquidateTick(tick, collShareToRebalance, debtShareToRebalance, price);
    unchecked {
      (uint256 totalDebts, uint256 totalColls) = _getDebtAndCollateralShares();
      _updateDebtAndCollateralShares(totalDebts - debtShareToRebalance, totalColls - collShareToRebalance);
    }
  }

  /// @inheritdoc IPool
  function rebalance(
    uint32 positionId,
    uint256 maxRawDebts
  ) external onlyPoolManager returns (RebalanceResult memory result) {
    _requireOwned(positionId);

    (uint256 cachedCollIndex, uint256 cachedDebtIndex) = _updateCollAndDebtIndex();
    (, uint256 price, ) = IPriceOracle(priceOracle).getPrice(); // use min price
    PositionInfo memory position = _getAndUpdatePosition(positionId);
    uint256 positionRawColl = _convertToRawColl(position.colls, cachedCollIndex, Math.Rounding.Down);
    uint256 positionRawDebt = _convertToRawDebt(position.debts, cachedDebtIndex, Math.Rounding.Down);
    (uint256 rebalanceDebtRatio, uint256 rebalanceBonusRatio) = _getRebalanceRatios();
    // rebalance only debt ratio >= `rebalanceDebtRatio` and ratio < `liquidateDebtRatio`
    if (positionRawDebt * PRECISION * PRECISION < rebalanceDebtRatio * positionRawColl * price) {
      revert ErrorRebalanceDebtRatioNotReached();
    }
    {
      (uint256 liquidateDebtRatio, ) = _getLiquidateRatios();
      if (positionRawDebt * PRECISION * PRECISION >= liquidateDebtRatio * positionRawColl * price) {
        revert ErrorRebalanceOnLiquidatableTick();
      }
    }
    _removePositionFromTick(position);

    // compute debts to rebalance to make debt ratio to `rebalanceDebtRatio`
    result.rawDebts = _getRawDebtToRebalance(
      positionRawColl,
      positionRawDebt,
      price,
      rebalanceDebtRatio,
      rebalanceBonusRatio
    );
    if (maxRawDebts < result.rawDebts) result.rawDebts = maxRawDebts;

    uint256 debtShareToRebalance = _convertToDebtShares(result.rawDebts, cachedDebtIndex, Math.Rounding.Down);
    result.rawColls = (result.rawDebts * PRECISION) / price;
    result.bonusRawColls = (result.rawColls * rebalanceBonusRatio) / FEE_PRECISION;
    if (result.bonusRawColls > positionRawColl - result.rawColls) {
      result.bonusRawColls = positionRawColl - result.rawColls;
    }
    uint256 collShareToRebalance = _convertToCollShares(
      result.rawColls + result.bonusRawColls,
      cachedCollIndex,
      Math.Rounding.Down
    );
    position.debts -= uint96(debtShareToRebalance);
    position.colls -= uint96(collShareToRebalance);

    {
      int256 tick;
      (tick, position.nodeId) = _addPositionToTick(position.colls, position.debts, false);
      position.tick = int16(tick);
    }
    positionData[positionId] = position;
    unchecked {
      (uint256 totalDebts, uint256 totalColls) = _getDebtAndCollateralShares();
      _updateDebtAndCollateralShares(totalDebts - debtShareToRebalance, totalColls - collShareToRebalance);
    }

    emit PositionSnapshot(positionId, position.tick, position.colls, position.debts, price);
  }

  /// @inheritdoc IPool
  function liquidate(
    uint256 positionId,
    uint256 maxRawDebts,
    uint256 reservedRawColls
  ) external onlyPoolManager returns (LiquidateResult memory result) {
    _requireOwned(positionId);

    (uint256 cachedCollIndex, uint256 cachedDebtIndex) = _updateCollAndDebtIndex();
    (, uint256 price, ) = IPriceOracle(priceOracle).getPrice(); // use min price
    PositionInfo memory position = _getAndUpdatePosition(positionId);
    uint256 positionRawColl = _convertToRawColl(position.colls, cachedCollIndex, Math.Rounding.Down);
    uint256 positionRawDebt = _convertToRawDebt(position.debts, cachedDebtIndex, Math.Rounding.Down);
    uint256 liquidateBonusRatio;
    // liquidate only debt ratio >= `liquidateDebtRatio`
    {
      uint256 liquidateDebtRatio;
      (liquidateDebtRatio, liquidateBonusRatio) = _getLiquidateRatios();
      if (positionRawDebt * PRECISION * PRECISION < liquidateDebtRatio * positionRawColl * price) {
        revert ErrorLiquidateDebtRatioNotReached();
      }
    }

    _removePositionFromTick(position);

    result.rawDebts = positionRawDebt;
    if (result.rawDebts > maxRawDebts) result.rawDebts = maxRawDebts;
    uint256 debtShareToLiquidate = result.rawDebts == positionRawDebt
      ? position.debts
      : _convertToDebtShares(result.rawDebts, cachedDebtIndex, Math.Rounding.Down);
    uint256 collShareToLiquidate;
    result.rawColls = (result.rawDebts * PRECISION) / price;
    if (positionRawColl < result.rawColls) {
      // adjust result.rawColls, result.rawDebts and debtShareToLiquidate
      result.rawColls = positionRawColl;
      result.rawDebts = (positionRawColl * price) / PRECISION;
      if (result.rawDebts > positionRawDebt) result.rawDebts = positionRawDebt;
      debtShareToLiquidate = result.rawDebts == positionRawDebt
        ? position.debts
        : _convertToDebtShares(result.rawDebts, cachedDebtIndex, Math.Rounding.Down);
    }

    result.bonusRawColls = (result.rawColls * liquidateBonusRatio) / FEE_PRECISION;
    if (result.bonusRawColls > positionRawColl - result.rawColls) {
      uint256 diff = result.bonusRawColls - (positionRawColl - result.rawColls);
      if (diff < reservedRawColls) result.bonusFromReserve = diff;
      else result.bonusFromReserve = reservedRawColls;
      result.bonusRawColls = positionRawColl - result.rawColls + result.bonusFromReserve;

      collShareToLiquidate = position.colls;
    } else {
      collShareToLiquidate = _convertToCollShares(
        result.rawColls + result.bonusRawColls,
        cachedCollIndex,
        Math.Rounding.Down
      );
    }
    position.debts -= uint96(debtShareToLiquidate);
    position.colls -= uint96(collShareToLiquidate);

    unchecked {
      (uint256 totalDebts, uint256 totalColls) = _getDebtAndCollateralShares();
      _updateDebtAndCollateralShares(totalDebts - debtShareToLiquidate, totalColls - collShareToLiquidate);
    }

    // try distribute bad debts
    if (position.colls == 0 && position.debts > 0) {
      (uint256 totalDebts, ) = _getDebtAndCollateralShares();
      totalDebts -= position.debts;
      _updateDebtShares(totalDebts);
      uint256 rawBadDebt = _convertToRawDebt(position.debts, cachedDebtIndex, Math.Rounding.Down);
      _updateDebtIndex(cachedDebtIndex + (rawBadDebt * E96) / totalDebts);
      position.debts = 0;
    }
    {
      int256 tick;
      (tick, position.nodeId) = _addPositionToTick(position.colls, position.debts, false);
      position.tick = int16(tick);
    }
    positionData[positionId] = position;

    emit PositionSnapshot(positionId, position.tick, position.colls, position.debts, price);
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Update the borrow and redeem status.
  /// @param borrowStatus The new borrow status.
  /// @param redeemStatus The new redeem status.
  function updateBorrowAndRedeemStatus(bool borrowStatus, bool redeemStatus) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateBorrowStatus(borrowStatus);
    _updateRedeemStatus(redeemStatus);
  }

  /// @notice Update debt ratio range.
  /// @param minRatio The minimum allowed debt ratio to update, multiplied by 1e18.
  /// @param maxRatio The maximum allowed debt ratio to update, multiplied by 1e18.
  function updateDebtRatioRange(uint256 minRatio, uint256 maxRatio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateDebtRatioRange(minRatio, maxRatio);
  }

  /// @notice Update maximum redeem ratio per tick.
  /// @param ratio The ratio to update, multiplied by 1e9.
  function updateMaxRedeemRatioPerTick(uint256 ratio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateMaxRedeemRatioPerTick(ratio);
  }

  /// @notice Update ratio for rebalance.
  /// @param debtRatio The minimum debt ratio to start rebalance, multiplied by 1e18.
  /// @param bonusRatio The bonus ratio during rebalance, multiplied by 1e9.
  function updateRebalanceRatios(uint256 debtRatio, uint256 bonusRatio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateRebalanceRatios(debtRatio, bonusRatio);
  }

  /// @notice Update ratio for liquidate.
  /// @param debtRatio The minimum debt ratio to start liquidate, multiplied by 1e18.
  /// @param bonusRatio The bonus ratio during liquidate, multiplied by 1e9.
  function updateLiquidateRatios(uint256 debtRatio, uint256 bonusRatio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateLiquidateRatios(debtRatio, bonusRatio);
  }

  /// @notice Update the address of price oracle.
  /// @param newOracle The address of new price oracle.
  function updatePriceOracle(address newOracle) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updatePriceOracle(newOracle);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to compute the amount of debt to rebalance to reach certain debt ratio.
  /// @param coll The amount of collateral tokens.
  /// @param debt The amount of debt tokens.
  /// @param price The price of the collateral token.
  /// @param targetDebtRatio The target debt ratio, multiplied by 1e18.
  /// @param incentiveRatio The bonus ratio, multiplied by 1e9.
  /// @return rawDebts The amount of debt tokens to rebalance.
  function _getRawDebtToRebalance(
    uint256 coll,
    uint256 debt,
    uint256 price,
    uint256 targetDebtRatio,
    uint256 incentiveRatio
  ) internal pure returns (uint256 rawDebts) {
    // we have
    //   1. (debt - x) / (price * (coll - y * (1 + incentive))) <= target_ratio
    //   2. debt / (price * coll) >= target_ratio
    // then
    // => debt - x <= target * price * (coll - y * (1 + incentive)) and y = x / price
    // => debt - target_ratio * price * coll <= (1 - (1 + incentive) * target) * x
    // => x >= (debt - target_ratio * price * coll) / (1 - (1 + incentive) * target)
    rawDebts =
      (debt * PRECISION * PRECISION - targetDebtRatio * price * coll) /
      (PRECISION * PRECISION - (PRECISION * targetDebtRatio * (FEE_PRECISION + incentiveRatio)) / FEE_PRECISION);
  }

  /// @dev Internal function to update collateral and debt index.
  /// @return newCollIndex The updated collateral index.
  /// @return newDebtIndex The updated debt index.
  function _updateCollAndDebtIndex() internal virtual returns (uint256 newCollIndex, uint256 newDebtIndex);

  /// @dev Internal function to compute the protocol fees.
  /// @param rawColl The amount of collateral tokens involved.
  /// @return fees The expected protocol fees.
  function _deductProtocolFees(int256 rawColl) internal view virtual returns (uint256 fees);

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   */
  uint256[50] private __gap;
}

// File: contracts/core/pool/AaveFundingPool.sol

pragma solidity ^0.8.26;









contract AaveFundingPool is BasePool, IAaveFundingPool {
  using WordCodec for bytes32;

  /*************
   * Constants *
   *************/

  /// @dev The offset of *open ratio* in `fundingMiscData`.
  uint256 private constant OPEN_RATIO_OFFSET = 0;

  /// @dev The offset of *open ratio step* in `fundingMiscData`.
  uint256 private constant OPEN_RATIO_STEP_OFFSET = 30;

  /// @dev The offset of *close fee ratio* in `fundingMiscData`.
  uint256 private constant CLOSE_FEE_RATIO_OFFSET = 90;

  /// @dev The offset of *funding ratio* in `fundingMiscData`.
  uint256 private constant FUNDING_RATIO_OFFSET = 120;

  /// @dev The offset of *interest rate* in `fundingMiscData`.
  uint256 private constant INTEREST_RATE_OFFSET = 152;

  /// @dev The offset of *timestamp* in `fundingMiscData`.
  uint256 private constant TIMESTAMP_OFFSET = 220;

  /// @dev The maximum value of *funding ratio*.
  uint256 private constant MAX_FUNDING_RATIO = 4294967295;

  /// @dev The minimum Aave borrow index snapshot delay.
  uint256 private constant MIN_SNAPSHOT_DELAY = 30 minutes;

  /***********************
   * Immutable Variables *
   ***********************/

  /// @dev The address of Aave V3 `LendingPool` contract.
  address private immutable lendingPool;

  /// @dev The address of asset used for interest calculation.
  address private immutable baseAsset;

  /***********
   * Structs *
   ***********/

  /// @dev The struct for AAVE borrow rate snapshot.
  /// @param borrowIndex The current borrow index of AAVE, multiplied by 1e27.
  /// @param lastInterestRate The last recorded interest rate, multiplied by 1e18.
  /// @param timestamp The timestamp when the snapshot is taken.
  struct BorrowRateSnapshot {
    // The initial value of `borrowIndex` is `10^27`, it is very unlikely this value will exceed `2^128`.
    uint128 borrowIndex;
    uint80 lastInterestRate;
    uint48 timestamp;
  }

  /*********************
   * Storage Variables *
   *********************/

  /// @dev `fundingMiscData` is a storage slot that can be used to store unrelated pieces of information.
  ///
  /// - The *open ratio* is the fee ratio for opening position, multiplied by 1e9.
  /// - The *open ratio step* is the fee ratio step for opening position, multiplied by 1e18.
  /// - The *close fee ratio* is the fee ratio for closing position, multiplied by 1e9.
  /// - The *funding ratio* is the scalar for funding rate, multiplied by 1e9.
  ///   The maximum value is `4.294967296`.
  ///
  /// [ open ratio | open ratio step | close fee ratio | funding ratio | reserved ]
  /// [  30  bits  |     60 bits     |     30 bits     |    32 bits    | 104 bits ]
  /// [ MSB                                                                   LSB ]
  bytes32 private fundingMiscData;

  /// @notice The snapshot for AAVE borrow rate.
  BorrowRateSnapshot public borrowRateSnapshot;

  /***************
   * Constructor *
   ***************/

  constructor(address _poolManager, address _lendingPool, address _baseAsset) BasePool(_poolManager) {
    _checkAddressNotZero(_lendingPool);
    _checkAddressNotZero(_baseAsset);

    lendingPool = _lendingPool;
    baseAsset = _baseAsset;
  }

  function initialize(
    address admin,
    string memory name_,
    string memory symbol_,
    address _collateralToken,
    address _priceOracle
  ) external initializer {
    __Context_init();
    __ERC165_init();
    __ERC721_init(name_, symbol_);
    __AccessControl_init();

    __PoolStorage_init(_collateralToken, _priceOracle);
    __TickLogic_init();
    __PositionLogic_init();
    __BasePool_init();

    _grantRole(DEFAULT_ADMIN_ROLE, admin);

    _updateOpenRatio(1000000, 50000000000000000); // 0.1% and 5%
    _updateCloseFeeRatio(1000000); // 0.1%

    uint256 borrowIndex = IAaveV3Pool(lendingPool).getReserveNormalizedVariableDebt(baseAsset);
    IAaveV3Pool.ReserveDataLegacy memory reserveData = IAaveV3Pool(lendingPool).getReserveData(baseAsset);
    _updateInterestRate(borrowIndex, reserveData.currentVariableBorrowRate / 1e9);
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Get open fee ratio related parameters.
  /// @return ratio The value of open ratio, multiplied by 1e9.
  /// @return step The value of open ratio step, multiplied by 1e18.
  function getOpenRatio() external view returns (uint256 ratio, uint256 step) {
    return _getOpenRatio();
  }

  /// @notice Return the value of funding ratio, multiplied by 1e9.
  function getFundingRatio() external view returns (uint256) {
    return _getFundingRatio();
  }

  /// @notice Return the fee ratio for opening position, multiplied by 1e9.
  function getOpenFeeRatio() public view returns (uint256) {
    (uint256 openRatio, uint256 openRatioStep) = _getOpenRatio();
    (, uint256 rate) = _getAverageInterestRate(borrowRateSnapshot);
    unchecked {
      uint256 aaveRatio = rate <= openRatioStep ? 1 : (rate - 1) / openRatioStep;
      return aaveRatio * openRatio;
    }
  }

  /// @notice Return the fee ratio for closing position, multiplied by 1e9.
  function getCloseFeeRatio() external view returns (uint256) {
    return _getCloseFeeRatio();
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Update the fee ratio for opening position.
  /// @param ratio The open ratio value, multiplied by 1e9.
  /// @param step The open ratio step value, multiplied by 1e18.
  function updateOpenRatio(uint256 ratio, uint256 step) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateOpenRatio(ratio, step);
  }

  /// @notice Update the fee ratio for closing position.
  /// @param ratio The close ratio value, multiplied by 1e9.
  function updateCloseFeeRatio(uint256 ratio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateCloseFeeRatio(ratio);
  }

  /// @notice Update the funding ratio.
  /// @param ratio The funding ratio value, multiplied by 1e9.
  function updateFundingRatio(uint256 ratio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateFundingRatio(ratio);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to get open ratio and open ratio step.
  /// @return ratio The value of open ratio, multiplied by 1e9.
  /// @return step The value of open ratio step, multiplied by 1e18.
  function _getOpenRatio() internal view returns (uint256 ratio, uint256 step) {
    bytes32 data = fundingMiscData;
    ratio = data.decodeUint(OPEN_RATIO_OFFSET, 30);
    step = data.decodeUint(OPEN_RATIO_STEP_OFFSET, 60);
  }

  /// @dev Internal function to update the fee ratio for opening position.
  /// @param ratio The open ratio value, multiplied by 1e9.
  /// @param step The open ratio step value, multiplied by 1e18.
  function _updateOpenRatio(uint256 ratio, uint256 step) internal {
    _checkValueTooLarge(ratio, FEE_PRECISION);
    _checkValueTooLarge(step, PRECISION);

    bytes32 data = fundingMiscData;
    data = data.insertUint(ratio, OPEN_RATIO_OFFSET, 30);
    fundingMiscData = data.insertUint(step, OPEN_RATIO_STEP_OFFSET, 60);

    emit UpdateOpenRatio(ratio, step);
  }

  /// @dev Internal function to get the value of close ratio, multiplied by 1e9.
  function _getCloseFeeRatio() internal view returns (uint256) {
    return fundingMiscData.decodeUint(CLOSE_FEE_RATIO_OFFSET, 30);
  }

  /// @dev Internal function to update the fee ratio for closing position.
  /// @param newRatio The close fee ratio value, multiplied by 1e9.
  function _updateCloseFeeRatio(uint256 newRatio) internal {
    _checkValueTooLarge(newRatio, FEE_PRECISION);

    bytes32 data = fundingMiscData;
    uint256 oldRatio = data.decodeUint(CLOSE_FEE_RATIO_OFFSET, 30);
    fundingMiscData = data.insertUint(newRatio, CLOSE_FEE_RATIO_OFFSET, 30);

    emit UpdateCloseFeeRatio(oldRatio, newRatio);
  }

  /// @dev Internal function to get the value of funding ratio, multiplied by 1e9.
  function _getFundingRatio() internal view returns (uint256) {
    return fundingMiscData.decodeUint(FUNDING_RATIO_OFFSET, 32);
  }

  /// @dev Internal function to update the funding ratio.
  /// @param newRatio The funding ratio value, multiplied by 1e9.
  function _updateFundingRatio(uint256 newRatio) internal {
    _checkValueTooLarge(newRatio, MAX_FUNDING_RATIO);

    bytes32 data = fundingMiscData;
    uint256 oldRatio = data.decodeUint(FUNDING_RATIO_OFFSET, 32);
    fundingMiscData = data.insertUint(newRatio, FUNDING_RATIO_OFFSET, 32);

    emit UpdateFundingRatio(oldRatio, newRatio);
  }

  /// @dev Internal function to return interest rate snapshot.
  /// @param snapshot The previous borrow index snapshot.
  /// @return newBorrowIndex The current borrow index, multiplied by 1e27.
  /// @return rate The annual interest rate, multiplied by 1e18.
  function _getAverageInterestRate(
    BorrowRateSnapshot memory snapshot
  ) internal view returns (uint256 newBorrowIndex, uint256 rate) {
    uint256 prevBorrowIndex = snapshot.borrowIndex;
    newBorrowIndex = IAaveV3Pool(lendingPool).getReserveNormalizedVariableDebt(baseAsset);
    // absolute rate change is (new - prev) / prev
    // annual interest rate is (new - prev) / prev / duration * 365 days
    uint256 duration = block.timestamp - snapshot.timestamp;
    if (duration < MIN_SNAPSHOT_DELAY) {
      rate = snapshot.lastInterestRate;
    } else {
      rate = ((newBorrowIndex - prevBorrowIndex) * 365 days * PRECISION) / (prevBorrowIndex * duration);
      if (rate == 0) rate = snapshot.lastInterestRate;
    }
  }

  /// @dev Internal function to update interest rate snapshot.
  function _updateInterestRate(uint256 newBorrowIndex, uint256 lastInterestRate) internal {
    BorrowRateSnapshot memory snapshot = borrowRateSnapshot;
    // don't update snapshot when the duration is too small.
    if (snapshot.timestamp > 0 && block.timestamp - snapshot.timestamp < MIN_SNAPSHOT_DELAY) return;

    snapshot.borrowIndex = uint128(newBorrowIndex);
    snapshot.lastInterestRate = uint80(lastInterestRate);
    snapshot.timestamp = uint48(block.timestamp);
    borrowRateSnapshot = snapshot;

    emit SnapshotAaveBorrowIndex(newBorrowIndex, block.timestamp);
  }

  /// @inheritdoc BasePool
  function _updateCollAndDebtIndex() internal virtual override returns (uint256 newCollIndex, uint256 newDebtIndex) {
    (newDebtIndex, newCollIndex) = _getDebtAndCollateralIndex();

    BorrowRateSnapshot memory snapshot = borrowRateSnapshot;
    uint256 duration = block.timestamp - snapshot.timestamp;
    if (duration > 0) {
      (uint256 borrowIndex, uint256 interestRate) = _getAverageInterestRate(snapshot);
      if (IPegKeeper(pegKeeper).isFundingEnabled()) {
        (, uint256 totalColls) = _getDebtAndCollateralShares();
        uint256 totalRawColls = _convertToRawColl(totalColls, newCollIndex, Math.Rounding.Down);
        uint256 funding = (totalRawColls * interestRate * duration) / (365 days * PRECISION);
        funding = ((funding * _getFundingRatio()) / FEE_PRECISION);

        // update collateral index with funding costs
        newCollIndex = (newCollIndex * totalRawColls) / (totalRawColls - funding);
        _updateCollateralIndex(newCollIndex);
      }

      // update interest snapshot
      _updateInterestRate(borrowIndex, interestRate);
    }
  }

  /// @inheritdoc BasePool
  function _deductProtocolFees(int256 rawColl) internal view virtual override returns (uint256) {
    if (rawColl > 0) {
      // open position or add collateral
      uint256 feeRatio = getOpenFeeRatio();
      if (feeRatio > FEE_PRECISION) feeRatio = FEE_PRECISION;
      return (uint256(rawColl) * feeRatio) / FEE_PRECISION;
    } else {
      // close position or remove collateral
      return (uint256(-rawColl) * _getCloseFeeRatio()) / FEE_PRECISION;
    }
  }
}

// File: contracts/helpers/EmptyContract.sol

pragma solidity ^0.8.26;

contract EmptyContract {}

// File: contracts/helpers/External.sol

pragma solidity ^0.8.26;

// File: contracts/helpers/GaugeRewarder.sol

pragma solidity ^0.8.26;









contract GaugeRewarder is PermissionedSwap, IRewardSplitter {
  using SafeERC20 for IERC20;

  /***********************
   * Immutable Variables *
   ***********************/

  /// @notice The address of `LiquidityGauge` contract.
  address public immutable gauge;

  /***************
   * Constructor *
   ***************/

  constructor(address _gauge) initializer {
    __Context_init();
    __ERC165_init();
    __AccessControl_init();

    gauge = _gauge;

    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IRewardSplitter
  function split(address token) external override {
    // do nothing
  }

  /// @inheritdoc IRewardSplitter
  function depositReward(address token, uint256 amount) external override {
    IERC20(token).safeTransferFrom(_msgSender(), address(this), amount);
  }

  /// @notice Harvest base token to target token by amm trading and distribute to fxBASE gauge.
  /// @param baseToken The address of base token to use.
  /// @param targetToken The address target token.
  /// @param params The parameters used for trading.
  /// @return amountOut The amount of target token received.
  function swapAndDistribute(
    address baseToken,
    address targetToken,
    TradingParameter memory params
  ) external returns (uint256 amountOut) {
    uint256 amountIn = IERC20(baseToken).balanceOf(address(this));

    // swap base token to target
    amountOut = _doTrade(baseToken, targetToken, amountIn, params);

    // deposit target token to gauge
    IERC20(targetToken).forceApprove(gauge, amountOut);
    IMultipleRewardDistributor(gauge).depositReward(targetToken, amountOut);
  }
}

// File: contracts/helpers/RevenuePool.sol

pragma solidity ^0.8.26;





// copy from: https://github.com/AladdinDAO/aladdin-v3-contracts/blob/main/contracts/helpers/PlatformFeeSpliter.sol
contract RevenuePool is Ownable {
  using SafeERC20 for IERC20;

  /**********
   * Events *
   **********/

  /// @notice Emitted when the address of staker contract is updated.
  /// @param staker The address of new staker contract.
  event UpdateStaker(address staker);

  /// @notice Emitted when the address of treasury contract is updated.
  /// @param treasury The address of new treasury contract.
  event UpdateTreasury(address treasury);

  /// @notice Emitted when the address of ecosystem contract is updated.
  /// @param ecosystem The address of new ecosystem contract.
  event UpdateEcosystem(address ecosystem);

  /// @notice Emitted when a new reward token is added.
  /// @param token The address of reward token.
  /// @param burner The address of token burner contract.
  /// @param stakerRatio The ratio of token distributed to liquidity stakers, multipled by 1e9.
  /// @param treasuryRatio The ratio of token distributed to treasury, multipled by 1e9.
  /// @param lockerRatio The ratio of token distributed to ve token lockers, multipled by 1e9.
  event AddRewardToken(address token, address burner, uint256 stakerRatio, uint256 treasuryRatio, uint256 lockerRatio);

  /// @notice Emitted when the percentage is updated for existing reward token.
  /// @param token The address of reward token.
  /// @param stakerRatio The ratio of token distributed to liquidity stakers, multipled by 1e9.
  /// @param treasuryRatio The ratio of token distributed to treasury, multipled by 1e9.
  /// @param lockerRatio The ratio of token distributed to ve token lockers, multipled by 1e9.
  event UpdateRewardTokenRatio(address token, uint256 stakerRatio, uint256 treasuryRatio, uint256 lockerRatio);

  /// @notice Emitted when the address of token burner is updated.
  /// @param token The address of reward token.
  /// @param burner The address of token burner contract.
  event UpdateRewardTokenBurner(address token, address burner);

  /// @notice Emitted when a reward token is removed.
  /// @param token The address of reward token.
  event RemoveRewardToken(address token);

  /*************
   * Constants *
   *************/

  /// @dev The fee denominator used for ratio calculation.
  uint256 private constant FEE_PRECISION = 1e9;

  /***********
   * Structs *
   ***********/

  struct RewardInfo {
    // The address of reward token.
    address token;
    // The ratio of token distributed to liquidity stakers, multipled by 1e9.
    uint32 stakerRatio;
    // The ratio of token distributed to treasury, multipled by 1e9.
    uint32 treasuryRatio;
    // The ratio of token distributed to ve token lockers, multipled by 1e9.
    uint32 lockerRatio;
    // @note The rest token will transfer to ecosystem fund for future usage.
  }

  /*************
   * Variables *
   *************/

  /// @notice The address of contract used to hold treasury fund.
  address public treasury;

  /// @notice The address of contract used to hold ecosystem fund.
  address public ecosystem;

  /// @notice The address of contract used to distribute incentive for liquidity stakers.
  address public staker;

  /// @notice The list of rewards token.
  RewardInfo[] public rewards;

  /// @notice Mapping from reward token address to corresponding token burner.
  mapping(address => address) public burners;

  /***************
   * Constructor *
   ***************/

  constructor(
    address _treasury,
    address _ecosystem,
    address _staker
  ) Ownable(_msgSender()) {
    _ensureNonZeroAddress(_treasury, "treasury");
    _ensureNonZeroAddress(_ecosystem, "ecosystem");
    _ensureNonZeroAddress(_staker, "staker");

    treasury = _treasury;
    ecosystem = _ecosystem;
    staker = _staker;
  }

  /// @notice Return the number of reward tokens.
  function getRewardCount() external view returns (uint256) {
    return rewards.length;
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Claim and distribute pending rewards to staker/treasury/locker/ecosystem contract.
  /// @dev The function can only be called by staker contract.
  function claim() external {
    address _staker = staker;
    require(msg.sender == _staker, "not staker");

    address _treasury = treasury;
    address _ecosystem = ecosystem;

    uint256 _length = rewards.length;
    for (uint256 i = 0; i < _length; i++) {
      RewardInfo memory _reward = rewards[i];
      uint256 _balance = IERC20(_reward.token).balanceOf(address(this));
      if (_balance > 0) {
        uint256 _stakerAmount = (_reward.stakerRatio * _balance) / FEE_PRECISION;
        uint256 _treasuryAmount = (_reward.treasuryRatio * _balance) / FEE_PRECISION;
        uint256 _lockerAmount = (_reward.lockerRatio * _balance) / FEE_PRECISION;
        uint256 _ecosystemAmount = _balance - _stakerAmount - _treasuryAmount - _lockerAmount;

        if (_stakerAmount > 0) {
          IERC20(_reward.token).safeTransfer(_staker, _stakerAmount);
        }
        if (_treasuryAmount > 0) {
          IERC20(_reward.token).safeTransfer(_treasury, _treasuryAmount);
        }
        if (_lockerAmount > 0) {
          IERC20(_reward.token).safeTransfer(burners[_reward.token], _lockerAmount);
        }
        if (_ecosystemAmount > 0) {
          IERC20(_reward.token).safeTransfer(_ecosystem, _ecosystemAmount);
        }
      }
    }
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Update the address of treasury contract.
  /// @param _treasury The address of new treasury contract.
  function updateTreasury(address _treasury) external onlyOwner {
    _ensureNonZeroAddress(_treasury, "treasury");

    treasury = _treasury;

    emit UpdateTreasury(_treasury);
  }

  /// @notice Update the address of ecosystem contract.
  /// @param _ecosystem The address of new ecosystem contract.
  function updateEcosystem(address _ecosystem) external onlyOwner {
    _ensureNonZeroAddress(_ecosystem, "ecosystem");

    ecosystem = _ecosystem;

    emit UpdateEcosystem(_ecosystem);
  }

  /// @notice Update the address of staker contract.
  /// @param _staker The address of new staker contract.
  function updateStaker(address _staker) external onlyOwner {
    _ensureNonZeroAddress(_staker, "staker");

    staker = _staker;

    emit UpdateStaker(_staker);
  }

  /// @notice Add a new reward token.
  /// @param _token The address of reward token.
  /// @param _burner The address of corresponding token burner.
  /// @param _stakerRatio The ratio of token distributed to liquidity stakers, multipled by 1e9.
  /// @param _treasuryRatio The ratio of token distributed to treasury, multipled by 1e9.
  /// @param _lockerRatio The ratio of token distributed to ve token lockers, multipled by 1e9.
  function addRewardToken(
    address _token,
    address _burner,
    uint32 _stakerRatio,
    uint32 _treasuryRatio,
    uint32 _lockerRatio
  ) external onlyOwner {
    _checkRatioRange(_stakerRatio, _treasuryRatio, _lockerRatio);
    _ensureNonZeroAddress(_burner, "burner");

    require(burners[_token] == address(0), "duplicated reward token");
    burners[_token] = _burner;

    rewards.push(RewardInfo(_token, _stakerRatio, _treasuryRatio, _lockerRatio));

    emit AddRewardToken(_token, _burner, _stakerRatio, _treasuryRatio, _lockerRatio);
  }

  /// @notice Update reward ratio of existing reward token.
  /// @param _index The index of reward token.
  /// @param _stakerRatio The ratio of token distributed to liquidity stakers, multipled by 1e9.
  /// @param _treasuryRatio The ratio of token distributed to treasury, multipled by 1e9.
  /// @param _lockerRatio The ratio of token distributed to ve token lockers, multipled by 1e9.
  function updateRewardTokenRatio(
    uint256 _index,
    uint32 _stakerRatio,
    uint32 _treasuryRatio,
    uint32 _lockerRatio
  ) external onlyOwner {
    _checkRatioRange(_stakerRatio, _treasuryRatio, _lockerRatio);
    require(_index < rewards.length, "index out of range");

    RewardInfo memory _info = rewards[_index];
    _info.stakerRatio = _stakerRatio;
    _info.treasuryRatio = _treasuryRatio;
    _info.lockerRatio = _lockerRatio;

    rewards[_index] = _info;
    emit UpdateRewardTokenRatio(_info.token, _stakerRatio, _treasuryRatio, _lockerRatio);
  }

  /// @notice Update the token burner of existing reward token.
  /// @param _token The address of the reward token.
  /// @param _burner The address of corresponding token burner.
  function updateRewardTokenBurner(address _token, address _burner) external onlyOwner {
    _ensureNonZeroAddress(_burner, "new burner");
    _ensureNonZeroAddress(burners[_token], "old burner");

    burners[_token] = _burner;

    emit UpdateRewardTokenBurner(_token, _burner);
  }

  /// @notice Remove an existing reward token.
  /// @param _index The index of reward token.
  function removeRewardToken(uint256 _index) external onlyOwner {
    uint256 _length = rewards.length;
    require(_index < _length, "index out of range");

    address _token = rewards[_index].token;
    if (_index != _length - 1) {
      rewards[_index] = rewards[_length - 1];
    }
    rewards.pop();

    burners[_token] = address(0);

    emit RemoveRewardToken(_token);
  }

  /**********************
   * Internal Functions *
   **********************/

  function _checkRatioRange(
    uint32 _stakerRatio,
    uint32 _treasuryRatio,
    uint32 _lockerRatio
  ) internal pure {
    require(_stakerRatio <= FEE_PRECISION, "staker ratio too large");
    require(_treasuryRatio <= FEE_PRECISION, "treasury ratio too large");
    require(_lockerRatio <= FEE_PRECISION, "locker ratio too large");
    require(_stakerRatio + _treasuryRatio + _lockerRatio <= FEE_PRECISION, "ecosystem ratio too small");
  }

  function _ensureNonZeroAddress(address _addr, string memory _name) internal pure {
    require(_addr != address(0), string(abi.encodePacked(_name, " address should not be zero")));
  }
}

// File: contracts/interfaces/IWrappedEther.sol

pragma solidity ^0.8.0;

interface IWrappedEther {
  function deposit() external payable;

  function withdraw(uint256 wad) external;
}

// File: contracts/helpers/interfaces/ITokenConverter.sol

pragma solidity ^0.8.0;

interface ITokenConverter {
  /*************************
   * Public View Functions *
   *************************/

  /// @notice The address of Converter Registry.
  function registry() external view returns (address);

  /// @notice Return the input token and output token for the route.
  /// @param route The encoding of the route.
  /// @return tokenIn The address of input token.
  /// @return tokenOut The address of output token.
  function getTokenPair(uint256 route) external view returns (address tokenIn, address tokenOut);

  /// @notice Query the output token amount according to the encoding.
  ///
  /// @dev See the comments in `convert` for the meaning of encoding.
  ///
  /// @param encoding The encoding used to convert.
  /// @param amountIn The amount of input token.
  /// @param amountOut The amount of output token received.
  function queryConvert(uint256 encoding, uint256 amountIn) external returns (uint256 amountOut);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Convert input token to output token according to the encoding.
  /// Assuming that the input token is already in the contract.
  ///
  /// @dev encoding for single route
  /// |   8 bits  | 2 bits |  246 bits  |
  /// | pool_type | action | customized |
  ///
  /// + pool_type = 0: UniswapV2, only action = 0
  ///   customized = |   160 bits   | 24 bits |     1 bit    | 1 bit | ... |
  ///                | pool address | fee_num | zero_for_one | twamm | ... |
  /// + pool_type = 1: UniswapV3, only action = 0
  ///   customized = |   160 bits   | 24 bits |     1 bit    | ... |
  ///                | pool address | fee_num | zero_for_one | ... |
  /// + pool_type = 2: BalancerV1, only action = 0
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  | ... |
  ///                | pool address | tokens | index in | index out | ... |
  /// + pool_type = 3: BalancerV2, only action = 0
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  | ... |
  ///                | pool address | tokens | index in | index out | ... |
  /// + pool_type = 4: CurvePlainPool or CurveFactoryPlainPool
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  |  1 bit  | ... |
  ///                | pool address | tokens | index in | index out | use_eth | ... |
  /// + pool_type = 5: CurveAPool
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  |     1 bits     | ... |
  ///                | pool address | tokens | index in | index out | use_underlying | ... |
  /// + pool_type = 6: CurveYPool
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  |     1 bits     | ... |
  ///                | pool address | tokens | index in | index out | use_underlying | ... |
  /// + pool_type = 7: CurveMetaPool or CurveFactoryMetaPool
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  | ... |
  ///                | pool address | tokens | index in | index out | ... |
  /// + pool_type = 8: CurveCryptoPool or CurveFactoryCryptoPool
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  |  1 bit  | ... |
  ///                | pool address | tokens | index in | index out | use_eth | ... |
  /// + pool_type = 9: ERC4626, no action 0
  ///   customized = |   160 bits   | ... |
  ///                | pool address | ... |
  /// + pool_type = 10: Lido, no action 0
  ///   customized = |   160 bits   | ... |
  ///                | pool address | ... |
  /// + pool_type = 11:  ETHLSDConverter v1, no action 0
  ///   supported in other pool type
  ///     puffer: pufETH is ERC4626, base is stETH
  ///     frax: sfrxETH is ERC4626, base is frxETH
  ///     pirex: apxETH is ERC4626, base is pxETH
  ///   supported in this pool type
  ///     0=wBETH: mint wBETH from ETH
  ///     1=RocketPool: mint rETH from ETH
  ///     2=frax: mint frxETH from ETH
  ///     3=pirex: mint pxETH from ETH
  ///     4=renzo: mint ezETH from ETH, stETH, wBETH
  ///     5=ether.fi: mint eETH from ETH, mint weETH from eETH, unwrap weETH to eETH
  ///     6=kelpdao.xyz: mint rsETH from ETH, ETHx, stETH, sfrxETH, and etc.
  ///   customized = |   160 bits   |  8 bits  | ... |
  ///                | pool address | protocol | ... |
  /// + pool_type = 12: CurveStableSwapNG
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  | ... |
  ///                | pool address | tokens | index in | index out | ... |
  /// + pool_type = 13: CurveStableSwapMetaNG
  ///   customized = |   160 bits   | 3 bits |  3 bits  |   3 bits  | ... |
  ///                | pool address | tokens | index in | index out | ... |
  /// + pool_type = 14: WETH
  ///   customized = |   160 bits   | ... |
  ///                | pool address | ... |
  ///
  /// Note: tokens + 1 is the number of tokens of the pool
  ///
  /// + action = 0: swap
  /// + action = 1: add liquidity / wrap / stake
  /// + action = 2: remove liquidity / unwrap / unstake
  ///
  /// @param encoding The encoding used to convert.
  /// @param amountIn The amount of input token.
  /// @param recipient The address of token receiver.
  /// @return amountOut The amount of output token received.
  function convert(
    uint256 encoding,
    uint256 amountIn,
    address recipient
  ) external payable returns (uint256 amountOut);

  /// @notice Withdraw dust assets in this contract.
  /// @param token The address of token to withdraw.
  /// @param recipient The address of token receiver.
  function withdrawFund(address token, address recipient) external;
}

// File: contracts/helpers/converter/MultiPathConverter.sol

pragma solidity ^0.8.26;








contract MultiPathConverter is IMultiPathConverter {
  using SafeERC20 for IERC20;

  /*************
   * Constants *
   *************/

  /// @dev The address of WETH token.
  address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  /*************
   * Variables *
   *************/

  /// @notice The address of GeneralTokenConverter contract.
  address public immutable converter;

  /***************
   * Constructor *
   ***************/

  constructor(address _converter) {
    converter = _converter;
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @inheritdoc IMultiPathConverter
  function queryConvert(
    uint256 _amount,
    uint256 _encoding,
    uint256[] calldata _routes
  ) external returns (uint256 amountOut) {
    uint256 _offset;
    for (uint256 i = 0; i < 8; i++) {
      uint256 _ratio = _encoding & 0xfffff;
      uint256 _length = (_encoding >> 20) & 0xfff;
      if (_ratio == 0) break;

      uint256 _amountIn = (_amount * _ratio) / 0xfffff;
      for (uint256 j = 0; j < _length; j++) {
        _amountIn = ITokenConverter(converter).queryConvert(_routes[_offset], _amountIn);
        _offset += 1;
      }
      _encoding >>= 32;
      amountOut += _amountIn;
    }
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IMultiPathConverter
  function convert(
    address _tokenIn,
    uint256 _amount,
    uint256 _encoding,
    uint256[] memory _routes
  ) external payable returns (uint256 amountOut) {
    if (_tokenIn == address(0)) {
      IWrappedEther(WETH).deposit{ value: _amount }();
      IERC20(WETH).safeTransfer(converter, _amount);
    } else {
      // convert all approved.
      if (_amount == type(uint256).max) {
        _amount = IERC20(_tokenIn).allowance(msg.sender, address(this));
      }
      IERC20(_tokenIn).safeTransferFrom(msg.sender, converter, _amount);
    }

    uint256 _offset;
    for (uint256 i = 0; i < 8; i++) {
      uint256 _ratio = _encoding & 0xfffff;
      uint256 _length = (_encoding >> 20) & 0xfff;
      if (_ratio == 0) break;

      uint256 _amountIn = (_amount * _ratio) / 0xfffff;
      for (uint256 j = 0; j < _length; j++) {
        address _recipient = j < _length - 1 ? converter : msg.sender;
        _amountIn = ITokenConverter(converter).convert(_routes[_offset], _amountIn, _recipient);
        _offset += 1;
      }
      _encoding >>= 32;
      amountOut += _amountIn;
    }
  }
}

// File: contracts/interfaces/Balancer/IBalancerVault.sol

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IBalancerVault {
  enum JoinKind {
    INIT,
    EXACT_TOKENS_IN_FOR_BPT_OUT,
    TOKEN_IN_FOR_EXACT_BPT_OUT,
    ALL_TOKENS_IN_FOR_EXACT_BPT_OUT
  }

  enum ExitKind {
    EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
    EXACT_BPT_IN_FOR_TOKENS_OUT,
    BPT_IN_FOR_EXACT_TOKENS_OUT
  }

  enum SwapKind {
    GIVEN_IN,
    GIVEN_OUT
  }

  struct SingleSwap {
    bytes32 poolId;
    SwapKind kind;
    address assetIn;
    address assetOut;
    uint256 amount;
    bytes userData;
  }

  struct FundManagement {
    address sender;
    bool fromInternalBalance;
    address payable recipient;
    bool toInternalBalance;
  }

  function getPoolTokens(bytes32 poolId)
    external
    view
    returns (
      address[] memory tokens,
      uint256[] memory balances,
      uint256 lastChangeBlock
    );

  function swap(
    SingleSwap memory singleSwap,
    FundManagement memory funds,
    uint256 limit,
    uint256 deadline
  ) external payable returns (uint256 amountCalculated);

  struct JoinPoolRequest {
    address[] assets;
    uint256[] maxAmountsIn;
    bytes userData;
    bool fromInternalBalance;
  }

  function joinPool(
    bytes32 poolId,
    address sender,
    address recipient,
    JoinPoolRequest memory request
  ) external payable;

  struct ExitPoolRequest {
    address[] assets;
    uint256[] minAmountsOut;
    bytes userData;
    bool toInternalBalance;
  }

  function exitPool(
    bytes32 poolId,
    address sender,
    address payable recipient,
    ExitPoolRequest memory request
  ) external;

  /**
   * @dev Data for each individual swap executed by `batchSwap`. The asset in and out fields are indexes into the
   * `assets` array passed to that function, and ETH assets are converted to WETH.
   *
   * If `amount` is zero, the multihop mechanism is used to determine the actual amount based on the amount in/out
   * from the previous swap, depending on the swap kind.
   *
   * The `userData` field is ignored by the Vault, but forwarded to the Pool in the `onSwap` hook, and may be
   * used to extend swap behavior.
   */
  struct BatchSwapStep {
    bytes32 poolId;
    uint256 assetInIndex;
    uint256 assetOutIndex;
    uint256 amount;
    bytes userData;
  }

  // This function is not marked as `nonReentrant` because the underlying mechanism relies on reentrancy
  function queryBatchSwap(
    SwapKind kind,
    BatchSwapStep[] memory swaps,
    address[] memory assets,
    FundManagement memory funds
  ) external returns (int256[] memory);

  function flashLoan(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts,
    bytes memory userData
  ) external;
}

// File: contracts/interfaces/Balancer/IFlashLoanRecipient.sol

pragma solidity ^0.8.0;

interface IFlashLoanRecipient {
  /**
   * @dev When `flashLoan` is called on the Vault, it invokes the `receiveFlashLoan` hook on the recipient.
   *
   * At the time of the call, the Vault will have transferred `amounts` for `tokens` to the recipient. Before this
   * call returns, the recipient must have transferred `amounts` plus `feeAmounts` for each token back to the
   * Vault, or else the entire flash loan will revert.
   *
   * `userData` is the same value passed in the `IVault.flashLoan` call.
   */
  function receiveFlashLoan(
    address[] memory tokens,
    uint256[] memory amounts,
    uint256[] memory feeAmounts,
    bytes memory userData
  ) external;
}

// File: contracts/interfaces/Curve/ICurvePoolOracle.sol

pragma solidity ^0.8.0;

// solhint-disable func-name-mixedcase

interface ICurvePoolOracle {
  /********************
   * Common Functions *
   ********************/

  function ma_exp_time() external view returns (uint256);

  function ma_last_time() external view returns (uint256);

  /***************************
   * Functions of Plain Pool *
   ***************************/

  function get_p() external view returns (uint256);

  function last_price() external view returns (uint256);

  function last_prices() external view returns (uint256);

  function ema_price() external view returns (uint256);

  function price_oracle() external view returns (uint256);

  /************************
   * Functions of NG Pool *
   ************************/

  function get_p(uint256 index) external view returns (uint256);

  /// @notice Returns last price of the coin at index `k` w.r.t the coin
  ///         at index 0.
  /// @dev last_prices returns the quote by the AMM for an infinitesimally small swap
  ///      after the last trade. It is not equivalent to the last traded price, and
  ///      is computed by taking the partial differential of `x` w.r.t `y`. The
  ///      derivative is calculated in `get_p` and then multiplied with price_scale
  ///      to give last_prices.
  /// @param index The index of the coin.
  /// @return uint256 Last logged price of coin.
  function last_price(uint256 index) external view returns (uint256);

  function last_prices(uint256 index) external view returns (uint256);

  function ema_price(uint256 index) external view returns (uint256);

  function price_oracle(uint256 index) external view returns (uint256);
}

// File: contracts/mocks/MockAaveV3Pool.sol

pragma solidity ^0.8.26;



contract MockAaveV3Pool is IAaveV3Pool {
  uint128 public variableBorrowRate;
  uint256 public reserveNormalizedVariableDebt;

  constructor(uint128 _variableBorrowRate) {
    variableBorrowRate = _variableBorrowRate;
  }

  function setVariableBorrowRate(uint128 _variableBorrowRate) external {
    variableBorrowRate = _variableBorrowRate;
  }

  function setReserveNormalizedVariableDebt(uint256 _reserveNormalizedVariableDebt) external {
    reserveNormalizedVariableDebt = _reserveNormalizedVariableDebt;
  }

  function getReserveData(address) external view returns (ReserveDataLegacy memory result) {
    result.currentVariableBorrowRate = variableBorrowRate;
  }

  function getReserveNormalizedVariableDebt(address) external view returns (uint256) {
    return reserveNormalizedVariableDebt;
  }
}

// File: contracts/mocks/MockAggregatorV3Interface.sol

pragma solidity ^0.8.26;



contract MockAggregatorV3Interface is AggregatorV3Interface {
  uint8 public immutable decimals;

  int256 public price;

  constructor(uint8 _decimals, int256 _price) {
    decimals = _decimals;
    price = _price;
  }

  function setPrice(int256 _price) external {
    price = _price;
  }

  function description() external view override returns (string memory) {}

  function version() external view override returns (uint256) {}

  function latestAnswer() external view override returns (uint256) {
    return uint256(price);
  }

  function getRoundData(
    uint80
  )
    external
    view
    override
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
  {
    roundId = 0;
    answer = price;
    startedAt = block.timestamp;
    updatedAt = block.timestamp;
    answeredInRound = 0;
  }

  function latestRoundData()
    external
    view
    override
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
  {
    roundId = 0;
    answer = price;
    startedAt = block.timestamp;
    updatedAt = block.timestamp;
    answeredInRound = 0;
  }
}

// File: contracts/mocks/MockCurveStableSwapNG.sol

pragma solidity ^0.8.26;

contract MockCurveStableSwapNG {
    mapping(uint256 => address) public coins;

    mapping(uint256 => uint256) public price_oracle;

    function setCoin(uint256 index, address token) external {
        coins[index] = token;
    }

    function setPriceOracle(uint256 index, uint256 value) external {
        price_oracle[index] = value;
    }
}

// File: contracts/mocks/MockERC20.sol

pragma solidity ^0.8.26;



contract MockERC20 is ERC20 {
  uint8 private immutable _decimals;

  constructor(string memory _name, string memory _symbol, uint8 __decimals) ERC20(_name, _symbol) {
    _decimals = __decimals;
  }

  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }

  function mint(address _recipient, uint256 _amount) external {
    _mint(_recipient, _amount);
  }
}

// File: contracts/mocks/MockMultiPathConverter.sol

pragma solidity ^0.8.26;






contract MockMultiPathConverter {
  using SafeERC20 for IERC20;

  /*************
   * Constants *
   *************/

  /// @dev The address of WETH token.
  address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  address tokenOut;
  uint256 amountOut;

  function setTokenOut(address _tokenOut, uint256 _amountOut) external {
    tokenOut = _tokenOut;
    amountOut = _amountOut;
  }

  function convert(address _tokenIn, uint256 _amount, uint256, uint256[] calldata) external payable returns (uint256) {
    if (_tokenIn == address(0)) {
      IWrappedEther(WETH).deposit{ value: _amount }();
      IERC20(WETH).safeTransfer(address(this), _amount);
    } else {
      // convert all approved.
      if (_amount == type(uint256).max) {
        _amount = IERC20(_tokenIn).allowance(msg.sender, address(this));
      }
      IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amount);
    }
    IERC20(tokenOut).safeTransfer(msg.sender, amountOut);
    return amountOut;
  }
}

// File: contracts/mocks/MockMultipleRewardDistributor.sol

pragma solidity ^0.8.26;



contract MockMultipleRewardDistributor is LinearMultipleRewardDistributor {
  constructor() LinearMultipleRewardDistributor(1 weeks) {}

  function initialize() external {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function _accumulateReward(address _token, uint256 _amount) internal virtual override {}
}

// File: contracts/mocks/MockPriceOracle.sol

pragma solidity ^0.8.26;



contract MockPriceOracle is IPriceOracle {
  uint256 public anchorPrice;
  uint256 public minPrice;
  uint256 public maxPrice;

  constructor(uint256 _anchorPrice, uint256 _minPrice, uint256 _maxPrice) {
    anchorPrice = _anchorPrice;
    minPrice = _minPrice;
    maxPrice = _maxPrice;
  }

  function setPrices(uint256 _anchorPrice, uint256 _minPrice, uint256 _maxPrice) external {
    anchorPrice = _anchorPrice;
    minPrice = _minPrice;
    maxPrice = _maxPrice;
  }

  function getPrice() external view returns (uint256, uint256, uint256) {
    return (anchorPrice, minPrice, maxPrice);
  }
}

// File: contracts/mocks/MockRateProvider.sol

pragma solidity ^0.8.26;



contract MockRateProvider is IRateProvider {
  uint256 public rate;

  constructor(uint256 _rate) {
    rate = _rate;
  }

  function setRate(uint256 _rate) external {
    rate = _rate;
  }

  function getRate() external view returns (uint256) {
    return rate;
  }
}

// File: contracts/mocks/MockStakedFxUSD.sol

pragma solidity ^0.8.26;






contract MockFxUSDSave {
  /// @notice The address of `PoolManager` contract.
  address public immutable poolManager;

  /// @notice The address of `PegKeeper` contract.
  address public immutable pegKeeper;

  /// @dev This is also the address of FxUSD token.
  address public immutable yieldToken;

  /// @dev The address of USDC token.
  address public immutable stableToken;

  uint256 private immutable stableTokenScale;

  /// @notice The Chainlink USDC/USD price feed.
  /// @dev The encoding is below.
  /// ```text
  /// |  32 bits  | 64 bits |  160 bits  |
  /// | heartbeat |  scale  | price_feed |
  /// |low                          high |
  /// ```
  bytes32 public immutable Chainlink_USDC_USD_Spot;

  constructor(
    address _poolManager,
    address _pegKeeper,
    address _yieldToken,
    address _stableToken,
    bytes32 _Chainlink_USDC_USD_Spot
  ) {
    poolManager = _poolManager;
    pegKeeper = _pegKeeper;
    yieldToken = _yieldToken;
    stableToken = _stableToken;
    Chainlink_USDC_USD_Spot = _Chainlink_USDC_USD_Spot;

    stableTokenScale = 10 ** (18 - IERC20Metadata(_stableToken).decimals());
  }

  function totalYieldToken() external view returns (uint256) {
    return IERC20Metadata(yieldToken).balanceOf(address(this));
  }

  /// @notice The total amount of stable token managed in this contract
  function totalStableToken() external view returns (uint256) {
    return IERC20Metadata(stableToken).balanceOf(address(this));
  }

  function getStableTokenPrice() public view returns (uint256) {
    bytes32 encoding = Chainlink_USDC_USD_Spot;
    address aggregator;
    uint256 scale;
    uint256 heartbeat;
    assembly {
      aggregator := shr(96, encoding)
      scale := and(shr(32, encoding), 0xffffffffffffffff)
      heartbeat := and(encoding, 0xffffffff)
    }
    (, int256 answer, , uint256 updatedAt, ) = AggregatorV3Interface(aggregator).latestRoundData();
    if (answer < 0) revert("invalid");
    if (block.timestamp - updatedAt > heartbeat) revert("expired");
    return uint256(answer) * scale;
  }

  function getStableTokenPriceWithScale() public view returns (uint256) {
    return getStableTokenPrice() * stableTokenScale;
  }

  function rebalance(
    address pool,
    int16 tickId,
    uint256 maxFxUSD,
    uint256 maxStable
  ) external returns (uint256 colls, uint256 yieldTokenUsed, uint256 stableTokenUsed) {
    IERC20Metadata(yieldToken).approve(poolManager, type(uint256).max);
    IERC20Metadata(stableToken).approve(poolManager, type(uint256).max);
    (colls, yieldTokenUsed, stableTokenUsed) = IPoolManager(poolManager).rebalance(
      pool,
      msg.sender,
      tickId,
      maxFxUSD,
      maxStable
    );
  }

  function rebalance(
    address pool,
    uint32 positionId,
    uint256 maxFxUSD,
    uint256 maxStable
  ) external returns (uint256 colls, uint256 yieldTokenUsed, uint256 stableTokenUsed) {
    IERC20Metadata(yieldToken).approve(poolManager, type(uint256).max);
    IERC20Metadata(stableToken).approve(poolManager, type(uint256).max);
    (colls, yieldTokenUsed, stableTokenUsed) = IPoolManager(poolManager).rebalance(
      pool,
      msg.sender,
      positionId,
      maxFxUSD,
      maxStable
    );
  }

  function liquidate(
    address pool,
    uint32 positionId,
    uint256 maxFxUSD,
    uint256 maxStable
  ) external returns (uint256 colls, uint256 yieldTokenUsed, uint256 stableTokenUsed) {
    IERC20Metadata(yieldToken).approve(poolManager, type(uint256).max);
    IERC20Metadata(stableToken).approve(poolManager, type(uint256).max);
    (colls, yieldTokenUsed, stableTokenUsed) = IPoolManager(poolManager).liquidate(
      pool,
      msg.sender,
      positionId,
      maxFxUSD,
      maxStable
    );
  }
}

// File: contracts/periphery/libraries/LibRouter.sol

pragma solidity ^0.8.0;









library LibRouter {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  /**********
   * Errors *
   **********/

  /// @dev Thrown when use unapproved target contract.
  error ErrorTargetNotApproved();

  /// @dev Thrown when msg.value is different from amount.
  error ErrorMsgValueMismatch();

  /// @dev Thrown when the output token is not enough.
  error ErrorInsufficientOutput();

  /// @dev Thrown when the whitelisted account type is incorrect.
  error ErrorNotWhitelisted();

  /*************
   * Constants *
   *************/

  /// @dev The storage slot for router storage.
  bytes32 private constant ROUTER_STORAGE_SLOT = keccak256("diamond.router.storage");

  /// @dev The address of WETH token.
  address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  uint8 internal constant NOT_FLASH_LOAN = 0;

  uint8 internal constant HAS_FLASH_LOAN = 1;

  uint8 internal constant NOT_ENTRANT = 0;

  uint8 internal constant HAS_ENTRANT = 1;

  /***********
   * Structs *
   ***********/

  /// @param spenders Mapping from target address to token spender address.
  /// @param approvedTargets The list of approved target contracts.
  /// @param whitelisted The list of whitelisted contracts.
  struct RouterStorage {
    mapping(address => address) spenders;
    EnumerableSet.AddressSet approvedTargets;
    EnumerableSet.AddressSet whitelisted;
    address revenuePool;
    uint8 flashLoanContext;
    uint8 reentrantContext;
  }

  /// @notice The struct for input token convert parameters.
  ///
  /// @param tokenIn The address of source token.
  /// @param amount The amount of source token.
  /// @param target The address of converter contract.
  /// @param data The calldata passing to the target contract.
  /// @param minOut The minimum amount of output token should receive.
  /// @param signature The optional data for future usage.
  struct ConvertInParams {
    address tokenIn;
    uint256 amount;
    address target;
    bytes data;
    uint256 minOut;
    bytes signature;
  }

  /// @notice The struct for output token convert parameters.
  /// @param tokenOut The address of output token.
  /// @param converter The address of converter contract.
  /// @param encodings The encodings for `MultiPathConverter`.
  /// @param minOut The minimum amount of output token should receive.
  /// @param routes The convert route encodings.
  /// @param signature The optional data for future usage.
  struct ConvertOutParams {
    address tokenOut;
    address converter;
    uint256 encodings;
    uint256[] routes;
    uint256 minOut;
    bytes signature;
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Return the RouterStorage reference.
  function routerStorage() internal pure returns (RouterStorage storage gs) {
    bytes32 position = ROUTER_STORAGE_SLOT;
    assembly {
      gs.slot := position
    }
  }

  /// @dev Approve contract to be used in token converting.
  function approveTarget(address target, address spender) internal {
    RouterStorage storage $ = routerStorage();

    if ($.approvedTargets.add(target) && target != spender) {
      $.spenders[target] = spender;
    }
  }

  /// @dev Remove approve contract in token converting.
  function removeTarget(address target) internal {
    RouterStorage storage $ = routerStorage();

    if ($.approvedTargets.remove(target)) {
      delete $.spenders[target];
    }
  }

  /// @dev Whitelist account with type.
  function updateWhitelist(address account, bool status) internal {
    RouterStorage storage $ = routerStorage();

    if (status) {
      $.whitelisted.add(account);
    } else {
      $.whitelisted.remove(account);
    }
  }

  /// @dev Check whether the account is whitelisted with specific type.
  function ensureWhitelisted(address account) internal view {
    RouterStorage storage $ = routerStorage();
    if (!$.whitelisted.contains(account)) {
      revert ErrorNotWhitelisted();
    }
  }

  function updateRevenuePool(address revenuePool) internal {
    RouterStorage storage $ = routerStorage();
    $.revenuePool = revenuePool;
  }

  /// @dev Transfer token into this contract and convert to `tokenOut`.
  /// @param params The parameters used in token converting.
  /// @param tokenOut The address of final converted token.
  /// @return amountOut The amount of token received.
  function transferInAndConvert(ConvertInParams memory params, address tokenOut) internal returns (uint256 amountOut) {
    RouterStorage storage $ = routerStorage();
    if (!$.approvedTargets.contains(params.target)) {
      revert ErrorTargetNotApproved();
    }

    transferTokenIn(params.tokenIn, address(this), params.amount);

    amountOut = IERC20(tokenOut).balanceOf(address(this));
    if (params.tokenIn == tokenOut) return amountOut;

    bool _success;
    if (params.tokenIn == address(0)) {
      (_success, ) = params.target.call{ value: params.amount }(params.data);
    } else {
      address _spender = $.spenders[params.target];
      if (_spender == address(0)) _spender = params.target;

      approve(params.tokenIn, _spender, params.amount);
      (_success, ) = params.target.call(params.data);
    }

    // below lines will propagate inner error up
    if (!_success) {
      // solhint-disable-next-line no-inline-assembly
      assembly {
        let ptr := mload(0x40)
        let size := returndatasize()
        returndatacopy(ptr, 0, size)
        revert(ptr, size)
      }
    }

    amountOut = IERC20(tokenOut).balanceOf(address(this)) - amountOut;
  }

  /// @dev Convert `tokenIn` to other token and transfer out.
  /// @param params The parameters used in token converting.
  /// @param tokenIn The address of token to convert.
  /// @param amountIn The amount of token to convert.
  /// @return amountOut The amount of token received.
  function convertAndTransferOut(
    ConvertOutParams memory params,
    address tokenIn,
    uint256 amountIn,
    address receiver
  ) internal returns (uint256 amountOut) {
    RouterStorage storage $ = routerStorage();
    if (!$.approvedTargets.contains(params.converter)) {
      revert ErrorTargetNotApproved();
    }
    if (amountIn == 0) return 0;

    amountOut = amountIn;
    if (params.routes.length > 0) {
      approve(tokenIn, params.converter, amountIn);
      amountOut = IMultiPathConverter(params.converter).convert(tokenIn, amountIn, params.encodings, params.routes);
    }
    if (amountOut < params.minOut) revert ErrorInsufficientOutput();
    if (params.tokenOut == address(0)) {
      IWrappedEther(WETH).withdraw(amountOut);
      Address.sendValue(payable(receiver), amountOut);
    } else {
      IERC20(params.tokenOut).safeTransfer(receiver, amountOut);
    }
  }

  /// @dev Internal function to transfer token to this contract.
  /// @param token The address of token to transfer.
  /// @param amount The amount of token to transfer.
  /// @return uint256 The amount of token transferred.
  function transferTokenIn(address token, address receiver, uint256 amount) internal returns (uint256) {
    if (token == address(0)) {
      if (msg.value != amount) revert ErrorMsgValueMismatch();
    } else {
      IERC20(token).safeTransferFrom(msg.sender, receiver, amount);
    }
    return amount;
  }

  /// @dev Internal function to refund extra token.
  /// @param token The address of token to refund.
  /// @param recipient The address of the token receiver.
  function refundERC20(address token, address recipient) internal {
    uint256 _balance = IERC20(token).balanceOf(address(this));
    if (_balance > 0) {
      IERC20(token).safeTransfer(recipient, _balance);
    }
  }

  /// @dev Internal function to approve token.
  function approve(address token, address spender, uint256 amount) internal {
    IERC20(token).forceApprove(spender, amount);
  }
}

// File: contracts/periphery/facets/FlashLoanCallbackFacet.sol

pragma solidity ^0.8.20;








contract FlashLoanCallbackFacet is IFlashLoanRecipient {
  using SafeERC20 for IERC20;

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the caller is not balancer vault.
  error ErrorNotFromBalancer();

  error ErrorNotFromRouterFlashLoan();

  /***********************
   * Immutable Variables *
   ***********************/

  /// @dev The address of Balancer V2 Vault.
  address private immutable balancer;

  /***************
   * Constructor *
   ***************/

  constructor(address _balancer) {
    balancer = _balancer;
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IFlashLoanRecipient
  /// @dev Balancer V2 callback
  function receiveFlashLoan(
    address[] memory tokens,
    uint256[] memory amounts,
    uint256[] memory feeAmounts,
    bytes memory userData
  ) external {
    if (msg.sender != balancer) revert ErrorNotFromBalancer();

    // make sure call invoked by router
    LibRouter.RouterStorage storage $ = LibRouter.routerStorage();
    if ($.flashLoanContext != LibRouter.HAS_FLASH_LOAN) revert ErrorNotFromRouterFlashLoan();

    (bool success, ) = address(this).call(userData);
    // below lines will propagate inner error up
    if (!success) {
      // solhint-disable-next-line no-inline-assembly
      assembly {
        let ptr := mload(0x40)
        let size := returndatasize()
        returndatacopy(ptr, 0, size)
        revert(ptr, size)
      }
    }

    for (uint256 i = 0; i < tokens.length; i++) {
      IERC20(tokens[i]).safeTransfer(msg.sender, amounts[i] + feeAmounts[i]);
    }
  }
}

// File: contracts/periphery/facets/FlashLoanFacetBase.sol

pragma solidity ^0.8.20;





abstract contract FlashLoanFacetBase {
  /**********
   * Errors *
   **********/

  /// @dev Thrown when the caller is not self.
  error ErrorNotFromSelf();

  /// @dev Unauthorized reentrant call.
  error ReentrancyGuardReentrantCall();

  /***********************
   * Immutable Variables *
   ***********************/

  /// @dev The address of Balancer V2 Vault.
  address private immutable balancer;

  /*************
   * Modifiers *
   *************/

  modifier onlySelf() {
    if (msg.sender != address(this)) revert ErrorNotFromSelf();
    _;
  }

  modifier onFlashLoan() {
    LibRouter.RouterStorage storage $ = LibRouter.routerStorage();
    $.flashLoanContext = LibRouter.HAS_FLASH_LOAN;
    _;
    $.flashLoanContext = LibRouter.NOT_FLASH_LOAN;
  }

  modifier nonReentrant() {
    LibRouter.RouterStorage storage $ = LibRouter.routerStorage();
    if ($.reentrantContext == LibRouter.HAS_ENTRANT) {
      revert ReentrancyGuardReentrantCall();
    }
    $.reentrantContext = LibRouter.HAS_ENTRANT;
    _;
    $.reentrantContext = LibRouter.NOT_ENTRANT;
  }

  /***************
   * Constructor *
   ***************/

  constructor(address _balancer) {
    balancer = _balancer;
  }

  /**********************
   * Internal Functions *
   **********************/

  function _invokeFlashLoan(address token, uint256 amount, bytes memory data) internal onFlashLoan {
    address[] memory tokens = new address[](1);
    uint256[] memory amounts = new uint256[](1);
    tokens[0] = token;
    amounts[0] = amount;
    IBalancerVault(balancer).flashLoan(address(this), tokens, amounts, data);
  }
}

// File: contracts/voting-escrow/interfaces/ILiquidityGauge.sol

pragma solidity ^0.8.0;

// solhint-disable func-name-mixedcase

interface ILiquidityGauge {
  /**********
   * Events *
   **********/

  /// @notice Emitted when user deposit staking token to this contract.
  /// @param owner The address of token owner.
  /// @param receiver The address of recipient for the pool share.
  /// @param amount The amount of staking token deposited.
  event Deposit(address indexed owner, address indexed receiver, uint256 amount);

  /// @notice Emitted when user withdraw staking token from this contract.
  /// @param owner The address of token owner.
  /// @param receiver The address of recipient for the staking token
  /// @param amount The amount of staking token withdrawn.
  event Withdraw(address indexed owner, address indexed receiver, uint256 amount);

  /// @notice Emitted then the working balance is updated.
  /// @param account The address of user updated.
  /// @param originalBalance The original pool share of the user.
  /// @param originalSupply The original total pool share of the contract.
  /// @param workingBalance The current working balance of the user.
  /// @param workingSupply The current working supply of the contract.
  event UpdateLiquidityLimit(
    address indexed account,
    uint256 originalBalance,
    uint256 originalSupply,
    uint256 workingBalance,
    uint256 workingSupply
  );

  /// @notice Emitted when the address of liquidity manager is updated.
  /// @param oldLiquidityManager The address of previous liquidity manager contract.
  /// @param newLiquidityManager The address of current liquidity manager contract.
  event UpdateLiquidityManager(address indexed oldLiquidityManager, address indexed newLiquidityManager);

  /**********
   * Errors *
   **********/

  /// @dev Thrown when someone deposit zero amount staking token.
  error DepositZeroAmount();

  /// @dev Thrown when someone withdraw zero amount staking token.
  error WithdrawZeroAmount();

  /// @dev Thrown when some unauthorized user call `user_checkpoint`.
  error UnauthorizedCaller();

  /// @dev Throw when someone try to kick user who has no changes on their ve balance.
  error KickNotAllowed();

  /// @dev Thrown when someone try to do unnecessary kick.
  error KickNotNeeded();

  /// @dev Thrown when try to remove an active liquidity manager.
  error LiquidityManagerIsActive();

  /// @dev Thrown when try to add an inactive liquidity manager.
  error LiquidityManagerIsNotActive();

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return whether the gauge is active.
  function isActive() external view returns (bool);

  /// @notice Return the address of staking token.
  function stakingToken() external view returns (address);

  /// @notice Return the amount of working supply.
  function workingSupply() external view returns (uint256);

  /// @notice Return the amount of working balance of some user.
  /// @param account The address of user to query.
  function workingBalanceOf(address account) external view returns (uint256);

  /// @notice Return the governance token reward integrate for some user.
  ///
  /// @dev This is used in TokenMinter.
  ///
  /// @param account The address of user to query.
  function integrate_fraction(address account) external view returns (uint256);

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Initialize the state of LiquidityGauge.
  ///
  /// @param _stakingToken The address of staking token.
  function initialize(address _stakingToken) external;

  /// @notice Deposit some staking token to this contract.
  ///
  /// @dev Use `amount = type(uint256).max`, if caller wants to deposit all held staking tokens.
  ///
  /// @param amount The amount of staking token to deposit.
  function deposit(uint256 amount) external;

  /// @notice Deposit some staking token to this contract and transfer the share to others.
  ///
  /// @dev Use `amount = type(uint256).max`, if caller wants to deposit all held staking tokens.
  ///
  /// @param amount The amount of staking token to deposit.
  /// @param receiver The address of the pool share recipient.
  function deposit(uint256 amount, address receiver) external;

  /// @notice Deposit some staking token to this contract and transfer the share to others.
  ///
  /// @dev Use `amount = type(uint256).max`, if caller wants to deposit all held staking tokens.
  ///
  /// @param amount The amount of staking token to deposit.
  /// @param receiver The address of the pool share recipient.
  /// @param manage The parameter passed to possible `LiquidityManager`.
  function deposit(
    uint256 amount,
    address receiver,
    bool manage
  ) external;

  /// @notice Withdraw some staking token from this contract.
  ///
  /// @dev Use `amount = type(uint256).max`, if caller wants to deposit all held staking tokens.
  ///
  /// @param amount The amount of staking token to withdraw.
  function withdraw(uint256 amount) external;

  /// @notice Withdraw some staking token from this contract and transfer the token to others.
  ///
  /// @dev Use `amount = type(uint256).max`, if caller wants to deposit all held staking tokens.
  ///
  /// @param amount The amount of staking token to withdraw.
  /// @param receiver The address of the staking token recipient.
  function withdraw(uint256 amount, address receiver) external;

  /// @notice Update the snapshot for some user.
  ///
  /// @dev This is used in TokenMinter.
  ///
  /// @param account The address of user to update.
  function user_checkpoint(address account) external returns (bool);

  /// @notice Kick some user for abusing their boost.
  ///
  /// @dev Only if either they had another voting event, or their voting escrow lock expired.
  ///
  /// @param account The address of user to kick.
  function kick(address account) external;
}

// File: contracts/periphery/facets/FxUSDBasePoolFacet.sol

pragma solidity ^0.8.20;












contract FxUSDBasePoolFacet {
  using SafeERC20 for IERC20;

  /*************
   * Constants *
   *************/

  /// @notice The address of USDC token.
  address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  /// @notice The address of fxUSD token.
  address private constant fxUSD = 0x085780639CC2cACd35E474e71f4d000e2405d8f6;

  /***********************
   * Immutable Variables *
   ***********************/

  /// @dev The address of `PoolManager` contract.
  address private immutable poolManager;

  /// @dev The address of `FxUSDBasePool` contract.
  address private immutable fxBASE;

  /// @dev The address of fxBASE gauge contract.
  address private immutable gauge;

  /***************
   * Constructor *
   ***************/

  constructor(address _poolManager, address _fxBASE, address _gauge) {
    poolManager = _poolManager;
    fxBASE = _fxBASE;
    gauge = _gauge;
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Migrate fxUSD from rebalance pool to fxBASE.
  /// @param pool The address of rebalance pool.
  /// @param amountIn The amount of rebalance pool shares to migrate.
  /// @param minShares The minimum shares should receive.
  /// @param receiver The address of fxBASE share recipient.
  function migrateToFxBase(address pool, uint256 amountIn, uint256 minShares, address receiver) external {
    IFxShareableRebalancePool(pool).withdrawFrom(msg.sender, amountIn, address(this));
    address baseToken = IFxShareableRebalancePool(pool).baseToken();
    address asset = IFxShareableRebalancePool(pool).asset();
    LibRouter.approve(asset, fxUSD, amountIn);
    IFxUSD(fxUSD).wrap(baseToken, amountIn, address(this));
    LibRouter.approve(fxUSD, fxBASE, amountIn);
    IFxUSDBasePool(fxBASE).deposit(receiver, fxUSD, amountIn, minShares);
  }

  /// @notice Migrate fxUSD from rebalance pool to fxBASE gauge.
  /// @param pool The address of rebalance pool.
  /// @param amountIn The amount of rebalance pool shares to migrate.
  /// @param minShares The minimum shares should receive.
  /// @param receiver The address of fxBASE share recipient.
  function migrateToFxBaseGauge(address pool, uint256 amountIn, uint256 minShares, address receiver) external {
    IFxShareableRebalancePool(pool).withdrawFrom(msg.sender, amountIn, address(this));
    address baseToken = IFxShareableRebalancePool(pool).baseToken();
    address asset = IFxShareableRebalancePool(pool).asset();
    LibRouter.approve(asset, fxUSD, amountIn);
    IFxUSD(fxUSD).wrap(baseToken, amountIn, address(this));
    LibRouter.approve(fxUSD, fxBASE, amountIn);
    uint256 shares = IFxUSDBasePool(fxBASE).deposit(address(this), fxUSD, amountIn, minShares);
    LibRouter.approve(fxBASE, gauge, shares);
    ILiquidityGauge(gauge).deposit(shares, receiver);
  }

  /// @notice Deposit token to fxBASE.
  /// @param params The parameters to convert source token to `tokenOut`.
  /// @param tokenOut The target token, USDC or fxUSD.
  /// @param minShares The minimum shares should receive.
  /// @param receiver The address of fxBASE share recipient.
  function depositToFxBase(
    LibRouter.ConvertInParams memory params,
    address tokenOut,
    uint256 minShares,
    address receiver
  ) external payable {
    uint256 amountIn = LibRouter.transferInAndConvert(params, tokenOut);
    LibRouter.approve(tokenOut, fxBASE, amountIn);
    IFxUSDBasePool(fxBASE).deposit(receiver, tokenOut, amountIn, minShares);
  }

  /// @notice Deposit token to fxBase and then deposit to gauge.
  /// @param params The parameters to convert source token to `tokenOut`.
  /// @param tokenOut The target token, USDC or fxUSD.
  /// @param minShares The minimum shares should receive.
  /// @param receiver The address of gauge share recipient.
  function depositToFxBaseGauge(
    LibRouter.ConvertInParams memory params,
    address tokenOut,
    uint256 minShares,
    address receiver
  ) external payable {
    uint256 amountIn = LibRouter.transferInAndConvert(params, tokenOut);
    LibRouter.approve(tokenOut, fxBASE, amountIn);
    uint256 shares = IFxUSDBasePool(fxBASE).deposit(address(this), tokenOut, amountIn, minShares);
    LibRouter.approve(fxBASE, gauge, shares);
    ILiquidityGauge(gauge).deposit(shares, receiver);
  }
  
  /*
  /// @notice Burn fxBASE shares and then convert USDC and fxUSD to another token.
  /// @param fxusdParams The parameters to convert fxUSD to target token.
  /// @param usdcParams The parameters to convert USDC to target token.
  /// @param amountIn The amount of fxBASE to redeem.
  /// @param receiver The address of token recipient.
  function redeemFromFxBase(
    LibRouter.ConvertOutParams memory fxusdParams,
    LibRouter.ConvertOutParams memory usdcParams,
    uint256 amountIn,
    address receiver
  ) external {
    IERC20(fxBASE).safeTransferFrom(msg.sender, address(this), amountIn);
    (uint256 amountFxUSD, uint256 amountUSDC) = IFxUSDBasePool(fxBASE).redeem(address(this), amountIn);
    LibRouter.convertAndTransferOut(fxusdParams, fxUSD, amountFxUSD, receiver);
    LibRouter.convertAndTransferOut(usdcParams, USDC, amountUSDC, receiver);
  }

  /// @notice Burn fxBASE shares from gauge and then convert USDC and fxUSD to another token.
  /// @param fxusdParams The parameters to convert fxUSD to target token.
  /// @param usdcParams The parameters to convert USDC to target token.
  /// @param amountIn The amount of fxBASE to redeem.
  /// @param receiver The address of token recipient.
  function redeemFromFxBaseGauge(
    LibRouter.ConvertOutParams memory fxusdParams,
    LibRouter.ConvertOutParams memory usdcParams,
    uint256 amountIn,
    address receiver
  ) external {
    IERC20(gauge).safeTransferFrom(msg.sender, address(this), amountIn);
    ILiquidityGauge(gauge).withdraw(amountIn);
    (uint256 amountFxUSD, uint256 amountUSDC) = IFxUSDBasePool(fxBASE).redeem(address(this), amountIn);
    LibRouter.convertAndTransferOut(fxusdParams, fxUSD, amountFxUSD, receiver);
    LibRouter.convertAndTransferOut(usdcParams, USDC, amountUSDC, receiver);
  }
  */
}

// File: contracts/periphery/facets/MigrateFacet.sol

pragma solidity ^0.8.20;
















contract MigrateFacet is FlashLoanFacetBase {
  using SafeERC20 for IERC20;
  using WordCodec for bytes32;

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the amount of tokens swapped are not enough.
  error ErrorInsufficientAmountSwapped();

  /// @dev Thrown when debt ratio out of range.
  error ErrorDebtRatioOutOfRange();

  /*************
   * Constants *
   *************/

  /// @dev The address of USDC token.
  address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  /// @dev The address of fxUSD token.
  address private constant fxUSD = 0x085780639CC2cACd35E474e71f4d000e2405d8f6;

  /// @dev The address of wstETH market contract.
  address private constant wstETHMarket = 0xAD9A0E7C08bc9F747dF97a3E7E7f620632CB6155;

  /// @dev The address of wstETH token.
  address private constant wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

  /// @dev The address of fstETH token.
  address private constant fstETH = 0xD6B8162e2fb9F3EFf09bb8598ca0C8958E33A23D;

  /// @dev The address of xstETH token.
  address private constant xstETH = 0x5a097b014C547718e79030a077A91Ae37679EfF5;

  /// @dev The address of sfrxETH market contract.
  address private constant sfrxETHMarket = 0x714B853b3bA73E439c652CfE79660F329E6ebB42;

  /// @dev The address of sfrxETH token.
  address private constant sfrxETH = 0xac3E018457B222d93114458476f3E3416Abbe38F;

  /// @dev The address of ffrxETH token.
  address private constant ffrxETH = 0xa87F04c9743Fd1933F82bdDec9692e9D97673769;

  /// @dev The address of xfrxETH token.
  address private constant xfrxETH = 0x2bb0C32101456F5960d4e994Bac183Fe0dc6C82c;

  /***********************
   * Immutable Variables *
   ***********************/

  /// @dev The address of `PoolManager` contract.
  address private immutable poolManager;

  /// @dev The address of `MultiPathConverter` contract.
  address private immutable converter;

  /***************
   * Constructor *
   ***************/

  constructor(address _balancer, address _poolManager, address _converter) FlashLoanFacetBase(_balancer) {
    poolManager = _poolManager;
    converter = _converter;
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Migrate xstETH to fx position.
  /// @param pool The address of fx position pool.
  /// @param positionId The index of position.
  /// @param xTokenAmount The amount of xstETH to migrate.
  /// @param borrowAmount The amount of USDC to borrow.
  /// @param data The calldata passing to `onMigrateXstETHPosition` hook function.
  function migrateXstETHPosition(
    address pool,
    uint256 positionId,
    uint256 xTokenAmount,
    uint256 borrowAmount,
    bytes calldata data
  ) external nonReentrant {
    IERC20(xstETH).safeTransferFrom(msg.sender, address(this), xTokenAmount);
    if (positionId > 0) {
      IERC721(pool).transferFrom(msg.sender, address(this), positionId);
    }

    _invokeFlashLoan(
      USDC,
      borrowAmount,
      abi.encodeCall(
        MigrateFacet.onMigrateXstETHPosition,
        (pool, positionId, xTokenAmount, borrowAmount, msg.sender, data)
      )
    );

    // refund USDC to caller
    LibRouter.refundERC20(USDC, LibRouter.routerStorage().revenuePool);
  }

  /// @notice Migrate xfrxETH to fx position.
  /// @param pool The address of fx position pool.
  /// @param positionId The index of position.
  /// @param xTokenAmount The amount of xfrxETH to migrate.
  /// @param borrowAmount The amount of USDC to borrow.
  /// @param data The calldata passing to `onMigrateXfrxETHPosition` hook function.
  function migrateXfrxETHPosition(
    address pool,
    uint256 positionId,
    uint256 xTokenAmount,
    uint256 borrowAmount,
    bytes calldata data
  ) external nonReentrant {
    IERC20(xfrxETH).safeTransferFrom(msg.sender, address(this), xTokenAmount);
    if (positionId > 0) {
      IERC721(pool).transferFrom(msg.sender, address(this), positionId);
    }

    _invokeFlashLoan(
      USDC,
      borrowAmount,
      abi.encodeCall(
        MigrateFacet.onMigrateXfrxETHPosition,
        (pool, positionId, xTokenAmount, borrowAmount, msg.sender, data)
      )
    );

    // refund USDC to caller
    LibRouter.refundERC20(USDC, LibRouter.routerStorage().revenuePool);
  }

  /// @notice Hook for `migrateXstETHPosition`.
  /// @param pool The address of fx position pool.
  /// @param positionId The index of position.
  /// @param xTokenAmount The amount of xstETH to migrate.
  /// @param borrowAmount The amount of USDC to borrow.
  /// @param recipient The address of position holder.
  /// @param data Hook data.
  function onMigrateXstETHPosition(
    address pool,
    uint256 positionId,
    uint256 xTokenAmount,
    uint256 borrowAmount,
    address recipient,
    bytes memory data
  ) external onlySelf {
    uint256 fTokenAmount = (xTokenAmount * IERC20(fstETH).totalSupply()) / IERC20(xstETH).totalSupply();

    // swap USDC to fxUSD
    fTokenAmount = _swapUSDCToFxUSD(borrowAmount, fTokenAmount, data);

    // unwrap fxUSD as fToken
    IFxUSD(fxUSD).unwrap(wstETH, fTokenAmount, address(this));

    uint256 wstETHAmount;
    {
      wstETHAmount = IFxMarketV2(wstETHMarket).redeemXToken(xTokenAmount, address(this), 0);
      (uint256 baseOut, uint256 bonus) = IFxMarketV2(wstETHMarket).redeemFToken(fTokenAmount, address(this), 0);
      wstETHAmount += baseOut + bonus;
    }

    // since we need to swap back to USDC, mint 0.1% more fxUSD to cover slippage.
    fTokenAmount = (fTokenAmount * 1001) / 1000;

    LibRouter.approve(wstETH, poolManager, wstETHAmount);
    positionId = IPoolManager(poolManager).operate(pool, positionId, int256(wstETHAmount), int256(fTokenAmount));
    _checkPositionDebtRatio(pool, positionId, abi.decode(data, (bytes32)));
    IERC721(pool).transferFrom(address(this), recipient, positionId);

    // swap fxUSD to USDC and pay debts
    _swapFxUSDToUSDC(IERC20(fxUSD).balanceOf(address(this)), borrowAmount, data);
  }

  /// @notice Hook for `migrateXfrxETHPosition`.
  /// @param pool The address of fx position pool.
  /// @param positionId The index of position.
  /// @param xTokenAmount The amount of xstETH to migrate.
  /// @param borrowAmount The amount of USDC to borrow.
  /// @param recipient The address of position holder.
  /// @param data Hook data.
  function onMigrateXfrxETHPosition(
    address pool,
    uint256 positionId,
    uint256 xTokenAmount,
    uint256 borrowAmount,
    address recipient,
    bytes memory data
  ) external onlySelf {
    uint256 fTokenAmount = (xTokenAmount * IERC20(ffrxETH).totalSupply()) / IERC20(xfrxETH).totalSupply();

    // swap USDC to fxUSD
    fTokenAmount = _swapUSDCToFxUSD(borrowAmount, fTokenAmount, data);

    // unwrap fxUSD as fToken
    IFxUSD(fxUSD).unwrap(sfrxETH, fTokenAmount, address(this));

    uint256 wstETHAmount;
    {
      // redeem
      wstETHAmount = IFxMarketV2(sfrxETHMarket).redeemXToken(xTokenAmount, address(this), 0);
      (uint256 baseOut, uint256 bonus) = IFxMarketV2(sfrxETHMarket).redeemFToken(fTokenAmount, address(this), 0);
      wstETHAmount += baseOut + bonus;
      // swap sfrxETH to wstETH
      wstETHAmount = _swapSfrxETHToWstETH(wstETHAmount, 0, data);
    }

    // since we need to swap back to USDC, mint 0.1% more fxUSD to cover slippage.
    fTokenAmount = (fTokenAmount * 1001) / 1000;

    LibRouter.approve(wstETH, poolManager, wstETHAmount);
    positionId = IPoolManager(poolManager).operate(pool, positionId, int256(wstETHAmount), int256(fTokenAmount));
    _checkPositionDebtRatio(pool, positionId, abi.decode(data, (bytes32)));
    IERC721(pool).transferFrom(address(this), recipient, positionId);

    // swap fxUSD to USDC and pay debts
    _swapFxUSDToUSDC(IERC20(fxUSD).balanceOf(address(this)), borrowAmount, data);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to swap USDC to fxUSD.
  /// @param amountUSDC The amount of USDC to use.
  /// @param minFxUSD The minimum amount of fxUSD should receive.
  /// @param data The swap route encoding.
  /// @return amountFxUSD The amount of fxUSD received.
  function _swapUSDCToFxUSD(
    uint256 amountUSDC,
    uint256 minFxUSD,
    bytes memory data
  ) internal returns (uint256 amountFxUSD) {
    (, uint256 swapEncoding, uint256[] memory swapRoutes) = abi.decode(data, (bytes32, uint256, uint256[]));
    return _swap(USDC, amountUSDC, minFxUSD, swapEncoding, swapRoutes);
  }

  /// @dev Internal function to swap fxUSD to USDC.
  /// @param amountFxUSD The amount of fxUSD to use.
  /// @param minUSDC The minimum amount of USDC should receive.
  /// @param data The swap route encoding.
  /// @return amountUSDC The amount of USDC received.
  function _swapFxUSDToUSDC(
    uint256 amountFxUSD,
    uint256 minUSDC,
    bytes memory data
  ) internal returns (uint256 amountUSDC) {
    (, , , uint256 swapEncoding, uint256[] memory swapRoutes) = abi.decode(
      data,
      (bytes32, uint256, uint256[], uint256, uint256[])
    );
    return _swap(fxUSD, amountFxUSD, minUSDC, swapEncoding, swapRoutes);
  }

  /// @dev Internal function to swap sfrxETH to wstETH.
  /// @param amountSfrxETH The amount of sfrxETH to use.
  /// @param minWstETH The minimum amount of wstETH should receive.
  /// @param data The swap route encoding.
  /// @return amountWstETH The amount of wstETH received.
  function _swapSfrxETHToWstETH(
    uint256 amountSfrxETH,
    uint256 minWstETH,
    bytes memory data
  ) internal returns (uint256 amountWstETH) {
    (, , , , , uint256 swapEncoding, uint256[] memory swapRoutes) = abi.decode(
      data,
      (bytes32, uint256, uint256[], uint256, uint256[], uint256, uint256[])
    );
    return _swap(sfrxETH, amountSfrxETH, minWstETH, swapEncoding, swapRoutes);
  }

  /// @dev Internal function to do swap.
  /// @param token The address of input token.
  /// @param amountIn The amount of input token.
  /// @param minOut The minimum amount of output tokens should receive.
  /// @param encoding The encoding for swap routes.
  /// @param routes The swap routes to `MultiPathConverter`.
  /// @return amountOut The amount of output tokens received.
  function _swap(
    address token,
    uint256 amountIn,
    uint256 minOut,
    uint256 encoding,
    uint256[] memory routes
  ) internal returns (uint256 amountOut) {
    LibRouter.approve(token, converter, amountIn);
    amountOut = IMultiPathConverter(converter).convert(token, amountIn, encoding, routes);
    if (amountOut < minOut) revert ErrorInsufficientAmountSwapped();
  }

  /// @dev Internal function to check debt ratio for the position.
  /// @param pool The address of fx position pool.
  /// @param positionId The index of the position.
  /// @param miscData The encoded data for debt ratio range.
  function _checkPositionDebtRatio(address pool, uint256 positionId, bytes32 miscData) internal view {
    uint256 debtRatio = IPool(pool).getPositionDebtRatio(positionId);
    uint256 minDebtRatio = miscData.decodeUint(0, 60);
    uint256 maxDebtRatio = miscData.decodeUint(60, 60);
    if (debtRatio < minDebtRatio || debtRatio > maxDebtRatio) {
      revert ErrorDebtRatioOutOfRange();
    }
  }
}

// File: contracts/periphery/facets/PositionOperateFlashLoanFacet.sol

pragma solidity ^0.8.20;













contract PositionOperateFlashLoanFacet is FlashLoanFacetBase {
  using SafeERC20 for IERC20;
  using WordCodec for bytes32;

  /**********
   * Events *
   **********/

  event OpenOrAdd(address pool, uint256 position, address recipient, uint256 colls, uint256 debts, uint256 borrows);

  event CloseOrRemove(address pool, uint256 position, address recipient, uint256 colls, uint256 debts, uint256 borrows);

  /**********
   * Errors *
   **********/

  /// @dev Thrown when the amount of tokens swapped are not enough.
  error ErrorInsufficientAmountSwapped();

  /// @dev Thrown when debt ratio out of range.
  error ErrorDebtRatioOutOfRange();

  /*************
   * Constants *
   *************/

  address private constant fxUSD = 0x085780639CC2cACd35E474e71f4d000e2405d8f6;

  /***********************
   * Immutable Variables *
   ***********************/

  /// @dev The address of `PoolManager` contract.
  address private immutable poolManager;

  /// @dev The address of `MultiPathConverter` contract.
  address private immutable converter;

  /***************
   * Constructor *
   ***************/

  constructor(address _balancer, address _poolManager, address _converter) FlashLoanFacetBase(_balancer) {
    poolManager = _poolManager;
    converter = _converter;
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @notice Open a new position or add collateral to position with any tokens.
  /// @param params The parameters to convert source token to collateral token.
  /// @param pool The address of fx position pool.
  /// @param positionId The index of position.
  /// @param borrowAmount The amount of collateral token to borrow.
  /// @param data Hook data passing to `onOpenOrAddPositionFlashLoan`.
  function openOrAddPositionFlashLoan(
    LibRouter.ConvertInParams memory params,
    address pool,
    uint256 positionId,
    uint256 borrowAmount,
    bytes calldata data
  ) external payable nonReentrant {
    uint256 amountIn = LibRouter.transferInAndConvert(params, IPool(pool).collateralToken()) + borrowAmount;
    _invokeFlashLoan(
      IPool(pool).collateralToken(),
      borrowAmount,
      abi.encodeCall(
        PositionOperateFlashLoanFacet.onOpenOrAddPositionFlashLoan,
        (pool, positionId, amountIn, borrowAmount, msg.sender, data)
      )
    );
    // refund collateral token to caller
    LibRouter.refundERC20(IPool(pool).collateralToken(), LibRouter.routerStorage().revenuePool);
  }

  /// @notice Close a position or remove collateral from position.
  /// @param params The parameters to convert collateral token to target token.
  /// @param positionId The index of position.
  /// @param pool The address of fx position pool.
  /// @param borrowAmount The amount of collateral token to borrow.
  /// @param data Hook data passing to `onCloseOrRemovePositionFlashLoan`.
  function closeOrRemovePositionFlashLoan(
    LibRouter.ConvertOutParams memory params,
    address pool,
    uint256 positionId,
    uint256 amountOut,
    uint256 borrowAmount,
    bytes calldata data
  ) external nonReentrant {
    address collateralToken = IPool(pool).collateralToken();

    _invokeFlashLoan(
      collateralToken,
      borrowAmount,
      abi.encodeCall(
        PositionOperateFlashLoanFacet.onCloseOrRemovePositionFlashLoan,
        (pool, positionId, amountOut, borrowAmount, msg.sender, data)
      )
    );

    // convert collateral token to other token
    amountOut = IERC20(collateralToken).balanceOf(address(this));
    LibRouter.convertAndTransferOut(params, collateralToken, amountOut, msg.sender);

    // refund rest fxUSD and leveraged token
    LibRouter.refundERC20(fxUSD, LibRouter.routerStorage().revenuePool);
  }

  /// @notice Hook for `openOrAddPositionFlashLoan`.
  /// @param pool The address of fx position pool.
  /// @param position The index of position.
  /// @param amount The amount of collateral token to supply.
  /// @param repayAmount The amount of collateral token to repay.
  /// @param recipient The address of position holder.
  /// @param data Hook data passing to `onOpenOrAddPositionFlashLoan`.
  function onOpenOrAddPositionFlashLoan(
    address pool,
    uint256 position,
    uint256 amount,
    uint256 repayAmount,
    address recipient,
    bytes memory data
  ) external onlySelf {
    (bytes32 miscData, uint256 fxUSDAmount, uint256 swapEncoding, uint256[] memory swapRoutes) = abi.decode(
      data,
      (bytes32, uint256, uint256, uint256[])
    );

    // open or add collateral to position
    if (position != 0) {
      IERC721(pool).transferFrom(recipient, address(this), position);
    }
    LibRouter.approve(IPool(pool).collateralToken(), poolManager, amount);
    position = IPoolManager(poolManager).operate(pool, position, int256(amount), int256(fxUSDAmount));
    _checkPositionDebtRatio(pool, position, miscData);
    IERC721(pool).transferFrom(address(this), recipient, position);

    emit OpenOrAdd(pool, position, recipient, amount, fxUSDAmount, repayAmount);

    // swap fxUSD to collateral token
    _swap(fxUSD, fxUSDAmount, repayAmount, swapEncoding, swapRoutes);
  }

  /// @notice Hook for `closeOrRemovePositionFlashLoan`.
  /// @param pool The address of fx position pool.
  /// @param position The index of position.
  /// @param amount The amount of collateral token to withdraw.
  /// @param repayAmount The amount of collateral token to repay.
  /// @param recipient The address of position holder.
  /// @param data Hook data passing to `onCloseOrRemovePositionFlashLoan`.
  function onCloseOrRemovePositionFlashLoan(
    address pool,
    uint256 position,
    uint256 amount,
    uint256 repayAmount,
    address recipient,
    bytes memory data
  ) external onlySelf {
    (bytes32 miscData, uint256 fxUSDAmount, uint256 swapEncoding, uint256[] memory swapRoutes) = abi.decode(
      data,
      (bytes32, uint256, uint256, uint256[])
    );

    // swap collateral token to fxUSD
    _swap(IPool(pool).collateralToken(), repayAmount, fxUSDAmount, swapEncoding, swapRoutes);

    // close or remove collateral from position
    IERC721(pool).transferFrom(recipient, address(this), position);
    (, uint256 maxFxUSD) = IPool(pool).getPosition(position);
    if (fxUSDAmount >= maxFxUSD) {
      // close entire position
      IPoolManager(poolManager).operate(pool, position, type(int256).min, type(int256).min);
    } else {
      IPoolManager(poolManager).operate(pool, position, -int256(amount), -int256(fxUSDAmount));
      _checkPositionDebtRatio(pool, position, miscData);
    }
    IERC721(pool).transferFrom(address(this), recipient, position);

    emit CloseOrRemove(pool, position, recipient, amount, fxUSDAmount, repayAmount);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to do swap.
  /// @param token The address of input token.
  /// @param amountIn The amount of input token.
  /// @param minOut The minimum amount of output tokens should receive.
  /// @param encoding The encoding for swap routes.
  /// @param routes The swap routes to `MultiPathConverter`.
  /// @return amountOut The amount of output tokens received.
  function _swap(
    address token,
    uint256 amountIn,
    uint256 minOut,
    uint256 encoding,
    uint256[] memory routes
  ) internal returns (uint256 amountOut) {
    if (amountIn == 0) return 0;

    LibRouter.approve(token, converter, amountIn);
    amountOut = IMultiPathConverter(converter).convert(token, amountIn, encoding, routes);
    if (amountOut < minOut) revert ErrorInsufficientAmountSwapped();
  }

  /// @dev Internal function to check debt ratio for the position.
  /// @param pool The address of fx position pool.
  /// @param positionId The index of the position.
  /// @param miscData The encoded data for debt ratio range.
  function _checkPositionDebtRatio(address pool, uint256 positionId, bytes32 miscData) internal view {
    uint256 debtRatio = IPool(pool).getPositionDebtRatio(positionId);
    uint256 minDebtRatio = miscData.decodeUint(0, 60);
    uint256 maxDebtRatio = miscData.decodeUint(60, 60);
    if (debtRatio < minDebtRatio || debtRatio > maxDebtRatio) {
      revert ErrorDebtRatioOutOfRange();
    }
  }
}

// File: contracts/periphery/facets/RouterManagementFacet.sol

pragma solidity ^0.8.20;






contract RouterManagementFacet {
  using EnumerableSet for EnumerableSet.AddressSet;

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the token approve spender for the given target.
  function getSpender(address target) external view returns (address _spender) {
    LibRouter.RouterStorage storage $ = LibRouter.routerStorage();
    _spender = $.spenders[target];
    if (_spender == address(0)) _spender = target;
  }

  /// @notice Return the list of approved targets.
  function getApprovedTargets() external view returns (address[] memory _accounts) {
    LibRouter.RouterStorage storage $ = LibRouter.routerStorage();
    uint256 _numAccount = $.approvedTargets.length();
    _accounts = new address[](_numAccount);
    for (uint256 i = 0; i < _numAccount; i++) {
      _accounts[i] = $.approvedTargets.at(i);
    }
  }

  /// @notice Return the whitelist kind for the given target.
  function getWhitelisted() external view returns (address[] memory _accounts) {
    LibRouter.RouterStorage storage $ = LibRouter.routerStorage();
    uint256 _numAccount = $.whitelisted.length();
    _accounts = new address[](_numAccount);
    for (uint256 i = 0; i < _numAccount; i++) {
      _accounts[i] = $.whitelisted.at(i);
    }
  }

  function getRevenuePool() external view returns (address) {
    LibRouter.RouterStorage storage $ = LibRouter.routerStorage();
    return $.revenuePool;
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Approve contract to be used in token converting.
  function approveTarget(address target, address spender) external {
    LibDiamond.enforceIsContractOwner();
    LibRouter.approveTarget(target, spender);
  }

  /// @notice Remove approve contract in token converting.
  function removeTarget(address target) external {
    LibDiamond.enforceIsContractOwner();
    LibRouter.removeTarget(target);
  }

  /// @notice Update whitelist status of the given contract.
  function updateWhitelist(address target, bool status) external {
    LibDiamond.enforceIsContractOwner();
    LibRouter.updateWhitelist(target, status);
  }

  /// @notice Update revenue pool.
  function updateRevenuePool(address revenuePool) external {
    LibDiamond.enforceIsContractOwner();
    LibRouter.updateRevenuePool(revenuePool);
  }
}

// File: contracts/price-oracle/interfaces/ISpotPriceOracle.sol

pragma solidity ^0.8.0;

interface ISpotPriceOracle {
  /// @notice Return spot price with 18 decimal places.
  ///
  /// @dev encoding for single route
  /// |   8 bits  | 160 bits |  88  bits  |
  /// | pool_type |   pool   | customized |
  /// assume all base and quote token has no more than 18 decimals.
  ///
  /// + pool_type = 0: UniswapV2
  ///   customized = |   1  bit   |   8  bits   |   8 bits   | ... |
  ///                | base_index | base_scale | quote_scale | ... |
  /// + pool_type = 1: UniswapV3
  ///   customized = |   1  bit   |   8 bits   |   8  bits   | ... |
  ///                | base_index | base_scale | quote_scale | ... |
  /// + pool_type = 2: Balancer V2 Weighted
  ///   customized = |   3  bit   |    3 bit    |   8 bits   |   8  bits   | ... |
  ///                | base_index | quote_index | base_scale | quote_scale | ... |
  /// + pool_type = 3: Balancer V2 Stable
  ///   customized = |   3 bits   |   3  bits   | ... |
  ///                | base_index | quote_index | ... |
  /// + pool_type = 4: Curve Plain
  ///   customized = | 3 bits |   3 bits   |   3  bits   |     1  bits     |  8 bits  | ... |  8 bits  | ... |
  ///                | tokens | base_index | quote_index | has_amm_precise | scale[0] | ... | scale[n] | ... |
  /// + pool_type = 5: Curve Plain with oracle
  ///   customized = |   1  bit   |   1 bit   |... |
  ///                | base_index | use_cache | ... |
  /// + pool_type = 6: Curve Plain NG
  ///   customized = |   3 bits   |   3  bits   |   1 bit   | ... |
  ///                | base_index | quote_index | use_cache | ... |
  /// + pool_type = 7: Curve Crypto
  ///   customized = |   1  bit   | ... |
  ///                | base_index | ... |
  /// + pool_type = 8: Curve TriCrypto
  ///   customized = |   2 bits   |   2  bits   | ... |
  ///                | base_index | quote_index | ... |
  /// + pool_type = 9: ERC4626
  ///   customized = |       1  bit       | ... |
  ///                | base_is_underlying | ... |
  /// + pool_type = 10: ETHLSD, wstETH, weETH, ezETH
  ///   customized = |    1 bit    | ... |
  ///                | base_is_ETH | ... |
  /// + pool_type = 11: BalancerV2CachedRate
  ///   customized = |   3 bits   | ... |
  ///                | base_index | ... |
  ///
  /// @param encoding The encoding of the price source.
  /// @return spotPrice The spot price with 18 decimal places.
  function getSpotPrice(uint256 encoding) external view returns (uint256 spotPrice);
}

// File: contracts/price-oracle/SpotPriceOracleBase.sol

pragma solidity ^0.8.26;







abstract contract SpotPriceOracleBase is Ownable2Step {
  /**********
   * Errors *
   **********/

  /// @dev Thrown when the given encodings are invalid.
  error ErrorInvalidEncodings();

  /// @dev Thrown when update some parameters to the same value.
  error ErrorParameterUnchanged();

  /*************
   * Constants *
   *************/

  /// @dev The precision for oracle price.
  uint256 internal constant PRECISION = 1e18;

  /// @dev The address of `SpotPriceOracle` contract.
  address immutable spotPriceOracle;

  /***************
   * Constructor *
   ***************/

  constructor(address _spotPriceOracle) Ownable(_msgSender()) {
    spotPriceOracle = _spotPriceOracle;
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev The encoding is below.
  /// ```text
  /// |  32 bits  | 64 bits |  160 bits  |
  /// | heartbeat |  scale  | price_feed |
  /// |low                          high |
  /// ```
  function _readSpotPriceByChainlink(bytes32 encoding) internal view returns (uint256) {
    address aggregator;
    uint256 scale;
    uint256 heartbeat;
    assembly {
      aggregator := shr(96, encoding)
      scale := and(shr(32, encoding), 0xffffffffffffffff)
      heartbeat := and(encoding, 0xffffffff)
    }
    (, int256 answer, , uint256 updatedAt, ) = AggregatorV3Interface(aggregator).latestRoundData();
    if (answer <= 0) revert("invalid");
    if (block.timestamp - updatedAt > heartbeat) revert("expired");
    return uint256(answer) * scale;
  }

  /// @dev Internal function to calculate spot price by encodings.
  ///
  /// The details of the encoding is below
  /// ```text
  /// |   1 byte   |    ...    |    ...    | ... |    ...    |
  /// | num_source | source[0] | source[1] | ... | source[n] |
  ///
  /// source encoding:
  /// |  1 byte  | 32 bytes | 32 bytes | ... | 32 bytes |
  /// | num_pool |  pool[0] |  pool[1] | ... |  pool[n] |
  /// 1 <= num_pool <= 3
  ///
  /// The encoding of each pool can be found in `SpotPriceOracle` contract.
  /// ```
  /// @return prices The list of prices of each source, multiplied by 1e18.
  function _getSpotPriceByEncoding(bytes memory encodings) internal view returns (uint256[] memory prices) {
    uint256 ptr;
    uint256 length;
    assembly {
      ptr := add(encodings, 0x21)
      length := byte(0, mload(sub(ptr, 1)))
    }
    prices = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      uint256 encoding1;
      uint256 encoding2;
      uint256 encoding3;
      assembly {
        let cnt := byte(0, mload(ptr))
        ptr := add(ptr, 0x01)
        if gt(cnt, 0) {
          encoding1 := mload(ptr)
          ptr := add(ptr, 0x20)
        }
        if gt(cnt, 1) {
          encoding2 := mload(ptr)
          ptr := add(ptr, 0x20)
        }
        if gt(cnt, 2) {
          encoding3 := mload(ptr)
          ptr := add(ptr, 0x20)
        }
      }
      if (encoding1 == 0) {
        revert ErrorInvalidEncodings();
      } else if (encoding2 == 0) {
        prices[i] = _readSpotPrice(encoding1);
      } else if (encoding3 == 0) {
        prices[i] = _readSpotPrice(encoding1, encoding2);
      } else {
        prices[i] = _readSpotPrice(encoding1, encoding2, encoding3);
      }
    }
  }

  /// @dev Internal function to calculate spot price of single pool.
  /// @param encoding The encoding for the pool.
  /// @return price The spot price of the source, multiplied by 1e18.
  function _readSpotPrice(uint256 encoding) private view returns (uint256 price) {
    price = ISpotPriceOracle(spotPriceOracle).getSpotPrice(encoding);
  }

  /// @dev Internal function to calculate spot price of two pools.
  /// @param encoding1 The encoding for the first pool.
  /// @param encoding2 The encoding for the second pool.
  /// @return price The spot price of the source, multiplied by 1e18.
  function _readSpotPrice(uint256 encoding1, uint256 encoding2) private view returns (uint256 price) {
    unchecked {
      price = (_readSpotPrice(encoding1) * _readSpotPrice(encoding2)) / PRECISION;
    }
  }

  /// @dev Internal function to calculate spot price of three pools.
  /// @param encoding1 The encoding for the first pool.
  /// @param encoding2 The encoding for the second pool.
  /// @param encoding3 The encoding for the third pool.
  /// @return price The spot price of the source, multiplied by 1e18.
  function _readSpotPrice(
    uint256 encoding1,
    uint256 encoding2,
    uint256 encoding3
  ) private view returns (uint256 price) {
    unchecked {
      price = (_readSpotPrice(encoding1, encoding2) * _readSpotPrice(encoding3)) / PRECISION;
    }
  }
}

// File: contracts/price-oracle/interfaces/ITwapOracle.sol

pragma solidity ^0.8.0;

interface ITwapOracle {
  /// @notice Return TWAP with 18 decimal places in the epoch ending at the specified timestamp.
  ///         Zero is returned if TWAP in the epoch is not available.
  /// @param timestamp End Timestamp in seconds of the epoch
  /// @return TWAP (18 decimal places) in the epoch, or zero if not available
  function getTwap(uint256 timestamp) external view returns (uint256);

  /// @notice Return the latest price with 18 decimal places.
  function getLatest() external view returns (uint256);
}

// File: contracts/price-oracle/LSDPriceOracleBase.sol

pragma solidity ^0.8.20;








abstract contract LSDPriceOracleBase is SpotPriceOracleBase, IPriceOracle {
  /*************
   * Constants *
   *************/

  /// @notice The Chainlink ETH/USD price feed.
  /// @dev See comments of `_readSpotPriceByChainlink` for more details.
  bytes32 public immutable Chainlink_ETH_USD_Spot;

  /*************
   * Variables *
   *************/

  /// @dev The encodings for ETH/USD spot sources.
  bytes private onchainSpotEncodings_ETHUSD;

  /// @dev The encodings for LSD/ETH spot sources.
  bytes private onchainSpotEncodings_LSDETH;

  /// @dev The encodings for LSD/USD spot sources.
  bytes private onchainSpotEncodings_LSDUSD;

  /// @notice The value of maximum price deviation, multiplied by 1e18.
  uint256 public maxPriceDeviation;

  /***************
   * Constructor *
   ***************/

  constructor(bytes32 _Chainlink_ETH_USD_Spot) {
    Chainlink_ETH_USD_Spot = _Chainlink_ETH_USD_Spot;

    _updateMaxPriceDeviation(1e16); // 1%
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the ETH/USD spot price.
  /// @return chainlinkPrice The spot price from Chainlink price feed.
  /// @return minPrice The minimum spot price among all available sources.
  /// @return maxPrice The maximum spot price among all available sources.
  function getETHUSDSpotPrice() external view returns (uint256 chainlinkPrice, uint256 minPrice, uint256 maxPrice) {
    (chainlinkPrice, minPrice, maxPrice) = _getETHUSDSpotPrice();
  }

  /// @notice Return the ETH/USD spot prices.
  /// @return prices The list of spot price among all available sources, multiplied by 1e18.
  function getETHUSDSpotPrices() external view returns (uint256[] memory prices) {
    prices = _getSpotPriceByEncoding(onchainSpotEncodings_ETHUSD);
  }

  /// @notice Return the LSD/ETH spot prices.
  /// @return prices The list of spot price among all available sources, multiplied by 1e18.
  function getLSDETHSpotPrices() public view returns (uint256[] memory prices) {
    prices = _getSpotPriceByEncoding(onchainSpotEncodings_LSDETH);
  }

  /// @notice Return the LSD/ETH spot prices.
  /// @return prices The list of spot price among all available sources, multiplied by 1e18.
  function getLSDUSDSpotPrices() public view returns (uint256[] memory prices) {
    prices = _getSpotPriceByEncoding(onchainSpotEncodings_LSDUSD);
  }

  /// @notice Return the LSD/USD anchor price, the price that is hard to manipulate in single tx.
  /// @return price The anchor price, multiplied by 1e18.
  function getLSDUSDAnchorPrice() external view returns (uint256 price) {
    price = _getLSDUSDAnchorPrice();
  }

  /// @inheritdoc IPriceOracle
  /// @dev The price is valid iff |maxPrice-minPrice|/minPrice < maxPriceDeviation
  function getPrice() external view override returns (uint256 anchorPrice, uint256 minPrice, uint256 maxPrice) {
    anchorPrice = _getLSDUSDAnchorPrice();
    (minPrice, maxPrice) = _getLSDMinMaxPrice(anchorPrice);

    uint256 cachedMaxPriceDeviation = maxPriceDeviation; // gas saving
    // use anchor price when the price deviation between anchor price and min price exceed threshold
    if ((anchorPrice - minPrice) * PRECISION > cachedMaxPriceDeviation * minPrice) {
      minPrice = anchorPrice;
    }

    // use anchor price when the price deviation between anchor price and max price exceed threshold
    if ((maxPrice - anchorPrice) * PRECISION > cachedMaxPriceDeviation * anchorPrice) {
      maxPrice = anchorPrice;
    }
  }

  /************************
   * Restricted Functions *
   ************************/

  /// @notice Update the on-chain spot encodings.
  /// @param encodings The encodings to update. See `_getSpotPriceByEncoding` for more details.
  /// @param spotType The type of the encodings.
  function updateOnchainSpotEncodings(bytes memory encodings, uint256 spotType) external onlyOwner {
    // validate encoding
    uint256[] memory prices = _getSpotPriceByEncoding(encodings);

    if (spotType == 0) {
      onchainSpotEncodings_ETHUSD = encodings;
      if (prices.length == 0) revert ErrorInvalidEncodings();
    } else if (spotType == 1) {
      onchainSpotEncodings_LSDETH = encodings;
    } else if (spotType == 2) {
      onchainSpotEncodings_LSDUSD = encodings;
    }
  }

  /// @notice Update the value of maximum price deviation.
  /// @param newMaxPriceDeviation The new value of maximum price deviation, multiplied by 1e18.
  function updateMaxPriceDeviation(uint256 newMaxPriceDeviation) external onlyOwner {
    _updateMaxPriceDeviation(newMaxPriceDeviation);
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Internal function to update the value of maximum price deviation.
  /// @param newMaxPriceDeviation The new value of maximum price deviation, multiplied by 1e18.
  function _updateMaxPriceDeviation(uint256 newMaxPriceDeviation) private {
    uint256 oldMaxPriceDeviation = maxPriceDeviation;
    if (oldMaxPriceDeviation == newMaxPriceDeviation) {
      revert ErrorParameterUnchanged();
    }

    maxPriceDeviation = newMaxPriceDeviation;

    emit UpdateMaxPriceDeviation(oldMaxPriceDeviation, newMaxPriceDeviation);
  }

  /// @dev Internal function to calculate the ETH/USD spot price.
  /// @return chainlinkPrice The spot price from Chainlink price feed, multiplied by 1e18.
  /// @return minPrice The minimum spot price among all available sources, multiplied by 1e18.
  /// @return maxPrice The maximum spot price among all available sources, multiplied by 1e18.
  function _getETHUSDSpotPrice() internal view returns (uint256 chainlinkPrice, uint256 minPrice, uint256 maxPrice) {
    chainlinkPrice = _readSpotPriceByChainlink(Chainlink_ETH_USD_Spot);
    uint256[] memory prices = _getSpotPriceByEncoding(onchainSpotEncodings_ETHUSD);
    minPrice = maxPrice = chainlinkPrice;
    for (uint256 i = 0; i < prices.length; i++) {
      if (prices[i] > maxPrice) maxPrice = prices[i];
      if (prices[i] < minPrice) minPrice = prices[i];
    }
  }

  /// @dev Internal function to return the min/max LSD/USD prices.
  /// @param anchorPrice The LSD/USD anchor price, multiplied by 1e18.
  /// @return minPrice The minimum price among all available sources (including twap), multiplied by 1e18.
  /// @return maxPrice The maximum price among all available sources (including twap), multiplied by 1e18.
  function _getLSDMinMaxPrice(uint256 anchorPrice) internal view returns (uint256 minPrice, uint256 maxPrice) {
    minPrice = maxPrice = anchorPrice;
    (, uint256 minETHUSDPrice, uint256 maxETHUSDPrice) = _getETHUSDSpotPrice();
    uint256[] memory LSD_ETH_prices = getLSDETHSpotPrices();
    uint256[] memory LSD_USD_prices = getLSDUSDSpotPrices();

    uint256 length = LSD_ETH_prices.length;
    uint256 LSD_ETH_minPrice = type(uint256).max;
    uint256 LSD_ETH_maxPrice;
    unchecked {
      for (uint256 i = 0; i < length; i++) {
        uint256 price = LSD_ETH_prices[i];
        if (price > LSD_ETH_maxPrice) LSD_ETH_maxPrice = price;
        if (price < LSD_ETH_minPrice) LSD_ETH_minPrice = price;
      }
      if (LSD_ETH_maxPrice != 0) {
        minPrice = Math.min(minPrice, (LSD_ETH_minPrice * minETHUSDPrice) / PRECISION);
        maxPrice = Math.max(maxPrice, (LSD_ETH_maxPrice * maxETHUSDPrice) / PRECISION);
      }

      length = LSD_USD_prices.length;
      for (uint256 i = 0; i < length; i++) {
        uint256 price = LSD_USD_prices[i];
        if (price > maxPrice) maxPrice = price;
        if (price < minPrice) minPrice = price;
      }
    }
  }

  /// @dev Internal function to return the LSD/USD anchor price.
  /// @return price The anchor price of LSD/USD, multiplied by 1e18.
  function _getLSDUSDAnchorPrice() internal view virtual returns (uint256 price);
}

// File: contracts/price-oracle/StETHPriceOracle.sol

pragma solidity ^0.8.20;






contract StETHPriceOracle is LSDPriceOracleBase {
  /***********************
   * Immutable Variables *
   ***********************/

  /// @notice The address of curve ETH/stETH pool.
  address public immutable Curve_ETH_stETH_Pool;

  /***************
   * Constructor *
   ***************/

  constructor(
    address _spotPriceOracle,
    bytes32 _Chainlink_ETH_USD_Spot,
    address _Curve_ETH_stETH_Pool
  ) SpotPriceOracleBase(_spotPriceOracle) LSDPriceOracleBase(_Chainlink_ETH_USD_Spot) {
    Curve_ETH_stETH_Pool = _Curve_ETH_stETH_Pool;
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @inheritdoc LSDPriceOracleBase
  /// @dev [Curve stETH/ETH ema price] * [Chainlink ETH/USD spot]
  function _getLSDUSDAnchorPrice() internal view virtual override returns (uint256) {
    uint256 stETH_ETH_CurveEma = ICurvePoolOracle(Curve_ETH_stETH_Pool).price_oracle();
    uint256 ETH_USD_ChainlinkSpot = _readSpotPriceByChainlink(Chainlink_ETH_USD_Spot);
    unchecked {
      return (stETH_ETH_CurveEma * ETH_USD_ChainlinkSpot) / PRECISION;
    }
  }
}

// File: contracts/v2/interfaces/IFxRebalancePoolRegistry.sol

pragma solidity ^0.8.0;

interface IFxRebalancePoolRegistry {
  /**********
   * Events *
   **********/

  /// @notice Emitted when a new rebalance pool is added.
  /// @param pool The address of the rebalance pool.
  event RegisterPool(address indexed pool);

  /// @notice Emitted when an exsited rebalance pool is removed.
  /// @param pool The address of the rebalance pool.
  event DeregisterPool(address indexed pool);

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return the address list of all registered RebalancePool.
  function getPools() external view returns (address[] memory pools);

  /// @notice Return the total amount of asset managed by all registered RebalancePool.
  function totalSupply() external view returns (uint256);
}

// File: contracts/v2/interfaces/IFxReservePool.sol

pragma solidity ^0.8.0;

interface IFxReservePool {
  /// @notice Request bonus token from Reserve Pool.
  /// @param token The address of token to request.
  /// @param receiver The address recipient for the bonus token.
  /// @param originalAmount The original amount of token used.
  /// @param bonus The amount of bonus token received.
  function requestBonus(
    address token,
    address receiver,
    uint256 originalAmount
  ) external returns (uint256 bonus);
}

// File: contracts/v2/MarketV2.sol

pragma solidity ^0.8.20;













// solhint-disable max-states-count

contract MarketV2 is AccessControlUpgradeable, ReentrancyGuardUpgradeable, IFxMarketV2 {
  using SafeERC20Upgradeable for IERC20Upgradeable;

  using WordCodec for bytes32;

  /*************
   * Constants *
   *************/

  /// @notice The role for emergency dao.
  bytes32 public constant EMERGENCY_DAO_ROLE = keccak256("EMERGENCY_DAO_ROLE");

  /// @notice The role for migrator.
  bytes32 public constant MIGRATOR_ROLE = keccak256("MIGRATOR_ROLE");

  /// @dev The precision used to compute nav.
  uint256 private constant FEE_PRECISION = 1e18;

  /// @dev The offset of mint flag in `marketConfigData`.
  uint256 private constant MINT_FLAG_OFFSET = 0;

  /// @dev The offset of redeem flag in `marketConfigData`.
  uint256 private constant REDEEM_FLAG_OFFSET = 1;

  /// @dev The offset of stability mode mint flag in `marketConfigData`.
  uint256 private constant MINT_FLAG_STABILITY_OFFSET = 2;

  /// @dev The offset of stability mode redeem flag in `marketConfigData`.
  uint256 private constant REDEEM_FLAG_STABILITY_OFFSET = 3;

  /// @dev The offset of stability ratio in `marketConfigData`.
  uint256 private constant STABILITY_RATIO_OFFSET = 34;

  /// @dev The offset of default fToken fee ratio in `mintFeeData` and `redeemFeeData`.
  uint256 private constant FTOKEN_DEFAULT_FEE_OFFSET = 0;

  /// @dev The offset of delta fToken fee ratio in `mintFeeData` and `redeemFeeData`.
  uint256 private constant FTOKEN_DELTA_FEE_OFFSET = 64;

  /// @dev The offset of default xToken fee ratio in `mintFeeData` and `redeemFeeData`.
  uint256 private constant XTOKEN_DEFAULT_FEE_OFFSET = 128;

  /// @dev The offset of delta xToken fee ratio in `mintFeeData` and `redeemFeeData`.
  uint256 private constant XTOKEN_DELTA_FEE_OFFSET = 192;

  /// @inheritdoc IFxMarketV2
  address public immutable override treasury;

  /// @inheritdoc IFxMarketV2
  address public immutable override baseToken;

  /// @inheritdoc IFxMarketV2
  address public immutable override fToken;

  /// @inheritdoc IFxMarketV2
  address public immutable override xToken;

  /*************
   * Variables *
   *************/

  /// @dev `marketConfigData` is a storage slot that can be used to store market configuration.
  ///
  /// - The *mint flag* indicate whether the token mint is paused (both fToken and xToken).
  /// - The *redeem flag* indicate whether the token redeem is paused (both fToken and xToken).
  /// - The *mint flag stability* indicate whether the fToken mint is paused in stability mode.
  /// - The *redeem flag stability* indicate whether the xToken redeem is paused in stability mode.
  /// - The *stability ratio* is the collateral ratio to enter stability mode, multiplied by 1e18.
  ///
  /// [ mint flag | redeem flag | mint flag stability | redeem flag stability | stability ratio | available ]
  /// [   1 bit   |    1 bit    |        1 bit        |         1 bit         |     64 bits     |  188 bits ]
  /// [ MSB                                                                                             LSB ]
  bytes32 private marketConfigData;

  /// @dev `mintFeeData` is a storage slot that can be used to store mint fee ratio.
  ///
  /// [ default fToken | delta fToken | default xToken | delta xToken |
  /// [     64 bit     |    64 bit    |     64 bit     |    64 bit    ]
  /// [ MSB                                                       LSB ]
  bytes32 private mintFeeData;

  /// @dev `redeemFeeData` is a storage slot that can be used to store redeem fee ratio.
  ///
  /// [ default fToken | delta fToken | default xToken | delta xToken |
  /// [     64 bit     |    64 bit    |     64 bit     |    64 bit    ]
  /// [ MSB                                                       LSB ]
  bytes32 private redeemFeeData;

  /// @notice The address of platform contract;
  address public platform;

  /// @notice The address of ReservePool contract.
  address public reservePool;

  /// @notice The address of RebalancePoolRegistry contract.
  address public registry;

  /// @inheritdoc IFxMarketV2
  address public fxUSD;

  /// @dev Slots for future use.
  uint256[43] private _gap;

  /***************
   * Constructor *
   ***************/

  constructor(address _treasury) {
    treasury = _treasury;

    baseToken = IFxTreasuryV2(_treasury).baseToken();
    fToken = IFxTreasuryV2(_treasury).fToken();
    xToken = IFxTreasuryV2(_treasury).xToken();
  }

  function initialize(address _platform, address _reservePool, address _registry) external initializer {
    __Context_init();
    __ERC165_init();
    __AccessControl_init();
    __ReentrancyGuard_init();

    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _updatePlatform(_platform);
    _updateReservePool(_reservePool);
    _updateRebalancePoolRegistry(_registry);
  }

  /*************************
   * Public View Functions *
   *************************/

  /// @notice Return whether token mint is paused.
  function mintPaused() public view returns (bool) {
    return marketConfigData.decodeBool(MINT_FLAG_OFFSET);
  }

  /// @notice Return whether token redeem is paused.
  function redeemPaused() public view returns (bool) {
    return marketConfigData.decodeBool(REDEEM_FLAG_OFFSET);
  }

  /// @notice Return whether fToken mint is paused in stability mode.
  function fTokenMintPausedInStabilityMode() public view returns (bool) {
    return marketConfigData.decodeBool(MINT_FLAG_STABILITY_OFFSET);
  }

  /// @notice Return whether xToken redeem is paused in stability mode.
  function xTokenRedeemPausedInStabilityMode() public view returns (bool) {
    return marketConfigData.decodeBool(REDEEM_FLAG_STABILITY_OFFSET);
  }

  /// @inheritdoc IFxMarketV2
  function stabilityRatio() public view returns (uint256) {
    return marketConfigData.decodeUint(STABILITY_RATIO_OFFSET, 64);
  }

  /// @notice The mint fee ratio for fToken.
  function fTokenMintFeeRatio() public view returns (uint256 defaultFee, int256 deltaFee) {
    bytes32 _mintFeeData = mintFeeData;
    defaultFee = _mintFeeData.decodeUint(FTOKEN_DEFAULT_FEE_OFFSET, 64);
    deltaFee = _mintFeeData.decodeInt(FTOKEN_DELTA_FEE_OFFSET, 64);
  }

  /// @notice The mint fee ratio for xToken.
  function xTokenMintFeeRatio() public view returns (uint256 defaultFee, int256 deltaFee) {
    bytes32 _mintFeeData = mintFeeData;
    defaultFee = _mintFeeData.decodeUint(XTOKEN_DEFAULT_FEE_OFFSET, 64);
    deltaFee = _mintFeeData.decodeInt(XTOKEN_DELTA_FEE_OFFSET, 64);
  }

  /// @notice The redeem fee ratio for fToken.
  function fTokenRedeemFeeRatio() public view returns (uint256 defaultFee, int256 deltaFee) {
    bytes32 _redeemFeeData = redeemFeeData;
    defaultFee = _redeemFeeData.decodeUint(FTOKEN_DEFAULT_FEE_OFFSET, 64);
    deltaFee = _redeemFeeData.decodeInt(FTOKEN_DELTA_FEE_OFFSET, 64);
  }

  /// @notice The redeem fee ratio for xToken.
  function xTokenRedeemFeeRatio() public view returns (uint256 defaultFee, int256 deltaFee) {
    bytes32 _redeemFeeData = redeemFeeData;
    defaultFee = _redeemFeeData.decodeUint(XTOKEN_DEFAULT_FEE_OFFSET, 64);
    deltaFee = _redeemFeeData.decodeInt(XTOKEN_DELTA_FEE_OFFSET, 64);
  }

  /****************************
   * Public Mutated Functions *
   ****************************/

  /// @inheritdoc IFxMarketV2
  function mintFToken(
    uint256 _baseIn,
    address _recipient,
    uint256 _minFTokenMinted
  ) external override nonReentrant returns (uint256 _fTokenMinted) {
    if (mintPaused()) revert ErrorMintPaused();

    // make sure caller is fxUSD, when fxUSD is enabled
    {
      address _fxUSD = fxUSD;
      if (_fxUSD != address(0) && _fxUSD != _msgSender()) revert ErrorCallerNotFUSD();
    }
    _beforeMintFToken();

    if (_baseIn == type(uint256).max) {
      _baseIn = IERC20Upgradeable(baseToken).balanceOf(_msgSender());
    }
    if (_baseIn == 0) revert ErrorMintZeroAmount();

    uint256 _stabilityRatio = stabilityRatio();
    (uint256 _maxBaseInBeforeSystemStabilityMode, ) = IFxTreasuryV2(treasury).maxMintableFToken(_stabilityRatio);
    if (_maxBaseInBeforeSystemStabilityMode > 0) {
      _maxBaseInBeforeSystemStabilityMode = IFxTreasuryV2(treasury).getWrapppedValue(
        _maxBaseInBeforeSystemStabilityMode
      );
    }

    if (fTokenMintPausedInStabilityMode()) {
      uint256 _collateralRatio = IFxTreasuryV2(treasury).collateralRatio();
      if (_collateralRatio <= _stabilityRatio) revert ErrorFTokenMintPausedInStabilityMode();

      // bound maximum amount of base token to mint fToken.
      if (_baseIn > _maxBaseInBeforeSystemStabilityMode) {
        _baseIn = _maxBaseInBeforeSystemStabilityMode;
      }
    }

    uint256 _amountWithoutFee = _deductFTokenMintFee(_baseIn, _maxBaseInBeforeSystemStabilityMode);
    IERC20Upgradeable(baseToken).safeTransferFrom(_msgSender(), treasury, _amountWithoutFee);

    _fTokenMinted = IFxTreasuryV2(treasury).mintFToken(
      IFxTreasuryV2(treasury).getUnderlyingValue(_amountWithoutFee),
      _recipient
    );
    if (_fTokenMinted < _minFTokenMinted) revert ErrorInsufficientFTokenOutput();

    emit MintFToken(_msgSender(), _recipient, _baseIn, _fTokenMinted, _baseIn - _amountWithoutFee);
  }

  /// @inheritdoc IFxMarketV2
  function mintXToken(
    uint256 _baseIn,
    address _recipient,
    uint256 _minXTokenMinted
  ) external override nonReentrant returns (uint256 _xTokenMinted, uint256 _bonus) {
    if (mintPaused()) revert ErrorMintPaused();
    _beforeMintXToken();

    if (_baseIn == type(uint256).max) {
      _baseIn = IERC20Upgradeable(baseToken).balanceOf(_msgSender());
    }
    if (_baseIn == 0) revert ErrorMintZeroAmount();

    uint256 _stabilityRatio = stabilityRatio();
    (uint256 _maxBaseInBeforeSystemStabilityMode, ) = IFxTreasuryV2(treasury).maxMintableXToken(_stabilityRatio);
    if (_maxBaseInBeforeSystemStabilityMode > 0) {
      _maxBaseInBeforeSystemStabilityMode = IFxTreasuryV2(treasury).getWrapppedValue(
        _maxBaseInBeforeSystemStabilityMode
      );
    }

    uint256 _amountWithoutFee = _deductXTokenMintFee(_baseIn, _maxBaseInBeforeSystemStabilityMode);
    IERC20Upgradeable(baseToken).safeTransferFrom(_msgSender(), treasury, _amountWithoutFee);

    _xTokenMinted = IFxTreasuryV2(treasury).mintXToken(
      IFxTreasuryV2(treasury).getUnderlyingValue(_amountWithoutFee),
      _recipient
    );
    if (_xTokenMinted < _minXTokenMinted) revert ErrorInsufficientXTokenOutput();

    // give bnous
    if (_amountWithoutFee < _maxBaseInBeforeSystemStabilityMode) {
      _bonus = _amountWithoutFee;
    } else {
      _bonus = _maxBaseInBeforeSystemStabilityMode;
    }
    if (_bonus > 0 && IFxRebalancePoolRegistry(registry).totalSupply() == 0) {
      _bonus = IFxReservePool(reservePool).requestBonus(baseToken, _recipient, _bonus);
    } else {
      _bonus = 0;
    }

    emit MintXToken(_msgSender(), _recipient, _baseIn, _xTokenMinted, _bonus, _baseIn - _amountWithoutFee);
  }

  /// @inheritdoc IFxMarketV2
  function redeemFToken(
    uint256 _fTokenIn,
    address _recipient,
    uint256 _minBaseOut
  ) external override nonReentrant returns (uint256 _baseOut, uint256 _bonus) {
    if (redeemPaused()) revert ErrorRedeemPaused();
    _beforeRedeemFToken();

    if (_fTokenIn == type(uint256).max) {
      _fTokenIn = IERC20Upgradeable(fToken).balanceOf(_msgSender());
    }
    if (_fTokenIn == 0) revert ErrorRedeemZeroAmount();

    uint256 _stabilityRatio = stabilityRatio();
    (uint256 _maxBaseOut, uint256 _maxFTokenInBeforeSystemStabilityMode) = IFxTreasuryV2(treasury).maxRedeemableFToken(
      _stabilityRatio
    );
    uint256 _feeRatio;
    if (!hasRole(MIGRATOR_ROLE, _msgSender())) {
      _feeRatio = _computeFTokenRedeemFeeRatio(_fTokenIn, _maxFTokenInBeforeSystemStabilityMode);
    }

    _baseOut = IFxTreasuryV2(treasury).redeem(_fTokenIn, 0, _msgSender());
    // give bonus when redeem fToken
    if (_baseOut < _maxBaseOut) {
      _bonus = _baseOut;
    } else {
      _bonus = _maxBaseOut;
    }

    // request bonus
    if (_bonus > 0 && IFxRebalancePoolRegistry(registry).totalSupply() == 0) {
      (uint256 _defaultRatio, int256 _deltaRatio) = fTokenMintFeeRatio();
      _bonus -= (_bonus * uint256(int256(_defaultRatio) + _deltaRatio)) / FEE_PRECISION; // deduct fee
      _bonus = IFxReservePool(reservePool).requestBonus(
        baseToken,
        _recipient,
        IFxTreasuryV2(treasury).getWrapppedValue(_bonus)
      );
    } else {
      _bonus = 0;
    }

    _baseOut = IFxTreasuryV2(treasury).getWrapppedValue(_baseOut);
    uint256 _balance = IERC20Upgradeable(baseToken).balanceOf(address(this));
    // consider possible slippage
    if (_balance < _baseOut) {
      _baseOut = _balance;
    }

    uint256 _fee = (_baseOut * _feeRatio) / FEE_PRECISION;
    if (_fee > 0) {
      IERC20Upgradeable(baseToken).safeTransfer(platform, _fee);
      _baseOut = _baseOut - _fee;
    }
    if (_baseOut < _minBaseOut) revert ErrorInsufficientBaseOutput();

    IERC20Upgradeable(baseToken).safeTransfer(_recipient, _baseOut);

    emit RedeemFToken(_msgSender(), _recipient, _fTokenIn, _baseOut, _bonus, _fee);
  }

  /// @inheritdoc IFxMarketV2
  function redeemXToken(
    uint256 _xTokenIn,
    address _recipient,
    uint256 _minBaseOut
  ) external override nonReentrant returns (uint256 _baseOut) {
    if (redeemPaused()) revert ErrorRedeemPaused();
    _beforeRedeemXToken();

    if (_xTokenIn == type(uint256).max) {
      _xTokenIn = IERC20Upgradeable(xToken).balanceOf(_msgSender());
    }
    if (_xTokenIn == 0) revert ErrorRedeemZeroAmount();

    uint256 _stabilityRatio = stabilityRatio();
    uint256 _feeRatio;
    (, uint256 _maxXTokenInBeforeSystemStabilityMode) = IFxTreasuryV2(treasury).maxRedeemableXToken(_stabilityRatio);

    if (xTokenRedeemPausedInStabilityMode()) {
      uint256 _collateralRatio = IFxTreasuryV2(treasury).collateralRatio();
      if (_collateralRatio <= _stabilityRatio) revert ErrorXTokenRedeemPausedInStabilityMode();

      // bound maximum amount of xToken to redeem.
      if (_xTokenIn > _maxXTokenInBeforeSystemStabilityMode) {
        _xTokenIn = _maxXTokenInBeforeSystemStabilityMode;
      }
    }

    if (!hasRole(MIGRATOR_ROLE, _msgSender())) {
      _feeRatio = _computeXTokenRedeemFeeRatio(_xTokenIn, _maxXTokenInBeforeSystemStabilityMode);
    }

    _baseOut = IFxTreasuryV2(treasury).redeem(0, _xTokenIn, _msgSender());
    _baseOut = IFxTreasuryV2(treasury).getWrapppedValue(_baseOut);
    uint256 _balance = IERC20Upgradeable(baseToken).balanceOf(address(this));
    // consider possible slippage
    if (_balance < _baseOut) {
      _baseOut = _balance;
    }

    uint256 _fee = (_baseOut * _feeRatio) / FEE_PRECISION;
    if (_fee > 0) {
      IERC20Upgradeable(baseToken).safeTransfer(platform, _fee);
      _baseOut = _baseOut - _fee;
    }
    if (_baseOut < _minBaseOut) revert ErrorInsufficientBaseOutput();

    IERC20Upgradeable(baseToken).safeTransfer(_recipient, _baseOut);

    emit RedeemXToken(_msgSender(), _recipient, _xTokenIn, _baseOut, _fee);
  }

  /*******************************
   * Public Restricted Functions *
   *******************************/

  /// @notice Update the fee ratio for redeeming.
  /// @param _defaultFeeRatio The new default fee ratio, multipled by 1e18.
  /// @param _extraFeeRatio The new extra fee ratio, multipled by 1e18.
  /// @param _isFToken Whether we are updating for fToken.
  function updateRedeemFeeRatio(
    uint256 _defaultFeeRatio,
    int256 _extraFeeRatio,
    bool _isFToken
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _validateFeeRatio(_defaultFeeRatio, _extraFeeRatio);

    bytes32 _redeemFeeData = redeemFeeData;
    if (_isFToken) {
      _redeemFeeData = _redeemFeeData.insertUint(_defaultFeeRatio, FTOKEN_DEFAULT_FEE_OFFSET, 64);
      _redeemFeeData = _redeemFeeData.insertInt(_extraFeeRatio, FTOKEN_DELTA_FEE_OFFSET, 64);
      emit UpdateRedeemFeeRatioFToken(_defaultFeeRatio, _extraFeeRatio);
    } else {
      _redeemFeeData = _redeemFeeData.insertUint(_defaultFeeRatio, XTOKEN_DEFAULT_FEE_OFFSET, 64);
      _redeemFeeData = _redeemFeeData.insertInt(_extraFeeRatio, XTOKEN_DELTA_FEE_OFFSET, 64);
      emit UpdateRedeemFeeRatioXToken(_defaultFeeRatio, _extraFeeRatio);
    }
    redeemFeeData = _redeemFeeData;
  }

  /// @notice Update the fee ratio for minting.
  /// @param _defaultFeeRatio The new default fee ratio, multipled by 1e18.
  /// @param _extraFeeRatio The new extra fee ratio, multipled by 1e18.
  /// @param _isFToken Whether we are updating for fToken.
  function updateMintFeeRatio(
    uint128 _defaultFeeRatio,
    int128 _extraFeeRatio,
    bool _isFToken
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _validateFeeRatio(_defaultFeeRatio, _extraFeeRatio);

    bytes32 _mintFeeData = mintFeeData;
    if (_isFToken) {
      _mintFeeData = _mintFeeData.insertUint(_defaultFeeRatio, FTOKEN_DEFAULT_FEE_OFFSET, 64);
      _mintFeeData = _mintFeeData.insertInt(_extraFeeRatio, FTOKEN_DELTA_FEE_OFFSET, 64);
      emit UpdateMintFeeRatioFToken(_defaultFeeRatio, _extraFeeRatio);
    } else {
      _mintFeeData = _mintFeeData.insertUint(_defaultFeeRatio, XTOKEN_DEFAULT_FEE_OFFSET, 64);
      _mintFeeData = _mintFeeData.insertInt(_extraFeeRatio, XTOKEN_DELTA_FEE_OFFSET, 64);
      emit UpdateMintFeeRatioXToken(_defaultFeeRatio, _extraFeeRatio);
    }
    mintFeeData = _mintFeeData;
  }

  /// @notice Update the stability ratio.
  /// @param _newRatio The new collateral ratio to enter stability mode, multiplied by 1e18.
  function updateStabilityRatio(uint256 _newRatio) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateStabilityRatio(_newRatio);
  }

  /// @notice Update mint pause status.
  /// @param _newStatus The new mint pause status.
  function updateMintStatus(bool _newStatus) external onlyRole(EMERGENCY_DAO_ROLE) {
    bool _oldStatus = _updateBoolInMarketConfigData(MINT_FLAG_OFFSET, _newStatus);

    emit UpdateMintStatus(_oldStatus, _newStatus);
  }

  /// @notice Update redeem pause status.
  /// @param _newStatus The new redeem pause status.
  function updateRedeemStatus(bool _newStatus) external onlyRole(EMERGENCY_DAO_ROLE) {
    bool _oldStatus = _updateBoolInMarketConfigData(REDEEM_FLAG_OFFSET, _newStatus);

    emit UpdateRedeemStatus(_oldStatus, _newStatus);
  }

  /// @notice Update fToken mint pause status in stability mode.
  /// @param _newStatus The new mint pause status.
  function updateFTokenMintStatusInStabilityMode(bool _newStatus) external onlyRole(EMERGENCY_DAO_ROLE) {
    bool _oldStatus = _updateBoolInMarketConfigData(MINT_FLAG_STABILITY_OFFSET, _newStatus);

    emit UpdateFTokenMintStatusInStabilityMode(_oldStatus, _newStatus);
  }

  /// @notice Update xToken redeem status in stability mode
  /// @param _newStatus The new redeem pause status.
  function updateXTokenRedeemStatusInStabilityMode(bool _newStatus) external onlyRole(EMERGENCY_DAO_ROLE) {
    bool _oldStatus = _updateBoolInMarketConfigData(REDEEM_FLAG_STABILITY_OFFSET, _newStatus);

    emit UpdateXTokenRedeemStatusInStabilityMode(_oldStatus, _newStatus);
  }

  /// @notice Change address of platform contract.
  /// @param _newPlatform The new address of platform contract.
  function updatePlatform(address _newPlatform) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updatePlatform(_newPlatform);
  }

  /// @notice Change address of reserve pool contract.
  /// @param _newReservePool The new address of reserve pool contract.
  function updateReservePool(address _newReservePool) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateReservePool(_newReservePool);
  }

  /// @notice Change address of RebalancePoolRegistry contract.
  /// @param _newRegistry The new address of RebalancePoolRegistry contract.
  function updateRebalancePoolRegistry(address _newRegistry) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _updateRebalancePoolRegistry(_newRegistry);
  }

  /// @notice Enable fxUSD mint.
  /// @param _fxUSD The address of fxUSD token.
  function enableFxUSD(address _fxUSD) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_fxUSD == address(0)) revert ErrorZeroAddress();

    if (fxUSD == address(0)) fxUSD = _fxUSD;
  }

  /**********************
   * Internal Functions *
   **********************/

  /// @dev Hook function to call before mint fToken.
  function _beforeMintFToken() internal virtual {}

  /// @dev Hook function to call before mint xToken.
  function _beforeMintXToken() internal virtual {}

  /// @dev Hook function to call before redeem fToken.
  function _beforeRedeemFToken() internal virtual {}

  /// @dev Hook function to call before redeem xToken.
  function _beforeRedeemXToken() internal virtual {}

  /// @dev Internal function to validate fee ratio.
  function _validateFeeRatio(uint256 _defaultFeeRatio, int256 _extraFeeRatio) internal pure {
    if (_defaultFeeRatio > FEE_PRECISION) revert ErrorDefaultFeeTooLarge();
    if (_extraFeeRatio < 0) {
      if (uint256(-_extraFeeRatio) > _defaultFeeRatio) revert ErrorDeltaFeeTooSmall();
    } else {
      if (uint256(_extraFeeRatio) > FEE_PRECISION - _defaultFeeRatio) revert ErrorTotalFeeTooLarge();
    }
  }

  /// @dev Internal function to update bool value in `marketConfigData`.
  /// @param offset The offset of the value in `marketConfigData`.
  /// @param newValue The value to update.
  /// @return oldValue The original value in the `offset`.
  function _updateBoolInMarketConfigData(uint256 offset, bool newValue) private returns (bool oldValue) {
    bytes32 _data = marketConfigData;
    oldValue = _data.decodeBool(offset);
    marketConfigData = _data.insertBool(newValue, offset);
  }

  /// @dev Internal function to update stability ratio.
  /// @param _newRatio The new collateral ratio to enter stability mode, multiplied by 1e18.
  function _updateStabilityRatio(uint256 _newRatio) private {
    if (_newRatio > type(uint64).max) revert ErrorStabilityRatioTooLarge();

    bytes32 _data = marketConfigData;
    uint256 _oldRatio = _data.decodeUint(STABILITY_RATIO_OFFSET, 64);
    marketConfigData = _data.insertUint(_newRatio, STABILITY_RATIO_OFFSET, 64);

    emit UpdateStabilityRatio(_oldRatio, _newRatio);
  }

  /// @notice Change address of platform contract.
  /// @param _newPlatform The new address of platform contract.
  function _updatePlatform(address _newPlatform) private {
    if (_newPlatform == address(0)) revert ErrorZeroAddress();

    address _oldPlatform = platform;
    platform = _newPlatform;

    emit UpdatePlatform(_oldPlatform, _newPlatform);
  }

  /// @notice Change address of reserve pool contract.
  /// @param _newReservePool The new address of reserve pool contract.
  function _updateReservePool(address _newReservePool) private {
    if (_newReservePool == address(0)) revert ErrorZeroAddress();

    address _oldReservePool = reservePool;
    reservePool = _newReservePool;

    emit UpdateReservePool(_oldReservePool, _newReservePool);
  }

  /// @notice Change address of RebalancePoolRegistry contract.
  /// @param _newRegistry The new address of RebalancePoolRegistry contract.
  function _updateRebalancePoolRegistry(address _newRegistry) private {
    if (_newRegistry == address(0)) revert ErrorZeroAddress();

    address _oldRegistry = registry;
    registry = _newRegistry;

    emit UpdateRebalancePoolRegistry(_oldRegistry, _newRegistry);
  }

  /// @dev Internal function to deduct fToken mint fee for base token.
  /// @param _baseIn The amount of base token.
  /// @param _maxBaseInBeforeSystemStabilityMode The maximum amount of base token can be deposit before entering system stability mode.
  /// @return _baseInWithoutFee The amount of base token without fee.
  function _deductFTokenMintFee(
    uint256 _baseIn,
    uint256 _maxBaseInBeforeSystemStabilityMode
  ) private returns (uint256 _baseInWithoutFee) {
    // [0, _maxBaseInBeforeSystemStabilityMode) => default = fee_ratio_0
    // [_maxBaseInBeforeSystemStabilityMode, infinity) => default + extra = fee_ratio_1

    (uint256 _defaultRatio, int256 _deltaRatio) = fTokenMintFeeRatio();
    uint256 _feeRatio0 = _defaultRatio;
    uint256 _feeRatio1 = uint256(int256(_defaultRatio) + _deltaRatio);

    _baseInWithoutFee = _deductMintFee(_baseIn, _feeRatio0, _feeRatio1, _maxBaseInBeforeSystemStabilityMode);
  }

  /// @dev Internal function to deduct fToken mint fee for base token.
  /// @param _baseIn The amount of base token.
  /// @param _maxBaseInBeforeSystemStabilityMode The maximum amount of base token can be deposit before entering system stability mode.
  /// @return _baseInWithoutFee The amount of base token without fee.
  function _deductXTokenMintFee(
    uint256 _baseIn,
    uint256 _maxBaseInBeforeSystemStabilityMode
  ) private returns (uint256 _baseInWithoutFee) {
    // [0, _maxBaseInBeforeSystemStabilityMode) => default + extra = fee_ratio_0
    // [_maxBaseInBeforeSystemStabilityMode, infinity) => default = fee_ratio_1

    (uint256 _defaultRatio, int256 _deltaRatio) = xTokenMintFeeRatio();
    uint256 _feeRatio0 = uint256(int256(_defaultRatio) + _deltaRatio);
    uint256 _feeRatio1 = _defaultRatio;

    _baseInWithoutFee = _deductMintFee(_baseIn, _feeRatio0, _feeRatio1, _maxBaseInBeforeSystemStabilityMode);
  }

  function _deductMintFee(
    uint256 _baseIn,
    uint256 _feeRatio0,
    uint256 _feeRatio1,
    uint256 _maxBaseInBeforeSystemStabilityMode
  ) private returns (uint256 _baseInWithoutFee) {
    uint256 _maxBaseIn = (_maxBaseInBeforeSystemStabilityMode * FEE_PRECISION) / (FEE_PRECISION - _feeRatio0);

    // compute fee
    uint256 _fee;
    if (_baseIn <= _maxBaseIn) {
      _fee = (_baseIn * _feeRatio0) / FEE_PRECISION;
    } else {
      _fee = (_maxBaseIn * _feeRatio0) / FEE_PRECISION;
      _fee += ((_baseIn - _maxBaseIn) * _feeRatio1) / FEE_PRECISION;
    }

    _baseInWithoutFee = _baseIn - _fee;
    // take fee to platform
    if (_fee > 0) {
      IERC20Upgradeable(baseToken).safeTransferFrom(_msgSender(), platform, _fee);
    }
  }

  /// @dev Internal function to deduct mint fee for base token.
  /// @param _amountIn The amount of fToken.
  /// @param _maxInBeforeSystemStabilityMode The maximum amount of fToken can be redeemed before leaving system stability mode.
  /// @return _feeRatio The computed fee ratio for base token redeemed.
  function _computeFTokenRedeemFeeRatio(
    uint256 _amountIn,
    uint256 _maxInBeforeSystemStabilityMode
  ) private view returns (uint256 _feeRatio) {
    // [0, _maxBaseInBeforeSystemStabilityMode) => default + extra = fee_ratio_0
    // [_maxBaseInBeforeSystemStabilityMode, infinity) => default = fee_ratio_1

    (uint256 _defaultRatio, int256 _deltaRatio) = fTokenRedeemFeeRatio();
    uint256 _feeRatio0 = uint256(int256(_defaultRatio) + _deltaRatio);
    uint256 _feeRatio1 = _defaultRatio;

    _feeRatio = _computeRedeemFeeRatio(_amountIn, _feeRatio0, _feeRatio1, _maxInBeforeSystemStabilityMode);
  }

  /// @dev Internal function to deduct mint fee for base token.
  /// @param _amountIn The amount of xToken.
  /// @param _maxInBeforeSystemStabilityMode The maximum amount of xToken can be redeemed before entering system stability mode.
  /// @return _feeRatio The computed fee ratio for base token redeemed.
  function _computeXTokenRedeemFeeRatio(
    uint256 _amountIn,
    uint256 _maxInBeforeSystemStabilityMode
  ) private view returns (uint256 _feeRatio) {
    // [0, _maxBaseInBeforeSystemStabilityMode) => default = fee_ratio_0
    // [_maxBaseInBeforeSystemStabilityMode, infinity) => default + extra = fee_ratio_1

    (uint256 _defaultRatio, int256 _deltaRatio) = xTokenRedeemFeeRatio();
    uint256 _feeRatio0 = _defaultRatio;
    uint256 _feeRatio1 = uint256(int256(_defaultRatio) + _deltaRatio);

    _feeRatio = _computeRedeemFeeRatio(_amountIn, _feeRatio0, _feeRatio1, _maxInBeforeSystemStabilityMode);
  }

  /// @dev Internal function to deduct mint fee for base token.
  /// @param _amountIn The amount of fToken or xToken.
  /// @param _feeRatio0 The default fee ratio.
  /// @param _feeRatio1 The second fee ratio.
  /// @param _maxInBeforeSystemStabilityMode The maximum amount of fToken/xToken can be redeemed before entering/leaving system stability mode.
  /// @return _feeRatio The computed fee ratio for base token redeemed.
  function _computeRedeemFeeRatio(
    uint256 _amountIn,
    uint256 _feeRatio0,
    uint256 _feeRatio1,
    uint256 _maxInBeforeSystemStabilityMode
  ) private pure returns (uint256 _feeRatio) {
    if (_amountIn <= _maxInBeforeSystemStabilityMode) {
      return _feeRatio0;
    }
    uint256 _fee = _maxInBeforeSystemStabilityMode * _feeRatio0;
    _fee += (_amountIn - _maxInBeforeSystemStabilityMode) * _feeRatio1;
    return _fee / _amountIn;
  }
}
