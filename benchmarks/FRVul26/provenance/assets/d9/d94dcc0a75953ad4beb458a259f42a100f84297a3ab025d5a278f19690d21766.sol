// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

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

// File: lib/openzeppelin-contracts/contracts/token/ERC20/extensions/draft-IERC20Permit.sol

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

// File: lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/interfaces/draft-IERC1822Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
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

// File: lib/openzeppelin-contracts-upgradeable/contracts/proxy/beacon/IBeaconUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/utils/AddressUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

// File: lib/openzeppelin-contracts-upgradeable/contracts/utils/StorageSlotUpgradeable.sol

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
library StorageSlotUpgradeable {
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

// File: lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
        if (_initialized < type(uint8).max) {
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

// File: lib/openzeppelin-contracts-upgradeable/contracts/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol

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
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
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
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            _functionDelegateCall(newImplementation, data);
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
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
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
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
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
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;





/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: src/core/interfaces/IeETH.sol

pragma solidity ^0.8.13;

interface IeETH {

    struct PermitInput {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    } 
    
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalShares() external view returns (uint256);

    function shares(address _user) external view returns (uint256);
    function balanceOf(address _user) external view returns (uint256);

    function initialize() external;
    function mintShares(address _user, uint256 _share) external;
    function burnShares(address _user, uint256 _share) external;
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function increaseAllowance(address _spender, uint256 _increaseAmount) external returns (bool);
    function decreaseAllowance(address _spender, uint256 _decreaseAmount) external returns (bool);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// File: src/core/interfaces/ILiquidityPool.sol

pragma solidity ^0.8.13;




interface ILiquidityPool {

    struct PermitInput {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct FundStatistics {
        uint32 numberOfValidators;
        uint32 targetWeight;
    }

    // Necessary to preserve "statelessness" of dutyForWeek().
    // Handles case where new users join/leave holder list during an active slot
    struct HoldersUpdate {
        uint32 timestamp;
        uint32 startOfSlotNumOwners;
    }

    struct BnftHolder {
        address holder;
    }

    struct ValidatorSpawner {
        bool registered;
    }

    struct ConstructorAddresses {
        address stakingManager;
        address nodesManager;
        address eETH;
        address withdrawRequestNFT;
        address liquifier;
        address etherFiRedemptionManager;
        address roleRegistry;
        address priorityWithdrawalQueue;
        address blacklister;
        address etherFiAdminContract;
        address membershipManager;
    }

    enum SourceOfFunds {
        UNDEFINED,
        EETH,
        ETHER_FAN,
        DELEGATED_STAKING
    }

    function totalValueOutOfLp() external view returns (uint128);
    function totalValueInLp() external view returns (uint128);
    function validatorSizeWei() external view returns (uint256);
    function getTotalEtherClaimOf(address _user) external view returns (uint256);
    function getTotalPooledEther() external view returns (uint256);
    function sharesForAmount(uint256 _amount) external view returns (uint256);
    function sharesForWithdrawalAmount(uint256 _amount) external view returns (uint256);
    function amountForShare(uint256 _share) external view returns (uint256);
    function amountPerShareCeil() external view returns (uint256);
    function eETH() external view returns (IeETH);
    function escrowMigrationCompleted() external view returns (bool);

    function deposit() external payable returns (uint256);
    function deposit(address _referral) external payable returns (uint256);
    function deposit(address _user, address _referral) external payable returns (uint256);
    function depositToRecipient(address _recipient, uint256 _amount, address _referral) external returns (uint256);
    function withdraw(address _recipient, uint256 _amount) external returns (uint256);
    function withdraw(uint256 _amount, uint256 _share) external;
    function burnEEthSharesForNonETHWithdrawal(uint256 _amountSharesToBurn, uint256 _withdrawalValueInETH) external;
    function requestWithdraw(address recipient, uint256 amount) external returns (uint256);
    function requestWithdrawWithPermit(address _owner, uint256 _amount, PermitInput calldata _permit) external returns (uint256);
    function requestMembershipNFTWithdraw(address recipient, uint256 amount, uint256 fee) external returns (uint256);

    function batchRegister(IStakingManager.DepositData[] calldata _depositData, uint256[] calldata _bidIds, address _etherFiNode) external;
    function batchCreateBeaconValidators(IStakingManager.DepositData[] calldata _depositData, uint256[] calldata _bidIds, address _etherFiNode) external;
    function confirmAndFundBeaconValidators(IStakingManager.DepositData[] calldata depositData, uint256 validatorSizeWei) external;

    function registerValidatorSpawner(address _user) external;
    function unregisterValidatorSpawner(address _user) external;

    function rebase(int128 _accruedRewards, uint128 _protocolFees) external;
    function addEthAmountLockedForWithdrawal(uint128 _amount) external;
    function transferLockedEthForPriority(uint128 _amount) external;

    function burnEEthShares(uint256 shares) external;
    function setValidatorSizeWei(uint256 _size) external;
}

// File: src/staking/interfaces/IStakingManager.sol

pragma solidity ^0.8.13;



interface IStakingManager {

    struct DepositData {
        bytes publicKey;
        bytes signature;
        bytes32 depositDataRoot;
        string ipfsHashForEncryptedValidatorKey;
    }

    // Possible values for validator creation status
    enum ValidatorCreationStatus {
        NOT_REGISTERED,
        REGISTERED,
        CONFIRMED,
        INVALIDATED
    }

    function INITIAL_DEPOSIT_AMOUNT() external view returns (uint256);
    function MIN_VALIDATOR_SIZE_WEI() external view returns (uint256);
    function MAX_VALIDATOR_SIZE_WEI() external view returns (uint256);

    // deposit flow
    function registerBeaconValidators(DepositData[] calldata depositData, uint256[] calldata bidIds, address etherFiNode) external;
    function createBeaconValidators(DepositData[] calldata depositData, uint256[] calldata bidIds, address etherFiNode) external payable;
    function invalidateRegisteredBeaconValidator(DepositData calldata depositData, uint256 bidId, address etherFiNode) external;
    function confirmAndFundBeaconValidators(DepositData[] calldata depositData, uint256 validatorSizeWei) external payable;
    function calculateValidatorPubkeyHash(bytes memory pubkey) external pure returns (bytes32);
    function generateDepositDataRoot(bytes memory pubkey, bytes memory signature, bytes memory withdrawalCredentials, uint256 amount) external pure returns (bytes32);

    // EtherFiNode Beacon Proxy
    function upgradeEtherFiNode(address _newImplementation) external;
    function getEtherFiNodeBeacon() external view returns (address);
    function deployedEtherFiNodes(address etherFiNode) external view returns (bool);

    // prevent storage shift on upgrade
    struct LegacyStakingManagerState {
        uint256[14] legacyState;
        /*
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | stakeAmount            | uint128                                               | 301  | 16     | 16    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | implementationContract | address                                               | 302  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | liquidityPoolContract  | address                                               | 303  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | isFullStakeEnabled     | bool                                                  | 303  | 20     | 1     | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | merkleRoot             | bytes32                                               | 304  | 0      | 32    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | TNFTInterfaceInstance  | contract ITNFT                                        | 305  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | BNFTInterfaceInstance  | contract IBNFT                                        | 306  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | auctionManager         | contract IAuctionManager                              | 307  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | depositContractEth2    | contract IDepositContract                             | 308  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | nodesManager           | contract IEtherFiNodesManager                         | 309  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | upgradableBeacon       | contract UpgradeableBeacon                            | 310  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | bidIdToStakerInfo      | mapping(uint256 => struct IStakingManager.StakerInfo) | 311  | 0      | 32    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | DEPRECATED_admin       | address                                               | 312  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | nodeOperatorManager    | address                                               | 313  | 0      | 20    | src/StakingManager.sol:StakingManager |
        |------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------|
        | admins                 | mapping(address => bool)                              | 314  | 0      | 32    | src/StakingManager.sol:StakingManager |
        ╰------------------------+-------------------------------------------------------+------+--------+-------+---------------------------------------╯
        */
    }

    //---------------------------------------------------------------------------
    //-----------------------------  Events  -----------------------------------
    //---------------------------------------------------------------------------

    event validatorCreated(bytes32 indexed pubkeyHash, address indexed etherFiNode, bytes pubkey);
    event validatorConfirmed(bytes32 indexed pubkeyHash, address indexed bnftRecipient, address indexed tnftRecipient, bytes pubkey);
    event linkLegacyValidatorId(bytes32 indexed pubkeyHash, uint256 indexed legacyId);
    event EtherFiNodeDeployed(address indexed etheFiNode);

    // legacy event still being emitted in its original form to play nice with existing external tooling
    event ValidatorRegistered(address indexed operator, address indexed bNftOwner, address indexed tNftOwner, uint256 validatorId, bytes validatorPubKey, string ipfsHashForEncryptedValidatorKey);

    event ValidatorCreationStatusUpdated(DepositData depositData, uint256 bidId, address etherFiNode, bytes32 hashedAllData, ValidatorCreationStatus indexed status);

    //--------------------------------------------------------------------------
    //-----------------------------  Errors  -----------------------------------
    //--------------------------------------------------------------------------

    error InvalidCaller();
    error UnlinkedPubkey();
    error IncorrectBeaconRoot();
    error InvalidPubKeyLength();
    error InvalidDepositData();
    error InactiveBid();
    error InvalidEtherFiNode();
    error InvalidValidatorSize();
    error InvalidUpgrade();
    error InvalidValidatorCreationStatus();

}

// File: src/withdrawals/interfaces/IWithdrawRequestNFT.sol

pragma solidity ^0.8.13;

interface IWithdrawRequestNFT {
    struct WithdrawRequest {
        uint96  amountOfEEth;
        uint96  shareOfEEth;
        bool    isValid;
        uint32  feeGwei;
    }

    function initialize() external;
    function requestWithdraw(uint96 amountOfEEth, uint96 shareOfEEth, address requester) external returns (uint256);
    function claimWithdraw(uint256 requestId) external;

    function getRequest(uint256 requestId) external view returns (WithdrawRequest memory);
    function isFinalized(uint256 requestId) external view returns (bool);
    function ethAmountLockedForWithdrawal() external view returns (uint128);
    function nextRequestId() external view returns (uint32);
    function lastFinalizedRequestId() external view returns (uint32);

    function invalidateRequest(uint256 requestId) external;
    function finalizeRequests(uint256 upperBound) external;
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/utils/math/SafeCastUpgradeable.sol

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
library SafeCastUpgradeable {
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

// File: lib/eigenlayer-libraries/SlashingLib.sol

pragma solidity ^0.8.27;




/// @dev All scaling factors have `1e18` as an initial/default value. This value is represented
/// by the constant `WAD`, which is used to preserve precision with uint256 math.
///
/// When applying scaling factors, they are typically multiplied/divided by `WAD`, allowing this
/// constant to act as a "1" in mathematical formulae.
uint64 constant WAD = 1e18;

/*
 * There are 2 types of shares:
 *      1. deposit shares
 *          - These can be converted to an amount of tokens given a strategy
 *              - by calling `sharesToUnderlying` on the strategy address (they're already tokens 
 *              in the case of EigenPods)
 *          - These live in the storage of the EigenPodManager and individual StrategyManager strategies 
 *      2. withdrawable shares
 *          - For a staker, this is the amount of shares that they can withdraw
 *          - For an operator, the shares delegated to them are equal to the sum of their stakers'
 *            withdrawable shares
 *
 * Along with a slashing factor, the DepositScalingFactor is used to convert between the two share types.
 */
struct DepositScalingFactor {
    uint256 _scalingFactor;
}

using SlashingLib for DepositScalingFactor global;

library SlashingLib {
    using Math for uint256;
    using SlashingLib for uint256;
    using SafeCastUpgradeable for uint256;

    // WAD MATH

    function mulWad(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mulDiv(y, WAD);
    }

    function divWad(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mulDiv(WAD, y);
    }

    /**
     * @notice Used explicitly for calculating slashed magnitude, we want to ensure even in the
     * situation where an operator is slashed several times and precision has been lost over time,
     * an incoming slashing request isn't rounded down to 0 and an operator is able to avoid slashing penalties.
     */
    function mulWadRoundUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mulDiv(y, WAD, Math.Rounding.Up);
    }

    // GETTERS

    function scalingFactor(
        DepositScalingFactor memory dsf
    ) internal pure returns (uint256) {
        return dsf._scalingFactor == 0 ? WAD : dsf._scalingFactor;
    }

    function scaleForQueueWithdrawal(
        DepositScalingFactor memory dsf,
        uint256 depositSharesToWithdraw
    ) internal pure returns (uint256) {
        return depositSharesToWithdraw.mulWad(dsf.scalingFactor());
    }

    function scaleForCompleteWithdrawal(uint256 scaledShares, uint256 slashingFactor) internal pure returns (uint256) {
        return scaledShares.mulWad(slashingFactor);
    }

    /**
     * @notice Scales shares according to the difference in an operator's magnitude before and
     * after being slashed. This is used to calculate the number of slashable shares in the
     * withdrawal queue.
     * NOTE: max magnitude is guaranteed to only ever decrease.
     */
    function scaleForBurning(
        uint256 scaledShares,
        uint64 prevMaxMagnitude,
        uint64 newMaxMagnitude
    ) internal pure returns (uint256) {
        return scaledShares.mulWad(prevMaxMagnitude - newMaxMagnitude);
    }

    function update(
        DepositScalingFactor storage dsf,
        uint256 prevDepositShares,
        uint256 addedShares,
        uint256 slashingFactor
    ) internal {
        if (prevDepositShares == 0) {
            // If this is the staker's first deposit or they are delegating to an operator,
            // the slashing factor is inverted and applied to the existing DSF. This has the
            // effect of "forgiving" prior slashing for any subsequent deposits.
            dsf._scalingFactor = dsf.scalingFactor().divWad(slashingFactor);
            return;
        }

        /**
         * Base Equations:
         * (1) newShares = currentShares + addedShares
         * (2) newDepositShares = prevDepositShares + addedShares
         * (3) newShares = newDepositShares * newDepositScalingFactor * slashingFactor
         *
         * Plugging (1) into (3):
         * (4) newDepositShares * newDepositScalingFactor * slashingFactor = currentShares + addedShares
         *
         * Solving for newDepositScalingFactor
         * (5) newDepositScalingFactor = (currentShares + addedShares) / (newDepositShares * slashingFactor)
         *
         * Plugging in (2) into (5):
         * (7) newDepositScalingFactor = (currentShares + addedShares) / ((prevDepositShares + addedShares) * slashingFactor)
         * Note that magnitudes must be divided by WAD for precision. Thus,
         *
         * (8) newDepositScalingFactor = WAD * (currentShares + addedShares) / ((prevDepositShares + addedShares) * slashingFactor / WAD)
         * (9) newDepositScalingFactor = (currentShares + addedShares) * WAD / (prevDepositShares + addedShares) * WAD / slashingFactor
         */

        // Step 1: Calculate Numerator
        uint256 currentShares = dsf.calcWithdrawable(prevDepositShares, slashingFactor);

        // Step 2: Compute currentShares + addedShares
        uint256 newShares = currentShares + addedShares;

        // Step 3: Calculate newDepositScalingFactor
        /// forgefmt: disable-next-item
        uint256 newDepositScalingFactor = newShares
            .divWad(prevDepositShares + addedShares)
            .divWad(slashingFactor);

        dsf._scalingFactor = newDepositScalingFactor;
    }

    /// @dev Reset the staker's DSF for a strategy by setting it to 0. This is the same
    /// as setting it to WAD (see the `scalingFactor` getter above).
    ///
    /// A DSF is reset when a staker reduces their deposit shares to 0, either by queueing
    /// a withdrawal, or undelegating from their operator. This ensures that subsequent
    /// delegations/deposits do not use a stale DSF (e.g. from a prior operator).
    function reset(
        DepositScalingFactor storage dsf
    ) internal {
        dsf._scalingFactor = 0;
    }

    // CONVERSION

    function calcWithdrawable(
        DepositScalingFactor memory dsf,
        uint256 depositShares,
        uint256 slashingFactor
    ) internal pure returns (uint256) {
        /// forgefmt: disable-next-item
        return depositShares
            .mulWad(dsf.scalingFactor())
            .mulWad(slashingFactor);
    }

    function calcDepositShares(
        DepositScalingFactor memory dsf,
        uint256 withdrawableShares,
        uint256 slashingFactor
    ) internal pure returns (uint256) {
        /// forgefmt: disable-next-item
        return withdrawableShares
            .divWad(dsf.scalingFactor())
            .divWad(slashingFactor);
    }

    function calcSlashedAmount(
        uint256 operatorShares,
        uint256 prevMaxMagnitude,
        uint256 newMaxMagnitude
    ) internal pure returns (uint256) {
        // round up mulDiv so we don't overslash
        return operatorShares - operatorShares.mulDiv(newMaxMagnitude, prevMaxMagnitude, Math.Rounding.Up);
    }
}

// File: src/interfaces/eigenlayer-interfaces/ISemVerMixin.sol

pragma solidity ^0.8.0;

/// @title ISemVerMixin
/// @notice A mixin interface that provides semantic versioning functionality.
/// @dev Follows SemVer 2.0.0 specification (https://semver.org/)
interface ISemVerMixin {
    /// @notice Returns the semantic version string of the contract.
    /// @return The version string in SemVer format (e.g., "v1.1.1")
    function version() external view returns (string memory);
}

// File: src/interfaces/eigenlayer-interfaces/IStrategy.sol

pragma solidity >=0.5.0;





interface IStrategyErrors {
    /// @dev Thrown when called by an account that is not strategy manager.
    error OnlyStrategyManager();
    /// @dev Thrown when new shares value is zero.
    error NewSharesZero();
    /// @dev Thrown when total shares exceeds max.
    error TotalSharesExceedsMax();
    /// @dev Thrown when amount shares is greater than total shares.
    error WithdrawalAmountExceedsTotalDeposits();
    /// @dev Thrown when attempting an action with a token that is not accepted.
    error OnlyUnderlyingToken();

    /// StrategyBaseWithTVLLimits

    /// @dev Thrown when `maxPerDeposit` exceeds max.
    error MaxPerDepositExceedsMax();
    /// @dev Thrown when balance exceeds max total deposits.
    error BalanceExceedsMaxTotalDeposits();
}

interface IStrategyEvents {
    /**
     * @notice Used to emit an event for the exchange rate between 1 share and underlying token in a strategy contract
     * @param rate is the exchange rate in wad 18 decimals
     * @dev Tokens that do not have 18 decimals must have offchain services scale the exchange rate by the proper magnitude
     */
    event ExchangeRateEmitted(uint256 rate);

    /**
     * Used to emit the underlying token and its decimals on strategy creation
     * @notice token
     * @param token is the ERC20 token of the strategy
     * @param decimals are the decimals of the ERC20 token in the strategy
     */
    event StrategyTokenSet(IERC20 token, uint8 decimals);
}

/**
 * @title Minimal interface for an `Strategy` contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Custom `Strategy` implementations may expand extensively on this interface.
 */
interface IStrategy is IStrategyErrors, IStrategyEvents, ISemVerMixin {
    /**
     * @notice Used to deposit tokens into this Strategy
     * @param token is the ERC20 token being deposited
     * @param amount is the amount of token being deposited
     * @dev This function is only callable by the strategyManager contract. It is invoked inside of the strategyManager's
     * `depositIntoStrategy` function, and individual share balances are recorded in the strategyManager as well.
     * @return newShares is the number of new shares issued at the current exchange ratio.
     */
    function deposit(IERC20 token, uint256 amount) external returns (uint256);

    /**
     * @notice Used to withdraw tokens from this Strategy, to the `recipient`'s address
     * @param recipient is the address to receive the withdrawn funds
     * @param token is the ERC20 token being transferred out
     * @param amountShares is the amount of shares being withdrawn
     * @dev This function is only callable by the strategyManager contract. It is invoked inside of the strategyManager's
     * other functions, and individual share balances are recorded in the strategyManager as well.
     */
    function withdraw(address recipient, IERC20 token, uint256 amountShares) external;

    /**
     * @notice Used to convert a number of shares to the equivalent amount of underlying tokens for this strategy.
     * For a staker using this function and trying to calculate the amount of underlying tokens they have in total they
     * should input into `amountShares` their withdrawable shares read from the `DelegationManager` contract.
     * @notice In contrast to `sharesToUnderlyingView`, this function **may** make state modifications
     * @param amountShares is the amount of shares to calculate its conversion into the underlying token
     * @return The amount of underlying tokens corresponding to the input `amountShares`
     * @dev Implementation for these functions in particular may vary significantly for different strategies
     */
    function sharesToUnderlying(
        uint256 amountShares
    ) external returns (uint256);

    /**
     * @notice Used to convert an amount of underlying tokens to the equivalent amount of shares in this strategy.
     * @notice In contrast to `underlyingToSharesView`, this function **may** make state modifications
     * @param amountUnderlying is the amount of `underlyingToken` to calculate its conversion into strategy shares
     * @return The amount of shares corresponding to the input `amountUnderlying`.  This is used as deposit shares
     * in the `StrategyManager` contract.
     * @dev Implementation for these functions in particular may vary significantly for different strategies
     */
    function underlyingToShares(
        uint256 amountUnderlying
    ) external returns (uint256);

    /**
     * @notice convenience function for fetching the current underlying value of all of the `user`'s shares in
     * this strategy. In contrast to `userUnderlyingView`, this function **may** make state modifications
     */
    function userUnderlying(
        address user
    ) external returns (uint256);

    /**
     * @notice convenience function for fetching the current total shares of `user` in this strategy, by
     * querying the `strategyManager` contract
     */
    function shares(
        address user
    ) external view returns (uint256);

    /**
     * @notice Used to convert a number of shares to the equivalent amount of underlying tokens for this strategy.
     * For a staker using this function and trying to calculate the amount of underlying tokens they have in total they
     * should input into `amountShares` their withdrawable shares read from the `DelegationManager` contract.
     * @notice In contrast to `sharesToUnderlying`, this function guarantees no state modifications
     * @param amountShares is the amount of shares to calculate its conversion into the underlying token
     * @return The amount of underlying tokens corresponding to the input `amountShares`
     * @dev Implementation for these functions in particular may vary significantly for different strategies
     */
    function sharesToUnderlyingView(
        uint256 amountShares
    ) external view returns (uint256);

    /**
     * @notice Used to convert an amount of underlying tokens to the equivalent amount of shares in this strategy.
     * @notice In contrast to `underlyingToShares`, this function guarantees no state modifications
     * @param amountUnderlying is the amount of `underlyingToken` to calculate its conversion into strategy shares
     * @return The amount of shares corresponding to the input `amountUnderlying`. This is used as deposit shares
     * in the `StrategyManager` contract.
     * @dev Implementation for these functions in particular may vary significantly for different strategies
     */
    function underlyingToSharesView(
        uint256 amountUnderlying
    ) external view returns (uint256);

    /**
     * @notice convenience function for fetching the current underlying value of all of the `user`'s shares in
     * this strategy. In contrast to `userUnderlying`, this function guarantees no state modifications
     */
    function userUnderlyingView(
        address user
    ) external view returns (uint256);

    /// @notice The underlying token for shares in this Strategy
    function underlyingToken() external view returns (IERC20);

    /// @notice The total number of extant shares in this Strategy
    function totalShares() external view returns (uint256);

    /// @notice Returns either a brief string explaining the strategy's goal & purpose, or a link to metadata that explains in more detail.
    function explanation() external view returns (string memory);
}

// File: src/interfaces/eigenlayer-interfaces/IShareManager.sol

pragma solidity ^0.8.27;





/**
 * @title Interface for a `IShareManager` contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice This contract is used by the DelegationManager as a unified interface to interact with the EigenPodManager and StrategyManager
 */
interface IShareManager {
    /// @notice Used by the DelegationManager to remove a Staker's shares from a particular strategy when entering the withdrawal queue
    /// @dev strategy must be beaconChainETH when talking to the EigenPodManager
    /// @return updatedShares the staker's deposit shares after decrement
    function removeDepositShares(
        address staker,
        IStrategy strategy,
        uint256 depositSharesToRemove
    ) external returns (uint256);

    /// @notice Used by the DelegationManager to award a Staker some shares that have passed through the withdrawal queue
    /// @dev strategy must be beaconChainETH when talking to the EigenPodManager
    /// @return existingDepositShares the shares the staker had before any were added
    /// @return addedShares the new shares added to the staker's balance
    function addShares(address staker, IStrategy strategy, uint256 shares) external returns (uint256, uint256);

    /// @notice Used by the DelegationManager to convert deposit shares to tokens and send them to a staker
    /// @dev strategy must be beaconChainETH when talking to the EigenPodManager
    /// @dev token is not validated when talking to the EigenPodManager
    function withdrawSharesAsTokens(address staker, IStrategy strategy, IERC20 token, uint256 shares) external;

    /// @notice Returns the current shares of `user` in `strategy`
    /// @dev strategy must be beaconChainETH when talking to the EigenPodManager
    /// @dev returns 0 if the user has negative shares
    function stakerDepositShares(address user, IStrategy strategy) external view returns (uint256 depositShares);

    /**
     * @notice Increase the amount of burnable shares for a given Strategy. This is called by the DelegationManager
     * when an operator is slashed in EigenLayer.
     * @param strategy The strategy to burn shares in.
     * @param addedSharesToBurn The amount of added shares to burn.
     * @dev This function is only called by the DelegationManager when an operator is slashed.
     */
    function increaseBurnableShares(IStrategy strategy, uint256 addedSharesToBurn) external;
}

// File: src/interfaces/eigenlayer-interfaces/IPauserRegistry.sol

pragma solidity >=0.5.0;

/**
 * @title Interface for the `PauserRegistry` contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 */
interface IPauserRegistry {
    error OnlyUnpauser();
    error InputAddressZero();

    event PauserStatusChanged(address pauser, bool canPause);

    event UnpauserChanged(address previousUnpauser, address newUnpauser);

    /// @notice Mapping of addresses to whether they hold the pauser role.
    function isPauser(
        address pauser
    ) external view returns (bool);

    /// @notice Unique address that holds the unpauser role. Capable of changing *both* the pauser and unpauser addresses.
    function unpauser() external view returns (address);
}

// File: src/interfaces/eigenlayer-interfaces/ISignatureUtilsMixin.sol

pragma solidity >=0.5.0;



interface ISignatureUtilsMixinErrors {
    /// @notice Thrown when a signature is invalid.
    error InvalidSignature();
    /// @notice Thrown when a signature has expired.
    error SignatureExpired();
}

interface ISignatureUtilsMixinTypes {
    /// @notice Struct that bundles together a signature and an expiration time for the signature.
    /// @dev Used primarily for stack management.
    struct SignatureWithExpiry {
        // the signature itself, formatted as a single bytes object
        bytes signature;
        // the expiration timestamp (UTC) of the signature
        uint256 expiry;
    }

    /// @notice Struct that bundles together a signature, a salt for uniqueness, and an expiration time for the signature.
    /// @dev Used primarily for stack management.
    struct SignatureWithSaltAndExpiry {
        // the signature itself, formatted as a single bytes object
        bytes signature;
        // the salt used to generate the signature
        bytes32 salt;
        // the expiration timestamp (UTC) of the signature
        uint256 expiry;
    }
}

/**
 * @title The interface for common signature utilities.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 */
interface ISignatureUtilsMixin is ISignatureUtilsMixinErrors, ISignatureUtilsMixinTypes, ISemVerMixin {
    /// @notice Computes the EIP-712 domain separator used for signature validation.
    /// @dev The domain separator is computed according to EIP-712 specification, using:
    ///      - The hardcoded name "EigenLayer"
    ///      - The contract's version string
    ///      - The current chain ID
    ///      - This contract's address
    /// @return The 32-byte domain separator hash used in EIP-712 structured data signing.
    /// @dev See https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator.
    function domainSeparator() external view returns (bytes32);
}

// File: src/interfaces/eigenlayer-interfaces/IDelegationManager.sol

pragma solidity >=0.5.0;






interface IDelegationManagerErrors {
    /// @dev Thrown when caller is neither the StrategyManager or EigenPodManager contract.
    error OnlyStrategyManagerOrEigenPodManager();
    /// @dev Thrown when msg.sender is not the EigenPodManager
    error OnlyEigenPodManager();
    /// @dev Throw when msg.sender is not the AllocationManager
    error OnlyAllocationManager();

    /// Delegation Status

    /// @dev Thrown when an operator attempts to undelegate.
    error OperatorsCannotUndelegate();
    /// @dev Thrown when an account is actively delegated.
    error ActivelyDelegated();
    /// @dev Thrown when an account is not actively delegated.
    error NotActivelyDelegated();
    /// @dev Thrown when `operator` is not a registered operator.
    error OperatorNotRegistered();

    /// Invalid Inputs

    /// @dev Thrown when attempting to execute an action that was not queued.
    error WithdrawalNotQueued();
    /// @dev Thrown when caller cannot undelegate on behalf of a staker.
    error CallerCannotUndelegate();
    /// @dev Thrown when two array parameters have mismatching lengths.
    error InputArrayLengthMismatch();
    /// @dev Thrown when input arrays length is zero.
    error InputArrayLengthZero();

    /// Slashing

    /// @dev Thrown when an operator has been fully slashed(maxMagnitude is 0) for a strategy.
    /// or if the staker has had been natively slashed to the point of their beaconChainScalingFactor equalling 0.
    error FullySlashed();

    /// Signatures

    /// @dev Thrown when attempting to spend a spent eip-712 salt.
    error SaltSpent();

    /// Withdrawal Processing

    /// @dev Thrown when attempting to withdraw before delay has elapsed.
    error WithdrawalDelayNotElapsed();
    /// @dev Thrown when withdrawer is not the current caller.
    error WithdrawerNotCaller();
}

interface IDelegationManagerTypes {
    // @notice Struct used for storing information about a single operator who has registered with EigenLayer
    struct OperatorDetails {
        /// @notice DEPRECATED -- this field is no longer used, payments are handled in RewardsCoordinator.sol
        address __deprecated_earningsReceiver;
        /**
         * @notice Address to verify signatures when a staker wishes to delegate to the operator, as well as controlling "forced undelegations".
         * @dev Signature verification follows these rules:
         * 1) If this address is left as address(0), then any staker will be free to delegate to the operator, i.e. no signature verification will be performed.
         * 2) If this address is an EOA (i.e. it has no code), then we follow standard ECDSA signature verification for delegations to the operator.
         * 3) If this address is a contract (i.e. it has code) then we forward a call to the contract and verify that it returns the correct EIP-1271 "magic value".
         */
        address delegationApprover;
        /// @notice DEPRECATED -- this field is no longer used. An analogous field is the `allocationDelay` stored in the AllocationManager
        uint32 __deprecated_stakerOptOutWindowBlocks;
    }

    /**
     * @notice Abstract struct used in calculating an EIP712 signature for an operator's delegationApprover to approve that a specific staker delegate to the operator.
     * @dev Used in computing the `DELEGATION_APPROVAL_TYPEHASH` and as a reference in the computation of the approverDigestHash in the `_delegate` function.
     */
    struct DelegationApproval {
        // the staker who is delegating
        address staker;
        // the operator being delegated to
        address operator;
        // the operator's provided salt
        bytes32 salt;
        // the expiration timestamp (UTC) of the signature
        uint256 expiry;
    }

    /**
     * @dev A struct representing an existing queued withdrawal. After the withdrawal delay has elapsed, this withdrawal can be completed via `completeQueuedWithdrawal`.
     * A `Withdrawal` is created by the `DelegationManager` when `queueWithdrawals` is called. The `withdrawalRoots` hashes returned by `queueWithdrawals` can be used
     * to fetch the corresponding `Withdrawal` from storage (via `getQueuedWithdrawal`).
     *
     * @param staker The address that queued the withdrawal
     * @param delegatedTo The address that the staker was delegated to at the time the withdrawal was queued. Used to determine if additional slashing occurred before
     * this withdrawal became completable.
     * @param withdrawer The address that will call the contract to complete the withdrawal. Note that this will always equal `staker`; alternate withdrawers are not
     * supported at this time.
     * @param nonce The staker's `cumulativeWithdrawalsQueued` at time of queuing. Used to ensure withdrawals have unique hashes.
     * @param startBlock The block number when the withdrawal was queued.
     * @param strategies The strategies requested for withdrawal when the withdrawal was queued
     * @param scaledShares The staker's deposit shares requested for withdrawal, scaled by the staker's `depositScalingFactor`. Upon completion, these will be
     * scaled by the appropriate slashing factor as of the withdrawal's completable block. The result is what is actually withdrawable.
     */
    struct Withdrawal {
        address staker;
        address delegatedTo;
        address withdrawer;
        uint256 nonce;
        uint32 startBlock;
        IStrategy[] strategies;
        uint256[] scaledShares;
    }

    /**
     * @param strategies The strategies to withdraw from
     * @param depositShares For each strategy, the number of deposit shares to withdraw. Deposit shares can
     * be queried via `getDepositedShares`.
     * NOTE: The number of shares ultimately received when a withdrawal is completed may be lower depositShares
     * if the staker or their delegated operator has experienced slashing.
     * @param __deprecated_withdrawer This field is ignored. The only party that may complete a withdrawal
     * is the staker that originally queued it. Alternate withdrawers are not supported.
     */
    struct QueuedWithdrawalParams {
        IStrategy[] strategies;
        uint256[] depositShares;
        address __deprecated_withdrawer;
    }
}

interface IDelegationManagerEvents is IDelegationManagerTypes {
    // @notice Emitted when a new operator registers in EigenLayer and provides their delegation approver.
    event OperatorRegistered(address indexed operator, address delegationApprover);

    /// @notice Emitted when an operator updates their delegation approver
    event DelegationApproverUpdated(address indexed operator, address newDelegationApprover);

    /**
     * @notice Emitted when @param operator indicates that they are updating their MetadataURI string
     * @dev Note that these strings are *never stored in storage* and are instead purely emitted in events for off-chain indexing
     */
    event OperatorMetadataURIUpdated(address indexed operator, string metadataURI);

    /// @notice Emitted whenever an operator's shares are increased for a given strategy. Note that shares is the delta in the operator's shares.
    event OperatorSharesIncreased(address indexed operator, address staker, IStrategy strategy, uint256 shares);

    /// @notice Emitted whenever an operator's shares are decreased for a given strategy. Note that shares is the delta in the operator's shares.
    event OperatorSharesDecreased(address indexed operator, address staker, IStrategy strategy, uint256 shares);

    /// @notice Emitted when @param staker delegates to @param operator.
    event StakerDelegated(address indexed staker, address indexed operator);

    /// @notice Emitted when @param staker undelegates from @param operator.
    event StakerUndelegated(address indexed staker, address indexed operator);

    /// @notice Emitted when @param staker is undelegated via a call not originating from the staker themself
    event StakerForceUndelegated(address indexed staker, address indexed operator);

    /// @notice Emitted when a staker's depositScalingFactor is updated
    event DepositScalingFactorUpdated(address staker, IStrategy strategy, uint256 newDepositScalingFactor);

    /**
     * @notice Emitted when a new withdrawal is queued.
     * @param withdrawalRoot Is the hash of the `withdrawal`.
     * @param withdrawal Is the withdrawal itself.
     * @param sharesToWithdraw Is an array of the expected shares that were queued for withdrawal corresponding to the strategies in the `withdrawal`.
     */
    event SlashingWithdrawalQueued(bytes32 withdrawalRoot, Withdrawal withdrawal, uint256[] sharesToWithdraw);

    /// @notice Emitted when a queued withdrawal is completed
    event SlashingWithdrawalCompleted(bytes32 withdrawalRoot);

    /// @notice Emitted whenever an operator's shares are slashed for a given strategy
    event OperatorSharesSlashed(address indexed operator, IStrategy strategy, uint256 totalSlashedShares);
}

/**
 * @title DelegationManager
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice  This is the contract for delegation in EigenLayer. The main functionalities of this contract are
 * - enabling anyone to register as an operator in EigenLayer
 * - allowing operators to specify parameters related to stakers who delegate to them
 * - enabling any staker to delegate its stake to the operator of its choice (a given staker can only delegate to a single operator at a time)
 * - enabling a staker to undelegate its assets from the operator it is delegated to (performed as part of the withdrawal process, initiated through the StrategyManager)
 */
interface IDelegationManager is ISignatureUtilsMixin, IDelegationManagerErrors, IDelegationManagerEvents {
    /**
     * @dev Initializes the initial owner and paused status.
     */
    function initialize(address initialOwner, uint256 initialPausedStatus) external;

    /**
     * @notice Registers the caller as an operator in EigenLayer.
     * @param initDelegationApprover is an address that, if set, must provide a signature when stakers delegate
     * to an operator.
     * @param allocationDelay The delay before allocations take effect.
     * @param metadataURI is a URI for the operator's metadata, i.e. a link providing more details on the operator.
     *
     * @dev Once an operator is registered, they cannot 'deregister' as an operator, and they will forever be considered "delegated to themself".
     * @dev This function will revert if the caller is already delegated to an operator.
     * @dev Note that the `metadataURI` is *never stored * and is only emitted in the `OperatorMetadataURIUpdated` event
     */
    function registerAsOperator(
        address initDelegationApprover,
        uint32 allocationDelay,
        string calldata metadataURI
    ) external;

    /**
     * @notice Updates an operator's stored `delegationApprover`.
     * @param operator is the operator to update the delegationApprover for
     * @param newDelegationApprover is the new delegationApprover for the operator
     *
     * @dev The caller must have previously registered as an operator in EigenLayer.
     */
    function modifyOperatorDetails(address operator, address newDelegationApprover) external;

    /**
     * @notice Called by an operator to emit an `OperatorMetadataURIUpdated` event indicating the information has updated.
     * @param operator The operator to update metadata for
     * @param metadataURI The URI for metadata associated with an operator
     * @dev Note that the `metadataURI` is *never stored * and is only emitted in the `OperatorMetadataURIUpdated` event
     */
    function updateOperatorMetadataURI(address operator, string calldata metadataURI) external;

    /**
     * @notice Caller delegates their stake to an operator.
     * @param operator The account (`msg.sender`) is delegating its assets to for use in serving applications built on EigenLayer.
     * @param approverSignatureAndExpiry (optional) Verifies the operator approves of this delegation
     * @param approverSalt (optional) A unique single use value tied to an individual signature.
     * @dev The signature/salt are used ONLY if the operator has configured a delegationApprover.
     * If they have not, these params can be left empty.
     */
    function delegateTo(
        address operator,
        SignatureWithExpiry memory approverSignatureAndExpiry,
        bytes32 approverSalt
    ) external;

    /**
     * @notice Undelegates the staker from their operator and queues a withdrawal for all of their shares
     * @param staker The account to be undelegated
     * @return withdrawalRoots The roots of the newly queued withdrawals, if a withdrawal was queued. Returns
     * an empty array if none was queued.
     *
     * @dev Reverts if the `staker` is also an operator, since operators are not allowed to undelegate from themselves.
     * @dev Reverts if the caller is not the staker, nor the operator who the staker is delegated to, nor the operator's specified "delegationApprover"
     * @dev Reverts if the `staker` is not delegated to an operator
     */
    function undelegate(
        address staker
    ) external returns (bytes32[] memory withdrawalRoots);

    /**
     * @notice Undelegates the staker from their current operator, and redelegates to `newOperator`
     * Queues a withdrawal for all of the staker's withdrawable shares. These shares will only be
     * delegated to `newOperator` AFTER the withdrawal is completed.
     * @dev This method acts like a call to `undelegate`, then `delegateTo`
     * @param newOperator the new operator that will be delegated all assets
     * @dev NOTE: the following 2 params are ONLY checked if `newOperator` has a `delegationApprover`.
     * If not, they can be left empty.
     * @param newOperatorApproverSig A signature from the operator's `delegationApprover`
     * @param approverSalt A unique single use value tied to the approver's signature
     */
    function redelegate(
        address newOperator,
        SignatureWithExpiry memory newOperatorApproverSig,
        bytes32 approverSalt
    ) external returns (bytes32[] memory withdrawalRoots);

    /**
     * @notice Allows a staker to queue a withdrawal of their deposit shares. The withdrawal can be
     * completed after the MIN_WITHDRAWAL_DELAY_BLOCKS via either of the completeQueuedWithdrawal methods.
     *
     * While in the queue, these shares are removed from the staker's balance, as well as from their operator's
     * delegated share balance (if applicable). Note that while in the queue, deposit shares are still subject
     * to slashing. If any slashing has occurred, the shares received may be less than the queued deposit shares.
     *
     * @dev To view all the staker's strategies/deposit shares that can be queued for withdrawal, see `getDepositedShares`
     * @dev To view the current conversion between a staker's deposit shares and withdrawable shares, see `getWithdrawableShares`
     */
    function queueWithdrawals(
        QueuedWithdrawalParams[] calldata params
    ) external returns (bytes32[] memory);

    /**
     * @notice Used to complete a queued withdrawal
     * @param withdrawal The withdrawal to complete
     * @param tokens Array in which the i-th entry specifies the `token` input to the 'withdraw' function of the i-th Strategy in the `withdrawal.strategies` array.
     * @param tokens For each `withdrawal.strategies`, the underlying token of the strategy
     * NOTE: if `receiveAsTokens` is false, the `tokens` array is unused and can be filled with default values. However, `tokens.length` MUST still be equal to `withdrawal.strategies.length`.
     * NOTE: For the `beaconChainETHStrategy`, the corresponding `tokens` value is ignored (can be 0).
     * @param receiveAsTokens If true, withdrawn shares will be converted to tokens and sent to the caller. If false, the caller receives shares that can be delegated to an operator.
     * NOTE: if the caller receives shares and is currently delegated to an operator, the received shares are
     * automatically delegated to the caller's current operator.
     */
    function completeQueuedWithdrawal(
        Withdrawal calldata withdrawal,
        IERC20[] calldata tokens,
        bool receiveAsTokens
    ) external;

    /**
     * @notice Used to complete multiple queued withdrawals
     * @param withdrawals Array of Withdrawals to complete. See `completeQueuedWithdrawal` for the usage of a single Withdrawal.
     * @param tokens Array of tokens for each Withdrawal. See `completeQueuedWithdrawal` for the usage of a single array.
     * @param receiveAsTokens Whether or not to complete each withdrawal as tokens. See `completeQueuedWithdrawal` for the usage of a single boolean.
     * @dev See `completeQueuedWithdrawal` for relevant dev tags
     */
    function completeQueuedWithdrawals(
        Withdrawal[] calldata withdrawals,
        IERC20[][] calldata tokens,
        bool[] calldata receiveAsTokens
    ) external;

    /**
     * @notice Called by a share manager when a staker's deposit share balance in a strategy increases.
     * This method delegates any new shares to an operator (if applicable), and updates the staker's
     * deposit scaling factor regardless.
     * @param staker The address whose deposit shares have increased
     * @param strategy The strategy in which shares have been deposited
     * @param prevDepositShares The number of deposit shares the staker had in the strategy prior to the increase
     * @param addedShares The number of deposit shares added by the staker
     *
     * @dev Note that if the either the staker's current operator has been slashed 100% for `strategy`, OR the
     * staker has been slashed 100% on the beacon chain such that the calculated slashing factor is 0, this
     * method WILL REVERT.
     */
    function increaseDelegatedShares(
        address staker,
        IStrategy strategy,
        uint256 prevDepositShares,
        uint256 addedShares
    ) external;

    /**
     * @notice If the staker is delegated, decreases its operator's shares in response to
     * a decrease in balance in the beaconChainETHStrategy
     * @param staker the staker whose operator's balance will be decreased
     * @param curDepositShares the current deposit shares held by the staker
     * @param beaconChainSlashingFactorDecrease the amount that the staker's beaconChainSlashingFactor has decreased by
     * @dev Note: `beaconChainSlashingFactorDecrease` are assumed to ALWAYS be < 1 WAD.
     * These invariants are maintained in the EigenPodManager.
     */
    function decreaseDelegatedShares(
        address staker,
        uint256 curDepositShares,
        uint64 beaconChainSlashingFactorDecrease
    ) external;

    /**
     * @notice Decreases the operators shares in storage after a slash and increases the burnable shares by calling
     * into either the StrategyManager or EigenPodManager (if the strategy is beaconChainETH).
     * @param operator The operator to decrease shares for
     * @param strategy The strategy to decrease shares for
     * @param prevMaxMagnitude the previous maxMagnitude of the operator
     * @param newMaxMagnitude the new maxMagnitude of the operator
     * @dev Callable only by the AllocationManager
     * @dev Note: Assumes `prevMaxMagnitude <= newMaxMagnitude`. This invariant is maintained in
     * the AllocationManager.
     */
    function slashOperatorShares(
        address operator,
        IStrategy strategy,
        uint64 prevMaxMagnitude,
        uint64 newMaxMagnitude
    ) external;

    /**
     *
     *                         VIEW FUNCTIONS
     *
     */

    /**
     * @notice returns the address of the operator that `staker` is delegated to.
     * @notice Mapping: staker => operator whom the staker is currently delegated to.
     * @dev Note that returning address(0) indicates that the staker is not actively delegated to any operator.
     */
    function delegatedTo(
        address staker
    ) external view returns (address);

    /**
     * @notice Mapping: delegationApprover => 32-byte salt => whether or not the salt has already been used by the delegationApprover.
     * @dev Salts are used in the `delegateTo` function. Note that this function only processes the delegationApprover's
     * signature + the provided salt if the operator being delegated to has specified a nonzero address as their `delegationApprover`.
     */
    function delegationApproverSaltIsSpent(address _delegationApprover, bytes32 salt) external view returns (bool);

    /// @notice Mapping: staker => cumulative number of queued withdrawals they have ever initiated.
    /// @dev This only increments (doesn't decrement), and is used to help ensure that otherwise identical withdrawals have unique hashes.
    function cumulativeWithdrawalsQueued(
        address staker
    ) external view returns (uint256);

    /**
     * @notice Returns 'true' if `staker` *is* actively delegated, and 'false' otherwise.
     */
    function isDelegated(
        address staker
    ) external view returns (bool);

    /**
     * @notice Returns true is an operator has previously registered for delegation.
     */
    function isOperator(
        address operator
    ) external view returns (bool);

    /**
     * @notice Returns the delegationApprover account for an operator
     */
    function delegationApprover(
        address operator
    ) external view returns (address);

    /**
     * @notice Returns the shares that an operator has delegated to them in a set of strategies
     * @param operator the operator to get shares for
     * @param strategies the strategies to get shares for
     */
    function getOperatorShares(
        address operator,
        IStrategy[] memory strategies
    ) external view returns (uint256[] memory);

    /**
     * @notice Returns the shares that a set of operators have delegated to them in a set of strategies
     * @param operators the operators to get shares for
     * @param strategies the strategies to get shares for
     */
    function getOperatorsShares(
        address[] memory operators,
        IStrategy[] memory strategies
    ) external view returns (uint256[][] memory);

    /**
     * @notice Returns amount of withdrawable shares from an operator for a strategy that is still in the queue
     * and therefore slashable. Note that the *actual* slashable amount could be less than this value as this doesn't account
     * for amounts that have already been slashed. This assumes that none of the shares have been slashed.
     * @param operator the operator to get shares for
     * @param strategy the strategy to get shares for
     * @return the amount of shares that are slashable in the withdrawal queue for an operator and a strategy
     */
    function getSlashableSharesInQueue(address operator, IStrategy strategy) external view returns (uint256);

    /**
     * @notice Given a staker and a set of strategies, return the shares they can queue for withdrawal and the
     * corresponding depositShares.
     * This value depends on which operator the staker is delegated to.
     * The shares amount returned is the actual amount of Strategy shares the staker would receive (subject
     * to each strategy's underlying shares to token ratio).
     */
    function getWithdrawableShares(
        address staker,
        IStrategy[] memory strategies
    ) external view returns (uint256[] memory withdrawableShares, uint256[] memory depositShares);

    /**
     * @notice Returns the number of shares in storage for a staker and all their strategies
     */
    function getDepositedShares(
        address staker
    ) external view returns (IStrategy[] memory, uint256[] memory);

    /**
     * @notice Returns the scaling factor applied to a staker's deposits for a given strategy
     */
    function depositScalingFactor(address staker, IStrategy strategy) external view returns (uint256);

    /**
     * @notice Returns the Withdrawal associated with a `withdrawalRoot`.
     * @param withdrawalRoot The hash identifying the queued withdrawal.
     * @return withdrawal The withdrawal details.
     */
    function queuedWithdrawals(
        bytes32 withdrawalRoot
    ) external view returns (Withdrawal memory withdrawal);

    /**
     * @notice Returns the Withdrawal and corresponding shares associated with a `withdrawalRoot`
     * @param withdrawalRoot The hash identifying the queued withdrawal
     * @return withdrawal The withdrawal details
     * @return shares Array of shares corresponding to each strategy in the withdrawal
     * @dev The shares are what a user would receive from completing a queued withdrawal, assuming all slashings are applied
     * @dev Withdrawals queued before the slashing release cannot be queried with this method
     */
    function getQueuedWithdrawal(
        bytes32 withdrawalRoot
    ) external view returns (Withdrawal memory withdrawal, uint256[] memory shares);

    /**
     * @notice Returns all queued withdrawals and their corresponding shares for a staker.
     * @param staker The address of the staker to query withdrawals for.
     * @return withdrawals Array of Withdrawal structs containing details about each queued withdrawal.
     * @return shares 2D array of shares, where each inner array corresponds to the strategies in the withdrawal.
     * @dev The shares are what a user would receive from completing a queued withdrawal, assuming all slashings are applied.
     */
    function getQueuedWithdrawals(
        address staker
    ) external view returns (Withdrawal[] memory withdrawals, uint256[][] memory shares);

    /// @notice Returns a list of queued withdrawal roots for the `staker`.
    /// NOTE that this only returns withdrawals queued AFTER the slashing release.
    function getQueuedWithdrawalRoots(
        address staker
    ) external view returns (bytes32[] memory);

    /**
     * @notice Converts shares for a set of strategies to deposit shares, likely in order to input into `queueWithdrawals`.
     * This function will revert from a division by 0 error if any of the staker's strategies have a slashing factor of 0.
     * @param staker the staker to convert shares for
     * @param strategies the strategies to convert shares for
     * @param withdrawableShares the shares to convert
     * @return the deposit shares
     * @dev will be a few wei off due to rounding errors
     */
    function convertToDepositShares(
        address staker,
        IStrategy[] memory strategies,
        uint256[] memory withdrawableShares
    ) external view returns (uint256[] memory);

    /// @notice Returns the keccak256 hash of `withdrawal`.
    function calculateWithdrawalRoot(
        Withdrawal memory withdrawal
    ) external pure returns (bytes32);

    /**
     * @notice Calculates the digest hash to be signed by the operator's delegationApprove and used in the `delegateTo` function.
     * @param staker The account delegating their stake
     * @param operator The account receiving delegated stake
     * @param _delegationApprover the operator's `delegationApprover` who will be signing the delegationHash (in general)
     * @param approverSalt A unique and single use value associated with the approver signature.
     * @param expiry Time after which the approver's signature becomes invalid
     */
    function calculateDelegationApprovalDigestHash(
        address staker,
        address operator,
        address _delegationApprover,
        bytes32 approverSalt,
        uint256 expiry
    ) external view returns (bytes32);

    /// @notice return address of the beaconChainETHStrategy
    function beaconChainETHStrategy() external view returns (IStrategy);

    /**
     * @notice Returns the minimum withdrawal delay in blocks to pass for withdrawals queued to be completable.
     * Also applies to legacy withdrawals so any withdrawals not completed prior to the slashing upgrade will be subject
     * to this longer delay.
     * @dev Backwards-compatible interface to return the internal `MIN_WITHDRAWAL_DELAY_BLOCKS` value
     * @dev Previous value in storage was deprecated. See `__deprecated_minWithdrawalDelayBlocks`
     */
    function minWithdrawalDelayBlocks() external view returns (uint32);

    /// @notice The EIP-712 typehash for the DelegationApproval struct used by the contract
    function DELEGATION_APPROVAL_TYPEHASH() external view returns (bytes32);
}

// File: lib/openzeppelin-contracts/contracts/proxy/beacon/IBeacon.sol

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

// File: src/interfaces/eigenlayer-interfaces/IETHPOSDeposit.sol

// ┏━━━┓━┏┓━┏┓━━┏━━━┓━━┏━━━┓━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━┏┓━━━━━┏━━━┓━━━━━━━━━┏┓━━━━━━━━━━━━━━┏┓━
// ┃┏━━┛┏┛┗┓┃┃━━┃┏━┓┃━━┃┏━┓┃━━━━┗┓┏┓┃━━━━━━━━━━━━━━━━━━┏┛┗┓━━━━┃┏━┓┃━━━━━━━━┏┛┗┓━━━━━━━━━━━━┏┛┗┓
// ┃┗━━┓┗┓┏┛┃┗━┓┗┛┏┛┃━━┃┃━┃┃━━━━━┃┃┃┃┏━━┓┏━━┓┏━━┓┏━━┓┏┓┗┓┏┛━━━━┃┃━┗┛┏━━┓┏━┓━┗┓┏┛┏━┓┏━━┓━┏━━┓┗┓┏┛
// ┃┏━━┛━┃┃━┃┏┓┃┏━┛┏┛━━┃┃━┃┃━━━━━┃┃┃┃┃┏┓┃┃┏┓┃┃┏┓┃┃━━┫┣┫━┃┃━━━━━┃┃━┏┓┃┏┓┃┃┏┓┓━┃┃━┃┏┛┗━┓┃━┃┏━┛━┃┃━
// ┃┗━━┓━┃┗┓┃┃┃┃┃┃┗━┓┏┓┃┗━┛┃━━━━┏┛┗┛┃┃┃━┫┃┗┛┃┃┗┛┃┣━━┃┃┃━┃┗┓━━━━┃┗━┛┃┃┗┛┃┃┃┃┃━┃┗┓┃┃━┃┗┛┗┓┃┗━┓━┃┗┓
// ┗━━━┛━┗━┛┗┛┗┛┗━━━┛┗┛┗━━━┛━━━━┗━━━┛┗━━┛┃┏━┛┗━━┛┗━━┛┗┛━┗━┛━━━━┗━━━┛┗━━┛┗┛┗┛━┗━┛┗┛━┗━━━┛┗━━┛━┗━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┃┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┗┛━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


pragma solidity >=0.5.0;

// This interface is designed to be compatible with the Vyper version.
/// @notice This is the Ethereum 2.0 deposit contract interface.
/// For more information see the Phase 0 specification under https://github.com/ethereum/eth2.0-specs
interface IETHPOSDeposit {
    /// @notice A processed deposit event.
    event DepositEvent(bytes pubkey, bytes withdrawal_credentials, bytes amount, bytes signature, bytes index);

    /// @notice Submit a Phase 0 DepositData object.
    /// @param pubkey A BLS12-381 public key.
    /// @param withdrawal_credentials Commitment to a public key for withdrawals.
    /// @param signature A BLS12-381 signature.
    /// @param deposit_data_root The SHA-256 hash of the SSZ-encoded DepositData object.
    /// Used as a protection against malformed input.
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;

    /// @notice Query the current deposit root hash.
    /// @return The deposit root hash.
    function get_deposit_root() external view returns (bytes32);

    /// @notice Query the current deposit count.
    /// @return The deposit count encoded as a little endian 64-bit number.
    function get_deposit_count() external view returns (bytes memory);
}

// File: lib/eigenlayer-libraries/EigenlayerMerkle.sol

// Adapted from OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library EigenlayerMerkle {
    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. The tree is built assuming `leaf` is
     * the 0 indexed `index`'th leaf from the bottom left of the tree.
     *
     * Note this is for a Merkle tree using the keccak/sha3 hash function
     */
    function verifyInclusionKeccak(
        bytes memory proof,
        bytes32 root,
        bytes32 leaf,
        uint256 index
    ) internal pure returns (bool) {
        return processInclusionProofKeccak(proof, leaf, index) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. The tree is built assuming `leaf` is
     * the 0 indexed `index`'th leaf from the bottom left of the tree.
     *
     * _Available since v4.4._
     *
     * Note this is for a Merkle tree using the keccak/sha3 hash function
     */
    function processInclusionProofKeccak(
        bytes memory proof,
        bytes32 leaf,
        uint256 index
    ) internal pure returns (bytes32) {
        require(
            proof.length != 0 && proof.length % 32 == 0,
            "Merkle.processInclusionProofKeccak: proof length should be a non-zero multiple of 32"
        );
        bytes32 computedHash = leaf;
        for (uint256 i = 32; i <= proof.length; i += 32) {
            if (index % 2 == 0) {
                // if ith bit of index is 0, then computedHash is a left sibling
                assembly {
                    mstore(0x00, computedHash)
                    mstore(0x20, mload(add(proof, i)))
                    computedHash := keccak256(0x00, 0x40)
                    index := div(index, 2)
                }
            } else {
                // if ith bit of index is 1, then computedHash is a right sibling
                assembly {
                    mstore(0x00, mload(add(proof, i)))
                    mstore(0x20, computedHash)
                    computedHash := keccak256(0x00, 0x40)
                    index := div(index, 2)
                }
            }
        }
        return computedHash;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. The tree is built assuming `leaf` is
     * the 0 indexed `index`'th leaf from the bottom left of the tree.
     *
     * Note this is for a Merkle tree using the sha256 hash function
     */
    function verifyInclusionSha256(
        bytes memory proof,
        bytes32 root,
        bytes32 leaf,
        uint256 index
    ) internal view returns (bool) {
        return processInclusionProofSha256(proof, leaf, index) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. The tree is built assuming `leaf` is
     * the 0 indexed `index`'th leaf from the bottom left of the tree.
     *
     * _Available since v4.4._
     *
     * Note this is for a Merkle tree using the sha256 hash function
     */
    function processInclusionProofSha256(
        bytes memory proof,
        bytes32 leaf,
        uint256 index
    ) internal view returns (bytes32) {
        require(
            proof.length != 0 && proof.length % 32 == 0,
            "Merkle.processInclusionProofSha256: proof length should be a non-zero multiple of 32"
        );
        bytes32[1] memory computedHash = [leaf];
        for (uint256 i = 32; i <= proof.length; i += 32) {
            if (index % 2 == 0) {
                // if ith bit of index is 0, then computedHash is a left sibling
                assembly {
                    mstore(0x00, mload(computedHash))
                    mstore(0x20, mload(add(proof, i)))
                    if iszero(staticcall(sub(gas(), 2000), 2, 0x00, 0x40, computedHash, 0x20)) {
                        revert(0, 0)
                    }
                    index := div(index, 2)
                }
            } else {
                // if ith bit of index is 1, then computedHash is a right sibling
                assembly {
                    mstore(0x00, mload(add(proof, i)))
                    mstore(0x20, mload(computedHash))
                    if iszero(staticcall(sub(gas(), 2000), 2, 0x00, 0x40, computedHash, 0x20)) {
                        revert(0, 0)
                    }
                    index := div(index, 2)
                }
            }
        }
        return computedHash[0];
    }

    /**
     @notice this function returns the merkle root of a tree created from a set of leaves using sha256 as its hash function
     @param leaves the leaves of the merkle tree
     @return The computed Merkle root of the tree.
     @dev A pre-condition to this function is that leaves.length is a power of two.  If not, the function will merkleize the inputs incorrectly.
     */
    function merkleizeSha256(bytes32[] memory leaves) internal pure returns (bytes32) {
        //there are half as many nodes in the layer above the leaves
        uint256 numNodesInLayer = leaves.length / 2;
        //create a layer to store the internal nodes
        bytes32[] memory layer = new bytes32[](numNodesInLayer);
        //fill the layer with the pairwise hashes of the leaves
        for (uint256 i = 0; i < numNodesInLayer; i++) {
            layer[i] = sha256(abi.encodePacked(leaves[2 * i], leaves[2 * i + 1]));
        }
        //the next layer above has half as many nodes
        numNodesInLayer /= 2;
        //while we haven't computed the root
        while (numNodesInLayer != 0) {
            //overwrite the first numNodesInLayer nodes in layer with the pairwise hashes of their children
            for (uint256 i = 0; i < numNodesInLayer; i++) {
                layer[i] = sha256(abi.encodePacked(layer[2 * i], layer[2 * i + 1]));
            }
            //the next layer above has half as many nodes
            numNodesInLayer /= 2;
        }
        //the first node in the layer is the root
        return layer[0];
    }
}

// File: lib/eigenlayer-libraries/Endian.sol

pragma solidity ^0.8.0;

library Endian {
    /**
     * @notice Converts a little endian-formatted uint64 to a big endian-formatted uint64
     * @param lenum little endian-formatted uint64 input, provided as 'bytes32' type
     * @return n The big endian-formatted uint64
     * @dev Note that the input is formatted as a 'bytes32' type (i.e. 256 bits), but it is immediately truncated to a uint64 (i.e. 64 bits)
     * through a right-shift/shr operation.
     */
    function fromLittleEndianUint64(bytes32 lenum) internal pure returns (uint64 n) {
        // the number needs to be stored in little-endian encoding (ie in bytes 0-8)
        n = uint64(uint256(lenum >> 192));
        return
            (n >> 56) |
            ((0x00FF000000000000 & n) >> 40) |
            ((0x0000FF0000000000 & n) >> 24) |
            ((0x000000FF00000000 & n) >> 8) |
            ((0x00000000FF000000 & n) << 8) |
            ((0x0000000000FF0000 & n) << 24) |
            ((0x000000000000FF00 & n) << 40) |
            ((0x00000000000000FF & n) << 56);
    }
}

// File: lib/eigenlayer-libraries/BeaconChainProofs.sol

pragma solidity ^0.8.0;




//Utility library for parsing and PHASE0 beacon chain block headers
//SSZ Spec: https://github.com/ethereum/consensus-specs/blob/dev/ssz/simple-serialize.md#merkleization
//BeaconBlockHeader Spec: https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#beaconblockheader
//BeaconState Spec: https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#beaconstate
library BeaconChainProofs {

    /// @notice Heights of various merkle trees in the beacon chain
    /// - beaconBlockRoot
    /// |                                             HEIGHT: BEACON_BLOCK_HEADER_TREE_HEIGHT
    /// -- beaconStateRoot
    /// |                                             HEIGHT: BEACON_STATE_TREE_HEIGHT
    /// validatorContainerRoot, balanceContainerRoot
    /// |                       |                     HEIGHT: BALANCE_TREE_HEIGHT
    /// |                       individual balances
    /// |                                             HEIGHT: VALIDATOR_TREE_HEIGHT
    /// individual validators
    uint256 internal constant BEACON_BLOCK_HEADER_TREE_HEIGHT = 3;
    uint256 internal constant BEACON_STATE_TREE_HEIGHT = 5;
    uint256 internal constant BALANCE_TREE_HEIGHT = 38;
    uint256 internal constant VALIDATOR_TREE_HEIGHT = 40;
    
    /// @notice Index of the beaconStateRoot in the `BeaconBlockHeader` container
    ///
    /// BeaconBlockHeader = [..., state_root, ...]
    ///                      0...      3
    ///
    /// (See https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#beaconblockheader)
    uint256 internal constant STATE_ROOT_INDEX = 3;

    /// @notice Indices for fields in the `BeaconState` container
    ///
    /// BeaconState = [..., validators, balances, ...]
    ///                0...     11         12
    ///
    /// (See https://github.com/ethereum/consensus-specs/blob/dev/specs/capella/beacon-chain.md#beaconstate)
    uint256 internal constant VALIDATOR_CONTAINER_INDEX = 11;
    uint256 internal constant BALANCE_CONTAINER_INDEX = 12;

    /// @notice Number of fields in the `Validator` container
    /// (See https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#validator)
    uint256 internal constant VALIDATOR_FIELDS_LENGTH = 8;

    /// @notice Indices for fields in the `Validator` container
    uint256 internal constant VALIDATOR_PUBKEY_INDEX = 0;
    uint256 internal constant VALIDATOR_WITHDRAWAL_CREDENTIALS_INDEX = 1;
    uint256 internal constant VALIDATOR_BALANCE_INDEX = 2;
    uint256 internal constant VALIDATOR_SLASHED_INDEX = 3;
    uint256 internal constant VALIDATOR_EXIT_EPOCH_INDEX = 6;

    /// @notice Slot/Epoch timings
    uint64 internal constant SECONDS_PER_SLOT = 12;
    uint64 internal constant SLOTS_PER_EPOCH = 32;
    uint64 internal constant SECONDS_PER_EPOCH = SLOTS_PER_EPOCH * SECONDS_PER_SLOT;

    /// @notice `FAR_FUTURE_EPOCH` is used as the default value for certain `Validator`
    /// fields when a `Validator` is first created on the beacon chain
    uint64 internal constant FAR_FUTURE_EPOCH = type(uint64).max;
    bytes8 internal constant UINT64_MASK = 0xffffffffffffffff;

    /// @notice Contains a beacon state root and a merkle proof verifying its inclusion under a beacon block root
    struct StateRootProof {
        bytes32 beaconStateRoot;
        bytes proof;
    }

    /// @notice Contains a validator's fields and a merkle proof of their inclusion under a beacon state root
    struct ValidatorProof {
        bytes32[] validatorFields;
        bytes proof;
    }

    /// @notice Contains a beacon balance container root and a proof of this root under a beacon block root
    struct BalanceContainerProof {
        bytes32 balanceContainerRoot;
        bytes proof;
    }

    /// @notice Contains a validator balance root and a proof of its inclusion under a balance container root
    struct BalanceProof {
        bytes32 pubkeyHash;
        bytes32 balanceRoot;
        bytes proof;
    }

    /*******************************************************************************
                 VALIDATOR FIELDS -> BEACON STATE ROOT -> BEACON BLOCK ROOT
    *******************************************************************************/

    /// @notice Verify a merkle proof of the beacon state root against a beacon block root
    /// @param beaconBlockRoot merkle root of the beacon block
    /// @param proof the beacon state root and merkle proof of its inclusion under `beaconBlockRoot`
    function verifyStateRoot(
        bytes32 beaconBlockRoot,
        StateRootProof calldata proof
    ) internal view {
        require(
            proof.proof.length == 32 * (BEACON_BLOCK_HEADER_TREE_HEIGHT),
            "BeaconChainProofs.verifyStateRoot: Proof has incorrect length"
        );

        /// This merkle proof verifies the `beaconStateRoot` under the `beaconBlockRoot`
        /// - beaconBlockRoot
        /// |                            HEIGHT: BEACON_BLOCK_HEADER_TREE_HEIGHT
        /// -- beaconStateRoot
        require(
            EigenlayerMerkle.verifyInclusionSha256({
                proof: proof.proof,
                root: beaconBlockRoot,
                leaf: proof.beaconStateRoot,
                index: STATE_ROOT_INDEX
            }),
            "BeaconChainProofs.verifyStateRoot: Invalid state root merkle proof"
        );
    }

    /// @notice Verify a merkle proof of a validator container against a `beaconStateRoot`
    /// @dev This proof starts at a validator's container root, proves through the validator container root,
    /// and continues proving to the root of the `BeaconState`
    /// @dev See https://eth2book.info/capella/part3/containers/dependencies/#validator for info on `Validator` containers
    /// @dev See https://eth2book.info/capella/part3/containers/state/#beaconstate for info on `BeaconState` containers
    /// @param beaconStateRoot merkle root of the `BeaconState` container
    /// @param validatorFields an individual validator's fields. These are merklized to form a `validatorRoot`,
    /// which is used as the leaf to prove against `beaconStateRoot`
    /// @param validatorFieldsProof a merkle proof of inclusion of `validatorFields` under `beaconStateRoot`
    /// @param validatorIndex the validator's unique index
    function verifyValidatorFields(
        bytes32 beaconStateRoot,
        bytes32[] calldata validatorFields,
        bytes calldata validatorFieldsProof,
        uint40 validatorIndex
    ) internal view {
        require(
            validatorFields.length == VALIDATOR_FIELDS_LENGTH,
            "BeaconChainProofs.verifyValidatorFields: Validator fields has incorrect length"
        );

        /// Note: the reason we use `VALIDATOR_TREE_HEIGHT + 1` here is because the merklization process for
        /// this container includes hashing the root of the validator tree with the length of the validator list
        require(
            validatorFieldsProof.length == 32 * ((VALIDATOR_TREE_HEIGHT + 1) + BEACON_STATE_TREE_HEIGHT),
            "BeaconChainProofs.verifyValidatorFields: Proof has incorrect length"
        );

        // Merkleize `validatorFields` to get the leaf to prove
        bytes32 validatorRoot = EigenlayerMerkle.merkleizeSha256(validatorFields);

        /// This proof combines two proofs, so its index accounts for the relative position of leaves in two trees:
        /// - beaconStateRoot
        /// |                            HEIGHT: BEACON_STATE_TREE_HEIGHT
        /// -- validatorContainerRoot
        /// |                            HEIGHT: VALIDATOR_TREE_HEIGHT + 1
        /// ---- validatorRoot
        uint256 index = (VALIDATOR_CONTAINER_INDEX << (VALIDATOR_TREE_HEIGHT + 1)) | uint256(validatorIndex);

        require(
            EigenlayerMerkle.verifyInclusionSha256({
                proof: validatorFieldsProof,
                root: beaconStateRoot,
                leaf: validatorRoot,
                index: index
            }),
            "BeaconChainProofs.verifyValidatorFields: Invalid merkle proof"
        );
    }

    /*******************************************************************************
             VALIDATOR BALANCE -> BALANCE CONTAINER ROOT -> BEACON BLOCK ROOT
    *******************************************************************************/

    /// @notice Verify a merkle proof of the beacon state's balances container against the beacon block root
    /// @dev This proof starts at the balance container root, proves through the beacon state root, and
    /// continues proving through the beacon block root. As a result, this proof will contain elements
    /// of a `StateRootProof` under the same block root, with the addition of proving the balances field
    /// within the beacon state.
    /// @dev This is used to make checkpoint proofs more efficient, as a checkpoint will verify multiple balances
    /// against the same balance container root.
    /// @param beaconBlockRoot merkle root of the beacon block
    /// @param proof a beacon balance container root and merkle proof of its inclusion under `beaconBlockRoot`
    function verifyBalanceContainer(
        bytes32 beaconBlockRoot,
        BalanceContainerProof calldata proof
    ) internal view {
        require(
            proof.proof.length == 32 * (BEACON_BLOCK_HEADER_TREE_HEIGHT + BEACON_STATE_TREE_HEIGHT),
            "BeaconChainProofs.verifyBalanceContainer: Proof has incorrect length"
        );

        /// This proof combines two proofs, so its index accounts for the relative position of leaves in two trees:
        /// - beaconBlockRoot
        /// |                            HEIGHT: BEACON_BLOCK_HEADER_TREE_HEIGHT
        /// -- beaconStateRoot
        /// |                            HEIGHT: BEACON_STATE_TREE_HEIGHT
        /// ---- balancesContainerRoot
        uint256 index = (STATE_ROOT_INDEX << (BEACON_STATE_TREE_HEIGHT)) | BALANCE_CONTAINER_INDEX;
        
        require(
            EigenlayerMerkle.verifyInclusionSha256({
                proof: proof.proof,
                root: beaconBlockRoot,
                leaf: proof.balanceContainerRoot,
                index: index
            }),
            "BeaconChainProofs.verifyBalanceContainer: invalid balance container proof"
        );
    }

    /// @notice Verify a merkle proof of a validator's balance against the beacon state's `balanceContainerRoot`
    /// @param balanceContainerRoot the merkle root of all validators' current balances
    /// @param validatorIndex the index of the validator whose balance we are proving
    /// @param proof the validator's associated balance root and a merkle proof of inclusion under `balanceContainerRoot`
    /// @return validatorBalanceGwei the validator's current balance (in gwei)
    function verifyValidatorBalance(
        bytes32 balanceContainerRoot,
        uint40 validatorIndex,
        BalanceProof calldata proof
    ) internal view returns (uint64 validatorBalanceGwei) {
        /// Note: the reason we use `BALANCE_TREE_HEIGHT + 1` here is because the merklization process for
        /// this container includes hashing the root of the balances tree with the length of the balances list
        require(
            proof.proof.length == 32 * (BALANCE_TREE_HEIGHT + 1),
            "BeaconChainProofs.verifyValidatorBalance: Proof has incorrect length"
        );

        /// When merkleized, beacon chain balances are combined into groups of 4 called a `balanceRoot`. The merkle
        /// proof here verifies that this validator's `balanceRoot` is included in the `balanceContainerRoot`
        /// - balanceContainerRoot
        /// |                            HEIGHT: BALANCE_TREE_HEIGHT
        /// -- balanceRoot
        uint256 balanceIndex = uint256(validatorIndex / 4);
 
        require(
            EigenlayerMerkle.verifyInclusionSha256({
                proof: proof.proof,
                root: balanceContainerRoot,
                leaf: proof.balanceRoot,
                index: balanceIndex
            }),
            "BeaconChainProofs.verifyValidatorBalance: Invalid merkle proof"
        );

        /// Extract the individual validator's balance from the `balanceRoot`
        return getBalanceAtIndex(proof.balanceRoot, validatorIndex);
    }

    /**
     * @notice Parses a balanceRoot to get the uint64 balance of a validator.  
     * @dev During merkleization of the beacon state balance tree, four uint64 values are treated as a single 
     * leaf in the merkle tree. We use validatorIndex % 4 to determine which of the four uint64 values to 
     * extract from the balanceRoot.
     * @param balanceRoot is the combination of 4 validator balances being proven for
     * @param validatorIndex is the index of the validator being proven for
     * @return The validator's balance, in Gwei
     */
    function getBalanceAtIndex(bytes32 balanceRoot, uint40 validatorIndex) internal pure returns (uint64) {
        uint256 bitShiftAmount = (validatorIndex % 4) * 64;
        return 
            Endian.fromLittleEndianUint64(bytes32((uint256(balanceRoot) << bitShiftAmount)));
    }

    /// @notice Indices for fields in the `Validator` container:
    /// 0: pubkey
    /// 1: withdrawal credentials
    /// 2: effective balance
    /// 3: slashed?
    /// 4: activation elligibility epoch
    /// 5: activation epoch
    /// 6: exit epoch
    /// 7: withdrawable epoch
    ///
    /// (See https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#validator)

    /// @dev Retrieves a validator's pubkey hash
    function getPubkeyHash(bytes32[] memory validatorFields) internal pure returns (bytes32) {
        return 
            validatorFields[VALIDATOR_PUBKEY_INDEX];
    }

    /// @dev Retrieves a validator's withdrawal credentials
    function getWithdrawalCredentials(bytes32[] memory validatorFields) internal pure returns (bytes32) {
        return
            validatorFields[VALIDATOR_WITHDRAWAL_CREDENTIALS_INDEX];
    }

    /// @dev Retrieves a validator's effective balance (in gwei)
    function getEffectiveBalanceGwei(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return 
            Endian.fromLittleEndianUint64(validatorFields[VALIDATOR_BALANCE_INDEX]);
    }

    /// @dev Retrieves true IFF a validator is marked slashed
    function isValidatorSlashed(bytes32[] memory validatorFields) internal pure returns (bool) {
        return validatorFields[VALIDATOR_SLASHED_INDEX] != 0;
    }

    /// @dev Retrieves a validator's exit epoch
    function getExitEpoch(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return 
            Endian.fromLittleEndianUint64(validatorFields[VALIDATOR_EXIT_EPOCH_INDEX]);
    }
}

// File: src/interfaces/eigenlayer-interfaces/IEigenPod.sol

pragma solidity >=0.5.0;







interface IEigenPodErrors {
    /// @dev Thrown when msg.sender is not the EPM.
    error OnlyEigenPodManager();
    /// @dev Thrown when msg.sender is not the pod owner.
    error OnlyEigenPodOwner();
    /// @dev Thrown when msg.sender is not owner or the proof submitter.
    error OnlyEigenPodOwnerOrProofSubmitter();
    /// @dev Thrown when attempting an action that is currently paused.
    error CurrentlyPaused();

    /// Invalid Inputs

    /// @dev Thrown when an address of zero is provided.
    error InputAddressZero();
    /// @dev Thrown when two array parameters have mismatching lengths.
    error InputArrayLengthMismatch();
    /// @dev Thrown when `validatorPubKey` length is not equal to 48-bytes.
    error InvalidPubKeyLength();
    /// @dev Thrown when provided timestamp is out of range.
    error TimestampOutOfRange();

    /// Checkpoints

    /// @dev Thrown when no active checkpoints are found.
    error NoActiveCheckpoint();
    /// @dev Thrown if an uncompleted checkpoint exists.
    error CheckpointAlreadyActive();
    /// @dev Thrown if there's not a balance available to checkpoint.
    error NoBalanceToCheckpoint();
    /// @dev Thrown when attempting to create a checkpoint twice within a given block.
    error CannotCheckpointTwiceInSingleBlock();

    /// Withdrawing

    /// @dev Thrown when amount exceeds `restakedExecutionLayerGwei`.
    error InsufficientWithdrawableBalance();

    /// Validator Status

    /// @dev Thrown when a validator's withdrawal credentials have already been verified.
    error CredentialsAlreadyVerified();
    /// @dev Thrown if the provided proof is not valid for this EigenPod.
    error WithdrawalCredentialsNotForEigenPod();
    /// @dev Thrown when a validator is not in the ACTIVE status in the pod.
    error ValidatorNotActiveInPod();
    /// @dev Thrown when validator is not active yet on the beacon chain.
    error ValidatorInactiveOnBeaconChain();
    /// @dev Thrown if a validator is exiting the beacon chain.
    error ValidatorIsExitingBeaconChain();
    /// @dev Thrown when a validator has not been slashed on the beacon chain.
    error ValidatorNotSlashedOnBeaconChain();

    /// Misc

    /// @dev Thrown when an invalid block root is returned by the EIP-4788 oracle.
    error InvalidEIP4788Response();
    /// @dev Thrown when attempting to send an invalid amount to the beacon deposit contract.
    error MsgValueNot32ETH();
    /// @dev Thrown when provided `beaconTimestamp` is too far in the past.
    error BeaconTimestampTooFarInPast();
    /// @dev Thrown when the pectraForkTimestamp returned from the EigenPodManager is zero
    error ForkTimestampZero();
}

interface IEigenPodTypes {
    enum VALIDATOR_STATUS {
        INACTIVE, // doesnt exist
        ACTIVE, // staked on ethpos and withdrawal credentials are pointed to the EigenPod
        WITHDRAWN // withdrawn from the Beacon Chain

    }

    struct ValidatorInfo {
        // index of the validator in the beacon chain
        uint64 validatorIndex;
        // amount of beacon chain ETH restaked on EigenLayer in gwei
        uint64 restakedBalanceGwei;
        //timestamp of the validator's most recent balance update
        uint64 lastCheckpointedAt;
        // status of the validator
        VALIDATOR_STATUS status;
    }

    struct Checkpoint {
        bytes32 beaconBlockRoot;
        uint24 proofsRemaining;
        uint64 podBalanceGwei;
        int64 balanceDeltasGwei;
        uint64 prevBeaconBalanceGwei;
    }

    /**
     * @param pubkey the pubkey of the validator to withdraw from
     * @param amountGwei the amount (in gwei) to withdraw from the beacon chain to the pod
     * @dev Note that if amountGwei == 0, this is a "full exit request," and will fully exit
     * the validator to the pod.
     * For more notes on usage, see `requestWithdrawal`
     */
    struct WithdrawalRequest {
        bytes pubkey;
        uint64 amountGwei;
    }

    /**
     * @param srcPubkey the pubkey of the source validator for the consolidation
     * @param targetPubkey the pubkey of the target validator for the consolidation
     * @dev Note that if srcPubkey == targetPubkey, this is a "switch request," and will
     * change the validator's withdrawal credential type from 0x01 to 0x02.
     * For more notes on usage, see `requestConsolidation`
     */
    struct ConsolidationRequest {
        bytes srcPubkey;
        bytes targetPubkey;
    }
}

interface IEigenPodEvents is IEigenPodTypes {
    /// @notice Emitted when an ETH validator stakes via this eigenPod
    event EigenPodStaked(bytes32 pubkeyHash);

    /// @notice Emitted when a pod owner updates the proof submitter address
    event ProofSubmitterUpdated(address prevProofSubmitter, address newProofSubmitter);

    /// @notice Emitted when an ETH validator's withdrawal credentials are successfully verified to be pointed to this eigenPod
    event ValidatorRestaked(bytes32 pubkeyHash);

    /// @notice Emitted when an ETH validator's  balance is proven to be updated.  Here newValidatorBalanceGwei
    //  is the validator's balance that is credited on EigenLayer.
    event ValidatorBalanceUpdated(bytes32 pubkeyHash, uint64 balanceTimestamp, uint64 newValidatorBalanceGwei);

    /// @notice Emitted when restaked beacon chain ETH is withdrawn from the eigenPod.
    event RestakedBeaconChainETHWithdrawn(address indexed recipient, uint256 amount);

    /// @notice Emitted when ETH is received via the `receive` fallback
    event NonBeaconChainETHReceived(uint256 amountReceived);

    /// @notice Emitted when a checkpoint is created
    event CheckpointCreated(
        uint64 indexed checkpointTimestamp, bytes32 indexed beaconBlockRoot, uint256 validatorCount
    );

    /// @notice Emitted when a checkpoint is finalized
    event CheckpointFinalized(uint64 indexed checkpointTimestamp, int256 totalShareDeltaWei);

    /// @notice Emitted when a validator is proven for a given checkpoint
    event ValidatorCheckpointed(uint64 indexed checkpointTimestamp, bytes32 indexed pubkeyHash);

    /// @notice Emitted when a validaor is proven to have 0 balance at a given checkpoint
    event ValidatorWithdrawn(uint64 indexed checkpointTimestamp, uint40 indexed validatorIndex);

    /// @notice Emitted when a withdrawal request is initiated where request.amountGwei == 0
    event ExitRequested(bytes32 indexed validatorPubkeyHash);

    /// @notice Emitted when a partial withdrawal request is initiated
    event WithdrawalRequested(bytes32 indexed validatorPubkeyHash, uint64 withdrawalAmountGwei);

    /// @notice Emitted when a consolidation request is initiated where source == target
    event SwitchToCompoundingRequested(bytes32 indexed validatorPubkeyHash);

    /// @notice Emitted when a standard consolidation request is initiated
    event ConsolidationRequested(bytes32 indexed sourcePubkeyHash, bytes32 indexed targetPubkeyHash);

}

/**
 * @title The implementation contract used for restaking beacon chain ETH on EigenLayer
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @dev Note that all beacon chain balances are stored as gwei within the beacon chain datastructures. We choose
 *   to account balances in terms of gwei in the EigenPod contract and convert to wei when making calls to other contracts
 */
interface IEigenPod is IEigenPodErrors, IEigenPodEvents, ISemVerMixin {
    /// @notice Used to initialize the pointers to contracts crucial to the pod's functionality, in beacon proxy construction from EigenPodManager
    function initialize(
        address owner
    ) external;

    /// @notice Called by EigenPodManager when the owner wants to create another ETH validator.
    /// @dev This function only supports staking to a 0x01 validator. For compounding validators, please interact directly with the deposit contract.
    function stake(bytes calldata pubkey, bytes calldata signature, bytes32 depositDataRoot) external payable;

    /**
     * @notice Transfers `amountWei` in ether from this contract to the specified `recipient` address
     * @notice Called by EigenPodManager to withdrawBeaconChainETH that has been added to the EigenPod's balance due to a withdrawal from the beacon chain.
     * @dev The podOwner must have already proved sufficient withdrawals, so that this pod's `restakedExecutionLayerGwei` exceeds the
     * `amountWei` input (when converted to GWEI).
     * @dev Reverts if `amountWei` is not a whole Gwei amount
     */
    function withdrawRestakedBeaconChainETH(address recipient, uint256 amount) external;

    /**
     * @dev Create a checkpoint used to prove this pod's active validator set. Checkpoints are completed
     * by submitting one checkpoint proof per ACTIVE validator. During the checkpoint process, the total
     * change in ACTIVE validator balance is tracked, and any validators with 0 balance are marked `WITHDRAWN`.
     * @dev Once finalized, the pod owner is awarded shares corresponding to:
     * - the total change in their ACTIVE validator balances
     * - any ETH in the pod not already awarded shares
     * @dev A checkpoint cannot be created if the pod already has an outstanding checkpoint. If
     * this is the case, the pod owner MUST complete the existing checkpoint before starting a new one.
     * @param revertIfNoBalance Forces a revert if the pod ETH balance is 0. This allows the pod owner
     * to prevent accidentally starting a checkpoint that will not increase their shares
     */
    function startCheckpoint(
        bool revertIfNoBalance
    ) external;

    /**
     * @dev Progress the current checkpoint towards completion by submitting one or more validator
     * checkpoint proofs. Anyone can call this method to submit proofs towards the current checkpoint.
     * For each validator proven, the current checkpoint's `proofsRemaining` decreases.
     * @dev If the checkpoint's `proofsRemaining` reaches 0, the checkpoint is finalized.
     * (see `_updateCheckpoint` for more details)
     * @dev This method can only be called when there is a currently-active checkpoint.
     * @param balanceContainerProof proves the beacon's current balance container root against a checkpoint's `beaconBlockRoot`
     * @param proofs Proofs for one or more validator current balances against the `balanceContainerRoot`
     */
    function verifyCheckpointProofs(
        BeaconChainProofs.BalanceContainerProof calldata balanceContainerProof,
        BeaconChainProofs.BalanceProof[] calldata proofs
    ) external;

    /**
     * @dev Verify one or more validators have their withdrawal credentials pointed at this EigenPod, and award
     * shares based on their effective balance. Proven validators are marked `ACTIVE` within the EigenPod, and
     * future checkpoint proofs will need to include them.
     * @dev Withdrawal credential proofs MUST NOT be older than `currentCheckpointTimestamp`.
     * @dev Validators proven via this method MUST NOT have an exit epoch set already.
     * @param beaconTimestamp the beacon chain timestamp sent to the 4788 oracle contract. Corresponds
     * to the parent beacon block root against which the proof is verified.
     * @param stateRootProof proves a beacon state root against a beacon block root
     * @param validatorIndices a list of validator indices being proven
     * @param validatorFieldsProofs proofs of each validator's `validatorFields` against the beacon state root
     * @param validatorFields the fields of the beacon chain "Validator" container. See consensus specs for
     * details: https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#validator
     */
    function verifyWithdrawalCredentials(
        uint64 beaconTimestamp,
        BeaconChainProofs.StateRootProof calldata stateRootProof,
        uint40[] calldata validatorIndices,
        bytes[] calldata validatorFieldsProofs,
        bytes32[][] calldata validatorFields
    ) external;

    /// @notice Allows the owner or proof submitter to initiate one or more requests to
    /// withdraw funds from validators on the beacon chain.
    /// @param requests An array of requests consisting of the source validator and an
    /// amount to withdraw
    /// @dev The withdrawal request predeploy requires a fee is sent with each request;
    /// this is pulled from msg.value. After submitting all requests, any remaining fee is
    /// refunded to the caller by calling its fallback function.
    /// @dev This contract exposes `getWithdrawalRequestFee` to query the current fee for
    /// a single request. If submitting multiple requests in a single block, the total fee
    /// is equal to (fee * requests.length). This fee is updated at the end of each block.
    ///
    /// (See https://eips.ethereum.org/EIPS/eip-7002#fee-update-rule for details)
    ///
    /// @dev Note on beacon chain behavior:
    /// - Withdrawal requests have two types: full exit requests, and partial exit requests.
    ///   Partial exit requests will be skipped if the validator has 0x01 withdrawal credentials.
    ///   If you want your validators to have access to partial exits, use `requestConsolidation`
    ///   to change their withdrawal credentials to compounding (0x02).
    /// - If request.amount == 0, this is a FULL exit request. A full exit request initiates a
    ///   standard validator exit.
    /// - Other amounts are treated as PARTIAL exit requests. A partial exit request will NOT result
    ///   in a validator with less than 32 ETH balance. Any requested amount above this is ignored.
    /// - The actual amount withdrawn for a partial exit is given by the formula:
    ///   min(request.amount, state.balances[vIdx] - 32 ETH - pending_balance_to_withdraw)
    ///   (where `pending_balance_to_withdraw` is the sum of any outstanding partial exit requests)
    ///   (Note that this means you may request more than is actually withdrawn!)
    ///
    /// @dev Note that withdrawal requests CAN FAIL for a variety of reasons. Failures occur when the request
    /// is processed on the beacon chain, and are invisible to the pod. The pod and predeploy cannot guarantee
    /// a request will succeed; it's up to the pod owner to determine this for themselves. If your request fails,
    /// you can retry by initiating another request via this method.
    ///
    /// Some requirements that are NOT checked by the pod:
    /// - request.pubkey MUST be a valid validator pubkey
    /// - request.pubkey MUST belong to a validator whose withdrawal credentials are this pod
    /// - If request.amount is for a partial exit, the validator MUST have 0x02 withdrawal credentials
    /// - If request.amount is for a full exit, the validator MUST NOT have any pending partial exits
    /// - The validator MUST be active and MUST NOT have initiated exit
    ///
    /// For further reference: https://github.com/ethereum/consensus-specs/blob/dev/specs/electra/beacon-chain.md#new-process_withdrawal_request
    function requestWithdrawal(
        WithdrawalRequest[] calldata requests
    ) external payable;

    /// @notice Allows the owner or proof submitter to initiate one or more consolidation requests.
    /// @param requests Array of consolidation requests consisting of source and target validator pubkeys
    /// @dev The consolidation request predeploy requires a fee is sent with each request;
    /// this is pulled from msg.value. After submitting all requests, any remaining fee is
    /// refunded to the caller by calling its fallback function.
    /// @dev This contract exposes `getConsolidationRequestFee` to query the current fee for
    /// a single request. If submitting multiple requests in a single block, the total fee
    /// is equal to (fee * requests.length). This fee is updated at the end of each block.
    ///
    /// (See https://eips.ethereum.org/EIPS/eip-7251#fee-calculation for details)
    ///
    /// @dev Note on beacon chain behavior:
    /// - If request.srcPubkey == request.targetPubkey, this is a "switch request" that converts
    ///   a validator's withdrawal credentials from 0x01 to 0x02 (compounding).
    /// - Otherwise, this consolidates multiple validators by transferring the source validator's
    ///   balance to the target validator and exiting the source validator.
    /// - Target validators for consolidation MUST have 0x02 withdrawal credentials.
    /// - Switch requests require the validator to have 0x01 withdrawal credentials.
    ///
    /// @dev Note that consolidation requests CAN FAIL for a variety of reasons. Failures occur when the request
    /// is processed on the beacon chain, and are invisible to the pod. The pod and predeploy cannot guarantee
    /// a request will succeed; it's up to the pod owner to determine this for themselves. If your request fails,
    /// you can retry by initiating another request via this method.
    ///
    /// Some requirements that are NOT checked by the pod:
    /// - request.srcPubkey MUST be a valid validator pubkey
    /// - request.srcPubkey MUST belong to a validator whose withdrawal credentials are this pod
    /// - If srcPubkey == targetPubkey, the validator MUST have 0x01 credentials
    /// - If srcPubkey != targetPubkey, the target validator MUST have 0x02 credentials
    /// - Both source and target validators MUST be active and MUST NOT have initiated exits
    /// - The source validator MUST NOT have pending partial withdrawal requests
    ///
    /// For further reference: https://github.com/ethereum/consensus-specs/blob/dev/specs/electra/beacon-chain.md#new-process_consolidation_request
    function requestConsolidation(
        ConsolidationRequest[] calldata requests
    ) external payable;

    /**
     * @dev Prove that one of this pod's active validators was slashed on the beacon chain. A successful
     * staleness proof allows the caller to start a checkpoint.
     *
     * @dev Note that in order to start a checkpoint, any existing checkpoint must already be completed!
     * (See `_startCheckpoint` for details)
     *
     * @dev Note that this method allows anyone to start a checkpoint as soon as a slashing occurs on the beacon
     * chain. This is intended to make it easier to external watchers to keep a pod's balance up to date.
     *
     * @dev Note too that beacon chain slashings are not instant. There is a delay between the initial slashing event
     * and the validator's final exit back to the execution layer. During this time, the validator's balance may or
     * may not drop further due to a correlation penalty. This method allows proof of a slashed validator
     * to initiate a checkpoint for as long as the validator remains on the beacon chain. Once the validator
     * has exited and been checkpointed at 0 balance, they are no longer "checkpoint-able" and cannot be proven
     * "stale" via this method.
     * See https://eth2book.info/capella/part3/transition/epoch/#slashings for more info.
     *
     * @param beaconTimestamp the beacon chain timestamp sent to the 4788 oracle contract. Corresponds
     * to the parent beacon block root against which the proof is verified.
     * @param stateRootProof proves a beacon state root against a beacon block root
     * @param proof the fields of the beacon chain "Validator" container, along with a merkle proof against
     * the beacon state root. See the consensus specs for more details:
     * https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#validator
     *
     * @dev Staleness conditions:
     * - Validator's last checkpoint is older than `beaconTimestamp`
     * - Validator MUST be in `ACTIVE` status in the pod
     * - Validator MUST be slashed on the beacon chain
     */
    function verifyStaleBalance(
        uint64 beaconTimestamp,
        BeaconChainProofs.StateRootProof calldata stateRootProof,
        BeaconChainProofs.ValidatorProof calldata proof
    ) external;

    /// @notice called by owner of a pod to remove any ERC20s deposited in the pod
    function recoverTokens(IERC20[] memory tokenList, uint256[] memory amountsToWithdraw, address recipient) external;

    /// @notice Allows the owner of a pod to update the proof submitter, a permissioned
    /// address that can call `startCheckpoint` and `verifyWithdrawalCredentials`.
    /// @dev Note that EITHER the podOwner OR proofSubmitter can access these methods,
    /// so it's fine to set your proofSubmitter to 0 if you want the podOwner to be the
    /// only address that can call these methods.
    /// @param newProofSubmitter The new proof submitter address. If set to 0, only the
    /// pod owner will be able to call `startCheckpoint` and `verifyWithdrawalCredentials`
    function setProofSubmitter(
        address newProofSubmitter
    ) external;

    /**
     *
     *                                VIEW METHODS
     *
     */

    /// @notice An address with permissions to call `startCheckpoint` and `verifyWithdrawalCredentials`, set
    /// by the podOwner. This role exists to allow a podOwner to designate a hot wallet that can call
    /// these methods, allowing the podOwner to remain a cold wallet that is only used to manage funds.
    /// @dev If this address is NOT set, only the podOwner can call `startCheckpoint` and `verifyWithdrawalCredentials`
    function proofSubmitter() external view returns (address);

    /// @notice the amount of execution layer ETH in this contract that is staked in EigenLayer (i.e. withdrawn from beaconchain but not EigenLayer),
    function withdrawableRestakedExecutionLayerGwei() external view returns (uint64);

    /// @notice The single EigenPodManager for EigenLayer
    function eigenPodManager() external view returns (IEigenPodManager);

    /// @notice The owner of this EigenPod
    function podOwner() external view returns (address);

    /// @notice Returns the validatorInfo struct for the provided pubkeyHash
    function validatorPubkeyHashToInfo(
        bytes32 validatorPubkeyHash
    ) external view returns (ValidatorInfo memory);

    /// @notice Returns the validatorInfo struct for the provided pubkey
    function validatorPubkeyToInfo(
        bytes calldata validatorPubkey
    ) external view returns (ValidatorInfo memory);

    /// @notice Returns the validator status for a given validator pubkey hash
    function validatorStatus(
        bytes32 pubkeyHash
    ) external view returns (VALIDATOR_STATUS);

    /// @notice Returns the validator status for a given validator pubkey
    function validatorStatus(
        bytes calldata validatorPubkey
    ) external view returns (VALIDATOR_STATUS);

    /// @notice Number of validators with proven withdrawal credentials, who do not have proven full withdrawals
    function activeValidatorCount() external view returns (uint256);

    /// @notice The timestamp of the last checkpoint finalized
    function lastCheckpointTimestamp() external view returns (uint64);

    /// @notice The timestamp of the currently-active checkpoint. Will be 0 if there is not active checkpoint
    function currentCheckpointTimestamp() external view returns (uint64);

    /// @notice Returns the currently-active checkpoint
    function currentCheckpoint() external view returns (Checkpoint memory);

    /// @notice Returns the current fee required to add a withdrawal request to the EIP-7002 predeploy.
    /// @dev Note that the predeploy updates its fee every block according to https://eips.ethereum.org/EIPS/eip-7002#fee-update-rule
    /// Consider overestimating the amount sent to ensure the fee does not update before your transaction.
    function getWithdrawalRequestFee() external view returns (uint256);

    /// @notice Returns the fee required to add a consolidation request to the EIP-7251 predeploy this block.
    /// @dev Note that the predeploy updates its fee every block according to https://eips.ethereum.org/EIPS/eip-7251#fee-calculation
    /// Consider overestimating the amount sent to ensure the fee does not update before your transaction.
    function getConsolidationRequestFee() external view returns (uint256);

    /// @notice For each checkpoint, the total balance attributed to exited validators, in gwei
    ///
    /// NOTE that the values added to this mapping are NOT guaranteed to capture the entirety of a validator's
    /// exit - rather, they capture the total change in a validator's balance when a checkpoint shows their
    /// balance change from nonzero to zero. While a change from nonzero to zero DOES guarantee that a validator
    /// has been fully exited, it is possible that the magnitude of this change does not capture what is
    /// typically thought of as a "full exit."
    ///
    /// For example:
    /// 1. Consider a validator was last checkpointed at 32 ETH before exiting. Once the exit has been processed,
    /// it is expected that the validator's exited balance is calculated to be `32 ETH`.
    /// 2. However, before `startCheckpoint` is called, a deposit is made to the validator for 1 ETH. The beacon
    /// chain will automatically withdraw this ETH, but not until the withdrawal sweep passes over the validator
    /// again. Until this occurs, the validator's current balance (used for checkpointing) is 1 ETH.
    /// 3. If `startCheckpoint` is called at this point, the balance delta calculated for this validator will be
    /// `-31 ETH`, and because the validator has a nonzero balance, it is not marked WITHDRAWN.
    /// 4. After the exit is processed by the beacon chain, a subsequent `startCheckpoint` and checkpoint proof
    /// will calculate a balance delta of `-1 ETH` and attribute a 1 ETH exit to the validator.
    ///
    /// If this edge case impacts your usecase, it should be possible to mitigate this by monitoring for deposits
    /// to your exited validators, and waiting to call `startCheckpoint` until those deposits have been automatically
    /// exited.
    ///
    /// Additional edge cases this mapping does not cover:
    /// - If a validator is slashed, their balance exited will reflect their original balance rather than the slashed amount
    /// - The final partial withdrawal for an exited validator will be likely be included in this mapping.
    ///   i.e. if a validator was last checkpointed at 32.1 ETH before exiting, the next checkpoint will calculate their
    ///   "exited" amount to be 32.1 ETH rather than 32 ETH.
    function checkpointBalanceExitedGwei(
        uint64
    ) external view returns (uint64);

    /// @notice Query the 4788 oracle to get the parent block root of the slot with the given `timestamp`
    /// @param timestamp of the block for which the parent block root will be returned. MUST correspond
    /// to an existing slot within the last 24 hours. If the slot at `timestamp` was skipped, this method
    /// will revert.
    function getParentBlockRoot(
        uint64 timestamp
    ) external view returns (bytes32);
}

// File: src/interfaces/eigenlayer-interfaces/IPausable.sol

pragma solidity >=0.5.0;



/**
 * @title Adds pausability to a contract, with pausing & unpausing controlled by the `pauser` and `unpauser` of a PauserRegistry contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Contracts that inherit from this contract may define their own `pause` and `unpause` (and/or related) functions.
 * These functions should be permissioned as "onlyPauser" which defers to a `PauserRegistry` for determining access control.
 * @dev Pausability is implemented using a uint256, which allows up to 256 different single bit-flags; each bit can potentially pause different functionality.
 * Inspiration for this was taken from the NearBridge design here https://etherscan.io/address/0x3FEFc5A4B1c02f21cBc8D3613643ba0635b9a873#code.
 * For the `pause` and `unpause` functions we've implemented, if you pause, you can only flip (any number of) switches to on/1 (aka "paused"), and if you unpause,
 * you can only flip (any number of) switches to off/0 (aka "paused").
 * If you want a pauseXYZ function that just flips a single bit / "pausing flag", it will:
 * 1) 'bit-wise and' (aka `&`) a flag with the current paused state (as a uint256)
 * 2) update the paused state to this new value
 * @dev We note as well that we have chosen to identify flags by their *bit index* as opposed to their numerical value, so, e.g. defining `DEPOSITS_PAUSED = 3`
 * indicates specifically that if the *third bit* of `_paused` is flipped -- i.e. it is a '1' -- then deposits should be paused
 */
interface IPausable {
    /// @dev Thrown when caller is not pauser.
    error OnlyPauser();
    /// @dev Thrown when caller is not unpauser.
    error OnlyUnpauser();
    /// @dev Thrown when currently paused.
    error CurrentlyPaused();
    /// @dev Thrown when invalid `newPausedStatus` is provided.
    error InvalidNewPausedStatus();
    /// @dev Thrown when a null address input is provided.
    error InputAddressZero();

    /// @notice Emitted when the pause is triggered by `account`, and changed to `newPausedStatus`.
    event Paused(address indexed account, uint256 newPausedStatus);

    /// @notice Emitted when the pause is lifted by `account`, and changed to `newPausedStatus`.
    event Unpaused(address indexed account, uint256 newPausedStatus);

    /// @notice Address of the `PauserRegistry` contract that this contract defers to for determining access control (for pausing).
    function pauserRegistry() external view returns (IPauserRegistry);

    /**
     * @notice This function is used to pause an EigenLayer contract's functionality.
     * It is permissioned to the `pauser` address, which is expected to be a low threshold multisig.
     * @param newPausedStatus represents the new value for `_paused` to take, which means it may flip several bits at once.
     * @dev This function can only pause functionality, and thus cannot 'unflip' any bit in `_paused` from 1 to 0.
     */
    function pause(
        uint256 newPausedStatus
    ) external;

    /**
     * @notice Alias for `pause(type(uint256).max)`.
     */
    function pauseAll() external;

    /**
     * @notice This function is used to unpause an EigenLayer contract's functionality.
     * It is permissioned to the `unpauser` address, which is expected to be a high threshold multisig or governance contract.
     * @param newPausedStatus represents the new value for `_paused` to take, which means it may flip several bits at once.
     * @dev This function can only unpause functionality, and thus cannot 'flip' any bit in `_paused` from 0 to 1.
     */
    function unpause(
        uint256 newPausedStatus
    ) external;

    /// @notice Returns the current paused status as a uint256.
    function paused() external view returns (uint256);

    /// @notice Returns 'true' if the `indexed`th bit of `_paused` is 1, and 'false' otherwise
    function paused(
        uint8 index
    ) external view returns (bool);
}

// File: src/interfaces/eigenlayer-interfaces/IEigenPodManager.sol

pragma solidity >=0.5.0;










interface IEigenPodManagerErrors {
    /// @dev Thrown when caller is not a EigenPod.
    error OnlyEigenPod();
    /// @dev Thrown when caller is not DelegationManager.
    error OnlyDelegationManager();
    /// @dev Thrown when caller already has an EigenPod.
    error EigenPodAlreadyExists();
    /// @dev Thrown when shares is not a multiple of gwei.
    error SharesNotMultipleOfGwei();
    /// @dev Thrown when shares would result in a negative integer.
    error SharesNegative();
    /// @dev Thrown when the strategy is not the beaconChainETH strategy.
    error InvalidStrategy();
    /// @dev Thrown when the pods shares are negative and a beacon chain balance update is attempted.
    /// The podOwner should complete legacy withdrawal first.
    error LegacyWithdrawalsNotCompleted();
    /// @dev Thrown when caller is not the proof timestamp setter
    error OnlyProofTimestampSetter();
}

interface IEigenPodManagerEvents {
    /// @notice Emitted to notify the deployment of an EigenPod
    event PodDeployed(address indexed eigenPod, address indexed podOwner);

    /// @notice Emitted to notify a deposit of beacon chain ETH recorded in the strategy manager
    event BeaconChainETHDeposited(address indexed podOwner, uint256 amount);

    /// @notice Emitted when the balance of an EigenPod is updated
    event PodSharesUpdated(address indexed podOwner, int256 sharesDelta);

    /// @notice Emitted every time the total shares of a pod are updated
    event NewTotalShares(address indexed podOwner, int256 newTotalShares);

    /// @notice Emitted when a withdrawal of beacon chain ETH is completed
    event BeaconChainETHWithdrawalCompleted(
        address indexed podOwner,
        uint256 shares,
        uint96 nonce,
        address delegatedAddress,
        address withdrawer,
        bytes32 withdrawalRoot
    );

    /// @notice Emitted when a staker's beaconChainSlashingFactor is updated
    event BeaconChainSlashingFactorDecreased(
        address staker, uint64 prevBeaconChainSlashingFactor, uint64 newBeaconChainSlashingFactor
    );

    /// @notice Emitted when an operator is slashed and shares to be burned are increased
    event BurnableETHSharesIncreased(uint256 shares);

    /// @notice Emitted when the Pectra fork timestamp is updated
    event PectraForkTimestampSet(uint64 newPectraForkTimestamp);

    /// @notice Emitted when the proof timestamp setter is updated
    event ProofTimestampSetterSet(address newProofTimestampSetter);
}

interface IEigenPodManagerTypes {
    /**
     * @notice The amount of beacon chain slashing experienced by a pod owner as a proportion of WAD
     * @param isSet whether the slashingFactor has ever been updated. Used to distinguish between
     * a value of "0" and an uninitialized value.
     * @param slashingFactor the proportion of the pod owner's balance that has been decreased due to
     * slashing or other beacon chain balance decreases.
     * @dev NOTE: if !isSet, `slashingFactor` should be treated as WAD. `slashingFactor` is monotonically
     * decreasing and can hit 0 if fully slashed.
     */
    struct BeaconChainSlashingFactor {
        bool isSet;
        uint64 slashingFactor;
    }
}

/**
 * @title Interface for factory that creates and manages solo staking pods that have their withdrawal credentials pointed to EigenLayer.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 */
interface IEigenPodManager is
    IEigenPodManagerErrors,
    IEigenPodManagerEvents,
    IEigenPodManagerTypes,
    IShareManager,
    IPausable,
    ISemVerMixin
{
    /**
     * @notice Creates an EigenPod for the sender.
     * @dev Function will revert if the `msg.sender` already has an EigenPod.
     * @dev Returns EigenPod address
     */
    function createPod() external returns (address);

    /**
     * @notice Stakes for a new beacon chain validator on the sender's EigenPod.
     * Also creates an EigenPod for the sender if they don't have one already.
     * @param pubkey The 48 bytes public key of the beacon chain validator.
     * @param signature The validator's signature of the deposit data.
     * @param depositDataRoot The root/hash of the deposit data for the validator's deposit.
     */
    function stake(bytes calldata pubkey, bytes calldata signature, bytes32 depositDataRoot) external payable;

    /**
     * @notice Adds any positive share delta to the pod owner's deposit shares, and delegates them to the pod
     * owner's operator (if applicable). A negative share delta does NOT impact the pod owner's deposit shares,
     * but will reduce their beacon chain slashing factor and delegated shares accordingly.
     * @param podOwner is the pod owner whose balance is being updated.
     * @param prevRestakedBalanceWei is the total amount restaked through the pod before the balance update, including
     * any amount currently in the withdrawal queue.
     * @param balanceDeltaWei is the amount the balance changed
     * @dev Callable only by the podOwner's EigenPod contract.
     * @dev Reverts if `sharesDelta` is not a whole Gwei amount
     */
    function recordBeaconChainETHBalanceUpdate(
        address podOwner,
        uint256 prevRestakedBalanceWei,
        int256 balanceDeltaWei
    ) external;

    /// @notice Sets the address that can set proof timestamps
    function setProofTimestampSetter(
        address newProofTimestampSetter
    ) external;

    /// @notice Sets the Pectra fork timestamp, only callable by `proofTimestampSetter`
    function setPectraForkTimestamp(
        uint64 timestamp
    ) external;

    /// @notice Returns the address of the `podOwner`'s EigenPod if it has been deployed.
    function ownerToPod(
        address podOwner
    ) external view returns (IEigenPod);

    /// @notice Returns the address of the `podOwner`'s EigenPod (whether it is deployed yet or not).
    function getPod(
        address podOwner
    ) external view returns (IEigenPod);

    /// @notice The ETH2 Deposit Contract
    function ethPOS() external view returns (IETHPOSDeposit);

    /// @notice Beacon proxy to which the EigenPods point
    function eigenPodBeacon() external view returns (IBeacon);

    /// @notice Returns 'true' if the `podOwner` has created an EigenPod, and 'false' otherwise.
    function hasPod(
        address podOwner
    ) external view returns (bool);

    /// @notice Returns the number of EigenPods that have been created
    function numPods() external view returns (uint256);

    /**
     * @notice Mapping from Pod owner owner to the number of shares they have in the virtual beacon chain ETH strategy.
     * @dev The share amount can become negative. This is necessary to accommodate the fact that a pod owner's virtual beacon chain ETH shares can
     * decrease between the pod owner queuing and completing a withdrawal.
     * When the pod owner's shares would otherwise increase, this "deficit" is decreased first _instead_.
     * Likewise, when a withdrawal is completed, this "deficit" is decreased and the withdrawal amount is decreased; We can think of this
     * as the withdrawal "paying off the deficit".
     */
    function podOwnerDepositShares(
        address podOwner
    ) external view returns (int256);

    /// @notice returns canonical, virtual beaconChainETH strategy
    function beaconChainETHStrategy() external view returns (IStrategy);

    /**
     * @notice Returns the historical sum of proportional balance decreases a pod owner has experienced when
     * updating their pod's balance.
     */
    function beaconChainSlashingFactor(
        address staker
    ) external view returns (uint64);

    /// @notice Returns the accumulated amount of beacon chain ETH Strategy shares
    function burnableETHShares() external view returns (uint256);

    /// @notice Returns the timestamp of the Pectra hard fork
    /// @dev Specifically, this returns the timestamp of the first non-missed slot at or after the Pectra hard fork
    function pectraForkTimestamp() external view returns (uint64);
}

// File: src/interfaces/eigenlayer-interfaces/IStrategyManager.sol

pragma solidity >=0.5.0;







interface IStrategyManagerErrors {
    /// @dev Thrown when total strategies deployed exceeds max.
    error MaxStrategiesExceeded();
    /// @dev Thrown when call attempted from address that's not delegation manager.
    error OnlyDelegationManager();
    /// @dev Thrown when call attempted from address that's not strategy whitelister.
    error OnlyStrategyWhitelister();
    /// @dev Thrown when provided `shares` amount is too high.
    error SharesAmountTooHigh();
    /// @dev Thrown when provided `shares` amount is zero.
    error SharesAmountZero();
    /// @dev Thrown when provided `staker` address is null.
    error StakerAddressZero();
    /// @dev Thrown when provided `strategy` not found.
    error StrategyNotFound();
    /// @dev Thrown when attempting to deposit to a non-whitelisted strategy.
    error StrategyNotWhitelisted();
}

interface IStrategyManagerEvents {
    /**
     * @notice Emitted when a new deposit occurs on behalf of `staker`.
     * @param staker Is the staker who is depositing funds into EigenLayer.
     * @param strategy Is the strategy that `staker` has deposited into.
     * @param shares Is the number of new shares `staker` has been granted in `strategy`.
     */
    event Deposit(address staker, IStrategy strategy, uint256 shares);

    /// @notice Emitted when the `strategyWhitelister` is changed
    event StrategyWhitelisterChanged(address previousAddress, address newAddress);

    /// @notice Emitted when a strategy is added to the approved list of strategies for deposit
    event StrategyAddedToDepositWhitelist(IStrategy strategy);

    /// @notice Emitted when a strategy is removed from the approved list of strategies for deposit
    event StrategyRemovedFromDepositWhitelist(IStrategy strategy);

    /// @notice Emitted when an operator is slashed and shares to be burned are increased
    event BurnableSharesIncreased(IStrategy strategy, uint256 shares);

    /// @notice Emitted when shares are burned
    event BurnableSharesDecreased(IStrategy strategy, uint256 shares);
}

/**
 * @title Interface for the primary entrypoint for funds into EigenLayer.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice See the `StrategyManager` contract itself for implementation details.
 */
interface IStrategyManager is IStrategyManagerErrors, IStrategyManagerEvents, IShareManager, ISemVerMixin {
    /**
     * @notice Initializes the strategy manager contract. Sets the `pauserRegistry` (currently **not** modifiable after being set),
     * and transfers contract ownership to the specified `initialOwner`.
     * @param initialOwner Ownership of this contract is transferred to this address.
     * @param initialStrategyWhitelister The initial value of `strategyWhitelister` to set.
     * @param initialPausedStatus The initial value of `_paused` to set.
     */
    function initialize(
        address initialOwner,
        address initialStrategyWhitelister,
        uint256 initialPausedStatus
    ) external;

    /**
     * @notice Deposits `amount` of `token` into the specified `strategy` and credits shares to the caller
     * @param strategy the strategy that handles `token`
     * @param token the token from which the `amount` will be transferred
     * @param amount the number of tokens to deposit
     * @return depositShares the number of deposit shares credited to the caller
     * @dev The caller must have previously approved this contract to transfer at least `amount` of `token` on their behalf.
     *
     * WARNING: Be extremely cautious when depositing tokens that do not strictly adhere to ERC20 standards.
     * Tokens that diverge significantly from ERC20 norms can cause unexpected behavior in token balances for
     * that strategy, e.g. ERC-777 tokens allowing cross-contract reentrancy.
     */
    function depositIntoStrategy(
        IStrategy strategy,
        IERC20 token,
        uint256 amount
    ) external returns (uint256 depositShares);

    /**
     * @notice Deposits `amount` of `token` into the specified `strategy` and credits shares to the `staker`
     * Note tokens are transferred from `msg.sender`, NOT from `staker`. This method allows the caller, using a
     * signature, to deposit their tokens to another staker's balance.
     * @param strategy the strategy that handles `token`
     * @param token the token from which the `amount` will be transferred
     * @param amount the number of tokens to transfer from the caller to the strategy
     * @param staker the staker that the deposited assets will be credited to
     * @param expiry the timestamp at which the signature expires
     * @param signature a valid ECDSA or EIP-1271 signature from `staker`
     * @return depositShares the number of deposit shares credited to `staker`
     * @dev The caller must have previously approved this contract to transfer at least `amount` of `token` on their behalf.
     *
     * WARNING: Be extremely cautious when depositing tokens that do not strictly adhere to ERC20 standards.
     * Tokens that diverge significantly from ERC20 norms can cause unexpected behavior in token balances for
     * that strategy, e.g. ERC-777 tokens allowing cross-contract reentrancy.
     */
    function depositIntoStrategyWithSignature(
        IStrategy strategy,
        IERC20 token,
        uint256 amount,
        address staker,
        uint256 expiry,
        bytes memory signature
    ) external returns (uint256 depositShares);

    /**
     * @notice Burns Strategy shares for the given strategy by calling into the strategy to transfer
     * to the default burn address.
     * @param strategy The strategy to burn shares in.
     */
    function burnShares(
        IStrategy strategy
    ) external;

    /**
     * @notice Owner-only function to change the `strategyWhitelister` address.
     * @param newStrategyWhitelister new address for the `strategyWhitelister`.
     */
    function setStrategyWhitelister(
        address newStrategyWhitelister
    ) external;

    /**
     * @notice Owner-only function that adds the provided Strategies to the 'whitelist' of strategies that stakers can deposit into
     * @param strategiesToWhitelist Strategies that will be added to the `strategyIsWhitelistedForDeposit` mapping (if they aren't in it already)
     */
    function addStrategiesToDepositWhitelist(
        IStrategy[] calldata strategiesToWhitelist
    ) external;

    /**
     * @notice Owner-only function that removes the provided Strategies from the 'whitelist' of strategies that stakers can deposit into
     * @param strategiesToRemoveFromWhitelist Strategies that will be removed to the `strategyIsWhitelistedForDeposit` mapping (if they are in it)
     */
    function removeStrategiesFromDepositWhitelist(
        IStrategy[] calldata strategiesToRemoveFromWhitelist
    ) external;

    /// @notice Returns bool for whether or not `strategy` is whitelisted for deposit
    function strategyIsWhitelistedForDeposit(
        IStrategy strategy
    ) external view returns (bool);

    /**
     * @notice Get all details on the staker's deposits and corresponding shares
     * @return (staker's strategies, shares in these strategies)
     */
    function getDeposits(
        address staker
    ) external view returns (IStrategy[] memory, uint256[] memory);

    function getStakerStrategyList(
        address staker
    ) external view returns (IStrategy[] memory);

    /// @notice Simple getter function that returns `stakerStrategyList[staker].length`.
    function stakerStrategyListLength(
        address staker
    ) external view returns (uint256);

    /// @notice Returns the current shares of `user` in `strategy`
    function stakerDepositShares(address user, IStrategy strategy) external view returns (uint256 shares);

    /// @notice Returns the single, central Delegation contract of EigenLayer
    function delegation() external view returns (IDelegationManager);

    /// @notice Returns the address of the `strategyWhitelister`
    function strategyWhitelister() external view returns (address);

    /// @notice Returns the burnable shares of a strategy
    function getBurnableShares(
        IStrategy strategy
    ) external view returns (uint256);

    /**
     * @notice Gets every strategy with burnable shares and the amount of burnable shares in each said strategy
     *
     * WARNING: This operation can copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Users should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function getStrategiesWithBurnableShares() external view returns (address[] memory, uint256[] memory);

    /**
     * @param staker The address of the staker.
     * @param strategy The strategy to deposit into.
     * @param token The token to deposit.
     * @param amount The amount of `token` to deposit.
     * @param nonce The nonce of the staker.
     * @param expiry The expiry of the signature.
     * @return The EIP-712 signable digest hash.
     */
    function calculateStrategyDepositDigestHash(
        address staker,
        IStrategy strategy,
        IERC20 token,
        uint256 amount,
        uint256 nonce,
        uint256 expiry
    ) external view returns (bytes32);
}

// File: src/governance/interfaces/IRoleRegistry.sol

pragma solidity ^0.8.24;

/**
 * @title IRoleRegistry
 * @notice Interface for the RoleRegistry contract
 * @dev Defines the external interface for RoleRegistry with role management functions
 * @author ether.fi
 */
interface IRoleRegistry {
    /**
     * @dev Error thrown when a function is called by an account without the protocol upgrader role
     */
    error OnlyProtocolUpgrader();

    /**
     * @dev Error thrown when a function is called by an account without the upgrade timelock role
     */
    error OnlyUpgradeTimelock();

    /**
     * @notice Returns the maximum allowed role value
     * @dev This is used by EnumerableRoles._validateRole to ensure roles are within valid range
     * @return The maximum role value
     */
    function MAX_ROLE() external pure returns (uint256);

    /**
     * @notice Initializes the contract with the specified owner
     * @param _owner The address that will be set as the initial owner
     */
    function initialize(address _owner) external;

    /**
     * @notice Checks if an account has any of the specified roles
     * @dev Reverts if the account doesn't have at least one of the roles
     * @param account The address to check roles for
     * @param encodedRoles ABI encoded roles (abi.encode(ROLE_1, ROLE_2, ...))
     */
    function checkRoles(address account, bytes memory encodedRoles) external view;

    /**
     * @notice Checks if an account has a specific role
     * @param role The role to check (as bytes32)
     * @param account The address to check the role for
     * @return bool True if the account has the role, false otherwise
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @notice Grants a role to an account
     * @dev Only callable by the contract owner
     * @param role The role to grant (as bytes32)
     * @param account The address to grant the role to
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @notice Revokes a role from an account
     * @dev Only callable by the contract owner
     * @param role The role to revoke (as bytes32)
     * @param account The address to revoke the role from
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @notice Revokes a role from an account quickly
     * @dev Only callable by the revoke admin
     * @param role The role to revoke (as bytes32)
     * @param account The address to revoke the role from
     */
    function revokeFast(bytes32 role, address account) external;

    /**
     * @notice Gets all addresses that have a specific role
     * @dev Wrapper around EnumerableRoles roleHolders function
     * @param role The role to query (as bytes32)
     * @return Array of addresses that have the specified role
     */
    function roleHolders(bytes32 role) external view returns (address[] memory);

    /**
     * @notice Checks if an account is the protocol upgrader
     * @dev Reverts if the account is not the protocol upgrader
     * @param account The address to check
     */
    function onlyProtocolUpgrader(address account) external view;

    /**
     * @notice Checks if an account is the upgrade timelock
     * @dev Reverts if the account is not the upgrade timelock
     * @param account The address to check
     */
    function onlyUpgradeTimelock(address account) external view;

    /**
     * @notice Checks if an account is the operating timelock
     * @dev Reverts if the account is not the operating timelock
     * @param account The address to check
     */
    function onlyOperatingTimelock(address account) external view;

    /**
     * @notice Checks if an account is the operating multisig
     * @dev Reverts if the account is not the operating multisig
     * @param account The address to check
     */
    function onlyOperatingMultisig(address account) external view;

    /**
     * @notice Checks if an account is the super guardian
     * @dev Reverts if the account is not the super guardian
     * @param account The address to check
     */
    function onlySuperGuardian(address account) external view;

    /**
     * @notice Checks if an account is the guardian
     * @dev Reverts if the account is not the guardian
     * @param account The address to check
     */
    function onlyGuardian(address account) external view;

    /**
     * @notice Checks if an account is the oracle operations
     * @dev Reverts if the account is not the oracle operations
     * @param account The address to check
     */
    function onlyOracleOperations(address account) external view;

    /**
     * @notice Checks if an account is the housekeeping operations
     * @dev Reverts if the account is not the housekeeping operations
     * @param account The address to check
     */
    function onlyHousekeepingOperations(address account) external view;

    /**
     * @notice Checks if an account is the executor operations
     * @dev Reverts if the account is not the executor operations
     * @param account The address to check
     */
    function onlyExecutorOperations(address account) external view;

    /**
     * @notice Checks if an account is the eigenpod operations
     * @dev Reverts if the account is not the eigenpod operations
     * @param account The address to check
     */
    function onlyEigenpodOperations(address account) external view;

    /**
     * @notice Returns the current owner of the contract
     * @return The address of the current owner
     */
    function owner() external view returns (address);

    function UPGRADE_TIMELOCK_ROLE() external view returns (bytes32);

    function OPERATION_TIMELOCK_ROLE() external view returns (bytes32);

    function OPERATION_MULTISIG_ROLE() external view returns (bytes32);

    function SUPER_GUARDIAN_ROLE() external view returns (bytes32);

    function GUARDIAN_ROLE() external view returns (bytes32);

    function ORACLE_OPERATIONS_ROLE() external view returns (bytes32);
    
    function HOUSEKEEPING_OPERATIONS_ROLE() external view returns (bytes32);

    function EXECUTOR_OPERATIONS_ROLE() external view returns (bytes32);

    function EIGENPOD_OPERATIONS_ROLE() external view returns (bytes32);
}

// File: src/deposits/interfaces/ILiquifier.sol

pragma solidity ^0.8.13;







// stETH-ETH mainnet: 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022
interface ICurvePool {
    function exchange_underlying(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external returns (uint256);
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);
    function get_virtual_price() external view returns (uint256);
}

interface ICurvePoolQuoter1 {
    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256); // stETH-ETH
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// mint forwarder: 0xfae23c30d383DF59D3E031C325a73d454e8721a6
// mainnet: 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704
interface IcbETH is IERC20 {
    function mint(address _to, uint256 _amount) external;
    function exchangeRate() external view returns (uint256 _exchangeRate);
}

// mainnet: 0xa2E3356610840701BDf5611a53974510Ae27E2e1
interface IwBETH is IERC20 {
    function deposit(address referral) payable external;
    function mint(address _to, uint256 _amount) external;
    function exchangeRate() external view returns (uint256 _exchangeRate);
}

// mainnet: 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84
interface ILido is IERC20 {
    function getTotalPooledEther() external view returns (uint256);
    function getTotalShares() external view returns (uint256);

    function submit(address _referral) external payable returns (uint256);
    function nonces(address _user) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via PancakeSwap V3
interface IPancackeV3SwapRouter {
    function WETH9() external returns (address);

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
    /// and swap the entire amount, enabling contracts to send tokens before calling this function.
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;
}

interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;
}

// mainnet: 0x858646372CC42E1A627fcE94aa7A7033e7CF075A
interface IEigenLayerStrategyManager is IStrategyManager {
    function withdrawalRootPending(bytes32 _withdrawalRoot) external view returns (bool);
    function numWithdrawalsQueued(address _user) external view returns (uint96);
    function pauserRegistry() external returns (IPauserRegistry);
    function paused(uint8 index) external view returns (bool);
    function unpause(uint256 newPausedStatus) external;

    // For testing
    function queueWithdrawal( uint256[] calldata strategyIndexes, IStrategy[] calldata strategies, uint256[] calldata shares, address withdrawer, bool undelegateIfPossible ) external returns(bytes32);
}

interface IEigenLayerStrategyTVLLimits is IStrategy {
    function getTVLLimits() external view returns (uint256, uint256);
    function setTVLLimits(uint256 newMaxPerDeposit, uint256 newMaxTotalDeposits) external;
    function pauserRegistry() external returns (IPauserRegistry);
    function paused(uint8 index) external view returns (bool);
    function unpause(uint256 newPausedStatus) external;
}

// mainnet: 0x889edC2eDab5f40e902b864aD4d7AdE8E412F9B1
interface ILidoWithdrawalQueue {
    struct WithdrawalRequestStatus {
        /// @notice stETH token amount that was locked on withdrawal queue for this request
        uint256 amountOfStETH;
        /// @notice amount of stETH shares locked on withdrawal queue for this request
        uint256 amountOfShares;
        /// @notice address that can claim or transfer this request
        address owner;
        /// @notice timestamp of when the request was created, in seconds
        uint256 timestamp;
        /// @notice true, if request is finalized
        bool isFinalized;
        /// @notice true, if request is claimed. Request is claimable if (isFinalized && !isClaimed)
        bool isClaimed;
    }

    function FINALIZE_ROLE() external view returns (bytes32);
    function MAX_STETH_WITHDRAWAL_AMOUNT() external view returns (uint256);
    function MIN_STETH_WITHDRAWAL_AMOUNT() external view returns (uint256);
    function requestWithdrawals(uint256[] calldata _amount, address _depositor) external returns (uint256[] memory);
    function claimWithdrawals(uint256[] calldata _requestIds, uint256[] calldata _hints) external;

    function finalize(uint256 _lastRequestIdToBeFinalized, uint256 _maxShareRate) external payable;
    function prefinalize(uint256[] calldata _batches, uint256 _maxShareRate) external view returns (uint256 ethToLock, uint256 sharesToBurn);

    function findCheckpointHints(uint256[] calldata _requestIds, uint256 _firstIndex, uint256 _lastIndex) external view returns (uint256[] memory hintIds);
    function getRoleMember(bytes32 _role, uint256 _index) external view returns (address);
    function getLastRequestId() external view returns (uint256);
    function getLastCheckpointIndex() external view returns (uint256);
    function getWithdrawalRequests(address _owner) external view returns (uint256[] memory requestsIds);
    function getWithdrawalStatus(uint256[] memory _requestIds) external view returns (WithdrawalRequestStatus[] memory statuses);
}

interface ILiquifier {
    
    struct PermitInput {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    } 

    struct TokenInfo {
        uint128 strategyShare;
        uint128 ethAmountPendingForWithdrawals;
        IStrategy strategy;
        bool isWhitelisted;
        uint16 discountInBasisPoints;
        uint32 timeBoundCapClockStartTime;
        uint32 timeBoundCapInEther;
        uint32 totalCapInEther;
        uint96 totalDepositedThisPeriod;
        uint96 totalDeposited;
        bool isL2Eth;
    }

    struct ConstructorAddresses {
        address liquidityPool;
        address lidoWithdrawalQueue;
        address lido;
        address stEth_Eth_Pool;
        address roleRegistry;
        address stEthPriceFeed;
        address blacklister;
        address etherfiRestaker;
        address l1SyncPool;
    }

    function lido() external view returns (ILido);
    function lidoWithdrawalQueue() external view returns (ILidoWithdrawalQueue);
    function tokenInfos(address _token) external view returns (uint128, uint128, IStrategy, bool, uint16, uint32, uint32, uint32, uint96, uint96, bool);

    function depositWithERC20(address _token, uint256 _amount, uint256 _minOutAmount, address _referral) external returns (uint256);
    function quoteByFairValue(address _token, uint256 _amount) external view returns (uint256);
}

// File: src/staking/interfaces/IEtherFiNode.sol

pragma solidity ^0.8.13;






interface IEtherFiNode {

    // eigenlayer
    function createEigenPod() external returns (address);
    function getEigenPod() external view returns (IEigenPod);
    function startCheckpoint() external;
    function setProofSubmitter(address newProofSubmitter) external;
    function verifyCheckpointProofs(BeaconChainProofs.BalanceContainerProof calldata balanceContainerProof, BeaconChainProofs.BalanceProof[] calldata proofs) external;
    function queueETHWithdrawal(uint256 amount) external returns (bytes32 withdrawalRoot);
    function completeQueuedETHWithdrawals(bool receiveAsTokens) external returns (uint256 balance);
    function queueWithdrawals(IDelegationManager.QueuedWithdrawalParams[] calldata params) external returns (bytes32[] memory withdrawalRoot);
    function completeQueuedWithdrawals(IDelegationManager.Withdrawal[] calldata withdrawals, IERC20[][] calldata tokens, bool[] calldata receiveAsTokens) external returns (uint256 balance);
    function sweepFunds() external returns (uint256 balance);
    function requestExecutionLayerTriggeredWithdrawal(IEigenPod.WithdrawalRequest[] calldata requests) external payable;
    function requestConsolidation(IEigenPod.ConsolidationRequest[] calldata requests) external payable;


    // call forwarding
    function forwardEigenPodCall(bytes memory data) external returns (bytes memory);
    function forwardExternalCall(address to, bytes memory data) external returns (bytes memory);

    struct LegacyNodeState {
        uint256[10] legacyPadding;
            /*
            ╭---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------╮
            | Name                                              | Type                              | Slot | Offset | Bytes | Contract                        |
            +=================================================================================================================================================+
            | etherFiNodesManager                               | address                           | 0    | 0      | 20    | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_localRevenueIndex                      | uint256                           | 1    | 0      | 32    | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_vestedAuctionRewards                   | uint256                           | 2    | 0      | 32    | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_ipfsHashForEncryptedValidatorKey       | string                            | 3    | 0      | 32    | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_exitRequestTimestamp                   | uint32                            | 4    | 0      | 4     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_exitTimestamp                          | uint32                            | 4    | 4      | 4     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_stakingStartTimestamp                  | uint32                            | 4    | 8      | 4     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_phase                                  | enum IEtherFiNode.VALIDATOR_PHASE | 4    | 12     | 1     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_restakingObservedExitBlock             | uint32                            | 4    | 13     | 4     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | eigenPod                                          | address                           | 5    | 0      | 20    | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | isRestakingEnabled                                | bool                              | 5    | 20     | 1     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | version                                           | uint16                            | 5    | 21     | 2     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | _numAssociatedValidators                          | uint16                            | 5    | 23     | 2     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | numExitRequestsByTnft                             | uint16                            | 5    | 25     | 2     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | numExitedValidators                               | uint16                            | 5    | 27     | 2     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | associatedValidatorIndices                        | mapping(uint256 => uint256)       | 6    | 0      | 32    | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | associatedValidatorIds                            | uint256[]                         | 7    | 0      | 32    | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_pendingWithdrawalFromRestakingInGwei   | uint64                            | 8    | 0      | 8     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_completedWithdrawalFromRestakingInGwei | uint64                            | 8    | 8      | 8     | src/EtherFiNode.sol:EtherFiNode |
            |---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------|
            | DEPRECATED_restakingObservedExitBlocks            | mapping(uint256 => uint32)        | 9    | 0      | 32    | src/EtherFiNode.sol:EtherFiNode |
            ╰---------------------------------------------------+-----------------------------------+------+--------+-------+---------------------------------╯
        */
    }

    //---------------------------------------------------------------------------
    //-----------------------------  Events  -----------------------------------
    //---------------------------------------------------------------------------

    event PartialWithdrawal(uint256 indexed _validatorId, address indexed etherFiNode, uint256 toOperator, uint256 toTnft, uint256 toBnft, uint256 toTreasury);
    event FullWithdrawal(uint256 indexed _validatorId, address indexed etherFiNode, uint256 toOperator, uint256 toTnft, uint256 toBnft, uint256 toTreasury);
    event QueuedRestakingWithdrawal(uint256 indexed _validatorId, address indexed etherFiNode, bytes32[] withdrawalRoots);
    event FundsTransferred(address indexed recipient, uint256 amount);

    //--------------------------------------------------------------------------
    //-----------------------------  Errors  -----------------------------------
    //--------------------------------------------------------------------------

    error TransferFailed();
    error ForwardedCallNotAllowed();
    error InvalidForwardedCall();
    error InvalidCaller();
    error NoCompleteableWithdrawals();

}

// File: src/staking/interfaces/IEtherFiNodesManager.sol

pragma solidity ^0.8.13;







interface IEtherFiNodesManager {

    function addressToWithdrawalCredentials(address addr) external pure returns (bytes memory);
    function addressToCompoundingWithdrawalCredentials(address addr) external pure returns (bytes memory);
    function etherfiNodeAddress(uint256 id) external view returns(address);
    function etherFiNodeFromPubkeyHash(bytes32 pubkeyHash) external view returns (IEtherFiNode);
    function linkPubkeyToNode(bytes calldata pubkey, address nodeAddress, uint256 legacyId) external;
    function calculateValidatorPubkeyHash(bytes memory pubkey) external pure returns (bytes32);

    function stakingManager() external view returns (IStakingManager);

    // eigenlayer interactions
    function createEigenPod(address node) external returns (address);
    function getEigenPod(uint256 id) external view returns (address);
    function getEigenPod(address node) external view returns (address);
    function startCheckpoint(uint256 id) external;
    function startCheckpoint(address node) external;
    function verifyCheckpointProofs(uint256 id, BeaconChainProofs.BalanceContainerProof calldata balanceContainerProof, BeaconChainProofs.BalanceProof[] calldata proofs) external;
    function verifyCheckpointProofs(address node, BeaconChainProofs.BalanceContainerProof calldata balanceContainerProof, BeaconChainProofs.BalanceProof[] calldata proofs) external;
    function setProofSubmitter(uint256 id, address newProofSubmitter) external;
    function setProofSubmitter(address node, address newProofSubmitter) external;
    function queueETHWithdrawal(uint256 id, uint256 amount) external returns (bytes32 withdrawalRoot);
    function queueETHWithdrawal(address node, uint256 amount) external returns (bytes32 withdrawalRoot);
    function completeQueuedETHWithdrawals(uint256 id, bool receiveAsTokens) external;
    function completeQueuedETHWithdrawals(address node, bool receiveAsTokens) external;
    function queueWithdrawals(uint256 id, IDelegationManager.QueuedWithdrawalParams[] calldata params) external;
    function queueWithdrawals(address node, IDelegationManager.QueuedWithdrawalParams[] calldata params) external;
    function completeQueuedWithdrawals(uint256 id, IDelegationManager.Withdrawal[] calldata withdrawals, IERC20[][] calldata tokens, bool[] calldata receiveAsTokens) external;
    function completeQueuedWithdrawals(address node, IDelegationManager.Withdrawal[] calldata withdrawals, IERC20[][] calldata tokens, bool[] calldata receiveAsTokens) external;
    function sweepFunds(uint256 id) external;
    //function sweepFunds(address node) external;
    function requestExecutionLayerTriggeredWithdrawal(IEigenPod.WithdrawalRequest[] calldata requests) external payable;
    function requestConsolidation(IEigenPod.ConsolidationRequest[] calldata requests) external payable;


    // rate limiting constants
    function UNRESTAKING_LIMIT_ID() external view returns (bytes32);
    function EXIT_REQUEST_LIMIT_ID() external view returns (bytes32);
    function CONSOLIDATION_REQUEST_LIMIT_ID() external view returns (bytes32);

    // call forwarding
    function updateAllowedForwardedExternalCalls(address user, bytes4 selector, address target, bool allowed) external;
    function updateAllowedForwardedEigenpodCalls(address user, bytes4 selector, bool allowed) external;
    function forwardExternalCall(address[] calldata nodes, bytes[] calldata data, address target) external returns (bytes[] memory returnData);
    function forwardEigenPodCall(address[] calldata nodes, bytes[] calldata data) external returns (bytes[] memory returnData);
    function allowedForwardedEigenpodCalls(address user, bytes4 selector) external view returns (bool);
    function allowedForwardedExternalCalls(address user, bytes4 selector, address to) external view returns (bool);


    struct LegacyNodesManagerState {
        uint256[4] legacyPadding1;
        // we are continuing to use this field in the short term before we fully transition to using pubkeyhash
        mapping(uint256 => address) DEPRECATED_etherfiNodeAddress;
        uint256[15] legacyPadding2;
        /*
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | numberOfValidators                        | uint64                                                        | 301  | 0      | 8     | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | nonExitPenaltyPrincipal                   | uint64                                                        | 301  | 8      | 8     | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | nonExitPenaltyDailyRate                   | uint64                                                        | 301  | 16     | 8     | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | SCALE                                     | uint64                                                        | 301  | 24     | 8     | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | treasuryContract                          | address                                                       | 302  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | stakingManagerContract                    | address                                                       | 303  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | DEPRECATED_protocolRevenueManagerContract | address                                                       | 304  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | etherfiNodeAddress                        | mapping(uint256 => address)                                   | 305  | 0      | 32    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | tnft                                      | contract TNFT                                                 | 306  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | bnft                                      | contract BNFT                                                 | 307  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | auctionManager                            | contract IAuctionManager                                      | 308  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | DEPRECATED_protocolRevenueManager         | contract IProtocolRevenueManager                              | 309  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | stakingRewardsSplit                       | struct IEtherFiNodesManager.RewardsSplit                      | 310  | 0      | 32    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | DEPRECATED_protocolRewardsSplit           | struct IEtherFiNodesManager.RewardsSplit                      | 311  | 0      | 32    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | DEPRECATED_admin                          | address                                                       | 312  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | admins                                    | mapping(address => bool)                                      | 313  | 0      | 32    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | eigenPodManager                           | contract IEigenPodManager                                     | 314  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | delayedWithdrawalRouter                   | contract IDelayedWithdrawalRouter                             | 315  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | maxEigenlayerWithdrawals                  | uint8                                                         | 315  | 20     | 1     | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | unusedWithdrawalSafes                     | address[]                                                     | 316  | 0      | 32    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | DEPRECATED_enableNodeRecycling            | bool                                                          | 317  | 0      | 1     | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | validatorInfos                            | mapping(uint256 => struct IEtherFiNodesManager.ValidatorInfo) | 318  | 0      | 32    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | delegationManager                         | contract IDelegationManager                                   | 319  | 0      | 20    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
            | operatingAdmin                            | mapping(address => bool)                                      | 320  | 0      | 32    | src/EtherFiNodesManager.sol:EtherFiNodesManager |
            |-------------------------------------------+---------------------------------------------------------------+------+--------+-------+-------------------------------------------------|
        */
    }

    //---------------------------------------------------------------------------
    //-----------------------------  Events  -----------------------------------
    //---------------------------------------------------------------------------

    event PubkeyLinked(bytes32 indexed pubkeyHash, address indexed nodeAddress, uint256 indexed legacyId, bytes pubkey);
    event UserAllowedForwardedExternalCallsUpdated(address indexed user, bytes4 indexed selector, address indexed _target, bool _allowed);
    event UserAllowedForwardedEigenpodCallsUpdated(address indexed user, bytes4 indexed selector, bool _allowed);
    event FundsTransferred(address indexed nodeAddress, uint256 amount);
    event ValidatorWithdrawalRequestSent(address indexed pod, bytes32 indexed validatorPubkeyHash, bytes validatorPubkey);
    event ValidatorSwitchToCompoundingRequested(address indexed pod, bytes32 indexed validatorPubkeyHash, bytes validatorPubkey);
    event ValidatorConsolidationRequested(address indexed pod, bytes32 indexed sourcePubkeyHash, bytes sourcePubkey, bytes32 targetPubkeyHash, bytes targetPubkey);

    //--------------------------------------------------------------------------
    //-----------------------------  Errors  -----------------------------------
    //--------------------------------------------------------------------------

    error AlreadyLinked();
    error UnknownNode();
    error InvalidPubKeyLength();
    error LengthMismatch();
    error InvalidCaller();
    error ForwardedCallNotAllowed();
    error InvalidForwardedCall();
    error EmptyWithdrawalsRequest();
    error EmptyConsolidationRequest();
    error InsufficientWithdrawalFees();
    error InsufficientConsolidationFees();
}

// File: src/governance/rate-limiting/libraries/BucketLimiter.sol

pragma solidity ^0.8.0;

/**
 * The BucketLimiter contract is used to limit the rate of some action.
 * 
 * Buckets refill at a constant rate, and have a maximum capacity. Each time
 * the consume function is called, the bucket gets depleted by the provided
 * amount. If the bucket is empty, the consume function will return false
 * and the bucket will not be depleted. Rates are measured in units per 
 * second.
 * 
 * To limit storage usage to a single slot, the Bucket struct is packed into
 * a single word, meaning all fields are uint64.
 *
 * Examples:
 *
 * ```sol
 * BucketLimiter.Limit storage limit = BucketLimiter.create(100, 1);
 * limit.consume(10); // returns true, remaining = 90
 * limit.consume(80); // returns true, remaining = 10
 * limit.consume(20); // returns false, remaining = 10
 * // Wait 10 seconds (10 tokens get refilled)
 * limit.consume(20); // returns true, remaining = 0)
 * // Increase capacity
 * limit.setCapacity(200); // remaining = 0, capacity = 200
 * // Increase refill rate
 * limit.setRefillRate(2); // remaining = 0, capacity = 200, refillRate = 2
 * // Wait 10 seconds (20 tokens get refilled)
 * limit.consume(20); // returns true, remaining = 0
 * ```
 * 
 * Developers should notice that rate-limits are vulnerable to two attacks:
 * 1. Sybil-attacks: Rate limits should typically be global across all user
 *       accounts, otherwise an attacker can simply create many accounts to
 *       bypass the rate limit.
 * 2. DoS attacks: Rate limits should typically apply to actions with a
 *       friction such as a fee or a minimum stake time. Otherwise, an
 *       attacker can simply spam the action to deplete the rate limit.
 */
library BucketLimiter {
    struct Limit {
        // The maximum capacity of the bucket, in consumable units (eg. tokens)
        uint64 capacity;
        // The remaining capacity in the bucket, that can be consumed
        uint64 remaining;
        // The timestamp of the last time the bucket was refilled
        uint64 lastRefill;
        // The rate at which the bucket refills, in units per second
        uint64 refillRate;
    }

    /*
     * Creates a new bucket with the given capacity and refill rate.
     * 
     * @param capacity The maximum capacity of the bucket, in consumable units (eg. tokens)
     * @param refillRate The rate at which the bucket refills, in units per second
     * @return The created bucket
     */
    function create(uint64 capacity, uint64 refillRate) internal view returns (Limit memory) {
        return Limit({
            capacity: capacity,
            remaining: capacity,
            lastRefill: uint64(block.timestamp),
            refillRate: refillRate
        });
    }

    function canConsume(Limit memory limit, uint64 amount) external view returns (bool) {
        _refill(limit);
        return limit.remaining >= amount;
    }

    function consumable(Limit memory limit) external view returns (uint64) {
        _refill(limit);
        return limit.remaining;
    }

    /*
     * Consumes the given amount from the bucket, if there is sufficient capacity, and returns
     * whether the bucket had enough remaining capacity to consume the amount.
     * 
     * @param limit The bucket to consume from
     * @param amount The amount to consume
     * @return True if the bucket had enough remaining capacity to consume the amount, false otherwise
     */
    function consume(Limit storage limit, uint64 amount) internal returns (bool) {
        Limit memory _limit = limit;
        _refill(_limit);
        if (_limit.remaining < amount) {
            return false;
        }
        limit.remaining = _limit.remaining - amount;
        limit.lastRefill = _limit.lastRefill;
        return true;
    }

    /*
     * Refills the bucket based on the time elapsed since the last refill. This effectively simulates
     * the idea of the bucket continuously refilling at a constant rate.
     * 
     * @param limit The bucket to refill
     */
    function refill(Limit storage limit) internal {
        Limit memory _limit = limit;
        _refill(_limit);
        limit.remaining = _limit.remaining;
        limit.lastRefill = _limit.lastRefill;
    }

    function _refill(Limit memory limit) internal view {
        uint64 now_ = uint64(block.timestamp);

        if (now_ == limit.lastRefill) {
            return;
        }

        uint256 delta;
        unchecked {
            delta = now_ - limit.lastRefill;
        }
        uint256 tokens = delta * uint256(limit.refillRate);
        uint256 newRemaining = uint256(limit.remaining) + tokens;
        if (newRemaining > limit.capacity) {
            limit.remaining = limit.capacity;
        } else {
            limit.remaining = uint64(newRemaining);
        }
        limit.lastRefill = now_;
    }

    /*
     * Sets the capacity of the bucket. If the new capacity is less than the remaining capacity,
     * the remaining capacity is set to the new capacity.
     * 
     * @param limit The bucket to set the capacity of
     * @param capacity The new capacity
     */
    function setCapacity(Limit storage limit, uint64 capacity) internal {
        refill(limit);
        limit.capacity = capacity;
        if (limit.remaining > capacity) {
            limit.remaining = capacity;
        }
    }

    /*
     * Sets the refill rate of the bucket, in units per second.
     *
     * @param limit The bucket to set the refill rate of
     * @param refillRate The new refill rate
     */
    function setRefillRate(Limit storage limit, uint64 refillRate) internal {
        refill(limit);
        limit.refillRate = refillRate;
    }

    /*
     * Sets the remaining capacity of the bucket. If the new remaining capacity is greater than
     * the capacity, the remaining capacity is set to the capacity.
     * 
     * @param limit The bucket to set the remaining capacity of
     * @param remaining The new remaining capacity
     */
    function setRemaining(Limit storage limit, uint64 remaining) internal {
        refill(limit);
        limit.remaining = remaining > limit.capacity ? limit.capacity : remaining;
    }
}

// File: src/withdrawals/interfaces/IEtherFiRedemptionManager.sol

pragma solidity ^0.8.13;



interface IEtherFiRedemptionManager {
    struct RedemptionInfo {
        BucketLimiter.Limit limit;
        uint16 exitFeeSplitToTreasuryInBps;
        uint16 exitFeeInBps;
        uint16 lowWatermarkInBpsOfTvl;
    }

    struct ConstructorAddresses {
        address liquidityPool;
        address eEth;
        address weEth;
        address treasury;
        address roleRegistry;
        address etherFiRestaker;
        address priorityWithdrawalQueue;
        address blacklister;
        address stEthPriceFeed;
    }

    function redeemEEth(uint256 eEthAmount, address receiver, address outputToken) external;
    function redeemWeEth(uint256 weEthAmount, address receiver, address outputToken) external;
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol

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

// File: src/core/interfaces/IWeETH.sol

pragma solidity ^0.8.13;





interface IWeETH is IERC20Upgradeable {

    struct PermitInput {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    } 
    
    // STATE VARIABLES
    function eETH() external view returns (IeETH);
    function liquidityPool() external view returns (ILiquidityPool);
    function whitelistedSpender(address spender) external view returns (bool);
    function blacklistedRecipient(address recipient) external view returns (bool);

    // STATE-CHANGING FUNCTIONS
    function initialize(address _liquidityPool, address _eETH) external;
    function wrap(uint256 _eETHAmount) external returns (uint256);
    function wrapWithPermit(uint256 _eETHAmount, ILiquidityPool.PermitInput calldata _permit) external returns (uint256);
    function unwrap(uint256 _weETHAmount) external returns (uint256);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function setWhitelistedSpender(address[] calldata _spenders, bool _isWhitelisted) external;
    function setBlacklistedRecipient(address[] calldata _recipients, bool _isBlacklisted) external;

    // GETTER FUNCTIONS
    function getWeETHByeETH(uint256 _eETHAmount) external view returns (uint256);
    function getEETHByWeETH(uint256 _weETHAmount) external view returns (uint256);
    function getRate() external view returns (uint256);
    function getImplementation() external view returns (address);

}

// File: src/withdrawals/interfaces/IPriorityWithdrawalQueue.sol

pragma solidity ^0.8.13;



interface IPriorityWithdrawalQueue {
    /// @notice Withdrawal request struct stored as hash in EnumerableSet
    /// @param user The user who created the request
    /// @param amountOfEEth Original eETH amount requested
    /// @param shareOfEEth eETH shares at time of request
    /// @param amountWithFee ETH amount the user receives after fee deduction (amountOfEEth - fee)
    /// @param nonce Unique nonce to prevent hash collisions
    /// @param creationTime Timestamp when request was created
    struct WithdrawRequest {
        address user;           // 20 bytes
        uint96 amountOfEEth;    // 12 bytes | Slot 1 = 32 bytes
        uint96 shareOfEEth;     // 12 bytes
        uint96 amountWithFee;    // 12 bytes
        uint32 nonce;           // 4 bytes
        uint32 creationTime;    // 4 bytes  | Slot 2 = 32 bytes
    }

    struct PermitInput {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    // User functions
    function requestWithdraw(uint96 amountOfEEth, uint96 amountWithFee) external returns (bytes32 requestId);
    function requestWithdrawWithPermit(uint96 amountOfEEth, uint96 amountWithFee, PermitInput calldata permit) external returns (bytes32 requestId);
    function requestWithdrawWithWeETH(uint96 weEthAmount, uint96 amountWithFee) external returns (bytes32 requestId);
    function requestWithdrawWithWeETHAndPermit(uint96 weEthAmount, uint96 amountWithFee, PermitInput calldata permit) external returns (bytes32 requestId);
    function weETH() external view returns (IWeETH);
    function cancelWithdraw(WithdrawRequest calldata request) external returns (bytes32 requestId);
    function claimWithdraw(WithdrawRequest calldata request) external;
    function batchClaimWithdraw(WithdrawRequest[] calldata requests) external;

    // View functions
    function getRequestId(WithdrawRequest calldata request) external pure returns (bytes32);
    function getRequestIds() external view returns (bytes32[] memory);
    function getClaimableAmount(WithdrawRequest calldata request) external view returns (uint256);
    function isWhitelisted(address user) external view returns (bool);
    function nonce() external view returns (uint32);
    function ethAmountLockedForPriorityWithdrawal() external view returns (uint128);

    // Constants
    function minDelay() external view returns (uint32);
    function MIN_AMOUNT() external view returns (uint96);

    // Oracle/Solver functions
    function fulfillRequests(WithdrawRequest[] calldata requests) external;

    // Admin functions
    function addToWhitelist(address user) external;
    function removeFromWhitelist(address user) external;
    function batchUpdateWhitelist(address[] calldata users, bool[] calldata statuses) external;
    function invalidateRequests(WithdrawRequest[] calldata requests) external returns(bytes32[] memory);
}

// File: src/governance/interfaces/IBlacklister.sol

pragma solidity ^0.8.27;

interface IBlacklister {
    function blacklistUser(address user) external;
    function unblacklistUser(address user) external;
    function nonBlacklisted(address user) external view;
}

// File: lib/solady/src/utils/ReentrancyGuardTransient.sol

pragma solidity ^0.8.24;

/// @notice Reentrancy guard mixin (transient storage variant).
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ReentrancyGuardTransient.sol)
///
/// @dev Note: This implementation utilizes the `TSTORE` and `TLOAD` opcodes.
/// Please ensure that the chain you are deploying on supports them.
abstract contract ReentrancyGuardTransient {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unauthorized reentrant call.
    error Reentrancy();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to: `uint32(bytes4(keccak256("Reentrancy()"))) | 1 << 71`.
    /// 9 bytes is large enough to avoid collisions in practice,
    /// but not too large to result in excessive bytecode bloat.
    uint256 private constant _REENTRANCY_GUARD_SLOT = 0x8000000000ab143c06;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      REENTRANCY GUARD                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Guards a function from reentrancy.
    modifier nonReentrant() virtual {
        if (_useTransientReentrancyGuardOnlyOnMainnet()) {
            uint256 s = _REENTRANCY_GUARD_SLOT;
            if (block.chainid == 1) {
                /// @solidity memory-safe-assembly
                assembly {
                    if tload(s) {
                        mstore(0x00, s) // `Reentrancy()`.
                        revert(0x1c, 0x04)
                    }
                    tstore(s, address())
                }
            } else {
                /// @solidity memory-safe-assembly
                assembly {
                    if eq(sload(s), address()) {
                        mstore(0x00, s) // `Reentrancy()`.
                        revert(0x1c, 0x04)
                    }
                    sstore(s, address())
                }
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                if tload(_REENTRANCY_GUARD_SLOT) {
                    mstore(0x00, 0xab143c06) // `Reentrancy()`.
                    revert(0x1c, 0x04)
                }
                tstore(_REENTRANCY_GUARD_SLOT, address())
            }
        }
        _;
        if (_useTransientReentrancyGuardOnlyOnMainnet()) {
            uint256 s = _REENTRANCY_GUARD_SLOT;
            if (block.chainid == 1) {
                /// @solidity memory-safe-assembly
                assembly {
                    tstore(s, 0)
                }
            } else {
                /// @solidity memory-safe-assembly
                assembly {
                    sstore(s, s)
                }
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                tstore(_REENTRANCY_GUARD_SLOT, 0)
            }
        }
    }

    /// @dev Guards a view function from read-only reentrancy.
    modifier nonReadReentrant() virtual {
        if (_useTransientReentrancyGuardOnlyOnMainnet()) {
            uint256 s = _REENTRANCY_GUARD_SLOT;
            if (block.chainid == 1) {
                /// @solidity memory-safe-assembly
                assembly {
                    if tload(s) {
                        mstore(0x00, s) // `Reentrancy()`.
                        revert(0x1c, 0x04)
                    }
                }
            } else {
                /// @solidity memory-safe-assembly
                assembly {
                    if eq(sload(s), address()) {
                        mstore(0x00, s) // `Reentrancy()`.
                        revert(0x1c, 0x04)
                    }
                }
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                if tload(_REENTRANCY_GUARD_SLOT) {
                    mstore(0x00, 0xab143c06) // `Reentrancy()`.
                    revert(0x1c, 0x04)
                }
            }
        }
        _;
    }

    /// @dev For widespread compatibility with L2s.
    /// Only Ethereum mainnet is expensive anyways.
    function _useTransientReentrancyGuardOnlyOnMainnet() internal view virtual returns (bool) {
        return true;
    }
}

// File: src/governance/utils/RolesLibrary.sol

pragma solidity ^0.8.27;



abstract contract RolesLibrary {
    //--------------------------------------------------------------------------------------
    //-----------------------------------  IMMUTABLES  -------------------------------------
    //--------------------------------------------------------------------------------------
    IRoleRegistry public immutable roleRegistry;

    //--------------------------------------------------------------------------------------
    //-----------------------------------  CONSTRUCTOR  -------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Constructor
     * @param _roleRegistry The address of the role registry
     */
    constructor(address _roleRegistry) {
        roleRegistry = IRoleRegistry(_roleRegistry);
    }

    //--------------------------------------------------------------------------------------
    //-----------------------------------  MODIFIERS  --------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Modifier to check if the caller is the upgrade timelock
     * @dev reverts with OnlyUpgradeTimelock if the caller is not the upgrade timelock
     */
    modifier onlyUpgradeTimelock() {
        roleRegistry.onlyUpgradeTimelock(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the operating timelock
     * @dev reverts with OnlyOperatingTimelock if the caller is not the operating timelock
     */
    modifier onlyOperatingTimelock() {
        roleRegistry.onlyOperatingTimelock(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the operating multisig
     * @dev reverts with OnlyOperatingMultisig if the caller is not the operating multisig
     */
    modifier onlyOperatingMultisig() {
        roleRegistry.onlyOperatingMultisig(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the super guardian
     * @dev reverts with OnlySuperGuardian if the caller is not the super guardian
     */
    modifier onlySuperGuardian() {
        roleRegistry.onlySuperGuardian(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the guardian
     * @dev reverts with OnlyGuardian if the caller is not the guardian
     */
    modifier onlyGuardian() {
        roleRegistry.onlyGuardian(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the oracle operations
     * @dev reverts with OnlyOracleOperations if the caller is not the oracle operations
     */
    modifier onlyOracleOperations() {
        roleRegistry.onlyOracleOperations(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the housekeeping operations
     * @dev reverts with OnlyHousekeepingOperations if the caller is not the housekeeping operations
     */
    modifier onlyHousekeepingOperations() {
        roleRegistry.onlyHousekeepingOperations(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the executor operations
     * @dev reverts with OnlyExecutorOperations if the caller is not the executor operations
     */
    modifier onlyExecutorOperations() {
        roleRegistry.onlyExecutorOperations(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the eigenpod operations
     * @dev reverts with OnlyEigenpodOperations if the caller is not the eigenpod operations
     */
    modifier onlyEigenpodOperations() {
        roleRegistry.onlyEigenpodOperations(msg.sender);
        _;
    }
}

// File: src/governance/utils/Pausable.sol

pragma solidity ^0.8.27;



/**
 * @title Pausable
 * @notice Shared, custom pausing base for all etherfi contracts. Replaces OpenZeppelin's
 *         `PausableUpgradeable`. Holds the paused flag in namespaced storage so it never
 *         collides with the inheriting contract's linear storage, and exposes a single
 *         `whenNotPaused` modifier as the only pause primitive contracts need to use.
 * @dev    Pause/unpause is gated by the operating multisig via {RolesLibrary}. The modifier
 *         is `virtual` so {PausableUntil} can extend it to also enforce the timed pause.
 */
abstract contract Pausable is RolesLibrary {
    //--------------------------------------------------------------------------------------
    //------------------------------  STORAGE STRUCT  --------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice PausableStorage
     * @param paused Whether the contract is indefinitely paused
     */
    struct PausableStorage {
        bool paused;
    }

    //--------------------------------------------------------------------------------------
    //-----------------------------------  CONSTANTS  --------------------------------------
    //--------------------------------------------------------------------------------------
    bytes32 private constant PAUSABLE_STORAGE_SLOT = 0x78b0b9eaa76f2f3afc4ee6c17ac4a6b5c1dfd190bc39879fb866c5b50b872744; // keccak256("pausable.storage")

    //--------------------------------------------------------------------------------------
    //-----------------------------------  EVENTS  -----------------------------------------
    //--------------------------------------------------------------------------------------
    event Paused(address account);
    event Unpaused(address account);

    //--------------------------------------------------------------------------------------
    //-----------------------------------  ERRORS  -----------------------------------------
    //--------------------------------------------------------------------------------------
    error AlreadyPaused();
    error NotPaused();
    error ContractPaused();

    //--------------------------------------------------------------------------------------
    //--------------------------  PAUSING FUNCTIONS  --------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Pause the contract indefinitely
     * @dev only callable by the operating multisig
     */
    function pause() external onlyOperatingMultisig {
        PausableStorage storage $ = _getPausableStorage();
        if ($.paused) revert AlreadyPaused();
        $.paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @notice Unpause the contract
     * @dev only callable by the operating multisig
     */
    function unpause() external onlyOperatingMultisig {
        PausableStorage storage $ = _getPausableStorage();
        if (!$.paused) revert NotPaused();
        $.paused = false;
        emit Unpaused(msg.sender);
    }

    //--------------------------------------------------------------------------------------
    //----------------------------  INTERNAL FUNCTIONS  -------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Get the storage of the Pausable contract
     * @return $ The storage of the Pausable contract
     */
    function _getPausableStorage() internal pure returns (PausableStorage storage $) {
        assembly {
            $.slot := PAUSABLE_STORAGE_SLOT
        }
    }

    /**
     * @notice Require the contract to be not paused
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) revert ContractPaused();
    }

    //--------------------------------------------------------------------------------------
    //-----------------------------------  GETTERS  ----------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Whether the contract is indefinitely paused
     * @return Whether the contract is paused
     */
    function paused() public view virtual returns (bool) {
        return _getPausableStorage().paused;
    }

    //--------------------------------------------------------------------------------------
    //-----------------------------------  MODIFIERS  --------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Modifier to check if the contract is not paused
     * @dev virtual so {PausableUntil} can extend it with the timed-pause check
     */
    modifier whenNotPaused() virtual {
        _requireNotPaused();
        _;
    }
}

// File: src/governance/utils/PausableUntil.sol

pragma solidity ^0.8.27;



abstract contract PausableUntil is Pausable {
    //--------------------------------------------------------------------------------------
    //------------------------------  STORAGE STRUCT  --------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice PausableUntilStorage
     * @dev Storage for the PausableUntil contract
     * @param pausedUntil The timestamp when the contract is paused until
     * @param pauseUntilDuration The duration for which the contract is paused until
     * @param lastPauseTimestamp The timestamp when the last pause occurred
     */
    struct PausableUntilStorage {
        uint256 pausedUntil;
        uint256 pauseUntilDuration;
        mapping(address => uint256) lastPauseTimestamp;
    }

    //--------------------------------------------------------------------------------------
    //-----------------------------------  CONSTANTS  --------------------------------------
    //--------------------------------------------------------------------------------------
    bytes32 private constant PAUSABLE_UNTIL_STORAGE_SLOT = 0x2c7e4bc092c2002f0baaf2f47367bc442b098266b43d189dafe4cb25f1e1fea2; // keccak256("pausableUntil.storage")

    uint256 public constant MIN_PAUSE_DURATION = 8 hours;
    uint256 public constant MAX_PAUSE_DURATION = 30 days;
    uint256 public constant PAUSER_UNTIL_COOLDOWN = 7 days;

    //--------------------------------------------------------------------------------------
    //-----------------------------------  EVENTS  -----------------------------------------
    //--------------------------------------------------------------------------------------
    event PauseUntilDurationSet(uint256 pauseUntilDuration);
    event PausedUntil(uint256 pausedUntil);
    event UnpausedUntil();

    //--------------------------------------------------------------------------------------
    //-----------------------------------  ERRORS  -----------------------------------------
    //--------------------------------------------------------------------------------------
    error ContractPausedUntil(uint256 pausedUntil);
    error ContractNotPausedUntil();
    error PauserCooldownStillActive();
    error InvalidPauseUntilDuration();

    //--------------------------------------------------------------------------------------
    //----------------------------  PAUSING FUNCTIONS  -------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Pause the contract for the configured duration
     * @dev gated to the guardian; `virtual` so contracts requiring stricter gating (e.g. the
     *      super guardian for eETH/weETH) can override the access control
     */
    function pauseUntil() external virtual onlyGuardian {
        _pauseUntil();
    }

    /**
     * @notice Lift a timed pause early
     * @dev gated to the operating multisig
     */
    function unpauseUntil() external onlyOperatingMultisig {
        _requirePausedUntil();
        PausableUntilStorage storage $ = _getPausableUntilStorage();
        $.pausedUntil = 0;
        emit UnpausedUntil();
    }

    /**
     * @notice Set the duration applied by {pauseUntil}
     * @dev gated to the operating timelock (admin)
     */
    function setPauseUntilDuration(uint256 _pauseUntilDuration) external onlyOperatingTimelock {
        if (_pauseUntilDuration < MIN_PAUSE_DURATION || _pauseUntilDuration > MAX_PAUSE_DURATION) revert InvalidPauseUntilDuration();
        _getPausableUntilStorage().pauseUntilDuration = _pauseUntilDuration;
        emit PauseUntilDurationSet(_pauseUntilDuration);
    }

    //--------------------------------------------------------------------------------------
    //----------------------------  INTERNAL FUNCTIONS  -------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Get the storage of the PausableUntil contract
     * @return $ The storage of the PausableUntil contract
     */
    function _getPausableUntilStorage() internal pure returns (PausableUntilStorage storage $) {
        assembly {
            $.slot := PAUSABLE_UNTIL_STORAGE_SLOT
        }
    }

    /**
     * @notice Require the contract to be not paused until
     */
    function _requireNotPausedUntil() internal view {
        uint256 _pausedUntil = _getPausableUntilStorage().pausedUntil;
        if (_pausedUntil >= block.timestamp) revert ContractPausedUntil(_pausedUntil);
    }

    /**
     * @notice Require the contract to be paused until
     */
    function _requirePausedUntil() internal view {
        uint256 _pausedUntil = _getPausableUntilStorage().pausedUntil;
        if (_pausedUntil < block.timestamp) revert ContractNotPausedUntil();
    }

    /**
     * @notice Pause the contract until
     * @dev only callable when contract is not paused until and pauser is not in cooldown
     */
    function _pauseUntil() internal {
        _requireNotPausedUntil();
        PausableUntilStorage storage $ = _getPausableUntilStorage();
        uint256 _pauseUntilDuration = $.pauseUntilDuration;
        // If the duration was never configured (0 — e.g. a fresh proxy or a just-upgraded
        // contract before setPauseUntilDuration is called), fall back to MIN_PAUSE_DURATION
        // so the emergency pause is always effective. Without this, `pausedUntil` would be
        // `block.timestamp + 0` (expires the same block) — a silent no-op that still burns
        // the pauser's cooldown.
        if (_pauseUntilDuration == 0) _pauseUntilDuration = MIN_PAUSE_DURATION;
        if ($.lastPauseTimestamp[msg.sender] + _pauseUntilDuration + PAUSER_UNTIL_COOLDOWN > block.timestamp) revert PauserCooldownStillActive();
        $.pausedUntil = block.timestamp + _pauseUntilDuration;
        $.lastPauseTimestamp[msg.sender] = block.timestamp;
        emit PausedUntil($.pausedUntil);
    }

    //--------------------------------------------------------------------------------------
    //-----------------------------------  GETTERS  ----------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Get the timestamp when the contract is paused until
     * @return The timestamp when the contract is paused until
     */
    function pausedUntil() external view returns (uint256) {
        return _getPausableUntilStorage().pausedUntil;
    }

    /**
     * @notice Get the pause duration for the contract
     * @return The pause duration for the contract
     */
    function pauseUntilDuration() external view returns (uint256) {
        return _getPausableUntilStorage().pauseUntilDuration;
    }

    /**
     * @notice Get the last pause timestamp for a given pauser
     * @param pauser The address of the pauser
     * @return The last pause timestamp for the pauser
     */
    function lastPauseTimestamp(address pauser) external view returns (uint256) {
        return _getPausableUntilStorage().lastPauseTimestamp[pauser];
    }

    //--------------------------------------------------------------------------------------
    //-----------------------------------  MODIFIERS  --------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Modifier to check if the contract is not paused until
     * @dev Only callable when the contract is not paused until
     */
    modifier whenNotPausedUntil() {
        _requireNotPausedUntil();
        _;
    }

    /**
     * @notice Modifier enforcing both the indefinite pause and the timed pause
     * @dev overrides {Pausable-whenNotPaused} so any function gated by `whenNotPaused` is
     *      blocked during a timed pause too — without needing a per-contract
     *      `_requireNotPaused` override
     */
    modifier whenNotPaused() override {
        _requireNotPaused();
        _requireNotPausedUntil();
        _;
    }
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol

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

// File: src/governance/utils/DeprecatedOZOwnable.sol

pragma solidity ^0.8.27;




/**
 * @title DeprecatedOZOwnable
 * @notice Storage-layout placeholder that reproduces the exact storage footprint of
 *         OpenZeppelin's `OwnableUpgradeable` so an already-deployed proxy's layout is
 *         preserved after migrating ownership to the custom {Ownable} base.
 * @dev    Inherit this in the exact position where `OwnableUpgradeable` used to sit.
 *         OZ's `OwnableUpgradeable is Initializable, ContextUpgradeable` and declares
 *         `address _owner` + `uint256[49] __gap`. We mirror that here — including the
 *         `ContextUpgradeable` base, which contributes its own `uint256[50]` gap. Where the
 *         inheriting contract already pulls in `ContextUpgradeable` elsewhere (e.g. via
 *         `OwnableUpgradeable`) it collapses to a single shared instance, exactly as it did
 *         under OZ. Do not use any of this; it exists solely to keep storage slots stable.
 */
abstract contract DeprecatedOZOwnable is Initializable, ContextUpgradeable {
    address private _owner;
    uint256[49] private __gap;
}

// File: src/core/LiquidityPool.sol

pragma solidity ^0.8.13;




















contract LiquidityPool is Initializable, DeprecatedOZOwnable, UUPSUpgradeable, ReentrancyGuardTransient, PausableUntil, ILiquidityPool {
    using SafeERC20 for IERC20;

    //--------------------------------------------------------------------------------------
    //---------------------------------  STATE-VARIABLES  ----------------------------------
    //--------------------------------------------------------------------------------------
    // deprecated storage slots
    uint256[6] private __gap_0;

    uint128 public totalValueOutOfLp;
    uint128 public totalValueInLp;
    address public feeRecipient;

    // deprecated storage slots
    uint32 private __gap_1;
    uint256[10] private __gap_2;

    mapping(address => ValidatorSpawner) public validatorSpawner;
    
    //deprecated storage slots
    uint256[5] private __gap_3;

    uint256 public validatorSizeWei;
    uint256 public maxWithdrawAmount;
    uint256 public minWithdrawAmount;
    bool public escrowMigrationCompleted;

    //--------------------------------------------------------------------------------------
    //-------------------------------------  IMMUTABLES  ----------------------------------
    //--------------------------------------------------------------------------------------

    IStakingManager public immutable stakingManager;
    IEtherFiNodesManager public immutable nodesManager;
    IeETH public immutable eETH;
    IWithdrawRequestNFT public immutable withdrawRequestNFT;
    ILiquifier public immutable liquifier;
    IEtherFiRedemptionManager public immutable etherFiRedemptionManager;
    IPriorityWithdrawalQueue public immutable priorityWithdrawalQueue;
    IBlacklister public immutable blacklister;
    address public immutable etherFiAdminContract;
    address public immutable membershipManager;

    //--------------------------------------------------------------------------------------
    //---------------------------------  CONSTANTS  ---------------------------------------
    //--------------------------------------------------------------------------------------
    uint256 public constant SHARE_UNIT = 1e18;

    // Hard cap on how far a single rebase may INCREASE TVL (rewards), in bps of TVL.
    // 25 bps ≈ 1 month of reward accrual at 3% APR — there is no legitimate reason for a
    // single report to raise the rate by more than this, so it is a fixed invariant (not
    // governance-configurable). Bounds a buggy/compromised rebase caller at the share-rate
    // chokepoint regardless of the oracle-side checks.
    uint256 public constant MAX_POSITIVE_REBASE_BPS = 25;
    uint256 private constant REBASE_BPS_DENOMINATOR = 10_000;

    //--------------------------------------------------------------------------------------
    //-------------------------------------  EVENTS  ---------------------------------------
    //--------------------------------------------------------------------------------------
    event Deposit(address indexed sender, uint256 amount, SourceOfFunds source, address referral);
    event Withdraw(address indexed sender, address recipient, uint256 amount, SourceOfFunds source);
    event EEthSharesBurnedForNonETHWithdrawal(uint256 amountSharesToBurn, uint256 withdrawalValueInETH);
    event UpdatedFeeRecipient(address newFeeRecipient);
    event ValidatorSpawnerRegistered(address user);
    event ValidatorSpawnerUnregistered(address user);
    event Rebase(uint256 totalEthLocked, uint256 totalEEthShares);
    event ProtocolFeePaid(uint128 protocolFees);
    event MinWithdrawAmountSet(uint256 minWithdrawAmount);
    event MaxWithdrawAmountSet(uint256 maxWithdrawAmount);

    //--------------------------------------------------------------------------------------
    //-------------------------------------  ERRORS  ---------------------------------------
    //--------------------------------------------------------------------------------------
    error IncorrectCaller();
    error InvalidAmount();
    error InvalidWithdrawalAmount();
    error InvalidShareAmount();
    error InsufficientLiquidity();
    error SendFail();
    error InvalidValidatorSize();
    error RebaseExceedsPositiveCap();
    error AlreadyMigrated();
    error MigrationNotComplete();
    error AlreadyRegistered();
    error NotRegistered();
    error EETHRateDeflation();

    //--------------------------------------------------------------------------------------
    //----------------------------  CONSTRUCTOR  ------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Constructor
     * @param _constructorAddresses The addresses of the contracts to use
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor(ConstructorAddresses memory _constructorAddresses) RolesLibrary(_constructorAddresses.roleRegistry) {
        stakingManager = IStakingManager(_constructorAddresses.stakingManager);
        nodesManager = IEtherFiNodesManager(_constructorAddresses.nodesManager);
        eETH = IeETH(_constructorAddresses.eETH);
        withdrawRequestNFT = IWithdrawRequestNFT(_constructorAddresses.withdrawRequestNFT);
        liquifier = ILiquifier(_constructorAddresses.liquifier);
        etherFiRedemptionManager = IEtherFiRedemptionManager(payable(_constructorAddresses.etherFiRedemptionManager));
        priorityWithdrawalQueue = IPriorityWithdrawalQueue(_constructorAddresses.priorityWithdrawalQueue);
        blacklister = IBlacklister(_constructorAddresses.blacklister);
        etherFiAdminContract = _constructorAddresses.etherFiAdminContract;
        membershipManager = _constructorAddresses.membershipManager;
        _disableInitializers();
    }

    //--------------------------------------------------------------------------------------
    //----------------------------  INITIALIZERS  ------------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Initialize the Liquidity Pool
     */
    function initialize() external initializer {
        __UUPSUpgradeable_init();
    }

    /**
    * @notice One-shot post-upgrade migration that sweeps existing locked ETH from LP to WithdrawRequestNFT and PriorityWithdrawalQueue.
    * @dev Only callable by the upgrade timelock
    */
    function initializeOnUpgradeV2() external onlyUpgradeTimelock {
        if (escrowMigrationCompleted) revert AlreadyMigrated();

        // Legacy `ethAmountLockedForWithdrawal` was a uint128 packed at bit offset 8
        // (byte 1) of __gap_3[0]; read it out directly from that slot.
        uint128 nftLocked;
        assembly {
            nftLocked := and(shr(8, sload(__gap_3.slot)), 0xffffffffffffffffffffffffffffffff)
        }
        uint128 queueLocked = address(priorityWithdrawalQueue) != address(0)
            ? uint128(priorityWithdrawalQueue.ethAmountLockedForPriorityWithdrawal())
            : 0;

        uint128 totalLocked = nftLocked + queueLocked;
        if (totalLocked > 0) {
            if (totalValueInLp < totalLocked) revert InsufficientLiquidity();
            totalValueInLp    -= totalLocked;
            totalValueOutOfLp += totalLocked;

            if (nftLocked > 0) {
                // zero the legacy uint128 (bits 8..135 of __gap_3[0]), preserving its slot neighbours
                assembly {
                    let slot := __gap_3.slot
                    sstore(slot, and(sload(slot), not(shl(8, 0xffffffffffffffffffffffffffffffff))))
                }
                _sendFund(address(withdrawRequestNFT), nftLocked);
            }
            if (queueLocked > 0) _sendFund(address(priorityWithdrawalQueue), queueLocked);
        }

        _checkTotalValueInLp();
        escrowMigrationCompleted = true;
    }

    //--------------------------------------------------------------------------------------
    //----------------------------  RECEIVE FUNCTIONS  -------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Receive ETH
     */
    receive() external payable {
        if (msg.value > type(uint128).max) revert InvalidAmount();
        totalValueOutOfLp -= uint128(msg.value);
        totalValueInLp += uint128(msg.value);
        _checkTotalValueInLp();
    }

    //--------------------------------------------------------------------------------------
    //----------------------------  DEPOSIT FUNCTIONS  -------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Deposit ETH into the Liquidity Pool
     * @return uint256 The amount of eETH minted to the caller
     * @dev Used by eETH staking flow
     */
    function deposit() external payable returns (uint256) {
        return deposit(address(0));
    }

    /**
     * @notice Deposit ETH into the Liquidity Pool
     * @param _referral The address of the referral
     * @return uint256 The amount of eETH minted to the caller
     * @dev Used by eETH staking flow
     */
    function deposit(address _referral) public payable nonReentrant whenNotPaused nonBlacklisted returns (uint256) {
        emit Deposit(msg.sender, msg.value, SourceOfFunds.EETH, _referral);

        return _deposit(msg.sender, msg.value, 0);
    }

    /**
     * @notice Deposit ETH into the Liquidity Pool
     * @param _recipient The address of the recipient
     * @param _amount The amount of ETH to deposit
     * @param _referral The address of the referral
     * @return uint256 The amount of eETH minted to the caller
     * @dev Used by eETH staking flow through Liquifier contract; deVamp or to pay protocol fees
     */
    function depositToRecipient(address _recipient, uint256 _amount, address _referral) public nonReentrant whenNotPaused returns (uint256) {
        if (msg.sender != address(liquifier) && msg.sender != address(etherFiAdminContract)) revert IncorrectCaller();
        blacklister.nonBlacklisted(_recipient);

        emit Deposit(_recipient, _amount, SourceOfFunds.EETH, _referral);

        return _deposit(_recipient, 0, _amount);
    }

    /**
     * @notice Deposit ETH into the Liquidity Pool
     * @param _user The address of the user
     * @param _referral The address of the referral
     * @return uint256 The amount of eETH minted to the caller
     * @dev Used by ether.fan staking flow
     */
    function deposit(address _user, address _referral) external payable nonReentrant whenNotPaused returns (uint256) {
        if (msg.sender != address(membershipManager)) revert IncorrectCaller();
        blacklister.nonBlacklisted(_user);

        emit Deposit(msg.sender, msg.value, SourceOfFunds.ETHER_FAN, _referral);

        return _deposit(msg.sender, msg.value, 0);
    }

    //--------------------------------------------------------------------------------------
    //----------------------------  WITHDRAW FUNCTIONS  -------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Burns shares and pays ETH. For NFT/queue callers, ETH is paid by the caller from its own segregated balance; LP only does accounting. Other callers receive ETH from LP.
     * @param _recipient The address of the recipient
     * @param _amount The amount of ETH to withdraw
     * @return uint256 The amount of eETH burned
     * @dev Only callable by the membership manager or the etherFi redemption manager
     * Live rate withdraw for membershipManager and etherFiRedemptionManager.
     * Burns shares at the live rate and pays ETH from the LP to `_recipient`.
     */
    function withdraw(address _recipient, uint256 _amount) external nonReentrant whenNotPaused nonDecreasingRate returns (uint256) {
        if (msg.sender != address(membershipManager) && msg.sender != address(etherFiRedemptionManager)) {
            revert IncorrectCaller();
        }
        uint256 share = sharesForWithdrawalAmount(_amount);
        if (eETH.balanceOf(msg.sender) < _amount) revert InsufficientLiquidity();
        if (_amount > type(uint128).max || _amount == 0 || share == 0) revert InvalidAmount();
        if (totalValueInLp < _amount) revert InsufficientLiquidity();
        totalValueInLp -= uint128(_amount);
        eETH.burnShares(msg.sender, share);

        _sendFund(_recipient, _amount);

        _checkTotalValueInLp();

        return share;
    }

    /**
     * @notice Settles a finalized claim for withdrawRequestNFT or priorityWithdrawalQueue.
     * @param _amount The amount of ETH paid to the claimer; the credit removed from `totalValueOutOfLp`.
     * @param _share The full share allocation of the request, burned in its entirety.
     * @dev Only callable by the withdrawRequestNFT or the priorityWithdrawalQueue.
     * The caller (WRN / PWQ) supplies the request's full share snapshot and the ETH amount to pay;
     * LP burns the full `_share` and unwinds the matching `_amount` from `totalValueOutOfLp`.
     * Burning the full share (rather than a rate-derived subset) removes the dust/remainder
     * that the prior rate-based burn left behind, so no separate remainder-handling flow is needed.
     * `_share` MUST be the request-time share snapshot; LP cannot independently verify this and
     * trusts the caller to pass it honestly. The `eETH.shares(msg.sender) < _share` solvency check
     * is the only bound against the caller burning more than its actual holdings.
     * ETH was already segregated to the caller at finalize/fulfill via
     * `addEthAmountLockedForWithdrawal` / `transferLockedEthForPriority`; LP only
     * performs accounting (burn + `totalValueOutOfLp -=`).
     * A negative rebase that drops `totalValueOutOfLp` below `_amount` reverts the claim
     * (finalized-withdrawal DoS, bounded by EtherFiAdmin's rebase-APR cap).
    */
    function withdraw(uint256 _amount, uint256 _share) external nonReentrant {
        if (msg.sender != address(withdrawRequestNFT) && msg.sender != address(priorityWithdrawalQueue)) {
            revert IncorrectCaller();
        }
        if (_amount > type(uint128).max || _amount == 0 || _share == 0) revert InvalidAmount();

        totalValueOutOfLp -= uint128(_amount);
        eETH.burnShares(msg.sender, _share);
    }

    /**
     * @notice request withdraw from pool and receive a WithdrawRequestNFT
     * @param recipient The address of the recipient
     * @param amount The amount of ETH to withdraw
     * @return uint256 The requestId of the WithdrawRequestNFT
     * @dev Transfers the amount of eETH from msg.senders account to the WithdrawRequestNFT contract & mints an NFT to the msg.sender
     */
    function requestWithdraw(address recipient, uint256 amount) public nonReentrant whenNotPaused nonBlacklisted returns (uint256) {
        blacklister.nonBlacklisted(recipient);
        if (amount == 0) revert InvalidWithdrawalAmount();
        if (amount < minWithdrawAmount || amount > maxWithdrawAmount) revert InvalidWithdrawalAmount();
        uint256 share = sharesForAmount(amount);
        if (share == 0) revert InvalidShareAmount();

        return _requestWithdraw(recipient, amount, share, SourceOfFunds.EETH);
    }

    /**
     * @notice request withdraw from pool with signed permit data and receive a WithdrawRequestNFT
     * @param _owner The address of the owner
     * @param _amount The amount of ETH to withdraw
     * @param _permit The permit data to approve transfer of eETH
     * @return uint256 The requestId of the WithdrawRequestNFT
     * @dev accepts PermitInput signed data to approve transfer of eETH (EIP-2612) so withdraw request can happen in 1 tx
     */
    function requestWithdrawWithPermit(address _owner, uint256 _amount, PermitInput calldata _permit) external returns (uint256)
    {
        try eETH.permit(msg.sender, address(this), _permit.value, _permit.deadline, _permit.v, _permit.r, _permit.s) {} catch {}
        return requestWithdraw(_owner, _amount);
    }

    /**
     * @notice request withdraw of some or all of the eETH backing a MembershipNFT and receive a WithdrawRequestNFT
     * @param recipient The address of the recipient
     * @param amount The amount of ETH to withdraw
     * @param fee The fee amount not used anymore, only kept to maintain compatibility with existing code
     * @return uint256 The requestId of the WithdrawRequestNFT
     * @dev Transfers the amount of eETH from MembershipManager to the WithdrawRequestNFT contract & mints an NFT to the recipient
     */
    function requestMembershipNFTWithdraw(address recipient, uint256 amount, uint256 fee) public nonReentrant whenNotPaused returns (uint256) {
        if (msg.sender != address(membershipManager)) revert IncorrectCaller();
        uint256 share = sharesForAmount(amount);
        if (amount > type(uint96).max || amount == 0 || share == 0) revert InvalidAmount();

        return _requestWithdraw(recipient, amount, share, SourceOfFunds.ETHER_FAN);
    }


    //--------------------------------------------------------------------------------------
    //---------------------- STAKING FLOW FUNCTIONS -------------------------------------
    //--------------------------------------------------------------------------------------
    // [Liquidity Pool Staking flow]
    // Step 1: (Off-chain) create the keys using the desktop app
    // Step 2: register validator deposit data for later confirmation from the oracle before the 1eth deposit
    // Step 3: create validators with 1 eth deposits to official deposit contract
    // Step 4: oracle approves and funds the remaining balance for the validator
    /**
     * @notice claim bids and send 1 eth deposits to deposit contract to create the provided validators.
     * @param _depositData The deposit data for the validators
     * @param _bidIds The bid ids for the validators
     * @param _etherFiNode The etherFi node for the validators
     * @dev step 2 of staking flow
     */
    function batchRegister(
        IStakingManager.DepositData[] calldata _depositData,
        uint256[] calldata _bidIds,
        address _etherFiNode
    ) external whenNotPaused {
        if (!validatorSpawner[msg.sender].registered) revert IncorrectCaller();
        stakingManager.registerBeaconValidators(_depositData, _bidIds, _etherFiNode);
    }

    /**
     * @notice create validators with 1 eth deposits to official deposit contract
     * @param _depositData The deposit data for the validators
     * @param _bidIds The bid ids for the validators
     * @param _etherFiNode The etherFi node for the validators
     * @dev step 3 of staking flow
     */
    function batchCreateBeaconValidators(
        IStakingManager.DepositData[] calldata _depositData,
        uint256[] calldata _bidIds,
        address _etherFiNode
    ) external nonReentrant whenNotPaused onlyOracleOperations {
        // liquidity pool supplies 1 eth per validator
        uint256 outboundEthAmountFromLp = stakingManager.INITIAL_DEPOSIT_AMOUNT() * _bidIds.length;
        stakingManager.createBeaconValidators{value: outboundEthAmountFromLp}(_depositData, _bidIds, _etherFiNode);

        _accountForEthSentOut(outboundEthAmountFromLp);
    }

    /**
     * @notice send remaining eth to deposit contract to activate the provided validators
     * @param _depositData The deposit data for the validators
     * @param _validatorSizeWei The size of the validators
     * @dev step 3 of staking flow. Callable directly by oracle ops, or by EtherFiAdmin
     *      when forwarding from `executeValidatorApprovalTask` (which gates oracle ops at
     *      its own entry point and tracks task completion on-chain). Both upstream paths
     *      enforce oracle-ops authorization, so accepting EtherFiAdmin here doesn't widen
     *      the auth surface.
    */
    function confirmAndFundBeaconValidators(
        IStakingManager.DepositData[] calldata _depositData,
        uint256 _validatorSizeWei
    ) external nonReentrant whenNotPaused {
        if (msg.sender != address(etherFiAdminContract)) roleRegistry.onlyOracleOperations(msg.sender);
        _requireValidValidatorSize(_validatorSizeWei);

        // we have already deposited the initial amount to create the validator on the beacon chain
        uint256 remainingEthPerValidator = _validatorSizeWei - stakingManager.INITIAL_DEPOSIT_AMOUNT();

        uint256 outboundEthAmountFromLp = remainingEthPerValidator * _depositData.length;
        stakingManager.confirmAndFundBeaconValidators{value: outboundEthAmountFromLp}(_depositData, _validatorSizeWei);

        _accountForEthSentOut(outboundEthAmountFromLp);
    }

    /**
     * @notice The admin can register an address to become a BNFT holder
     * @param _user The address of the Validator Spawner to register
     * @dev The admin can register an address to become a BNFT holder
     */
    function registerValidatorSpawner(address _user) public onlyOperatingTimelock {
        if (validatorSpawner[_user].registered) revert AlreadyRegistered();  
        validatorSpawner[_user] = ValidatorSpawner({registered: true});
        emit ValidatorSpawnerRegistered(_user);
    }

    /**
     * @notice Removes a Validator Spawner
     * @param _user the address of the Validator Spawner to remove
     * @dev Removes a Validator Spawner
     */
    function unregisterValidatorSpawner(address _user) external onlyOperatingMultisig {
        if (!validatorSpawner[_user].registered) revert NotRegistered();
        delete validatorSpawner[_user];
        emit ValidatorSpawnerUnregistered(_user);
    }

    //--------------------------------------------------------------------------------------
    //------------------------------  OPERATIONAL FUNCTIONS  -------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Rebase by ether.fi and pay protocol fees in a single oracle-driven step
     * @param _accruedRewards The amount of rewards to rebase
     * @param _protocolFees The amount of protocol fees to pay in ether. Minted to feeRecipient after the rebase.
     * @dev Only callable by the etherFiAdminContract
     */
    function rebase(int128 _accruedRewards, uint128 _protocolFees) external {
        if (msg.sender != address(etherFiAdminContract)) revert IncorrectCaller();

        // Positive (reward) upper bound, enforced at the share-rate chokepoint regardless
        // of who calls rebase. A single rebase cannot increase TVL by more than
        // MAX_POSITIVE_REBASE_BPS of pre-rebase TVL. Defense-in-depth alongside the
        // oracle-side negative cap in EtherFiAdmin; the negative side is intentionally not
        // re-checked here (the oracle path owns it and bounds it tighter). Guarded on the
        // positive branch: for a negative _accruedRewards, uint128(_accruedRewards) would
        // reinterpret the sign bit as a huge unsigned value and spuriously trip the cap.
        if (_accruedRewards > 0) {
            uint256 maxIncrease = (getTotalPooledEther() * MAX_POSITIVE_REBASE_BPS) / REBASE_BPS_DENOMINATOR;
            if (uint256(uint128(_accruedRewards)) > maxIncrease) revert RebaseExceedsPositiveCap();
        }

        totalValueOutOfLp = uint128(int128(totalValueOutOfLp) + _accruedRewards);
        emit Rebase(getTotalPooledEther(), eETH.totalShares());

        if (_protocolFees > 0) {
            emit ProtocolFeePaid(_protocolFees);
            depositToRecipient(feeRecipient, _protocolFees, address(0));
        }
    }

    /**
     * @notice Locks ETH for finalized NFT withdrawals by transferring from LP to WithdrawRequestNFT. TVL preserved by InLp/OutOfLp rebalance; share rate unchanged.
     * @param _amount The amount of ETH to lock
     * @dev Only callable by the etherFiAdminContract or the withdrawRequestNFT
     */
    function addEthAmountLockedForWithdrawal(uint128 _amount) external {
        if (msg.sender != address(etherFiAdminContract) && msg.sender != address(withdrawRequestNFT)) revert IncorrectCaller();
        _lockEth(address(withdrawRequestNFT), _amount);
    }

    /**
     * @notice Locks ETH for the priority withdrawal queue by transferring from LP to the queue contract. TVL preserved by InLp/OutOfLp rebalance.
     * @param _amount The amount of ETH to lock
     * @dev Only callable by the priorityWithdrawalQueue
     */
    function transferLockedEthForPriority(uint128 _amount) external {
        if (msg.sender != address(priorityWithdrawalQueue)) revert IncorrectCaller();
        _lockEth(address(priorityWithdrawalQueue), _amount);
    }

    /**
     * @notice Burns eETH shares
     * @param shares The amount of eETH shares to burn
     * @dev Only callable by the etherFiRedemptionManager, the withdrawRequestNFT or the priorityWithdrawalQueue
     */
    function burnEEthShares(uint256 shares) external nonDecreasingRate {
        if (msg.sender != address(etherFiRedemptionManager) && msg.sender != address(withdrawRequestNFT) && msg.sender != address(priorityWithdrawalQueue)) revert IncorrectCaller();
        eETH.burnShares(msg.sender, shares);
    }

    /**
     * @notice Burns eETH shares for non-ETH withdrawal
     * @param _amountSharesToBurn The amount of eETH shares to burn
     * @param _withdrawalValueInETH The amount of ETH to withdraw
     * @dev Only callable by the etherFiRedemptionManager
     */
    function burnEEthSharesForNonETHWithdrawal(uint256 _amountSharesToBurn, uint256 _withdrawalValueInETH) external nonDecreasingRate {
        uint256 share = sharesForWithdrawalAmount(_withdrawalValueInETH);
        if (msg.sender != address(etherFiRedemptionManager)) revert IncorrectCaller();
        if (_amountSharesToBurn == 0 || _withdrawalValueInETH == 0) revert InvalidAmount();

        // Verify the share price will not go down
        if (share > _amountSharesToBurn) revert InvalidAmount();

        totalValueOutOfLp -= uint128(_withdrawalValueInETH);

        eETH.burnShares(msg.sender, _amountSharesToBurn);
        emit EEthSharesBurnedForNonETHWithdrawal(_amountSharesToBurn, _withdrawalValueInETH);
    }

    //--------------------------------------------------------------------------------------
    //------------------------------  SETTER FUNCTIONS  ------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice set the size of validators created when EtherFiAdmin.executeValidatorApprovalTask
     * @param _validatorSizeWei The size of the validators
     * @dev set the size of validators created when EtherFiAdmin.executeValidatorApprovalTask
     *      forwards into confirmAndFundBeaconValidators(). In a future upgrade this will be a
     *      parameter to that call but was done like this to limit changes to other dependent contracts.
     */
    function setValidatorSizeWei(uint256 _validatorSizeWei) external onlyOperatingTimelock {
        _requireValidValidatorSize(_validatorSizeWei);
        validatorSizeWei = _validatorSizeWei;
    }

    /**
     * @notice Set the fee recipient address
     * @param _feeRecipient The address to set as the fee recipient
     * @dev Only callable by the admin
     */
    function setFeeRecipient(address _feeRecipient) external onlyOperatingTimelock {
        feeRecipient = _feeRecipient;
        emit UpdatedFeeRecipient(_feeRecipient);
    }

    /**
     * @notice Set the minimum withdraw amount
     * @param _minWithdrawAmount The minimum withdraw amount
     * @dev Only callable by the operating multisig
     */
    function setMinWithdrawAmount(uint256 _minWithdrawAmount) external onlyOperatingMultisig {
        if (_minWithdrawAmount > maxWithdrawAmount) revert InvalidAmount();
        minWithdrawAmount = _minWithdrawAmount;
        emit MinWithdrawAmountSet(_minWithdrawAmount);
    }

    /**
     * @notice Set the maximum withdraw amount
     * @param _maxWithdrawAmount The maximum withdraw amount
     * @dev Only callable by the operating multisig
     */
    function setMaxWithdrawAmount(uint256 _maxWithdrawAmount) external onlyOperatingMultisig {
        if (_maxWithdrawAmount == 0 || _maxWithdrawAmount < minWithdrawAmount) revert InvalidAmount();
        maxWithdrawAmount = _maxWithdrawAmount;
        emit MaxWithdrawAmountSet(_maxWithdrawAmount);
    }

    //--------------------------------------------------------------------------------------
    //------------------------------  INTERNAL FUNCTIONS  ----------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Deposits ETH into the Liquidity Pool
     * @param _recipient The address of the recipient
     * @param _amountInLp The amount of ETH to deposit into the Liquidity Pool
     * @param _amountOutOfLp The amount of ETH to deposit into the Liquidity Pool
     */
    function _deposit(address _recipient, uint256 _amountInLp, uint256 _amountOutOfLp) internal nonDecreasingRate returns (uint256) {
        totalValueInLp += uint128(_amountInLp);
        totalValueOutOfLp += uint128(_amountOutOfLp);
        uint256 amount = _amountInLp + _amountOutOfLp;
        uint256 share = _sharesForDepositAmount(amount);
        if (amount > type(uint128).max || amount == 0 || share == 0) revert InvalidAmount();

        eETH.mintShares(_recipient, share);

        _checkTotalValueInLp();

        return share;
    }

    /**
     * @notice Shared tail for requestWithdraw / requestMembershipNFTWithdraw: moves `amount` eETH
     * @param recipient The address of the recipient
     * @param amount The amount of eETH to move
     * @param share The share of eETH to move
     * @param source The source of the eETH
     * @return requestId The requestId of the WithdrawRequestNFT
     */
    function _requestWithdraw(address recipient, uint256 amount, uint256 share, SourceOfFunds source) internal returns (uint256 requestId) {
        IERC20(address(eETH)).safeTransferFrom(msg.sender, address(withdrawRequestNFT), amount);
        requestId = withdrawRequestNFT.requestWithdraw(uint96(amount), uint96(share), recipient);
        emit Withdraw(msg.sender, recipient, amount, source);
    }

    /**
     * @notice Calculates the shares for a deposit amount
     * @param _depositAmount The amount of ETH to deposit
     * @return uint256 The shares for the deposit amount
     */
    function _sharesForDepositAmount(uint256 _depositAmount) internal view returns (uint256) {
        uint256 totalPooledEther = getTotalPooledEther() - _depositAmount;
        if (totalPooledEther == 0) {
            return _depositAmount;
        }
        return Math.mulDiv(_depositAmount, eETH.totalShares(), totalPooledEther, Math.Rounding.Down);
    }

    /**
     * @notice Sends ETH to a recipient
     * @param _recipient The address of the recipient
     * @param _amount The amount of ETH to send
     */
    function _sendFund(address _recipient, uint256 _amount) internal {
        uint256 balance = address(this).balance;
        (bool sent, ) = _recipient.call{value: _amount}("");
        if (!sent || address(this).balance < balance - _amount) revert SendFail();
    }

    /**
     * @notice Shared body for `addEthAmountLockedForWithdrawal` and `transferLockedEthForPriority`.
     * @param _dest The address of the recipient
     * @param _amount The amount of ETH to send
     * @dev Both move ETH out of LP into a segregated escrow (WRNFT or PQ) while keeping TVL
     *      invariant by rebalancing `totalValueInLp` -> `totalValueOutOfLp`. Caller-gating
     *      lives in the two external entry points.
     */
    function _lockEth(address _dest, uint128 _amount) internal {
        if (!escrowMigrationCompleted) revert MigrationNotComplete();
        if (totalValueInLp < _amount) revert InsufficientLiquidity();
        totalValueInLp    -= _amount;
        totalValueOutOfLp += _amount;
        _sendFund(_dest, _amount);
        _checkTotalValueInLp();
    }

    /**
     * @notice Accounts for ETH sent out
     * @param _amount The amount of ETH to send out
     * @dev Accounts for ETH sent out by the WithdrawRequestNFT or the PriorityWithdrawalQueue
     */
    function _accountForEthSentOut(uint256 _amount) internal {
        totalValueOutOfLp += uint128(_amount);
        totalValueInLp -= uint128(_amount);
        _checkTotalValueInLp();
    }

    /**
     * @notice Checks if the total value in LP is greater than the balance of the contract
     */
    function _checkTotalValueInLp() internal view {
        if (totalValueInLp > address(this).balance) revert InsufficientLiquidity();
    }

    /**
     * @notice Snaps the rate
     * @return P The total pooled ether
     * @return S The total shares
     */
    function _snapRate() internal view returns (uint256 P, uint256 S) {
        P = getTotalPooledEther();
        S = eETH.totalShares();
    }

    /**
     * @notice Checks if the rate is non-decreasing
     * @param P0 The total pooled ether before the rate is snapped
     * @param S0 The total shares before the rate is snapped
     */
    function _checkRateNonDec(uint256 P0, uint256 S0) internal view {
        (uint256 P1, uint256 S1) = _snapRate();
        // Bootstrap exempt (no rate before/after to compare).
        if (S0 != 0 && S1 != 0 && P1 * S0 < P0 * S1) revert EETHRateDeflation();
    }

    /**
     * @notice Checks if the validator size is valid
     * @param _validatorSizeWei The validator size
     */
    function _requireValidValidatorSize(uint256 _validatorSizeWei) internal view {
        if (_validatorSizeWei < stakingManager.MIN_VALIDATOR_SIZE_WEI() || _validatorSizeWei > stakingManager.MAX_VALIDATOR_SIZE_WEI()) revert InvalidValidatorSize();
    }

    /**
     * @notice Authorizes the upgrade of the contract
     * @param newImplementation The new implementation address
     * @dev Only callable by the upgrade timelock
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyUpgradeTimelock {}

    //--------------------------------------------------------------------------------------
    //------------------------------------  GETTERS  ---------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Gets the total ether claim of a user
     * @param _user The address of the user
     * @return uint256 The total ether claim of the user
     */
    function getTotalEtherClaimOf(address _user) external view returns (uint256) {
        uint256 staked;
        uint256 totalShares = eETH.totalShares();
        if (totalShares > 0) {
            staked = Math.mulDiv(getTotalPooledEther(), eETH.shares(_user), totalShares, Math.Rounding.Down);
        }
        return staked;
    }

    /**
     * @notice Gets the total pooled ether
     * @return uint256 The total pooled ether
     */
    function getTotalPooledEther() public view returns (uint256) {
        return totalValueOutOfLp + totalValueInLp;
    }

    /**
     * @notice Gets the shares for an amount
     * @param _amount The amount of ETH
     * @return uint256 The shares for the amount
     */
    function sharesForAmount(uint256 _amount) public view returns (uint256) {
        uint256 totalPooledEther = getTotalPooledEther();
        if (totalPooledEther == 0) {
            return 0;
        }
        return Math.mulDiv(_amount, eETH.totalShares(), totalPooledEther, Math.Rounding.Down);
    }

    /**
     * @notice Gets the shares for a withdrawal amount
     * @param _amount The amount of ETH to withdraw
     * @return uint256 The shares for the withdrawal amount
     * @dev withdrawal rounding errors favor the protocol by rounding up
     */
    function sharesForWithdrawalAmount(uint256 _amount) public view returns (uint256) {
        uint256 totalPooledEther = getTotalPooledEther();
        if (totalPooledEther == 0) {
            return 0;
        }

        // ceiling division so rounding errors favor the protocol
        return Math.mulDiv(_amount, eETH.totalShares(), totalPooledEther, Math.Rounding.Up);
    }

    /**
     * @notice Gets the amount for a share
     * @param _share The share of eETH
     * @return uint256 The amount for the share
     */
    function amountForShare(uint256 _share) public view returns (uint256) {
        uint256 totalShares = eETH.totalShares();
        if (totalShares == 0) {
            return 0;
        }
        return Math.mulDiv(_share, getTotalPooledEther(), totalShares, Math.Rounding.Down);
    }

    /**
     * @notice Gets the amount per share ceil
     * @return uint256 The amount per share ceil
     * @dev ETH value of `1e18` shares, rounded UP. Single source of truth for the rate
     *      snapshotted by segregated callers (WithdrawRequestNFT / PriorityWithdrawalQueue)
     *      at finalize/fulfill. Ceiling rounding keeps the frozen rate >= `amountForShare`'s
     *      floor value so the round-trips at claim time satisfy:
     *      `shareOfEEth * rate / 1e18 >= amountForShare(shareOfEEth)` (solvency check) and
     *      `ceil(amount * 1e18 / rate) <= shareOfEEth` (burn-bounded-by-request).
     */
    function amountPerShareCeil() public view returns (uint256) {
        uint256 totalShares = eETH.totalShares();
        if (totalShares == 0) return 0;
        return Math.mulDiv(SHARE_UNIT, getTotalPooledEther(), totalShares, Math.Rounding.Up);
    }

    /**
     * @notice Gets the implementation address
     * @return address The implementation address
     */
    function getImplementation() external view returns (address) {return _getImplementation();}

    //--------------------------------------------------------------------------------------
    //-----------------------------------  MODIFIERS  --------------------------------------
    //--------------------------------------------------------------------------------------
    /**
     * @notice Modifier to check if the caller is not blacklisted
     * @dev Only callable by the blacklister
     */
    modifier nonBlacklisted() {
        blacklister.nonBlacklisted(msg.sender);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the etherFiAdminContract
     * @dev Only callable by the etherFiAdminContract
     */
    modifier onlyEtherFiAdmin() {
        if (msg.sender != address(etherFiAdminContract)) revert IncorrectCaller();
        _;
    }

    /**
     * @notice Modifier to check if the eETH exchange rate is non-decreasing
     * @dev Invariant — the eETH exchange rate
     *      (`totalPooledEther / totalShares`) does not decrease across
     *      this call. Snapshots (P0, S0) before the function body, then
     *      (P1, S1) after, and asserts `P1 * S0 >= P0 * S1` (the
     *      cross-multiplied form of `P1/S1 >= P0/S0`, integer-exact).
     *
     *         APPLIED to every share-changing entry point where the rate
     *         is supposed to stay equal or move UP by construction:
     *           - deposit() / depositToRecipient / deposit(user, ref)
     *             — proportional mint, floor-rounded shares (rate up)
     *           - withdraw(address, uint256)
     *             — live-rate burn, ceil-rounded shares (rate up)
     *           - burnEEthShares
     *             — share-only burn, no P-side change (rate up)
     *           - burnEEthSharesForNonETHWithdrawal
     *             — already locally checks rate non-decrease; modifier is
     *               belt-and-suspenders
     *
     *         INTENTIONALLY NOT applied to:
     *           - withdraw(uint256, uint256, uint256) — frozen-rate finalized claim,
     *             rate-drop bounded by the three-guard design at that function's
     *             docblock (WRN/PQ-only)
     *           - rebase() — oracle path, rate-change bounded by
     *             EtherFiAdmin._validateRebaseApr's APR cap
     *
     *         These two are the only intentional rate-changing paths.
     *         Anything else that drops the rate trips the modifier.
     *
     *         Overflow note: P, S each fit in uint128 in any plausible
     *         protocol state; P*S ≈ 1.4e52 ≪ uint256 max. Safe by inspection.
     *
     *         Implementation note: the snapshot / check pair lives in two
     *         internal view helpers so the body isn't duplicated at every
     *         site Solidity inlines this modifier into. Same semantics,
     *         ~1 KB smaller runtime.   
     */
    modifier nonDecreasingRate() {
        (uint256 P0, uint256 S0) = _snapRate();
        _;
        _checkRateNonDec(P0, S0);
    }
}
