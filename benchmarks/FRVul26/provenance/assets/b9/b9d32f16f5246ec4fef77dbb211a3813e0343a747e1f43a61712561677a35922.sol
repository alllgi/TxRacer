// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/ICallProxy.sol

pragma solidity ^0.8.7;

interface ICallProxy {

    /// @dev Chain from which the current submission is received
    function submissionChainIdFrom() external view returns (uint256);
    /// @dev Native sender of the current submission
    function submissionNativeSender() external view returns (bytes memory);

    /// @dev Used for calls where native asset transfer is involved.
    /// @param _reserveAddress Receiver of the tokens if the call to _receiver fails
    /// @param _receiver Contract to be called
    /// @param _data Call data
    /// @param _flags Flags to change certain behavior of this function, see Flags library for more details
    /// @param _nativeSender Native sender
    /// @param _chainIdFrom Id of a chain that originated the request
    function call(
        address _reserveAddress,
        address _receiver,
        bytes memory _data,
        uint256 _flags,
        bytes memory _nativeSender,
        uint256 _chainIdFrom
    ) external payable returns (bool);

    /// @dev Used for calls where ERC20 transfer is involved.
    /// @param _token Asset address
    /// @param _reserveAddress Receiver of the tokens if the call to _receiver fails
    /// @param _receiver Contract to be called
    /// @param _data Call data
    /// @param _flags Flags to change certain behavior of this function, see Flags library for more details
    /// @param _nativeSender Native sender
    /// @param _chainIdFrom Id of a chain that originated the request
    function callERC20(
        address _token,
        address _reserveAddress,
        address _receiver,
        bytes memory _data,
        uint256 _flags,
        bytes memory _nativeSender,
        uint256 _chainIdFrom
    ) external returns (bool);
}

// File: contracts/libraries/SafeCast.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

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
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
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
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
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
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
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
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/libraries/SignatureUtil.sol

pragma solidity ^0.8.7;

library SignatureUtil {
    /* ========== ERRORS ========== */

    error WrongArgumentLength();
    error SignatureInvalidLength();
    error SignatureInvalidV();

    /// @dev Prepares raw msg that was signed by the oracle.
    /// @param _submissionId Submission identifier.
    function getUnsignedMsg(bytes32 _submissionId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _submissionId));
    }

    /// @dev Splits signature bytes to r,s,v components.
    /// @param _signature Signature bytes in format r+s+v.
    function splitSignature(bytes memory _signature)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        if (_signature.length != 65) revert SignatureInvalidLength();
        return parseSignature(_signature, 0);
    }

    function parseSignature(bytes memory _signatures, uint256 offset)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        assembly {
            r := mload(add(_signatures, add(32, offset)))
            s := mload(add(_signatures, add(64, offset)))
            v := and(mload(add(_signatures, add(65, offset))), 0xff)
        }

        if (v < 27) v += 27;
        if (v != 27 && v != 28) revert SignatureInvalidV();
    }

    function toUint256(bytes memory _bytes, uint256 _offset)
        internal
        pure
        returns (uint256 result)
    {
        if (_bytes.length < _offset + 32) revert WrongArgumentLength();

        assembly {
            result := mload(add(add(_bytes, 0x20), _offset))
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/libraries/Permit.sol

pragma solidity ^0.8.7;





library Permit {
    using SignatureUtil for bytes;

    error PermitFailure();

    function executePermit(address _tokenAddress, bytes memory _permitEnvelope) internal {
        if (_permitEnvelope.length > 0) {
            uint256 permitAmount = _permitEnvelope.toUint256(0);
            uint256 deadline = _permitEnvelope.toUint256(32);
            (bytes32 r, bytes32 s, uint8 v) = _permitEnvelope.parseSignature(64);
            try
                IERC20Permit(_tokenAddress).permit(
                    msg.sender,
                    address(this),
                    permitAmount,
                    deadline,
                    v,
                    r,
                    s
                )
            {
                return;
            } catch {
                if (IERC20(_tokenAddress).allowance(msg.sender, address(this)) >= permitAmount) {
                    return;
                }
            }

            revert PermitFailure();
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol

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

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

// File: @openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol

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

// File: @openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol

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

// File: @openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

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
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
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
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
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

// File: @openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;




/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/IDeBridgeGate.sol

pragma solidity ^0.8.7;

interface IDeBridgeGate {
    /* ========== STRUCTS ========== */

    struct TokenInfo {
        uint256 nativeChainId;
        bytes nativeAddress;
    }

    struct DebridgeInfo {
        uint256 chainId; // native chain id
        uint256 maxAmount; // maximum amount to transfer
        uint256 balance; // total locked assets
        uint256 lockedInStrategies; // total locked assets in strategy (AAVE, Compound, etc)
        address tokenAddress; // asset address on the current chain
        uint16 minReservesBps; // minimal hot reserves in basis points (1/10000)
        bool exist;
    }

    struct DebridgeFeeInfo {
        uint256 collectedFees; // total collected fees
        uint256 withdrawnFees; // fees that already withdrawn
        mapping(uint256 => uint256) getChainFee; // whether the chain for the asset is supported
    }

    struct ChainSupportInfo {
        uint256 fixedNativeFee; // transfer fixed fee
        bool isSupported; // whether the chain for the asset is supported
        uint16 transferFeeBps; // transfer fee rate nominated in basis points (1/10000) of transferred amount
    }

    struct DiscountInfo {
        uint16 discountFixBps; // fix discount in BPS
        uint16 discountTransferBps; // transfer % discount in BPS
    }

    /// @param executionFee Fee paid to the transaction executor.
    /// @param fallbackAddress Receiver of the tokens if the call fails.
    struct SubmissionAutoParamsTo {
        uint256 executionFee;
        uint256 flags;
        bytes fallbackAddress;
        bytes data;
    }

    /// @param executionFee Fee paid to the transaction executor.
    /// @param fallbackAddress Receiver of the tokens if the call fails.
    struct SubmissionAutoParamsFrom {
        uint256 executionFee;
        uint256 flags;
        address fallbackAddress;
        bytes data;
        bytes nativeSender;
    }

    struct FeeParams {
        uint256 receivedAmount;
        uint256 fixFee;
        uint256 transferFee;
        bool useAssetFee;
        bool isNativeToken;
    }

    /* ========== PUBLIC VARS GETTERS ========== */

    /// @dev Returns whether the transfer with the submissionId was claimed.
    /// submissionId is generated in getSubmissionIdFrom
    function isSubmissionUsed(bytes32 submissionId) view external returns (bool);

    /// @dev Returns native token info by wrapped token address
    function getNativeInfo(address token) view external returns (
        uint256 nativeChainId,
        bytes memory nativeAddress);

    /// @dev Returns address of the proxy to execute user's calls.
    function callProxy() external view returns (address);

    /// @dev Fallback fixed fee in native asset, used if a chain fixed fee is set to 0
    function globalFixedNativeFee() external view returns (uint256);

    /// @dev Fallback transfer fee in BPS, used if a chain transfer fee is set to 0
    function globalTransferFeeBps() external view returns (uint16);

    /* ========== FUNCTIONS ========== */

    /// @dev Submits the message to the deBridge infrastructure to be broadcasted to another supported blockchain (identified by _dstChainId)
    ///      with the instructions to call the _targetContractAddress contract using the given _targetContractCalldata
    /// @notice NO ASSETS ARE BROADCASTED ALONG WITH THIS MESSAGE
    /// @notice DeBridgeGate only accepts submissions with msg.value (native ether) covering a small protocol fee
    ///         (defined in the globalFixedNativeFee property). Any excess amount of ether passed to this function is
    ///         included in the message as the execution fee - the amount deBridgeGate would give as an incentive to
    ///         a third party in return for successful claim transaction execution on the destination chain.
    /// @notice DeBridgeGate accepts a set of flags that control the behaviour of the execution. This simple method
    ///         sets the default set of flags: REVERT_IF_EXTERNAL_FAIL, PROXY_WITH_SENDER
    /// @param _dstChainId ID of the destination chain.
    /// @param _targetContractAddress A contract address to be called on the destination chain
    /// @param _targetContractCalldata Calldata to execute against the target contract on the destination chain
    function sendMessage(
        uint256 _dstChainId,
        bytes memory _targetContractAddress,
        bytes memory _targetContractCalldata
    ) external payable returns (bytes32 submissionId);

    /// @dev Submits the message to the deBridge infrastructure to be broadcasted to another supported blockchain (identified by _dstChainId)
    ///      with the instructions to call the _targetContractAddress contract using the given _targetContractCalldata
    /// @notice NO ASSETS ARE BROADCASTED ALONG WITH THIS MESSAGE
    /// @notice DeBridgeGate only accepts submissions with msg.value (native ether) covering a small protocol fee
    ///         (defined in the globalFixedNativeFee property). Any excess amount of ether passed to this function is
    ///         included in the message as the execution fee - the amount deBridgeGate would give as an incentive to
    ///         a third party in return for successful claim transaction execution on the destination chain.
    /// @notice DeBridgeGate accepts a set of flags that control the behaviour of the execution. This simple method
    ///         sets the default set of flags: REVERT_IF_EXTERNAL_FAIL, PROXY_WITH_SENDER
    /// @param _dstChainId ID of the destination chain.
    /// @param _targetContractAddress A contract address to be called on the destination chain
    /// @param _targetContractCalldata Calldata to execute against the target contract on the destination chain
    /// @param _flags A bitmask of toggles listed in the Flags library
    /// @param _referralCode Referral code to identify this submission
    function sendMessage(
        uint256 _dstChainId,
        bytes memory _targetContractAddress,
        bytes memory _targetContractCalldata,
        uint256 _flags,
        uint32 _referralCode
    ) external payable returns (bytes32 submissionId);

    /// @dev This method is used for the transfer of assets [from the native chain](https://docs.debridge.finance/the-core-protocol/transfers#transfer-from-native-chain).
    /// It locks an asset in the smart contract in the native chain and enables minting of deAsset on the secondary chain.
    /// @param _tokenAddress Asset identifier.
    /// @param _amount Amount to be transferred (note: the fee can be applied).
    /// @param _chainIdTo Chain id of the target chain.
    /// @param _receiver Receiver address.
    /// @param _permitEnvelope Permit for approving the spender by signature. bytes (amount + deadline + signature)
    /// @param _useAssetFee use assets fee for pay protocol fix (work only for specials token)
    /// @param _referralCode Referral code
    /// @param _autoParams Auto params for external call in target network
    function send(
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bytes memory _receiver,
        bytes memory _permitEnvelope,
        bool _useAssetFee,
        uint32 _referralCode,
        bytes calldata _autoParams
    ) external payable returns (bytes32 submissionId) ;

    /// @dev Is used for transfers [into the native chain](https://docs.debridge.finance/the-core-protocol/transfers#transfer-from-secondary-chain-to-native-chain)
    /// to unlock the designated amount of asset from collateral and transfer it to the receiver.
    /// @param _debridgeId Asset identifier.
    /// @param _amount Amount of the transferred asset (note: the fee can be applied).
    /// @param _chainIdFrom Chain where submission was sent
    /// @param _receiver Receiver address.
    /// @param _nonce Submission id.
    /// @param _signatures Validators signatures to confirm
    /// @param _autoParams Auto params for external call
    function claim(
        bytes32 _debridgeId,
        uint256 _amount,
        uint256 _chainIdFrom,
        address _receiver,
        uint256 _nonce,
        bytes calldata _signatures,
        bytes calldata _autoParams
    ) external;

    /// @dev Withdraw collected fees to feeProxy
    /// @param _debridgeId Asset identifier.
    function withdrawFee(bytes32 _debridgeId) external;

    /// @dev Returns asset fixed fee value for specified debridge and chainId.
    /// @param _debridgeId Asset identifier.
    /// @param _chainId Chain id.
    function getDebridgeChainAssetFixedFee(
        bytes32 _debridgeId,
        uint256 _chainId
    ) external view returns (uint256);

    /* ========== EVENTS ========== */

    /// @dev Emitted once the tokens are sent from the original(native) chain to the other chain; the transfer tokens
    /// are expected to be claimed by the users.
    event Sent(
        bytes32 submissionId,
        bytes32 indexed debridgeId,
        uint256 amount,
        bytes receiver,
        uint256 nonce,
        uint256 indexed chainIdTo,
        uint32 referralCode,
        FeeParams feeParams,
        bytes autoParams,
        address nativeSender
        // bool isNativeToken //added to feeParams
    );

    /// @dev Emitted once the tokens are transferred and withdrawn on a target chain
    event Claimed(
        bytes32 submissionId,
        bytes32 indexed debridgeId,
        uint256 amount,
        address indexed receiver,
        uint256 nonce,
        uint256 indexed chainIdFrom,
        bytes autoParams,
        bool isNativeToken
    );

    /// @dev Emitted when new asset support is added.
    event PairAdded(
        bytes32 debridgeId,
        address tokenAddress,
        bytes nativeAddress,
        uint256 indexed nativeChainId,
        uint256 maxAmount,
        uint16 minReservesBps
    );

    event MonitoringSendEvent(
        bytes32 submissionId,
        uint256 nonce,
        uint256 lockedOrMintedAmount,
        uint256 totalSupply
    );

    event MonitoringClaimEvent(
        bytes32 submissionId,
        uint256 lockedOrMintedAmount,
        uint256 totalSupply
    );

    /// @dev Emitted when the asset is allowed/disallowed to be transferred to the chain.
    event ChainSupportUpdated(uint256 chainId, bool isSupported, bool isChainFrom);
    /// @dev Emitted when the supported chains are updated.
    event ChainsSupportUpdated(
        uint256 chainIds,
        ChainSupportInfo chainSupportInfo,
        bool isChainFrom);

    /// @dev Emitted when the new call proxy is set.
    event CallProxyUpdated(address callProxy);
    /// @dev Emitted when the transfer request is executed.
    event AutoRequestExecuted(
        bytes32 submissionId,
        bool indexed success,
        address callProxy
    );

    /// @dev Emitted when a submission is blocked.
    event Blocked(bytes32 submissionId);
    /// @dev Emitted when a submission is unblocked.
    event Unblocked(bytes32 submissionId);

    /// @dev Emitted when fee is withdrawn.
    event WithdrawnFee(bytes32 debridgeId, uint256 fee);

    /// @dev Emitted when globalFixedNativeFee and globalTransferFeeBps are updated.
    event FixedNativeFeeUpdated(
        uint256 globalFixedNativeFee,
        uint256 globalTransferFeeBps);

    /// @dev Emitted when globalFixedNativeFee is updated by feeContractUpdater
    event FixedNativeFeeAutoUpdated(uint256 globalFixedNativeFee);
}

// File: contracts/interfaces/IERC20Permit.sol

pragma solidity ^0.8.7;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
}

// File: contracts/libraries/BytesLib.sol

/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity >=0.8.0 <0.9.0;


library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toAddress(bytes memory _bytes) internal pure returns (address) {
        require(_bytes.length == 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), 0)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}

// File: contracts/libraries/DlnOrderLib.sol

pragma solidity ^0.8.7;

library DlnOrderLib {
    /* ========== CONSTANTS ========== */

    uint256 public constant MAX_ADDRESS_LENGTH = 255;
    uint256 public constant EVM_ADDRESS_LENGTH = 20;
    uint256 public constant SOLANA_ADDRESS_LENGTH = 32;

    /* ========== ERRORS ========== */

    error WrongExternalCallHash();
    error WrongAddressLength();

    /* ========== ENUMS ========== */

    /**
     * @dev Enum defining the supported blockchain engines.
     * - `UNDEFINED`: Represents an undefined or unknown blockchain engine (0).
     * - `EVM`: Represents the Ethereum Virtual Machine (EVM) blockchain engine (1).
     * - `SOLANA`: Represents the Solana blockchain engine (2).
     */
    enum ChainEngine {
        UNDEFINED, // 0
        EVM, // 1
        SOLANA // 2
    }

    /* ========== STRUCTS ========== */

    /// @dev Struct representing the creation parameters for creating an order on the (EVM) chain.
    struct OrderCreation {
        /// Address of the ERC-20 token that the maker is offering as part of this order.
        /// Use the zero address to indicate that the maker is offering a native blockchain token (such as Ether, Matic, etc.).
        address giveTokenAddress;
        /// Amount of tokens the maker is offering.
        uint256 giveAmount;
        /// Address of the ERC-20 token that the maker is willing to accept on the destination chain.
        bytes takeTokenAddress;
        /// Amount of tokens the maker is willing to accept on the destination chain.
        uint256 takeAmount;
        // the ID of the chain where an order should be fulfilled.
        uint256 takeChainId;
        /// Address on the destination chain where funds should be sent upon order fulfillment.
        bytes receiverDst;
        /// Deprecated field. It is always ignored.
        address givePatchAuthoritySrc;
        /// Address on the destination chain authorized to patch the order by reducing the take amount, making it more attractive to takers,
        /// and can also cancel the order in the take chain.
        bytes orderAuthorityAddressDst;
        // An optional address restricting anyone in the open market from fulfilling
        // this order but the given address. This can be useful if you are creating a order
        // for a specific taker. By default, set to empty bytes array (0x)
        bytes allowedTakerDst;
        /// An optional external call data payload.
        bytes externalCall;
        // An optional address on the source (current) chain where the given input tokens
        // would be transferred to in case order cancellation is initiated by the orderAuthorityAddressDst
        // on the destination chain. This property can be safely set to an empty bytes array (0x):
        // in this case, tokens would be transferred to the arbitrary address specified
        // by the orderAuthorityAddressDst upon order cancellation
        bytes allowedCancelBeneficiarySrc;
    }

    /// @dev  Struct representing an order.
    struct Order {
        /// Nonce for each maker.
        uint64 makerOrderNonce;
        /// Order maker address in the source chain.
        bytes makerSrc;
        /// Chain ID where the order's was created.
        uint256 giveChainId;
        /// Address of the ERC-20 token that the maker is offering as part of this order.
        /// Use the zero address to indicate that the maker is offering a native blockchain token (such as Ether, Matic, etc.).
        bytes giveTokenAddress;
        /// Amount of tokens the maker is offering.
        uint256 giveAmount;
        // the ID of the chain where an order should be fulfilled.
        uint256 takeChainId;
        /// Address of the ERC-20 token that the maker is willing to accept on the destination chain.
        bytes takeTokenAddress;
        /// Amount of tokens the maker is willing to accept on the destination chain.
        uint256 takeAmount;
        /// Address on the destination chain where funds should be sent upon order fulfillment.
        bytes receiverDst;
        /// Deprecated field. It is always ignored.
        bytes givePatchAuthoritySrc;
        /// Address on the destination chain authorized to patch the order by reducing the take amount, making it more attractive to takers,
        /// and can also cancel the order in the take chain.
        bytes orderAuthorityAddressDst;
        // An optional address restricting anyone in the open market from fulfilling
        // this order but the given address. This can be useful if you are creating a order
        // for a specific taker. By default, set to empty bytes array (0x)
        bytes allowedTakerDst;
        // An optional address on the source (current) chain where the given input tokens
        // would be transferred to in case order cancellation is initiated by the orderAuthorityAddressDst
        // on the destination chain. This property can be safely set to an empty bytes array (0x):
        // in this case, tokens would be transferred to the arbitrary address specified
        // by the orderAuthorityAddressDst upon order cancellation
        bytes allowedCancelBeneficiarySrc;
        /// An optional external call data payload.
        bytes externalCall;
    }

    /* ========== Methods ========== */

    function getOrderId(Order memory _order) internal pure returns (bytes32) {
        return keccak256(encodeOrder(_order, false));
    }

    function getOrderIdWithExternalCallHash(
        Order memory _order
    ) internal pure returns (bytes32) {
        return keccak256(encodeOrder(_order, true));
    }

    function encodeOrder(
        Order memory _order,
        bool externalCallIsHash
    ) internal pure returns (bytes memory encoded) {
        {
            if (
                _order.makerSrc.length > MAX_ADDRESS_LENGTH ||
                _order.giveTokenAddress.length > MAX_ADDRESS_LENGTH ||
                _order.takeTokenAddress.length > MAX_ADDRESS_LENGTH ||
                _order.receiverDst.length > MAX_ADDRESS_LENGTH ||
                _order.givePatchAuthoritySrc.length > MAX_ADDRESS_LENGTH ||
                _order.orderAuthorityAddressDst.length > MAX_ADDRESS_LENGTH ||
                _order.allowedTakerDst.length > MAX_ADDRESS_LENGTH ||
                _order.allowedCancelBeneficiarySrc.length > MAX_ADDRESS_LENGTH
            ) revert WrongAddressLength();
        }
        // | Bytes | Bits | Field                                                |
        // | ----- | ---- | ---------------------------------------------------- |
        // | 8     | 64   | Nonce                                                |
        // | 1     | 8    | Maker Src Address Size (!=0)                         |
        // | N     | 8*N  | Maker Src Address                                    |
        // | 32    | 256  | Give Chain Id                                        |
        // | 1     | 8    | Give Token Address Size (!=0)                        |
        // | N     | 8*N  | Give Token Address                                   |
        // | 32    | 256  | Give Amount                                          |
        // | 32    | 256  | Take Chain Id                                        |
        // | 1     | 8    | Take Token Address Size (!=0)                        |
        // | N     | 8*N  | Take Token Address                                   |
        // | 32    | 256  | Take Amount                                          |
        // | 1     | 8    | Receiver Dst Address Size (!=0)                      |
        // | N     | 8*N  | Receiver Dst Address                                 |
        // | 1     | 8    | Give Patch Authority Address Size (!=0)              |
        // | N     | 8*N  | Give Patch Authority Address                         |
        // | 1     | 8    | Order Authority Address Dst Size (!=0)               |
        // | N     | 8*N  | Order Authority Address Dst                          |
        // | 1     | 8    | Allowed Taker Dst Address Size                       |
        // | N     | 8*N  | * Allowed Taker Address Dst                          |
        // | 1     | 8    | Allowed Cancel Beneficiary Src Address Size          |
        // | N     | 8*N  | * Allowed Cancel Beneficiary Address Src             |
        // | 1     | 8    | Is External Call Presented 0x0 - Not, != 0x0 - Yes   |
        // | 32    | 256  | * External Call Envelope Hash

        encoded = abi.encodePacked(
            _order.makerOrderNonce,
            (uint8)(_order.makerSrc.length),
            _order.makerSrc
        );
        {
            encoded = abi.encodePacked(
                encoded,
                _order.giveChainId,
                (uint8)(_order.giveTokenAddress.length),
                _order.giveTokenAddress,
                _order.giveAmount,
                _order.takeChainId
            );
        }
        //Avoid stack to deep
        {
            encoded = abi.encodePacked(
                encoded,
                (uint8)(_order.takeTokenAddress.length),
                _order.takeTokenAddress,
                _order.takeAmount,
                (uint8)(_order.receiverDst.length),
                _order.receiverDst
            );
        }
        {
            encoded = abi.encodePacked(
                encoded,
                (uint8)(_order.givePatchAuthoritySrc.length),
                _order.givePatchAuthoritySrc,
                (uint8)(_order.orderAuthorityAddressDst.length),
                _order.orderAuthorityAddressDst
            );
        }
        {
            encoded = abi.encodePacked(
                encoded,
                (uint8)(_order.allowedTakerDst.length),
                _order.allowedTakerDst,
                (uint8)(_order.allowedCancelBeneficiarySrc.length),
                _order.allowedCancelBeneficiarySrc,
                _order.externalCall.length > 0
            );
        }
        if (_order.externalCall.length > 0) {
            if (externalCallIsHash) {
                if (_order.externalCall.length != 32) revert WrongExternalCallHash();
                encoded = abi.encodePacked(encoded, _order.externalCall);
            } else {
                encoded = abi.encodePacked(
                    encoded,
                    keccak256(_order.externalCall)
                );
            }
        }
        return encoded;
    }
}

// File: contracts/libraries/TokenLib.sol

pragma solidity ^0.8.17;




library TokenLib {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    error EthTransferFailed();

    address private constant USDT_ON_TRON = address(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C);

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        if (value > 0) {
            if (token == address(0)) {
                _safeTransferETH(to, value);
            }
            else if (token == USDT_ON_TRON) {
                // The return value of transfer is intentionally ignored here because the Tron USDT implementation
                // is known to deviate from the standard ERC20 pattern and can return 'false' on successful transfers.
                IERC20Upgradeable(token).transfer(to, value);
            } else {
                IERC20Upgradeable(token).safeTransfer(to, value);
            }
        }
    }

    function trySafeTransfer(
        address token,
        address to,
        uint256 value
    ) internal returns (bool success) {
        if (value == 0) return true;

        if (token == address(0)) {
            (success, ) = to.call{value: value}(new bytes(0));
            return success;
        }

        if (token.code.length == 0) {
            // ERC20 token is not contract
            return false;
        }

        bytes memory returnData;
        (success, returnData) = token.call(
            abi.encodeWithSelector(IERC20Upgradeable.transfer.selector, to, value)
        );

        if (!success) return false;

        if (token == USDT_ON_TRON) {
            // The return value of transfer is intentionally ignored here because the Tron USDT implementation
            // is known to deviate from the standard ERC20 pattern and can return 'false' on successful transfers.
            return true;
        }

        if (returnData.length == 0) {
            // Non-standard ERC20: no return value
            return true;
        }

        // Standard ERC20: check return value
        return abi.decode(returnData, (bool));
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) revert EthTransferFailed();
    }
}

// File: contracts/DLN/DlnBase.sol

pragma solidity ^0.8.17;














abstract contract DlnBase is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address payable;
    using SignatureUtil for bytes;

    /* ========== CONSTANTS ========== */

    /// @dev Basis points or bps, set to 10 000 (equal to 1/10000). Used to express relative values (fees)
    uint256 public constant BPS_DENOMINATOR = 10000;

    /// @dev Role allowed to stop transfers
    bytes32 public constant GOVMONITORING_ROLE =
        keccak256("GOVMONITORING_ROLE");

    uint256 public constant MAX_ADDRESS_LENGTH = 255;
    uint256 public constant EVM_ADDRESS_LENGTH = 20;
    uint256 public constant SOLANA_ADDRESS_LENGTH = 32;

    /// @dev DeBridge Gate contract interface
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    IDeBridgeGate public immutable deBridgeGate;

    /// @dev Subscription (generated by the Subscription contract) that is used instead of chain id
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    uint32 public immutable subscriptionId;

    /* ========== STATE VARIABLES ========== */

    // @dev Maps chainId => type of chain engine
    mapping(uint256 => DlnOrderLib.ChainEngine) public chainEngines;

    /// @dev Reserved storage slot (previously deBridgeGate, moved to immutable)
    address private buf1;

    /* ========== ERRORS ========== */

    error AdminBadRole();
    error CallProxyBadRole();
    error GovMonitoringBadRole();
    error NativeSenderBadRole(bytes nativeSender, uint256 chainIdFrom);
    error MismatchedTransferAmount();
    error MismatchedOrderId();
    error ZeroAddress();
    error NotSupportedDstChain();
    error EthTransferFailed();
    error Unauthorized();
    error IncorrectOrderStatus();
    error WrongChain();
    error WrongArgument();
    error UnknownEngine();

    /* ========== EVENTS ========== */

    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    modifier onlyGovMonitoring() {
        if (!hasRole(GOVMONITORING_ROLE, msg.sender))
            revert GovMonitoringBadRole();
        _;
    }

    /* ========== CONSTRUCTOR  ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(IDeBridgeGate _deBridgeGate, uint32 _subscriptionId) {
        deBridgeGate = _deBridgeGate;
        subscriptionId = _subscriptionId;
        _disableInitializers();
    }

    function __DlnBase_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        __DlnBase_init_unchained();
    }

    function __DlnBase_init_unchained()
        internal
        initializer
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /* ========== ADMIN METHODS ========== */

    /// @dev Stop all protocol.
    function pause() external onlyGovMonitoring {
        _pause();
    }

    /// @dev Unlock protocol.
    function unpause() external onlyAdmin {
        _unpause();
    }

    /* ========== INTERNAL ========== */

    /// @dev Safely transfers tokens and returns the actual amount credited to the receiver.
    /// @param _strict If true, requires an exact match (used when tokens are held by the contract).
    ///                If false, accepts any actual received amount to support rebasing/taxable tokens.
    /// @return receivedAmount The actual amount credited to `_to`.
    function _safeTransferFrom(
        address _tokenAddress,
        address _from,
        address _to,
        uint256 _amount,
        bool _strict
    ) internal returns (uint256 receivedAmount) {
         if (_from == _to) return _amount;

        IERC20Upgradeable token = IERC20Upgradeable(_tokenAddress);
        uint256 balanceBefore = token.balanceOf(_to);
        token.safeTransferFrom(_from, _to, _amount);
        receivedAmount = token.balanceOf(_to) - balanceBefore;

        if (_strict && _amount != receivedAmount) {
            revert MismatchedTransferAmount();
        }
    }

    /// @dev Transfer ETH or token
    /// @param tokenAddress address(0) to transfer ETH
    /// @param to  recipient of the transfer
    /// @param value the amount to send
    function _safeTransferEthOrToken(
        address tokenAddress,
        address to,
        uint256 value
    ) internal {
        TokenLib.safeTransfer(tokenAddress, to, value);
    }

    // ============ VIEWS ============

    function getOrderId(DlnOrderLib.Order memory _order) public pure returns (bytes32) {
        return DlnOrderLib.getOrderId(_order);
    }

    /// @dev Get current chain id
    function getChainId() public view virtual returns (uint256 cid) {
        cid = subscriptionId;
        if (cid != 0) return cid;

        assembly {
            cid := chainid()
        }
    }
}

