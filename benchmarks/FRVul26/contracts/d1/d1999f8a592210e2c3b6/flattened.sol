// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

// File: src/interfaces/ISystemComponent.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/// @notice Stores a reference to the registry for this system
interface ISystemComponent {
    /// @notice The system instance this contract is tied to
    function getSystemRegistry() external view returns (address registry);
}

// File: src/utils/Errors.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;




// solhint-disable max-line-length
library Errors {
    using Address for address;
    ///////////////////////////////////////////////////////////////////
    //                       Set errors
    ///////////////////////////////////////////////////////////////////

    error AccessDenied();
    error ZeroAddress(string paramName);
    error ZeroAmount();
    error InsufficientBalance(address token);
    error AssetNotAllowed(address token);
    error NotImplemented();
    error InvalidAddress(address addr);
    error InvalidParam(string paramName);
    error InvalidParams();
    error UnsafePrice(address token, uint256 spotPrice, uint256 safePrice);
    error AlreadySet(string param);
    error AlreadyRegistered(address param);
    error SlippageExceeded(uint256 expected, uint256 actual);
    error ArrayLengthMismatch(uint256 length1, uint256 length2, string details);

    error ItemNotFound();
    error ItemExists();
    error MissingRole(bytes32 role, address user);
    error RegistryItemMissing(string item);
    error NotRegistered();
    // Used to check storage slot is empty before setting.
    error MustBeZero();
    // Used to check storage slot set before deleting.
    error MustBeSet();

    error ApprovalFailed(address token);
    error FlashLoanFailed(address token, uint256 amount);

    error SystemMismatch(address source1, address source2);

    error InvalidToken(address token);
    error UnreachableError();

    error InvalidSigner(address signer);

    error InvalidChainId(uint256 chainId);

    error SenderMismatch(address recipient, address sender);

    error UnsupportedMessage(bytes32 messageType, bytes message);

    error NotSupported();

    error InvalidConfiguration();

    error InvalidDataReturned();

    function verifyNotZero(address addr, string memory paramName) internal pure {
        if (addr == address(0)) {
            revert ZeroAddress(paramName);
        }
    }

    function verifyNotZero(bytes32 key, string memory paramName) internal pure {
        if (key == bytes32(0)) {
            revert InvalidParam(paramName);
        }
    }

    function verifyNotEmpty(string memory val, string memory paramName) internal pure {
        if (bytes(val).length == 0) {
            revert InvalidParam(paramName);
        }
    }

    function verifyNotZero(uint256 num, string memory paramName) internal pure {
        if (num == 0) {
            revert InvalidParam(paramName);
        }
    }

    function verifySystemsMatch(address component1, address component2) internal view {
        address registry1 =
            abi.decode(component1.functionStaticCall(abi.encodeCall(ISystemComponent.getSystemRegistry, ())), (address));
        address registry2 =
            abi.decode(component2.functionStaticCall(abi.encodeCall(ISystemComponent.getSystemRegistry, ())), (address));

        if (registry1 != registry2) {
            revert SystemMismatch(component1, component2);
        }
    }

    function verifyArrayLengths(uint256 length1, uint256 length2, string memory details) internal pure {
        if (length1 != length2) {
            revert ArrayLengthMismatch(length1, length2, details);
        }
    }
}

// File: src/interfaces/utils/ICurveResolver.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;

interface ICurveResolver {
    /// @notice Resolve details of a Curve pool regardless of type or version
    /// @dev This resolves tokens without unwrapping to underlying in the case of meta pools.
    /// @param poolAddress pool address to lookup
    /// @return tokens tokens that make up the pool
    /// @return numTokens the number of tokens. tokens are not unwrapped.
    /// @return isStableSwap is this a StableSwap pool. false = CryptoSwap
    function resolve(address poolAddress)
        external
        view
        returns (address[8] memory tokens, uint256 numTokens, bool isStableSwap);

