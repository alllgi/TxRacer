// Sources flattened with hardhat v2.22.6 https://hardhat.org

// SPDX-License-Identifier: BUSL-1.1 AND GPL-3.0-only AND MIT AND UNLICENSED AND UNLISENCED

pragma abicoder v2;

// File @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File @openzeppelin/contracts/utils/Address.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
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
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
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
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}


// File contracts/interfaces/IController.sol

interface IController {
    function whiteListDex(address, bool) external returns(bool);
    function adminPause() external; 
    function adminUnPause() external;
    function isWhiteListedDex(address) external returns(bool);
}


// File contracts/dependencies/Controller.sol

// Original license: SPDX_License_Identifier: UNLISENCED
pragma solidity 0.8.12;



abstract contract Controller is
    OwnableUpgradeable,
    PausableUpgradeable,
    IController
{
    mapping(address => bool) private _isVerified;

    function __Controller_init_() internal onlyInitializing {
        __Ownable_init();
        __Pausable_init();
    }

    function whiteListDex(address _exchangeAddr, bool _verification)
        external
        override
        onlyOwner
        returns (bool)
    {
        require(_exchangeAddr != address(0), "Zero-address");
        _isVerified[_exchangeAddr] = _verification;
        return (_verification);
    }

    function whiteListDexes(
        address[] memory _dexes,
        bool[] memory _verifications
    ) external onlyOwner {
        for (uint8 i = 0; i < _dexes.length; i++) {
            require(_dexes[i] != address(0), "Zero-address");
            _isVerified[_dexes[i]] = _verifications[i];
        }
    }

    function adminPause() external override onlyOwner {
        _pause();
    }

    function adminUnPause() external override onlyOwner {
        _unpause();
    }

    function isWhiteListedDex(address _exchangeAddr)
        public
        view
        override
        returns (bool)
    {
        return _isVerified[_exchangeAddr];
    }
}


// File contracts/interfaces/ILayerZeroUserApplicationConfig.sol

// Original license: SPDX_License_Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroUserApplicationConfig {
    // @notice set the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _configType - type of configuration. every messaging library has its own convention.
    // @param _config - configuration in the bytes. can encode arbitrary content.
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;

    // @notice set the send() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setSendVersion(uint16 _version) external;

    // @notice set the lzReceive() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setReceiveVersion(uint16 _version) external;

    // @notice Only when the UA needs to resume the message flow in blocking mode and clear the stored payload
    // @param _srcChainId - the chainId of the source chain
    // @param _srcAddress - the contract address of the source contract at the source chain
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}


// File contracts/interfaces/ILayerZeroEndpoint.sol

// Original license: SPDX_License_Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {
    // @notice send a LayerZero message to the specified address at a LayerZero endpoint.
    // @param _dstChainId - the destination chain identifier
    // @param _destination - the address on destination chain (in bytes). address length/format may vary by chains
    // @param _payload - a custom bytes payload to send to the destination contract
    // @param _refundAddress - if the source transaction is cheaper than the amount of value passed, refund the additional amount to this address
    // @param _zroPaymentAddress - the address of the ZRO token holder who would pay for the transaction
    // @param _adapterParams - parameters for custom functionality. e.g. receive airdropped native gas from the relayer on destination
    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;

    // @notice used by the messaging library to publish verified payload
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source contract (as bytes) at the source chain
    // @param _dstAddress - the address on destination chain
    // @param _nonce - the unbound message ordering nonce
    // @param _gasLimit - the gas limit for external contract execution
    // @param _payload - verified payload to send to the destination contract
    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external;

    // @notice get the inboundNonce of a receiver from a source chain which could be EVM or non-EVM chain
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);

    // @notice get the outboundNonce from this source chain which, consequently, is always an EVM
    // @param _srcAddress - the source chain contract address
    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);

    // @notice gets a quote in source native gas, for the amount that send() requires to pay for message delivery
    // @param _dstChainId - the destination chain identifier
    // @param _userApplication - the user app address on this EVM chain
    // @param _payload - the custom message to send over LayerZero
    // @param _payInZRO - if false, user app pays the protocol fee in native token
    // @param _adapterParam - parameters for the adapter service, e.g. send some dust native token to dstChain
    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);

    // @notice get this Endpoint's immutable source identifier
    function getChainId() external view returns (uint16);

    // @notice the interface to retry failed message on this Endpoint destination
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    // @param _payload - the payload to be retried
    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;

    // @notice query if any STORED payload (message blocking) at the endpoint.
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);

    // @notice query if the _libraryAddress is valid for sending msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getSendLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the _libraryAddress is valid for receiving msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getReceiveLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the non-reentrancy guard for send() is on
    // @return true if the guard is on. false otherwise
    function isSendingPayload() external view returns (bool);

    // @notice query if the non-reentrancy guard for receive() is on
    // @return true if the guard is on. false otherwise
    function isReceivingPayload() external view returns (bool);

    // @notice get the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _userApplication - the contract address of the user application
    // @param _configType - type of configuration. every messaging library has its own convention.
    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);

    // @notice get the send() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getSendVersion(address _userApplication) external view returns (uint16);

    // @notice get the lzReceive() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getReceiveVersion(address _userApplication) external view returns (uint16);
}