// File: contracts/interfaces/IDlnSource.sol

pragma solidity ^0.8.7;



interface IDlnSource {
    /**
     * @notice This function returns the global fixed fee in the native asset of the protocol.
     * @dev This fee is denominated in the native asset (like Ether in Ethereum).
     * @return uint88 This return value represents the global fixed fee in the native asset.
     */
    function globalFixedNativeFee() external returns (uint88);

    /**
     * @notice This function provides the global transfer fee, expressed in Basis Points (BPS).
     * @dev It retrieves a global fee which is applied to order.giveAmount. The fee is represented in Basis Points (BPS), where 1 BPS equals 0.01%.
     * @return uint16 The return value represents the global transfer fee in BPS.
     */
    function globalTransferFeeBps() external returns (uint16);

    /**
     * @dev Places a new order with pseudo-random orderId onto the DLN
     * @notice deprecated
     * @param _orderCreation a structured parameter from the DlnOrderLib.OrderCreation library, containing all the necessary information required for creating a new order.
     * @param _affiliateFee a bytes parameter specifying the affiliate fee that will be rewarded to the beneficiary. It includes the beneficiary's details and the affiliate amount.
     * @param _referralCode a 32-bit unsigned integer containing the referral code. This code is traced back to the referral source or person that facilitated this order. This code is also emitted in an event for tracking purposes.
     * @param _permitEnvelope a bytes parameter that is used to approve the spender through a signature. It contains the amount, the deadline, and the signature.
     * @return bytes32 identifier (orderId) of a newly placed order
     */
    function createOrder(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        bytes calldata _affiliateFee,
        uint32 _referralCode,
        bytes calldata _permitEnvelope
    ) external payable returns (bytes32);

    /**
     * @dev Places a new order with deterministic orderId onto the DLN
     * @param _orderCreation a structured parameter from the DlnOrderLib.OrderCreation library, containing all the necessary information required for creating a new order.
     * @param _salt an input source of randomness for getting a deterministic identifier of an order (orderId)
     * @param _affiliateFee a bytes parameter specifying the affiliate fee that will be rewarded to the beneficiary. It includes the beneficiary's details and the affiliate amount.
     * @param _referralCode a 32-bit unsigned integer containing the referral code. This code is traced back to the referral source or person that facilitated this order. This code is also emitted in an event for tracking purposes.
     * @param _permitEnvelope a bytes parameter that is used to approve the spender through a signature. It contains the amount, the deadline, and the signature.
     * @param _metadata an arbitrary data to be tied together with the order for future off-chain analysis
     * @return bytes32 identifier (orderId) of a newly placed order
     */
    function createSaltedOrder(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        uint64 _salt,
        bytes calldata _affiliateFee,
        uint32 _referralCode,
        bytes calldata _permitEnvelope,
        bytes calldata _metadata
    ) external payable returns (bytes32);

    /**
     * @dev Places a new order for intent manager with deterministic orderId onto the DLN
     * @notice This function can only be called by the intent manager and has special fee handling:
     *         - No fixed native fee is charged
     *         - Uses custom fee instead of the global fee
     *         - No affiliate fees are supported
     * @param _orderCreation a structured parameter from the DlnOrderLib.OrderCreation library, containing all the necessary information required for creating a new order.
     * @param _salt an input source of randomness for getting a deterministic identifier of an order (orderId)
     * @param _referralCode a 32-bit unsigned integer containing the referral code. This code is traced back to the referral source or person that facilitated this order.
     * @param _giveTokenFeeAmount custom fee to be charged instead of the global fee
     * @param _metadata an arbitrary data to be tied together with the order for future off-chain analysis
     * @return bytes32 identifier (orderId) of a newly placed order
     */
    function createSaltedOrderForIntent(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        uint64 _salt,
        uint32 _referralCode,
        uint256 _giveTokenFeeAmount,
        bytes calldata _metadata
    ) external payable returns (bytes32);

    /**
     * @dev Places a new order for intent manager with deterministic orderId and an explicitly specified maker.
     * @notice This function can only be called by the intent manager and has special fee handling:
     *         - No fixed native fee is charged
     *         - Uses custom fee instead of the global fee
     *         - No affiliate fees are supported
     * @param _orderCreation a structured parameter from the DlnOrderLib.OrderCreation library, containing all the necessary information required for creating a new order.
     * @param _maker address to use as the order maker
     * @param _salt an input source of randomness for getting a deterministic identifier of an order (orderId)
     * @param _referralCode a 32-bit unsigned integer containing the referral code. This code is traced back to the referral source or person that facilitated this order.
     * @param _giveTokenFeeAmount custom fee to be charged instead of the global fee
     * @param _metadata an arbitrary data to be tied together with the order for future off-chain analysis
     * @return bytes32 identifier (orderId) of a newly placed order
     */
    function createSaltedOrderForIntent(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        address _maker,
        uint64 _salt,
        uint32 _referralCode,
        uint256 _giveTokenFeeAmount,
        bytes calldata _metadata
    ) external payable returns (bytes32);
}

// File: contracts/interfaces/IIntentManagerValidator.sol

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

// File: contracts/DLN/DlnSource.sol

pragma solidity ^0.8.17;









