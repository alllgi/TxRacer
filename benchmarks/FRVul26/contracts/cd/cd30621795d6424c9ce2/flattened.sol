// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol

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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol

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

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol

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

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol

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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol

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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

// EIP-2612 is Final as of 2022-11-01. This file is deprecated.

// File: contracts/helpers/Constants.sol

pragma solidity ^0.8.0;

library XBridgeConstants {
    address public constant NATIVE_TOKEN = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    /// @dev WETH address is network-specific and needs to be changed before deployment.
    /// It can not be moved to immutable as immutables are not supported in assembly
    // ETH:     C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    // BSC:     bb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // OEC:     8F8526dbfd6E38E3D8307702cA8469Bae6C56C15
    // LOCAL:   5FbDB2315678afecb367f032d93F642f64180aa3
    // LOCAL2:  02121128f1Ed0AdA5Df3a87f42752fcE4Ad63e59
    // POLYGON: 0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270
    // AVAX:    B31f66AA3C1e785363F0875A1B74E27b85FD66c7
    // FTM:     21be370D5312f44cB42ce377BC9b8a0cEF1A4C83
    // ARB:     82aF49447D8a07e3bd95BD0d56f35241523fBab1
    // OP:      4200000000000000000000000000000000000006
    // CRO:     5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23
    // CFX:     14b2D3bC65e74DAE1030EAFd8ac30c533c976A9b
    // POLYZK   4F9A0e7FD2Bf6067db6994CF12E4495Df938E6e9
    // MANTA    0Dc808adcE2099A9F62AA87D9670745AbA741746
    // METIS    75cb093E4D61d2A2e65D8e0BBb01DE8d89b53481
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // ETH:     70cBb871E8f30Fc8Ce23609E9E0Ea87B6b222F58
    // ETH-DEV：02D0131E5Cc86766e234EbF1eBe33444443b98a3
    // BSC:     d99cAE3FAC551f6b6Ba7B9f19bDD316951eeEE98
    // OEC:     E9BBD6eC0c9Ca71d3DcCD1282EE9de4F811E50aF
    // LOCAL:   e7f1725E7734CE288F8367e1Bb143E90bb3F0512
    // LOCAL2:  95D7fF1684a8F2e202097F28Dc2e56F773A55D02
    // POLYGON: 40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
    // AVAX:    70cBb871E8f30Fc8Ce23609E9E0Ea87B6b222F58
    // FTM:     E9BBD6eC0c9Ca71d3DcCD1282EE9de4F811E50aF
    // ARB:     E9BBD6eC0c9Ca71d3DcCD1282EE9de4F811E50aF
    // ARB_DEV: eDC3a1C195591968488cA2E41E54d5Ac6c8016e2
    // OP:      100F3f74125C8c724C7C0eE81E4dd5626830dD9a
    // CRO:     E9BBD6eC0c9Ca71d3DcCD1282EE9de4F811E50aF
    // CFX:     100F3f74125C8c724C7C0eE81E4dd5626830dD9a
    // POLYZK   1b5d39419C268b76Db06DE49e38B010fbFB5e226
    // MANTA    1b5d39419C268b76Db06DE49e38B010fbFB5e226
    // METIS    1b5d39419C268b76Db06DE49e38B010fbFB5e226
    address public constant APPROVE_PROXY = 0x70cBb871E8f30Fc8Ce23609E9E0Ea87B6b222F58;

    // ETH:     5703B683c7F928b721CA95Da988d73a3299d4757
    // BSC:     0B5f474ad0e3f7ef629BD10dbf9e4a8Fd60d9A48
    // OEC:     d99cAE3FAC551f6b6Ba7B9f19bDD316951eeEE98
    // LOCAL:   D49a0e9A4CD5979aE36840f542D2d7f02C4817Be
    // LOCAL2:  11457D5b1025D162F3d9B7dBeab6E1fBca20e043
    // POLYGON: f332761c673b59B21fF6dfa8adA44d78c12dEF09
    // AVAX:    3B86917369B83a6892f553609F3c2F439C184e31
    // FTM:     40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
    // ARB:     d99cAE3FAC551f6b6Ba7B9f19bDD316951eeEE98
    // ARB_DEV: C183cFF4aC3B6D2b9405D856143C35a36E4C8710
    // OP:      40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
    // CRO:     40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
    // CFX:     40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
    // POLYZK   d2F0aC2012C8433F235c8e5e97F2368197DD06C7
    // MANTA    d2F0aC2012C8433F235c8e5e97F2368197DD06C7
    // METIS    d2F0aC2012C8433F235c8e5e97F2368197DD06C7
    address public constant WNATIVE_RELAY = 0x5703B683c7F928b721CA95Da988d73a3299d4757;
    
    // sysRatio
    uint256 public constant GAS_TOKEN_RECEIVE_MAX_INDEX = 1;
    uint256 public constant CLAIM_TOKEN_RATIO_MAX_INDEX = 2;
    uint256 public constant CHAIN_ID_INDEX              = 3;

    // sysAddressConfig
    // uint256 public constant ORACLE_ADDRESS_INDEX = 1; // deprecated

    uint256 public constant DEFAULT_RATIO_BASE = 100;

    uint256 public constant ADAPTER_ID_ANYSWAP = 1;
    uint256 public constant ADAPTER_ID_CBRIDGE = 2;
    uint256 public constant ADAPTER_ID_SWFT    = 3;

    string public constant __REFUND__ = string("__refund__");
}

// File: contracts/helpers/Errors.sol

pragma solidity ^0.8.0;