// File contracts/helpers/EthReceiver.sol

abstract contract EthReceiver {
    receive() external payable {
    }
}


// File contracts/interfaces/IFeeClaimers.sol

interface IFeeClaimer {
    function topUpFee(
        address feeClaimer,
        address token,
        uint256 amount,
        uint256 unizenAmount
    ) external payable returns(bool);

    function withdrawToken(address token, address receiver) external;

    function withdrawETH(address payable receiver) external;

    function batchWithdrawTokensAndETH(
        address[] calldata tokens,
        address payable receiver
    ) external;
}


// File contracts/interfaces/ILayerZeroReceiver.sol

// Original license: SPDX_License_Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroReceiver {
    // @notice LayerZero endpoint will invoke this function to deliver the message on the destination
    // @param _srcChainId - the source endpoint identifier
    // @param _srcAddress - the source sending contract address from the source chain
    // @param _nonce - the ordered message nonce
    // @param _payload - the signed payload is the UA bytes has encoded to be sent
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
}


// File contracts/interfaces/IStargateReceiver.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.4;

interface IStargateReceiver {
    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        address _token,
        uint256 amountLD,
        bytes memory payload
    ) external;
}


// File contracts/interfaces/IStargateRouter.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.4;
// Original pragma directive: pragma abicoder v2

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);
}


// File contracts/interfaces/ITcRouter.sol

interface ITcRouter {
     function depositWithExpiry(address payable vault, address asset, uint amount, string memory memo, uint expiration) external payable;
}


// File contracts/interfaces/IUnizenDexAggr.sol

// Original license: SPDX_License_Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

interface IUnizenDexAggr {
     struct SwapCall {
        address targetExchange;
        address sellToken;
        address buyToken;
        uint256 amount;
        bytes data; // Encoded data to execute the trade by contract call
    }  

    struct SwapTC { 
        address srcToken; //Input token
        address dstToken; //Output token, must be asset support by Thorchain like ETH, USDT ... 
        uint256 amountIn; // amount in user want to trade
        uint256 amountOutMin; // expected amount out min
        uint256 feePercent;
        uint256 sharePercent;
        address vault;
        uint256 deadline;
        string memo;
        string uuid;
        uint16 apiId;
    }

    struct SwapExactInInfo {
        address receiver; // Receiver address
        address srcToken; //Input token
        address dstToken; //Output token
        uint256 amountIn; // amount in user want to trade
        uint256 amountOutMin; // expected amount out min
        uint256 actualQuote; // expected amount out
        uint256 feePercent;
        uint256 sharePercent;
        uint16 apiId;
        uint16 userPSFee;
        string uuid; //integrator uuid (if swap directly by unizen leave it empty "")
    }

    struct SwapExactOutInfo {
        address receiver; // Receiver address
        address srcToken; //Input token
        address dstToken; //Output token
        uint256 amountOut; // expect amount out of user
        uint256 amountInMax; //amount in max that user willing to pay
        uint256 actualQuote; // expected amountIn,
        uint256 feePercent;
        uint256 sharePercent;
        uint16 apiId;
        uint16 userPSFee;
        string uuid; //integrator uuid (if swap directly by unizen leave it empty "")
    }

    struct CrossChainSwapSg {
        address srcToken;
        address receiver;
        uint256 amount;
        uint256 nativeFee; // fee to LZ
        address dstToken;
        uint256 actualQuote; // expected amount out
        uint256 gasDstChain;
        uint256 feePercent;
        uint256 sharePercent;
        uint16 dstChain; // dstChainId in LZ - not network chain id
        uint16 srcPool; // src stable pool id
        uint16 dstPool; // dst stable pool id
        uint16 apiId;
        uint16 userPSFee;
        bool isFromNative;
        string uuid; //integrator uuid (if swap directly by unizen leave it empty "")
    }
    struct ContractStatus {
        uint256 balanceDstBefore;
        uint256 balanceDstAfter;
        uint256 balanceSrcBefore;
        uint256 balanceSrcAfter;
        uint256 totalDstAmount;
    }