contract DlnSource is DlnBase, ReentrancyGuardUpgradeable, IDlnSource {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeCast for uint256;
    using BytesLib for bytes;
    using Permit for address;

    /* ========== CONSTANTS ========== */

    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address public immutable intentManager;

    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    IIntentManagerValidator public immutable intentManagerRights;

    /* ========== STATE VARIABLES ========== */

    /// @dev Role for fee withdrawal.
    bytes32 public constant FEE_COLLECTOR_ROLE = keccak256("FEE_COLLECTOR_ROLE");

    /// @dev A fixed fee specified in the native asset.
    uint88 public globalFixedNativeFee;

    /// @dev Transfer fee expressed in Basis Points (BPS).
    uint16 public globalTransferFeeBps;

    /// @dev Maps each chainId to the address of the `dlnDestination` contract on the respective chain.
    mapping(uint256 => bytes) public dlnDestinationAddresses;

    /// @dev Maps each order ID (derived using `getOrderId`) to its state and collected processing fee.
    /// This fee will be returned if an order is canceled.
    mapping(bytes32 => GiveOrderState) public giveOrders;

    /// @dev Tracks the additional amounts for an order's give part during the unlock or cancel operations.
    /// Writing to this mapping is now deprecated but it is kept for backward compatibility as public getter.
    mapping(bytes32 => uint256) public givePatches;

    /// @dev Allocates a unique nonce for each order maker to ensure order uniqueness.
    mapping(address => uint256) public masterNonce;

    /// @dev Keeps track of the protocol fees collected from orders.
    mapping(address => uint256) public collectedFee;

    /// @dev Keeps track of orders with unexpected statuses during unlock claims.
    /// Maps an order ID to the claim beneficiary address.
    mapping(bytes32 => address) public unexpectedOrderStatusForClaim;

    /// @dev Keeps track of orders with unexpected statuses during cancel claims.
    /// Maps an order ID to the cancel beneficiary address.
    mapping(bytes32 => address) public unexpectedOrderStatusForCancel;

    /// @dev Records the amount of ETH owed to affiliate beneficiaries (used in cases where sending ETH failed).
    /// Maps an affiliate beneficiary's address to the owed ETH amount.
    mapping(address => uint256) public unclaimedAffiliateETHFees;

    // // maps the amount of ERC-20 per affiliate beneficiary (in case we failed to send ETH to him)
    // // for ETH, refer to the unclaimedAffiliateETHFees mapping
    // // token => affiliateBeneficiary => amount
    mapping(address => mapping(address => uint256)) public unclaimedERC20AffiliateFees;

    /// @dev Reserved storage slot (previously subscriptionId, moved to base contract)
    uint32 private buf0;

    /* ========== ENUMS ========== */

    /**
     * @dev Enum defining the status of an order in give chain.
     * - `NotSet`: Indicates that the order does not exist (0).
     * - `Created`: Indicates that the order has been created (1).
     * - `ClaimedUnlock`: Indicates that the order has been fully unlocked (2).
     * - `ClaimedCancel`: Indicates that the order has been canceled (3).
     */
    enum OrderGiveStatus {
        NotSet, // 0
        Created, // 1
        ClaimedUnlock, // 2
        ClaimedCancel // 3
    }

    /* ========== STRUCTS ========== */

    /**
     * @dev Struct representing the state of order in "give" chain.
     *
     * - `status`: Indicates the status of the "give" part of the order, including whether it's created, claimed, or canceled.
     * - `giveTokenAddress`: The address of the ERC-20 token (or native blockchain token) involved in the "give" part of the order.
     * - `nativeFixFee`: A fixed fee that was paid by the maker when creating the order.
     * - `takeChainId`: The chain ID where the "take" part of the order is intended to be fulfilled.
     * - `percentFee`: A fee represented as a percentage of the total amount involved in the "give" part of the order.
     * - `giveAmount`: The amount of tokens involved in the "give" part of the order.
     * - `affiliateBeneficiary`: The address designated to receive affiliate rewards, if applicable.
     * - `affiliateAmount`: The amount of tokens allocated for affiliate rewards.
     */
    struct GiveOrderState {
        OrderGiveStatus status;
        uint160 giveTokenAddress; // stot optimisation used uint160 instead address
        uint88 nativeFixFee;
        uint48 takeChainId;
        uint208 percentFee;
        uint256 giveAmount;
        address affiliateBeneficiary;
        uint256 affiliateAmount;
    }

    /* ========== EVENTS ========== */

    event CreatedOrder(
        DlnOrderLib.Order order,
        bytes32 orderId,
        bytes affiliateFee,
        uint256 nativeFixFee,
        uint256 percentFee,
        uint32 referralCode,
        bytes metadata
    );

    event AffiliateFeePaid(
        bytes32 _orderId,
        address beneficiary,
        uint256 affiliateFee,
        address giveTokenAddress
    );

    event ClaimedUnlock(
        bytes32 orderId,
        address beneficiary,
        uint256 giveAmount,
        address giveTokenAddress
    );

    event UnexpectedOrderStatusForClaim(bytes32 orderId, OrderGiveStatus status, address beneficiary);

    event CriticalMismatchChainId(bytes32 orderId, address beneficiary, uint256 takeChainId,  uint256 submissionChainIdFrom);

    event UnclaimedAffiliateFees(bytes32 orderId, address token, uint256 amount);
    event UnclaimedAffiliateFeePaid(address beneficiary, uint256 amount, address token);

    event ClaimedOrderCancel(
        bytes32 orderId,
        address beneficiary,
        uint256 paidAmount,
        address giveTokenAddress
    );

    event UnexpectedOrderStatusForCancel(bytes32 orderId, OrderGiveStatus status, address beneficiary);

    event SetDlnDestinationAddress(uint256 chainIdTo, bytes dlnDestinationAddress, DlnOrderLib.ChainEngine chainEngine);

    event WithdrawnFee(address tokenAddress, uint256 amount, address beneficiary);

    event GlobalFixedNativeFeeUpdated(uint88 oldGlobalFixedNativeFee, uint88 newGlobalFixedNativeFee);
    event GlobalTransferFeeBpsUpdated(uint16 oldGlobalTransferFeeBps, uint16 newGlobalTransferFeeBps);


    /* ========== ERRORS ========== */

    error FeeCollectorBadRole();
    error IntentManagerBadRole();
    error WrongFixedFee(uint256 received, uint256 actual);
    error WrongAffiliateFeeLength();
    error MismatchNativeGiveAmount();
    error CriticalMismatchTakeChainId(bytes32 orderId, uint48 takeChainId, uint256 submissionsChainIdFrom);

    /* ========== MODIFIERS ========== */

    modifier onlyFeeCollector() {
        if (!hasRole(FEE_COLLECTOR_ROLE, msg.sender))
            revert FeeCollectorBadRole();
        _;
    }

    modifier onlyIntentManager() {
        if (msg.sender != intentManager) {
            // If msg.sender is not the direct intentManager, check external validation
            if (address(intentManagerRights) == address(0) || !intentManagerRights.validateIntentManager(msg.sender)) {
                revert IntentManagerBadRole();
            }
        }
        _;
    }

    /* ========== CONSTRUCTOR  ========== */

    constructor(address _intentManager, IIntentManagerValidator _intentManagerRights, IDeBridgeGate _deBridgeGate, uint32 _subscriptionId) DlnBase(_deBridgeGate, _subscriptionId) {
        intentManager = _intentManager;
        intentManagerRights = _intentManagerRights;
    }

    function initialize(
        uint88 _globalFixedNativeFee,
        uint16 _globalTransferFeeBps
    ) public initializer {
        _setFixedNativeFee(_globalFixedNativeFee);
        _setTransferFeeBps(_globalTransferFeeBps);

        __DlnBase_init();
        __ReentrancyGuard_init();
    }

    /* ========== PUBLIC METHODS ========== */

    /**
     * @inheritdoc IDlnSource
     */
    function createOrder(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        bytes calldata _affiliateFee,
        uint32 _referralCode,
        bytes memory _permitEnvelope
    ) external payable nonReentrant whenNotPaused returns (bytes32) {
        return _createSaltedOrderWithGlobalFee(
            _orderCreation,
            uint64(masterNonce[tx.origin]++),
            _affiliateFee,
            _referralCode,
            _permitEnvelope,
            bytes("")
        );
    }

    /**
     * @inheritdoc IDlnSource
     */
    function createSaltedOrder(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        uint64 _salt,
        bytes calldata _affiliateFee,
        uint32 _referralCode,
        bytes memory _permitEnvelope,
        bytes memory _metadata
    ) external payable nonReentrant whenNotPaused returns (bytes32) {
        return _createSaltedOrderWithGlobalFee(
            _orderCreation,
            _salt,
            _affiliateFee,
            _referralCode,
            _permitEnvelope,
            _metadata
        );
    }

    /**
     * @inheritdoc IDlnSource
     */
    function createSaltedOrderForIntent(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        uint64 _salt,
        uint32 _referralCode,
        uint256 _giveTokenFeeAmount,
        bytes memory _metadata
    ) external payable nonReentrant whenNotPaused onlyIntentManager returns (bytes32) {
        return _createSaltedOrderForIntent(
            _orderCreation,
            msg.sender,
            _salt,
            _referralCode,
            _giveTokenFeeAmount,
            _metadata
        );
    }

    /**
     * @inheritdoc IDlnSource
     */
    function createSaltedOrderForIntent(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        address _maker,
        uint64 _salt,
        uint32 _referralCode,
        uint256 _giveTokenFeeAmount,
        bytes memory _metadata
    ) external payable nonReentrant whenNotPaused onlyIntentManager returns (bytes32) {
        if (_maker == address(0)) revert ZeroAddress();

        return _createSaltedOrderForIntent(
            _orderCreation,
            _maker,
            _salt,
            _referralCode,
            _giveTokenFeeAmount,
            _metadata
        );
    }

    function _createSaltedOrderForIntent(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        address _maker,
        uint64 _salt,
        uint32 _referralCode,
        uint256 _giveTokenFeeAmount,
        bytes memory _metadata
    ) internal returns (bytes32) {
        // We trust that the intent manager will provide the correct _giveTokenFeeAmount, so we do not check whether it
        // exceeds the _orderCreation.giveAmount.

        return _createSaltedOrder(
            _orderCreation,
            _maker,
            _salt,
            bytes(""),
            _referralCode,
            bytes(""),
            _metadata,
            0,
            _giveTokenFeeAmount
        );
    }

    /**
     * @dev This function helps avoid "stack too deep" errors.
     */
    function _createSaltedOrderWithGlobalFee(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        uint64 _salt,
        bytes memory _affiliateFee,
        uint32 _referralCode,
        bytes memory _permitEnvelope,
        bytes memory _metadata
    ) internal returns (bytes32) {
        uint256 percentFee = (globalTransferFeeBps * _orderCreation.giveAmount) / BPS_DENOMINATOR;
        return _createSaltedOrder(
            _orderCreation,
            tx.origin,
            _salt,
            _affiliateFee,
            _referralCode,
            _permitEnvelope,
            _metadata,
            globalFixedNativeFee,
            percentFee
        );
    }

    function _createSaltedOrder(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        address _maker,
        uint64 _salt,
        bytes memory _affiliateFee,
        uint32 _referralCode,
        bytes memory _permitEnvelope,
        bytes memory _metadata,
        uint88 _fixedNativeFee,
        uint256 _percentFee
    ) internal returns (bytes32) {

        uint256 affiliateAmount;
        if (_affiliateFee.length > 0) {
            if (_affiliateFee.length != 52) revert WrongAffiliateFeeLength();
            affiliateAmount = BytesLib.toUint256(_affiliateFee, 20);
        }

        DlnOrderLib.Order memory _order = validateCreationOrder(_orderCreation, _maker, _salt);

        // take tokens from the user's wallet
        _pullTokens(_orderCreation, _order, _fixedNativeFee, _permitEnvelope);

        // reduce giveAmount on (percentFee + affiliateFee)
        _order.giveAmount -= _percentFee + affiliateAmount;

        bytes32 orderId = DlnOrderLib.getOrderId(_order);
        {
            GiveOrderState storage orderState = giveOrders[orderId];
            if (orderState.status != OrderGiveStatus.NotSet) revert IncorrectOrderStatus();

            orderState.status = OrderGiveStatus.Created;
            orderState.giveTokenAddress =  uint160(_orderCreation.giveTokenAddress);
            orderState.nativeFixFee = _fixedNativeFee;
            orderState.takeChainId = _order.takeChainId.toUint48();
            orderState.percentFee = _percentFee.toUint208();
            orderState.giveAmount = _order.giveAmount;
            // save affiliate_fee to storage
            if (affiliateAmount > 0) {
                address affiliateBeneficiary = BytesLib.toAddress(_affiliateFee, 0);
                if (affiliateAmount > 0 && affiliateBeneficiary == address(0)) revert ZeroAddress();
                orderState.affiliateAmount = affiliateAmount;
                orderState.affiliateBeneficiary = affiliateBeneficiary;
            }
        }

        emit CreatedOrder(
            _order,
            orderId,
            _affiliateFee,
            _fixedNativeFee,
            _percentFee,
            _referralCode,
            _metadata
        );

        return orderId;
    }

    /**
     * @dev Processes a batch of unlock orders originating from the order's take chain.
     * @param _orderIds An array containing the IDs of the orders to be unlocked.
     * @param _beneficiary The address that will receive the assets from the unlocked orders.
     * # Restrictions
     * This function can only be called through the debridge's external call mechanism,
     * ensuring it's invoked by a validated native sender.
     */
    function claimBatchUnlock(bytes32[] memory _orderIds, address _beneficiary)
        external
        nonReentrant
        whenNotPaused
    {
        uint256 submissionChainIdFrom = _onlyDlnDestinationAddress();
        //  store the give token of the order in the batch. If next order has different give token we will pay to beneficiary
        // and change distinctGiveToken to new one.
        address distinctGiveToken;
        uint256 distinctGiveTokenAmount;
        uint256 length = _orderIds.length;
        for (uint256 i; i < length; ++i) {
            bytes32 orderId = _orderIds[i];
            GiveOrderState storage orderState = giveOrders[orderId];

            // the give address of the first order is distinct
            if (i == 0) {
                distinctGiveToken = address(orderState.giveTokenAddress);
            }

            uint256 amountToPay = _claimUnlock(orderId, _beneficiary, submissionChainIdFrom, false);
            if (amountToPay != 0) {
                // transfer tokens for beneficiary if token address changed
                if (distinctGiveToken != address(orderState.giveTokenAddress)) {
                    _safeTransferEthOrToken(distinctGiveToken, _beneficiary, distinctGiveTokenAmount);
                    distinctGiveToken = address(orderState.giveTokenAddress);
                    distinctGiveTokenAmount = amountToPay;
                } else {
                    distinctGiveTokenAmount += amountToPay;
                }
            }
        }
        if (distinctGiveTokenAmount != 0) {
            _safeTransferEthOrToken(distinctGiveToken, _beneficiary, distinctGiveTokenAmount);
        }
    }

    /**
     * @dev Processes a single unlock order that originates from the order's take chain.
     * @param _orderId The ID of the order to be unlocked.
     * @param _beneficiary The address that will receive the assets from the unlocked order.
     * # Restrictions
     * This function can only be invoked through the debridge's external call mechanism,
     * ensuring it's called by a validated native sender.
     */
    function claimUnlock(bytes32 _orderId, address _beneficiary)
        external
        nonReentrant
        whenNotPaused
    {
        uint256 submissionChainIdFrom = _onlyDlnDestinationAddress();
        _claimUnlock(_orderId, _beneficiary, submissionChainIdFrom, true/*allowActualTransfer*/);
    }



    /**
     * @dev Processes a batch of cancel orders originating from the order's take chain.
     *
     * This function handles multiple order cancellations at once. It processes each order in the batch to
     * ensure that the designated beneficiaries receive their refunds.
     *
     * @param _orderIds Array of IDs of the orders to be canceled.
     * @param _beneficiary The address that will receive the refunds from the canceled orders.
     *
     * # Restrictions
     * This function can only be invoked through the debridge's external call mechanism,
     * ensuring it's called by a validated native sender.
     */
    function claimBatchCancel(bytes32[] memory _orderIds, address _beneficiary)
        external
        nonReentrant
        whenNotPaused
    {
        uint256 submissionChainIdFrom = _onlyDlnDestinationAddress();
        uint256 length = _orderIds.length;
        for (uint256 i; i < length; ++i) {
            _claimCancel(_orderIds[i], _beneficiary,submissionChainIdFrom);
        }
    }

    /**
     * @dev Processes the cancellation of an order originating from the order's take chain.
     *
     * This function manages the cancellation of a specific order, ensuring that the designated
     * beneficiary receives the full refund for the canceled order.
     *
     * @param _orderId ID of the order to be canceled.
     * @param _beneficiary The address that will receive the refund from the canceled order.
     *
     * # Restrictions
     * This function can only be invoked through the debridge's external call mechanism,
     * ensuring it's called by a validated native sender.
     */
    function claimCancel(bytes32 _orderId, address _beneficiary)
        external
        nonReentrant
        whenNotPaused
    {
        uint256 submissionChainIdFrom = _onlyDlnDestinationAddress();
        _claimCancel(_orderId, _beneficiary, submissionChainIdFrom);
    }

    /**
     * @dev Withdraws unclaimed affiliate fees for a list of tokens to a specified beneficiary.
     * This function allows a user (msg.sender) to retrieve accumulated affiliate rewards.
     * It processes both Ethereum and ERC20 token rewards.
     * @param _tokens An array of token addresses for which the affiliate fees are to be withdrawn.
     *        Pass the zero address for ETH.
     * @param _beneficiary The address to which the unclaimed fees will be transferred.
     * This function iterates through each token, checks and resets the accumulated fee,
     * and safely transfers the fee to the beneficiary.
     * Emits an UnclaimedAffiliateFeePaid event upon successful transfer of each token's fees.
     */
    function withdrawUnclaimedAffiliateFees(
        address[] memory _tokens,
        address _beneficiary
    ) external nonReentrant whenNotPaused {
        uint256 length = _tokens.length;
        for (uint256 i; i < length; ++i) {
            address token = _tokens[i];
            uint256 amount;
            if (token == address(0)) {
                amount = unclaimedAffiliateETHFees[msg.sender];
                unclaimedAffiliateETHFees[msg.sender] = 0;
            } else {
                amount = unclaimedERC20AffiliateFees[token][msg.sender];
                unclaimedERC20AffiliateFees[token][msg.sender] = 0;
            }
            if (amount > 0) {
                _safeTransferEthOrToken(token, _beneficiary, amount);
                emit UnclaimedAffiliateFeePaid(_beneficiary, amount, token);
            }
        }
    }

    /* ========== ADMIN METHODS ========== */

    /**
     * @dev Sets the DLN destination contract address for another chain.
     * @param _chainIdTo The destination chain ID.
     * @param _dlnDestinationAddress The address of the contract on the destination chain.
     * @param _chainEngine The engine type of the destination chain.
     */
    function setDlnDestinationAddress(
        uint256 _chainIdTo,
        bytes memory _dlnDestinationAddress,
        DlnOrderLib.ChainEngine _chainEngine
    ) external onlyAdmin {
        if(_chainEngine == DlnOrderLib.ChainEngine.UNDEFINED) revert WrongArgument();
        dlnDestinationAddresses[_chainIdTo] = _dlnDestinationAddress;
        chainEngines[_chainIdTo] = _chainEngine;
        emit SetDlnDestinationAddress(_chainIdTo, _dlnDestinationAddress, _chainEngine);
    }

    /**
     * @dev Withdraws the collected fees.
     * @param _tokens An array of token addresses for withdrawal.
     */
    function withdrawCollectedFees(
        address[] calldata _tokens
    ) external nonReentrant onlyFeeCollector whenNotPaused {
        uint256 length = _tokens.length;
        for (uint256 i; i < length; ++i) {
            address token = _tokens[i];
            uint256 feeAmount = collectedFee[token];
            _safeTransferEthOrToken(token, msg.sender, feeAmount);
            collectedFee[token] = 0;
            emit WithdrawnFee(token, feeAmount, msg.sender);
        }
    }

    /**
     * @dev Updates the settings for fixed fee in native asset and transfer fee.
     * @param _globalFixedNativeFee The fixed fee in the native asset.
     * @param _globalTransferFeeBps The transfer fee in basis points.
     */
    function updateGlobalFee(
        uint88 _globalFixedNativeFee,
        uint16 _globalTransferFeeBps
    ) external onlyAdmin {
        _setFixedNativeFee(_globalFixedNativeFee);
        _setTransferFeeBps(_globalTransferFeeBps);
    }

    /* ========== VIEW ========== */

    /**
     * @dev Validates the creation of an order. Throws an exception if incorrect parameters are passed.
     * @param _orderCreation Details of the order to be validated.
     * @param _signer Address that will be used as the order maker.
     * @return order Returns the validated order details.
     */
    function validateCreationOrder(DlnOrderLib.OrderCreation memory _orderCreation, address _signer)
        public
        view
        returns (DlnOrderLib.Order memory order)
    {
        return validateCreationOrder(_orderCreation, _signer, uint64(masterNonce[_signer]));
    }

    function validateCreationOrder(DlnOrderLib.OrderCreation memory _orderCreation, address _signer, uint64 _salt)
        public
        view
        returns (DlnOrderLib.Order memory order)
    {
        uint256 dstAddressLength = dlnDestinationAddresses[_orderCreation.takeChainId].length;

        if (dstAddressLength == 0) revert NotSupportedDstChain();
        if (
            _orderCreation.takeTokenAddress.length != dstAddressLength ||
            _orderCreation.receiverDst.length != dstAddressLength ||
            _orderCreation.orderAuthorityAddressDst.length != dstAddressLength ||
            (_orderCreation.allowedTakerDst.length > 0 &&
                _orderCreation.allowedTakerDst.length != dstAddressLength) ||
            (_orderCreation.allowedCancelBeneficiarySrc.length > 0 &&
                _orderCreation.allowedCancelBeneficiarySrc.length != EVM_ADDRESS_LENGTH)
        ) revert DlnOrderLib.WrongAddressLength();

        order.giveChainId = getChainId();
        order.makerOrderNonce = _salt;
        order.makerSrc = abi.encodePacked(_signer);
        order.giveTokenAddress = abi.encodePacked(_orderCreation.giveTokenAddress);
        order.giveAmount = _orderCreation.giveAmount;
        order.takeTokenAddress = _orderCreation.takeTokenAddress;
        order.takeAmount = _orderCreation.takeAmount;
        order.takeChainId = _orderCreation.takeChainId;
        order.receiverDst = _orderCreation.receiverDst;
        order.givePatchAuthoritySrc = abi.encodePacked(_orderCreation.givePatchAuthoritySrc);
        order.orderAuthorityAddressDst = _orderCreation.orderAuthorityAddressDst;
        order.allowedTakerDst = _orderCreation.allowedTakerDst;
        order.externalCall = _orderCreation.externalCall;
        order.allowedCancelBeneficiarySrc = _orderCreation.allowedCancelBeneficiarySrc;
    }


    /* ========== INTERNAL ========== */

    function _pullTokens(DlnOrderLib.OrderCreation calldata _orderCreation, DlnOrderLib.Order memory _order, uint _fixedNativeFee, bytes memory _permitEnvelope) internal {
        if (_orderCreation.giveTokenAddress == address(0)) {
            if (msg.value != _order.giveAmount + _fixedNativeFee) revert MismatchNativeGiveAmount();
        }
        else
        {
            if (msg.value != _fixedNativeFee) revert WrongFixedFee(msg.value, _fixedNativeFee);

            _orderCreation.giveTokenAddress.executePermit(_permitEnvelope);
            _safeTransferFrom(
                _orderCreation.giveTokenAddress,
                msg.sender,
                address(this),
                _order.giveAmount,
                true
            );
        }
    }

    /**
     * @dev Claims an unlock order that originated from the take chain.
     * @param _orderId The ID of the order to be unlocked.
     * @param _beneficiary Address that will receive the rewards.
     * @param _submissionChainIdFrom The chain ID of the submission sourced from the deBridgeCallProxy.
     * @param _allowActualTransfer Indicates if the funds should be transferred directly to the
     *        beneficiary or if the parent method will handle the transfer at a later stage.
     */
    function _claimUnlock(bytes32 _orderId, address _beneficiary, uint256 _submissionChainIdFrom, bool _allowActualTransfer) internal returns (uint256 amountToPay) {
        GiveOrderState storage orderState = giveOrders[_orderId];
        if (orderState.status != OrderGiveStatus.Created) {
            unexpectedOrderStatusForClaim[_orderId] = _beneficiary;
            emit UnexpectedOrderStatusForClaim(_orderId, orderState.status, _beneficiary);
            return 0;
        }
        // a circuit breaker in case DlnDestination has been compromised and is sending claim_unlock commands on behalf
        // of another chain
        if (orderState.takeChainId != _submissionChainIdFrom) {
            emit CriticalMismatchChainId(_orderId, _beneficiary, orderState.takeChainId, _submissionChainIdFrom);
            return 0;
        }
        amountToPay = orderState.giveAmount;
        orderState.status = OrderGiveStatus.ClaimedUnlock;
        address giveTokenAddress =  address(orderState.giveTokenAddress);
        if (_allowActualTransfer) {
            _safeTransferEthOrToken(giveTokenAddress, _beneficiary, amountToPay);
        }
        // send affiliateFee to affiliateFee beneficiary
        if (orderState.affiliateAmount > 0) {
            bool success;

            if (giveTokenAddress == address(0)) {
                (success, ) = orderState.affiliateBeneficiary.call{value: orderState.affiliateAmount, gas: 2300}(new bytes(0));
                if (!success) {
                    unclaimedAffiliateETHFees[orderState.affiliateBeneficiary] += orderState.affiliateAmount;
                    emit UnclaimedAffiliateFees(_orderId, address(0), orderState.affiliateAmount);
                }
            }
            else {
                success = TokenLib.trySafeTransfer(
                    giveTokenAddress,
                    orderState.affiliateBeneficiary,
                    orderState.affiliateAmount
                );

                if (!success) {
                    unclaimedERC20AffiliateFees[giveTokenAddress][orderState.affiliateBeneficiary] += orderState.affiliateAmount;
                    emit UnclaimedAffiliateFees(_orderId, giveTokenAddress, orderState.affiliateAmount);
                }
            }

            if (success) {
                emit AffiliateFeePaid(
                    _orderId,
                    orderState.affiliateBeneficiary,
                    orderState.affiliateAmount,
                    giveTokenAddress
                );
            }
        }
        emit ClaimedUnlock(
            _orderId,
            _beneficiary,
            amountToPay,
            giveTokenAddress
        );
        // Collected fee
        collectedFee[giveTokenAddress] += orderState.percentFee;
        collectedFee[address(0)] += orderState.nativeFixFee;
    }

    /**
     * @dev Claims a cancel order that originated from the take chain.
     * @param _orderId The ID of the order to be canceled.
     * @param _beneficiary Address that will receive the full refund.
     * @param _submissionChainIdFrom The chain ID of the submission sourced from the deBridgeCallProxy.
     */
     function _claimCancel(bytes32 _orderId, address _beneficiary, uint256 _submissionChainIdFrom) internal {
        GiveOrderState storage orderState = giveOrders[_orderId];
        uint256 amountToPay = orderState.giveAmount +
                orderState.percentFee +
                orderState.affiliateAmount;
        if (orderState.status == OrderGiveStatus.Created) {
            if (orderState.takeChainId != _submissionChainIdFrom) {
                revert CriticalMismatchTakeChainId(_orderId, orderState.takeChainId, _submissionChainIdFrom);
            }
            orderState.status = OrderGiveStatus.ClaimedCancel;
            address giveTokenAddress = address(orderState.giveTokenAddress);
            _safeTransferEthOrToken(giveTokenAddress, _beneficiary, amountToPay);
            _safeTransferEthOrToken(address(0), _beneficiary, orderState.nativeFixFee);
            emit ClaimedOrderCancel(
                _orderId,
                _beneficiary,
                amountToPay,
                giveTokenAddress
            );
        } else {
            unexpectedOrderStatusForCancel[_orderId] = _beneficiary;
            emit UnexpectedOrderStatusForCancel(_orderId, orderState.status, _beneficiary);
        }
    }

    function _setFixedNativeFee(uint88 _globalFixedNativeFee) internal {
        uint88 oldGlobalFixedNativeFee = globalFixedNativeFee;
        if (oldGlobalFixedNativeFee != _globalFixedNativeFee) {
            globalFixedNativeFee = _globalFixedNativeFee;
            emit GlobalFixedNativeFeeUpdated(oldGlobalFixedNativeFee, _globalFixedNativeFee);
        }
    }

    function _setTransferFeeBps(uint16 _globalTransferFeeBps) internal {
        uint16 oldGlobalTransferFeeBps = globalTransferFeeBps;
        if (oldGlobalTransferFeeBps != _globalTransferFeeBps) {
            globalTransferFeeBps = _globalTransferFeeBps;
            emit GlobalTransferFeeBpsUpdated(oldGlobalTransferFeeBps, _globalTransferFeeBps);
        }
    }

    /// @dev Check that method was called by correct dlnDestinationAddresses from the take chain
    function _onlyDlnDestinationAddress() internal view returns (uint256 submissionChainIdFrom) {
        ICallProxy callProxy = ICallProxy(deBridgeGate.callProxy());
        if (address(callProxy) != msg.sender) revert CallProxyBadRole();

        bytes memory nativeSender = callProxy.submissionNativeSender();
        submissionChainIdFrom = callProxy.submissionChainIdFrom();
        if (keccak256(dlnDestinationAddresses[submissionChainIdFrom]) != keccak256(nativeSender)) {
            revert NativeSenderBadRole(nativeSender, submissionChainIdFrom);
        }
        return submissionChainIdFrom;
    }

    /* ========== Version Control ========== */

    /// @dev Get this contract's version
    function version() external pure returns (string memory) {
        return "1.8.0";
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/IERC20Permit.sol

pragma solidity ^0.8.7;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/IDeBridgeToken.sol

pragma solidity ^0.8.7;




interface IDeBridgeToken is IERC20Upgradeable, IERC20Permit {
    /// @dev Issues new tokens.
    /// @param _receiver Token's receiver.
    /// @param _amount Amount to be minted.
    function mint(address _receiver, uint256 _amount) external;

    /// @dev Destroys existing tokens.
    /// @param _amount Amount to be burnt.
    function burn(uint256 _amount) external;
}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/IDeBridgeTokenDeployer.sol

pragma solidity ^0.8.7;

interface IDeBridgeTokenDeployer {

    /// @dev Deploy a deToken(DeBridgeTokenProxy) for an asset
    /// @param _debridgeId Asset id, see DeBridgeGate.getDebridgeId
    /// @param _name The asset's name
    /// @param _symbol The asset's symbol
    /// @param _decimals The asset's decimals
    function deployAsset(
        bytes32 _debridgeId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) external returns (address deTokenAddress);

    /// @dev Emitted when a deToken(DeBridgeTokenProxy) is deployed using this contract
    event DeBridgeTokenDeployed(
        address asset,
        string name,
        string symbol,
        uint8 decimals
    );
}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/IOraclesManager.sol

pragma solidity ^0.8.7;

interface IOraclesManager {
    /* ========== STRUCTS ========== */

    struct OracleInfo {
        bool exist; // exist oracle
        bool isValid; // is valid oracle
        bool required; // without this oracle (DSRM), the transfer will not be confirmed
    }

    /* ========== EVENTS ========== */
    /// @dev Emitted when an oracle is added
    /// @param oracle Address of an added oracle
    /// @param required Is this oracle's signature required for every transfer
    event AddOracle(address oracle, bool required);
    /// @dev Emitted when an oracle is updated
    /// @param oracle Address of an updated oracle
    /// @param required Is this oracle's signature required for every transfer
    /// @param isValid Is this oracle valid, i.e. should it be treated as an oracle
    event UpdateOracle(address oracle, bool required, bool isValid);
    /// @dev Emitted once the submission is confirmed by min required amount of oracles
    event DeployApproved(bytes32 deployId);
    /// @dev Emitted once the submission is confirmed by min required amount of oracles
    event SubmissionApproved(bytes32 submissionId);
}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/ISignatureVerifier.sol

pragma solidity ^0.8.7;

interface ISignatureVerifier {

    /* ========== EVENTS ========== */

    /// @dev Emitted once the submission is confirmed by one oracle.
    event Confirmed(bytes32 submissionId, address operator);
    /// @dev Emitted once the submission is confirmed by min required amount of oracles.
    event DeployConfirmed(bytes32 deployId, address operator);

    /* ========== FUNCTIONS ========== */

    /// @dev Check confirmation (validate signatures) for the transfer request.
    /// @param _submissionId Submission identifier.
    /// @param _signatures Array of signatures by oracles.
    /// @param _excessConfirmations override min confirmations count
    function submit(
        bytes32 _submissionId,
        bytes memory _signatures,
        uint8 _excessConfirmations
    ) external;

}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/IWETH.sol

pragma solidity ^0.8.7;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

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
}

// File: @debridge-finance/debridge-contracts-v1/contracts/interfaces/IWethGate.sol

pragma solidity ^0.8.7;

interface IWethGate {
    /// @dev Transfer assets to a receiver.
    /// @param receiver This address will receive a transfer.
    /// @param wad Amount in wei
    function withdraw(address receiver, uint wad) external;
}

// File: @debridge-finance/debridge-contracts-v1/contracts/libraries/BytesLib.sol

/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity >=0.8.0 <0.9.0;


library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/libraries/Flags.sol

pragma solidity ^0.8.7;

library Flags {

    /* ========== FLAGS ========== */

    /// @dev Flag to unwrap ETH
    uint256 public constant UNWRAP_ETH = 0;
    /// @dev Flag to revert if external call fails
    uint256 public constant REVERT_IF_EXTERNAL_FAIL = 1;
    /// @dev Flag to call proxy with a sender contract
    uint256 public constant PROXY_WITH_SENDER = 2;
    /// @dev Data is hash in DeBridgeGate send method
    uint256 public constant SEND_HASHED_DATA = 3;
    /// @dev First 24 bytes from data is gas limit for external call
    uint256 public constant SEND_EXTERNAL_CALL_GAS_LIMIT = 4;
    /// @dev Support multi send for externall call
    uint256 public constant MULTI_SEND = 5;

    /// @dev Get flag
    /// @param _packedFlags Flags packed to uint256
    /// @param _flag Flag to check
    function getFlag(
        uint256 _packedFlags,
        uint256 _flag
    ) internal pure returns (bool) {
        uint256 flag = (_packedFlags >> _flag) & uint256(1);
        return flag == 1;
    }

    /// @dev Set flag
    /// @param _packedFlags Flags packed to uint256
    /// @param _flag Flag to set
    /// @param _value Is set or not set
     function setFlag(
         uint256 _packedFlags,
         uint256 _flag,
         bool _value
     ) internal pure returns (uint256) {
         if (_value)
             return _packedFlags | uint256(1) << _flag;
         else
             return _packedFlags & ~(uint256(1) << _flag);
     }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/libraries/MultiSendCallOnly.sol

pragma solidity >=0.7.0 <0.9.0;

/// @title Multi Send Call Only - Allows to batch multiple transactions into one, but only calls
/// @author Stefan George - <stefan@gnosis.io>
/// @author Richard Meissner - <richard@gnosis.io>
/// @notice The guard logic is not required here as this contract doesn't support nested delegate calls
contract MultiSendCallOnly {
    /// @dev Sends multiple transactions and reverts all if one fails.
    /// @param transactions Encoded transactions. Each transaction is encoded as a packed bytes of
    ///                     operation has to be uint8(0) in this version (=> 1 byte),
    ///                     to as a address (=> 20 bytes),
    ///                     value as a uint256 (=> 32 bytes),
    ///                     data length as a uint256 (=> 32 bytes),
    ///                     data as bytes.
    ///                     see abi.encodePacked for more information on packed encoding
    /// @notice The code is for most part the same as the normal MultiSend (to keep compatibility),
    ///         but reverts if a transaction tries to use a delegatecall.
    /// @notice This method is payable as delegatecalls keep the msg.value from the previous call
    ///         If the calling method (e.g. execTransaction) received ETH this would revert otherwise
    function _multiSend(bytes memory transactions) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let length := mload(transactions)
            let i := 0x20
            for {
                // Pre block is not used in "while mode"
            } lt(i, length) {
                // Post block is not used in "while mode"
            } {
                // First byte of the data is the operation.
                // We shift by 248 bits (256 - 8 [operation byte]) it right since mload will always load 32 bytes (a word).
                // This will also zero out unused data.
                let operation := shr(0xf8, mload(add(transactions, i)))
                // We offset the load address by 1 byte (operation byte)
                // We shift it right by 96 bits (256 - 160 [20 address bytes]) to right-align the data and zero out unused data.
                let to := shr(0x60, mload(add(transactions, add(i, 0x01))))
                // We offset the load address by 21 byte (operation byte + 20 address bytes)
                let value := mload(add(transactions, add(i, 0x15)))
                // We offset the load address by 53 byte (operation byte + 20 address bytes + 32 value bytes)
                let dataLength := mload(add(transactions, add(i, 0x35)))
                // We offset the load address by 85 byte (operation byte + 20 address bytes + 32 value bytes + 32 data length bytes)
                let data := add(transactions, add(i, 0x55))
                let success := 0
                switch operation
                    case 0 {
                        success := call(gas(), to, value, data, dataLength, 0, 0)
                    }
                    // This version does not allow delegatecalls
                    case 1 {
                        revert(0, 0)
                    }
                if eq(success, 0) {
                    revert(0, 0)
                }
                // Next entry starts at 85 byte + data length
                i := add(i, add(0x55, dataLength))
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol

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

// File: @debridge-finance/debridge-contracts-v1/contracts/transfers/DeBridgeGate.sol

pragma solidity ^0.8.7;




















/// @dev Contract for assets transfers. The user can transfer the asset to any of the approved chains.
/// The admin manages the assets, fees and other important protocol parameters.
contract DeBridgeGate is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    IDeBridgeGate
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SignatureUtil for bytes;
    using Flags for uint256;

    /* ========== STATE VARIABLES ========== */

    /// @dev Basis points or bps, set to 10 000 (equal to 1/10000). Used to express relative values (fees)
    uint256 public constant BPS_DENOMINATOR = 10000;
    /// @dev Role allowed to stop transfers
    bytes32 public constant GOVMONITORING_ROLE = keccak256("GOVMONITORING_ROLE");

    /// @dev prefix to calculation submissionId
    uint256 public constant SUBMISSION_PREFIX = 1;
    /// @dev prefix to calculation deployId
    uint256 public constant DEPLOY_PREFIX = 2;

    /// @dev Address of IDeBridgeTokenDeployer contract
    address public deBridgeTokenDeployer;
    /// @dev Current signature verifier address to verify signatures.
    address public signatureVerifier;
    /// @dev Minimal required confirmations in case sent amount is big, have no effect if less than SignatureVerifier.minConfirmations
    uint8 public excessConfirmations;
    /// @dev *obsolete flashFeeBps
    uint256 public gap0;
    /// @dev outgoing submissions count
    uint256 public nonce;

    /// @dev Maps debridgeId (see getDebridgeId) => bridge-specific information.
    mapping(bytes32 => DebridgeInfo) public getDebridge;
    /// @dev Maps debridgeId (see getDebridgeId) => fee information
    mapping(bytes32 => DebridgeFeeInfo) public getDebridgeFeeInfo;
    /// @dev Returns whether the transfer with the submissionId was claimed.
    /// submissionId is generated in getSubmissionIdFrom
    mapping(bytes32 => bool) public override isSubmissionUsed;
    /// @dev Returns whether the transfer with the submissionId is blocked.
    mapping(bytes32 => bool) public isBlockedSubmission;
    /// @dev Maps debridgeId (see getDebridgeId) to threshold amount after which
    /// Math.max(excessConfirmations,SignatureVerifier.minConfirmations) is used instead of
    /// SignatureVerifier.minConfirmations
    mapping(bytes32 => uint256) public getAmountThreshold;
    /// @dev Whether the chain for the asset is supported to send
    mapping(uint256 => ChainSupportInfo) public getChainToConfig;
    /// @dev Whether the chain for the asset is supported to claim
    mapping(uint256 => ChainSupportInfo) public getChainFromConfig;
    /// @dev Fee discount for address
    mapping(address => DiscountInfo) public feeDiscount;
    /// @dev Returns native token info by wrapped token address
    mapping(address => TokenInfo) public override getNativeInfo;

    /// @dev *obsolete defiController
    address public gap1;
    /// @dev Returns proxy to convert the collected fees and transfer to Ethereum network to treasury
    address public feeProxy;
    /// @dev Returns address of the proxy to execute user's calls.
    address public override callProxy;
    /// @dev Returns contract for wrapped native token.
    IWETH public weth;

    /// @dev Contract address that can override globalFixedNativeFee
    address public feeContractUpdater;

    /// @dev Fallback fixed fee in native asset, used if a chain fixed fee is set to 0
    uint256 public override globalFixedNativeFee;
    /// @dev Fallback transfer fee in BPS, used if a chain transfer fee is set to 0
    uint16 public override globalTransferFeeBps;

    /// @dev WethGate contract, that is used for weth withdraws affected by EIP1884
    IWethGate public wethGate;
    /// @dev Locker for claim method
    uint256 public lockedClaim;

    /* ========== ERRORS ========== */

    error FeeProxyBadRole();
    error FeeContractUpdaterBadRole();
    error AdminBadRole();
    error GovMonitoringBadRole();
    error DebridgeNotFound();

    error WrongChainTo();
    error WrongChainFrom();
    error WrongArgument();
    error WrongAutoArgument();

    error TransferAmountTooHigh();

    error NotSupportedFixedFee();
    error TransferAmountNotCoverFees();
    error InvalidTokenToSend();

    error SubmissionUsed();
    error SubmissionBlocked();

    error AssetAlreadyExist();
    error ZeroAddress();

    error ProposedFeeTooHigh();

    error NotEnoughReserves();
    error EthTransferFailed();

    /* ========== MODIFIERS ========== */

    modifier onlyFeeProxy() {
        if (feeProxy != msg.sender) revert FeeProxyBadRole();
        _;
    }

    modifier onlyFeeContractUpdater() {
        if (feeContractUpdater != msg.sender) revert FeeContractUpdaterBadRole();
        _;
    }

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    modifier onlyGovMonitoring() {
        if (!hasRole(GOVMONITORING_ROLE, msg.sender)) revert GovMonitoringBadRole();
        _;
    }

    /* ========== CONSTRUCTOR  ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {
    }

    /// @dev Constructor that initializes the most important configurations.
    /// @param _excessConfirmations minimal required confirmations in case of too many confirmations
    /// @param _weth wrapped native token contract
    function initialize(
        uint8 _excessConfirmations,
        IWETH _weth
    ) public initializer {
        excessConfirmations = _excessConfirmations;
        weth = _weth;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __ReentrancyGuard_init();
    }

    /* ========== send, claim ========== */

    /// @inheritdoc IDeBridgeGate
    function sendMessage(
        uint256 _chainIdTo,
        bytes memory _targetContractAddress,
        bytes memory _targetContractCalldata
    ) external payable override returns (bytes32 submissionId) {
        uint flags = uint(0)
            .setFlag(Flags.REVERT_IF_EXTERNAL_FAIL, true)
            .setFlag(Flags.PROXY_WITH_SENDER, true);
        return sendMessage(_chainIdTo, _targetContractAddress, _targetContractCalldata, flags, 0);
    }

    /// @inheritdoc IDeBridgeGate
    function sendMessage(
        uint256 _chainIdTo,
        bytes memory _targetContractAddress,
        bytes memory _targetContractCalldata,
        uint256 _flags,
        uint32 _referralCode
    ) public payable override nonReentrant whenNotPaused
      returns (bytes32 submissionId) {
        if (_targetContractAddress.length == 0 || _targetContractCalldata.length == 0) {
            revert WrongAutoArgument();
        }

        (uint256 amountAfterFee, bytes32 debridgeId, FeeParams memory feeParams) = _send(
            "", // _permitEnvelope
            address(0), // _token: we use native currency
            0, // _amount to be bridged is set to zero because all amount goes to the claimer as the execution fee
            _chainIdTo,
            false // useAssetFee
        );

        SubmissionAutoParamsTo memory autoParams;
        autoParams.executionFee = _normalizeTokenAmount(address(0), amountAfterFee);
        autoParams.flags = _flags;
        autoParams.fallbackAddress = _targetContractAddress;
        autoParams.data = _targetContractCalldata;

        return _publishSubmission(
            debridgeId,
            _chainIdTo,
            0, // _amount to be bridged is set to zero because all amount goes to the claimer as the execution fee
            _targetContractAddress,
            feeParams,
            _referralCode,
            autoParams,
            true // _hasAutoParams
        );
    }

    /// @inheritdoc IDeBridgeGate
    function send(
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bytes memory _receiver,
        bytes memory _permitEnvelope,
        bool _useAssetFee,
        uint32 _referralCode,
        bytes calldata _autoParams
    ) external payable override nonReentrant whenNotPaused
      returns (bytes32 submissionId) {
        bytes32 debridgeId;
        FeeParams memory feeParams;
        uint256 amountAfterFee;
        // the amount will be reduced by the protocol fee
        (amountAfterFee, debridgeId, feeParams) = _send(
            _permitEnvelope,
            _tokenAddress,
            _amount,
            _chainIdTo,
            _useAssetFee
        );

        SubmissionAutoParamsTo memory autoParams;

        // Validate Auto Params
        if (_autoParams.length > 0) {
            autoParams = abi.decode(_autoParams, (SubmissionAutoParamsTo));
            autoParams.executionFee = _normalizeTokenAmount(_tokenAddress, autoParams.executionFee);
            if (autoParams.executionFee > amountAfterFee) {
                autoParams.executionFee = _normalizeTokenAmount(_tokenAddress, amountAfterFee);
            }
            if (autoParams.data.length > 0 && autoParams.fallbackAddress.length == 0 ) revert WrongAutoArgument();
        }

        amountAfterFee -= autoParams.executionFee;

        // round down amount in order not to bridge dust
        amountAfterFee = _normalizeTokenAmount(_tokenAddress, amountAfterFee);

        return _publishSubmission(
            debridgeId,
            _chainIdTo,
            amountAfterFee,
            _receiver,
            feeParams,
            _referralCode,
            autoParams,
            _autoParams.length > 0
        );
    }

    /// @inheritdoc IDeBridgeGate
    function claim(
        bytes32 _debridgeId,
        uint256 _amount,
        uint256 _chainIdFrom,
        address _receiver,
        uint256 _nonce,
        bytes calldata _signatures,
        bytes calldata _autoParams
    ) external override whenNotPaused {
        if (!getChainFromConfig[_chainIdFrom].isSupported) revert WrongChainFrom();

        SubmissionAutoParamsFrom memory autoParams;
        if (_autoParams.length > 0) {
            autoParams = abi.decode(_autoParams, (SubmissionAutoParamsFrom));
        }

        bytes32 submissionId = getSubmissionIdFrom(
            _debridgeId,
            _chainIdFrom,
            _amount,
            _receiver,
            _nonce,
            autoParams,
            _autoParams.length > 0,
            msg.sender
        );

        // check if submission already claimed
        if (isSubmissionUsed[submissionId]) revert SubmissionUsed();
        isSubmissionUsed[submissionId] = true;

        _checkConfirmations(submissionId, _debridgeId, _amount, _signatures);

        bool isNativeToken =_claim(
            submissionId,
            _debridgeId,
            _receiver,
            _amount,
            _chainIdFrom,
            autoParams
        );

        emit Claimed(
            submissionId,
            _debridgeId,
            _amount,
            _receiver,
            _nonce,
            _chainIdFrom,
            _autoParams,
            isNativeToken
        );
    }

    /// @dev Deploy a deToken(DeBridgeTokenProxy) for an asset
    /// @param _nativeTokenAddress A token address on a native chain
    /// @param _nativeChainId The token native chain's id
    /// @param _name The token's name
    /// @param _symbol The token's symbol
    /// @param _decimals The token's decimals
    /// @param _signatures Validators' signatures
    function deployNewAsset(
        bytes memory _nativeTokenAddress,
        uint256 _nativeChainId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        bytes memory _signatures
    ) external nonReentrant whenNotPaused{
        bytes32 debridgeId = getbDebridgeId(_nativeChainId, _nativeTokenAddress);

        if (getDebridge[debridgeId].exist) revert AssetAlreadyExist();

        bytes32 deployId = getDeployId(debridgeId, _name, _symbol, _decimals);

        // verify signatures
        ISignatureVerifier(signatureVerifier).submit(deployId, _signatures, excessConfirmations);

        address deBridgeTokenAddress = IDeBridgeTokenDeployer(deBridgeTokenDeployer)
            .deployAsset(debridgeId, _name, _symbol, _decimals);

        _addAsset(debridgeId, deBridgeTokenAddress, _nativeTokenAddress, _nativeChainId);
    }

    /// @dev Update native fix fee. Called by our fee update contract
    /// @param _globalFixedNativeFee  new value
    function autoUpdateFixedNativeFee(
        uint256 _globalFixedNativeFee
    ) external onlyFeeContractUpdater {
        globalFixedNativeFee = _globalFixedNativeFee;
        emit FixedNativeFeeAutoUpdated(_globalFixedNativeFee);
    }

    /* ========== ADMIN ========== */

    /// @dev Update asset's fees.
    /// @param _chainIds Chain identifiers.
    /// @param _chainSupportInfo Chain support info.
    /// @param _isChainFrom is true for editing getChainFromConfig.
    function updateChainSupport(
        uint256[] memory _chainIds,
        ChainSupportInfo[] memory _chainSupportInfo,
        bool _isChainFrom
    ) external onlyAdmin {
        if (_chainIds.length != _chainSupportInfo.length) revert WrongArgument();
        for (uint256 i = 0; i < _chainIds.length; i++) {
            if(_isChainFrom){
                getChainFromConfig[_chainIds[i]] = _chainSupportInfo[i];
            }
            else {
                getChainToConfig[_chainIds[i]] = _chainSupportInfo[i];
            }
            emit ChainsSupportUpdated(_chainIds[i], _chainSupportInfo[i], _isChainFrom);
        }
    }

    /// @dev Update fallbacks for fixed fee in native asset and transfer fee
    /// @param _globalFixedNativeFee Fallback fixed fee in native asset, used if a chain fixed fee is set to 0
    /// @param _globalTransferFeeBps Fallback transfer fee in BPS, used if a chain transfer fee is set to 0
    function updateGlobalFee(
        uint256 _globalFixedNativeFee,
        uint16 _globalTransferFeeBps
    ) external onlyAdmin {
        globalFixedNativeFee = _globalFixedNativeFee;
        globalTransferFeeBps = _globalTransferFeeBps;
        emit FixedNativeFeeUpdated(_globalFixedNativeFee, _globalTransferFeeBps);
    }

    /// @dev Update asset's fees.
    /// @param _debridgeId Asset identifier.
    /// @param _supportedChainIds Chain identifiers.
    /// @param _assetFeesInfo Chain support info.
    function updateAssetFixedFees(
        bytes32 _debridgeId,
        uint256[] memory _supportedChainIds,
        uint256[] memory _assetFeesInfo
    ) external onlyAdmin {
        if (_supportedChainIds.length != _assetFeesInfo.length) revert WrongArgument();
        DebridgeFeeInfo storage debridgeFee = getDebridgeFeeInfo[_debridgeId];
        for (uint256 i = 0; i < _supportedChainIds.length; i++) {
            debridgeFee.getChainFee[_supportedChainIds[i]] = _assetFeesInfo[i];
        }
    }

    /// @dev Update minimal amount of required signatures, must be > SignatureVerifier.minConfirmations to have an effect
    /// @param _excessConfirmations Minimal amount of required signatures
    function updateExcessConfirmations(uint8 _excessConfirmations) external onlyAdmin {
        if (_excessConfirmations == 0) revert WrongArgument();
        excessConfirmations = _excessConfirmations;
    }

    /// @dev Set support for the chains where the token can be transferred.
    /// @param _chainId Chain id where tokens are sent.
    /// @param _isSupported Whether the token is transferable to the other chain.
    /// @param _isChainFrom is true for editing getChainFromConfig.
    function setChainSupport(uint256 _chainId, bool _isSupported, bool _isChainFrom) external onlyAdmin {
        if (_isChainFrom) {
            getChainFromConfig[_chainId].isSupported = _isSupported;
        }
        else {
            getChainToConfig[_chainId].isSupported = _isSupported;
        }
        emit ChainSupportUpdated(_chainId, _isSupported, _isChainFrom);
    }

    /// @dev Set address of the call proxy.
    /// @param _callProxy Address of the proxy that executes external calls.
    function setCallProxy(address _callProxy) external onlyAdmin {
        callProxy = _callProxy;
        emit CallProxyUpdated(_callProxy);
    }

    /// @dev Update specific asset's bridge parameters.
    /// @param _debridgeId Asset identifier.
    /// @param _maxAmount Maximum amount of current chain token to be wrapped.
    /// @param _minReservesBps Minimal reserve ration in BPS.
    /// @param _amountThreshold Threshold amount after which Math.max(excessConfirmations,SignatureVerifier.minConfirmations) is used instead of SignatureVerifier.minConfirmations
    function updateAsset(
        bytes32 _debridgeId,
        uint256 _maxAmount,
        uint16 _minReservesBps,
        uint256 _amountThreshold
    ) external onlyAdmin {
        if (_minReservesBps > BPS_DENOMINATOR) revert WrongArgument();
        DebridgeInfo storage debridge = getDebridge[_debridgeId];
        // don't check existence of debridge - it allows to setup asset before first transfer
        debridge.maxAmount = _maxAmount;
        debridge.minReservesBps = _minReservesBps;
        getAmountThreshold[_debridgeId] = _amountThreshold;
    }


    /// @dev Set signature verifier address.
    /// @param _verifier Signature verifier address.
    function setSignatureVerifier(address _verifier) external onlyAdmin {
        signatureVerifier = _verifier;
    }

    /// @dev Set asset deployer address.
    /// @param _deBridgeTokenDeployer Asset deployer address.
    function setDeBridgeTokenDeployer(address _deBridgeTokenDeployer) external onlyAdmin {
        deBridgeTokenDeployer = _deBridgeTokenDeployer;
    }

    /// @dev Set fee contract updater, that can update fix native fee
    /// @param _value new contract address.
    function setFeeContractUpdater(address _value) external onlyAdmin {
        feeContractUpdater = _value;
    }

    /// @dev Set wethGate contract, that uses for weth withdraws affected by EIP1884
    /// @param _wethGate address of new wethGate contract.
    function setWethGate(IWethGate _wethGate) external onlyAdmin {
        wethGate = _wethGate;
    }

    /// @dev Stop all transfers.
    function pause() external onlyGovMonitoring {
        _pause();
    }

    /// @dev Allow transfers.
    function unpause() external onlyAdmin {
        _unpause();
    }

    /// @inheritdoc IDeBridgeGate
    function withdrawFee(bytes32 _debridgeId) external override nonReentrant onlyFeeProxy {
        DebridgeFeeInfo storage debridgeFee = getDebridgeFeeInfo[_debridgeId];
        // Amount for transfer to treasury
        uint256 amount = debridgeFee.collectedFees - debridgeFee.withdrawnFees;

        if (amount == 0) revert NotEnoughReserves();

        debridgeFee.withdrawnFees += amount;

        if (_debridgeId == getDebridgeId(getChainId(), address(0))) {
            _safeTransferETH(feeProxy, amount);
        } else {
            // don't need this check as we check that amount is not zero
            // if (!getDebridge[_debridgeId].exist) revert DebridgeNotFound();
            IERC20Upgradeable(getDebridge[_debridgeId].tokenAddress).safeTransfer(feeProxy, amount);
        }
        emit WithdrawnFee(_debridgeId, amount);
    }

    /// @dev Set fee converter proxy.
    /// @param _feeProxy Fee proxy address.
    function setFeeProxy(address _feeProxy) external onlyAdmin {
        feeProxy = _feeProxy;
    }

    /// @dev Block or unblock a list of submissions
    /// @param _submissionIds Ids of submissions to block/unblock
    /// @param isBlocked True to block, false to unblock
    function blockSubmission(bytes32[] memory _submissionIds, bool isBlocked) external onlyAdmin {
        for (uint256 i = 0; i < _submissionIds.length; i++) {
            isBlockedSubmission[_submissionIds[i]] = isBlocked;
            if (isBlocked) {
                emit Blocked(_submissionIds[i]);
            } else {
                emit Unblocked(_submissionIds[i]);
            }
        }
    }

    /// @dev Update discount.
    /// @param _address customer address
    /// @param _discountFixBps  fix discount in BPS
    /// @param _discountTransferBps transfer % discount in BPS
    function updateFeeDiscount(
        address _address,
        uint16 _discountFixBps,
        uint16 _discountTransferBps
    ) external onlyAdmin {
        if (_address == address(0) ||
            _discountFixBps > BPS_DENOMINATOR ||
            _discountTransferBps > BPS_DENOMINATOR
        ) revert WrongArgument();
        DiscountInfo storage discountInfo = feeDiscount[_address];
        discountInfo.discountFixBps = _discountFixBps;
        discountInfo.discountTransferBps = _discountTransferBps;
    }

    // we need to accept ETH sends to unwrap WETH
    receive() external payable {
        // assert(msg.sender == address(weth)); // only accept ETH via fallback from the WETH contract
    }

    /* ========== INTERNAL ========== */

    function _checkConfirmations(
        bytes32 _submissionId,
        bytes32 _debridgeId,
        uint256 _amount,
        bytes calldata _signatures
    ) internal {
        if (isBlockedSubmission[_submissionId]) revert SubmissionBlocked();
        // inside check is confirmed
        ISignatureVerifier(signatureVerifier).submit(
            _submissionId,
            _signatures,
            _amount >= getAmountThreshold[_debridgeId] ? excessConfirmations : 0
        );
    }

    /// @dev Add support for the asset.
    /// @param _debridgeId Asset identifier.
    /// @param _tokenAddress Address of the asset on the current chain.
    /// @param _nativeAddress Address of the asset on the native chain.
    /// @param _nativeChainId Native chain id.
    function _addAsset(
        bytes32 _debridgeId,
        address _tokenAddress,
        bytes memory _nativeAddress,
        uint256 _nativeChainId
    ) internal {
        DebridgeInfo storage debridge = getDebridge[_debridgeId];

        if (debridge.exist) revert AssetAlreadyExist();
        if (_tokenAddress == address(0)) revert ZeroAddress();

        debridge.exist = true;
        debridge.tokenAddress = _tokenAddress;
        debridge.chainId = _nativeChainId;
        // Don't override if the admin already set maxAmount in updateAsset method before
        if (debridge.maxAmount == 0) {
            debridge.maxAmount = type(uint256).max;
        }
        // set minReservesBps to 100% to prevent using new asset by DeFiController by default
        debridge.minReservesBps = uint16(BPS_DENOMINATOR);
        if (getAmountThreshold[_debridgeId] == 0) {
            getAmountThreshold[_debridgeId] = type(uint256).max;
        }

        TokenInfo storage tokenInfo = getNativeInfo[_tokenAddress];
        tokenInfo.nativeChainId = _nativeChainId;
        tokenInfo.nativeAddress = _nativeAddress;

        emit PairAdded(
            _debridgeId,
            _tokenAddress,
            _nativeAddress,
            _nativeChainId,
            debridge.maxAmount,
            debridge.minReservesBps
        );
    }

    /// @dev Locks asset on the chain and enables minting on the other chain.
    /// @param _amount Amount to be transferred (note: the fee can be applied).
    /// @param _chainIdTo Chain id of the target chain.
    /// @param _permitEnvelope Permit for approving the spender by signature. bytes (amount + deadline + signature)
    function _send(
        bytes memory _permitEnvelope,
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bool _useAssetFee
    ) internal returns (
        uint256 amountAfterFee,
        bytes32 debridgeId,
        FeeParams memory feeParams
    ) {
        _validateToken(_tokenAddress);

        // Run _permit first. Avoid Stack too deep
        if (_permitEnvelope.length > 0) {
            // call permit before transferring token
            uint256 permitAmount = _permitEnvelope.toUint256(0);
            uint256 deadline = _permitEnvelope.toUint256(32);
            (bytes32 r, bytes32 s, uint8 v) = _permitEnvelope.parseSignature(64);
            IERC20Permit(_tokenAddress).permit(
                msg.sender,
                address(this),
                permitAmount,
                deadline,
                v,
                r,
                s);
        }

        TokenInfo memory nativeTokenInfo = getNativeInfo[_tokenAddress];
        bool isNativeToken = nativeTokenInfo.nativeChainId  == 0
            ? true // token not in mapping
            : nativeTokenInfo.nativeChainId == getChainId(); // token native chain id the same

        if (isNativeToken) {
            //We use WETH debridgeId for transfer ETH
            debridgeId = getDebridgeId(
                getChainId(),
                _tokenAddress == address(0) ? address(weth) : _tokenAddress
            );
        }
        else {
            debridgeId = getbDebridgeId(
                nativeTokenInfo.nativeChainId,
                nativeTokenInfo.nativeAddress
            );
        }

        DebridgeInfo storage debridge = getDebridge[debridgeId];
        if (!debridge.exist) {
            if (isNativeToken) {
                // Use WETH as a token address for native tokens
                address assetAddress = _tokenAddress == address(0) ? address(weth) : _tokenAddress;
                _addAsset(
                    debridgeId,
                    assetAddress,
                    abi.encodePacked(assetAddress),
                    getChainId()
                );
            } else revert DebridgeNotFound();
        }

        ChainSupportInfo memory chainFees = getChainToConfig[_chainIdTo];
        if (!chainFees.isSupported) revert WrongChainTo();

        if (_tokenAddress == address(0)) {
            // use msg.value as amount for native tokens
            _amount = msg.value;
            weth.deposit{value: _amount}();
            _useAssetFee = true;
        } else {
            IERC20Upgradeable token = IERC20Upgradeable(_tokenAddress);
            uint256 balanceBefore = token.balanceOf(address(this));
            token.safeTransferFrom(msg.sender, address(this), _amount);
            // Received real amount
            _amount = token.balanceOf(address(this)) - balanceBefore;
        }

        if (_amount > debridge.maxAmount) revert TransferAmountTooHigh();

        //_processFeeForTransfer
        {
            DiscountInfo memory discountInfo = feeDiscount[msg.sender];
            DebridgeFeeInfo storage debridgeFee = getDebridgeFeeInfo[debridgeId];

            // calculate fixed fee
            uint256 assetsFixedFee;
            if (_useAssetFee) {
                if (_tokenAddress == address(0)) {
                    // collect asset fixed fee (in weth) for native token transfers
                    assetsFixedFee = chainFees.fixedNativeFee == 0 ? globalFixedNativeFee : chainFees.fixedNativeFee;
                } else {
                    // collect asset fixed fee for non native token transfers
                    assetsFixedFee = debridgeFee.getChainFee[_chainIdTo];
                    if (assetsFixedFee == 0) revert NotSupportedFixedFee();
                }
                // Apply discount for a asset fixed fee
                assetsFixedFee = _applyDiscount(assetsFixedFee, discountInfo.discountFixBps);
                if (_amount < assetsFixedFee) revert TransferAmountNotCoverFees();
                feeParams.fixFee = assetsFixedFee;
            } else {
                // collect fixed native fee for non native token transfers

                // use globalFixedNativeFee if value for chain is not set
                uint256 nativeFee = chainFees.fixedNativeFee == 0 ? globalFixedNativeFee : chainFees.fixedNativeFee;
                // Apply discount for a native fixed fee
                nativeFee = _applyDiscount(nativeFee, discountInfo.discountFixBps);

                if (msg.value < nativeFee) revert TransferAmountNotCoverFees();
                else if (msg.value > nativeFee) {
                    // refund extra fee eth
                     _safeTransferETH(msg.sender, msg.value - nativeFee);
                }
                bytes32 nativeDebridgeId = getDebridgeId(getChainId(), address(0));
                getDebridgeFeeInfo[nativeDebridgeId].collectedFees += nativeFee;
                feeParams.fixFee = nativeFee;
            }

            // Calculate transfer fee
            // use globalTransferFeeBps if value for chain is not set
            uint256 transferFee = (chainFees.transferFeeBps == 0
                ? globalTransferFeeBps : chainFees.transferFeeBps)
                * (_amount - assetsFixedFee) / BPS_DENOMINATOR;
            // apply discount for a transfer fee
            transferFee = _applyDiscount(transferFee, discountInfo.discountTransferBps);

            uint256 totalFee = transferFee + assetsFixedFee;
            if (_amount < totalFee) revert TransferAmountNotCoverFees();
            debridgeFee.collectedFees += totalFee;
            amountAfterFee = _amount - totalFee;

            // initialize feeParams
            feeParams.transferFee = transferFee;
            feeParams.useAssetFee = _useAssetFee;
            feeParams.receivedAmount = _amount;
            feeParams.isNativeToken = isNativeToken;
        }

        if (isNativeToken) {
            debridge.balance += amountAfterFee;
        }
        else {
            debridge.balance -= amountAfterFee;
            IDeBridgeToken(debridge.tokenAddress).burn(amountAfterFee);
        }
        return (amountAfterFee, debridgeId, feeParams);
    }

    function _publishSubmission(
        bytes32 _debridgeId,
        uint256 _chainIdTo,
        uint256 _amount,
        bytes memory _receiver,
        FeeParams memory feeParams,
        uint32 _referralCode,
        SubmissionAutoParamsTo memory autoParams,
        bool hasAutoParams
    ) internal returns (bytes32 submissionId) {
        bytes memory packedSubmission = abi.encodePacked(
            SUBMISSION_PREFIX,
            _debridgeId,
            getChainId(),
            _chainIdTo,
            _amount,
            _receiver,
            nonce
        );
        if (hasAutoParams) {
            bool isHashedData = autoParams.flags.getFlag(Flags.SEND_HASHED_DATA);
            if (isHashedData && autoParams.data.length != 32) revert WrongAutoArgument();
            // auto submission
            submissionId = keccak256(
                abi.encodePacked(
                    packedSubmission,
                    autoParams.executionFee,
                    autoParams.flags,
                    keccak256(autoParams.fallbackAddress),
                    isHashedData ? autoParams.data : abi.encodePacked(keccak256(autoParams.data)),
                    keccak256(abi.encodePacked(msg.sender))
                )
            );
        }
        // regular submission
        else {
            submissionId = keccak256(packedSubmission);
        }

        emit Sent(
            submissionId,
            _debridgeId,
            _amount,
            _receiver,
            nonce,
            _chainIdTo,
            _referralCode,
            feeParams,
            hasAutoParams ? abi.encode(autoParams): bytes(""),
            msg.sender
        );

        {
            emit MonitoringSendEvent(
                submissionId,
                nonce,
                getDebridge[_debridgeId].balance,
                IERC20Upgradeable(getDebridge[_debridgeId].tokenAddress).totalSupply()
            );
        }

        nonce++;
    }

    function _applyDiscount(
        uint256 amount,
        uint16 discountBps
    ) internal pure returns (uint256) {
        return amount - amount * discountBps / BPS_DENOMINATOR;
    }

    function _validateToken(address _token) internal {
        if (_token == address(0)) {
            // no validation for native tokens
            return;
        }

        // check existence of decimals method
        (bool success, ) = _token.call(abi.encodeWithSignature("decimals()"));
        if (!success) revert InvalidTokenToSend();

        // check existence of symbol method
        (success, ) = _token.call(abi.encodeWithSignature("symbol()"));
        if (!success) revert InvalidTokenToSend();
    }


    /// @dev Unlock the asset on the current chain and transfer to receiver.
    /// @param _debridgeId Asset identifier.
    /// @param _receiver Receiver address.
    /// @param _amount Amount of the transfered asset (note: the fee can be applyed).
    function _claim(
        bytes32 _submissionId,
        bytes32 _debridgeId,
        address _receiver,
        uint256 _amount,
        uint256 _chainIdFrom,
        SubmissionAutoParamsFrom memory _autoParams
    ) internal returns (bool isNativeToken) {
        DebridgeInfo storage debridge = getDebridge[_debridgeId];
        if (!debridge.exist) revert DebridgeNotFound();
        isNativeToken = debridge.chainId == getChainId();

        if (isNativeToken) {
            debridge.balance -= _amount + _autoParams.executionFee;
        } else {
            debridge.balance += _amount + _autoParams.executionFee;
        }

        address _token = debridge.tokenAddress;
        bool unwrapETH = isNativeToken
            && _autoParams.flags.getFlag(Flags.UNWRAP_ETH)
            && _token == address(weth);

        if (_autoParams.executionFee > 0) {
            _mintOrTransfer(_token, msg.sender, _autoParams.executionFee, isNativeToken);
        }
        if (_autoParams.data.length > 0) {
            // use local variable to reduce gas usage
            address _callProxy = callProxy;
            bool status;
            if (unwrapETH) {
                // withdraw weth to callProxy directly
                _withdrawWeth(_callProxy, _amount);
                status = ICallProxy(_callProxy).call(
                    _autoParams.fallbackAddress,
                    _receiver,
                    _autoParams.data,
                    _autoParams.flags,
                    _autoParams.nativeSender,
                    _chainIdFrom
                );
            }
            else {
                _mintOrTransfer(_token, _callProxy, _amount, isNativeToken);

                status = ICallProxy(_callProxy).callERC20(
                    _token,
                    _autoParams.fallbackAddress,
                    _receiver,
                    _autoParams.data,
                    _autoParams.flags,
                    _autoParams.nativeSender,
                    _chainIdFrom
                );
            }
            emit AutoRequestExecuted(_submissionId, status, _callProxy);
        } else if (unwrapETH) {
            // transferring WETH with unwrap flag
            _withdrawWeth(_receiver, _amount);
        } else {
            _mintOrTransfer(_token, _receiver, _amount, isNativeToken);
        }

        emit MonitoringClaimEvent(
            _submissionId,
            debridge.balance,
            IERC20Upgradeable(debridge.tokenAddress).totalSupply()
        );
    }

    function _mintOrTransfer(
        address _token,
        address _receiver,
        uint256 _amount,
        bool isNativeToken
    ) internal {
        if (_amount > 0) {
            if (isNativeToken) {
                IERC20Upgradeable(_token).safeTransfer(_receiver, _amount);
            } else {
                IDeBridgeToken(_token).mint(_receiver, _amount);
            }
        }
    }

    /*
    * @dev transfer ETH to an address, revert if it fails.
    * @param to recipient of the transfer
    * @param value the amount to send
    */
    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) revert EthTransferFailed();
    }


    function _withdrawWeth(address _receiver, uint _amount) internal {
        if (address(wethGate) == address(0)) {
            // dealing with weth withdraw affected by EIP1884
            weth.withdraw(_amount);
            _safeTransferETH(_receiver, _amount);
        }
        else {
            IERC20Upgradeable(address(weth)).safeTransfer(address(wethGate), _amount);
            wethGate.withdraw(_receiver, _amount);
        }
    }

    /*
    * @dev round down token amount
    * @param _token address of token, zero for native tokens
    * @param __amount amount for rounding
    */
    function _normalizeTokenAmount(
        address _token,
        uint256 _amount
    ) internal view returns (uint256) {
        uint256 decimals = _token == address(0)
            ? 18
            : IERC20Metadata(_token).decimals();
        uint256 maxDecimals = 8;
        if (decimals > maxDecimals) {
            uint256 multiplier = 10 ** (decimals - maxDecimals);
            _amount = _amount / multiplier * multiplier;
        }
        return _amount;
    }

    /* VIEW */

    /// @dev Calculates asset identifier.
    /// @param _chainId Current chain id.
    /// @param _tokenAddress Address of the asset on the other chain.
    function getDebridgeId(uint256 _chainId, address _tokenAddress) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_chainId, _tokenAddress));
    }

    /// @dev Calculates asset identifier.
    /// @param _chainId Current chain id.
    /// @param _tokenAddress Address of the asset on the other chain.
    function getbDebridgeId(uint256 _chainId, bytes memory _tokenAddress) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_chainId, _tokenAddress));
    }

    /// @inheritdoc IDeBridgeGate
    function getDebridgeChainAssetFixedFee(
        bytes32 _debridgeId,
        uint256 _chainId
    ) external view override returns (uint256) {
        // if (!getDebridge[_debridgeId].exist) revert DebridgeNotFound();
        return getDebridgeFeeInfo[_debridgeId].getChainFee[_chainId];
    }

    /// @dev Calculate submission id for auto claimable transfer.
    /// @param _debridgeId Asset identifier.
    /// @param _chainIdFrom Chain identifier of the chain where tokens are sent from.
    /// @param _amount Amount of the transferred asset (note: the fee can be applied).
    /// @param _receiver Receiver address.
    /// @param _nonce Submission id.
    /// @param _autoParams Auto params for external call
    /// @param _hasAutoParams True if auto params are provided
    /// @param _sender Address that will call claim
    function getSubmissionIdFrom(
        bytes32 _debridgeId,
        uint256 _chainIdFrom,
        uint256 _amount,
        address _receiver,
        uint256 _nonce,
        SubmissionAutoParamsFrom memory _autoParams,
        bool _hasAutoParams,
        address _sender
    ) public view returns (bytes32) {
        bytes memory packedSubmission = abi.encodePacked(
            SUBMISSION_PREFIX,
            _debridgeId,
            _chainIdFrom,
            getChainId(),
            _amount,
            _receiver,
            _nonce
        );
        if (_hasAutoParams) {
            // Needed to let fallback address claim tokens in case user lost call data and can't restore its' hash
            bool isHashedData = _autoParams.flags.getFlag(Flags.SEND_HASHED_DATA)
                             && _sender == _autoParams.fallbackAddress
                             && _autoParams.data.length == 32;

            // auto submission
            return keccak256(
                abi.encodePacked(
                    packedSubmission,
                    _autoParams.executionFee,
                    _autoParams.flags,
                    keccak256(abi.encodePacked(_autoParams.fallbackAddress)),
                    isHashedData ? _autoParams.data : abi.encodePacked(keccak256(_autoParams.data)),
                    keccak256(_autoParams.nativeSender)
                )
            );
        }
        // regular submission
        return keccak256(packedSubmission);
    }



    /// @dev Calculates asset identifier for deployment.
    /// @param _debridgeId Id of an asset, see getDebridgeId.
    /// @param _name Asset's name.
    /// @param _symbol Asset's symbol.
    /// @param _decimals Asset's decimals.
    function getDeployId(
        bytes32 _debridgeId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            DEPLOY_PREFIX,
            _debridgeId,
            keccak256(abi.encodePacked(_name)),
            keccak256(abi.encodePacked(_symbol)),
            _decimals));
    }

    /// @dev Get current chain id
    function getChainId() public view virtual returns (uint256 cid) {
        assembly {
            cid := chainid()
        }
    }

    // ============ Version Control ============
    /// @dev Get this contract's version
    function version() external pure returns (uint256) {
        return 421; // 4.2.1
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/mock/MockDeBridgeGate.sol

pragma solidity ^0.8.7;



contract MockDeBridgeGate is DeBridgeGate {
    uint256 public chainId;

    /* ========== CONSTRUCTOR  ========== */

    /// @dev Constructor that initializes the most important configurations.
    /// @param _signatureVerifier Aggregator address to verify signatures
    function initializeMock(
        uint8 _excessConfirmations,
        address _signatureVerifier,
        address _callProxy,
        IWETH _weth,
        address _feeProxy,
        address _deBridgeTokenDeployer,
        uint256 overrideChainId
    ) public initializer {
        chainId = overrideChainId;

        signatureVerifier = _signatureVerifier;

        callProxy = _callProxy;
        excessConfirmations = _excessConfirmations;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        weth = _weth;
        feeProxy = _feeProxy;
        deBridgeTokenDeployer = _deBridgeTokenDeployer;
    }

    // return overrided chain id
    function getChainId() public view override returns (uint256 cid) {
        return chainId;
    }

    /// @dev Calculate submission id.
    /// @param _debridgeId Asset identifier.
    /// @param _chainIdFrom Chain identifier of the chain where tokens are sent from.
    /// @param _chainIdTo Chain identifier of the chain where tokens are sent to.
    /// @param _receiver Receiver address.
    /// @param _amount Amount of the transfered asset (note: the fee can be applyed).
    /// @param _nonce Submission id.
    function getSubmissionId(
        bytes32 _debridgeId,
        uint256 _chainIdFrom,
        uint256 _chainIdTo,
        uint256 _amount,
        address _receiver,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(SUBMISSION_PREFIX, _debridgeId, _chainIdFrom, _chainIdTo, _amount, _receiver, _nonce)
            );
    }

    // function getEncodePackedFROM(
    //     bytes memory _nativeSender,
    //     bytes32 _debridgeId,
    //     uint256 _chainIdFrom,
    //     uint256 _amount,
    //     address _receiver,
    //     uint256 _nonce,//hello
    //     address _fallbackAddress,
    //     uint256 _executionFee,
    //     bytes memory _data
    // ) public view returns (bytes memory) {
    //     return
    //             abi.encodePacked(
    //                 // To avoid error:
    //                 // Variable value0 is 1 slot(s) too deep inside the stack.
    //                 abi.encodePacked(
    //                     //TODO: ALARM CHECK that we have the same abi.encodePacked from and TO getAutoSubmissionIdTo
    //                     _nativeSender,
    //                     _debridgeId,
    //                     _chainIdFrom
    //                 ),
    //                 getChainId(),//_chainIdTo,
    //                 _amount,
    //                 _receiver,
    //                 _nonce,
    //                 _fallbackAddress,
    //                 _executionFee,
    //                 _data
    //             );
    // }

    // function getEncodePackedTO(
    //     bytes32 _debridgeId,
    //     uint256 _chainIdTo,
    //     uint256 _amount,
    //     bytes memory _receiver,
    //     // uint256 _nonce,
    //     bytes memory _fallbackAddress,
    //     uint256 _executionFee,
    //     bytes memory _data
    // ) public view returns  (bytes memory) {
    //     return
    //             abi.encodePacked(
    //                 address(this), // only for test
    //                 // msg.sender,
    //                 _debridgeId,
    //                 getChainId(),
    //                 _chainIdTo,
    //                 _amount,
    //                 _receiver,
    //                 nonce, //_nonce,
    //                 _fallbackAddress,
    //                 _executionFee,
    //                 _data
    //             );
    // }
}

