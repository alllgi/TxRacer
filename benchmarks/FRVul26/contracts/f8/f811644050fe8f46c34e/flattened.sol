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

// File: contracts/8/interfaces/IUni.sol

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IUni {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);

    function token1() external view returns (address);
}

// File: contracts/8/libraries/SafeMath.sol

pragma solidity ^0.8.0;

library SafeMath {
    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    function wad() public pure returns (uint256) {
        return WAD;
    }

    function ray() public pure returns (uint256) {
        return RAY;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function sqrt(uint256 a) internal pure returns (uint256 b) {
        if (a > 3) {
            b = a;
            uint256 x = a / 2 + 1;
            while (x < b) {
                b = x;
                x = (a / x + x) / 2;
            }
        } else if (a != 0) {
            b = 1;
        }
    }

    function wmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / WAD;
    }

    function wmulRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, b), WAD / 2) / WAD;
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / RAY;
    }

    function rmulRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, b), RAY / 2) / RAY;
    }

    function wdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(mul(a, WAD), b);
    }

    function wdivRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, WAD), b / 2) / b;
    }

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(mul(a, RAY), b);
    }

    function rdivRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, RAY), b / 2) / b;
    }

    function wpow(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = WAD;
        while (n > 0) {
            if (n % 2 != 0) {
                result = wmul(result, x);
            }
            x = wmul(x, x);
            n /= 2;
        }
        return result;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = RAY;
        while (n > 0) {
            if (n % 2 != 0) {
                result = rmul(result, x);
            }
            x = rmul(x, x);
            n /= 2;
        }
        return result;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
}

// File: contracts/8/interfaces/IERC20.sol

pragma solidity ^0.8.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: contracts/8/libraries/Address.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {
        return payable(account);
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

// File: contracts/8/libraries/RevertReasonForwarder.sol

/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library RevertReasonForwarder {
    function reRevert() internal pure {
        // bubble up revert reason from latest external call
        /// @solidity memory-safe-assembly
        assembly { // solhint-disable-line no-inline-assembly
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, returndatasize())
            revert(ptr, returndatasize())
        }
    }
}

// File: contracts/8/interfaces/IERC20Permit.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
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
     * @dev Returns the domain separator used in the encoding of the signature for `permit`, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: contracts/8/interfaces/IDaiLikePermit.sol

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

// File: contracts/8/libraries/SafeERC20.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;








// File @1inch/solidity-utils/contracts/libraries/SafeERC20.sol@v2.1.1

library SafeERC20 {
    error SafeTransferFailed();
    error SafeTransferFromFailed();
    error ForceApproveFailed();
    error SafeIncreaseAllowanceFailed();
    error SafeDecreaseAllowanceFailed();
    error SafePermitBadLength();

    // Ensures method do not revert or return boolean `true`, admits call to non-smart-contract
    function safeTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        bytes4 selector = token.transferFrom.selector;
        bool success;
        /// @solidity memory-safe-assembly
        assembly { // solhint-disable-line no-inline-assembly
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), from)
            mstore(add(data, 0x24), to)
            mstore(add(data, 0x44), amount)
            success := call(gas(), token, 0, data, 100, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 { success := gt(extcodesize(token), 0) }
                default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
            }
        }
        if (!success) revert SafeTransferFromFailed();
    }

    // Ensures method do not revert or return boolean `true`, admits call to non-smart-contract
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        if (!_makeCall(token, token.transfer.selector, to, value)) {
            revert SafeTransferFailed();
        }
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        forceApprove(token, spender, value);
    }

    // If `approve(from, to, amount)` fails, try to `approve(from, to, 0)` before retry
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        if (!_makeCall(token, token.approve.selector, spender, value)) {
            if (!_makeCall(token, token.approve.selector, spender, 0) ||
                !_makeCall(token, token.approve.selector, spender, value))
            {
                revert ForceApproveFailed();
            }
        }
    }

    

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (value > type(uint256).max - allowance) revert SafeIncreaseAllowanceFailed();
        forceApprove(token, spender, allowance + value);
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (value > allowance) revert SafeDecreaseAllowanceFailed();
        forceApprove(token, spender, allowance - value);
    }

    function safePermit(IERC20 token, bytes calldata permit) internal {
        bool success;
        if (permit.length == 32 * 7) {
            success = _makeCalldataCall(token, IERC20Permit.permit.selector, permit);
        } else if (permit.length == 32 * 8) {
            success = _makeCalldataCall(token, IDaiLikePermit.permit.selector, permit);
        } else {
            revert SafePermitBadLength();
        }
        if (!success) RevertReasonForwarder.reRevert();
    }

    function _makeCall(IERC20 token, bytes4 selector, address to, uint256 amount) private returns(bool success) {
        /// @solidity memory-safe-assembly
        assembly { // solhint-disable-line no-inline-assembly
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), to)
            mstore(add(data, 0x24), amount)
            success := call(gas(), token, 0, data, 0x44, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 { success := gt(extcodesize(token), 0) }
                default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
            }
        }
    }

    function _makeCalldataCall(IERC20 token, bytes4 selector, bytes calldata args) private returns(bool success) {
        /// @solidity memory-safe-assembly
        assembly { // solhint-disable-line no-inline-assembly
            let len := add(4, args.length)
            let data := mload(0x40)

            mstore(data, selector)
            calldatacopy(add(data, 0x04), args.offset, args.length)
            success := call(gas(), token, 0, data, len, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 { success := gt(extcodesize(token), 0) }
                default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
            }
        }
    }
}

// File: contracts/8/libraries/UniversalERC20.sol

pragma solidity ^0.8.0;





library UniversalERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant ETH_ADDRESS =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(
        IERC20 token,
        address payable to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (isETH(token)) {
                to.transfer(amount);
            } else {
                token.safeTransfer(to, amount);
            }
        }
    }

    function universalTransferFrom(
        IERC20 token,
        address from,
        address payable to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalApproveMax(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        uint256 allowance = token.allowance(address(this), to);
        if (allowance < amount) {
            token.forceApprove(to, type(uint256).max);
        }
    }

    function universalBalanceOf(IERC20 token, address who)
        internal
        view
        returns (uint256)
    {
        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function tokenBalanceOf(IERC20 token, address who)
        internal
        view
        returns (uint256)
    {
        return token.balanceOf(who);
    }

    function isETH(IERC20 token) internal pure returns (bool) {
        return token == ETH_ADDRESS;
    }
}

// File: contracts/8/libraries/CommonUtils.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Base contract with common permit handling logics
abstract contract CommonUtils {

  address internal constant _ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  uint256 internal constant _ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
  uint256 internal constant _REVERSE_MASK = 0x8000000000000000000000000000000000000000000000000000000000000000;
  uint256 internal constant _ORDER_ID_MASK = 0xffffffffffffffffffffffff0000000000000000000000000000000000000000;
  uint256 internal constant _WEIGHT_MASK = 0x00000000000000000000ffff0000000000000000000000000000000000000000;
  uint256 internal constant _CALL_GAS_LIMIT = 5000;

  /// @dev WETH address is network-specific and needs to be changed before deployment.
  /// It can not be moved to immutable as immutables are not supported in assembly
  // ETH:     C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
  // BSC:     bb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
  // OEC:     8f8526dbfd6e38e3d8307702ca8469bae6c56c15
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
  address public constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  // address public constant _WETH = 0x5FbDB2315678afecb367f032d93F642f64180aa3;    // hardhat1
  // address public constant _WETH = 0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a;    // hardhat2


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
  // OP:      100F3f74125C8c724C7C0eE81E4dd5626830dD9a
  // CRO:     E9BBD6eC0c9Ca71d3DcCD1282EE9de4F811E50aF
  // CFX:     100F3f74125C8c724C7C0eE81E4dd5626830dD9a
  // POLYZK   1b5d39419C268b76Db06DE49e38B010fbFB5e226
  address public constant _APPROVE_PROXY = 0x70cBb871E8f30Fc8Ce23609E9E0Ea87B6b222F58;
  // address public constant _APPROVE_PROXY = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;    // hardhat1
  // address public constant _APPROVE_PROXY = 0x2538a10b7fFb1B78c890c870FC152b10be121f04;    // hardhat2

  // ETH:     5703B683c7F928b721CA95Da988d73a3299d4757
  // BSC:     0B5f474ad0e3f7ef629BD10dbf9e4a8Fd60d9A48
  // OEC:     d99cAE3FAC551f6b6Ba7B9f19bDD316951eeEE98
  // LOCAL:   D49a0e9A4CD5979aE36840f542D2d7f02C4817Be
  // LOCAL2:  11457D5b1025D162F3d9B7dBeab6E1fBca20e043
  // POLYGON: f332761c673b59B21fF6dfa8adA44d78c12dEF09
  // AVAX:    3B86917369B83a6892f553609F3c2F439C184e31
  // FTM:     40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
  // ARB:     d99cAE3FAC551f6b6Ba7B9f19bDD316951eeEE98
  // OP:      40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
  // CRO:     40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
  // CFX:     40aA958dd87FC8305b97f2BA922CDdCa374bcD7f
  // POLYZK   d2F0aC2012C8433F235c8e5e97F2368197DD06C7
  address public constant _WNATIVE_RELAY = 0x5703B683c7F928b721CA95Da988d73a3299d4757;
  // address public constant _WNATIVE_RELAY = 0x0B306BF915C4d645ff596e518fAf3F9669b97016;   // hardhat1
  // address public constant _WNATIVE_RELAY = 0x6A47346e722937B60Df7a1149168c0E76DD6520f;   // hardhat2

  event OrderRecord(address fromToken, address toToken, address sender, uint256 fromAmount, uint256 returnAmount);
  event SwapOrderId(uint256 id);
}

// File: contracts/8/UnxswapRouter.sol

pragma solidity ^0.8.0;






contract UnxswapRouter is CommonUtils {
    uint256 private constant _IS_TOKEN0_TAX =
        0x1000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _IS_TOKEN1_TAX =
        0x2000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _CLAIM_TOKENS_CALL_SELECTOR_32 =
        0x0a5ea46600000000000000000000000000000000000000000000000000000000;
    uint256 private constant _TRANSFER_DEPOSIT_SELECTOR =
        0xa9059cbbd0e30db0000000000000000000000000000000000000000000000000;
    uint256 private constant _SWAP_GETRESERVES_SELECTOR =
        0x022c0d9f0902f1ac000000000000000000000000000000000000000000000000;
    uint256 private constant _WITHDRAW_TRNASFER_SELECTOR =
        0x2e1a7d4da9059cbb000000000000000000000000000000000000000000000000;
    uint256 private constant _BALANCEOF_TOKEN0_SELECTOR =
        0x70a082310dfe1681000000000000000000000000000000000000000000000000;
    uint256 private constant _BALANCEOF_TOKEN1_SELECTOR =
        0x70a08231d21220a7000000000000000000000000000000000000000000000000;

    uint256 private constant _WETH_MASK =
        0x4000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _NUMERATOR_MASK =
        0x0000000000000000ffffffff0000000000000000000000000000000000000000;

    uint256 private constant _DENOMINATOR = 1_000_000_000;
    uint256 private constant _NUMERATOR_OFFSET = 160;

    uint256 private constant ETH_ADDRESS = 0x00;

    //-------------------------------
    //------- Internal Functions ----
    //-------------------------------
    /// @notice Performs the internal logic for executing a swap using the Unxswap protocol.
    /// @param srcToken The token to be swapped.
    /// @param amount The amount of the source token to be swapped.
    /// @param minReturn The minimum amount of tokens that must be received for the swap to be valid, protecting against slippage.
    /// @param pools The array of pool identifiers that define the swap route.
    /// @param payer The address of the entity providing the source tokens for the swap.
    /// @param receiver The address that will receive the tokens after the swap.
    /// @return returnAmount The amount of tokens received from the swap.
    /// @dev This internal function encapsulates the core logic of the Unxswap token swap process. It is meant to be called by other external functions that set up the required parameters. The actual interaction with the Unxswap pools and the token transfer mechanics are implemented here.
    function _unxswapInternal(
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        // solhint-disable-next-line no-unused-vars
        bytes32[] calldata pools,
        address payer,
        address receiver
    ) internal returns (uint256 returnAmount) {
        assembly {
            // solhint-disable-line no-inline-assembly

            function revertWithReason(m, len) {
                mstore(
                    0,
                    0x08c379a000000000000000000000000000000000000000000000000000000000
                )
                mstore(
                    0x20,
                    0x0000002000000000000000000000000000000000000000000000000000000000
                )
                mstore(0x40, m)
                revert(0, len)
            }
            function _getTokenAddr(emptyPtr, pair, selector) -> token {
                mstore(emptyPtr, selector)
                if iszero(
                    staticcall(
                        gas(),
                        pair,
                        add(0x04, emptyPtr),
                        0x04,
                        0x00,
                        0x20
                    )
                ) {
                    revertWithReason(
                        0x0000001067657420746f6b656e206661696c6564000000000000000000000000,
                        0x54
                    ) // "get token failed"
                }
                token := mload(0x00)
            }
            function _getBalanceOfToken0(emptyPtr, pair) -> token0, balance0 {
                mstore(emptyPtr, _BALANCEOF_TOKEN0_SELECTOR)
                if iszero(
                    staticcall(
                        gas(),
                        pair,
                        add(0x04, emptyPtr),
                        0x04,
                        0x00,
                        0x20
                    )
                ) {
                    revertWithReason(
                        0x00000012746f6b656e302063616c6c206661696c656400000000000000000000,
                        0x56
                    ) // "token0 call failed"
                }
                token0 := mload(0x00)
                mstore(add(0x04, emptyPtr), pair)
                if iszero(
                    staticcall(gas(), token0, emptyPtr, 0x24, 0x00, 0x20)
                ) {
                    revertWithReason(
                        0x0000001562616c616e63654f662063616c6c206661696c656400000000000000,
                        0x59
                    ) // "balanceOf call failed"
                }
                balance0 := mload(0x00)
            }
            function _getBalanceOfToken1(emptyPtr, pair) -> token1, balance1 {
                mstore(emptyPtr, _BALANCEOF_TOKEN1_SELECTOR)
                if iszero(
                    staticcall(
                        gas(),
                        pair,
                        add(0x04, emptyPtr),
                        0x04,
                        0x00,
                        0x20
                    )
                ) {
                    revertWithReason(
                        0x00000012746f6b656e312063616c6c206661696c656400000000000000000000,
                        0x56
                    ) // "token1 call failed"
                }
                token1 := mload(0x00)
                mstore(add(0x04, emptyPtr), pair)
                if iszero(
                    staticcall(gas(), token1, emptyPtr, 0x24, 0x00, 0x20)
                ) {
                    revertWithReason(
                        0x0000001562616c616e63654f662063616c6c206661696c656400000000000000,
                        0x59
                    ) // "balanceOf call failed"
                }
                balance1 := mload(0x00)
            }

            function swap(
                emptyPtr,
                swapAmount,
                pair,
                reversed,
                isToken0Tax,
                isToken1Tax,
                numerator,
                dst
            ) -> ret {
                mstore(emptyPtr, _SWAP_GETRESERVES_SELECTOR)
                if iszero(
                    staticcall(
                        gas(),
                        pair,
                        add(0x04, emptyPtr),
                        0x4,
                        0x00,
                        0x40
                    )
                ) {
                    // we only need the first 0x40 bytes, no need timestamp info
                    revertWithReason(
                        0x0000001472657365727665732063616c6c206661696c65640000000000000000,
                        0x58
                    ) // "reserves call failed"
                }
                let reserve0 := mload(0x00)
                let reserve1 := mload(0x20)

                switch reversed
                case 0 {
                    //swap token0 for token1
                    if isToken0Tax {
                        let token0, balance0 := _getBalanceOfToken0(
                            emptyPtr,
                            pair
                        )
                        swapAmount := sub(balance0, reserve0)
                    }
                }
                default {
                    //swap token1 for token0
                    if isToken1Tax {
                        let token1, balance1 := _getBalanceOfToken1(
                            emptyPtr,
                            pair
                        )
                        swapAmount := sub(balance1, reserve1)
                    }
                    let temp := reserve0
                    reserve0 := reserve1
                    reserve1 := temp
                }

                ret := mul(swapAmount, numerator)
                ret := div(
                    mul(ret, reserve1),
                    add(ret, mul(reserve0, _DENOMINATOR))
                )
                mstore(emptyPtr, _SWAP_GETRESERVES_SELECTOR)
                switch reversed
                case 0 {
                    mstore(add(emptyPtr, 0x04), 0)
                    mstore(add(emptyPtr, 0x24), ret)
                }
                default {
                    mstore(add(emptyPtr, 0x04), ret)
                    mstore(add(emptyPtr, 0x24), 0)
                }
                mstore(add(emptyPtr, 0x44), dst)
                mstore(add(emptyPtr, 0x64), 0x80)
                mstore(add(emptyPtr, 0x84), 0)
                if iszero(call(gas(), pair, 0, emptyPtr, 0xa4, 0, 0)) {
                    revertWithReason(
                        0x00000010737761702063616c6c206661696c6564000000000000000000000000,
                        0x54
                    ) // "swap call failed"
                }
            }

            let poolsOffset
            let poolsEndOffset
            {
                let len := pools.length
                poolsOffset := pools.offset //
                poolsEndOffset := add(poolsOffset, mul(len, 32))

                if eq(len, 0) {
                    revertWithReason(
                        0x000000b656d70747920706f6f6c73000000000000000000000000000000000000,
                        0x4e
                    ) // "empty pools"
                }
            }
            let emptyPtr := mload(0x40)
            let rawPair := calldataload(poolsOffset)
            switch eq(ETH_ADDRESS, srcToken)
            case 1 {
                // require callvalue() >= amount, lt: if x < y return 1，else return 0
                if eq(lt(callvalue(), amount), 1) {
                    revertWithReason(
                        0x00000011696e76616c6964206d73672e76616c75650000000000000000000000,
                        0x55
                    ) // "invalid msg.value"
                }

                mstore(emptyPtr, _TRANSFER_DEPOSIT_SELECTOR)
                if iszero(
                    call(gas(), _WETH, amount, add(emptyPtr, 0x04), 0x4, 0, 0)
                ) {
                    revertWithReason(
                        0x000000126465706f73697420455448206661696c656400000000000000000000,
                        0x56
                    ) // "deposit ETH failed"
                }
                mstore(add(0x04, emptyPtr), and(rawPair, _ADDRESS_MASK))
                mstore(add(0x24, emptyPtr), amount)
                if iszero(call(gas(), _WETH, 0, emptyPtr, 0x44, 0, 0x20)) {
                    revertWithReason(
                        0x000000147472616e736665722057455448206661696c65640000000000000000,
                        0x58
                    ) // "transfer WETH failed"
                }
            }
            default {
                if callvalue() {
                    revertWithReason(
                        0x00000011696e76616c6964206d73672e76616c75650000000000000000000000,
                        0x55
                    ) // "invalid msg.value"
                }

                mstore(emptyPtr, _CLAIM_TOKENS_CALL_SELECTOR_32)
                mstore(add(emptyPtr, 0x4), srcToken)
                mstore(add(emptyPtr, 0x24), payer)
                mstore(add(emptyPtr, 0x44), and(rawPair, _ADDRESS_MASK))
                mstore(add(emptyPtr, 0x64), amount)
                if iszero(
                    call(gas(), _APPROVE_PROXY, 0, emptyPtr, 0x84, 0, 0)
                ) {
                    revertWithReason(
                        0x00000012636c61696d20746f6b656e206661696c656400000000000000000000,
                        0x56
                    ) // "claim token failed"
                }
            }

            returnAmount := amount

            for {
                let i := add(poolsOffset, 0x20)
            } lt(i, poolsEndOffset) {
                i := add(i, 0x20)
            } {
                let nextRawPair := calldataload(i)

                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    and(rawPair, _IS_TOKEN0_TAX),
                    and(rawPair, _IS_TOKEN1_TAX),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    and(nextRawPair, _ADDRESS_MASK)
                )

                rawPair := nextRawPair
            }
            let toToken
            switch and(rawPair, _WETH_MASK)
            case 0 {
                let beforeAmount
                switch and(rawPair, _REVERSE_MASK)
                case 0 {
                    if and(rawPair, _IS_TOKEN1_TAX) {
                        mstore(emptyPtr, _BALANCEOF_TOKEN1_SELECTOR)
                        if iszero(
                            staticcall(
                                gas(),
                                and(rawPair, _ADDRESS_MASK),
                                add(0x04, emptyPtr),
                                0x04,
                                0x00,
                                0x20
                            )
                        ) {
                            revertWithReason(
                                0x00000012746f6b656e312063616c6c206661696c656400000000000000000000,
                                0x56
                            ) // "token1 call failed"
                        }
                        toToken := mload(0)
                        mstore(add(0x04, emptyPtr), receiver)
                        if iszero(
                            staticcall(
                                gas(),
                                toToken,
                                emptyPtr,
                                0x24,
                                0x00,
                                0x20
                            )
                        ) {
                            revertWithReason(
                                0x00000015746f6b656e312062616c616e6365206661696c656400000000000000,
                                0x59
                            ) // "token1 balance failed"
                        }
                        beforeAmount := mload(0)
                    }
                }
                default {
                    if and(rawPair, _IS_TOKEN0_TAX) {
                        mstore(emptyPtr, _BALANCEOF_TOKEN0_SELECTOR)
                        if iszero(
                            staticcall(
                                gas(),
                                and(rawPair, _ADDRESS_MASK),
                                add(0x04, emptyPtr),
                                0x04,
                                0x00,
                                0x20
                            )
                        ) {
                            revertWithReason(
                                0x00000012746f6b656e302063616c6c206661696c656400000000000000000000,
                                0x56
                            ) // "token0 call failed"
                        }
                        toToken := mload(0)
                        mstore(add(0x04, emptyPtr), receiver)
                        if iszero(
                            staticcall(
                                gas(),
                                toToken,
                                emptyPtr,
                                0x24,
                                0x00,
                                0x20
                            )
                        ) {
                            revertWithReason(
                                0x00000015746f6b656e302062616c616e6365206661696c656400000000000000,
                                0x56
                            ) // "token0 balance failed"
                        }
                        beforeAmount := mload(0)
                    }
                }
                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    and(rawPair, _IS_TOKEN0_TAX),
                    and(rawPair, _IS_TOKEN1_TAX),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    receiver
                )
                switch lt(0x0, toToken)
                case 1 {
                    mstore(emptyPtr, _BALANCEOF_TOKEN0_SELECTOR)
                    mstore(add(0x04, emptyPtr), receiver)
                    if iszero(
                        staticcall(gas(), toToken, emptyPtr, 0x24, 0x00, 0x20)
                    ) {
                        revertWithReason(
                            0x000000146765742062616c616e63654f66206661696c65640000000000000000,
                            0x58
                        ) // "get balanceOf failed"
                    }
                    returnAmount := sub(mload(0), beforeAmount)
                }
                default {
                    // set token0 addr for the non-safemoon token
                    switch and(rawPair, _REVERSE_MASK)
                    case 0 {
                        // get token1
                        toToken := _getTokenAddr(
                            emptyPtr,
                            and(rawPair, _ADDRESS_MASK),
                            _BALANCEOF_TOKEN1_SELECTOR
                        )
                    }
                    default {
                        // get token0
                        toToken := _getTokenAddr(
                            emptyPtr,
                            and(rawPair, _ADDRESS_MASK),
                            _BALANCEOF_TOKEN0_SELECTOR
                        )
                    }
                }
            }
            default {
                toToken := ETH_ADDRESS
                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    and(rawPair, _IS_TOKEN0_TAX),
                    and(rawPair, _IS_TOKEN1_TAX),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    address()
                )

                mstore(emptyPtr, _WITHDRAW_TRNASFER_SELECTOR)
                mstore(add(emptyPtr, 0x08), _WNATIVE_RELAY)
                mstore(add(emptyPtr, 0x28), returnAmount)
                if iszero(
                    call(gas(), _WETH, 0, add(0x04, emptyPtr), 0x44, 0, 0x20)
                ) {
                    revertWithReason(
                        0x000000147472616e736665722057455448206661696c65640000000000000000,
                        0x58
                    ) // "transfer WETH failed"
                }
                mstore(add(emptyPtr, 0x04), returnAmount)
                if iszero(
                    call(gas(), _WNATIVE_RELAY, 0, emptyPtr, 0x24, 0, 0x20)
                ) {
                    revertWithReason(
                        0x00000013776974686472617720455448206661696c6564000000000000000000,
                        0x57
                    ) // "withdraw ETH failed"
                }
                if iszero(call(gas(), receiver, returnAmount, 0, 0, 0, 0)) {
                    revertWithReason(
                        0x000000137472616e7366657220455448206661696c6564000000000000000000,
                        0x57
                    ) // "transfer ETH failed"
                }
            }

            if lt(returnAmount, minReturn) {
                revertWithReason(
                    0x000000164d696e2072657475726e206e6f742072656163686564000000000000,
                    0x5a
                ) // "Min return not reached"
            }
            // emit event
            mstore(emptyPtr, srcToken)
            mstore(add(emptyPtr, 0x20), toToken)
            mstore(add(emptyPtr, 0x40), origin())
            mstore(add(emptyPtr, 0x60), amount)
            mstore(add(emptyPtr, 0x80), returnAmount)
            log1(
                emptyPtr,
                0xa0,
                0x1bb43f2da90e35f7b0cf38521ca95a49e68eb42fac49924930a5bd73cdf7576c
            )
        }
    }
}