    /// @notice Resolve details of a Curve pool regardless of type or version
    /// @dev This resolves tokens without unwrapping to underlying in the case of meta pools.
    /// @dev Use the isStableSwap value to differentiate between StableSwap (V1) and CryptoSwap (V2) pools.
    /// @param poolAddress pool address to lookup
    /// @return tokens tokens that make up the pool
    /// @return numTokens the number of tokens. tokens are not unwrapped
    /// @return lpToken lp token of the pool
    /// @return isStableSwap is this a StableSwap pool. false = CryptoSwap
    function resolveWithLpToken(address poolAddress)
        external
        view
        returns (address[8] memory tokens, uint256 numTokens, address lpToken, bool isStableSwap);

    /// @notice Get the lp token of a Curve pool
    /// @param poolAddress pool address to lookup
    function getLpToken(address poolAddress) external view returns (address);

    /// @notice Get the reserves of a Curve pools' tokens
    /// @dev Actual balances length might differ from 8 and should be verified by the caller
    /// @param poolAddress pool address to lookup
    /// @return balances reserves of the pool tokens
    function getReservesInfo(address poolAddress) external view returns (uint256[8] memory balances);
}

// File: src/interfaces/external/curve/ICurveMetaRegistry.sol

pragma solidity 0.8.17;

// solhint-disable func-name-mixedcase, var-name-mixedcase
// slither-disable-start naming-convention
interface ICurveMetaRegistry {
    /// @notice Get the coins within a pool
    /// @dev For metapools, these are the wrapped coin addresses
    /// @param _pool Pool address
    /// @return List of coin addresses
    function get_coins(address _pool) external view returns (address[8] memory);

    /// @notice Get the coins within a pool
    /// @dev For metapools, these are the wrapped coin addresses
    /// @param _pool Pool address
    /// @param _handler_id id of registry handler
    /// @return List of coin addresses
    function get_coins(address _pool, uint256 _handler_id) external view returns (address[8] memory);

    /// @notice Get the number of coins in a pool
    /// @dev For metapools, it is tokens + wrapping/lending token (no underlying)
    /// @param _pool Pool address
    /// @return Number of coins
    function get_n_coins(address _pool) external view returns (uint256);

    /// @notice Get the number of coins in a pool
    /// @dev For metapools, it is tokens + wrapping/lending token (no underlying)
    /// @param _pool Pool address
    /// @param _handler_id Id of the registry to check
    /// @return Number of coins
    function get_n_coins(address _pool, uint256 _handler_id) external view returns (uint256);

    /// @notice Get the address of the LP token of a pool
    /// @param _pool Pool address
    /// @return Address of the LP token
    function get_lp_token(address _pool) external view returns (address);

    /// @notice Get the address of the LP token of a pool
    /// @param _pool Pool address
    /// @param _handler_id id of registry handler
    /// @return Address of the LP token
    function get_lp_token(address _pool, uint256 _handler_id) external view returns (address);

    /// @notice Get the balances of the tokens in the pool
    /// @dev For metapools, these are the wrapped coin addresses
    /// @param _pool Pool address
    /// @return List of balances
    function get_balances(address _pool) external view returns (uint256[8] memory);
}
// slither-disable-end naming-convention

// File: src/interfaces/external/curve/IPool.sol

pragma solidity 0.8.17;

//slither-disable-next-line name-reused
interface IPool {
    function coins(uint256 i) external view returns (address);

    function balances(uint256 i) external view returns (uint256);

    // These method used for cases when Pool is a LP token at the same time
    function balanceOf(address account) external returns (uint256);

    // These method used for cases when Pool is a LP token at the same time
    function totalSupply() external returns (uint256);

    // solhint-disable func-name-mixedcase
    function lp_token() external returns (address);

    function token() external returns (address);

    function gamma() external;
}

// File: src/utils/CurveResolverMainnet.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;