// File: @openzeppelin/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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

// File: @openzeppelin/contracts/utils/Strings.sol

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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

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
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
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
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
}

// File: @debridge-finance/debridge-contracts-v1/contracts/mock/MockToken.sol

pragma solidity ^0.8.7;





contract MockToken is ERC20 {
    uint8 private _decimals;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimal
    ) ERC20(_name, _symbol) {
        _decimals = _decimal;
    }

    fallback() external payable { }

    receive() external payable { }

    function mint(address _receiver, uint256 _amount) external {
        _mint(_receiver, _amount);
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/mock/MockWeth.sol

// Copyright (C) 2015, 2016, 2017 Dapphub

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.7;

contract MockWeth {
    string public name;  //   = "Wrapped Ether";
    string public symbol;//   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    error EthTransferFailed();

    constructor(string memory _name, string memory  _symbol) {
        name = _name;
        symbol = _symbol;
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        _safeTransferETH(msg.sender, wad);
        emit Withdrawal(msg.sender, wad);
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) revert EthTransferFailed();
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/periphery/CallProxy.sol

pragma solidity ^0.8.7;











/// @dev Proxy to execute the other contract calls.
/// This contract is used when a user requests transfer with specific call of other contract.
contract CallProxy is Initializable, AccessControlUpgradeable, MultiSendCallOnly, ICallProxy {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using Flags for uint256;
    using AddressUpgradeable for address;

    /* ========== STATE VARIABLES ========== */
    /// @dev Role allowed to withdraw fee
    bytes32 public constant DEBRIDGE_GATE_ROLE = keccak256("DEBRIDGE_GATE_ROLE");

    /// @dev Value for lock variable when function is not entered
    uint256 private constant _NOT_LOCKED = 1;
    /// @dev Value for lock variable when function is entered
    uint256 private constant _LOCKED = 2;

    /// @dev Chain from which the current submission is received
    uint256 public override submissionChainIdFrom;
    /// @dev Native sender of the current submission
    bytes public override submissionNativeSender;

    uint256 private _lock;

    /* ========== ERRORS ========== */

    error DeBridgeGateBadRole();
    error CallProxyBadRole();
    error ExternalCallFailed();
    error NotEnoughSafeTxGas();
    error CallFailed();
    error Locked();

    /* ========== MODIFIERS ========== */

    modifier onlyGateRole() {
        if (!hasRole(DEBRIDGE_GATE_ROLE, msg.sender)) revert DeBridgeGateBadRole();
        _;
    }

    /// @dev lock
    modifier lock() {
        if (_lock == _LOCKED) revert Locked();
        _lock = _LOCKED;
        _;
        _lock = _NOT_LOCKED;
    }

    /* ========== CONSTRUCTOR  ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {
    }
    
    function initialize() public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /* ========== PUBLIC METHODS ========== */

    /// @inheritdoc ICallProxy
    function call(
        address _reserveAddress,
        address _receiver,
        bytes memory _data,
        uint256 _flags,
        bytes memory _nativeSender,
        uint256 _chainIdFrom
    ) external payable override onlyGateRole lock returns (bool _result) {
        uint256 amount = address(this).balance;

        _result = _externalCall(
            _receiver,
            amount,
            _data,
            _nativeSender,
            _chainIdFrom,
            _flags
        );

        if (!_result && _flags.getFlag(Flags.REVERT_IF_EXTERNAL_FAIL)) {
            revert ExternalCallFailed();
        }

        amount = address(this).balance;
        if (amount > 0) {
            (bool success, ) = _reserveAddress.call{value: amount}(new bytes(0));
            if (!success) revert CallFailed();
        }
    }

    /// @inheritdoc ICallProxy
    function callERC20(
        address _token,
        address _reserveAddress,
        address _receiver,
        bytes memory _data,
        uint256 _flags,
        bytes memory _nativeSender,
        uint256 _chainIdFrom
    ) external override onlyGateRole lock returns (bool _result) {
        uint256 amount = IERC20Upgradeable(_token).balanceOf(address(this));
        if (_receiver != address(0)) {
            _customApprove(IERC20Upgradeable(_token), _receiver, amount);
        }
        _result = _externalCall(
            _receiver,
            0,
            _data,
            _nativeSender,
            _chainIdFrom,
            _flags
        );

        amount = IERC20Upgradeable(_token).balanceOf(address(this));

        if (!_result &&_flags.getFlag(Flags.REVERT_IF_EXTERNAL_FAIL)) {
            revert ExternalCallFailed();
        }
        if (amount > 0) {
            IERC20Upgradeable(_token).safeTransfer(_reserveAddress, amount);
        }
        if (_receiver != address(0)) {
            _customApprove(IERC20Upgradeable(_token), _receiver, 0);
        }
    }

    /// @dev Sends multiple transactions and reverts all if one fails.
    /// @param transactions Encoded transactions. Each transaction is encoded as a packed bytes of
    ///                     operation has to be uint8(0) in this version (=> 1 byte),
    ///                     to as a address (=> 20 bytes),
    ///                     value as a uint256 (=> 32 bytes),
    ///                     data length as a uint256 (=> 32 bytes),
    ///                     data as bytes.
    ///                     see abi.encodePacked for more information on packed encoding
    /// @notice The code is for most part the same as the normal MultiSend (to keep compatibility),
    ///         but reverts if a transaction tries to use a delegatecall.
    /// @notice This method is payable as delegatecalls keep the msg.value from the previous call
    ///         If the calling method (e.g. execTransaction) received ETH this would revert otherwise
    function multiSend(bytes memory transactions) external payable {
        if (address(this) != msg.sender) revert CallProxyBadRole();
        _multiSend(transactions);
    }

    // we need to accept ETH from deBridgeGate
    receive() external payable {
    }

    /* ========== INTERNAL METHODS ========== */

    function _externalCall(
        address _destination,
        uint256 _value,
        bytes memory _data,
        bytes memory _nativeSender,
        uint256 _chainIdFrom,
        uint256 _flags
    ) internal returns (bool result) {
        bool storeSender = _flags.getFlag(Flags.PROXY_WITH_SENDER);
        bool checkGasLimit = _flags.getFlag(Flags.SEND_EXTERNAL_CALL_GAS_LIMIT);
        bool multisendFlag = _flags.getFlag(Flags.MULTI_SEND);
        // Temporary write to a storage nativeSender and chainIdFrom variables.
        // External contract can read them during a call if needed
        if (storeSender) {
            submissionChainIdFrom = _chainIdFrom;
            submissionNativeSender = _nativeSender;
        }

        uint256 safeTxGas;
        if (checkGasLimit && _data.length > 4) {
            safeTxGas = BytesLib.toUint32(_data, 0);

            // Remove first 4 bytes from data
            _data = BytesLib.slice(_data, 4, _data.length - 4);
        }

        // We require some gas to finish transaction emit the events, approve(0) etc (at least 15000) after the execution and some to perform code until the execution (500)
        // We also include the 1/64 in the check that is not send along with a call to counteract potential shortings because of EIP-150
        if (gasleft() < safeTxGas * 64 / 63 + 15500) revert NotEnoughSafeTxGas();
        // if safeTxGas is zero set gasleft
        safeTxGas = safeTxGas == 0 ? gasleft() : uint256(safeTxGas);

        if (multisendFlag) {
            _destination = address(this);
            assembly {
                result := call(safeTxGas, _destination, _value, add(_data, 0x20), mload(_data), 0, 0)
            }
        }
        // check if _destination is a contract;
        // this is crucial because the CALL opcode will succeed when arbitrary data is
        // called against EOA, causing undesired behavior and possible asset loss.
        // Thus, we allow calls only to contracts explicitly
        else if (_destination.isContract()) {
            assembly {
                result := call(safeTxGas, _destination, _value, add(_data, 0x20), mload(_data), 0, 0)
            }
        }
        // clear storage variables to get gas refund
        if (storeSender) {
            submissionChainIdFrom = 0;
            submissionNativeSender = "";
        }
    }

    function _customApprove(IERC20Upgradeable token, address spender, uint value) internal {
        bytes memory returndata = address(token).functionCall(
            abi.encodeWithSelector(token.approve.selector, spender, value),
            "ERC20 approve failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "ERC20 operation did not succeed");
        }
    }

    // ============ Version Control ============

     /// @dev Get this contract's version
    function version() external pure returns (uint256) {
        return 424; // 4.2.4
    }
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;






/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
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
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Pausable.sol)

pragma solidity ^0.8.0;





/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @debridge-finance/debridge-contracts-v1/contracts/periphery/DeBridgeToken.sol

pragma solidity ^0.8.7;






/// @dev ERC20 token that is used as wrapped asset to represent the native token value on the other chains.
contract DeBridgeToken is
    Initializable,
    AccessControlUpgradeable,
    ERC20PausableUpgradeable,
    IDeBridgeToken
{
    /// @dev Minter role identifier
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    /// @dev Pauser role identifier
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    /// @dev Domain separator as described in [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale)
    bytes32 public DOMAIN_SEPARATOR;
    /// @dev Typehash as described in [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale).
    /// =keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    /// @dev Transfers counter
    mapping(address => uint256) public nonces;
    /// @dev Asset's decimals
    uint8 internal _decimals;

    /* ========== ERRORS ========== */

    error MinterBadRole();
    error PauserBadRole();

    /* ========== MODIFIERS ========== */

    modifier onlyMinter() {
        if (!hasRole(MINTER_ROLE, msg.sender)) revert MinterBadRole();
        _;
    }

    modifier onlyPauser() {
        if (!hasRole(PAUSER_ROLE, msg.sender)) revert PauserBadRole();
        _;
    }

    /// @dev Constructor that initializes the most important configurations.
    /// @param name_ Asset's name.
    /// @param symbol_ Asset's symbol.
    /// @param decimals_ Asset's decimals.
    /// @param admin Address to set as asset's admin.
    /// @param minters The accounts allowed to int new tokens.
    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address admin,
        address[] memory minters
    ) public initializer {
        _decimals = decimals_;
        name_ = string(abi.encodePacked("deBridge ",
            bytes(name_).length == 0 ? symbol_ : name_));
        symbol_ = string(abi.encodePacked("de", symbol_));

        __ERC20_init_unchained(name_, symbol_);

        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(PAUSER_ROLE, admin);
        uint256 mintersCount = minters.length;
        for (uint256 i = 0; i < mintersCount; i++) {
            _setupRole(MINTER_ROLE, minters[i]);
        }

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name_)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    /// @inheritdoc IDeBridgeToken
    function mint(address _receiver, uint256 _amount) external override onlyMinter {
        _mint(_receiver, _amount);
    }

    /// @inheritdoc IDeBridgeToken
    function burn(uint256 _amount) external override onlyMinter {
        _burn(msg.sender, _amount);
    }

    /// @dev Approves the spender by signature.
    /// @param _owner Token's owner.
    /// @param _spender Account to be approved.
    /// @param _value Amount to be approved.
    /// @param _deadline The permit valid until.
    /// @param _v Signature part.
    /// @param _r Signature part.
    /// @param _s Signature part.
    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        require(_deadline >= block.timestamp, "permit: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        _owner,
                        _spender,
                        _value,
                        nonces[_owner]++,
                        _deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, _v, _r, _s);
        require(
            recoveredAddress != address(0) && recoveredAddress == _owner,
            "permit: invalid signature"
        );
        _approve(_owner, _spender, _value);
    }

    /// @dev Asset's decimals
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /// @dev Pauses all token transfers. The caller must have the `PAUSER_ROLE`.
    function pause() public onlyPauser {
        _pause();
    }

     /// @dev Unpauses all token transfers. The caller must have the `PAUSER_ROLE`.
    function unpause() public onlyPauser {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
    }
}