// File: contracts/8/interfaces/IUniswapV3SwapCallback.sol

pragma solidity ^0.8.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

// File: contracts/8/interfaces/IUniV3.sol

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IUniV3 {
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function token0() external view returns (address);

    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);
}

// File: contracts/8/interfaces/IWETH.sol

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IWETH {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// File: contracts/8/interfaces/IWNativeRelayer.sol

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IWNativeRelayer {
    function withdraw(uint256 _amount) external;
}

// File: contracts/8/libraries/RouterErrors.sol

/// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library RouterErrors {
    error ReturnAmountIsNotEnough();
    error InvalidMsgValue();
    error ERC20TransferFailed();
    error EmptyPools();
    error InvalidFromToken();
    error MsgValuedNotRequired();
}

// File: contracts/8/libraries/SafeCast.sol

/// SPDX-License-Identifier: MIT

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
    function toInt248(int256 value) internal pure returns (int248) {
        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");
        return int248(value);
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
    function toInt240(int256 value) internal pure returns (int240) {
        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");
        return int240(value);
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
    function toInt232(int256 value) internal pure returns (int232) {
        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");
        return int232(value);
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
    function toInt224(int256 value) internal pure returns (int224) {
        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");
        return int224(value);
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
    function toInt216(int256 value) internal pure returns (int216) {
        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");
        return int216(value);
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
    function toInt208(int256 value) internal pure returns (int208) {
        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");
        return int208(value);
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
    function toInt200(int256 value) internal pure returns (int200) {
        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");
        return int200(value);
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
    function toInt192(int256 value) internal pure returns (int192) {
        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");
        return int192(value);
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
    function toInt184(int256 value) internal pure returns (int184) {
        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");
        return int184(value);
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
    function toInt176(int256 value) internal pure returns (int176) {
        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");
        return int176(value);
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
    function toInt168(int256 value) internal pure returns (int168) {
        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");
        return int168(value);
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
    function toInt160(int256 value) internal pure returns (int160) {
        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");
        return int160(value);
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
    function toInt152(int256 value) internal pure returns (int152) {
        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");
        return int152(value);
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
    function toInt144(int256 value) internal pure returns (int144) {
        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");
        return int144(value);
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
    function toInt136(int256 value) internal pure returns (int136) {
        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");
        return int136(value);
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
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
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
    function toInt120(int256 value) internal pure returns (int120) {
        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");
        return int120(value);
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
    function toInt112(int256 value) internal pure returns (int112) {
        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");
        return int112(value);
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
    function toInt104(int256 value) internal pure returns (int104) {
        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");
        return int104(value);
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
    function toInt96(int256 value) internal pure returns (int96) {
        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");
        return int96(value);
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
    function toInt88(int256 value) internal pure returns (int88) {
        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");
        return int88(value);
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
    function toInt80(int256 value) internal pure returns (int80) {
        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");
        return int80(value);
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
    function toInt72(int256 value) internal pure returns (int72) {
        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");
        return int72(value);
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
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
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
    function toInt56(int256 value) internal pure returns (int56) {
        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");
        return int56(value);
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
    function toInt48(int256 value) internal pure returns (int48) {
        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");
        return int48(value);
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
    function toInt40(int256 value) internal pure returns (int40) {
        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");
        return int40(value);
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
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
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
    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");
        return int24(value);
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
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
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
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
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

// File: contracts/8/UnxswapV3Router.sol

/// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;











contract UnxswapV3Router is IUniswapV3SwapCallback, CommonUtils {
    using Address for address payable;

    uint256 private constant _ONE_FOR_ZERO_MASK = 1 << 255; // Mask for identifying if the swap is one-for-zero
    uint256 private constant _WETH_UNWRAP_MASK = 1 << 253; // Mask for identifying if WETH should be unwrapped to ETH
    bytes32 private constant _POOL_INIT_CODE_HASH =
        0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54; // Pool init code hash
    bytes32 private constant _FF_FACTORY =
        0xff1F98431c8aD98523631AE4a59f267346ea31F9840000000000000000000000; // Factory address
    // concatenation of token0(), token1() fee(), transfer() and claimTokens() selectors
    bytes32 private constant _SELECTORS =
        0x0dfe1681d21220a7ddca3f43a9059cbb0a5ea466000000000000000000000000;
    // concatenation of withdraw(uint),transfer()
    bytes32 private constant _SELECTORS2 =
        0x2e1a7d4da9059cbb000000000000000000000000000000000000000000000000;
    uint160 private constant _MIN_SQRT_RATIO = 4_295_128_739 + 1;
    uint160 private constant _MAX_SQRT_RATIO =
        1_461_446_703_485_210_103_287_273_052_203_988_822_378_723_970_342 - 1;
    bytes32 private constant _SWAP_SELECTOR =
        0x128acb0800000000000000000000000000000000000000000000000000000000; // Swap function selector
    uint256 private constant _INT256_MAX =
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; // Maximum int256
    uint256 private constant _INT256_MIN =
        0x8000000000000000000000000000000000000000000000000000000000000000; // Minimum int256

    /// @notice Conducts a swap using the Uniswap V3 protocol internally within the contract.
    /// @param payer The address of the account providing the tokens for the swap.
    /// @param receiver The address that will receive the tokens after the swap.
    /// @param amount The amount of the source token to be swapped.
    /// @param minReturn The minimum amount of tokens that must be received for the swap to be valid, safeguarding against excessive slippage.
    /// @param pools An array of pool identifiers defining the swap route within Uniswap V3.
    /// @return returnAmount The amount of tokens received from the swap.
    /// @return srcTokenAddr The address of the source token used for the swap.
    /// @dev This internal function encapsulates the core logic for executing swaps on Uniswap V3. It is intended to be used by other functions in the contract that prepare and pass the necessary parameters. The function handles the swapping process, ensuring that the minimum return is met and managing the transfer of tokens.
    function _uniswapV3Swap(
        address payer,
        address payable receiver,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) internal returns (uint256 returnAmount, address srcTokenAddr) {
        assembly {
            function _revertWithReason(m, len) {
                mstore(
                    0,
                    0x08c379a000000000000000000000000000000000000000000000000000000000
                )
                mstore(
                    0x20,
                    0x0000002000000000000000000000000000000000000000000000000000000000
                )
                mstore(0x40, m)
                revert(0, len)
            }
            function _makeSwap(_receiver, _payer, _pool, _amount)
                -> _returnAmount
            {
                if lt(_INT256_MAX, _amount) {
                    mstore(
                        0,
                        0xb3f79fd000000000000000000000000000000000000000000000000000000000
                    ) //SafeCastToInt256Failed()
                    revert(0, 4)
                }
                let freePtr := mload(0x40)
                let zeroForOne := eq(and(_pool, _ONE_FOR_ZERO_MASK), 0)

                let poolAddr := and(_pool, _ADDRESS_MASK)
                switch zeroForOne
                case 1 {
                    mstore(freePtr, _SWAP_SELECTOR)
                    let paramPtr := add(freePtr, 4)
                    mstore(paramPtr, _receiver)
                    mstore(add(paramPtr, 0x20), true)
                    mstore(add(paramPtr, 0x40), _amount)
                    mstore(add(paramPtr, 0x60), _MIN_SQRT_RATIO)
                    mstore(add(paramPtr, 0x80), 0xa0)
                    mstore(add(paramPtr, 0xa0), 32)
                    mstore(add(paramPtr, 0xc0), _payer)
                    let success := call(gas(), poolAddr, 0, freePtr, 0xe4, 0, 0)
                    if iszero(success) {
                        revert(0, 32)
                    }
                    returndatacopy(0, 32, 32) // only copy _amount1   MEM[0:] <= RETURNDATA[32:32+32]
                }
                default {
                    mstore(freePtr, _SWAP_SELECTOR)
                    let paramPtr := add(freePtr, 4)
                    mstore(paramPtr, _receiver)
                    mstore(add(paramPtr, 0x20), false)
                    mstore(add(paramPtr, 0x40), _amount)
                    mstore(add(paramPtr, 0x60), _MAX_SQRT_RATIO)
                    mstore(add(paramPtr, 0x80), 0xa0)
                    mstore(add(paramPtr, 0xa0), 32)
                    mstore(add(paramPtr, 0xc0), _payer)
                    let success := call(gas(), poolAddr, 0, freePtr, 0xe4, 0, 0)
                    if iszero(success) {
                        revert(0, 32)
                    }
                    returndatacopy(0, 0, 32) // only copy _amount0   MEM[0:] <= RETURNDATA[0:0+32]
                }
                _returnAmount := mload(0)
                if lt(_returnAmount, _INT256_MIN) {
                    mstore(
                        0,
                        0x88c8ee9c00000000000000000000000000000000000000000000000000000000
                    ) //SafeCastToUint256Failed()
                    revert(0, 4)
                }
                _returnAmount := add(1, not(_returnAmount)) // -a = ~a + 1
            }
            function _wrapWeth(_amount) {
                // require callvalue() >= amount, lt: if x < y return 1，else return 0
                if eq(lt(callvalue(), _amount), 1) {
                    mstore(
                        0,
                        0x1841b4e100000000000000000000000000000000000000000000000000000000
                    ) // InvalidMsgValue()
                    revert(0, 4)
                }

                let success := call(gas(), _WETH, _amount, 0, 0, 0, 0) //进入fallback逻辑
                if iszero(success) {
                    _revertWithReason(
                        0x0000001357455448206465706f736974206661696c6564000000000000000000,
                        87
                    ) //WETH deposit failed
                }
            }
            function _unWrapWeth(_receiver, _amount) {
                let freePtr := mload(0x40)
                let transferPtr := add(freePtr, 4)

                mstore(freePtr, _SELECTORS2) // withdraw amountWith to amount
                // transfer
                mstore(add(transferPtr, 4), _WNATIVE_RELAY)
                mstore(add(transferPtr, 36), _amount)
                let success := call(gas(), _WETH, 0, transferPtr, 68, 0, 0)
                if iszero(success) {
                    _revertWithReason(
                        0x000000147472616e736665722077657468206661696c65640000000000000000,
                        88
                    ) // transfer weth failed
                }
                // withdraw
                mstore(add(freePtr, 4), _amount)
                success := call(gas(), _WNATIVE_RELAY, 0, freePtr, 36, 0, 0)
                if iszero(success) {
                    _revertWithReason(
                        0x0000001477697468647261772077657468206661696c65640000000000000000,
                        88
                    ) // withdraw weth failed
                }
                // msg.value transfer
                success := call(gas(), _receiver, _amount, 0, 0, 0, 0)
                if iszero(success) {
                    _revertWithReason(
                        0x0000001173656e64206574686572206661696c65640000000000000000000000,
                        85
                    ) // send ether failed
                }
            }
            function _token0(_pool) -> token0 {
                let freePtr := mload(0x40)
                mstore(freePtr, _SELECTORS)
                let success := staticcall(gas(), _pool, freePtr, 0x4, 0, 0)
                if iszero(success) {
                    _revertWithReason(
                        0x0000001167657420746f6b656e30206661696c65640000000000000000000000,
                        85
                    ) // get token0 failed
                }
                returndatacopy(0, 0, 32)
                token0 := mload(0)
            }
            function _token1(_pool) -> token1 {
                let freePtr := mload(0x40)
                mstore(freePtr, _SELECTORS)
                let success := staticcall(
                    gas(),
                    _pool,
                    add(freePtr, 4),
                    0x4,
                    0,
                    0
                )
                if iszero(success) {
                    _revertWithReason(
                        0x0000001167657420746f6b656e31206661696c65640000000000000000000000,
                        84
                    ) // get token1 failed
                }
                returndatacopy(0, 0, 32)
                token1 := mload(0)
            }
            function _emitEvent(
                _firstPoolStart,
                _lastPoolStart,
                _returnAmount,
                wrapWeth,
                unwrapWeth
            ) -> srcToken {
                srcToken := _ETH
                let toToken := _ETH
                if eq(wrapWeth, false) {
                    let firstPool := calldataload(_firstPoolStart)
                    switch eq(0, and(firstPool, _ONE_FOR_ZERO_MASK))
                    case true {
                        srcToken := _token0(firstPool)
                    }
                    default {
                        srcToken := _token1(firstPool)
                    }
                }
                if eq(unwrapWeth, false) {
                    let lastPool := calldataload(_lastPoolStart)
                    switch eq(0, and(lastPool, _ONE_FOR_ZERO_MASK))
                    case true {
                        toToken := _token1(lastPool)
                    }
                    default {
                        toToken := _token0(lastPool)
                    }
                }
                let freePtr := mload(0x40)
                mstore(0, srcToken)
                mstore(32, toToken)
                mstore(64, origin())
                // mstore(96, _initAmount) //avoid stack too deep, since i mstore the initAmount to 96, so no need to re-mstore it
                mstore(128, _returnAmount)
                log1(
                    0,
                    160,
                    0x1bb43f2da90e35f7b0cf38521ca95a49e68eb42fac49924930a5bd73cdf7576c
                )
                mstore(0x40, freePtr)
            }
            let firstPoolStart
            let lastPoolStart
            {
                let len := pools.length
                firstPoolStart := pools.offset //
                lastPoolStart := sub(add(firstPoolStart, mul(len, 32)), 32)

                if eq(len, 0) {
                    mstore(
                        0,
                        0x67e7c0f600000000000000000000000000000000000000000000000000000000
                    ) // EmptyPools()
                    revert(0, 4)
                }
            }

            let wrapWeth := gt(callvalue(), 0)
            if wrapWeth {
                _wrapWeth(amount)
                payer := address()
            }

            mstore(96, amount) // 96 is not override by _makeSwap, since it only use freePtr memory, and it is not override by unWrapWeth ethier
            for {
                let i := firstPoolStart
            } lt(i, lastPoolStart) {
                i := add(i, 32)
            } {
                amount := _makeSwap(address(), payer, calldataload(i), amount)
                payer := address()
            }
            let unwrapWeth := gt(
                and(calldataload(lastPoolStart), _WETH_UNWRAP_MASK),
                0
            ) // pools[lastIndex] & _WETH_UNWRAP_MASK > 0

            // last one or only one
            switch unwrapWeth
            case 1 {
                returnAmount := _makeSwap(
                    address(),
                    payer,
                    calldataload(lastPoolStart),
                    amount
                )
                _unWrapWeth(receiver, returnAmount)
            }
            case 0 {
                returnAmount := _makeSwap(
                    receiver,
                    payer,
                    calldataload(lastPoolStart),
                    amount
                )
            }
            if lt(returnAmount, minReturn) {
                _revertWithReason(
                    0x000000164d696e2072657475726e206e6f742072656163686564000000000000,
                    90
                ) // Min return not reached
            }
            srcTokenAddr := _emitEvent(
                firstPoolStart,
                lastPoolStart,
                returnAmount,
                wrapWeth,
                unwrapWeth
            )
        }
    }

    /// @inheritdoc IUniswapV3SwapCallback
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata /*data*/
    ) external override {
        assembly {
            // solhint-disable-line no-inline-assembly
            function reRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            function validateERC20Transfer(status) {
                if iszero(status) {
                    reRevert()
                }
                let success := or(
                    iszero(returndatasize()), // empty return data
                    and(gt(returndatasize(), 31), eq(mload(0), 1)) // true in return data
                )
                if iszero(success) {
                    mstore(
                        0,
                        0xf27f64e400000000000000000000000000000000000000000000000000000000
                    ) // ERC20TransferFailed()
                    revert(0, 4)
                }
            }

            let emptyPtr := mload(0x40)
            let resultPtr := add(emptyPtr, 21) // 0x15 = _FF_FACTORY size

            mstore(emptyPtr, _SELECTORS)
            // token0
            if iszero(staticcall(gas(), caller(), emptyPtr, 4, 0, 32)) {
                reRevert()
            }
            //token1
            if iszero(
                staticcall(gas(), caller(), add(emptyPtr, 4), 4, 32, 32)
            ) {
                reRevert()
            }
            // fee
            if iszero(
                staticcall(gas(), caller(), add(emptyPtr, 8), 4, 64, 32)
            ) {
                reRevert()
            }

            let token
            let amount
            switch sgt(amount0Delta, 0)
            case 1 {
                token := mload(0)
                amount := amount0Delta
            }
            default {
                token := mload(32)
                amount := amount1Delta
            }
            // let salt := keccak256(0, 96)
            mstore(emptyPtr, _FF_FACTORY)
            mstore(resultPtr, keccak256(0, 96)) // Compute the inner hash in-place
            mstore(add(resultPtr, 32), _POOL_INIT_CODE_HASH)
            let pool := and(keccak256(emptyPtr, 85), _ADDRESS_MASK)
            if iszero(eq(pool, caller())) {
                // if xor(pool, caller()) {
                mstore(
                    0,
                    0xb2c0272200000000000000000000000000000000000000000000000000000000
                ) // BadPool()
                revert(0, 4)
            }

            let payer := calldataload(132) // 4+32+32+32+32 = 132
            mstore(emptyPtr, _SELECTORS)
            switch eq(payer, address())
            case 1 {
                // token.safeTransfer(msg.sender,amount)
                mstore(add(emptyPtr, 0x10), caller())
                mstore(add(emptyPtr, 0x30), amount)
                validateERC20Transfer(
                    call(gas(), token, 0, add(emptyPtr, 0x0c), 0x44, 0, 0x20)
                )
            }
            default {
                // approveProxy.claimTokens(token, payer, msg.sender, amount);
                mstore(add(emptyPtr, 0x14), token)
                mstore(add(emptyPtr, 0x34), payer)
                mstore(add(emptyPtr, 0x54), caller())
                mstore(add(emptyPtr, 0x74), amount)
                validateERC20Transfer(
                    call(
                        gas(),
                        _APPROVE_PROXY,
                        0,
                        add(emptyPtr, 0x10),
                        0x84,
                        0,
                        0x20
                    )
                )
            }
        }
    }
}

// File: contracts/8/interfaces/IAdapter.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

interface IAdapter {
    function sellBase(
        address to,
        address pool,
        bytes memory data
    ) external;

    function sellQuote(
        address to,
        address pool,
        bytes memory data
    ) external;
}

// File: contracts/8/interfaces/IApproveProxy.sol

pragma solidity ^0.8.0;

interface IApproveProxy {
    function isAllowedProxy(address _proxy) external view returns (bool);

    function claimTokens(
        address token,
        address who,
        address dest,
        uint256 amount
    ) external;

    function tokenApprove() external view returns (address);
    function addProxy(address) external;
}

// File: contracts/8/interfaces/IXBridge.sol

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IXBridge {
    function payerReceiver() external view returns(address, address);
}

// File: contracts/8/libraries/RevertReasonParser.sol

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

// File: contracts/8/libraries/Permitable.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;






/// @title Base contract with common permit handling logics
abstract contract Permitable {
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
}

// File: contracts/8/libraries/PMMLib.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PMMLib {

  // ============ Struct ============
  struct PMMSwapRequest {
      uint256 pathIndex;
      address payer;
      address fromToken;
      address toToken;
      uint256 fromTokenAmountMax;
      uint256 toTokenAmountMax;
      uint256 salt;
      uint256 deadLine;
      bool isPushOrder;
      bytes extension;
      // address marketMaker;
      // uint256 subIndex;
      // bytes signature;
      // uint256 source;  1byte type + 1byte bool（reverse） + 0...0 + 20 bytes address
  }

  struct PMMBaseRequest {
    uint256 fromTokenAmount;
    uint256 minReturnAmount;
    uint256 deadLine;
    bool fromNative;
    bool toNative;
  }

  enum PMM_ERROR {
      NO_ERROR,
      INVALID_OPERATOR,
      QUOTE_EXPIRED,
      ORDER_CANCELLED_OR_FINALIZED,
      REMAINING_AMOUNT_NOT_ENOUGH,
      INVALID_AMOUNT_REQUEST,
      FROM_TOKEN_PAYER_ERROR,
      TO_TOKEN_PAYER_ERROR,
      WRONG_FROM_TOKEN
  }

  event PMMSwap(
    uint256 pathIndex,
    uint256 subIndex,
    uint256 errorCode
  );

  error PMMErrorCode(uint256 errorCode);

}

// File: contracts/8/libraries/CommissionLib.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/// @title Base contract with common permit handling logics

abstract contract CommissionLib is CommonUtils {
    uint256 internal constant _COMMISSION_FEE_MASK =
        0x000000000000ffffffffffff0000000000000000000000000000000000000000;
    uint256 internal constant _COMMISSION_FLAG_MASK =
        0xffffffffffff0000000000000000000000000000000000000000000000000000;
    uint256 internal constant FROM_TOKEN_COMMISSION =
        0x3ca20afc2aaa0000000000000000000000000000000000000000000000000000;
    uint256 internal constant TO_TOKEN_COMMISSION =
        0x3ca20afc2bbb0000000000000000000000000000000000000000000000000000;

    event CommissionRecord(uint256 commissionAmount, address referrerAddress);

    // set default vaule. can change when need.
    uint256 public constant commissionRateLimit = 300;

    struct CommissionInfo {
        bool isFromTokenCommission;
        bool isToTokenCommission;
        uint256 commissionRate;
        address refererAddress;
        address token;
    }

    function _getCommissionInfo()
        internal
        pure
        returns (CommissionInfo memory commissionInfo)
    {
        assembly ("memory-safe") {
            let freePtr := mload(0x40)
            mstore(0x40, add(freePtr, 0xa0))
            let commissionData := calldataload(sub(calldatasize(), 0x20))
            mstore(
                commissionInfo,
                eq(
                    FROM_TOKEN_COMMISSION,
                    and(commissionData, _COMMISSION_FLAG_MASK)
                )
            ) // isFromTokenCommission
            mstore(
                add(0x20, commissionInfo),
                eq(
                    TO_TOKEN_COMMISSION,
                    and(commissionData, _COMMISSION_FLAG_MASK)
                )
            )
            mstore(
                add(0x40, commissionInfo),
                shr(160, and(commissionData, _COMMISSION_FEE_MASK))
            )
            mstore(
                add(0x60, commissionInfo),
                and(commissionData, _ADDRESS_MASK)
            )
            mstore(
                add(0x80, commissionInfo),
                and(calldataload(sub(calldatasize(), 0x40)), _ADDRESS_MASK)
            )
        }
    }

    function _getBalanceOf(
        address token,
        address user
    ) internal returns (uint256 amount) {
        assembly {
            function _revertWithReason(m, len) {
                mstore(
                    0,
                    0x08c379a000000000000000000000000000000000000000000000000000000000
                )
                mstore(
                    0x20,
                    0x0000002000000000000000000000000000000000000000000000000000000000
                )
                mstore(0x40, m)
                revert(0, len)
            }
            switch eq(token, _ETH)
            case 1 {
                amount := selfbalance()
            }
            default {
                let freePtr := mload(0x40)
                mstore(0x40, add(freePtr, 0x24))
                mstore(
                    freePtr,
                    0x70a0823100000000000000000000000000000000000000000000000000000000
                ) //balanceOf
                mstore(add(freePtr, 0x04), user)
                let success := staticcall(gas(), token, freePtr, 0x24, 0, 0x20)
                if eq(success, 0) {
                    _revertWithReason(
                        0x000000146765742062616c616e63654f66206661696c65640000000000000000,
                        0x58
                    )
                }
                amount := mload(0x00)
            }
        }
    }

    function _doCommissionFromToken(
        CommissionInfo memory commissionInfo,
        address receiver,
        uint256 inputAmount
    ) internal returns (address, uint256) {
        if (commissionInfo.isToTokenCommission) {
            return (
                address(this),
                _getBalanceOf(commissionInfo.token, address(this))
            );
        }
        if (!commissionInfo.isFromTokenCommission) {
            return (receiver, 0);
        }
        assembly ("memory-safe") {
            function _revertWithReason(m, len) {
                mstore(
                    0,
                    0x08c379a000000000000000000000000000000000000000000000000000000000
                )
                mstore(
                    0x20,
                    0x0000002000000000000000000000000000000000000000000000000000000000
                )
                mstore(0x40, m)
                revert(0, len)
            }
            let rate := mload(add(commissionInfo, 0x40))
            if gt(rate, commissionRateLimit) {
                _revertWithReason(
                    0x0000001b6572726f7220636f6d6d697373696f6e2072617465206c696d697400,
                    0x5f
                ) //"error commission rate limit"
            }
            let token := mload(add(commissionInfo, 0x80))
            let referer := mload(add(commissionInfo, 0x60))
            let amount := div(mul(inputAmount, rate), sub(10000, rate))
            switch eq(token, _ETH)
            case 1 {
                let success := call(gas(), referer, amount, 0, 0, 0, 0)
                if eq(success, 0) {
                    _revertWithReason(
                        0x0000001b636f6d6d697373696f6e2077697468206574686572206572726f7200,
                        0x5f
                    )
                }
            }
            default {
                let freePtr := mload(0x40)
                mstore(0x40, add(freePtr, 0x84))
                mstore(
                    freePtr,
                    0x0a5ea46600000000000000000000000000000000000000000000000000000000
                ) // claimTokens
                mstore(add(freePtr, 0x04), token)
                mstore(add(freePtr, 0x24), caller())
                mstore(add(freePtr, 0x44), referer)
                mstore(add(freePtr, 0x64), amount)
                let success := call(
                    gas(),
                    _APPROVE_PROXY,
                    0,
                    freePtr,
                    0x84,
                    0,
                    0
                )
                if eq(success, 0) {
                    _revertWithReason(
                        0x00000013636c61696d20746f6b656e73206661696c6564000000000000000000,
                        0x57
                    )
                }
            }
            let freePtr := mload(0x40)
            mstore(0x40, add(freePtr, 0x40))
            mstore(freePtr, amount)
            mstore(add(freePtr, 0x20), referer)
            log1(
                freePtr,
                0x40,
                0xffc60ee157a42f4d8edbd1897e6581a96d9ed04e44fb2ab53a47ce1eb8f2775b
            ) //emit CommissionRecord(commissionAmount, refererAddress);
        }
        return (receiver, 0);
    }

    function _doCommissionToToken(
        CommissionInfo memory commissionInfo,
        address receiver,
        uint256 balanceBefore
    ) internal returns (uint256 amount) {
        if (!commissionInfo.isToTokenCommission) {
            return 0;
        }
        assembly ("memory-safe") {
            function _revertWithReason(m, len) {
                mstore(
                    0,
                    0x08c379a000000000000000000000000000000000000000000000000000000000
                )
                mstore(
                    0x20,
                    0x0000002000000000000000000000000000000000000000000000000000000000
                )
                mstore(0x40, m)
                revert(0, len)
            }
            let rate := mload(add(commissionInfo, 0x40))
            if gt(rate, commissionRateLimit) {
                _revertWithReason(
                    0x0000001b6572726f7220636f6d6d697373696f6e2072617465206c696d697400,
                    0x5f
                ) //"error commission rate limit"
            }
            let token := mload(add(commissionInfo, 0x80))
            let referer := mload(add(commissionInfo, 0x60))

            switch eq(token, _ETH)
            case 1 {
                if lt(selfbalance(), balanceBefore) {
                    _revertWithReason(
                        0x0000000a737562206661696c65640000000000000000000000000000000000000,
                        0x4d
                    ) // sub failed
                }
                let inputAmount := sub(selfbalance(), balanceBefore)
                amount := div(mul(inputAmount, rate), 10000)
                let success := call(gas(), referer, amount, 0, 0, 0, 0)
                if eq(success, 0) {
                    _revertWithReason(
                        0x000000197472616e73666572206574682072656665726572206661696c000000,
                        0x5d
                    ) // transfer eth referer fail
                }
                success := call(
                    gas(),
                    receiver,
                    sub(inputAmount, amount),
                    0,
                    0,
                    0,
                    0
                )
                if eq(success, 0) {
                    _revertWithReason(
                        0x0000001a7472616e7366657220657468207265636569766572206661696c0000,
                        0x5e
                    ) // transfer eth receiver fail
                }
            }
            default {
                let freePtr := mload(0x40)
                mstore(0x40, add(freePtr, 0x48))
                mstore(
                    freePtr,
                    0xa9059cbba9059cbb70a082310000000000000000000000000000000000000000
                ) // transfer transfer balanceOf
                mstore(add(freePtr, 0x0c), address())
                let success := staticcall(
                    gas(),
                    token,
                    add(freePtr, 8),
                    36,
                    0,
                    0x20
                )
                if eq(success, 0) {
                    _revertWithReason(
                        0x000000146765742062616c616e63654f66206661696c65640000000000000000,
                        0x58
                    )
                }
                let balanceAfter := mload(0x00)
                if lt(balanceAfter, balanceBefore) {
                    _revertWithReason(
                        0x0000000a737562206661696c65640000000000000000000000000000000000000,
                        0x4d
                    ) // sub failed
                }
                let inputAmount := sub(balanceAfter, balanceBefore)
                amount := div(mul(inputAmount, rate), 10000)
                mstore(add(freePtr, 0x08), referer)
                mstore(add(freePtr, 0x28), amount)
                success := call(gas(), token, 0, add(freePtr, 4), 0x44, 0, 0)
                if eq(success, 0) {
                    _revertWithReason(
                        0x0000001b7472616e7366657220746f6b656e2072656665726572206661696c00,
                        0x5f
                    ) //transfer token referer fail
                }
                mstore(add(freePtr, 0x04), receiver)
                mstore(add(freePtr, 0x24), sub(inputAmount, amount))
                success := call(gas(), token, 0, freePtr, 0x44, 0, 0)
                if eq(success, 0) {
                    _revertWithReason(
                        0x0000001c7472616e7366657220746f6b656e207265636569766572206661696c,
                        0x60
                    ) //transfer token receiver fail
                }
            }
            let freePtr := mload(0x40)
            mstore(0x40, add(freePtr, 0x40))
            mstore(freePtr, amount)
            mstore(add(freePtr, 0x20), referer)
            log1(
                freePtr,
                0x40,
                0xffc60ee157a42f4d8edbd1897e6581a96d9ed04e44fb2ab53a47ce1eb8f2775b
            ) //emit CommissionRecord(commissionAmount, refererAddress);
        }
    }
}

// File: contracts/8/libraries/EthReceiver.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Base contract with common payable logics
abstract contract EthReceiver {
  receive() external payable {
    // solhint-disable-next-line avoid-tx-origin
    require(msg.sender != tx.origin, "ETH deposit rejected");
  }
}

// File: contracts/8/libraries/WrapETHSwap.sol

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;








/// @title Base contract with common payable logics
abstract contract WrapETHSwap is CommonUtils {

  uint256 private constant SWAP_AMOUNT = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  
  function swapWrap(uint256 orderId, uint256 rawdata) external payable {
    bool reversed;
    uint128 amount;
    assembly {
      reversed := and(rawdata, _REVERSE_MASK)
      amount := and(rawdata, SWAP_AMOUNT)
    }
    require(amount > 0, "amount must be > 0");
    if (reversed) {
      IApproveProxy(_APPROVE_PROXY).claimTokens(_WETH, msg.sender, _WNATIVE_RELAY, amount);
      IWNativeRelayer(_WNATIVE_RELAY).withdraw(amount);
      (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
      require(success, "transfer native token failed");
    } else {
      require(msg.value == amount, "value not equal amount");
      IWETH(_WETH).deposit{value: amount}();
      SafeERC20.safeTransfer(IERC20(_WETH), msg.sender, amount);
    }
    emit SwapOrderId(orderId);
    emit OrderRecord(reversed ? _WETH : _ETH, reversed ? _ETH: _WETH, msg.sender, amount, amount);
  }
}

// File: contracts/8/storage/DexRouterStorage.sol

pragma solidity ^0.8.0;

contract DexRouterStorage {
    // In the test scenario, we take it as a settable state and adjust it to a constant after it stabilizes
    address public approveProxy;
    address public wNativeRelayer;
    mapping(address => bool) public priorityAddresses;

    uint256[19] internal _dexRouterGap;

    address public admin;
}

// File: contracts/8/DexRouter.sol

pragma solidity ^0.8.0;
pragma abicoder v2;






















/// @title DexRouterV1
/// @notice Entrance of Split trading in Dex platform
/// @dev Entrance of Split trading in Dex platform
contract DexRouter is
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    Permitable,
    EthReceiver,
    UnxswapRouter,
    UnxswapV3Router,
    DexRouterStorage,
    WrapETHSwap,
    CommissionLib
{
    using UniversalERC20 for IERC20;

    struct BaseRequest {
        uint256 fromToken;
        address toToken;
        uint256 fromTokenAmount;
        uint256 minReturnAmount;
        uint256 deadLine;
    }

    struct RouterPath {
        address[] mixAdapters;
        address[] assetTo;
        uint256[] rawData;
        bytes[] extraData;
        uint256 fromToken;
    }
    /// @notice Initializes the contract with necessary setup for ownership and reentrancy protection.
    /// @dev This function serves as a constructor for upgradeable contracts and should be called
    /// through a proxy during the initial deployment. It initializes inherited contracts
    /// such as `OwnableUpgradeable` and `ReentrancyGuardUpgradeable` to set up the contract's owner
    /// and reentrancy guard.

    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    //-------------------------------
    //------- Events ----------------
    //-------------------------------

    /// @notice Emitted when a priority address status is updated.
    /// @param priorityAddress The address whose priority status has been changed.
    /// @param valid A boolean indicating the new status of the priority address.
    /// True means the address is now considered a priority address, and false means it is not.
    event PriorityAddressChanged(address priorityAddress, bool valid);

    /// @notice Emitted when the admin address of the contract is changed.
    /// @param newAdmin The address of the new admin.
    event AdminChanged(address newAdmin);

    //-------------------------------
    //------- Modifier --------------
    //-------------------------------
    /// @notice Ensures a function is called before a specified deadline.
    /// @param deadLine The UNIX timestamp deadline.
    modifier isExpired(uint256 deadLine) {
        require(deadLine >= block.timestamp, "Route: expired");
        _;
    }
    /// @notice Restricts function access to addresses marked as priority.
    /// Ensures that only addresses designated with specific privileges can execute the function.

    modifier onlyPriorityAddress() {
        require(priorityAddresses[msg.sender] == true, "only priority");
        _;
    }

    //-------------------------------
    //------- Internal Functions ----
    //-------------------------------
    /// @notice Executes multiple adapters for a transaction pair.
    /// @param payer The address of the payer.
    /// @param to The address of the receiver.
    /// @param batchAmount The amount to be transferred in each batch.
    /// @param path The routing path for the swap.
    /// @param noTransfer A flag to indicate whether the token transfer should be skipped.
    /// @dev It includes checks for the total weight of the paths and executes the swapping through the adapters.
    function _exeForks(
        address payer,
        address to,
        uint256 batchAmount,
        RouterPath calldata path,
        bool noTransfer
    ) private {
        address fromToken = _bytes32ToAddress(path.fromToken);
        // fix post audit DRW-01: lack of check on Weights
        uint256 totalWeight;
        // execute multiple Adapters for a transaction pair
        uint256 pathLength = path.mixAdapters.length;
        for (uint256 i = 0; i < pathLength; ) {
            bytes32 rawData = bytes32(path.rawData[i]);
            address poolAddress;
            bool reserves;
            uint256 weight;
            assembly {
                poolAddress := and(rawData, _ADDRESS_MASK)
                reserves := and(rawData, _REVERSE_MASK)
                weight := shr(160, and(rawData, _WEIGHT_MASK))
            }
            totalWeight += weight;
            if (i == pathLength - 1) {
                require(
                    totalWeight <= 10_000,
                    "totalWeight can not exceed 10000 limit"
                );
            }

            if (!noTransfer) {
                uint256 _fromTokenAmount = weight == 10_000
                    ? batchAmount
                    : (batchAmount * weight) / 10_000;
                _transferInternal(
                    payer,
                    path.assetTo[i],
                    fromToken,
                    _fromTokenAmount
                );
            }

            if (reserves) {
                IAdapter(path.mixAdapters[i]).sellQuote(
                    to,
                    poolAddress,
                    path.extraData[i]
                );
            } else {
                IAdapter(path.mixAdapters[i]).sellBase(
                    to,
                    poolAddress,
                    path.extraData[i]
                );
            }
            unchecked {
                ++i;
            }
        }
    }
    /// @notice Executes a series of swaps or operations defined by a set of routing paths, potentially across different protocols or pools.
    /// @param payer The address providing the tokens for the swap.
    /// @param receiver The address receiving the output tokens.
    /// @param isToNative Indicates whether the final asset should be converted to the native blockchain asset (e.g., ETH).
    /// @param batchAmount The total amount of the input token to be swapped.
    /// @param hops An array of RouterPath structures, each defining a segment of the swap route.
    /// @dev This function manages complex swap routes that might involve multiple hops through different liquidity pools or swapping protocols.
    /// It iterates through the provided `hops`, executing each segment of the route in sequence.

    function _exeHop(
        address payer,
        address receiver,
        bool isToNative,
        uint256 batchAmount,
        RouterPath[] calldata hops
    ) private {
        address fromToken = _bytes32ToAddress(hops[0].fromToken);
        bool toNext;
        bool noTransfer;

        // execute hop
        uint256 hopLength = hops.length;
        for (uint256 i = 0; i < hopLength; ) {
            if (i > 0) {
                fromToken = _bytes32ToAddress(hops[i].fromToken);
                batchAmount = IERC20(fromToken).universalBalanceOf(
                    address(this)
                );
                payer = address(this);
            }

            address to = address(this);
            if (i == hopLength - 1 && !isToNative) {
                to = receiver;
            } else if (i < hopLength - 1 && hops[i + 1].assetTo.length == 1) {
                to = hops[i + 1].assetTo[0];
                toNext = true;
            } else {
                toNext = false;
            }

            // 3.2 execute forks
            _exeForks(payer, to, batchAmount, hops[i], noTransfer);
            noTransfer = toNext;

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Transfers tokens internally within the contract.
    /// @param payer The address of the payer.
    /// @param to The address of the receiver.
    /// @param token The address of the token to be transferred.
    /// @param amount The amount of tokens to be transferred.
    /// @dev Handles the transfer of ERC20 tokens or native tokens within the contract.
    function _transferInternal(
        address payer,
        address to,
        address token,
        uint256 amount
    ) private {
        if (payer == address(this)) {
            SafeERC20.safeTransfer(IERC20(token), to, amount);
        } else {
            IApproveProxy(_APPROVE_PROXY).claimTokens(token, payer, to, amount);
        }
    }
    /// @notice Transfers the specified token to the user.
    /// @param token The address of the token to be transferred.
    /// @param to The address of the receiver.
    /// @dev Handles the withdrawal of tokens to the user, converting WETH to ETH if necessary.

    function _transferTokenToUser(address token, address to) private {
        if ((IERC20(token).isETH())) {
            uint256 wethBal = IERC20(address(uint160(_WETH))).balanceOf(
                address(this)
            );
            if (wethBal > 0) {
                IWETH(address(uint160(_WETH))).transfer(
                    _WNATIVE_RELAY,
                    wethBal
                );
                IWNativeRelayer(_WNATIVE_RELAY).withdraw(wethBal);
            }
            if (to != address(this)) {
                uint256 ethBal = address(this).balance;
                if (ethBal > 0) {
                    (bool success, ) = payable(to).call{value: ethBal}("");
                    require(success, "transfer native token failed");
                }
            }
        } else {
            if (to != address(this)) {
                uint256 bal = IERC20(token).balanceOf(address(this));
                if (bal > 0) {
                    SafeERC20.safeTransfer(IERC20(token), to, bal);
                }
            }
        }
    }

    /// @notice Converts a uint256 value into an address.
    /// @param param The uint256 value to be converted.
    /// @return result The address obtained from the conversion.
    /// @dev This function is used to extract an address from a uint256,
    /// typically used when dealing with low-level data operations or when addresses are packed into larger data types.

    function _bytes32ToAddress(
        uint256 param
    ) private pure returns (address result) {
        assembly {
            result := and(param, _ADDRESS_MASK)
        }
    }
    /// @notice Executes a complex swap based on provided parameters and paths.
    /// @param baseRequest Basic swap details including tokens, amounts, and deadline.
    /// @param batchesAmount Amounts for each swap batch.
    /// @param batches Detailed swap paths for execution.
    /// @param payer Address providing the tokens.
    /// @param receiver Address receiving the swapped tokens.
    /// @return returnAmount Total received tokens from the swap.

    function _smartSwapInternal(
        BaseRequest memory baseRequest,
        uint256[] memory batchesAmount,
        RouterPath[][] calldata batches,
        address payer,
        address receiver
    ) private returns (uint256 returnAmount) {
        // 1. transfer from token in
        BaseRequest memory _baseRequest = baseRequest;
        require(
            _baseRequest.fromTokenAmount > 0,
            "Route: fromTokenAmount must be > 0"
        );
        address fromToken = _bytes32ToAddress(_baseRequest.fromToken);
        returnAmount = IERC20(_baseRequest.toToken).universalBalanceOf(
            receiver
        );

        // In order to deal with ETH/WETH transfer rules in a unified manner,
        // we do not need to judge according to fromToken.
        if (UniversalERC20.isETH(IERC20(fromToken))) {
            IWETH(address(uint160(_WETH))).deposit{
                value: _baseRequest.fromTokenAmount
            }();
            payer = address(this);
        }

        // 2. check total batch amount
        {
            // avoid stack too deep
            uint256 totalBatchAmount;
            for (uint256 i = 0; i < batchesAmount.length; ) {
                totalBatchAmount += batchesAmount[i];
                unchecked {
                    ++i;
                }
            }
            require(
                totalBatchAmount <= _baseRequest.fromTokenAmount,
                "Route: number of batches should be <= fromTokenAmount"
            );
        }

        // 4. execute batch
        // check length, fix DRW-02: LACK OF LENGTH CHECK ON BATATCHES
        require(batchesAmount.length == batches.length, "length mismatch");
        for (uint256 i = 0; i < batches.length; ) {
            // execute hop, if the whole swap replacing by pmm fails, the funds will return to dexRouter
            _exeHop(
                payer,
                receiver,
                IERC20(_baseRequest.toToken).isETH(),
                batchesAmount[i],
                batches[i]
            );
            unchecked {
                ++i;
            }
        }

        // 5. transfer tokens to user
        _transferTokenToUser(_baseRequest.toToken, receiver);

        // 6. check minReturnAmount
        returnAmount =
            IERC20(_baseRequest.toToken).universalBalanceOf(receiver) -
            returnAmount;
        require(
            returnAmount >= _baseRequest.minReturnAmount,
            "Min return not reached"
        );

        emit OrderRecord(
            fromToken,
            _baseRequest.toToken,
            tx.origin,
            _baseRequest.fromTokenAmount,
            returnAmount
        );
        return returnAmount;
    }

    //-------------------------------
    //------- Admin functions -------
    //-------------------------------

    /// @notice Updates the priority status of an address, allowing or disallowing it from performing certain actions.
    /// @param _priorityAddress The address whose priority status is to be updated.
    /// @param valid A boolean indicating whether the address should be marked as a priority (true) or not (false).
    /// @dev This function can only be called by the contract owner or another authorized entity.
    /// It is typically used to grant or revoke special permissions to certain addresses.
    function setPriorityAddress(address _priorityAddress, bool valid) external {
        require(msg.sender == admin || msg.sender == owner(), "na");
        priorityAddresses[_priorityAddress] = valid;
        emit PriorityAddressChanged(_priorityAddress, valid);
    }
    /// @notice Assigns a new admin address for the protocol.
    /// @param _newAdmin The address to be granted admin privileges.
    /// @dev Only the current owner or existing admin can assign a new admin, ensuring secure management of protocol permissions.
    /// Changing the admin address is a critical operation that should be performed with caution.

    function setProtocolAdmin(address _newAdmin) external {
        require(msg.sender == admin || msg.sender == owner(), "na");
        admin = _newAdmin;
        emit AdminChanged(_newAdmin);
    }

    //-------------------------------
    //------- Users Functions -------
    //-------------------------------

    /// @notice Executes a smart swap operation through the XBridge, identified by a specific order ID.
    /// @param orderId The unique identifier for the swap order, facilitating tracking and reference.
    /// @param baseRequest Contains essential parameters for the swap, such as source and destination tokens, amount, minimum return, and deadline.
    /// @param batchesAmount Array of amounts for each batch in the swap, allowing for split operations across different routes or pools.
    /// @param batches Detailed paths for each swap batch, including adapters and target assets.
    /// @param extraData Additional data required for executing the swap, which may include specific instructions or parameters for adapters.
    /// @return returnAmount The total amount of the destination token received from the swap.
    /// @dev This function allows for complex swap operations across different liquidity sources or protocols, initiated via the XBridge.
    /// It's designed to be called by authorized addresses, ensuring that the swap meets predefined criteria and security measures.
    function smartSwapByOrderIdByXBridge(
        uint256 orderId,
        BaseRequest calldata baseRequest,
        uint256[] calldata batchesAmount,
        RouterPath[][] calldata batches,
        PMMLib.PMMSwapRequest[] calldata extraData
    )
        external
        payable
        isExpired(baseRequest.deadLine)
        nonReentrant
        onlyPriorityAddress
        returns (uint256 returnAmount)
    {
        emit SwapOrderId(orderId);
        (address payer, address receiver) = IXBridge(msg.sender)
            .payerReceiver();
        require(receiver != address(0), "not address(0)");
        return
            _smartSwapTo(payer, receiver, baseRequest, batchesAmount, batches);
    }
    /// @notice Executes a token swap using Unxswap protocol via XBridge for a specific order ID.
    /// @param srcToken The source token's address to be swapped.
    /// @param amount The amount of the source token to be swapped.
    /// @param minReturn The minimum acceptable return amount of destination tokens to ensure the swap is executed within acceptable slippage.
    /// @param pools Pool identifiers used for the swap, allowing for route optimization.
    /// @return returnAmount The amount of destination tokens received from the swap.
    /// @dev This function is designed to facilitate cross-protocol swaps through the XBridge,
    /// enabling swaps that adhere to specific routing paths defined by the pools parameter.
    /// It is accessible only to priority addresses, ensuring controlled access and execution.

    function unxswapByOrderIdByXBridge(
        uint256 srcToken,
        uint256 amount,
        uint256 minReturn,
        // solhint-disable-next-line no-unused-vars
        bytes32[] calldata pools
    ) external payable onlyPriorityAddress returns (uint256 returnAmount) {
        emit SwapOrderId((srcToken & _ORDER_ID_MASK) >> 160);
        (address payer, address receiver) = IXBridge(msg.sender)
            .payerReceiver();
        require(receiver != address(0), "not address(0)");
        return _unxswapTo(srcToken, amount, minReturn, payer, receiver, pools);
    }
    /// @notice Executes a token swap using the Uniswap V3 protocol through the XBridge, specifically catering to priority addresses.
    /// @param receiver The address that will receive the swap funds.
    /// @param amount The amount of the source token to be swapped.
    /// @param minReturn The minimum acceptable amount of tokens to be received from the swap. This parameter ensures the swap does not proceed if the return is below the specified threshold, guarding against excessive slippage.
    /// @param pools An array of pool identifiers used to define the swap route in the Uniswap V3 pools.
    /// @return returnAmount The amount of tokens received from the swap.
    /// @dev This function is exclusively accessible to priority addresses and is responsible for executing swaps on Uniswap V3 through the XBridge interface. It ensures that the swap meets the criteria set by the parameters and utilizes the _uniswapV3Swap internal function to perform the actual swap.

    function uniswapV3SwapToByXBridge(
        uint256 receiver,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external payable onlyPriorityAddress returns (uint256 returnAmount) {
        emit SwapOrderId((receiver & _ORDER_ID_MASK) >> 160);
        (address payer, address receiver_) = IXBridge(msg.sender)
            .payerReceiver();
        require(receiver_ != address(0), "not address(0)");
        return
            _uniswapV3SwapTo(
                payer,
                uint160(receiver_),
                amount,
                minReturn,
                pools
            );
    }
    /// @notice Executes a smart swap based on the given order ID, supporting complex multi-path swaps.
    /// @param orderId The unique identifier for the swap order, facilitating tracking and reference.
    /// @param baseRequest Struct containing the base parameters for the swap, including the source and destination tokens, amount, minimum return, and deadline.
    /// @param batchesAmount An array specifying the amount to be swapped in each batch, allowing for split operations.
    /// @param batches An array of RouterPath structs defining the routing paths for each batch, enabling swaps through multiple protocols or liquidity pools.
    /// @param extraData Additional data required for some swaps, accommodating special instructions or parameters necessary for executing the swap.
    /// @return returnAmount The total amount of destination tokens received from executing the swap.
    /// @dev This function orchestrates a swap operation that may involve multiple steps, routes, or protocols based on the provided parameters.
    /// It's designed to ensure flexibility and efficiency in finding the best swap paths.

    function smartSwapByOrderId(
        uint256 orderId,
        BaseRequest calldata baseRequest,
        uint256[] calldata batchesAmount,
        RouterPath[][] calldata batches,
        PMMLib.PMMSwapRequest[] calldata extraData
    )
        external
        payable
        isExpired(baseRequest.deadLine)
        nonReentrant
        returns (uint256 returnAmount)
    {
        emit SwapOrderId(orderId);
        return
            _smartSwapTo(
                msg.sender,
                msg.sender,
                baseRequest,
                batchesAmount,
                batches
            );
    }
    /// @notice Executes a token swap using the Unxswap protocol based on a specified order ID.
    /// @param srcToken The source token involved in the swap.
    /// @param amount The amount of the source token to be swapped.
    /// @param minReturn The minimum amount of tokens expected to be received to ensure the swap does not proceed under unfavorable conditions.
    /// @param pools An array of pool identifiers specifying the pools to use for the swap, allowing for optimized routing.
    /// @return returnAmount The amount of destination tokens received from the swap.
    /// @dev This function allows users to perform token swaps based on predefined orders, leveraging the Unxswap protocol's liquidity pools. It ensures that the swap meets the user's specified minimum return criteria, enhancing trade efficiency and security.

    function unxswapByOrderId(
        uint256 srcToken,
        uint256 amount,
        uint256 minReturn,
        // solhint-disable-next-line no-unused-vars
        bytes32[] calldata pools
    ) external payable returns (uint256 returnAmount) {
        emit SwapOrderId((srcToken & _ORDER_ID_MASK) >> 160);
        return
            _unxswapTo(
                srcToken,
                amount,
                minReturn,
                msg.sender,
                msg.sender,
                pools
            );
    }
    /// @notice Executes a swap tailored for investment purposes, adjusting swap amounts based on the contract's balance.
    /// @param baseRequest Struct containing essential swap parameters like source and destination tokens, amounts, and deadline.
    /// @param batchesAmount Array indicating how much of the source token to swap in each batch, facilitating diversified investments.
    /// @param batches Detailed routing information for executing the swap across different paths or protocols.
    /// @param extraData Additional data for swaps, supporting protocol-specific requirements.
    /// @param to The address where the swapped tokens will be sent, typically an investment contract or pool.
    /// @return returnAmount The total amount of destination tokens received, ready for investment.
    /// @dev This function is designed for scenarios where investments are made in batches or through complex paths to optimize returns. Adjustments are made based on the contract's current token balance to ensure precise allocation.

    function smartSwapByInvest(
        BaseRequest calldata baseRequest,
        uint256[] calldata batchesAmount,
        RouterPath[][] calldata batches,
        PMMLib.PMMSwapRequest[] calldata extraData,
        address to
    )
        external
        payable
        isExpired(baseRequest.deadLine)
        nonReentrant
        returns (uint256 returnAmount)
    {
        address fromToken = _bytes32ToAddress(baseRequest.fromToken);
        require(fromToken != _ETH, "Invalid source token");
        uint256 amount = IERC20(fromToken).balanceOf(address(this));
        BaseRequest memory newBaseRequest = BaseRequest({
            fromToken: baseRequest.fromToken,
            toToken: baseRequest.toToken,
            fromTokenAmount: amount,
            minReturnAmount: baseRequest.minReturnAmount,
            deadLine: baseRequest.deadLine
        });
        uint256[] memory newBatchesAmount = new uint256[](batchesAmount.length);
        for (uint256 i = 0; i < batchesAmount.length; ) {
            newBatchesAmount[i] =
                (batchesAmount[i] * amount) /
                baseRequest.fromTokenAmount;
            unchecked {
                ++i;
            }
        }
        returnAmount = _smartSwapInternal(
            newBaseRequest,
            newBatchesAmount,
            batches,
            address(this),
            to
        );
    }

    /// @notice Executes a Uniswap V3 swap after obtaining a permit, allowing the approval of token spending and swap execution in a single transaction.
    /// @param receiver The address that will receive the funds from the swap.
    /// @param srcToken The token that will be swapped.
    /// @param amount The amount of source tokens to be swapped.
    /// @param minReturn The minimum acceptable amount of tokens to receive from the swap, guarding against slippage.
    /// @param pools An array of Uniswap V3 pool identifiers, specifying the pools to be used for the swap.
    /// @param permit A signed permit message that allows the router to spend the source tokens without requiring a separate `approve` transaction.
    /// @return returnAmount The amount of tokens received from the swap.
    /// @dev This function first utilizes the `_permit` function to approve token spending, then proceeds to execute the swap through `_uniswapV3Swap`. It's designed to streamline transactions by combining token approval and swap execution into a single operation.
    function uniswapV3SwapToWithPermit(
        uint256 receiver,
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools,
        bytes calldata permit
    ) external returns (uint256 returnAmount) {
        emit SwapOrderId((receiver & _ORDER_ID_MASK) >> 160);
        _permit(address(srcToken), permit);
        return _uniswapV3SwapTo(msg.sender, receiver, amount, minReturn, pools);
    }

    /// @notice Executes a swap using the Uniswap V3 protocol.
    /// @param receiver The address that will receive the swap funds.
    /// @param amount The amount of the source token to be swapped.
    /// @param minReturn The minimum acceptable amount of tokens to receive from the swap, guarding against excessive slippage.
    /// @param pools An array of pool identifiers used to define the swap route within Uniswap V3.
    /// @return returnAmount The amount of tokens received after the completion of the swap.
    /// @dev This function wraps and unwraps ETH as required, ensuring the transaction only accepts non-zero `msg.value` for ETH swaps. It invokes `_uniswapV3Swap` to execute the actual swap and handles commission post-swap.
    function uniswapV3SwapTo(
        uint256 receiver,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external payable returns (uint256 returnAmount) {
        emit SwapOrderId((receiver & _ORDER_ID_MASK) >> 160);
        return _uniswapV3SwapTo(msg.sender, receiver, amount, minReturn, pools);
    }

    function _uniswapV3SwapTo(
        address payer,
        uint256 receiver,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) internal returns (uint256 returnAmount) {
        CommissionInfo memory commissionInfo = _getCommissionInfo();

        (
            address middleReceiver,
            uint256 balanceBefore
        ) = _doCommissionFromToken(
                commissionInfo,
                address(uint160(receiver)),
                amount
            );

        (uint256 swappedAmount, ) = _uniswapV3Swap(
            payer,
            payable(middleReceiver),
            amount,
            minReturn,
            pools
        );

        uint256 commissionAmount = _doCommissionToToken(
            commissionInfo,
            address(uint160(receiver)),
            balanceBefore
        );

        return swappedAmount - commissionAmount;
    }

    /// @notice Executes a smart swap directly to a specified receiver address.
    /// @param orderId Unique identifier for the swap order, facilitating tracking.
    /// @param receiver Address to receive the output tokens from the swap.
    /// @param baseRequest Contains essential parameters for the swap such as source and destination tokens, amounts, and deadline.
    /// @param batchesAmount Array indicating amounts for each batch in the swap, allowing for split operations.
    /// @param batches Detailed routing information for executing the swap across different paths or protocols.
    /// @param extraData Additional data required for certain swaps, accommodating specific protocol needs.
    /// @return returnAmount The total amount of destination tokens received from the swap.
    /// @dev This function enables users to perform token swaps with complex routing directly to a specified address,
    /// optimizing for best returns and accommodating specific trading strategies.

    function smartSwapTo(
        uint256 orderId,
        address receiver,
        BaseRequest calldata baseRequest,
        uint256[] calldata batchesAmount,
        RouterPath[][] calldata batches,
        PMMLib.PMMSwapRequest[] calldata extraData
    )
        external
        payable
        isExpired(baseRequest.deadLine)
        nonReentrant
        returns (uint256 returnAmount)
    {
        emit SwapOrderId(orderId);
        return
            _smartSwapTo(
                msg.sender,
                receiver,
                baseRequest,
                batchesAmount,
                batches
            );
    }

    function _smartSwapTo(
        address payer,
        address receiver,
        BaseRequest calldata baseRequest,
        uint256[] calldata batchesAmount,
        RouterPath[][] calldata batches
    ) internal returns (uint256) {
        require(receiver != address(0), "not addr(0)");
        CommissionInfo memory commissionInfo = _getCommissionInfo();

        (
            address middleReceiver,
            uint256 balanceBefore
        ) = _doCommissionFromToken(
                commissionInfo,
                receiver,
                baseRequest.fromTokenAmount
            );
        address _payer = payer; // avoid stack too deep
        uint256 swappedAmount = _smartSwapInternal(
            baseRequest,
            batchesAmount,
            batches,
            _payer,
            middleReceiver
        );

        uint256 commissionAmount = _doCommissionToToken(
            commissionInfo,
            receiver,
            balanceBefore
        );

        return swappedAmount - commissionAmount;
    }
    /// @notice Executes a token swap using the Unxswap protocol, sending the output directly to a specified receiver.
    /// @param srcToken The source token to be swapped.
    /// @param amount The amount of the source token to be swapped.
    /// @param minReturn The minimum amount of destination tokens expected from the swap, ensuring the trade does not proceed under unfavorable conditions.
    /// @param receiver The address where the swapped tokens will be sent.
    /// @param pools An array of pool identifiers to specify the swap route, optimizing for best rates.
    /// @return returnAmount The total amount of destination tokens received from the swap.
    /// @dev This function facilitates direct swaps using Unxswap, allowing users to specify custom swap routes and ensuring that the output is sent to a predetermined address. It is designed for scenarios where the user wants to directly receive the tokens in their wallet or another contract.

    function unxswapTo(
        uint256 srcToken,
        uint256 amount,
        uint256 minReturn,
        address receiver,
        // solhint-disable-next-line no-unused-vars
        bytes32[] calldata pools
    ) external payable returns (uint256 returnAmount) {
        emit SwapOrderId((srcToken & _ORDER_ID_MASK) >> 160);
        return
            _unxswapTo(
                srcToken,
                amount,
                minReturn,
                msg.sender,
                receiver,
                pools
            );
    }

    function _unxswapTo(
        uint256 srcToken,
        uint256 amount,
        uint256 minReturn,
        address payer,
        address receiver,
        // solhint-disable-next-line no-unused-vars
        bytes32[] calldata pools
    ) internal returns (uint256 returnAmount) {
        require(receiver != address(0), "not addr(0)");
        CommissionInfo memory commissionInfo = _getCommissionInfo();

        (
            address middleReceiver,
            uint256 balanceBefore
        ) = _doCommissionFromToken(commissionInfo, receiver, amount);

        uint256 swappedAmount = _unxswapInternal(
            IERC20(address(uint160(srcToken & _ADDRESS_MASK))),
            amount,
            minReturn,
            pools,
            payer,
            middleReceiver
        );

        uint256 commissionAmount = _doCommissionToToken(
            commissionInfo,
            receiver,
            balanceBefore
        );

        return swappedAmount - commissionAmount;
    }

    /// @notice Allows the contract owner to withdraw any tokens or native currency considered as "dust".
    /// @param token The address of the token to withdraw, or the zero address for native currency.
    /// @param to The address where the dust tokens or native currency should be sent.
    /// @param amount The amount of the token or native currency to withdraw.
    /// @dev This function is intended for recovering small amounts of tokens or native currency
    /// left in the contract, which might not be recoverable through normal operations.
    /// It can only be executed by the contract owner to ensure control over the contract's assets.
    function withdrawDust(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        if (token == _ETH) {
            (bool success, bytes memory data) = payable(to).call{value: amount}(
                ""
            );
            require(success, string(data));
        } else {
            SafeERC20.safeTransfer(IERC20(token), to, amount);
        }
    }
}