library XBridgeErrors {
    string internal constant ONLY_X_BRIDGE = "only XBridge";
    string internal constant ONLY_MPC = "only mpc";
    string internal constant ONLY_ADMIN = "only admin";
    string internal constant ADDRESS_0 = "address 0";
    string internal constant LENGTH_NOT_EQUAL = "length not equal";
    string internal constant DEX_ROUTER_ERR = "dex router err : ";
    string internal constant ADDRESS_EQUAL = "address equal";
    string internal constant ADDRESS_NOT_EQUAL = "address not equal";
    string internal constant MIN_AMOUNT_ERR = "min amount err";
    string internal constant REFUND_ETH_ERROR = "refund eth err";
    string internal constant REFUND_EXIST = "refund exist";
    string internal constant CBRIDGE_HAS_WITHDRAW = "has withdraw";
    string internal constant HAS_PAID = "has paid";
    string internal constant HAS_RECEIVE_GAS = "has receive gas";
    string internal constant NO_ENOUGH_MONEY = "no enough money";
    string internal constant SLASH_MUCH_TOO_MONEY = "slash much too money";
    string internal constant ERROR_SELECTOR_ID = "err selector id";
    string internal constant EXCEED_ALLOWED_GAS = "exceed allowed gas";
    string internal constant ALLOWANCE_NOT_ENOUGH = "allowance not enough";
    string internal constant ORACLE_NO_INFO = "claim no oracle info";
    string internal constant ORACLE_TO_ADDRESS_ERR = "claim to address err";
    string internal constant ORACLE_TOKEN_ADDRESS_ERR = "claim token address err";
    string internal constant ORACLE_TOKEN_AMOUNT_ERR = "claim token amount err";
    string internal constant NOT_ORACLE_PROXY = "not oracle proxy";
    string internal constant ERR_CHAIN_ID = "err chain id";
    string internal constant ZERO_SIGNER = "zero signer";
    string internal constant CONTRACT_ADDRESS_ERROR = "contract address error";
    string internal constant INTERNAL_WRAP_FAIL = "internal wrap fail";
    string internal constant WRAP_AMOUNT_ZERO = "wrap amount must be > 0";
    string internal constant TRANSFER_ETH_FAILD = "ETH transfer failed";
    string internal constant AMOUNT_ZERO = "amount must be > 0";
    string internal constant MIN_AMOUNT_ZERO = "min amount must be > 0";
    string internal constant LEFT_VALUE_NOT_ZERO = "left value must be 0";

    string internal constant NOT_SUPPORT_CHAIN = "not support chain";
    string internal constant NOT_SUPPORT_TOKEN = "not support token";
    string internal constant AMOUNT_NOT_EQ_VALUE = "amount must == msg.value";
    string internal constant VALUE_NOT_ENOUGH = "amount must <= msg.value";
    string internal constant VALUE_MUST_ZERO = "msg.value == 0";
    string internal constant INVALID_ADAPTOR_ID = "invalid adaptorID";
    string internal constant INVALID_ADAPTOR_ADDRESS = "invalid adaptor address";
    string internal constant INVALID_ROUTER = "invalid router";
    string internal constant INVALID_MSG_VALUE = "invalid msg value";

    string internal constant COMMISSION_ERROR_RATE = "error commission rate limit";
    string internal constant COMMISSION_ERROR_ETHER = "commission with ether error";
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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

// File: @openzeppelin/contracts/utils/Address.sol

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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

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

// File: @openzeppelin/contracts/access/Ownable.sol

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

// File: contracts/adaptor/BridgeAdaptorBase.sol

pragma solidity ^0.8.0;
pragma abicoder v2;








/// @title BridgeAdaptorBase
/// @notice All Bridge adaptor must implement it
/// @dev All Bridge adaptor must implement it
abstract contract BridgeAdaptorBase is Ownable {
    using SafeERC20 for IERC20;

    address public immutable xBridge;

    mapping(address => bool) public routers;

    constructor(address _xBridge, address[] memory _routersList) {
        require(_xBridge != address(0), XBridgeErrors.ADDRESS_0);
        xBridge = _xBridge;
        for (uint256 i = 0; i < _routersList.length; i++) {
            routers[_routersList[i]] = true;
        }
    }

    //-------------------------------
    //------- Events ----------------
    //-------------------------------
    event LogOutboundBridgeTo(address _from, address _to, address _token, uint256 _amount, bytes32 _extraData);

    event EmergencyWithdraw(address indexed _to, address _token, uint amount);

    //-------------------------------
    //------- Modifier --------------
    //-------------------------------
    modifier onlyXBridge() {
        require(msg.sender == xBridge, XBridgeErrors.ONLY_X_BRIDGE);
        _;
    }

    //-------------------------------
    //------- Internal Functions ----
    //-------------------------------
    function _approve(address token, address spender, uint256 amount) internal {
        if (IERC20(token).allowance(address(this), spender) == 0) {
            IERC20(token).safeApprove(spender, amount);
        } else {
            IERC20(token).safeApprove(spender, 0);
            IERC20(token).safeApprove(spender, amount);
        }
    }

    function _approve2(address token, address spender, uint256 amount) internal {
        uint256 preAllowance = IERC20(token).allowance(address(this), spender);
        if (preAllowance == 0) {
            IERC20(token).safeApprove(spender, type(uint256).max);
        } else if (preAllowance < amount){
            IERC20(token).safeApprove(spender, 0);
            IERC20(token).safeApprove(spender, type(uint256).max);
        }
    }
    //-------------------------------
    //------- Admin functions -------
    //-------------------------------
    function setRouters(address[] calldata _routersList, bool[] calldata _v) public onlyOwner {
        for (uint256 i = 0; i < _routersList.length; i++) {
            routers[_routersList[i]] = _v[i];
        }
    }

    // workaround for a possible solidity bug
    function withdrawEmergency(address _to, address _token, uint _amount) public onlyOwner {
        if (_token == XBridgeConstants.NATIVE_TOKEN) {
            payable(_to).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }
        emit EmergencyWithdraw(_to, _token, _amount);
    }

    //-------------------------------
    //------- Users Functions -------
    //-------------------------------
    function outboundBridgeTo(
        address _from,
        address _to,
        address _refundAddress,
        address _token,
        uint256 _amount,
        uint256 _toChainId,
        bytes memory _data
    ) external payable virtual;

    receive() external payable {}
}

// File: contracts/interfaces/IDaiLikePermit.sol

pragma solidity ^0.8.0;

/// @title Interface for DAI-style permits
interface IDaiLikePermit {
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File: contracts/interfaces/IApproveProxy.sol

pragma solidity ^0.8.0;

interface IApproveProxy {
    function owner() external view returns (address);
    
    function isAllowedProxy(address _proxy) external view returns (bool);

    function claimTokens(
        address token,
        address who,
        address dest,
        uint256 amount
    ) external;

    function tokenApprove() external view returns (address);

    function addProxy(address _newProxy) external;
}

// File: contracts/interfaces/IWNativeRelayer.sol

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IWNativeRelayer {
    function owner() external view returns (address);
    function withdraw(uint256 _amount) external;
    function setCallerOk(address[] calldata whitelistedCallers, bool isOk) external;
}

// File: contracts/interfaces/IWETH.sol

pragma solidity ^0.8.0;
pragma abicoder v2;


interface IWETH {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// File: contracts/libraries/Bytes.sol

pragma solidity ^0.8.0;

library Bytes {
    function bytesToBytes32Array(bytes memory data)
        internal
        pure
        returns (bytes32[] memory dataList)
    {
        uint256 N = (data.length + 31) / 32;
        dataList = new bytes32[](N);
        for (uint256 index = 0; index < N; index++) {
            bytes32 element;
            uint256 start = 32 + index * 32;
            assembly {
                element := mload(add(data, start))
            }
            dataList[index] = element;
        }
    }
}

// File: contracts/libraries/RevertReasonParser.sol

pragma solidity ^0.8.0;

/// @title Library that allows to parse unsuccessful arbitrary calls revert reasons.
/// See https://solidity.readthedocs.io/en/latest/control-structures.html#revert for details.
/// Note that we assume revert reason being abi-encoded as Error(string) so it may fail to parse reason
/// if structured reverts appear in the future.
///
/// All unsuccessful parsings get encoded as Unknown(data) string
library RevertReasonParser {
    bytes4 private constant _PANIC_SELECTOR =
        bytes4(keccak256("Panic(uint256)"));
    bytes4 private constant _ERROR_SELECTOR =
        bytes4(keccak256("Error(string)"));

    function parse(bytes memory data, string memory prefix)
        internal
        pure
        returns (string memory)
    {
        if (data.length >= 4) {
            bytes4 selector;
            assembly {
                // solhint-disable-line no-inline-assembly
                selector := mload(add(data, 0x20))
            }

            // 68 = 4-byte selector + 32 bytes offset + 32 bytes length
            if (selector == _ERROR_SELECTOR && data.length >= 68) {
                uint256 offset;
                bytes memory reason;
                // solhint-disable no-inline-assembly
                assembly {
                    // 36 = 32 bytes data length + 4-byte selector
                    offset := mload(add(data, 36))
                    reason := add(data, add(36, offset))
                }
                /*
                    revert reason is padded up to 32 bytes with ABI encoder: Error(string)
                    also sometimes there is extra 32 bytes of zeros padded in the end:
                    https://github.com/ethereum/solidity/issues/10170
                    because of that we can't check for equality and instead check
                    that offset + string length + extra 36 bytes is less than overall data length
                */
                require(
                    data.length >= 36 + offset + reason.length,
                    "Invalid revert reason"
                );
                return string(abi.encodePacked(prefix, "Error(", reason, ")"));
            }
            // 36 = 4-byte selector + 32 bytes integer
            else if (selector == _PANIC_SELECTOR && data.length == 36) {
                uint256 code;
                // solhint-disable no-inline-assembly
                assembly {
                    // 36 = 32 bytes data length + 4-byte selector
                    code := mload(add(data, 36))
                }
                return
                    string(
                        abi.encodePacked(prefix, "Panic(", _toHex(code), ")")
                    );
            }
        }

        return string(abi.encodePacked(prefix, "Unknown(", _toHex(data), ")"));
    }

    function _toHex(uint256 value) private pure returns (string memory) {
        return _toHex(abi.encodePacked(value));
    }

    function _toHex(bytes memory data) private pure returns (string memory) {
        bytes16 alphabet = 0x30313233343536373839616263646566;
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 * i + 2] = alphabet[uint8(data[i] >> 4)];
            str[2 * i + 3] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}

// File: contracts/libraries/CommissionLib.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract CommissionLib {
    /** 
    * commissionInfo uint256
    * commissionInfo = flag + commissionRate + referrerAddress
    * [  48 bits  |      48 bits     |      160 bits     ]
    * [    flag   |  commissionRate  |  referrerAddress  ]
    * [ MSB                                          LSB ]
    */
    uint256 internal constant _REFERRER_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 internal constant _COMMISSION_FEE_MASK = 0x000000000000ffffffffffff0000000000000000000000000000000000000000;
    uint256 internal constant _COMMISSION_FLAG_MASK = 0xffffffffffff0000000000000000000000000000000000000000000000000000;
    uint256 internal constant OKX_COMMISSION = 0x3ca20afc2aaa0000000000000000000000000000000000000000000000000000;

    event CommissionRecord(uint256 commissionAmount, address referrerAddress);
    
    // set default vaule. can change when need.
    uint256 public constant commissionRateLimit = 300;
}

// File: contracts/XBridge.sol

pragma solidity ^0.8.0;
pragma abicoder v2;





















/**
 * @title XBridge
 * @notice Entrance for Bridge
 * - Users can:
 *   # Bridge: Initiate cross-chain asset transfers.
 *   # Swap and bridge: Perform token swaps and initiate cross-chain transfers.
 * @dev XBridge is a smart contract that serves as the entrance for cross-chain operations,
 * allowing users to interact with various functionalities such as bridging assets,
 * swapping and bridging tokens, and claiming assets on the destination chain.
 */
contract XBridge is PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, CommissionLib {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Struct representing the information needed for a bridge transaction
    struct BridgeRequestV2 {
        uint256 adaptorId;
        address to;
        address token;
        uint256 toChainId; // orderId[64bit] | gasFeeAmount[160] | target chainId[32bit]
        uint256 amount;
        bytes   data;      // router data
        bytes   extData;
    }

    // Struct representing the information needed for a swap and bridge transaction
    struct SwapBridgeRequestV2 {
        address fromToken;                // the source token
        address toToken;                  // the token to be bridged
        address to;                       // the address to be bridged to
        uint256 adaptorId;
        uint256 toChainId;                // orderId[64bit] | gasFeeAmount[160] | target chainId[32bit]
        uint256 fromTokenAmount;          // the source token amount
        uint256 toTokenMinAmount;
        uint256 toChainToTokenMinAmount;
        bytes   data;                     // router data
        bytes   dexData;                  // the call data for dexRouter
        bytes   extData;
    }

    // Struct representing the information needed for a swap transaction
    struct SwapRequest {
        address fromToken;
        address toToken;
        address to;
        uint256 amount; // amount of swapped fromToken
        uint256 gasFeeAmount; // tx gas fee slash from fromToken
        uint256 srcChainId;
        bytes32 srcTxHash;
        bytes   dexData;
        bytes   extData;
    }

    // Struct representing the information needed for receiving gas tokens on another chain
    struct ReceiveGasRequest {
        address to;
        uint256 amount;
        uint256 srcChainId;
        bytes32 srcTxHash;
        bytes   extData;
    }

    // Struct representing a threshold configuration for a specific address
    struct Threshold {
        bool    opened;
        uint256 amount;
    }

    // Struct representing information related to an oracle, used for verifying certain transactions
    struct OracleInfo {
        uint256 srcChainId;
        bytes32 txHash;
        bytes32 to;
        bytes32 token;
        uint256 amount;
        uint256 actualAmount;
    }

    //-------------------------------
    //------- storage ---------------
    //-------------------------------
    mapping(uint256 => address) public adaptorInfo;

    /**
     * @dev This state variable is deprecated and should not be used anymore.
     */
    address public approveProxy;

    address public dexRouter;

    address public payer;

    address public receiver;

    address public feeTo;

    address public admin;

    mapping(address => bool) public mpc;

    mapping(uint256 => mapping(bytes32 => bool)) public paidTx;

    mapping(uint256 => mapping(bytes32 => bool)) public receiveGasTx;

    /**
     * @dev Set by admin
     */
    mapping(uint256 => uint256) public sysRatio;

    /**
     * @dev This state variable is deprecated and should not be used anymore.
     */
    mapping(uint256 => address) public sysAddressConfig;

    mapping(address => Threshold) public thresholdConfig;

    mapping(address => bool) public proxies; // oracle proxy

    mapping(bytes4 => bool) public accessSelectorId; // for swap

    /**
     * @notice Initializes the XBridge contract.
     * @dev This function is part of the Upgradable pattern and is called once to initialize contract state.
     * It sets up the initial state by invoking the initializers of the inherited contracts.
     * The `admin` variable is set to the address of the account that deploys the contract.
     * Note: This function is meant to be called only once during the contract deployment.
     */
    function initialize() public initializer {
        __Pausable_init();
        __ReentrancyGuard_init();
        __Ownable_init();
        admin = msg.sender;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    //-------------------------------
    //------- Events ----------------
    //-------------------------------
    event DexRouterChanged(address _dexRouter);

    /**
     * @notice Event emitted when a bridge transaction occurs
     */
    event LogBridgeTo(
        uint256 indexed _adaptorId,
        address _from,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _receiveFee,
        bytes32[] ext
    );

    /**
     * @notice Event emitted when a swap and bridge transaction occurs
     */
    event LogSwapAndBridgeTo(
        uint256 indexed _adaptorId,
        address _from,
        address _to,
        address _fromToken,
        uint256 _fromAmount,
        address _toToken,
        uint256 _toAmount,
        uint256 _receiveFee,
        bytes32[] ext
    );
    event FeeToChanged(address _feeTo);

    event AdminChanged(address _newAdmin);

    event GasTokenReceived(
        address to,
        uint256 amount,
        uint256 srcChainId,
        bytes32[] ext
    );

    /**
     * @notice Event emitted when a claim transaction occurs
     */
    event Claimed(
        address to,
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 toTokenAmount,
        uint256 gasFeeAmount,
        uint256 srcChainId,
        string  errInfo,
        bytes32[] ext
    );

    event AdaptorsChanged(uint256 indexed _adaptorId, address _adaptor);

    event MpcChanged(address _mpc, bool _enable);

    event SysRatioChanged(uint256 _index, uint256 _ratio);

    event ProxiesChanged(address _proxy, bool _enable);

    event AccessSelectorIdChanged(bytes4 _selectorId, bool _enable);
    //-------------------------------
    //------- Modifier --------------
    //-------------------------------

    modifier onlyMPC() {
        require(mpc[msg.sender], XBridgeErrors.ONLY_MPC);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, XBridgeErrors.ONLY_ADMIN);
        _;
    }

    //-------------------------------
    //------- Internal Functions ----
    //-------------------------------

    /**
     * @notice Internal pure function to extract information from a packed uint256 value representing gas receive details
     * @param toChainId Packed uint256 value containing order ID, gas fee amount, and chain ID
     */
    function _getGasReceiveAmount(uint256 toChainId)
        internal
        pure
        returns (
            uint256 orderId,
            uint256 gasFeeAmount,
            uint256 chainId
        )
    {
        orderId      = (toChainId & 0xffffffffffffffff000000000000000000000000000000000000000000000000) >> 192;
        gasFeeAmount = (toChainId & 0x0000000000000000ffffffffffffffffffffffffffffffffffffffff00000000) >> 32;
        chainId      =  toChainId & 0x00000000000000000000000000000000000000000000000000000000ffffffff;
    }

    /**
     * @notice Internal function to perform a token deposit operation.
     * @dev Ensures that the caller has sufficient allowance to deposit the specified amount of tokens.
     * @param from The address from which tokens are transferred.
     * @param to The recipient address to receive the deposited tokens.
     * @param token The address of the ERC20 token being deposited.
     * @param amount The amount of tokens to be deposited.
    */
    function _deposit(
        address from,
        address to,
        address token,
        uint256 amount
    ) internal {
        IApproveProxy(XBridgeConstants.APPROVE_PROXY).claimTokens(token, from, to, amount);
    }

    function _getBalanceOf(address token) internal view returns (uint256) {
        return _getBalanceOf(token, address(this));
    }

    function _getBalanceOf(address token, address who) internal view returns(uint256) {
        return token == XBridgeConstants.NATIVE_TOKEN ? who.balance : IERC20Upgradeable(token).balanceOf(who);
    }


    /**
     * @notice Internal function to transfer ERC20 tokens or native tokens (ETH) to a specified address.
     * @param to The address to which tokens are transferred.
     * @param token The address of the ERC20 token to be transferred.
     * @param amount The amount of tokens to be transferred.
     */
    function _transferToken(address to, address token, uint256 amount) internal {
        if (amount > 0) {
            if (token == XBridgeConstants.NATIVE_TOKEN) {
                (bool success, ) = payable(to).call{value: amount}("");
                require(success, XBridgeErrors.TRANSFER_ETH_FAILD);
            } else {
                IERC20Upgradeable(token).safeTransfer(to, amount);
            }
        }
    }

    /**
     * @notice Internal pure function to construct extension data for cross-chain transaction.
     * @param orderId The unique identifier for the cross-chain transaction.
     * @param toChainId The identifier of the target chain.
     * @param adaptorId The identifier of the cross-chain adaptor used.
     * @param to The destination address on the target chain.
     * @param data Additional data specific to the cross-chain adaptor.
     * @param extData Additional extension data containing user-specific information.
     * @return ext An array of bytes32 values representing the constructed extension data.
     */
    function _constructExt(uint256 orderId, uint256 toChainId, uint256 adaptorId, address to, bytes memory data, bytes memory extData)
        internal
        pure
        returns(bytes32[] memory ext)
    {
        ext = new bytes32[](6);
        ext[0] = bytes32(orderId);
        ext[1] = bytes32(toChainId);

        if (adaptorId == XBridgeConstants.ADAPTER_ID_ANYSWAP
                || adaptorId == XBridgeConstants.ADAPTER_ID_CBRIDGE) {
            ext[2] = bytes32(abi.encodePacked(to));
            ext[3] = bytes32(abi.encodePacked(""));
        } else if (adaptorId == XBridgeConstants.ADAPTER_ID_SWFT) {
            (,,string memory destination,) = abi.decode(data, (address, string, string, uint256));
            bytes32[] memory destBytes32Arr = Bytes.bytesToBytes32Array(bytes(destination));
            ext[2] = destBytes32Arr[0];
            if (destBytes32Arr.length > 1) {
                ext[3] = destBytes32Arr[1];
            }
        }
        if (extData.length > 0) {
            (string memory userAddress) = abi.decode(extData, (string));
            bytes32[] memory userAddressBytes32Arr = Bytes.bytesToBytes32Array(bytes(userAddress));
            ext[4] = userAddressBytes32Arr[0];
            if (userAddressBytes32Arr.length > 1) {
                ext[5] = userAddressBytes32Arr[1];
            }
        } else {
            ext[4] = ext[2];
            ext[5] = ext[3];
        }
        return ext;
    }

    /**
     * @notice Struct to represent the result of a commission operation.
     */
    struct CommissionReturn {
        uint256 commissionAmount;  // commission amount
        bytes extDataWithoutLast32;  // extData without last 32 bytes
    }

    /**
     * @notice Internal function to initiate a cross-chain transaction using the specified BridgeRequestV2 parameters.
     * @param _request The BridgeRequestV2 struct containing transaction details.
     * @dev Performs necessary validations, token transfers, and calls the outboundBridgeTo function on the selected adaptor.
     */
    function _bridgeToV2Internal(BridgeRequestV2 memory _request) internal {
        require(_request.adaptorId != 0, XBridgeErrors.INVALID_ADAPTOR_ID);
        address adaptor = adaptorInfo[_request.adaptorId];
        require(adaptor != address(0), XBridgeErrors.INVALID_ADAPTOR_ADDRESS);
        require(_request.to != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.token != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.amount != 0, XBridgeErrors.AMOUNT_ZERO);

        // doCommission
        CommissionReturn memory vars;
        (vars.commissionAmount, vars.extDataWithoutLast32) = _doCommission(_request.amount, _request.token, _request.extData);
        _request.extData = vars.extDataWithoutLast32;
        uint256 ethValue = msg.value;

        // Extract gas fee details from toChainId
        (uint256 orderId, uint256 gasFeeAmount, uint256 toChainId) = _getGasReceiveAmount(_request.toChainId);
        if (_request.token == XBridgeConstants.NATIVE_TOKEN) {
            require(msg.value >= _request.amount + gasFeeAmount + vars.commissionAmount, XBridgeErrors.INVALID_MSG_VALUE);
            ethValue -= vars.commissionAmount;   // after docommission
            if (gasFeeAmount > 0) {
                (bool success, ) = payable(feeTo).call{value: gasFeeAmount}("");
                require(success, XBridgeErrors.TRANSFER_ETH_FAILD);
                ethValue -= gasFeeAmount;
            }
        } else {
            if (gasFeeAmount > 0) {
                _deposit(msg.sender, feeTo, _request.token, gasFeeAmount);
            }
            _deposit(msg.sender, adaptor, _request.token, _request.amount);
        }

        // Call the outboundBridgeTo function on the selected adaptor
        BridgeAdaptorBase(payable(adaptor)).outboundBridgeTo{value : ethValue}(
            msg.sender,
            _request.to,
            msg.sender, // refund to msg.sender
            _request.token,
            _request.amount,
            toChainId,
            _request.data
        );

        // Construct extension data and emit the LogBridgeTo event
        bytes32[] memory ext = _constructExt(
                                    orderId,
                                    toChainId,
                                    _request.adaptorId,
                                    _request.to,
                                    _request.data,
                                    _request.extData
                                );
        emit LogBridgeTo(
            _request.adaptorId,
            msg.sender,
            _request.to,
            _request.token,
            _request.amount,
            gasFeeAmount,
            ext
        );
    }

    /**
     * @notice Struct to represent the result of a cross-chain bridge operation.
     * @dev Holds information about the adaptor, token balances, gas fee, chain ID, order ID, success status, function selector, and result data.
     */
    struct BridgeVariants {
        address adaptor;
        uint256 toTokenBalance;
        uint256 toTokenBalanceOrigin;
        uint256 gasFeeAmount;
        uint256 toChainId;
        uint256 orderId;
        bool success;
        bytes4 selectorId;
        bytes result;
    }

    /**
     * @notice Internal function to perform a token swap and bridge operation using the specified SwapBridgeRequestV2 parameters.
     * @param _request The SwapBridgeRequestV2 struct containing swap and bridge details.
     * @dev Performs necessary validations, token swaps, bridge calls, and balance checks.
     */
    function _swapBridgeToInternal(SwapBridgeRequestV2 memory _request) internal {
        BridgeVariants memory vars;
        require(_request.adaptorId != 0, XBridgeErrors.INVALID_ADAPTOR_ID);
        vars.adaptor = adaptorInfo[_request.adaptorId];
        require(vars.adaptor != address(0), XBridgeErrors.INVALID_ADAPTOR_ADDRESS);
        require(_request.fromToken != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.toToken != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.fromToken != _request.toToken, XBridgeErrors.ADDRESS_EQUAL);
        require(_request.to != address(0), XBridgeErrors.ADDRESS_0);
        require(dexRouter != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.fromTokenAmount != 0, XBridgeErrors.AMOUNT_ZERO);
        require(_request.toTokenMinAmount != 0, XBridgeErrors.MIN_AMOUNT_ZERO);

        // Extract gas fee details from toChainId
        (vars.orderId, vars.gasFeeAmount,  vars.toChainId) = _getGasReceiveAmount(_request.toChainId);
        vars.toTokenBalanceOrigin = _getBalanceOf(_request.toToken);

        // Validate the dexData function selector
        require(accessSelectorId[bytes4(_request.dexData)], XBridgeErrors.ERROR_SELECTOR_ID);

        // Set payer and receiver addresses for potential refund
        payer = msg.sender;
        receiver = address(this);

        // doCommission
        (uint256 commissionAmount, bytes memory extDataWithoutLast32) = _doCommission(_request.fromTokenAmount, _request.fromToken, _request.extData);
        _request.extData = extDataWithoutLast32;

        // 1. prepare and swap
        if (_request.fromToken == XBridgeConstants.NATIVE_TOKEN) { //FROM NATIVE
            require(msg.value - commissionAmount >= _request.fromTokenAmount, XBridgeErrors.INVALID_MSG_VALUE);
            if (_request.toToken == XBridgeConstants.WETH) { //ETH => WETH
                vars.success = _swapWrap(address(this), address(this), _request.fromTokenAmount, false);
            } else { // ETH => ERC20, use dexRouter       
                (vars.success, vars.result) = dexRouter.call{value : _request.fromTokenAmount}(_request.dexData);
            }
        } else { // FROM ERC20
            if (_request.fromToken == XBridgeConstants.WETH && _request.toToken == XBridgeConstants.NATIVE_TOKEN) {
                // WETH => ETH
                vars.success = _swapWrap(msg.sender, address(this), _request.fromTokenAmount, true);
            } else { // ERC20 => ERC20, use dexRouter
                (vars.success, vars.result) = dexRouter.call(_request.dexData);
            }
        }
        delete payer;
        delete receiver;
        // 2. check result and balance

        require(vars.success,vars.result.length == 0 ? XBridgeErrors.INTERNAL_WRAP_FAIL : RevertReasonParser.parse(vars.result, XBridgeErrors.DEX_ROUTER_ERR));
        vars.toTokenBalance = _getBalanceOf(_request.toToken) - vars.toTokenBalanceOrigin; // toToken added
        require(vars.toTokenBalance >= vars.gasFeeAmount + _request.toTokenMinAmount, XBridgeErrors.MIN_AMOUNT_ERR);

        // 3. Receive to token for relay gas token on target chain to user
        _transferToken(feeTo, _request.toToken, vars.gasFeeAmount);

        // 4. Bridge the toToken to the target chain
        vars.toTokenBalance = vars.toTokenBalance - vars.gasFeeAmount;
        if (_request.toToken == XBridgeConstants.NATIVE_TOKEN) {
            // Internal with BridgeAdaptorBase, so it is safe to use payable
            BridgeAdaptorBase(payable(vars.adaptor)).outboundBridgeTo{
                value: vars.toTokenBalance + msg.value
            }(
                msg.sender,
                _request.to,
                msg.sender, // refund to msg.sender
                _request.toToken,
                vars.toTokenBalance,
                vars.toChainId,
                _request.data
            );
        } else {
            _transferToken(vars.adaptor, _request.toToken, vars.toTokenBalance);
            if (_request.fromToken == XBridgeConstants.NATIVE_TOKEN){
                BridgeAdaptorBase(payable(vars.adaptor)).outboundBridgeTo{value : msg.value - commissionAmount - _request.fromTokenAmount }(
                    msg.sender,
                    _request.to,
                    msg.sender, // refund to msg.sender
                    _request.toToken,
                    vars.toTokenBalance,
                    vars.toChainId,
                    _request.data
                );
            } else {
                BridgeAdaptorBase(payable(vars.adaptor)).outboundBridgeTo{value : msg.value }(
                    msg.sender,
                    _request.to,
                    msg.sender, // refund to msg.sender
                    _request.toToken,
                    vars.toTokenBalance,
                    vars.toChainId,
                    _request.data
                );
            }
        }

        // Construct extension data and emit the LogBridgeTo event
        bytes32[] memory ext = _constructExt(
                                    vars.orderId,
                                    vars.toChainId,
                                    _request.adaptorId,
                                    _request.to,
                                    _request.data,
                                    _request.extData
                                );
        emit LogSwapAndBridgeTo(
            _request.adaptorId,
            msg.sender,
            _request.to,
            _request.fromToken,
            _request.fromTokenAmount,
            _request.toToken,
            vars.toTokenBalance,
            vars.gasFeeAmount,
            ext
        );

        // 5. Check balance
        if (_request.toToken == XBridgeConstants.NATIVE_TOKEN){
            // if toToken equal nativeToken, should add msg.value
            require(_getBalanceOf(_request.toToken) + msg.value >= vars.toTokenBalanceOrigin, XBridgeErrors.SLASH_MUCH_TOO_MONEY);
        } else {
            require(_getBalanceOf(_request.toToken) >= vars.toTokenBalanceOrigin, XBridgeErrors.SLASH_MUCH_TOO_MONEY);
        }
    }

    /**
     * @notice Internal function to execute a permit on an ERC20 token if a permit data is provided.
     * @param token Address of the ERC20 token.
     * @param permit Permit data containing the necessary parameters for the permit function.
     */
    function _permit(address token, bytes calldata permit) internal {
        if (permit.length > 0) {
            bool success;
            bytes memory result;
            if (permit.length == 32 * 7) {
                // solhint-disable-next-line avoid-low-level-calls
                (success, result) = token.call(abi.encodePacked(IERC20Permit.permit.selector, permit));
            } else if (permit.length == 32 * 8) {
                // solhint-disable-next-line avoid-low-level-calls
                (success, result) = token.call(abi.encodePacked(IDaiLikePermit.permit.selector, permit));
            } else {
                revert("Wrong permit length");
            }
            if (!success) {
                revert(RevertReasonParser.parse(result, "Permit failed: "));
            }
        }
    }

    /**
     * @notice Internal function to receive gas tokens from the source chain and transfer them to the specified recipient.
     * @param _request The ReceiveGasRequest struct containing details about the gas token receipt.
     * @dev Performs necessary validations, updates state, and emits the GasTokenReceived event.
     */
    function _receiveGasTokenInternal(ReceiveGasRequest memory _request) internal {
        require(_request.amount <= sysRatio[XBridgeConstants.GAS_TOKEN_RECEIVE_MAX_INDEX], XBridgeErrors.EXCEED_ALLOWED_GAS);
        require(!receiveGasTx[_request.srcChainId][_request.srcTxHash], XBridgeErrors.HAS_RECEIVE_GAS);
        receiveGasTx[_request.srcChainId][_request.srcTxHash] = true;
        _transferToken(_request.to, XBridgeConstants.NATIVE_TOKEN, _request.amount);
        bytes32[] memory ext = new bytes32[](1);
        ext[0] = _request.srcTxHash;
        emit GasTokenReceived(_request.to, _request.amount, _request.srcChainId, ext);
    }

    /**
     * @notice Internal function to decode a message and its signature to extract relevant information.
     * @param _message The encoded message containing information about the oracle request.
     * @param _signature The signature of the message for authentication.
     * @return source The address of the message sender recovered from the signature.
     * @return thisChainId The chain ID of this contract.
     * @return thisContractAddress The address of this contract.
     * @return oracleInfo An OracleInfo struct containing details of the oracle request.
     * @dev Decodes the message and signature to extract source address, chain ID, contract address, and oracle request details.
     */
    function _decode(bytes memory _message, bytes memory _signature)
        internal
        pure
        returns (
            address source,
            uint256 thisChainId,
            address thisContractAddress,
            OracleInfo memory oracleInfo
        )
    {
        { // fix Stack too deep
            (bytes32 r, bytes32 s, uint8 v) = abi.decode(_signature, (bytes32, bytes32, uint8));
            bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(_message)));
            source = ecrecover(hash, v, r, s);
        }
        (
            thisChainId,
            thisContractAddress,
            oracleInfo.srcChainId,
            oracleInfo.txHash,
            oracleInfo.to,
            oracleInfo.token,
            oracleInfo.amount,
            oracleInfo.actualAmount
        ) = abi.decode(_message, (uint256, address, uint256, bytes32, bytes32, bytes32, uint256, uint256));
        return (source, thisChainId, thisContractAddress, oracleInfo);
    }

    /**
     * @notice Internal function to verify the oracle signature and details for a swap request.
     * @param _request The SwapRequest struct containing swap details.
     * @param _amount The amount to be verified against the oracle threshold.
     * @dev Verifies the oracle signature, source address, and additional details for the swap request.
     */
    function _verifyOracle(
        SwapRequest memory _request,
        uint256 _amount
    )
        view
        internal
    {
        (bytes memory message, bytes memory signature) = abi.decode(_request.extData, (bytes, bytes));
        (
            address source,
            uint256 thisChainId,
            address thisContractAddress,
            OracleInfo memory oracleInfo
        ) = _decode(message, signature);

        // Validate the source address, oracle proxy status, chain ID, contract address, and request details
        require(source != address(0), XBridgeErrors.ZERO_SIGNER);
        require(proxies[source], XBridgeErrors.NOT_ORACLE_PROXY);
        require(thisChainId == sysRatio[XBridgeConstants.CHAIN_ID_INDEX], XBridgeErrors.ERR_CHAIN_ID);
        require(thisContractAddress == address(this), XBridgeErrors.CONTRACT_ADDRESS_ERROR);
        require(_request.srcTxHash == oracleInfo.txHash, XBridgeErrors.ORACLE_NO_INFO);
        require(_request.to == address(uint160(uint256(oracleInfo.to))), XBridgeErrors.ORACLE_TO_ADDRESS_ERR);
        require(_request.fromToken == address(uint160(uint256(oracleInfo.token))), XBridgeErrors.ORACLE_TOKEN_ADDRESS_ERR);

        // Calculate the high threshold based on the actualAmount and configured ratio
        uint256 ratio = sysRatio[XBridgeConstants.CLAIM_TOKEN_RATIO_MAX_INDEX];
        uint256 high = oracleInfo.actualAmount * (ratio + XBridgeConstants.DEFAULT_RATIO_BASE) / XBridgeConstants.DEFAULT_RATIO_BASE;

        // Check if the requested amount is within the allowed high threshold
        require(_amount <= high, XBridgeErrors.ORACLE_TOKEN_AMOUNT_ERR);
    }

    /**
     * @notice Internal function to process the claim for a swap request, including gas fee handling and token transfer.
     * @param _request The SwapRequest struct containing swap details.
     * @dev Verifies the oracle, handles gas fees, performs token swap or transfer and emits the Claimed event.
     */
    function _claimInternal(SwapRequest memory _request) internal {
        uint256 fromTokenOriginBalance = _getBalanceOf(_request.fromToken);

        // Calculate the total amount needed, including swap amount and gas fees
        uint256 fromTokenNeed = _request.amount + _request.gasFeeAmount;

        // Verify the oracle signature and threshold for the source token
        _verifyOracle(_request, fromTokenNeed);
        require(fromTokenOriginBalance >= fromTokenNeed, XBridgeErrors.NO_ENOUGH_MONEY);
        require(dexRouter != address(0), XBridgeErrors.ADDRESS_0);
        require(!paidTx[_request.srcChainId][_request.srcTxHash], XBridgeErrors.HAS_PAID);
        paidTx[_request.srcChainId][_request.srcTxHash] = true;

        // Initialize extension data for the Claimed event
        bytes32[] memory ext = new bytes32[](1);
        ext[0] = _request.srcTxHash;
        bool success;
        bytes memory result;
        string memory errInfo;

        // 1. Handle gas fee
        _transferToken(feeTo, _request.fromToken, _request.gasFeeAmount);

        // 2. Perform token swap or transfer to the user
        if (_request.dexData.length > 0) {
            // swap
            uint256 toTokenReceiverBalance = _getBalanceOf(_request.toToken, _request.to);

            // Exchange anypair using the dexRouter except WETH<=>ETH
            payer = address(this);
            receiver = _request.to;
            if (_request.fromToken == XBridgeConstants.NATIVE_TOKEN) { // FROM NATIVE
                if (_request.toToken == XBridgeConstants.WETH) { // ETH => WETH
                    success = _swapWrap(address(this), _request.to, _request.amount, false);
                    if (!success) {
                        errInfo = XBridgeErrors.INTERNAL_WRAP_FAIL;
                    }  
                } else { // ETH => ERC20, use dexRouter
                    (success, result) = dexRouter.call{value : _request.amount}(_request.dexData); 
                }
            } else { // FROM ERC20
                if (_request.fromToken == XBridgeConstants.WETH && _request.toToken == XBridgeConstants.NATIVE_TOKEN) {
                    // WETH => ETH
                    success =_swapWrap(address(this), _request.to, _request.amount, true);
                    if (!success) {
                        errInfo = XBridgeErrors.INTERNAL_WRAP_FAIL;
                    } 
                } else { // ERC20 => ERC20, use dexRouter
                    address tokenApprove = IApproveProxy(XBridgeConstants.APPROVE_PROXY).tokenApprove();
                    IERC20Upgradeable(_request.fromToken).safeApprove(tokenApprove, _request.amount);
                    (success, result) = dexRouter.call(_request.dexData);
                    if (IERC20Upgradeable(_request.fromToken).allowance(address(this), tokenApprove) != 0){
                        IERC20Upgradeable(_request.fromToken).safeApprove(tokenApprove, 0);  
                    }
                }
            }
            if (!success && result.length > 0) {
                errInfo = RevertReasonParser.parse(result, XBridgeErrors.DEX_ROUTER_ERR);
            }
            delete payer; // payer = 0;
            delete receiver;
            if (!success) { // transfer fromToken if swap failed
                _transferToken(_request.to, _request.fromToken, _request.amount);
                emit Claimed(_request.to, _request.fromToken, _request.toToken, _request.amount, 0, _request.gasFeeAmount, _request.srcChainId, errInfo, ext);
            } else {
                toTokenReceiverBalance = _getBalanceOf(_request.toToken, _request.to) - toTokenReceiverBalance;
                emit Claimed(_request.to, _request.fromToken, _request.toToken, 0, toTokenReceiverBalance, _request.gasFeeAmount, _request.srcChainId, errInfo, ext);
            }
        } else { // transfer token
            errInfo = XBridgeConstants.__REFUND__;
            _transferToken(_request.to, _request.fromToken, _request.amount);
            emit Claimed(_request.to, _request.fromToken, _request.toToken, _request.amount, 0, _request.gasFeeAmount, _request.srcChainId, errInfo, ext);
        }

        // 3. Check the final balance of the source token
        require(fromTokenOriginBalance - _getBalanceOf(_request.fromToken) <= fromTokenNeed, XBridgeErrors.SLASH_MUCH_TOO_MONEY);
    }

    /**
     * @dev Internal function to swap and wrap tokens.
     * @param from The address to transfer the tokens from.
     * @param to The address to transfer the wrapped tokens to.
     * @param amount The amount of tokens to swap and wrap.
     * @param reversed Boolean indicating whether the swap is reversed (WETH => ETH).
     * @return A boolean indicating the success of the swap and wrap operation.
     */
    function _swapWrap(
        address from,
        address to,
        uint256 amount,
        bool reversed
    ) internal returns (bool) {
        require(amount > 0,  XBridgeErrors.WRAP_AMOUNT_ZERO);
        if (reversed) {
            // reversed == true: WETH => ETH
            if (from == address(this)){
                IWETH(address(uint160(XBridgeConstants.WETH))).transfer(XBridgeConstants.WNATIVE_RELAY, amount);
            } else {
                _deposit(from, XBridgeConstants.WNATIVE_RELAY, XBridgeConstants.WETH, amount);
            }
            IWNativeRelayer(XBridgeConstants.WNATIVE_RELAY).withdraw(amount);
            if (to != address(this)){
                (bool success, ) = payable(to).call{value: amount}("");
                require(success, XBridgeErrors.TRANSFER_ETH_FAILD);
            }
        } else {
            // reversed == false: ETH => WETH
            IWETH(XBridgeConstants.WETH).deposit{value: amount}();
            if (to != address(this)){
                IERC20Upgradeable(XBridgeConstants.WETH).safeTransfer(to, amount);
            }
        }
        return true;
    }

    /**
     * @notice Internal function to handle commission logic
     * @param inputAmount The amount of tokens to be transferred.
     * @param commissionToken The address of the ERC20 token to be transferred.
     * @param extData Additional extension data containing user-specific information.
     * @return commissionAmount The amount of commission tokens to be transferred.
     * @return extDataWithoutLast32 Additional extension data containing user-specific information without last 32 bytes.
     */
    function _doCommission( uint256 inputAmount, address commissionToken, bytes memory extData) internal returns (uint256 commissionAmount, bytes memory extDataWithoutLast32) {
        
        // Retrieve commission info from the last 32 bytes of extData
        uint256 commissionInfo;
        assembly {
            commissionInfo := calldataload(sub(calldatasize(),0x20))
        }

        if ((commissionInfo & _COMMISSION_FLAG_MASK) == OKX_COMMISSION) {
            // 0. decode the commissionInfo
            address referrerAddress = address(uint160(commissionInfo & _REFERRER_MASK));
            uint256 commissionRate = uint256((commissionInfo & _COMMISSION_FEE_MASK) >> 160);

            // 1. Check the commission ratio. CommissionFeeAmount = fromTokenAmount * Rate / (10000 - Rate)
            require(commissionRate <= commissionRateLimit, XBridgeErrors.COMMISSION_ERROR_RATE);
            commissionAmount = (inputAmount * commissionRate) / (10000 - commissionRate);

            // 2. Perform commission
            if (commissionToken == XBridgeConstants.NATIVE_TOKEN) {
                (bool success,) = payable(referrerAddress).call{value: commissionAmount}("");
                require(success, XBridgeErrors.COMMISSION_ERROR_ETHER); 
            } else {
                _deposit(msg.sender, referrerAddress, commissionToken, commissionAmount);
            }

            // 3. Restore extData
            uint256 extDataSize = extData.length;
            extDataWithoutLast32 = new bytes(extDataSize - 32);
            for (uint256 i = 0; i < extDataSize - 32; i++) {
                extDataWithoutLast32[i] = extData[i];
            }

            emit CommissionRecord(commissionAmount, referrerAddress);
        } else {
            extDataWithoutLast32 = extData;
        }
    }

    //-------------------------------
    //------- Admin functions -------
    //-------------------------------

    function setAdmin(address _newAdmin) external onlyOwner {
        require(_newAdmin != address(0), XBridgeErrors.ADDRESS_0);
        admin = _newAdmin;
        emit AdminChanged(_newAdmin);
    }

    function setDexRouter(address _newDexRouter) external onlyAdmin {
        require(_newDexRouter != address(0), XBridgeErrors.ADDRESS_0);
        dexRouter = _newDexRouter;
        emit DexRouterChanged(_newDexRouter);
    }

    function pause() external onlyAdmin {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }

    function setAdaptors(uint256[] calldata _ids, address[] calldata _adaptors) external onlyAdmin {
        require(_ids.length == _adaptors.length, XBridgeErrors.LENGTH_NOT_EQUAL);
        for (uint256 i = 0; i < _ids.length; i++) {
            adaptorInfo[_ids[i]] = _adaptors[i];
            emit AdaptorsChanged(_ids[i], _adaptors[i]);
        }
    }

    function setFeeTo(address _newFeeTo) external onlyAdmin {
        require(_newFeeTo != address(0), XBridgeErrors.ADDRESS_0);
        feeTo = _newFeeTo;
        emit FeeToChanged(_newFeeTo);
    }

    function setMpc(address[] memory _mpcList, bool[] memory _v) external onlyAdmin {
        require(_mpcList.length == _v.length, XBridgeErrors.LENGTH_NOT_EQUAL);
        for (uint256 i = 0; i < _mpcList.length; i++) {
            mpc[_mpcList[i]] = _v[i];
            emit MpcChanged(_mpcList[i], _v[i]);
        }
    }

    function setSysRatio(uint256 _index, uint256 _v) external onlyAdmin {
        sysRatio[_index] = _v;
        emit SysRatioChanged(_index, _v);
    }

    function setProxies(address[] memory proxiesList, bool[] memory values)
        external
        onlyAdmin
    {
        require(proxiesList.length == values.length, XBridgeErrors.LENGTH_NOT_EQUAL);
        for (uint256 i = 0; i < proxiesList.length; i++) {
            proxies[proxiesList[i]] = values[i];
            emit ProxiesChanged(proxiesList[i], values[i]);
        }
    }

    function setAccessSelectorId(bytes4[] memory selectorIds, bool[] memory values) external onlyAdmin{
        require(selectorIds.length == values.length, XBridgeErrors.LENGTH_NOT_EQUAL);
        for (uint256 i = 0; i < selectorIds.length; i++) {
            accessSelectorId[selectorIds[i]] = values[i];
            emit AccessSelectorIdChanged(selectorIds[i], values[i]);
        }
    }

    //-------------------------------
    //------- Users Functions -------
    //-------------------------------

    /**
     * @notice Initiates the bridge operation to transfer assets to another chain using the bridge.
     * @param _request The BridgeRequestV2 struct containing the details of the bridge operation.
     */
    function bridgeToV2(BridgeRequestV2 memory _request)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        _bridgeToV2Internal(_request);
    }

    /**
     * @notice Initiates a swap and bridge operation using the bridge.
     * @param _request The SwapBridgeRequestV2 struct containing the details of the swap and bridge operation.
     */
    function swapBridgeToV2(SwapBridgeRequestV2 memory _request)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        _swapBridgeToInternal(_request);
    }

    /**
     * @notice Initiates a swap and bridge operation with permit using V2 of the bridge.
     * @param _request The SwapBridgeRequestV2 struct containing the details of the swap and bridge operation.
     * @param _signature The permit signature for the fromToken.
     */
    function swapBridgeToWithPermit(
        SwapBridgeRequestV2 calldata _request,
        bytes calldata _signature
    ) external nonReentrant whenNotPaused {
        _permit(_request.fromToken, _signature);
        _swapBridgeToInternal(_request);
    }

    /**
     * @notice Completed receiving gas tokens from the source chain.
     * @param _request The ReceiveGasRequest struct containing the details of this operation.
     */
    function receiveGasToken(ReceiveGasRequest memory _request)
        public
        payable
        nonReentrant
        whenNotPaused
        onlyMPC
    {
        require(msg.value == _request.amount, XBridgeErrors.INVALID_MSG_VALUE);
        _receiveGasTokenInternal(_request);
    }

    /**
     * @notice Claims the assets on the current chain as part of the cross-chain swap.
     * @param _request The SwapRequest struct containing details of the asset claiming operation.
     */
    function claim(SwapRequest memory _request)
        public
        nonReentrant
        whenNotPaused
        onlyMPC
    {
        _claimInternal(_request);
    }

    /**
     * @notice Performs batch operations including Gas Token receiving and asset claiming.
     * @param _gasRequest Array of ReceiveGasRequest structs containing details of Gas Token receiving operations.
     * @param _claimRequest Array of SwapRequest structs containing details of asset claiming operations.
     */
    function doBatch(ReceiveGasRequest[] memory _gasRequest, SwapRequest[] memory _claimRequest)
        public
        payable
        nonReentrant
        whenNotPaused
        onlyMPC
    {
        uint256 leftValue = msg.value;
        for (uint256 i = 0; i < _gasRequest.length; i++) {
            _receiveGasTokenInternal(_gasRequest[i]);
            // DOES NOT need check, because it will overflow if less than amount
            leftValue -= _gasRequest[i].amount;
        }
        for (uint256 i = 0; i < _claimRequest.length; i++) {
            _claimInternal(_claimRequest[i]);
        }
        require(leftValue == 0, XBridgeErrors.LEFT_VALUE_NOT_ZERO);
    }

    function payerReceiver() external view returns(address, address) {
        return (payer, receiver);
    }

    receive() external payable {}
}