    event Swapped(
        uint256 amountIn,
        uint256 amountOut,
        address srcToken,
        address dstToken,
        address receiver,
        address sender,
        uint16 apiId
    );

    event CrossChainSwapped(
        uint16 chainId,
        address user,
        uint256 valueInUSD,
        uint16 apiId
    );

    event CrossChainUTXO(
        address srcToken,
        address vault,
        uint256 amount, 
        uint16 apiId
    );

    function getIntegratorInfor(
        string memory uuid
    ) external view returns (address, uint256, uint256);

    function psFee() external view returns (uint256);

    function integratorFees(string memory uuid) external view returns (uint256);

    function integratorAddrs(
        string memory uuid
    ) external view returns (address);

    function integratorUnizenSFP(
        string memory uuid
    ) external view returns (uint256);

    function psShare() external view returns (uint256);

    function uuidType(string memory uuid) external view returns (uint8);


    function initialize() external;
}


// File contracts/UnizenDexAggrETH.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity >=0.8.0;














contract UnizenDexAggrETH is IUnizenDexAggr, Controller, EthReceiver, ReentrancyGuardUpgradeable, IStargateReceiver {
    using SafeERC20 for IERC20;
    using Address for address payable;

    address public stargateRouter;
    address public layerZeroEndpoint;
    address public stable;
    uint16 public stableDecimal;
    mapping(uint16 => uint16) public chainStableDecimal;
    mapping(uint16 => address) public destAddr;
    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(uint16 => address) public poolToStableAddr;
    uint256 public dstGas;
    address public vipOracle;
    uint256 public tradingFee;
    uint256 public vipFee;
    address public treasury;
    uint256 public psFee;
    mapping(address => uint256) public _psEarned;
    mapping(string => address) public integratorAddrs;
    mapping(string => uint256) public integratorFees;
    mapping(string => uint256) public integratorUnizenSFP;
    address public feeClaimer;
    mapping(address => mapping(address => uint256)) public integratorPSEarned;
    uint256 public psShare; // psShare to KOLs
    mapping(string => uint8) public uuidType;
    uint256 public limitShare;
    mapping(address => mapping(address => uint256)) public integratorClaimed;
    mapping(address => bool) public stargateAddr;
    mapping(address => uint) public unizenFeeEarned;
    address public tcRouter;

    function initialize() external override initializer {
        __UnizenDexAggr_init();
    }

    function __UnizenDexAggr_init() internal onlyInitializing {
        __Controller_init_();
        __ReentrancyGuard_init();
        dstGas = 700000; // 700k gas for destination chain execution as default
    }

    function setStargateAddr(address _stgAddr, bool isValid) external onlyOwner {
        stargateAddr[_stgAddr] = isValid;
    }

    function setLimitShare(uint256 _limitShare) external onlyOwner {
        limitShare = _limitShare;
    }

    function setFeeClaimer(address feeClaimerAddr) external onlyOwner {
        feeClaimer = feeClaimerAddr;
    }

    function setDestAddr(uint16 chainId, address dexAggr) external onlyOwner {
        destAddr[chainId] = dexAggr;
    }

    function setStargateRouter(address router) external onlyOwner {
        require(router != address(0), "Invalid-address");
        stargateRouter = router;
    }

    function setPoolStable(uint16 poolId, address stableAddr) external onlyOwner {
        poolToStableAddr[poolId] = stableAddr;
        if (IERC20(stableAddr).allowance(address(this), stargateRouter) == 0) {
            IERC20(stableAddr).safeApprove(stargateRouter, type(uint256).max);
        }
    }

    function recoverAsset(address token) external onlyOwner {
        if (token == address(0)) {
            payable(msg.sender).sendValue(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            IERC20(token).safeTransfer(msg.sender, balance);
        }
    }

    function revokeApprove(address token, address spender) external onlyOwner {
        IERC20(token).safeApprove(spender, 0);
    }

    function setThorChainRouter(address _router) external onlyOwner {
        tcRouter = _router;
    }

    function executeSwapDstChain(address _srcToken, uint256 _srcAmount, SwapCall[] memory calls) external nonReentrant {
        require(msg.sender == address(this), "Not-unizen");
        _swap(_srcToken, _srcAmount, calls, true);
    }

    function _swap(address _srcToken, uint256 _srcAmount, SwapCall[] memory calls, bool isDstChainSwap) private {
        require(calls[0].sellToken == _srcToken, "Invalid-token");
        uint256 tempAmount;
        uint256 totalSrcAmount;
        IERC20 srcToken;
        for (uint8 i = 0; i < calls.length; ) {
            require(isWhiteListedDex(calls[i].targetExchange), "Not-verified-dex");
            if (calls[i].sellToken == _srcToken) {
                // if trade from source token
                // if not split trade, it will be calls[0]
                // if split trade, we count total amount of souce token we split into routes
                totalSrcAmount += calls[i].amount;
                require(totalSrcAmount <= _srcAmount, "Invalid-amount-to-sell");
            }
            if (calls[i].sellToken == address(0) && !isDstChainSwap) {
                // trade Ethereum, it will be for trade from source token as native, only trade single-chain as if trade dstChain, no native trade
                tempAmount = _executeTrade(
                    calls[i].targetExchange,
                    IERC20(address(0)),
                    IERC20(calls[i].buyToken),
                    calls[i].amount,
                    calls[i].amount,
                    calls[i].data
                );
            } else {
                // trade ERC20
                srcToken = IERC20(calls[i].sellToken);
                srcToken.safeApprove(calls[i].targetExchange, 0);
                srcToken.safeApprove(calls[i].targetExchange, calls[i].amount);

                tempAmount = _executeTrade(
                    calls[i].targetExchange,
                    srcToken,
                    IERC20(calls[i].buyToken),
                    calls[i].amount,
                    0,
                    calls[i].data
                );
                srcToken.safeApprove(calls[i].targetExchange, 0);
            }
            // Here we have to check the tempAmount we got from the trade is higher than sell amount of next, else that mean we got steal fund
            // But if there is split trade with split source token into multi routes, we dont check because first trade of route is trade from source token
            // And we already check totalSrcAmount is under total amount we got
            if (i != calls.length - 1 && calls[i + 1].sellToken != _srcToken) {
                require(tempAmount >= calls[i + 1].amount, "Steal-fund");
                // the next buy token must be the current sell token
                require(calls[i].buyToken == calls[i + 1].sellToken, "Steal-funds");
            }
            unchecked {
                ++i;
            }
        }
    }

    function swapSTG(
        CrossChainSwapSg memory swapInfo,
        SwapCall[] memory calls,
        SwapCall[] memory dstCalls
    ) external payable nonReentrant whenNotPaused {
        require(swapInfo.receiver != address(0), "Invalid-receiver-address");
        ContractStatus memory contractStatus = ContractStatus(0, 0, 0, 0, 0);
        IERC20 srcToken = IERC20(swapInfo.srcToken);
        IERC20 dstToken = IERC20(poolToStableAddr[swapInfo.srcPool]);
        contractStatus.balanceDstBefore = dstToken.balanceOf(address(this));
        if (!swapInfo.isFromNative) {
            srcToken.safeTransferFrom(msg.sender, address(this), swapInfo.amount);
            require(msg.value >= swapInfo.nativeFee, "Not-enough-fee");
        } else {
            require(
                msg.value >= swapInfo.amount + swapInfo.nativeFee && swapInfo.srcToken == address(0),
                "Invalid-amount"
            );
        }
        if (bytes(swapInfo.uuid).length != 0 && swapInfo.feePercent > 0) {
            swapInfo.amount =
                swapInfo.amount -
                _takeIntegratorFee(
                    swapInfo.uuid,
                    swapInfo.isFromNative,
                    srcToken,
                    swapInfo.amount,
                    swapInfo.feePercent,
                    swapInfo.sharePercent
                );
        }
        // execute trade logic
        if (calls.length > 0) {
            _swap(swapInfo.srcToken, swapInfo.amount, calls, false);
        }
        {
            // balance stable after swap, use swapInfo.amount to re-use the memory slot instead of new variables, prevent stack too deep
            contractStatus.balanceDstAfter = dstToken.balanceOf(address(this));
            swapInfo.amount = contractStatus.balanceDstAfter - contractStatus.balanceDstBefore;
            bytes memory payload;
            if (dstCalls.length != 0) {
                payload = abi.encode(
                    swapInfo.receiver,
                    swapInfo.dstToken,
                    swapInfo.actualQuote,
                    swapInfo.uuid,
                    swapInfo.userPSFee,
                    dstCalls
                );
            }

            _sendCrossChain(
                swapInfo.dstChain,
                swapInfo.srcPool,
                swapInfo.dstPool,
                msg.sender,
                swapInfo.nativeFee,
                swapInfo.amount,
                dstCalls.length == 0 ? swapInfo.receiver : destAddr[swapInfo.dstChain],
                swapInfo.gasDstChain,
                payload
            );
            emit CrossChainSwapped(swapInfo.dstChain, msg.sender, swapInfo.amount, swapInfo.apiId);
        }
    }

    function _sendCrossChain(
        uint16 dstChain,
        uint16 srcPool,
        uint16 dstPool,
        address feeReceiver,
        uint256 fee,
        uint256 amount,
        address to,
        uint256 gasDstChain,
        bytes memory payload
    ) private {
        IStargateRouter(stargateRouter).swap{value: fee}(
            dstChain,
            srcPool,
            dstPool,
            payable(feeReceiver),
            amount,
            (amount * 995) / 1000,
            IStargateRouter.lzTxObj(gasDstChain, 0, bytes("")),
            abi.encodePacked(to),
            payload
        );
    }

    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        address _token,
        uint256 amountLD,
        bytes memory payload
    ) external override {
        require(msg.sender == address(stargateRouter) || stargateAddr[msg.sender], "Only-Stargate-Router");
        require(
            _srcAddress.length == abi.encodePacked(destAddr[_chainId]).length &&
                keccak256(_srcAddress) == keccak256(abi.encodePacked(destAddr[_chainId])),
            "Unizen: Not-Unizen"
        );
        (
            address user,
            address dstToken,
            uint256 actualQuote,
            string memory uuid,
            uint16 userPSFee,
            SwapCall[] memory calls
        ) = abi.decode(payload, (address, address, uint256, string, uint16, SwapCall[]));
        ContractStatus memory contractStatus = ContractStatus(0, 0, 0, 0, 0);
        if (dstToken == address(0)) {
            // trade to ETH
            contractStatus.balanceDstBefore = address(this).balance; // eth balance of contract
        } else {
            contractStatus.balanceDstBefore = IERC20(dstToken).balanceOf(address(this));
        }
        contractStatus.balanceSrcBefore = IERC20(_token).balanceOf(address(this));
        // execute trade logic
        // if trade failed, return user stable token and end function
        try this.executeSwapDstChain(_token, amountLD, calls) {} catch {
            IERC20(_token).safeTransfer(user, amountLD);
            emit CrossChainSwapped(_chainId, user, amountLD, 0);
            return;
        }
        // _swap(_token, amountLD, calls, true);
        // Use _nocne to calculate the diff amount of stable _token left from that trade and send it to user, prevent stack too deep
        // _nonce = IERC20(_token).balanceOf(address(this)) + amountLD - contractStatus.balanceSrcBefore;
        // if (_nonce > 0) {
        //     IERC20(_token).safeTransfer(user, _nonce);
        // }

        if (dstToken == address(0)) {
            // trade to ETH
            contractStatus.balanceDstAfter = address(this).balance; // eth balance of contract
            _nonce = contractStatus.balanceDstAfter - contractStatus.balanceDstBefore;
            if (_nonce > 0) {
                payable(user).sendValue(_nonce);
            }
        } else {
            contractStatus.balanceDstAfter = IERC20(dstToken).balanceOf(address(this));
            _nonce = contractStatus.balanceDstAfter - contractStatus.balanceDstBefore;
            if (_nonce > 0) {
                IERC20(dstToken).safeTransfer(user, _nonce);
            }
        }

        emit CrossChainSwapped(_chainId, user, amountLD, 0);
    }

    // *** SWAP ***swapExactOut
    function swapExactOut(
        SwapExactOutInfo memory info,
        SwapCall[] memory calls
    ) external payable whenNotPaused nonReentrant {
        uint256 amountTakenIn = info.amountInMax; // total amount included fee maxium user willing to pay
        bool isETHTrade;
        bool tradeToNative = info.dstToken == address(0) ? true : false;
        IERC20 srcToken = IERC20(info.srcToken);
        IERC20 dstToken = IERC20(info.dstToken);
        if (msg.value > 0) {
            require(amountTakenIn <= msg.value && info.srcToken == address(0), "Invalid-ETH-amount");
            isETHTrade = true;
        } else {
            srcToken.safeTransferFrom(msg.sender, address(this), amountTakenIn);
        }
        require(info.receiver != address(0), "Invalid-receiver");
        //If swap with uuid takeIntegratorFee
        if (bytes(info.uuid).length != 0 && integratorFees[info.uuid] != 0) {
            amountTakenIn =
                amountTakenIn -
                _takeIntegratorFee(info.uuid, isETHTrade, srcToken, amountTakenIn, info.feePercent, info.sharePercent);
        }
        ContractStatus memory contractStatus = ContractStatus(0, 0, 0, 0, 0);
        if (tradeToNative) {
            // swap to ETH
            contractStatus.balanceDstBefore = address(this).balance; // eth balance of contract
        } else {
            // swap to token
            contractStatus.balanceDstBefore = dstToken.balanceOf(address(this));
        }
        // execute trade logic
        _swap(info.srcToken, amountTakenIn, calls, false);
        if (tradeToNative) {
            // swap to ETH
            contractStatus.balanceDstAfter = address(this).balance; // eth balance of contract
        } else {
            // swap to token
            contractStatus.balanceDstAfter = dstToken.balanceOf(address(this));
        }
        contractStatus.totalDstAmount = contractStatus.balanceDstAfter - contractStatus.balanceDstBefore;
        require(contractStatus.totalDstAmount >= info.amountOut, "Return-amount-is-not-enough");
        if (info.dstToken != address(0)) {
            dstToken.safeTransfer(info.receiver, contractStatus.totalDstAmount);
        } else {
            payable(info.receiver).sendValue(contractStatus.totalDstAmount);
        }
        emit Swapped(
            amountTakenIn, //actualTakenIn,
            contractStatus.totalDstAmount,
            info.srcToken,
            info.dstToken,
            info.receiver,
            msg.sender,
            info.apiId
        );
    }

    function swapSimple(SwapExactInInfo memory info, SwapCall memory call) external payable whenNotPaused nonReentrant {
        bool isETHTrade;
        bool tradeToNative = info.dstToken == address(0) ? true : false;
        uint256 amount = info.amountIn;
        IERC20 srcToken = IERC20(info.srcToken);
        IERC20 dstToken = IERC20(info.dstToken);
        if (msg.value > 0) {
            require(msg.value >= amount && info.srcToken == address(0), "Invalid-amount");
            isETHTrade = true;
        } else {
            srcToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        require(info.receiver != address(0), "Invalid-receiver");
        require(info.amountOutMin > 0, "Invalid-amount-Out-min");
        // trade via Integrator or Influencer ref
        if (bytes(info.uuid).length > 0 && integratorFees[info.uuid] > 0) {
            amount =
                amount -
                _takeIntegratorFee(info.uuid, isETHTrade, srcToken, amount, info.feePercent, info.sharePercent);
        }
        require(amount >= call.amount, "Invalid-amount-trade");
        uint256 balanceUserBefore = tradeToNative ? address(info.receiver).balance : dstToken.balanceOf(info.receiver);
        {
            bool success;
            require(isWhiteListedDex(call.targetExchange), "Not-verified-dex");
            // our trade logic here is trade at a single dex and that dex will send amount of dstToken to user directly
            // dex not send token to this contract as we want to save 1 ERC20/native transfer for user
            // we only send call.amount and approve max amount to trade if erc20 is amount, already checked above
            if (isETHTrade) {
                // trade ETH
                (success, ) = call.targetExchange.call{value: call.amount}(call.data);
            } else {
                // trade ERC20
                srcToken.safeApprove(call.targetExchange, 0);
                srcToken.safeApprove(call.targetExchange, amount);
                (success, ) = call.targetExchange.call(call.data);
            }
            require(success, "Trade-failed");
        }
        uint256 balanceUserAfter = tradeToNative ? address(info.receiver).balance : dstToken.balanceOf(info.receiver);
        // use amount as memory variables to not decalre another one
        amount = balanceUserAfter - balanceUserBefore;
        require(amount >= info.amountOutMin, "Unizen: INSUFFICIENT-OUTPUT-AMOUNT");
        emit Swapped(info.amountIn, amount, info.srcToken, info.dstToken, info.receiver, msg.sender, info.apiId);
    }

    // This is a function that using for swap ULDMv3 and also the dex
    //that not support return token to info.receiver but return token to msg.sender, thats mean this contract address
    function swap(SwapExactInInfo memory info, SwapCall[] memory calls) external payable whenNotPaused nonReentrant {
        bool isETHTrade;
        bool tradeToNative = info.dstToken == address(0) ? true : false;
        uint256 amount = info.amountIn;
        IERC20 srcToken = IERC20(info.srcToken);
        IERC20 dstToken = IERC20(info.dstToken);
        if (msg.value > 0) {
            require(msg.value >= amount && info.srcToken == address(0), "Invalid-amount");
            isETHTrade = true;
        } else {
            srcToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        require(info.receiver != address(0), "Invalid-receiver");
        require(info.amountOutMin > 0, "Invalid-amount-Out-min");
        // trade via Integrator or Influencer ref
        if (bytes(info.uuid).length > 0 && integratorFees[info.uuid] > 0) {
            amount =
                amount -
                _takeIntegratorFee(info.uuid, isETHTrade, srcToken, amount, info.feePercent, info.sharePercent);
        }
        uint256 balanceDstBefore;
        if (tradeToNative) {
            // swap to ETH
            balanceDstBefore = address(this).balance; // eth balance of contract
        } else {
            // swap to token
            balanceDstBefore = dstToken.balanceOf(address(this));
        }
        // execute trade logic
        _swap(info.srcToken, amount, calls, false);
        uint256 balanceDstAfter;
        if (tradeToNative) {
            // swap to ETH
            balanceDstAfter = address(this).balance; // eth balance of contract
        } else {
            // swap to token
            balanceDstAfter = dstToken.balanceOf(address(this));
        }
        // re-use amount variables to prevent stack too deep
        amount = balanceDstAfter - balanceDstBefore;
        require(amount >= info.amountOutMin, "Return-amount-is-not-enough");

        if (tradeToNative) {
            payable(info.receiver).sendValue(amount);
        } else {
            dstToken.safeTransfer(info.receiver, amount);
        }

        emit Swapped(info.amountIn, amount, info.srcToken, info.dstToken, info.receiver, msg.sender, info.apiId);
    }

    function swapTC(SwapTC memory info, SwapCall[] memory calls) external payable whenNotPaused nonReentrant {
        require(info.amountOutMin > 0, "Invalid-amount-Out-min"); // prevent mev attack
        bool isETHTrade;
        uint256 amount = info.amountIn;
        IERC20 srcToken = IERC20(info.srcToken);
        IERC20 dstToken = IERC20(info.dstToken);
        if (msg.value > 0) {
            require(msg.value >= amount && info.srcToken == address(0), "Invalid-amount");
            isETHTrade = true;
        } else {
            srcToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        // trade via Integrator or Influencer ref
        if (bytes(info.uuid).length > 0 && info.feePercent > 0) {
            amount =
                amount -
                _takeIntegratorFee(info.uuid, isETHTrade, srcToken, amount, info.feePercent, info.sharePercent);
        }
        if (isETHTrade) {
            // deposit directly to ThorchainRouter
            ITcRouter(tcRouter).depositWithExpiry{value: amount}(
                payable(info.vault),
                address(0),
                amount,
                info.memo,
                info.deadline
            );
            emit CrossChainUTXO(address(0), info.vault, amount, info.apiId);
            return;
        }

        // execute trade logic, swap from tokens to stable
        if (calls.length > 0) {
            uint256 balanceDstBefore = dstToken.balanceOf(address(this));
            _swap(info.srcToken, amount, calls, false);
            uint256 balanceDstAfter = dstToken.balanceOf(address(this));
            uint256 totalDstAmount = balanceDstAfter - balanceDstBefore;
            require(totalDstAmount >= info.amountOutMin, "Slippage");
            dstToken.safeApprove(tcRouter, 0);
            dstToken.safeApprove(tcRouter, totalDstAmount);
            ITcRouter(tcRouter).depositWithExpiry(
                payable(info.vault),
                info.dstToken,
                totalDstAmount,
                info.memo,
                info.deadline
            );
             emit CrossChainUTXO(info.dstToken, info.vault, totalDstAmount, info.apiId);
        } else {
            // no swap, use stable
            require(info.srcToken == info.dstToken, "Wrong-Token"); 
            dstToken.safeApprove(tcRouter, 0);
            dstToken.safeApprove(tcRouter, amount);
            ITcRouter(tcRouter).depositWithExpiry(payable(info.vault), info.dstToken, amount, info.memo, info.deadline);
            emit CrossChainUTXO(info.dstToken, info.vault, amount, info.apiId);
        }
    }

    function _executeTrade(
        address _targetExchange,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmount,
        uint256 _nativeAmount,
        bytes memory _data
    ) internal returns (uint256) {
        uint256 balanceBeforeTrade = address(sellToken) == address(0)
            ? address(this).balance
            : sellToken.balanceOf(address(this));
        uint256 balanceBuyTokenBefore = address(buyToken) == address(0)
            ? address(this).balance
            : buyToken.balanceOf(address(this));
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = _targetExchange.call{value: _nativeAmount}(_data);
        require(success, "Call-Failed");
        uint256 balanceAfterTrade = address(sellToken) == address(0)
            ? address(this).balance
            : sellToken.balanceOf(address(this));
        require(balanceAfterTrade >= balanceBeforeTrade - sellAmount, "Some-one-steal-fund");
        uint256 balanceBuyTokenAfter = address(buyToken) == address(0)
            ? address(this).balance
            : buyToken.balanceOf(address(this));
        return (balanceBuyTokenAfter - balanceBuyTokenBefore);
    }

    function setIntegrator(
        string memory uuid,
        address integratorAddr,
        uint256 feePercent,
        uint256 share,
        uint8 _type
    ) external onlyOwner {
        require(integratorAddr != address(0));
        integratorAddrs[uuid] = integratorAddr;
        uuidType[uuid] = _type;
        if (_type == 1) {
            // integrators
            integratorFees[uuid] = feePercent;
            integratorUnizenSFP[uuid] = share;
        }
    }

    function _takeIntegratorFee(
        string memory uuid,
        bool isETHTrade,
        IERC20 token,
        uint256 amount,
        uint256 feePercent,
        uint256 sharePercent
    ) private returns (uint256 totalFee) {
        uint256 unizenFee;
        totalFee = (amount * feePercent) / 10000;
        //Collect integrator unizen shared fee
        if (sharePercent > 0) {
            unizenFee = (totalFee * sharePercent) / 10000;
            unizenFeeEarned[address(token)] = unizenFeeEarned[address(token)] + unizenFee;
        }
        if (isETHTrade) {
            payable(integratorAddrs[uuid]).sendValue(totalFee - unizenFee);
        } else {
            token.safeTransfer(integratorAddrs[uuid], totalFee - unizenFee);
        }
        return totalFee;
    }

    function getIntegratorInfor(string memory uuid) external view override returns (address, uint256, uint256) {
        return (integratorAddrs[uuid], integratorFees[uuid], integratorUnizenSFP[uuid]);
    }

    function unizenWithdrawPS(address payable receiver, address[] calldata tokens) external onlyOwner {
        require(receiver != address(0), "Invalid-address");
        for (uint256 i; i < tokens.length; i++) {
            if (_psEarned[tokens[i]] > 0) {
                IERC20(tokens[i]).safeTransfer(receiver, _psEarned[tokens[i]]);
                _psEarned[tokens[i]] = 0;
            }
        }
        if (_psEarned[address(0)] > 0) {
            receiver.call{value: _psEarned[address(0)]}("");
            _psEarned[address(0)] = 0;
        }
    }

    function unizenWithdrawEarnedFee(address payable receiver, address[] calldata tokens) external onlyOwner {
        for (uint256 i; i < tokens.length; i++) {
            if (unizenFeeEarned[tokens[i]] > 0) {
                IERC20(tokens[i]).safeTransfer(receiver, unizenFeeEarned[tokens[i]]);
                unizenFeeEarned[tokens[i]] = 0;
            }
        }

        if (unizenFeeEarned[address(0)] > 0) {
            receiver.call{value: unizenFeeEarned[address(0)]}("");
            unizenFeeEarned[address(0)] = 0;
        }
    }

    function integratorsWithdrawPS(address[] calldata tokens) external nonReentrant {
        address integratorAddr = msg.sender;
        for (uint256 i; i < tokens.length; i++) {
            if (integratorPSEarned[integratorAddr][tokens[i]] > 0) {
                IERC20(tokens[i]).safeTransfer(integratorAddr, integratorPSEarned[integratorAddr][tokens[i]]);
                integratorClaimed[integratorAddr][tokens[i]] += integratorPSEarned[integratorAddr][tokens[i]];
                integratorPSEarned[integratorAddr][tokens[i]] = 0;
            }
        }
        if (integratorPSEarned[integratorAddr][address(0)] > 0) {
            integratorAddr.call{value: integratorPSEarned[integratorAddr][address(0)]}("");
            integratorClaimed[integratorAddr][address(0)] += integratorPSEarned[integratorAddr][address(0)];
            integratorPSEarned[integratorAddr][address(0)] = 0;
        }
    }
}