// File: @openzeppelin/contracts/proxy/beacon/IBeacon.sol

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

// File: @openzeppelin/contracts/proxy/Proxy.sol

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

// File: @openzeppelin/contracts/interfaces/draft-IERC1822.sol

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

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
}

// File: @openzeppelin/contracts/utils/StorageSlot.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
 * ```
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
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
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
}

// File: @openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol

// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;






/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

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
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
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
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
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
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

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
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

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
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// File: @openzeppelin/contracts/proxy/beacon/BeaconProxy.sol

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;





/**
 * @dev This contract implements a proxy that gets the implementation address for each call from an {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializing the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/periphery/DeBridgeTokenProxy.sol

pragma solidity ^0.8.7;



/// @dev This contract implements a proxy that gets the implementation address for each call
/// from DeBridgeTokenDeployer. It's deployed by DeBridgeTokenDeployer.
/// Implementation is DeBridgeToken.
contract DeBridgeTokenProxy is BeaconProxy {
    constructor(address beacon, bytes memory data) BeaconProxy(beacon, data) {

    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/transfers/DeBridgeTokenDeployer.sol

pragma solidity ^0.8.7;








/// @dev Deploys a deToken(DeBridgeTokenProxy) for an asset.
contract DeBridgeTokenDeployer is
    Initializable,
    AccessControlUpgradeable,
    IDeBridgeTokenDeployer
{

    /* ========== STATE VARIABLES ========== */

    /// @dev Address of deBridgeToken implementation
    address public tokenImplementation;
    /// @dev An addres to set as admin for any deployed deBridgeToken
    address public deBridgeTokenAdmin;
    /// @dev Debridge gate address
    address public debridgeAddress;
    /// @dev Maps debridge id to deBridgeToken address
    mapping(bytes32 => address) public getDeployedAssetAddress;
    /// @dev Maps debridge id to overridden token info (name, symbol). Used when autogenerated
    /// values for a token are not ideal.
    mapping(bytes32 => OverridedTokenInfo) public overridedTokens;

    /* ========== STRUCTS ========== */

    struct OverridedTokenInfo {
        bool accept;
        string name;
        string symbol;
    }

    /* ========== ERRORS ========== */

    error WrongArgument();
    error DeployedAlready();

    error AdminBadRole();
    error DeBridgeGateBadRole();


    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    modifier onlyDeBridgeGate() {
        if (msg.sender != debridgeAddress) revert DeBridgeGateBadRole();
        _;
    }


    /* ========== CONSTRUCTOR  ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {
    }

    /// @dev Constructor that initializes the most important configurations.
    /// @param _tokenImplementation Address of deBridgeToken implementation
    /// @param _deBridgeTokenAdmin Address to set as admin for any deployed deBridgeToken
    /// @param _debridgeAddress DeBridge gate address
    function initialize(
        address _tokenImplementation,
        address _deBridgeTokenAdmin,
        address _debridgeAddress
    ) public initializer {
        tokenImplementation = _tokenImplementation;
        deBridgeTokenAdmin = _deBridgeTokenAdmin;
        debridgeAddress = _debridgeAddress;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @dev Deploy a deToken for an asset
    /// @param _debridgeId Asset identifier
    /// @param _name Asset name
    /// @param _symbol Asset symbol
    /// @param _decimals Asset decimals
    function deployAsset(
        bytes32 _debridgeId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals)
        external
        override
        onlyDeBridgeGate
        returns (address deBridgeTokenAddress)
    {
        if (getDeployedAssetAddress[_debridgeId] != address(0)) revert DeployedAlready();

        OverridedTokenInfo memory overridedToken = overridedTokens[_debridgeId];
        if (overridedToken.accept) {
            _name = overridedToken.name;
            _symbol = overridedToken.symbol;
        }

        address[] memory minters = new address[](1);
        minters[0] = debridgeAddress;

        // Initialize args
        bytes memory initialisationArgs = abi.encodeWithSelector(
            DeBridgeToken.initialize.selector,
            _name,
            _symbol,
            _decimals,
            deBridgeTokenAdmin,
            minters
        );

        // initialize Proxy
        bytes memory constructorArgs = abi.encode(address(this), initialisationArgs);

        // deployment code
        bytes memory bytecode = abi.encodePacked(type(DeBridgeTokenProxy).creationCode, constructorArgs);

        assembly {
        // debridgeId is a salt
            deBridgeTokenAddress := create2(0, add(bytecode, 0x20), mload(bytecode), _debridgeId)

            if iszero(extcodesize(deBridgeTokenAddress)) {
                revert(0, 0)
            }
        }

        getDeployedAssetAddress[_debridgeId] = deBridgeTokenAddress;
        emit DeBridgeTokenDeployed(
            deBridgeTokenAddress,
            _name,
            _symbol,
            _decimals
        );
    }

    /// @dev Beacon getter for the deBridgeToken contracts
    function implementation() public view returns (address) {
        return tokenImplementation;
    }


    /* ========== ADMIN ========== */

    /// @dev Set deBridgeToken implementation contract address
    /// @param _impl Wrapped asset implementation contract address.
    function setTokenImplementation(address _impl) external onlyAdmin {
        if (_impl == address(0)) revert WrongArgument();
        tokenImplementation = _impl;
    }

    /// @dev Set admin for any deployed deBridgeToken.
    /// @param _deBridgeTokenAdmin Admin address.
    function setDeBridgeTokenAdmin(address _deBridgeTokenAdmin) external onlyAdmin {
        if (_deBridgeTokenAdmin == address(0)) revert WrongArgument();
        deBridgeTokenAdmin = _deBridgeTokenAdmin;
    }

    /// @dev Sets core debridge contract address.
    /// @param _debridgeAddress Debridge address.
    function setDebridgeAddress(address _debridgeAddress) external onlyAdmin {
        if (_debridgeAddress == address(0)) revert WrongArgument();
        debridgeAddress = _debridgeAddress;
    }

    /// @dev Override specific tokens name/symbol
    /// @param _debridgeIds Array of debridgeIds for tokens
    /// @param _tokens Array of new name/symbols for tokens
    function setOverridedTokenInfo (
        bytes32[] memory _debridgeIds,
        OverridedTokenInfo[] memory _tokens
    ) external onlyAdmin {
        if (_debridgeIds.length != _tokens.length) revert WrongArgument();
        for (uint256 i = 0; i < _debridgeIds.length; i++) {
            overridedTokens[_debridgeIds[i]] = _tokens[i];
        }
    }

    // ============ Version Control ============
    /// @dev Get this contract's version
    function version() external pure returns (uint256) {
        return 111; // 1.1.1
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/transfers/OraclesManager.sol

pragma solidity ^0.8.7;





/// @dev The base contract for oracles management. Allows adding/removing oracles,
/// managing the minimal required amount of confirmations.
contract OraclesManager is Initializable, AccessControlUpgradeable, IOraclesManager {
    /* ========== STATE VARIABLES ========== */

    /// @dev Minimal required confirmations
    uint8 public minConfirmations;
    /// @dev Minimal required confirmations in case of too many confirmations
    uint8 public excessConfirmations;
    /// @dev Count of required oracles
    uint8 public requiredOraclesCount;
    /// @dev Oracle addresses
    address[] public oracleAddresses;
    /// @dev Maps an oracle address to the oracle details
    mapping(address => OracleInfo) public getOracleInfo;

    /* ========== ERRORS ========== */

    error AdminBadRole();
    error OracleBadRole();

    error OracleAlreadyExist();
    error OracleNotFound();

    error WrongArgument();
    error LowMinConfirmations();


    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }
    modifier onlyOracle() {
        if (!getOracleInfo[msg.sender].isValid) revert OracleBadRole();
        _;
    }

    /* ========== CONSTRUCTOR  ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {
    }
    
    /// @dev Constructor that initializes the most important configurations.
    /// @param _minConfirmations Minimal required confirmations.
    /// @param _excessConfirmations Minimal required confirmations in case of too many confirmations.
    function initialize(uint8 _minConfirmations, uint8 _excessConfirmations) internal {
        if (_minConfirmations == 0 || _excessConfirmations < _minConfirmations) revert LowMinConfirmations();
        minConfirmations = _minConfirmations;
        excessConfirmations = _excessConfirmations;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /* ========== ADMIN ========== */

    /// @dev Sets minimal required confirmations.
    /// @param _minConfirmations Minimal required confirmations.
    function setMinConfirmations(uint8 _minConfirmations) external onlyAdmin {
        if (_minConfirmations < oracleAddresses.length / 2 + 1) revert LowMinConfirmations();
        minConfirmations = _minConfirmations;
    }

    /// @dev Sets minimal required confirmations in case of too many confirmations.
    /// @param _excessConfirmations Minimal required confirmations in case of too many confirmations.
    function setExcessConfirmations(uint8 _excessConfirmations) external onlyAdmin {
        if (_excessConfirmations < minConfirmations) revert LowMinConfirmations();
        excessConfirmations = _excessConfirmations;
    }

    /// @dev Add oracles.
    /// @param _oracles Oracles' addresses.
    /// @param _required A transfer will not be confirmed without oracles having required set to true,
    function addOracles(
        address[] memory _oracles,
        bool[] memory _required
    ) external onlyAdmin {
        if (_oracles.length != _required.length) revert WrongArgument();
        if (minConfirmations < (oracleAddresses.length +  _oracles.length) / 2 + 1) revert LowMinConfirmations();

        for (uint256 i = 0; i < _oracles.length; i++) {
            OracleInfo storage oracleInfo = getOracleInfo[_oracles[i]];
            if (oracleInfo.exist) revert OracleAlreadyExist();

            oracleAddresses.push(_oracles[i]);

            if (_required[i]) {
                requiredOraclesCount += 1;
            }

            oracleInfo.exist = true;
            oracleInfo.isValid = true;
            oracleInfo.required = _required[i];

            emit AddOracle(_oracles[i], _required[i]);
        }
    }

    /// @dev Update an oracle.
    /// @param _oracle An oracle address.
    /// @param _isValid Is this oracle valid, i.e. should it be treated as an oracle.
    /// @param _required If set to true a transfer will not be confirmed without this oracle.
    function updateOracle(
        address _oracle,
        bool _isValid,
        bool _required
    ) external onlyAdmin {
        //If oracle is invalid, it must be not required
        if (!_isValid && _required) revert WrongArgument();

        OracleInfo storage oracleInfo = getOracleInfo[_oracle];
        if (!oracleInfo.exist) revert OracleNotFound();

        if (oracleInfo.required && !_required) {
            requiredOraclesCount -= 1;
        } else if (!oracleInfo.required && _required) {
            requiredOraclesCount += 1;
        }
        if (oracleInfo.isValid && !_isValid) {
            // remove oracle from oracleAddresses array without keeping an order
            for (uint256 i = 0; i < oracleAddresses.length; i++) {
                if (oracleAddresses[i] == _oracle) {
                    oracleAddresses[i] = oracleAddresses[oracleAddresses.length - 1];
                    oracleAddresses.pop();
                    break;
                }
            }
        } else if (!oracleInfo.isValid && _isValid) {
            if (minConfirmations < (oracleAddresses.length + 1) / 2 + 1) revert LowMinConfirmations();
            oracleAddresses.push(_oracle);
        }
        oracleInfo.isValid = _isValid;
        oracleInfo.required = _required;
        emit UpdateOracle(_oracle, _required, _isValid);
    }
}

// File: @debridge-finance/debridge-contracts-v1/contracts/transfers/SignatureVerifier.sol

pragma solidity ^0.8.7;





/// @dev It's used to verify that a transfer is signed by oracles.
contract SignatureVerifier is OraclesManager, ISignatureVerifier {
    using SignatureUtil for bytes;
    using SignatureUtil for bytes32;

    /* ========== STATE VARIABLES ========== */
    /// @dev Number of required confirmations per block after the extra check is enabled
    uint8 public confirmationThreshold;
    /// @dev submissions count in current block
    uint40 public submissionsInBlock;
    /// @dev Current block
    uint40 public currentBlock;

    /// @dev Debridge gate address
    address public debridgeAddress;

    /* ========== ERRORS ========== */

    error DeBridgeGateBadRole();
    error NotConfirmedByRequiredOracles();
    error NotConfirmedThreshold();
    error SubmissionNotConfirmed();
    error DuplicateSignatures();

    /* ========== MODIFIERS ========== */

    modifier onlyDeBridgeGate() {
        if (msg.sender != debridgeAddress) revert DeBridgeGateBadRole();
        _;
    }

    /* ========== CONSTRUCTOR  ========== */

    /// @dev Constructor that initializes the most important configurations.
    /// @param _minConfirmations Common confirmations count.
    /// @param _confirmationThreshold Confirmations per block after the extra check is enabled.
    /// @param _excessConfirmations Confirmations count in case of excess activity.
    function initialize(
        uint8 _minConfirmations,
        uint8 _confirmationThreshold,
        uint8 _excessConfirmations,
        address _debridgeAddress
    ) public initializer {
        OraclesManager.initialize(_minConfirmations, _excessConfirmations);
        confirmationThreshold = _confirmationThreshold;
        debridgeAddress = _debridgeAddress;
    }


    /// @inheritdoc ISignatureVerifier
    function submit(
        bytes32 _submissionId,
        bytes memory _signatures,
        uint8 _excessConfirmations
    ) external override onlyDeBridgeGate {
        //Need confirmation to confirm submission
        uint8 needConfirmations = _excessConfirmations > minConfirmations
            ? _excessConfirmations
            : minConfirmations;
        // Count of required(DSRM) oracles confirmation
        uint256 currentRequiredOraclesCount;
        // stack variable to aggregate confirmations and write to storage once
        uint8 confirmations;
        uint256 signaturesCount = _countSignatures(_signatures);
        address[] memory validators = new address[](signaturesCount);
        for (uint256 i = 0; i < signaturesCount; i++) {
            (bytes32 r, bytes32 s, uint8 v) = _signatures.parseSignature(i * 65);
            address oracle = ecrecover(_submissionId.getUnsignedMsg(), v, r, s);
            if (getOracleInfo[oracle].isValid) {
                for (uint256 k = 0; k < i; k++) {
                    if (validators[k] == oracle) revert DuplicateSignatures();
                }
                validators[i] = oracle;

                confirmations += 1;
                emit Confirmed(_submissionId, oracle);
                if (getOracleInfo[oracle].required) {
                    currentRequiredOraclesCount += 1;
                }
                if (
                    confirmations >= needConfirmations &&
                    currentRequiredOraclesCount >= requiredOraclesCount
                ) {
                    break;
                }
            }
        }

        if (currentRequiredOraclesCount != requiredOraclesCount)
            revert NotConfirmedByRequiredOracles();

        if (confirmations >= minConfirmations) {
            if (currentBlock == uint40(block.number)) {
                submissionsInBlock += 1;
            } else {
                currentBlock = uint40(block.number);
                submissionsInBlock = 1;
            }
            emit SubmissionApproved(_submissionId);
        }

        if (submissionsInBlock > confirmationThreshold) {
            if (confirmations < excessConfirmations) revert NotConfirmedThreshold();
        }

        if (confirmations < needConfirmations) revert SubmissionNotConfirmed();
    }

    /* ========== ADMIN ========== */

    /// @dev Sets minimal required confirmations.
    /// @param _confirmationThreshold Confirmation info.
    function setThreshold(uint8 _confirmationThreshold) external onlyAdmin {
        if (_confirmationThreshold == 0) revert WrongArgument();
        confirmationThreshold = _confirmationThreshold;
    }

    /// @dev Sets core debridge conrtact address.
    /// @param _debridgeAddress Debridge address.
    function setDebridgeAddress(address _debridgeAddress) external onlyAdmin {
        debridgeAddress = _debridgeAddress;
    }

    /* ========== VIEW ========== */

    /// @dev Check is valid signature
    /// @param _submissionId Submission identifier.
    /// @param _signature signature by oracle.
    function isValidSignature(bytes32 _submissionId, bytes memory _signature)
        external
        view
        returns (bool)
    {
        (bytes32 r, bytes32 s, uint8 v) = _signature.splitSignature();
        address oracle = ecrecover(_submissionId.getUnsignedMsg(), v, r, s);
        return getOracleInfo[oracle].isValid;
    }

    /* ========== INTERNAL ========== */

    function _countSignatures(bytes memory _signatures) internal pure returns (uint256) {
        return _signatures.length % 65 == 0 ? _signatures.length / 65 : 0;
    }

    // ============ Version Control ============
    /// @dev Get this contract's version
    function version() external pure returns (uint256) {
        return 202; // 2.0.2
    }
}

// File: @openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol

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

// File: @openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.0;



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
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/interfaces/IExternalCallAdapter.sol

pragma solidity ^0.8.0;


/**
 * @title Interface for interactor which acts after `fullfill Order` transfers.
 * @notice DLN Destincation contract call receiver contract with information about order
*/
interface IExternalCallAdapter {
    /**
     * @notice Callback method that gets called after maker funds transfers
     * @param _orderId Hash of the order being processed
     * @param _callAuthority Address that can cancel external call and send tokens to fallback address
     * @param _tokenAddress  token that was transferred to adapter
     * @param _transferredAmount Actual amount that was transferred to adapter
     * @param _externalCall call data
     * @param _externalCallRewardBeneficiary Reward beneficiary address that will receiv execution fee. If address is 0 will not execute external call.
     */
    function receiveCall(
        bytes32 _orderId,
        address _callAuthority,
        address _tokenAddress,
        uint256 _transferredAmount,
        bytes calldata _externalCall,
        address _externalCallRewardBeneficiary
    ) external;
}

// File: contracts/libraries/EncodeSolanaDlnMessage.sol

pragma solidity ^0.8.7;

library EncodeSolanaDlnMessage {
    bytes8 public constant CLAIM_DESCRIMINATOR = 0x5951b44f8e9042fb;
    bytes8 public constant CANCEL_DESCRIMINATOR = 0x13617eeecc8d454c;

    function encodeInitWalletIfNeededInstruction(
        bytes32 _actionBeneficiary,
        bytes32 _orderGiveTokenAddress,
        uint64 _reward
    ) internal pure returns (bytes memory encodedData) {
        encodedData = abi.encodePacked(
            // Index 0: Field (8): Reward 1:
            // convert to Little Endian
            reverse(_reward),
            // Index 8: Const (86): "01f01d1f0000000000000000000101000000000000000100000000000000010000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f8590300000000000000000000002000000000000000"
            hex"01f01d1f0000000000000000000101000000000000000100000000000000010000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f8590300000000000000000000002000000000000000",
            // Index 94: Field (32): Action Beneficiary
            _actionBeneficiary,
            // Index 126: Const (56): "00000000200000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a9000000002000000000000000"
            hex"00000000200000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a9000000002000000000000000",
            // Index 182: Field (32): Give Token Address
            _orderGiveTokenAddress,
            // Index 214: Const (110): "00008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f85906000000000000001968562fef0aab1b1d8f99d44306595cd4ba41d7cc899c007a774d23ad702ff601019f3d96f657370bf1dbb3313efba51ea7a08296ac33d77b949e1b62d538db37f20001"
            hex"00008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f85906000000000000001968562fef0aab1b1d8f99d44306595cd4ba41d7cc899c007a774d23ad702ff601019f3d96f657370bf1dbb3313efba51ea7a08296ac33d77b949e1b62d538db37f20001",
            // Index 324: Field (32): Action Beneficiary
            _actionBeneficiary,
            // Index 356: Const (2): "0000"
            hex"0000",
            // Index 358: Field (32): Give Token Address
            _orderGiveTokenAddress,
            // Index 390: Const (79): "00000000000000000000000000000000000000000000000000000000000000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a90000010000000000000001"
            hex"00000000000000000000000000000000000000000000000000000000000000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a90000010000000000000001"
        );
    }

    function encodeClaimUnlockInstruction(
        uint256 _takeChainId,
        bytes32 _srcProgramId,
        bytes32 _actionBeneficiary,
        bytes32 _orderGiveTokenAddress,
        bytes32 _orderId,
        uint64 _reward2
    ) internal pure returns (bytes memory encodedClaimData) {
        return
            _encodeCall(
                _takeChainId,
                _srcProgramId,
                _actionBeneficiary,
                _orderGiveTokenAddress,
                _orderId,
                _reward2,
                CLAIM_DESCRIMINATOR
            );
    }

    function encodeClaimCancelInstruction(
        uint256 _takeChainId,
        bytes32 _srcProgramId,
        bytes32 _actionBeneficiary,
        bytes32 _orderGiveTokenAddress,
        bytes32 _orderId,
        uint64 _reward2
    ) internal pure returns (bytes memory encodedClaimData) {
        return
            _encodeCall(
                _takeChainId,
                _srcProgramId,
                _actionBeneficiary,
                _orderGiveTokenAddress,
                _orderId,
                _reward2,
                CANCEL_DESCRIMINATOR
            );
    }

    function _encodeCall(
        uint256 _takeChainId,
        bytes32 _srcProgramId,
        bytes32 _actionBeneficiary,
        bytes32 _orderGiveTokenAddress,
        bytes32 _orderId,
        uint64 _reward2,
        bytes8 _discriminator
    ) private pure returns (bytes memory encodedData) {
        {
            encodedData = abi.encodePacked(
                // Index 469: Field (8): Reward 2:
                // convert to Little Endian
                reverse(_reward2),
                // Index 477: Const (26): "0000000000010700000000000000020000000000000001000000"
                hex"0000000000010700000000000000020000000000000001000000",
                // Index 503: Field (32): Program Id
                _srcProgramId,
                // Index 535: Const (38): "0100000000000000000000000500000000000000535441544500030000000000000001000000"
                hex"0100000000000000000000000500000000000000535441544500030000000000000001000000",
                // Index 573: Field (32): Program Id
                _srcProgramId,
                // Index 605: Const (43): "0100000000000000000000000a00000000000000464545204c454447455200040000000000000001000000"
                hex"0100000000000000000000000a00000000000000464545204c454447455200040000000000000001000000",
                // Index 648: Field (32): Program Id
                _srcProgramId,
                // Index 680: Const (49): "02000000000000000000000011000000000000004645455f4c45444745525f57414c4c4554000000002000000000000000"
                hex"02000000000000000000000011000000000000004645455f4c45444745525f57414c4c4554000000002000000000000000",
                // Index 729: Field (32): Give Token Address
                _orderGiveTokenAddress,
                // Index 761: Const (13): "00060000000000000001000000"
                hex"00060000000000000001000000",
                // Index 774: Field (32): Program Id
                _srcProgramId,
                // Index 806: Const (48): "0200000000000000000000001000000000000000474956455f4f524445525f5354415445000000002000000000000000"
                hex"0200000000000000000000001000000000000000474956455f4f524445525f5354415445000000002000000000000000",
                // Index 854: Field (32): Order Id
                _orderId,
                // Index 886: Const (65): "000700000000000000010000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f8590300000000000000000000002000000000000000"
                hex"000700000000000000010000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f8590300000000000000000000002000000000000000",
                // Index 951: Field (32): Action Beneficiary
                _actionBeneficiary,
                // Index 983: Const (56): "00000000200000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a9000000002000000000000000"
                hex"00000000200000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a9000000002000000000000000",
                 // Index 1039: Field (32): Give Token Address
                _orderGiveTokenAddress,
                // Index 1071: Const (13): "00090000000000000001000000"
                hex"00090000000000000001000000",
                 // Index 1084: Field (32): Program Id
                _srcProgramId
            );
        }
        {
            encodedData = abi.encodePacked(
                encodedData,
                // Index 1116: Const (49): "0200000000000000000000001100000000000000474956455f4f524445525f57414c4c4554000000002000000000000000"
                hex"0200000000000000000000001100000000000000474956455f4f524445525f57414c4c4554000000002000000000000000",
                // Index 1165: Field (32): Order Id
                _orderId,
                // Index 1197: Const (13): "000b0000000000000001000000"
                hex"000b0000000000000001000000",
                // Index 1210: Field (32): Program Id
                _srcProgramId,
                // Index 1242: Const (56): "0200000000000000000000001800000000000000415554484f52495a45445f4e41544956455f53454e444552000000002000000000000000"
                hex"0200000000000000000000001800000000000000415554484f52495a45445f4e41544956455f53454e444552000000002000000000000000",
                // Index 1298: Field (32): Take Chain Id
                _takeChainId,
                // Index 1330: Const (2): "0000"
                hex"0000",
                // Index 1332: Field (32): Program Id
                _srcProgramId,
                // Index 1364: Const (280): "0d0000000000000062584959deb8a728a91cebdc187b545d920479265052145f31fb80c73fac5aea00001968562fef0aab1b1d8f99d44306595cd4ba41d7cc899c007a774d23ad702ff60101980176896e24d940ee6f0a89d0020e1cd53aa3d17be42270bb39223f6ed75c6300018c6ecc336484fb8f32871d3c1656d832cc86eb2465048fea348cde76ae57233100014026e8772b7640ce6fb9fd348473f43df344e3dcd89a43c93db81ee6efe08e67000106a7d517187bd16635dad40455fdc2c0c124c68f215675a5dbbacb5f080000000000107fe6a33e564217c5773c604a479581564c5e4c12465d65c9374ee2190f5ee400019f3d96f657370bf1dbb3313efba51ea7a08296ac33d77b949e1b62d538db37f20001"
                hex"0d0000000000000062584959deb8a728a91cebdc187b545d920479265052145f31fb80c73fac5aea00001968562fef0aab1b1d8f99d44306595cd4ba41d7cc899c007a774d23ad702ff60101980176896e24d940ee6f0a89d0020e1cd53aa3d17be42270bb39223f6ed75c6300018c6ecc336484fb8f32871d3c1656d832cc86eb2465048fea348cde76ae57233100014026e8772b7640ce6fb9fd348473f43df344e3dcd89a43c93db81ee6efe08e67000106a7d517187bd16635dad40455fdc2c0c124c68f215675a5dbbacb5f080000000000107fe6a33e564217c5773c604a479581564c5e4c12465d65c9374ee2190f5ee400019f3d96f657370bf1dbb3313efba51ea7a08296ac33d77b949e1b62d538db37f20001",
                // Index 1644: Field (32): Action Beneficiary
                _actionBeneficiary,
                // Index 1676: Const (36): "00011507b8f891ebbfc57577d4d2e6a2b52dc0a744eba2be503e686d0d07d19e6ec70001"
                hex"00011507b8f891ebbfc57577d4d2e6a2b52dc0a744eba2be503e686d0d07d19e6ec70001",
                // Index 1712: Field (32): Give Token Address
                _orderGiveTokenAddress,
                // Index 1744: Const (78): "0000efe9c4afa6dc798a27b0c18e3cf0b76ad3fe8cc93764f6cb3112f9397f2cd1c6000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a900002800000000000000"
                hex"0000efe9c4afa6dc798a27b0c18e3cf0b76ad3fe8cc93764f6cb3112f9397f2cd1c6000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a900002800000000000000",
                // Index 1822: Field (8): Discriminator
                _discriminator,
                // Index 1830: Field (32): Order Id
                _orderId
            );
        }
        return encodedData;
    }

    function reverse(uint64 input) private pure returns (uint64 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00FF00FF00) >> 8) | ((v & 0x00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v = ((v & 0xFFFF0000FFFF0000) >> 16) | ((v & 0x0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v = (v >> 32) | (v << 32);
    }
}

// File: contracts/interfaces/IDlnDestination.sol

pragma solidity ^0.8.7;


interface IDlnDestination {
    /**
     * @dev Executes the order fulfillment process for the provided order.
     *
     * @notice This function executes the process of fulfilling an order within the DLN protocol.
     *         It conducts several validations like verifying if the order is on the correct chain,
     *         if the order IDs match, and if the status and amounts are correct. After the checks,
     *         the function proceeds to handle the transfer of the tokens from the `taker` (either native ETH or
     *         an ERC20 token) to the order's receiver.
     *         If a patch order was taken previously, the patch amount is deducted.
     *
     * @param _order The details of the order being fulfilled.
     * @param _fulFillAmount The amount the taker is fulfilling.
     * @param _orderId The unique identifier of the order.
     * @param _permitEnvelope The signed permit information for ERC20 token transfers.
     * @param _unlockAuthority The authority responsible for unlocking the order.
     *
     *
     * Emits a {FulfilledOrder} event.
     *
     * Requirements:
     * - The order's takeChainId must match the current chain's ID.
     * - The order's status must be `NotSet`.
     * - If the order has an allowed taker (allowedTakerDst), it must match the `_unlockAuthority`.
     * - The taker must provide the correct fulfillment amount.
     * - For ERC20 token transfers, a valid permit must be provided.
     */
    function fulfillOrder(
        DlnOrderLib.Order memory _order,
        uint256 _fulFillAmount,
        bytes32 _orderId,
        bytes calldata _permitEnvelope,
        address _unlockAuthority
    ) external payable;

    /**
     * @dev Executes the order fulfillment process for the provided order.
     *
     * @notice This function executes the process of fulfilling an order and execute external call
     *         within the DLN protocol.
     *         It conducts several validations like verifying if the order is on the correct chain,
     *         if the order IDs match, and if the status and amounts are correct. After the checks,
     *         the function proceeds to handle the transfer of the tokens from the `taker` (either native ETH or
     *         an ERC20 token) to the order's receiver.
     *         If a patch order was taken previously, the patch amount is deducted.
     *         If the order includes an external call and an
     *         `_externalCallRewardBeneficiary` is provided, the external call is executed.
     *
     * @param _order The details of the order being fulfilled.
     * @param _fulFillAmount The amount the taker is fulfilling.
     * @param _orderId The unique identifier of the order.
     * @param _permitEnvelope The signed permit information for ERC20 token transfers.
     * @param _unlockAuthority The authority responsible for unlocking the order.
     * @param _externalCallRewardBeneficiary The beneficiary for rewards from the external call.
     *
     * Emits a {FulfilledOrder} event.
     *
     * Requirements:
     * - The order must be on the correct chain.
     * - The order's takeChainId must match the current chain's ID.
     * - The order's status must be `NotSet`.
     * - If the order has an allowed taker (allowedTakerDst), it must match the `_unlockAuthority`.
     * - The taker must provide the correct fulfillment amount.
     * - For ERC20 token transfers, a valid permit must be provided.
     */
    function fulfillOrder(
        DlnOrderLib.Order memory _order,
        uint256 _fulFillAmount,
        bytes32 _orderId,
        bytes calldata _permitEnvelope,
        address _unlockAuthority,
        address _externalCallRewardBeneficiary
    ) external payable;
}

// File: contracts/DLN/DlnDestination.sol

pragma solidity ^0.8.17;












contract DlnDestination is DlnBase, ReentrancyGuardUpgradeable, IDlnDestination {
    using BytesLib for bytes;
    using Permit for address;

    /* ========== CONSTANTS ========== */
    uint32 constant MAX_UINT32 = 2**32 - 1;

    bytes32 public constant GOVERNANCE_DELEGATED_ORDER_CANCEL_ROLE =
        keccak256("GOVERNANCE_DELEGATED_ORDER_CANCEL_ROLE");

    /// @notice Amount divider to adjust native assets when transferring from EVM to Solana.
    /// @dev Solana supports u64 integers, unlike EVM which supports u256. This constant helps
    /// in adjusting amounts considering the difference in supported integer sizes, ensuring compatibility
    /// when transferring assets between the two chains. The adjustment takes into account EVM's 18 decimals
    /// against Solana's 8 decimals.
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    uint256 public immutable NATIVE_AMOUNT_DIVIDER_FOR_TRANSFER_TO_SOLANA;

    /* ========== STATE VARIABLES ========== */

    /// @dev Mapping of each chainId to the address of the dlnSource contract on that chain.
    mapping(uint256 => bytes) public dlnSourceAddresses;

    /// @dev Mapping of orderId to the state of the order.
    mapping(bytes32 => OrderTakeState) public takeOrders;

    /// @dev Storage for patches that subtract from `Order.takeAmount` during the `fulfillOrder` function call.
    /// Writing to this mapping is now deprecated but it is kept for backward compatibility as public getter.
    mapping(bytes32 => uint256) public takePatches;

    /// @dev The maximum number of orders allowed in a batch for unlocking on the EVM-based chain.
    uint256 public maxOrderCountPerBatchEvmUnlock;

    /// @dev Maximum number of orders allowed per batch for unlocking from EVM to Solana.
    uint256 public maxOrderCountPerBatchSolanaUnlock;

    /// @dev The address of the external call adapter contract responsible for executing external calls in orders.
    address public externalCallAdapter;

    /// @dev Reserved storage slot (previously subscriptionId, moved to base contract)
    uint32 private buf0;

    /* ========== ENUMS ========== */

    /**
     * @dev Enum defining the status of an order in take chain.
     * - `NotSet`: Indicates that the order is not yet set (0).
     * - `Fulfilled`: Indicates that the order has been fully filled (1).
     * - `SentUnlock`: Indicates that the unlock command for the order has been sent by the taker (2).
     * - `SentCancel`: Indicates that the order has been canceled (3).
     */
    enum OrderTakeStatus {
        NotSet, // 0
        Fulfilled, // 1
        SentUnlock, // 2
        SentCancel // 3
    }

    /* ========== STRUCTS ========== */

    /**
     * @dev Struct representing the state of order in "take" chain.
     *
     * - `status`: Indicates the status of the order, including whether it's fulfilled, unlock commands sent, or canceled.
     * - `takerAddress`: The address of the taker who claimed the order, responsible for fulfilling or canceling it.
     * - `giveChainId`: The chain ID associated with the "give" part of the order.
     */
    struct OrderTakeState {
        OrderTakeStatus status;
        address takerAddress;
        // use giveChainId it chainId less then uint32 max
        uint32 giveChainId;
        // use bigGiveChainId it chainId more then uint32 max
        uint256 bigGiveChainId;
    }

    /* ========== EVENTS ========== */

    event FulfilledOrder(
        DlnOrderLib.Order order, bytes32 orderId, uint256 actualFulfillAmount, address sender, address unlockAuthority
    );

    event SentOrderCancel(DlnOrderLib.Order order, bytes32 orderId, bytes cancelBeneficiary, bytes32 submissionId);

    event SentOrderUnlock(bytes32 orderId, bytes beneficiary, bytes32 submissionId);

    event SetDlnSourceAddress(uint256 chainIdFrom, bytes dlnSourceAddress, DlnOrderLib.ChainEngine chainEngine);

    event ExternalCallAdapterUpdated(address oldAdapter, address newAdapter);

    event MaxOrderCountPerBatchEvmUnlockChanged(uint256 oldValue, uint256 newValue);

    event MaxOrderCountPerBatchSolanaUnlockChanged(uint256 oldValue, uint256 newValue);

    /* ========== ERRORS ========== */

    /// @dev Thrown if the taker's amount for an order doesn't match the expected.
    error InsufficientTakerAmount();

    /// @dev Thrown if the receiver gets less than the order's required take amount.
    error InsufficientActualFulfillAmount(uint256 actualAmount, uint256 requiredAmount);

    /// @dev Thrown if native token amount (e.g., ETH) sent by the taker doesn't match
    /// the expected amount for order fulfillment.
    error MismatchNativeFulfillAmount();

    /// @dev Thrown if there's a `giveTokenAddress` mismatch among orders
    /// in a Solana batch unlock.
    error WrongToken();

    /// @dev Thrown if the order has a specified `allowedCancelBeneficiarySrc` and
    /// the provided `_cancelBeneficiary` argument during order cancellation does
    /// not match the expected beneficiary.
    error AllowOnlyForBeneficiary(bytes expectedBeneficiary);

    /// @dev Thrown if batch size of orders is either 0 or exceeds the max allowed
    /// order count for a batch unlock.
    error UnexpectedBatchSize();

    /// @dev Thrown if there's a `giveChainId` mismatch among orders in a batch unlock.
    error MismatchGiveChainId();

    /// @dev Thrown if the transferred amount doesn't cover fees. Ensures amount
    /// for fixed fees, transfer fees, execution fees, and Solana call rewards.
    error TransferAmountNotCoverFees();

    /// @dev Thrown if account with GOVERNANCE_DELEGATED_ORDER_CANCEL_ROLE attempted
    /// to cancel an order without a specified cancel beneficiary.
    error AttemptToCancelWithoutBeneficiary();

    /* ========== CONSTRUCTOR  ========== */

    constructor(uint divider, IDeBridgeGate _deBridgeGate, uint32 _subscriptionId) DlnBase(_deBridgeGate, _subscriptionId) {
        NATIVE_AMOUNT_DIVIDER_FOR_TRANSFER_TO_SOLANA =  divider;
    }

    /// @dev Constructor that initializes the most important configurations.
    function initialize() public initializer {
        __DlnBase_init();
        __ReentrancyGuard_init();
    }

    /* ========== PUBLIC METHODS ========== */

    /**
     * @inheritdoc IDlnDestination
     */
    function fulfillOrder(
        DlnOrderLib.Order memory _order,
        uint256 _fulFillAmount,
        bytes32 _orderId,
        bytes calldata _permitEnvelope,
        address _unlockAuthority
    ) external payable nonReentrant whenNotPaused {
        _fulfillOrder(
            _permitEnvelope,
            _order,
            _fulFillAmount,
            _orderId,
            _unlockAuthority,
            address(0)
        );
    }

    /**
     * @inheritdoc IDlnDestination
     */
    function fulfillOrder(
        DlnOrderLib.Order memory _order,
        uint256 _fulFillAmount,
        bytes32 _orderId,
        bytes calldata _permitEnvelope,
        address _unlockAuthority,
        address _externalCallRewardBeneficiary
    ) external payable nonReentrant whenNotPaused {
        _fulfillOrder(
            _permitEnvelope,
            _order,
            _fulFillAmount,
            _orderId,
            _unlockAuthority,
            _externalCallRewardBeneficiary
        );
    }

    function _fulfillOrder(
        bytes memory _permitEnvelope,
        DlnOrderLib.Order memory _order,
        uint256 _fulFillAmount,
        bytes32 _orderId,
        address _unlockAuthority,
        address _externalCallRewardBeneficiary
    ) internal {
        if (_order.takeChainId != getChainId()) revert WrongChain();
        bytes32 orderId = DlnOrderLib.getOrderId(_order);
        if (orderId != _orderId) revert MismatchedOrderId();
        OrderTakeState storage orderState = takeOrders[orderId];
        // in dst chain order will start from 0-NotSet
        if (orderState.status != OrderTakeStatus.NotSet) revert IncorrectOrderStatus();
        // Check that the given unlock authority equals allowedTakerDst if allowedTakerDst was set
        if (
            _order.allowedTakerDst.length > 0 &&
            BytesLib.toAddress(_order.allowedTakerDst, 0) != _unlockAuthority

        ) revert Unauthorized();

        // Check that the taker supplied at least the nominal order take amount.
        if (_fulFillAmount < _order.takeAmount) revert InsufficientTakerAmount();

        uint256 actualFulfillAmount = _fulFillAmount;
        //Avoid Stack too deep
        {
            address takeTokenAddress = _order.takeTokenAddress.toAddress();
            // Need to send token to call adapter if exist external call
            address tokenReceiver = _order.externalCall.length > 0
                ? externalCallAdapter
                : _order.receiverDst.toAddress();

            if (takeTokenAddress == address(0)) {
                if (msg.value != _fulFillAmount) revert MismatchNativeFulfillAmount();
                _safeTransferEthOrToken(address(0), tokenReceiver, _fulFillAmount);
            }
            else
            {
                takeTokenAddress.executePermit(_permitEnvelope);

                actualFulfillAmount = _safeTransferFrom(
                    takeTokenAddress,
                    msg.sender,
                    tokenReceiver,
                    _fulFillAmount,
                    false
                );
            }
        }

        // Check that the receiver actually received at least the order take amount.
        // This protects fills with taxable or rebasing tokens.
        if (actualFulfillAmount < _order.takeAmount) {
            revert InsufficientActualFulfillAmount(actualFulfillAmount, _order.takeAmount);
        }

        //change order state to FulFilled
        orderState.status = OrderTakeStatus.Fulfilled;
        orderState.takerAddress = _unlockAuthority;
        //gas optimisation to save in storage
        if (_order.giveChainId <= MAX_UINT32) {
            orderState.giveChainId = uint32(_order.giveChainId);
        }
        else {
             orderState.bigGiveChainId = _order.giveChainId;
        }
        if (_order.externalCall.length > 0) {
            IExternalCallAdapter(externalCallAdapter).receiveCall(
                orderId,
                _order.orderAuthorityAddressDst.toAddress(),
                _order.takeTokenAddress.toAddress(),
                actualFulfillAmount,
                _order.externalCall,
                _externalCallRewardBeneficiary
            );
        }
        emit FulfilledOrder(_order, orderId, actualFulfillAmount, msg.sender, _unlockAuthority);
    }

    /**
     * @dev Initiates the unlocking process for a single order's `give` part on an EVM chain.
     *
     * @notice This function is designed for unlocking assets on EVM chains for orders that have been filled.
     *         It prepares the state of an order for unlocking and sends a cross-chain message to the target
     *         chain indicated by the order's `giveChainId`. On the receiving chain, the `claim_unlock`
     *         method is expected to be called, completing the unlock process. The taker of the order is
     *         responsible for the execution fee, which is an incentive for the keepers to perform the
     *         unlock on the target chain.
     *
     * @param _orderId The unique identifier of the order that needs unlocking.
     * @param _beneficiary The recipient's address on the `giveChainId` where the assets will be unlocked to.
     * @param _executionFee The fee provided to incentivize the keepers to execute the unlock on the target chain.
     *
     * Emits a {SentOrderUnlock} event.
     *
     * Requirements:
     * - The function caller must be the taker of the order.
     */
    function sendEvmUnlock(
        bytes32 _orderId,
        address _beneficiary,
        uint256 _executionFee
    ) external payable nonReentrant whenNotPaused {
        uint256 giveChainId = _prepareOrderStateForUnlock(_orderId, DlnOrderLib.ChainEngine.EVM);
        // encode function that will be called in target chain
        bytes memory claimUnlockMethod = _encodeClaimUnlock(_orderId, _beneficiary);
        //send crosschain message through deBridgeGate
        bytes32 submissionId = _sendCrossChainMessage(
            giveChainId, // _chainIdTo
            abi.encodePacked(_beneficiary),
            _executionFee,
            claimUnlockMethod
        );

        emit SentOrderUnlock(_orderId, abi.encodePacked(_beneficiary), submissionId);
    }


    /**
     * @dev Sends a batch of unlock orders on the EVM chain based on their giveChainId.
     * @notice This method is used to unlock multiple orders that have been filled on the EVM chain,
     *         but haven't been unlocked yet. It sends a batch unlock request using the `_orderIds`
     *         provided. It's expected that all these orders share the same `giveChainId`.
     *         On the receiving chain, the `dln::source::claim_unlock` will be invoked.
     *
     * @param _orderIds Array of order IDs to unlock. All orders must have the same giveChainId.
     *        An order's giveChainId indicates the chain where the assets to be given reside.
     * @param _beneficiary Address that will receive the give amount on the give chain.
     * @param _executionFee Execution fee covering auto-claim by keepers.
     *
     * Emits a {SentOrderUnlock} event for each order in the batch.
     *
     * Requirements:
     * - Caller must be the taker of the order.
     * - The order IDs provided must not exceed the maximum allowed batch size.
     * - All the orders in the batch must have the same giveChainId.
     */
    function sendBatchEvmUnlock(
        bytes32[] memory _orderIds,
        address _beneficiary,
        uint256 _executionFee
    ) external payable nonReentrant whenNotPaused {
        if (_orderIds.length == 0) revert UnexpectedBatchSize();
        if (_orderIds.length > maxOrderCountPerBatchEvmUnlock) revert UnexpectedBatchSize();

        uint256 giveChainId;
        uint256 length = _orderIds.length;
        for (uint256 i; i < length; ++i) {
            uint256 currentGiveChainId = _prepareOrderStateForUnlock(_orderIds[i], DlnOrderLib.ChainEngine.EVM);
            if (i == 0) {
                giveChainId = currentGiveChainId;
            }
            else {
                // giveChainId must be the same for all orders
                if (giveChainId != currentGiveChainId) revert MismatchGiveChainId();
            }
        }
        // encode function that will be called in target chain
        bytes memory claimUnlockMethod = _encodeBatchClaimUnlock(_orderIds, _beneficiary);

        //send crosschain message through deBridgeGate
        bytes32 submissionId = _sendCrossChainMessage(
            giveChainId, // _chainIdTo
            abi.encodePacked(_beneficiary),
            _executionFee,
            claimUnlockMethod
        );

        for (uint256 i; i < length; ++i) {
            emit SentOrderUnlock(_orderIds[i], abi.encodePacked(_beneficiary), submissionId);
        }
    }

    /**
     * @dev Sends multiple claim_unlock instructions to unlock several orders that was created from the Solana blockchain and filled on EVM.
     * @notice Assumes all orders share the same giveChainId, giveTokenAddress, and beneficiary, so only one
     *         init_wallet_if_needed instruction is required. This batch function processes multiple orders in one transaction,
     *         generating cross-chain instructions to handle the unlocks on Solana.
     *
     * @param _orders Array of orders to unlock.
     * @param _beneficiary Address that will receive give amount in give chain.
     * @param _executionFee Execution fee for auto claim by keepers. This fee must cover a single _initWalletIfNeededInstructionReward
     *                     and _claimUnlockInstructionReward * number of orders in this batch.
     * @param _initWalletIfNeededInstructionReward Reward for executing the `init_wallet_if_needed` instruction on Solana.
     * @param _claimUnlockInstructionReward Reward for executing a single `claim_unlock` instruction on Solana. This method
     *                      sends as many claim_unlock instructions as the number of orders in this batch.
     *
     * Emits a {SentOrderUnlock} event for each order in the batch.
     *
     * Requirements:
     * - The caller must be the taker of each order.
     * - Rewards and fees for each order must validate against the sent Ether value.
     */
    function sendBatchSolanaUnlock(
        DlnOrderLib.Order[] memory _orders,
        bytes32 _beneficiary,
        uint256 _executionFee,
        uint64 _initWalletIfNeededInstructionReward,
        uint64 _claimUnlockInstructionReward
    ) external payable nonReentrant whenNotPaused {
        if (_orders.length == 0) revert UnexpectedBatchSize();
        if (_orders.length > maxOrderCountPerBatchSolanaUnlock) revert UnexpectedBatchSize();
        // make sure execution fee covers rewards for single account initialisation instruction + claim_unlock for every order
        _validateSolanaRewards(msg.value, _executionFee, _initWalletIfNeededInstructionReward, uint64(_claimUnlockInstructionReward * _orders.length));

        uint256 giveChainId;
        bytes32 giveTokenAddress;
        bytes32 solanaSrcProgramId;
        bytes memory instructionsData;
        bytes32[] memory orderIds = new bytes32[](_orders.length);
        for (uint256 i; i < _orders.length; ++i) {
            DlnOrderLib.Order memory order = _orders[i];
            bytes32 orderId = DlnOrderLib.getOrderIdWithExternalCallHash(order);
            orderIds[i] = orderId;
            _prepareOrderStateForUnlock(orderId, DlnOrderLib.ChainEngine.SOLANA);

            if (i == 0) {
                // pre-cache giveChainId of the first order in a batch to ensure all other orders have the same giveChainId
                giveChainId = order.giveChainId;

                // pre-cache giveTokenAddress of the first order in a batch to ensure all other orders have the same giveTokenAddress
                // also, this value is used heavily when encoding instructions
                giveTokenAddress = BytesLib.toBytes32(order.giveTokenAddress, 0);

                // pre-cache solanaSrcProgramId because this value is used when encoding instructions
                solanaSrcProgramId = BytesLib.toBytes32(dlnSourceAddresses[order.giveChainId], 0);

                // first instruction must be account initializer.
                // actually by design, we must initialize account for every giveTokenAddress+beneficiary pair,
                // but right for simplicity reasons we assume that batches may contain orders with the same giveTokenAddress,
                // so only a single initialization is required
                instructionsData = EncodeSolanaDlnMessage.encodeInitWalletIfNeededInstruction(
                    _beneficiary,
                    giveTokenAddress,
                    _initWalletIfNeededInstructionReward
                );
            }
            else {
                // ensure every order is from the same chain
                if (order.giveChainId != giveChainId) revert WrongChain();

                // ensure every order has the same giveTokenAddress (otherwise, we may need to ensure this account is initalized)
                if (BytesLib.toBytes32(order.giveTokenAddress, 0) != giveTokenAddress) revert WrongToken();
            }

            // finally, add claim_unlock instruction for this order
            instructionsData = abi.encodePacked(
                instructionsData,
                EncodeSolanaDlnMessage.encodeClaimUnlockInstruction(
                    getChainId(), //_takeChainId,
                    solanaSrcProgramId, //_srcProgramId,
                    _beneficiary, //_actionBeneficiary,
                    giveTokenAddress, //_orderGiveTokenAddress,
                    orderId,
                    _claimUnlockInstructionReward
                )
            );
        }

        // send crosschain message through deBridgeGate
        bytes32 submissionId = _sendCrossChainMessage(
            giveChainId, // _chainIdTo
            abi.encodePacked(_beneficiary),
            _executionFee,
            instructionsData
        );

        // emit event for every order
        for (uint256 i; i < _orders.length; ++i) {
            emit SentOrderUnlock(orderIds[i], abi.encodePacked(_beneficiary), submissionId);
        }
    }


    /**
     * @dev Unlocks a fulfilled order that was created from the Solana blockchain and filled on EVM.
     * Once an order is filled in EVM and not yet unlocked, the taker can call this function to unlock
     * and claim the order's give part on Solana. The function prepares cross-chain instructions
     * to handle the unlock on Solana.
     *
     * @param _order The order to be unlocked.
     * @param _beneficiary The recipient of the give amount in the Solana chain.
     * @param _executionFee Fee for the cross-chain execution by keepers.
     * @param _initWalletIfNeededInstructionReward Reward for executing the `init_wallet_if_needed` instruction on Solana.
     * @param _claimUnlockInstructionReward Reward for executing the `claim_unlock` instruction on Solana.
     *
     * Emits a {SentOrderUnlock} event.
     *
     * Requirements:
     * - The caller must be the taker of the order.
     * - Rewards and fees must validate against the sent Ether value.
     */
    function sendSolanaUnlock(
        DlnOrderLib.Order memory _order,
        bytes32 _beneficiary,
        uint256 _executionFee,
        uint64 _initWalletIfNeededInstructionReward,
        uint64 _claimUnlockInstructionReward
    ) external payable nonReentrant whenNotPaused {
        _validateSolanaRewards(msg.value, _executionFee, _initWalletIfNeededInstructionReward, _claimUnlockInstructionReward);
        bytes32 orderId = DlnOrderLib.getOrderIdWithExternalCallHash(_order);
        uint256 giveChainId = _prepareOrderStateForUnlock(orderId, DlnOrderLib.ChainEngine.SOLANA);

        // encode function that will be called in target chain
        bytes32 giveTokenAddress = BytesLib.toBytes32(_order.giveTokenAddress, 0);
        bytes memory instructionsData = abi.encodePacked(
            EncodeSolanaDlnMessage.encodeInitWalletIfNeededInstruction(
                    _beneficiary,
                    giveTokenAddress,
                    _initWalletIfNeededInstructionReward
            ),
            EncodeSolanaDlnMessage.encodeClaimUnlockInstruction(
                getChainId(), //_takeChainId,
                BytesLib.toBytes32(dlnSourceAddresses[giveChainId], 0), //_srcProgramId,
                _beneficiary, //_actionBeneficiary,
                giveTokenAddress, //_orderGiveTokenAddress,
                orderId,
                _claimUnlockInstructionReward
            )
        );
        //send crosschain message through deBridgeGate
        bytes32 submissionId = _sendCrossChainMessage(
            giveChainId, // _chainIdTo
            abi.encodePacked(_beneficiary),
            _executionFee,
            instructionsData
        );

        emit SentOrderUnlock(orderId, abi.encodePacked(_beneficiary), submissionId);
    }


    /**
     * @dev Cancels an order on the destination chain if it hasn't been filled or previously cancelled.
     * The order's authority address on the destination chain can call this function to reclaim the
     * locked funds. The function prepares cross-chain instructions for order cancellation.
     *
     * @param _order The full order details.
     * @param _cancelBeneficiary The recipient of the refund in the give chain.
     * @param _executionFee Fee for the cross-chain execution by keepers.
     *
     * Emits a {SentOrderCancel} event.
     *
     * Requirements:
     * - The caller must be the `order_authority_address_dst` of the order.
     * - The order's `takeChainId` must match the current chain ID.
     * - The order's `giveChainId` must be of type EVM.
     * - If specified, only the `allowed_cancel_beneficiary` can be the beneficiary.
     * - Order status must be `NotSet`.
     */
    function sendEvmOrderCancel(
        DlnOrderLib.Order memory _order,
        address _cancelBeneficiary,
        uint256 _executionFee
    ) external payable nonReentrant whenNotPaused {
        if (_order.takeChainId != getChainId()) revert WrongChain();
        if (chainEngines[_order.giveChainId] != DlnOrderLib.ChainEngine.EVM) revert WrongChain();

        _authorizeOrderCancellation(_order);

        if (_order.allowedCancelBeneficiarySrc.length > 0
            && _order.allowedCancelBeneficiarySrc.toAddress() != _cancelBeneficiary) {
            revert AllowOnlyForBeneficiary(_order.allowedCancelBeneficiarySrc);
        }

        bytes32 orderId = DlnOrderLib.getOrderId(_order);
        OrderTakeState storage orderState = takeOrders[orderId];
        //In dst chain order will start from 0-NotSet
        if (orderState.status != OrderTakeStatus.NotSet) revert IncorrectOrderStatus();
        orderState.status = OrderTakeStatus.SentCancel;

        // encode function that will be called in target chain
        bytes memory claimCancelMethod = _encodeClaimCancel(orderId, _cancelBeneficiary);
        //send crosschain message through deBridgeGate
        bytes32 submissionId = _sendCrossChainMessage(
            _order.giveChainId, // _chainIdTo
            abi.encodePacked(_cancelBeneficiary),
            _executionFee,
            claimCancelMethod
        );
        emit SentOrderCancel(_order, orderId, abi.encodePacked(_cancelBeneficiary), submissionId);
    }

    /**
     * @dev Sends a request to cancel an order on the Solana blockchain.
     * If an order hasn't been filled or canceled previously, the `orderAuthorityAddressDst`
     * can invoke this function to cancel it, thereby retrieving the 'give' part of the order
     * back on the Solana chain. Subsequently, the `dln::source::claim_order_cancel` function
     * will be triggered on the Solana side.
     *
     * @param _order The order details to be canceled.
     * @param _cancelBeneficiary The address designated to receive the refund on the Solana chain.
     *        If the order's `allowedCancelBeneficiarySrc` is unspecified, any address can be the beneficiary.
     *        However, if specified, only the mentioned address can be the beneficiary.
     * @param _executionFee Fee for executing the cancellation, typically claimed by keepers.
     * @param _initWalletIfNeededInstructionReward Reward for executing the `init_wallet_if_needed` instruction on Solana.
     * @param _claimCancelInstructionReward Reward for claiming the cancel instruction.
     *
     * Requirements:
     * - Caller must be the `orderAuthorityAddressDst` of the order.
     * - The order's `takeChainId` must match the current chain's ID.
     * - The `giveChainId` of the order must correspond to Solana.
     * - If `allowedCancelBeneficiarySrc` is specified in the order, it must match the provided `_cancelBeneficiary`.
     */
    function sendSolanaOrderCancel(
        DlnOrderLib.Order memory _order,
        bytes32 _cancelBeneficiary,
        uint256 _executionFee,
        uint64 _initWalletIfNeededInstructionReward,
        uint64 _claimCancelInstructionReward
    ) external payable nonReentrant whenNotPaused {
        _validateSolanaRewards(msg.value, _executionFee, _initWalletIfNeededInstructionReward, _claimCancelInstructionReward);

        if (chainEngines[_order.giveChainId] != DlnOrderLib.ChainEngine.SOLANA) revert WrongChain();
        if (_order.takeChainId != getChainId()) revert WrongChain();
        bytes memory solanaSrcProgramId = dlnSourceAddresses[_order.giveChainId];
        if (solanaSrcProgramId.length != SOLANA_ADDRESS_LENGTH) revert WrongChain();

        _authorizeOrderCancellation(_order);

        if (_order.allowedCancelBeneficiarySrc.length > 0
            && BytesLib.toBytes32(_order.allowedCancelBeneficiarySrc, 0) != _cancelBeneficiary) {
            revert AllowOnlyForBeneficiary(_order.allowedCancelBeneficiarySrc);
        }

        bytes32 orderId = DlnOrderLib.getOrderId(_order);
        OrderTakeState storage orderState = takeOrders[orderId];
        //In dst chain order will start from 0-NotSet
        if (orderState.status != OrderTakeStatus.NotSet) revert IncorrectOrderStatus();
        orderState.status = OrderTakeStatus.SentCancel;

        // encode function that will be called in target chain
        bytes32 _orderGiveTokenAddress = BytesLib.toBytes32(_order.giveTokenAddress, 0);
        bytes memory claimCancelMethod = abi.encodePacked(
            EncodeSolanaDlnMessage.encodeInitWalletIfNeededInstruction(
                    _cancelBeneficiary,
                    _orderGiveTokenAddress,
                    _initWalletIfNeededInstructionReward
            ),
            EncodeSolanaDlnMessage.encodeClaimCancelInstruction(
                getChainId(), //_takeChainId,
                BytesLib.toBytes32(solanaSrcProgramId, 0), //_srcProgramId,
                _cancelBeneficiary, //_actionBeneficiary,
                _orderGiveTokenAddress, //_orderGiveTokenAddress,
                orderId,
                _claimCancelInstructionReward
            )
        );
        //send crosschain message through deBridgeGate
        bytes32 submissionId = _sendCrossChainMessage(
            _order.giveChainId, // _chainIdTo
            abi.encodePacked(_cancelBeneficiary),
            _executionFee,
            claimCancelMethod
        );

        emit SentOrderCancel(_order, orderId, abi.encodePacked(_cancelBeneficiary), submissionId);
    }

    /* ========== ADMIN METHODS ========== */

    function setDlnSourceAddress(uint256 _chainIdFrom, bytes memory _dlnSourceAddress, DlnOrderLib.ChainEngine _chainEngine)
        external
        onlyAdmin
    {
        if(_chainEngine == DlnOrderLib.ChainEngine.UNDEFINED) revert WrongArgument();
        dlnSourceAddresses[_chainIdFrom] = _dlnSourceAddress;
        chainEngines[_chainIdFrom] = _chainEngine;
        emit SetDlnSourceAddress(_chainIdFrom, _dlnSourceAddress, _chainEngine);
    }

    function setExternalCallAdapter(address _externalCallAdapter)
        external
        onlyAdmin
    {
        address oldAdapter = externalCallAdapter;
        externalCallAdapter = _externalCallAdapter;
        emit ExternalCallAdapterUpdated(oldAdapter, externalCallAdapter);
    }

    function setMaxOrderCountsPerBatch(uint256 _newEvmCount, uint256 _newSolanaCount) external onlyAdmin {
        // Setting and emitting for EVM count
        uint256 oldEvmValue = maxOrderCountPerBatchEvmUnlock;
        maxOrderCountPerBatchEvmUnlock = _newEvmCount;
        if(oldEvmValue != _newEvmCount) {
            emit MaxOrderCountPerBatchEvmUnlockChanged(oldEvmValue, _newEvmCount);
        }

        // Setting and emitting for Solana count
        uint256 oldSolanaValue = maxOrderCountPerBatchSolanaUnlock;
        maxOrderCountPerBatchSolanaUnlock = _newSolanaCount;
        if(oldSolanaValue != _newSolanaCount) {
            emit MaxOrderCountPerBatchSolanaUnlockChanged(oldSolanaValue, _newSolanaCount);
        }
    }



    /* ==========  Private methods ========== */

    /**
     * @dev Change the order's status from "Fulfilled" to "SentUnlock".
     * @notice Only the taker of the order can call this.
     * @param _orderId The unique identifier of the order being processed.
     * @return Returns the 'giveChainId' from the order.
     */
    function _prepareOrderStateForUnlock(bytes32 _orderId, DlnOrderLib.ChainEngine _chainEngine) internal
        returns (uint256) {
        OrderTakeState storage orderState = takeOrders[_orderId];
        if (orderState.status != OrderTakeStatus.Fulfilled) revert IncorrectOrderStatus();
        if (orderState.takerAddress != msg.sender) revert Unauthorized();
        uint256 giveChainIdValue = orderState.giveChainId > 0
            ? uint256(orderState.giveChainId)
            : orderState.bigGiveChainId;
        if (chainEngines[giveChainIdValue] != _chainEngine) revert WrongChain();
        orderState.status = OrderTakeStatus.SentUnlock;
        return giveChainIdValue;
    }

    function _encodeClaimUnlock(bytes32 _orderId, address _beneficiary)
        internal
        pure
        returns (bytes memory)
    {
        //claimUnlock(bytes32 _orderId, address _beneficiary)
        return abi.encodeWithSelector(DlnSource.claimUnlock.selector, _orderId, _beneficiary);
    }

    function _encodeBatchClaimUnlock(bytes32[] memory _orderIds, address _beneficiary)
        internal
        pure
        returns (bytes memory)
    {
        //claimBatchUnlock(bytes32[] memory _orderIds, address _beneficiary)
        return abi.encodeWithSelector(DlnSource.claimBatchUnlock.selector, _orderIds, _beneficiary);
    }


    function _encodeClaimCancel(bytes32 _orderId, address _beneficiary)
        internal
        pure
        returns (bytes memory)
    {
        //claimCancel(bytes32 _orderId, address _beneficiary)
        return abi.encodeWithSelector(DlnSource.claimCancel.selector, _orderId, _beneficiary);
    }

    function _encodeAutoParamsTo(
        bytes memory _data,
        uint256 _executionFee,
        bytes memory _fallbackAddress
    ) internal pure returns (bytes memory) {
        IDeBridgeGate.SubmissionAutoParamsTo memory autoParams;
        autoParams.flags = Flags.setFlag(autoParams.flags, Flags.REVERT_IF_EXTERNAL_FAIL, true);
        autoParams.flags = Flags.setFlag(autoParams.flags, Flags.PROXY_WITH_SENDER, true);

        // fallbackAddress won't be used because of REVERT_IF_EXTERNAL_FAIL flag
        // also it make no sense to use it because it's only for ERC20 tokens
        // autoParams.fallbackAddress = abi.encodePacked(address(0));
        autoParams.fallbackAddress = _fallbackAddress;
        autoParams.data = _data;
        autoParams.executionFee = _executionFee;
        return abi.encode(autoParams);
    }

    /**
     * @dev Validates whether the provided amount is sufficient to cover all execution rewards.
     * @param _inputAmount Amount being transferred, which should cover the execution fee and all rewards.
     * @param _executionFee Fee required for the claim execution.
     * @param _solanaExternalCallReward1 Fee for executing the first external call on Solana.
     * @param _solanaExternalCallReward2 Fee for executing the second external call on Solana.
     */
    function _validateSolanaRewards (
        uint256 _inputAmount,
        uint256 _executionFee,
        uint64 _solanaExternalCallReward1,
        uint64 _solanaExternalCallReward2
    ) internal view {
        uint256 transferFeeBPS = deBridgeGate.globalTransferFeeBps();
        uint256 fixFee = deBridgeGate.globalFixedNativeFee();
        if (_inputAmount < fixFee) revert TransferAmountNotCoverFees();
        uint256 transferFee = transferFeeBPS * (_inputAmount - fixFee) / BPS_DENOMINATOR;
        uint256 divider = NATIVE_AMOUNT_DIVIDER_FOR_TRANSFER_TO_SOLANA;
        if (_inputAmount / divider < (fixFee + transferFee + _executionFee) / divider
                                                        + _solanaExternalCallReward1 + _solanaExternalCallReward2) {
            revert TransferAmountNotCoverFees();
        }
    }

    function _sendCrossChainMessage(
        uint256 _chainIdTo,
        bytes memory _fallbackAddress,
        uint256 _executionFee,
        bytes memory _data
    ) internal returns (bytes32) {
        bytes memory srcAddress = dlnSourceAddresses[_chainIdTo];
        bytes memory autoParams = _encodeAutoParamsTo(_data, _executionFee, _fallbackAddress);
        {
            DlnOrderLib.ChainEngine _targetEngine = chainEngines[_chainIdTo];

            if (_targetEngine == DlnOrderLib.ChainEngine.EVM ) {
                if (srcAddress.length != EVM_ADDRESS_LENGTH) revert DlnOrderLib.WrongAddressLength();
                if (_fallbackAddress.length != EVM_ADDRESS_LENGTH) revert DlnOrderLib.WrongAddressLength();
            }
            else if (_targetEngine == DlnOrderLib.ChainEngine.SOLANA ) {
                if (srcAddress.length != SOLANA_ADDRESS_LENGTH) revert DlnOrderLib.WrongAddressLength();
                if (_fallbackAddress.length != SOLANA_ADDRESS_LENGTH) revert DlnOrderLib.WrongAddressLength();
            }
            else {
                revert UnknownEngine();
            }
        }

        return deBridgeGate.send{value: msg.value}(
            address(0), // _tokenAddress
            msg.value, // _amount
            _chainIdTo, // _chainIdTo
            srcAddress, // _receiver
            "", // _permit
            false, // _useAssetFee
            0, // _referralCode
            autoParams // _autoParams
        );
    }

    function _authorizeOrderCancellation(DlnOrderLib.Order memory _order) internal view {
        // The order authority on the destination chain can cancel the order.
        if (msg.sender == _order.orderAuthorityAddressDst.toAddress()) return;

        // Accounts with GOVERNANCE_DELEGATED_ORDER_CANCEL_ROLE can cancel any
        // order, but only if allowedCancelBeneficiarySrc is set in the order.
        if (hasRole(GOVERNANCE_DELEGATED_ORDER_CANCEL_ROLE, msg.sender)) {
            if (_order.allowedCancelBeneficiarySrc.length == 0)
                revert AttemptToCancelWithoutBeneficiary();

            return;
        }

        revert Unauthorized();
    }

    /* ========== Version Control ========== */

    /// @dev Get this contract's version
    function version() external pure returns (string memory) {
        return "1.7.1";
    }
}

// File: contracts/IntentManagerValidator.sol

pragma solidity ^0.8.17;




/**
 * @title IntentManagerValidator
 * @dev Contract for validating intent manager permissions using OpenZeppelin AccessControl
 * This contract is not upgradeable and uses role-based access control
 */
contract IntentManagerValidator is AccessControl, IIntentManagerValidator {
    /// @dev Role identifier for intent managers
    bytes32 public constant INTENT_MANAGER_ROLE = keccak256("INTENT_MANAGER_ROLE");

    /**
     * @dev Constructor that sets up the initial admin
     * @param admin The address that will have the DEFAULT_ADMIN_ROLE
     */
    constructor(address admin) {
        if (admin == address(0)) {
            revert("IntentManagerValidator: admin cannot be zero address");
        }
        
        // Grant the admin role to the specified address
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /**
     * @inheritdoc IIntentManagerValidator
     */
    function validateIntentManager(address caller) external view override returns (bool isValid) {
        return hasRole(INTENT_MANAGER_ROLE, caller);
    }
}

// File: contracts/libraries/DlnExternalCallLib.sol

pragma solidity ^0.8.7;

library DlnExternalCallLib {
    struct ExternalCallEnvelopV1 {
        // Address that will receive takeToken if ext call failed
        address fallbackAddress;
        // *optional. Smart contract that will execute ext call.
        address executorAddress;
        // fee that will pay for executor who will execute ext call
        uint160 executionFee;
        // If false, the taker must execute an external call with fulfill in a single transaction.
        bool allowDelayedExecution;
        // if true transaction that will execute ext call will fail if ext call is not success
        bool requireSuccessfullExecution;
        bytes payload;
    }

    struct ExternalCallPayload {
        // the address of the contract to call
        address to;
        // *optional. Tx gas for execute ext call
        uint32 txGas;
        bytes callData;
    }
}

// File: contracts/interfaces/IExternalCallExecutor.sol

pragma solidity ^0.8.0;

interface IExternalCallExecutor {
    /**
     * @notice Handles the receipt of Ether to the contract, then validates and executes a function call.
     * @dev Only callable by the adapter. This function decodes the payload to extract execution data.
     *      If the function specified in the callData is prohibited, or the recipient contract is zero,
     *      all Ether is transferred to the fallback address.
     *      Otherwise, it attempts to execute the function call. Any remaining Ether is then transferred to the fallback address.
     * @param _orderId The ID of the order that triggered this function.
     * @param _fallbackAddress The address to receive any unspent Ether.
     * @param _payload The encoded data containing the execution data.
     * @return callSucceeded A boolean indicating whether the call was successful.
     * @return callResult The data returned from the call.
     */
    function onEtherReceived(
        bytes32 _orderId,
        address _fallbackAddress,
        bytes memory _payload
    ) external payable returns (bool callSucceeded, bytes memory callResult);

    /**
     * @notice Handles the receipt of ERC20 tokens, validates and executes a function call.
     * @dev Only callable by the adapter. This function decodes the payload to extract execution data.
     *      If the function specified in the callData is prohibited, or the recipient contract is zero,
     *      all received tokens are transferred to the fallback address.
     *      Otherwise, it attempts to execute the function call. Any remaining tokens are then transferred to the fallback address.
     * @param _orderId The ID of the order that triggered this function.
     * @param _token The address of the ERC20 token that was transferred.
     * @param _transferredAmount The amount of tokens transferred.
     * @param _fallbackAddress The address to receive any unspent tokens.
     * @param _payload The encoded data containing the execution data.
     * @return callSucceeded A boolean indicating whether the call was successful.
     * @return callResult The data returned from the call.
     */
    function onERC20Received(
        bytes32 _orderId,
        address _token,
        uint256 _transferredAmount,
        address _fallbackAddress,
        bytes memory _payload
    ) external returns (bool callSucceeded, bytes memory callResult);
}

// File: contracts/adapters/DlnExternalCallAdapter.sol

pragma solidity ^0.8.17;













contract DlnExternalCallAdapter is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    IExternalCallAdapter
{
    using BytesLib for bytes;

    /* ========== STATE VARIABLES ========== */

    address public dlnDestination;

    /// @dev Default executor for external calls, used when specific executor addresses are not provided.
    IExternalCallExecutor public defaultExecutor;

    /// @dev Stores the status of each external call, identified by a unique bytes32 call ID.
    ///      The status is represented by the CallStatus enum.
    mapping(bytes32 => CallStatus) public externalCallStatus;

    /// @dev Reserved storage slot (previously tokenBalanceHistory mapping)
    uint256 private buf1;

    /* ========== ENUMS ========== */

    /**
     * @dev Enumerates the possible states of an external call.
     *      - NotSet (0): Initial state, indicating no status is set yet.
     *      - Created (1): Call has been created but not yet executed.
     *      - Executed (2): Call has been successfully executed.
     *      - Cancelled (3): Call has been cancelled.
     */
    enum CallStatus {
        NotSet, // 0
        Created, // 1
        Executed, // 2
        Cancelled // 3
    }

    /* ========== ERRORS ========== */

    error AdminBadRole();
    error DlnBadRole();
    error BadRole();
    error InvalidState();
    error IncorrectExecutionFee(uint256 amount, uint256 executionFee);
    error EthTransferFailed();
    error UnknownEnvelopeVersion(uint8 version);
    error DisabledDelayedExecution();
    error FailedExecuteExternalCall(bytes32 orderId, address target, bytes callResult);

    /* ========== EVENTS ========== */

    event ExternalCallRegistered(
        bytes32 callId,
        bytes32 orderId,
        address callAuthority,
        address tokenAddress,
        uint256 amount,
        bytes externalCall
    );
    event ExecutorUpdated(address oldExecutor, address newExecutor);
    event ExternalCallExecuted(bytes32 orderId, bool callSucceeded);
    event ExternalCallFailed(bytes32 orderId, bytes callResult);

    event ExternalCallCancelled(
        bytes32 callId,
        bytes32 orderId,
        address cancelBeneficiary,
        address tokenAddress,
        uint256 amount
    );

    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    modifier onlyDlnDestination() {
        if (dlnDestination != msg.sender) revert DlnBadRole();
        _;
    }

    /* ========== CONSTRUCTOR  ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _dlnDestination,
        address _executor
    ) public initializer {
        dlnDestination = _dlnDestination;
        _setExecutor(_executor);
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /* ========== PUBLIC METHODS ========== */

    /**
     * @notice Callback method invoked after the order has been fulfilled by the taker.
     * @param _orderId Hash of the order being processed
     * @param _callAuthority Address that can cancel external call and send tokens to fallback address
     * @param _tokenAddress  Token that was transferred to adapter
     * @param _transferredAmount Actual amount that was transferred to adapter
     * @param _externalCall Data for the external call.
     * @param _externalCallRewardBeneficiary Address to receive the execution fee;
     *    if set to address(0), external call will not be executed.
     *
     * # Functionality
     * - Uses the transferred amount reported by the trusted DlnDestination.
     * - Registers external calls if no reward beneficiary is set, otherwise executes them immediately.
     * - Emits an event for registered external calls.
     * - Reverts transaction on invalid amount or state inconsistencies.
     */
    function receiveCall(
        bytes32 _orderId,
        address _callAuthority,
        address _tokenAddress,
        uint256 _transferredAmount,
        bytes calldata _externalCall,
        address _externalCallRewardBeneficiary
    ) external nonReentrant whenNotPaused onlyDlnDestination {
        // registrate external call
        if (_externalCallRewardBeneficiary == address(0)) {
            _checkAllowDelayedExecution(_externalCall);
            bytes32 callId = getCallId(
                _orderId,
                _callAuthority,
                _tokenAddress,
                _transferredAmount,
                _externalCall
            );
            if (externalCallStatus[callId] != CallStatus.NotSet)
                revert InvalidState(); // impossible situation
            externalCallStatus[callId] = CallStatus.Created;
            emit ExternalCallRegistered(
                callId,
                _orderId,
                _callAuthority,
                _tokenAddress,
                _transferredAmount,
                _externalCall
            );
        }
        // execute external call if reward beneficiary is set
        else {
            _execute(
                _orderId,
                _tokenAddress,
                _transferredAmount,
                _externalCall,
                _externalCallRewardBeneficiary
            );
        }
    }

    /**
     * @dev Executes external calls related to an order.
     *
     * @param _orderId Unique identifier of the order.
     * @param _callAuthority Address that can cancel external call and send tokens to fallback address
     * @param _tokenAddress Token involved in the transaction.
     * @param _tokenAmount Amount of token used.
     * @param _externalCall Data for the external call.
     * @param _rewardBeneficiary Address receiving execution fee.
     *
     * Error Handling:
     * - Reverts if the call status is not set to 'Created'.
     */
    function executeCall(
        bytes32 _orderId,
        address _callAuthority,
        address _tokenAddress,
        uint256 _tokenAmount,
        bytes calldata _externalCall,
        address _rewardBeneficiary
    ) external nonReentrant whenNotPaused {
        bytes32 callId = getCallId(
            _orderId,
            _callAuthority,
            _tokenAddress,
            _tokenAmount,
            _externalCall
        );

        if (externalCallStatus[callId] != CallStatus.Created) revert InvalidState();
        externalCallStatus[callId] = CallStatus.Executed;

        _execute(
            _orderId,
            _tokenAddress,
            _tokenAmount,
            _externalCall,
            _rewardBeneficiary
        );
    }

    /**
     * @dev Cancels a previously created external call and refunds the associated funds.
     *
     * @param _orderId`: Unique identifier of the order.
     * @param _callAuthority`: Address that can cancel external call and send tokens to fallback address
     * @param _tokenAddress`: Address of the token involved in the call.
     * @param _tokenAmount`: Amount of the token to be refunded.
     * @param _recipient`: Address to receive the refunded tokens.
     * @param _externalCallHash`: Hash of the external call data.
     *
     * Functionality:
     * - Validates sender's authority for cancellation.
     * - Generates a unique call ID and checks if the call is in a 'Created' state.
     * - Refunds tokens to the specified recipient.
     * - Updates call status to 'Cancelled'.
     * - Emits an `ExternalCallCancelled` event with relevant details.
     *
     * Error Handling:
     * - Reverts if the sender is not the authorized call authority.
     * - Reverts if the call status is not set to 'Created'.
     */
    function cancelCall(
        bytes32 _orderId,
        address _callAuthority,
        address _tokenAddress,
        uint256 _tokenAmount,
        address _recipient,
        bytes32 _externalCallHash
    ) external nonReentrant whenNotPaused {
        if (msg.sender != _callAuthority) revert BadRole();
        bytes32 callId = getCallId(
            _orderId,
            _callAuthority,
            _tokenAddress,
            _tokenAmount,
            _externalCallHash
        );

        if (externalCallStatus[callId] != CallStatus.Created)
            revert InvalidState();
        externalCallStatus[callId] = CallStatus.Cancelled;
        _sendToken(_tokenAddress, _tokenAmount, _recipient);

        emit ExternalCallCancelled(
            callId,
            _orderId,
            _recipient,
            _tokenAddress,
            _tokenAmount
        );
    }

    receive() external payable onlyDlnDestination {}

    /* ========== ADMIN METHODS ========== */

    /**
     * @dev Updates the default executor address.
     *
     * @param _newExecutor The address of the new executor.
     *
     * Modifiers:
     * - `onlyAdmin`: Ensures that only an admin can call this function.
     *
     */
    function updateExecutor(address _newExecutor) external onlyAdmin {
        _setExecutor(_newExecutor);
    }

    /* ========== INTERNAL ========== */

    /**
     * @dev Internal function to process the execution of external calls.
     *
     * @param _orderId Unique identifier of the order.
     * @param _tokenAddress Token involved in the transaction.
     * @param _tokenAmount Amount of token used.
     * @param _externalCall Data for the external call.
     * @param _rewardBeneficiary Address receiving execution fee.
     *
     * Functionality:
     * - Parses and validates envelope data.
     * - Manages token transactions and execution fees.
     * - Chooses and executes call via correct executor.
     * - Emits events based on execution status.
     *
     * Error Handling:
     * - Reverts on incorrect fee, failed execution, or unknown envelope version.
     * - Emits failure event if external call execution fails.
     */
    function _execute(
        bytes32 _orderId,
        address _tokenAddress,
        uint256 _tokenAmount,
        bytes memory _externalCall,
        address _rewardBeneficiary
    ) internal {
        (uint8 envelopeVersion, bytes memory envelopData)= _getEnvelopeData(_externalCall);
        bool executionStatus;
        bytes memory callResult;
        if (envelopeVersion == 1) {
            DlnExternalCallLib.ExternalCallEnvelopV1 memory dataEnvelope = abi.decode(
                envelopData,
                (DlnExternalCallLib.ExternalCallEnvelopV1)
            );
            // pay execution fee
            if (_tokenAmount >= dataEnvelope.executionFee) {
                if (dataEnvelope.executionFee > 0) {
                    _tokenAmount = _tokenAmount - dataEnvelope.executionFee;
                    _sendToken(
                        _tokenAddress,
                        dataEnvelope.executionFee,
                        _rewardBeneficiary
                    );
                }
            }
            // if incorrect execution fee
            else {
                revert IncorrectExecutionFee(
                    _tokenAmount,
                    dataEnvelope.executionFee
                );
            }
            IExternalCallExecutor currentExecutor = dataEnvelope.executorAddress == address(0)
                                                 ? defaultExecutor
                                                 : IExternalCallExecutor(dataEnvelope.executorAddress);

            // call external
            if (_tokenAddress == address(0)) {
                (executionStatus, callResult) = currentExecutor.onEtherReceived{
                    value: _tokenAmount
                }(_orderId, dataEnvelope.fallbackAddress, dataEnvelope.payload);
            } else {
                IERC20 token = IERC20(_tokenAddress);
                uint256 executorBalanceBefore = token.balanceOf(address(currentExecutor));
                _sendToken(
                    _tokenAddress,
                    _tokenAmount,
                    address(currentExecutor)
                );
                uint256 actualTransferredAmount = token.balanceOf(address(currentExecutor)) - executorBalanceBefore;
                (executionStatus, callResult) = currentExecutor.onERC20Received(
                    _orderId,
                    _tokenAddress,
                    actualTransferredAmount,
                    dataEnvelope.fallbackAddress,
                    dataEnvelope.payload
                );
            }
            if (dataEnvelope.requireSuccessfullExecution && !executionStatus)
                revert FailedExecuteExternalCall(_orderId, address(currentExecutor), callResult);
        } else {
            revert UnknownEnvelopeVersion(envelopeVersion);
        }

        emit ExternalCallExecuted(_orderId, executionStatus);
        // Emit an event if the external call failed, including the callResult.
        if (!executionStatus) {
            emit ExternalCallFailed(_orderId, callResult);
        }
    }

    /**
     * @dev Validates if delayed execution is allowed for a given external call.
     *
     * @param _externalCall The raw bytes of the external call data.
     *
     * Functionality:
     * - Extracts the envelope version and data from the external call.
     * - Decodes the data based on the envelope version.
     * - For version 1, checks if delayed execution is permitted.
     * - Reverts if delayed execution is not allowed or if the envelope version is unknown.
     *
     * Error Handling:
     * - Reverts with `DisabledDelayedExecution` if delayed execution is disabled in the data envelope.
     * - Reverts with `UnknownEnvelopeVersion` if the envelope version is not recognized.
     *
     */
    function _checkAllowDelayedExecution(
        bytes memory _externalCall
    ) internal pure {
        (uint8 envelopeVersion, bytes memory envelopData) = _getEnvelopeData(
            _externalCall
        );
        if (envelopeVersion == 1) {
            DlnExternalCallLib.ExternalCallEnvelopV1 memory dataEnvelope = abi.decode(
                envelopData,
                (DlnExternalCallLib.ExternalCallEnvelopV1)
            );
            if (!dataEnvelope.allowDelayedExecution) {
                revert DisabledDelayedExecution();
            }
        } else {
            revert UnknownEnvelopeVersion(envelopeVersion);
        }
    }

    /**
     * @dev Extracts the envelope version and data from a given external call.
     *
     * @param _externalCall The raw bytes of the external call data.
     *
     * @return envelopeVersion The version number of the envelope extracted from the call data.
     * @return envelopData The remaining data in the envelope after removing the version byte.
     *
     */
    function _getEnvelopeData(
        bytes memory _externalCall
    ) internal pure returns (uint8 envelopeVersion, bytes memory envelopData) {
        envelopeVersion = BytesLib.toUint8(_externalCall, 0);
        // Remove first byte from data
        envelopData = BytesLib.slice(
            _externalCall,
            1,
            _externalCall.length - 1
        );
    }

    /**
     * @dev Internal function that sets a new executor and emits an event.
     *
     * @param _newExecutor The address of the new executor.
     *
     * Functionality:
     * - Updates the `defaultExecutor` to the new executor address.
     * - Emits `ExecutorUpdated` event with the old and new executor addresses.
     *
     */
    function _setExecutor(address _newExecutor) internal {
        address oldExecutor = address(defaultExecutor);
        defaultExecutor = IExternalCallExecutor(_newExecutor);
        emit ExecutorUpdated(oldExecutor, address(defaultExecutor));
    }

    /**
     * @dev Transfers a specified amount of tokens (or Ether) to a receiver.
     *
     * @param _tokenAddress The address of the token to transfer. If address(0), it refers to Ether.
     * @param _amount The amount of tokens (or Ether) to transfer.
     * @param _receiver The address of the recipient.
     *
     * Functionality:
     * - If `_tokenAddress` is address(0), transfers Ether using `_safeTransferETH`.
     * - Otherwise, transfers the specified ERC20 token using `safeTransfer`.
     *
     */
    function _sendToken(
        address _tokenAddress,
        uint256 _amount,
        address _receiver
    ) internal {
        TokenLib.safeTransfer(_tokenAddress, _receiver, _amount);
    }

    /**
     * @dev Generates a unique identifier (call ID) for an external call.
     *
     * @param _orderId Unique identifier of the order.
     * @param _callAuthority Address that can cancel external call and send tokens to fallback address
     * @param _tokenAddress Address of the token involved in the transaction.
     * @param _transferredAmount Amount of the token that was transferred.
     * @param _externalCall Raw bytes of the external call data.
     * @return  A bytes32 hash representing the unique call ID.
     *
     */
    function getCallId(
        bytes32 _orderId,
        address _callAuthority,
        address _tokenAddress,
        uint256 _transferredAmount,
        bytes memory _externalCall
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    _orderId,
                    _callAuthority,
                    _tokenAddress,
                    _transferredAmount,
                    keccak256(_externalCall)
                )
            );
    }

    /**
     * @dev Generates a unique identifier (call ID) for an external call.
     *
     * @param _orderId Unique identifier of the order.
     * @param _callAuthority Address that can cancel external call and send tokens to fallback address
     * @param _tokenAddress Address of the token involved in the transaction.
     * @param _transferredAmount Amount of the token that was transferred.
     * @param _externalCallHash Hash of external call data.
     * @return  A bytes32 hash representing the unique call ID.
     *
     */
    function getCallId(
        bytes32 _orderId,
        address _callAuthority,
        address _tokenAddress,
        uint256 _transferredAmount,
        bytes32 _externalCallHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    _orderId,
                    _callAuthority,
                    _tokenAddress,
                    _transferredAmount,
                    _externalCallHash
                )
            );
    }

    /* ========== Version Control ========== */

    /**
     * @dev Returns the current version of the contract.
     *
     * @return The version number of the contract as a string.
     *
     */
    function version() external pure returns (string memory) {
        return "1.2.0";
    }
}

// File: contracts/adapters/ExternalCallExecutorBase.sol

pragma solidity ^0.8.7;





abstract contract ExternalCallExecutorBase is AccessControl {
    using Address for address;
    using SafeERC20 for IERC20;

    /* ========== ERRORS ========== */

    error AdminBadRole();
    error AdapterBadRole();
    error EthTransferFailed();
    error NotEnoughTxGas();

    /* ========== STATE VARIABLES ========== */

    bytes32 public constant ADAPTER_ROLE = keccak256("ADAPTER_ROLE");

    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    modifier onlyAdapter() {
        if (!hasRole(ADAPTER_ROLE, msg.sender)) revert AdapterBadRole();
        _;
    }

    /* ========== CONSTRUCTOR  ========== */

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /* ========== ADMIN METHODS ========== */

    /**
     * @notice Allows the admin to withdraw tokens or ETH from the contract.
     * @dev Only callable by the admin.
     * @param _token The address of the ERC20 token to be withdrawn.
     *               Use the zero address for withdrawing ETH.
     * @param _recipient The address to receive the tokens or ETH.
     * @param _amount The amount of tokens or ETH to be withdrawn.
     */
    function rescueFunds(
        address _token,
        address _recipient,
        uint256 _amount
    ) external onlyAdmin {
        if (_token == address(0)) {
            _safeTransferETH(_recipient, _amount);
        } else {
            IERC20(_token).safeTransfer(_recipient, _amount);
        }
    }

    /* ========== INTERNAL METHODS ========== */

    /**
    * @notice Makes an external call to the provided address with the specified ether, data payload, and optional custom gas.
    * @param _to The address to call.
    * @param _value The amount of ether to send.
    * @param _data The data payload for the call.
    * @param _txGas The custom gas amount for the call. If set to 0, it uses the default.
    * @return callSucceeded A boolean indicating whether the call was successful.
    * @return callResult The data returned from the call.
    *
    * Notes:
    * 1. If the target address is not a contract, the function does not make a call.
    * 2. If `_txGas` is specified and there's not enough gas left in the current transaction, the function will revert.
    * 3. The function takes into account the EIP-150's 1/64th gas rule.
    */
    function _execute(
        address _to,
        uint256 _value,
        bytes memory _data,
        uint256 _txGas
    ) internal returns (bool callSucceeded, bytes memory callResult) {
        if (Address.isContract(_to)) {
            if (_txGas > 0) {
                // We include the 1/64 in the check that is not send along with a call to counteract potential shortings because of EIP-150
                if (gasleft() < _txGas * 64 / 63) revert NotEnoughTxGas();
                (callSucceeded, callResult) = _to.call{value: _value, gas: _txGas}(_data);
            } else {
                (callSucceeded, callResult) = _to.call{value: _value}(_data);
            }
        }
    }

    /**
     * @notice Internal function to approve the transfer of tokens on behalf of the contract.
     * @dev This function uses low-level call to interact with ERC20 contracts that don't strictly follow the standard.
     * @param token The address of the ERC20 token to be approved.
     * @param spender The address which will be approved to spend the tokens.
     * @param value The amount of tokens to be approved for spending.
     */
    function _customApprove(
        address token,
        address spender,
        uint256 value
    ) internal {
        bytes memory returndata = token.functionCall(
            abi.encodeWithSelector(IERC20.approve.selector, spender, value),
            "ERC20 approve failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "ERC20 operation did not succeed"
            );
        }
    }

    /*
     * @dev transfer ETH to an address, revert if it fails.
     * @param to recipient of the transfer
     * @param value the amount to send
     */
    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) revert EthTransferFailed();
    }
}

// File: contracts/adapters/ExternalCallExecutor.sol

pragma solidity ^0.8.17;







contract ExternalCallExecutor is
    ExternalCallExecutorBase,
    IExternalCallExecutor
{
    // Declare prohibitedSelectors as a constant
    bytes4 private constant APPROVE_SELECTOR = 0x095ea7b3;
    bytes4 private constant TRANSFER_FROM_SELECTOR = 0x23b872dd;
    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;
    bytes4 private constant INCREASE_ALLOWANCE_SELECTOR = 0x39509351;

    /* ========== ERRORS ========== */

    error CallFailed();

    /* ========== CONSTRUCTOR  ========== */

    constructor() {}

    /* ========== PUBLIC METHODS ========== */

    /**
     * @inheritdoc IExternalCallExecutor
     */
    function onEtherReceived(
        bytes32 /*_orderId*/,
        address _fallbackAddress,
        bytes memory _payload
    ) external payable onlyAdapter returns (bool callSucceeded, bytes memory callResult) {
        DlnExternalCallLib.ExternalCallPayload memory executionData = abi
            .decode(_payload, (DlnExternalCallLib.ExternalCallPayload));
        uint256 preBalance = address(this).balance - msg.value;

        // if prohibited function selector, transfer all msg.value to reserve address
        if (
            isProhibitedSelector(executionData.callData) ||
            executionData.to == address(0)
        ) {
            _safeTransferETH(_fallbackAddress, msg.value);
            return (false, "Prohibited selector");
        }

        (callSucceeded, callResult) = _execute(
            executionData.to,
            msg.value,
            executionData.callData,
            executionData.txGas
        );

        uint256 amountLeft = address(this).balance - preBalance;
        if (amountLeft != 0) {
            _safeTransferETH(_fallbackAddress, amountLeft);
        }
    }

    /**
     * @inheritdoc IExternalCallExecutor
     */
    function onERC20Received(
        bytes32 /*_orderId*/,
        address _token,
        uint256 _transferredAmount,
        address _fallbackAddress,
        bytes memory _payload
    ) external onlyAdapter returns (bool callSucceeded, bytes memory callResult) {
        IERC20 token = IERC20(_token);
        uint256 preBalance = token.balanceOf(address(this)) - _transferredAmount;
        DlnExternalCallLib.ExternalCallPayload memory executionData = abi
            .decode(_payload, (DlnExternalCallLib.ExternalCallPayload));

        // if prohibited function selector, transfer all amount to reserve address
        if (
            isProhibitedSelector(executionData.callData) ||
            executionData.to == address(0)
        ) {
            TokenLib.safeTransfer(_token, _fallbackAddress, _transferredAmount);
            return (false, "Prohibited selector");
        }
        // create approve to allow the target contract to spend tokens.
        if (_transferredAmount != 0) {
            _customApprove(_token, executionData.to, _transferredAmount);
        }

        (callSucceeded, callResult) = _execute(
            executionData.to,
            0,
            executionData.callData,
            executionData.txGas
        );

        uint256 amountLeft = token.balanceOf(address(this)) - preBalance;

        if (amountLeft != 0) {
            TokenLib.safeTransfer(_token, _fallbackAddress, amountLeft);
            _customApprove(_token, executionData.to, 0);
        }
    }

    /* ========== INTERNAL METHODS ========== */

    /**
     * @notice Checks if the function selector is prohibited to be called.
     * @dev This function extracts the function selector from the `_data` and compares it
     *      against a list of prohibited function selectors.
     * @param _data The encoded data containing the function selector and arguments.
     * @return A boolean indicating whether the function selector specified in the `_data` is prohibited.
     */
    function isProhibitedSelector(bytes memory _data) public pure returns (bool) {
        bytes4 functionSelector = _toBytes4(_data, 0);

        // Check against the constant selectors
        return functionSelector == APPROVE_SELECTOR ||
                 functionSelector == TRANSFER_FROM_SELECTOR ||
                 functionSelector == TRANSFER_SELECTOR ||
                 functionSelector == INCREASE_ALLOWANCE_SELECTOR;
    }

    /**
     * @notice Converts the first 4 bytes starting at a specific position in a byte array to a bytes4 type.
     * @dev This function uses assembly for efficient memory operations.
     * @param _bytes The byte array to be converted.
     * @param _start The position in the byte array to start the conversion.
     * @return The first 4 bytes starting at the `_start` position in the byte array as a bytes4 type.
     * throws If there are less than 4 bytes starting at the `_start` position in the byte array.
     */
    function _toBytes4(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (bytes4) {
        require(_bytes.length >= _start + 4, "toBytes4_outOfBounds");
        bytes4 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }
}

// File: contracts/adapters/examples/AAVECallExecutor.sol

pragma solidity ^0.8.17;






contract AAVECallExecutor is ExternalCallExecutorBase, IExternalCallExecutor {
    using BytesLib for bytes;
    /* ========== ERRORS ========== */

    error NotSupported();

    /* ========== CONSTRUCTOR  ========== */

    constructor(address _externalCallAdapter) {
        _grantRole(ADAPTER_ROLE, _externalCallAdapter);
    }

    /* ========== PUBLIC METHODS ========== */

    /**
     * @inheritdoc IExternalCallExecutor
     */
    function onEtherReceived(
        bytes32 _orderId,
        address _fallbackAddress,
        bytes memory _payload
    ) external payable onlyAdapter returns (bool callSucceeded, bytes memory callResult) {
        revert NotSupported();
    }

    /**
     * @inheritdoc IExternalCallExecutor
     */
    function onERC20Received(
        bytes32 _orderId,
        address _token,
        uint256 _transferredAmount,
        address _fallbackAddress,
        bytes memory _payload
    ) external onlyAdapter returns (bool callSucceeded, bytes memory callResult) {
        // IERC20 token = IERC20(_token);
        address pool = _payload.toAddress(0);
        address onBehalfOf = _payload.toAddress(20);
        // create approve to allow the target contract to spend tokens.
        if (_transferredAmount > 0) {
            _customApprove(_token, pool, _transferredAmount);
        }

        IPool(pool).supply(_token, _transferredAmount, onBehalfOf, 0);
        callSucceeded = true;
    }
}

/**
 * @title IPool
 * @author Aave
 * @notice Defines the basic interface for an Aave Pool.
 */
interface IPool {
    /**
     * @notice Supplies an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
     * - E.g. User supplies 100 USDC and gets in return 100 aUSDC
     * @param asset The address of the underlying asset to supply
     * @param amount The amount to be supplied
     * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
     *   is a different wallet
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without any middle-man
     */
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
}

// File: contracts/adapters/examples/WidoCallExecutor.sol

pragma solidity ^0.8.17;







contract WidoCallExecutor is ExternalCallExecutorBase, IExternalCallExecutor {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    address public widoRouter;
    address public widoTokenManager;

    /* ========== ERRORS ========== */

    error NotSupported();

    /* ========== CONSTRUCTOR  ========== */

    constructor(
        address _widoRouter,
        address _widoTokenManager,
        address _externalCallAdapter
    ) {
        widoRouter = _widoRouter;
        widoTokenManager = _widoTokenManager;
        _grantRole(ADAPTER_ROLE, _externalCallAdapter);
    }

    /* ========== PUBLIC METHODS ========== */

    /**
     * @inheritdoc IExternalCallExecutor
     */
    function onEtherReceived(
        bytes32 _orderId,
        address _fallbackAddress,
        bytes memory _payload
    ) external payable onlyAdapter returns (bool callSucceeded, bytes memory callResult) {
        revert NotSupported();
    }

    /**
     * @inheritdoc IExternalCallExecutor
     */
    function onERC20Received(
        bytes32 _orderId,
        address _token,
        uint256 _transferredAmount,
        address _fallbackAddress,
        bytes memory _payload
    ) external onlyAdapter returns (bool callSucceeded, bytes memory callResult) {
        IERC20 token = IERC20(_token);
        uint256 amount = token.balanceOf(address(this));

        // create approve to allow the target contract to spend tokens.
        if (amount > 0) {
            _customApprove(_token, widoTokenManager, amount);
        }

        widoRouter.call(_payload);
        callSucceeded = true;

        amount = token.balanceOf(address(this));

        if (amount > 0) {
            token.safeTransfer(_fallbackAddress, amount);
            _customApprove(_token, widoTokenManager, 0);
        }
    }
}

// File: contracts/imports.sol

pragma solidity ^0.8.7;

// import this contract for typechain

// File: contracts/mock/DummyToken.sol

pragma solidity ^0.8.7;



contract DummyToken is ERC20 {
    uint8 _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}

// File: contracts/mock/Imports.sol

pragma solidity ^0.8.7;

// File: contracts/mock/MockCallProxy.sol

pragma solidity ^0.8.0;

contract MockCallProxy {
    bytes public submissionNativeSender;
    uint256 public submissionChainIdFrom;

    function bypassCall(bytes calldata _submissionNativeSender, uint _submissionChainIdFrom, address to, bytes calldata data) external payable {
        submissionNativeSender = _submissionNativeSender;
        submissionChainIdFrom = _submissionChainIdFrom;

        (bool success, bytes memory result) = to.call{value: msg.value}(data);

        if(!success) {
            // Revert the transaction with the revert reason from the called contract
            if (result.length > 0) {
                // The easiest way to bubble up the revert reason is to use solidity's built-in functionality
                assembly {
                    let result_size := mload(result)
                    revert(add(32, result), result_size)
                }
            } else {
                revert("Call to the target contract failed without a revert reason");
            }
        }
    }
}

// File: contracts/mock/MockCallReceiver.sol

pragma solidity ^0.8.0;




contract MockCallReceiver {
    using SafeERC20 for IERC20;
    function collectTokens(address tokenAddress, uint256 amount) external {
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
    }

    function revertWithMessage(string memory _message) external pure {
        revert(_message);
    }
}

// File: contracts/mock/MockDlnSource.sol

pragma solidity ^0.8.17;




contract MockDlnSource is DlnSource {

    constructor(address _intentManager, IIntentManagerValidator _intentManagerRights, IDeBridgeGate _deBridgeGate, uint32 _subscriptionId) DlnSource(_intentManager, _intentManagerRights, _deBridgeGate, _subscriptionId) {
    }

    function initializeMock(
        uint80 _globalFixedNativeFee,
        uint16 _globalTransferFeeBps
    ) public initializer {
        super.initialize(_globalFixedNativeFee, _globalTransferFeeBps);
    }

    function encodeOrder(DlnOrderLib.Order memory _order)
        public
        pure
        returns (bytes memory encoded)
    {
        return DlnOrderLib.encodeOrder(_order, false);
    }
}

// File: contracts/mock/MockFeeCollectorForDlnSource.sol

pragma solidity ^0.8.7;



contract MockFeeCollectorForDlnSource {
    function withdrawCollectedFees(
        DlnSource _dlnSource,
        address[] calldata _tokens
    ) external {
        _dlnSource.withdrawCollectedFees(_tokens);
    }
}

// File: contracts/mock/MockRebasingToken.sol

pragma solidity ^0.8.7;



/// @dev Synthetic rebasing token that mimics stETH transfer behavior.
/// Internally tracks balances as "shares". transferFrom converts amount → shares → amount,
/// which may lose 1 wei due to integer division rounding — exactly like stETH.
contract MockRebasingToken is ERC20 {
    uint8 private _decimals;

    uint256 public totalShares;
    uint256 public totalPooledEther;
    mapping(address => uint256) public sharesOf;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /// @dev Sets the total pooled ether (rebasing numerator). Changing this value
    /// after minting simulates a rebase event.
    function setTotalPooledEther(uint256 _totalPooledEther) external {
        totalPooledEther = _totalPooledEther;
    }

    /// @dev Mint shares such that the token-denominated balance equals `amount`
    /// at the current exchange rate.
    function mint(address recipient, uint256 amount) external {
        uint256 sharesToMint;
        if (totalShares == 0 || totalPooledEther == 0) {
            sharesToMint = amount;
            totalPooledEther += amount;
        } else {
            sharesToMint = (amount * totalShares) / totalPooledEther;
            totalPooledEther += amount;
        }
        totalShares += sharesToMint;
        sharesOf[recipient] += sharesToMint;
        _mint(recipient, amount);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        if (totalShares == 0) return 0;
        return (sharesOf[account] * totalPooledEther) / totalShares;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return totalPooledEther;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        uint256 sharesToTransfer = (amount * totalShares) / totalPooledEther;
        require(sharesToTransfer > 0, "Transfer amount too small");
        require(sharesOf[msg.sender] >= sharesToTransfer, "Insufficient shares");

        sharesOf[msg.sender] -= sharesToTransfer;
        sharesOf[to] += sharesToTransfer;

        // The actual token amount the recipient receives may differ by 1 wei
        // due to shares→amount rounding, exactly like stETH
        uint256 tokensTransferred = (sharesToTransfer * totalPooledEther) / totalShares;
        emit Transfer(msg.sender, to, tokensTransferred);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, amount);

        uint256 sharesToTransfer = (amount * totalShares) / totalPooledEther;
        require(sharesToTransfer > 0, "Transfer amount too small");
        require(sharesOf[from] >= sharesToTransfer, "Insufficient shares");

        sharesOf[from] -= sharesToTransfer;
        sharesOf[to] += sharesToTransfer;

        uint256 tokensTransferred = (sharesToTransfer * totalPooledEther) / totalShares;
        emit Transfer(from, to, tokensTransferred);
        return true;
    }
}

// File: contracts/mock/MockReceiver.sol

pragma solidity ^0.8.0;



contract MockReceiver {
    using SafeERC20 for IERC20;

    event ReceivedEth(uint256 amount, address receiver);
    event ReceivedERC20(uint256 amount, address receiver);
    event ReceivedEther(address sender, uint256 value);

    function receiveETH(address _receiver) external payable {
        _receiver.call{value: msg.value}(new bytes(0));
        emit ReceivedEth(msg.value, _receiver);
    }

    function receiveERC20(
        uint256 _amount,
        address _tokenAddress,
        address _receiver
    ) external {
        IERC20(_tokenAddress).safeTransferFrom(msg.sender, _receiver, _amount);
        emit ReceivedERC20(_amount, _receiver);
    }
     
    receive () external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
}

// File: contracts/mock/MockSignatureVerifier.sol

pragma solidity ^0.8.0;

contract MockSignatureVerifier {
    function submit(
        bytes32 _submissionId,
        bytes memory _signatures,
        uint8 _excessConfirmations
    ) external {}
}

// File: contracts/mock/MockTaxableToken.sol

pragma solidity ^0.8.7;



/// @dev ERC20 token that charges a fixed 10% tax on every transfer.
contract MockTaxableToken is ERC20 {
    uint256 public constant TAX_BPS = 1000;
    uint256 public constant BPS_DENOMINATOR = 10_000;

    uint8 private _decimals;
    address public immutable taxCollector;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address taxCollector_
    ) ERC20(name_, symbol_) {
        require(taxCollector_ != address(0), "tax collector is zero");
        _decimals = decimals_;
        taxCollector = taxCollector_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 taxAmount = (amount * TAX_BPS) / BPS_DENOMINATOR;
        uint256 receiveAmount = amount - taxAmount;

        if (receiveAmount > 0) {
            super._transfer(from, to, receiveAmount);
        }

        if (taxAmount > 0) {
            super._transfer(from, taxCollector, taxAmount);
        }
    }
}

// File: contracts/mock/MockTokenLib.sol

pragma solidity ^0.8.0;



contract MockTokenLib {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) external {
        TokenLib.safeTransfer(token, to, value);
    }

    function trySafeTransfer(
        address token,
        address to,
        uint256 value
    ) external returns (bool success) {
        return TokenLib.trySafeTransfer(token, to, value);
    }
}

// File: contracts/mock/MockTokenWithTransferFalseResult.sol

pragma solidity ^0.8.0;



contract MockTokenWithTransferFalseResult is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }

    function transfer(address to, uint256 amount) public pure override returns (bool) {
        (to, amount); // silence compiler warnings
        return false;
    }
}

// File: contracts/mock/MockTokenWithTransferRevert.sol

pragma solidity ^0.8.0;



contract MockTokenWithTransferRevert is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }

    function transfer(address to, uint256 amount) public pure override returns (bool) {
        (to, amount); // silence compiler warnings
        revert("Transfer reverted");
    }
}

// File: contracts/mock/NonStandardToken.sol

pragma solidity ^0.8.0;

interface INonStandardToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
}

contract NonStandardToken is INonStandardToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) private {
        totalSupply += amount;
        balances[account] += amount;
    }

    function balanceOf(address owner) external view override returns (uint256) {
        return balances[owner];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external override {
        allowances[msg.sender][spender] = value;
    }

    function transfer(address to, uint256 value) external override {
        balances[msg.sender] -= value;
        balances[to] += value;
    }

    function transferFrom(address from, address to, uint256 value) external override {
        allowances[from][msg.sender] -= value;
        balances[from] -= value;
        balances[to] += value;
    }
}