contract CurveResolverMainnet is ICurveResolver {
    ICurveMetaRegistry public immutable curveMetaRegistry;

    error CouldNotResolve(address poolAddress);

    constructor(ICurveMetaRegistry _curveMetaRegistry) {
        Errors.verifyNotZero(address(_curveMetaRegistry), "_curveMetaRegistry");

        curveMetaRegistry = _curveMetaRegistry;
    }

    /// @inheritdoc ICurveResolver
    function resolve(address poolAddress)
        public
        view
        returns (address[8] memory tokens, uint256 numTokens, bool isStableSwap)
    {
        Errors.verifyNotZero(poolAddress, "poolAddress");

        // If a pool is not showing up in the registry, this will revert
        try curveMetaRegistry.get_coins(poolAddress) returns (address[8] memory retTokens) {
            tokens = retTokens;
            numTokens = curveMetaRegistry.get_n_coins(poolAddress);
        } catch {
            // We have to try other means to get the information
            do {
                //slither-disable-start low-level-calls,missing-zero-check
                (bool success, bytes memory retData) = poolAddress.staticcall(abi.encodeCall(IPool.coins, (numTokens)));
                //slither-disable-end low-level-calls,missing-zero-check
                if (!success) {
                    break;
                }
                if (retData.length > 0) {
                    tokens[numTokens] = abi.decode(retData, (address));
                }
                if (tokens[numTokens] == address(0)) {
                    break;
                }
                unchecked {
                    ++numTokens;
                }
            } while (true);
        }

        if (numTokens == 0) {
            revert CouldNotResolve(poolAddress);
        }

        isStableSwap = _isStableSwap(poolAddress);
    }

    /// @inheritdoc ICurveResolver
    function resolveWithLpToken(address poolAddress)
        external
        view
        returns (address[8] memory tokens, uint256 numTokens, address lpToken, bool isStableSwap)
    {
        (tokens, numTokens, isStableSwap) = resolve(poolAddress);
        lpToken = getLpToken(poolAddress);
    }

    /// @inheritdoc ICurveResolver
    function getLpToken(address poolAddress) public view returns (address) {
        // If a pool is not showing up in the registry, this will revert
        try curveMetaRegistry.get_lp_token(poolAddress) returns (address lpToken) {
            return lpToken;
        } catch {
            //slither-disable-start low-level-calls,missing-zero-check
            // We have to try other means to get the information
            (bool success, bytes memory retData) = poolAddress.staticcall(abi.encodeCall(IPool.totalSupply, ()));
            if (success && retData.length > 0) {
                // If the pool address has a totalSupply() call then pool is lpToken
                return poolAddress;
            }

            (success, retData) = poolAddress.staticcall(abi.encodeCall(IPool.lp_token, ()));
            if (success && retData.length > 0) {
                return abi.decode(retData, (address));
            }

            (success, retData) = poolAddress.staticcall(abi.encodeCall(IPool.token, ()));
            if (success && retData.length > 0) {
                return abi.decode(retData, (address));
            }
            //slither-disable-end low-level-calls,missing-zero-check
        }

        revert CouldNotResolve(poolAddress);
    }

    /// @inheritdoc ICurveResolver
    function getReservesInfo(address poolAddress) external view returns (uint256[8] memory ret) {
        Errors.verifyNotZero(poolAddress, "poolAddress");

        // If a pool is not showing up in the registry, this will revert
        try curveMetaRegistry.get_balances(poolAddress) returns (uint256[8] memory retBalances) {
            return retBalances;
        } catch {
            // We have to try other means to get the information
            uint256 i = 0;
            do {
                // No newer pools use the balances(int256) interface and we won't be targeting the older ones
                //slither-disable-start low-level-calls,missing-zero-check
                (bool success, bytes memory retData) = poolAddress.staticcall(abi.encodeCall(IPool.balances, i));
                //slither-disable-end low-level-calls,missing-zero-check
                if (success && retData.length > 0) {
                    ret[i] = abi.decode(retData, (uint256));
                } else {
                    break;
                }

                unchecked {
                    ++i;
                }
            } while (i < 8);

            if (i == 0) {
                revert CouldNotResolve(poolAddress);
            }
        }
    }

    function _isStableSwap(address pool) private view returns (bool) {
        // Using the presence of a gamma() fn as an indicator of pool type
        // Zero check for the poolAddress is above
        // slither-disable-start low-level-calls,missing-zero-check,unchecked-lowlevel
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = pool.staticcall(abi.encodeCall(IPool.gamma, ()));
        // slither-disable-end low-level-calls,missing-zero-check,unchecked-lowlevel

        return !success;
    }
}
