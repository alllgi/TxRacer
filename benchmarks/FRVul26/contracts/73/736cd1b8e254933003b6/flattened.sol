// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

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

// File: contracts/pendle/contracts/interfaces/IWETH.sol

/*
 * MIT License
 * ===========
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 */
pragma solidity ^0.8.0;



interface IWETH is IERC20 {
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// File: contracts/pendle/contracts/core/libraries/TokenHelper.sol

pragma solidity ^0.8.0;





abstract contract TokenHelper {
    using SafeERC20 for IERC20;

    address internal constant NATIVE = address(0);
    uint256 internal constant LOWER_BOUND_APPROVAL = type(uint96).max / 2; // some tokens use 96 bits for approval

    function _transferIn(address token, address from, uint256 amount) internal {
        if (token == NATIVE) require(msg.value == amount, "eth mismatch");
        else if (amount != 0) IERC20(token).safeTransferFrom(from, address(this), amount);
    }

    function _transferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        if (amount != 0) token.safeTransferFrom(from, to, amount);
    }

    function _transferOut(address token, address to, uint256 amount) internal {
        if (amount == 0) return;
        if (token == NATIVE) {
            (bool success, ) = to.call{value: amount}("");
            require(success, "eth send failed");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function _transferOut(address[] memory tokens, address to, uint256[] memory amounts) internal {
        uint256 numTokens = tokens.length;
        require(numTokens == amounts.length, "length mismatch");
        for (uint256 i = 0; i < numTokens; ) {
            _transferOut(tokens[i], to, amounts[i]);
            unchecked {
                i++;
            }
        }
    }

    function _selfBalance(address token) internal view returns (uint256) {
        return (token == NATIVE) ? address(this).balance : IERC20(token).balanceOf(address(this));
    }

    function _selfBalance(IERC20 token) internal view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev PLS PAY ATTENTION to tokens that requires the approval to be set to 0 before changing it
    function _safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Safe Approve");
    }

    function _safeApproveInf(address token, address to) internal {
        if (token == NATIVE) return;
        if (IERC20(token).allowance(address(this), to) < LOWER_BOUND_APPROVAL) {
            _safeApprove(token, to, 0);
            _safeApprove(token, to, type(uint256).max);
        }
    }

    function _wrap_unwrap_ETH(address tokenIn, address tokenOut, uint256 netTokenIn) internal {
        if (tokenIn == NATIVE) IWETH(tokenOut).deposit{value: netTokenIn}();
        else IWETH(tokenIn).withdraw(netTokenIn);
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/IPSwapAggregator.sol

pragma solidity ^0.8.0;

struct SwapData {
    SwapType swapType;
    address extRouter;
    bytes extCalldata;
    bool needScale;
}

struct SwapDataExtra {
    address tokenIn;
    address tokenOut;
    uint256 minOut;
    SwapData swapData;
}

enum SwapType {
    NONE,
    KYBERSWAP,
    ODOS,
    // ETH_WETH not used in Aggregator
    ETH_WETH
}

interface IPSwapAggregator {
    event SwapSingle(SwapType indexed swapType, address indexed tokenIn, uint256 amountIn);

    function swap(address tokenIn, uint256 amountIn, SwapData calldata swapData) external payable;

    function swapMultiOdos(address[] calldata tokensIn, SwapData calldata swapData) external payable;
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/pools/IKyberLO.sol

pragma solidity ^0.8.0;

interface IKyberLO {
    struct Order {
        uint256 salt;
        address makerAsset;
        address takerAsset;
        address maker;
        address receiver;
        address allowedSender; // equals to Zero address on public orders
        uint256 makingAmount;
        uint256 takingAmount;
        address feeRecipient;
        uint32 makerTokenFeePercent;
        bytes makerAssetData;
        bytes takerAssetData;
        bytes getMakerAmount; // this.staticcall(abi.encodePacked(bytes, swapTakerAmount)) => (swapMakerAmount)
        bytes getTakerAmount; // this.staticcall(abi.encodePacked(bytes, swapMakerAmount)) => (swapTakerAmount)
        bytes predicate; // this.staticcall(bytes) => (bool)
        bytes permit; // On first fill: permit.1.call(abi.encodePacked(permit.selector, permit.2))
        bytes interaction;
    }

    struct FillBatchOrdersParams {
        Order[] orders;
        bytes[] signatures;
        uint256 takingAmount;
        uint256 thresholdAmount;
        address target;
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/pools/IKyberDSLO.sol

pragma solidity ^0.8.0;

interface IKyberDSLO {
    struct Order {
        uint256 salt;
        address makerAsset;
        address takerAsset;
        address maker;
        address receiver;
        address allowedSender; // equals to Zero address on public orders
        uint256 makingAmount;
        uint256 takingAmount;
        uint256 feeConfig; // bit slot  1 -> 32 -> 160: isTakerAssetFee - amountTokenFeePercent - feeRecipient
        bytes makerAssetData;
        bytes takerAssetData;
        bytes getMakerAmount; // this.staticcall(abi.encodePacked(bytes, swapTakerAmount)) => (swapMakerAmount)
        bytes getTakerAmount; // this.staticcall(abi.encodePacked(bytes, swapMakerAmount)) => (swapTakerAmount)
        bytes predicate; // this.staticcall(bytes) => (bool)
        bytes interaction;
    }

    struct Signature {
        bytes orderSignature; // Signature to confirm quote ownership
        bytes opSignature; // OP Signature to confirm quote ownership
    }

    struct FillBatchOrdersParams {
        Order[] orders;
        Signature[] signatures;
        uint32[] opExpireTimes;
        uint256 takingAmount;
        uint256 thresholdAmount;
        address target;
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/pools/IBebopV3.sol

pragma solidity ^0.8.0;

interface IBebopV3 {
    struct Single {
        uint256 expiry;
        address taker_address;
        address maker_address;
        uint256 maker_nonce;
        address taker_token;
        address maker_token;
        uint256 taker_amount;
        uint256 maker_amount;
        address receiver;
        uint256 packed_commands;
        uint256 flags; // `hashSingleOrder` doesn't use this field for SingleOrder hash
    }

    struct MakerSignature {
        bytes signatureBytes;
        uint256 flags;
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/IExecutorHelperStruct.sol

pragma solidity ^0.8.0;





interface IExecutorHelperStruct {
    struct Swap {
        bytes data;
        bytes32 selectorAndFlags; // [selector (32 bits) + flags (224 bits)]; selector is 4 most significant bytes; flags are stored in 4 least significant bytes.
    }

    struct SwapExecutorDescription {
        Swap[][] swapSequences;
        address tokenIn;
        address tokenOut;
        uint256 minTotalAmountOut;
        address to;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    struct UniSwap {
        address pool;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 collectAmount; // amount that should be transferred to the pool
        uint32 swapFee;
        uint32 feePrecision;
        uint32 tokenWeightInput;
    }

    struct StableSwap {
        address pool;
        address tokenFrom;
        address tokenTo;
        uint8 tokenIndexFrom;
        uint8 tokenIndexTo;
        uint256 dx;
        uint256 poolLength;
        address poolLp;
        bool isSaddle; // true: saddle, false: stable
    }

    struct CurveSwap {
        address pool;
        address tokenFrom;
        address tokenTo;
        int128 tokenIndexFrom;
        int128 tokenIndexTo;
        uint256 dx;
        bool usePoolUnderlying;
        bool useTriCrypto;
    }

    struct UniswapV3KSElastic {
        address recipient;
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount;
        uint160 sqrtPriceLimitX96;
        bool isUniV3; // true = UniV3, false = KSElastic
    }

    struct BalancerV2 {
        address vault;
        bytes32 poolId;
        address assetIn;
        address assetOut;
        uint256 amount;
    }

    struct DODO {
        address recipient;
        address pool;
        address tokenFrom;
        address tokenTo;
        uint256 amount;
        address sellHelper;
        bool isSellBase;
        bool isVersion2;
    }

    struct GMX {
        address vault;
        address tokenIn;
        address tokenOut;
        uint256 amount;
        address receiver;
    }

    struct Synthetix {
        address synthetixProxy;
        address tokenIn;
        address tokenOut;
        bytes32 sourceCurrencyKey;
        uint256 sourceAmount;
        bytes32 destinationCurrencyKey;
        bool useAtomicExchange;
    }

    struct Platypus {
        address pool;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 collectAmount; // amount that should be transferred to the pool
    }

    struct PSM {
        address router;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        address recipient;
    }

    struct WSTETH {
        address pool;
        uint256 amount;
        bool isWrapping;
    }

    struct Maverick {
        address pool;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 swapAmount;
        uint256 sqrtPriceLimitD18;
    }

    struct SyncSwap {
        bytes _data;
        address vault;
        address tokenIn;
        address pool;
        uint256 collectAmount;
    }

    struct AlgebraV1 {
        address recipient;
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount;
        uint160 sqrtPriceLimitX96;
        uint256 senderFeeOnTransfer; // [ FoT_FLAG(1 bit) ... SENDER_ADDRESS(160 bits) ]
    }

    struct BalancerBatch {
        address vault;
        bytes32[] poolIds;
        address[] path; // swap path from assetIn to assetOut
        bytes[] userDatas;
        uint256 amountIn; // assetIn amount
    }

    struct Mantis {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amount;
        address recipient;
    }

    struct IziSwap {
        address pool;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 swapAmount;
        int24 limitPoint;
    }

    struct TraderJoeV2 {
        address recipient;
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 collectAmount; // most significant 1 bit is to determine whether pool is v2.1, else v2.0
    }

    struct LevelFiV2 {
        address pool;
        address fromToken;
        address toToken;
        uint256 amountIn;
        uint256 minAmountOut;
        address recipient; // receive token out
    }

    struct GMXGLP {
        address rewardRouter;
        address stakedGLP;
        address glpManager;
        address yearnVault;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount;
        address recipient;
    }

    struct Vooi {
        address pool;
        address fromToken;
        address toToken;
        uint256 fromID;
        uint256 toID;
        uint256 fromAmount;
        address to;
    }

    struct VelocoreV2 {
        address vault;
        uint256 amount;
        address tokenIn;
        address tokenOut;
        address stablePool; // if not empty then use stable pool
        address wrapToken;
        bool isConvertFirst;
    }

    struct MaticMigrate {
        address pool;
        address tokenAddress; // should be POL
        uint256 amount;
        address recipient; // empty if migrate
    }

    struct Kokonut {
        address pool;
        uint256 dx;
        uint256 tokenIndexFrom;
        address fromToken;
        address toToken;
    }

    struct BalancerV1 {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amount;
    }

    struct ArbswapStable {
        address pool;
        uint256 dx;
        uint256 tokenIndexFrom;
        address tokenIn;
        address tokenOut;
    }

    struct BancorV2 {
        address pool;
        address[] swapPath;
        uint256 amount;
        address recipient;
    }

    struct Ambient {
        address pool;
        uint128 qty;
        address base;
        address quote;
        uint256 poolIdx;
        uint8 settleFlags;
    }

    struct UniV1 {
        address pool;
        uint256 amount;
        address tokenIn;
        address tokenOut;
        address recipient;
    }

    struct LighterV2 {
        address orderBook;
        uint256 amount;
        bool isAsk; // isAsk = orderBook.isAskOrder(orderId);
        address tokenIn;
        address tokenOut;
        address recipient;
    }

    struct EtherFiWeETH {
        uint256 amount;
        bool isWrapping;
    }

    struct Kelp {
        address pool;
        uint256 amount;
        address tokenIn;
        address tokenOut;
    }

    struct EthenaSusde {
        uint256 amount;
        address recipient;
    }

    struct RocketPool {
        address pool;
        uint256 isDepositAndAmount; // 1 isDeposit + 127 empty + 128 amount token in
    }

    struct MakersDAI {
        uint256 isRedeemAndAmount; // 1 isRedeem + 127 empty + 128 amount token in
        address recipient;
    }

    struct Renzo {
        address pool;
        uint256 amount;
        address tokenIn;
        address tokenOut;
    }

    struct FrxETH {
        address pool;
        uint256 amount;
        address tokenOut;
    }

    struct SfrxETH {
        address pool;
        uint256 amount;
        address tokenOut;
        address recipient;
    }

    struct SfrxETHConvertor {
        address pool;
        uint256 isDepositAndAmount; // 1 isDeposit + 127 empty + 128 amount token in
        address tokenIn;
        address tokenOut;
        address recipient;
    }

    struct OriginETH {
        address pool;
        uint256 amount;
    }

    struct Permit {
        uint256 deadline;
        uint256 amount;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct PufferFinance {
        address pool;
        bool isStETH;
        Permit permit;
    }

    struct StaderETHx {
        uint256 amount;
        address recipient;
    }

    struct RFQTQuote {
        address pool;
        address externalAccount;
        address trader;
        address effectiveTrader;
        address baseToken;
        address quoteToken;
        uint256 effectiveBaseTokenAmount;
        uint256 baseTokenAmount;
        uint256 quoteTokenAmount;
        uint256 quoteExpiry;
        uint256 nonce;
        bytes32 txid;
        bytes signature;
    }

    struct Hashflow {
        address router;
        RFQTQuote quote;
    }

    struct OrderRFQ {
        // lowest 64 bits is the order id, next 64 bits is the expiration timestamp
        // highest bit is unwrap WETH flag which is set on taker's side
        // [unwrap eth(1 bit) | unused (127 bits) | expiration timestamp(64 bits) | orderId (64 bits)]
        uint256 info;
        address makerAsset;
        address takerAsset;
        address maker;
        address allowedSender; // null address on public orders
        uint256 makingAmount;
        uint256 takingAmount;
    }

    struct KyberRFQ {
        address rfq;
        OrderRFQ order;
        bytes signature;
        uint256 amount;
        address payable target;
    }

    struct Native {
        address target; // txRequest.target from api result
        uint256 amount; // should equal which amount_wei from api request
        bytes data; // txRequest.calldata from api result
        address tokenIn;
        address tokenOut;
        address recipient; // should equal which to_address from api request
        uint256 multihopAndOffset; // [1 bytes multihop + 127 bytes empty + 64 bytes amountInOffset + 64 bytes amountOutMinOffset]
    }

    struct KyberDSLO {
        address kyberLOAddress;
        address makerAsset;
        address takerAsset;
        IKyberDSLO.FillBatchOrdersParams params;
    }

    struct KyberLimitOrder {
        address kyberLOAddress;
        address makerAsset;
        address takerAsset;
        IKyberLO.FillBatchOrdersParams params;
    }

    struct Bebop {
        address pool;
        uint256 amount;
        bytes data;
        address tokenIn;
        address tokenOut;
        address recipient;
    }

    struct SymbioticLRT {
        address vault;
        uint256 amount;
        address tokenIn;
        address recipient;
        bool isVer0;
    }

    struct MaverickV2 {
        address pool;
        uint256 collectAmount; // amount that should be transferred to the pool
        address tokenIn;
        address tokenOut;
        address recipient;
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/IExecutorHelper.sol

pragma solidity ^0.8.0;



interface IExecutorHelper is IExecutorHelperStruct {
    // supported dexes
    function executeUniswap(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeStableSwap(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeCurve(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeKSClassic(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeUniV3KSElastic(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeBalV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeDODO(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeVelodrome(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeGMX(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executePlatypus(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeWrappedstETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeStEth(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeSynthetix(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeHashflow(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executePSM(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeFrax(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeCamelot(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeMaverick(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeSyncSwap(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeAlgebraV1(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeBalancerBatch(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeWombat(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeMantis(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeIziSwap(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeWooFiV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeTraderJoeV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executePancakeStableSwap(
        bytes memory data,
        uint256 flagsAndPrevAmountOut
    ) external payable returns (uint256);

    function executeLevelFiV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeGMXGLP(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeVooi(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeVelocoreV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeMaticMigrate(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeSmardex(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeSolidlyV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeKokonut(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeBalancerV1(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeSwaapV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeNomiswapStable(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeArbswapStable(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeBancorV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeBancorV3(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeAmbient(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeUniV1(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeLighterV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeEtherFieETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeEtherFiWeETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeKelp(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeRocketPool(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeEthenaSusde(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeMakersDAI(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeRenzo(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeWBETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeMantleETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeFrxETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeSfrxETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeSfrxETHConvertor(
        bytes memory data,
        uint256 flagsAndPrevAmountOut
    ) external payable returns (uint256);

    function executeSwellETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeRswETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeStaderETHx(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeOriginETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executePrimeETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeMantleUsd(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeBedrockUniETH(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeMaiPSM(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executePufferFinance(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeRfq(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeNative(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeKyberLimitOrder(
        bytes memory data,
        uint256 flagsAndPrevAmountOut
    ) external payable returns (uint256);

    function executeKyberDSLO(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeBebop(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeSymbioticLRT(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeMaverickV2(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeIntegral(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);

    function executeUsd0PP(bytes memory data, uint256 flagsAndPrevAmountOut) external payable returns (uint256);
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/IAggregationExecutor.sol

pragma solidity >=0.6.12;

interface IAggregationExecutor {
    struct Swap {
        bytes data;
        bytes32 selectorAndFlags; // [selector (32 bits) + empty (192 bits) + flags (32 bits)]; selector is 4 most significant bytes; flags are stored in 4 least significant bytes.
    }

    struct SwapExecutorDescription {
        Swap[][] swapSequences;
        address tokenIn;
        address tokenOut;
        address to;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    function callBytes(bytes calldata data) external payable; // 0xd9c45357

    // callbytes per swap sequence
    function swapSingleSequence(bytes calldata data) external;

    function finalTransactionProcessing(
        address tokenIn,
        address tokenOut,
        address to,
        bytes calldata destTokenFeeData
    ) external;
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/IMetaAggregationRouterV2.sol

pragma solidity ^0.8.0;




interface IMetaAggregationRouterV2 {
    struct SwapDescriptionV2 {
        IERC20 srcToken;
        IERC20 dstToken;
        address[] srcReceivers; // transfer src token to these addresses, default
        uint256[] srcAmounts;
        address[] feeReceivers;
        uint256[] feeAmounts;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

    /// @dev  use for swapGeneric and swap to avoid stack too deep
    struct SwapExecutionParams {
        address callTarget; // call this address
        address approveTarget; // approve this address if _APPROVE_FUND set
        bytes targetData;
        SwapDescriptionV2 desc;
        bytes clientData;
    }

    struct SimpleSwapData {
        address[] firstPools;
        uint256[] firstSwapAmounts;
        bytes[] swapDatas;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    function swap(SwapExecutionParams calldata execution) external payable returns (uint256, uint256);

    function swapSimpleMode(
        IAggregationExecutor caller,
        SwapDescriptionV2 memory desc,
        bytes calldata executorData,
        bytes calldata clientData
    ) external returns (uint256, uint256);
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/libraries/BytesHelper.sol

pragma solidity ^0.8.0;

library BytesHelper {
    function update(
        bytes memory originalCalldata,
        uint256 newAmount,
        uint256 amountInOffset
    ) internal pure returns (bytes memory) {
        require(amountInOffset + 32 <= originalCalldata.length, "Offset out of bounds");

        // Update the 32 bytes at the specified offset with the new amount
        for (uint256 i; i < 32; ++i) {
            originalCalldata[amountInOffset + i] = bytes32(newAmount)[i];
        }

        return originalCalldata;
    }

    function splitCalldata(bytes memory data) internal pure returns (bytes4 selector, bytes memory functionCalldata) {
        require(data.length >= 4, "Calldata too short");

        // Extract the selector
        assembly {
            selector := mload(add(data, 32))
        }
        // Extract the function calldata
        functionCalldata = new bytes(data.length - 4);
        for (uint256 i = 0; i < data.length - 4; i++) {
            functionCalldata[i] = data[i + 4];
        }
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l1-contracts/ScalingDataLib.sol

pragma solidity ^0.8.0;





library ScalingDataLib {
    using BytesHelper for bytes;

    function newUniSwap(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.UniSwap memory uniSwap = abi.decode(data, (IExecutorHelperStruct.UniSwap));
        uniSwap.collectAmount = (uniSwap.collectAmount * newAmount) / oldAmount;
        return abi.encode(uniSwap);
    }

    function newStableSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.StableSwap memory stableSwap = abi.decode(data, (IExecutorHelperStruct.StableSwap));
        stableSwap.dx = (stableSwap.dx * newAmount) / oldAmount;
        return abi.encode(stableSwap);
    }

    function newCurveSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.CurveSwap memory curveSwap = abi.decode(data, (IExecutorHelperStruct.CurveSwap));
        curveSwap.dx = (curveSwap.dx * newAmount) / oldAmount;
        return abi.encode(curveSwap);
    }

    function newUniV3ProMM(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.UniswapV3KSElastic memory uniSwapV3ProMM = abi.decode(
            data,
            (IExecutorHelperStruct.UniswapV3KSElastic)
        );
        uniSwapV3ProMM.swapAmount = (uniSwapV3ProMM.swapAmount * newAmount) / oldAmount;

        return abi.encode(uniSwapV3ProMM);
    }

    function newBalancerV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.BalancerV2 memory balancerV2 = abi.decode(data, (IExecutorHelperStruct.BalancerV2));
        balancerV2.amount = (balancerV2.amount * newAmount) / oldAmount;
        return abi.encode(balancerV2);
    }

    function newDODO(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.DODO memory dodo = abi.decode(data, (IExecutorHelperStruct.DODO));
        dodo.amount = (dodo.amount * newAmount) / oldAmount;
        return abi.encode(dodo);
    }

    function newGMX(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.GMX memory gmx = abi.decode(data, (IExecutorHelperStruct.GMX));
        gmx.amount = (gmx.amount * newAmount) / oldAmount;
        return abi.encode(gmx);
    }

    function newSynthetix(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Synthetix memory synthetix = abi.decode(data, (IExecutorHelperStruct.Synthetix));
        synthetix.sourceAmount = (synthetix.sourceAmount * newAmount) / oldAmount;
        return abi.encode(synthetix);
    }

    function newCamelot(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.UniSwap memory camelot = abi.decode(data, (IExecutorHelperStruct.UniSwap));
        camelot.collectAmount = (camelot.collectAmount * newAmount) / oldAmount;
        return abi.encode(camelot);
    }

    function newPlatypus(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Platypus memory platypus = abi.decode(data, (IExecutorHelperStruct.Platypus));
        platypus.collectAmount = (platypus.collectAmount * newAmount) / oldAmount;
        return abi.encode(platypus);
    }

    function newWrappedstETHSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.WSTETH memory wstEthData = abi.decode(data, (IExecutorHelperStruct.WSTETH));
        wstEthData.amount = (wstEthData.amount * newAmount) / oldAmount;
        return abi.encode(wstEthData);
    }

    function newPSM(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.PSM memory psm = abi.decode(data, (IExecutorHelperStruct.PSM));
        psm.amountIn = (psm.amountIn * newAmount) / oldAmount;
        return abi.encode(psm);
    }

    function newStETHSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 amount = abi.decode(data, (uint256));
        amount = (amount * newAmount) / oldAmount;
        return abi.encode(amount);
    }

    function newMaverick(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Maverick memory maverick = abi.decode(data, (IExecutorHelperStruct.Maverick));
        maverick.swapAmount = (maverick.swapAmount * newAmount) / oldAmount;
        return abi.encode(maverick);
    }

    function newSyncSwap(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.SyncSwap memory syncSwap = abi.decode(data, (IExecutorHelperStruct.SyncSwap));
        syncSwap.collectAmount = (syncSwap.collectAmount * newAmount) / oldAmount;
        return abi.encode(syncSwap);
    }

    function newAlgebraV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.AlgebraV1 memory algebraV1Swap = abi.decode(data, (IExecutorHelperStruct.AlgebraV1));
        algebraV1Swap.swapAmount = (algebraV1Swap.swapAmount * newAmount) / oldAmount;
        return abi.encode(algebraV1Swap);
    }

    function newBalancerBatch(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.BalancerBatch memory balancerBatch = abi.decode(
            data,
            (IExecutorHelperStruct.BalancerBatch)
        );
        balancerBatch.amountIn = (balancerBatch.amountIn * newAmount) / oldAmount;
        return abi.encode(balancerBatch);
    }

    function newMantis(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Mantis memory mantis = abi.decode(data, (IExecutorHelperStruct.Mantis));
        mantis.amount = (mantis.amount * newAmount) / oldAmount;
        return abi.encode(mantis);
    }

    function newIziSwap(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.IziSwap memory iZi = abi.decode(data, (IExecutorHelperStruct.IziSwap));
        iZi.swapAmount = (iZi.swapAmount * newAmount) / oldAmount;
        return abi.encode(iZi);
    }

    function newTraderJoeV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.TraderJoeV2 memory traderJoe = abi.decode(data, (IExecutorHelperStruct.TraderJoeV2));

        // traderJoe.collectAmount; // most significant 1 bit is to determine whether pool is v2.1, else v2.0
        traderJoe.collectAmount =
            (traderJoe.collectAmount & (1 << 255)) |
            ((uint256((traderJoe.collectAmount << 1) >> 1) * newAmount) / oldAmount);
        return abi.encode(traderJoe);
    }

    function newLevelFiV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.LevelFiV2 memory levelFiV2 = abi.decode(data, (IExecutorHelperStruct.LevelFiV2));
        levelFiV2.amountIn = (levelFiV2.amountIn * newAmount) / oldAmount;
        return abi.encode(levelFiV2);
    }

    function newGMXGLP(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.GMXGLP memory swapData = abi.decode(data, (IExecutorHelperStruct.GMXGLP));
        swapData.swapAmount = (swapData.swapAmount * newAmount) / oldAmount;
        return abi.encode(swapData);
    }

    function newVooi(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Vooi memory vooi = abi.decode(data, (IExecutorHelperStruct.Vooi));
        vooi.fromAmount = (vooi.fromAmount * newAmount) / oldAmount;
        return abi.encode(vooi);
    }

    function newVelocoreV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.VelocoreV2 memory velocorev2 = abi.decode(data, (IExecutorHelperStruct.VelocoreV2));
        velocorev2.amount = (velocorev2.amount * newAmount) / oldAmount;
        return abi.encode(velocorev2);
    }

    function newMaticMigrate(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.MaticMigrate memory maticMigrate = abi.decode(data, (IExecutorHelperStruct.MaticMigrate));
        maticMigrate.amount = (maticMigrate.amount * newAmount) / oldAmount;
        return abi.encode(maticMigrate);
    }

    function newKokonut(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Kokonut memory kokonut = abi.decode(data, (IExecutorHelperStruct.Kokonut));
        kokonut.dx = (kokonut.dx * newAmount) / oldAmount;
        return abi.encode(kokonut);
    }

    function newBalancerV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.BalancerV1 memory balancerV1 = abi.decode(data, (IExecutorHelperStruct.BalancerV1));
        balancerV1.amount = (balancerV1.amount * newAmount) / oldAmount;
        return abi.encode(balancerV1);
    }

    function newArbswapStable(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.ArbswapStable memory arbswapStable = abi.decode(
            data,
            (IExecutorHelperStruct.ArbswapStable)
        );
        arbswapStable.dx = (arbswapStable.dx * newAmount) / oldAmount;
        return abi.encode(arbswapStable);
    }

    function newBancorV2(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.BancorV2 memory bancorV2 = abi.decode(data, (IExecutorHelperStruct.BancorV2));
        bancorV2.amount = (bancorV2.amount * newAmount) / oldAmount;
        return abi.encode(bancorV2);
    }

    function newAmbient(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Ambient memory ambient = abi.decode(data, (IExecutorHelperStruct.Ambient));
        ambient.qty = uint128((uint256(ambient.qty) * newAmount) / oldAmount);
        return abi.encode(ambient);
    }

    function newLighterV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.LighterV2 memory structData = abi.decode(data, (IExecutorHelperStruct.LighterV2));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newUniV1(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.UniV1 memory structData = abi.decode(data, (IExecutorHelperStruct.UniV1));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newEtherFiWeETH(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.EtherFiWeETH memory structData = abi.decode(data, (IExecutorHelperStruct.EtherFiWeETH));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newKelp(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Kelp memory structData = abi.decode(data, (IExecutorHelperStruct.Kelp));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newEthenaSusde(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.EthenaSusde memory structData = abi.decode(data, (IExecutorHelperStruct.EthenaSusde));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newRocketPool(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.RocketPool memory structData = abi.decode(data, (IExecutorHelperStruct.RocketPool));

        uint128 _amount = uint128((uint256(uint128(structData.isDepositAndAmount)) * newAmount) / oldAmount);

        bool _isDeposit = (structData.isDepositAndAmount >> 255) == 1;

        // reset and create new variable for isDeposit and amount
        structData.isDepositAndAmount = 0;
        structData.isDepositAndAmount |= uint256(uint128(_amount));
        structData.isDepositAndAmount |= uint256(_isDeposit ? 1 : 0) << 255;

        return abi.encode(structData);
    }

    function newMakersDAI(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.MakersDAI memory structData = abi.decode(data, (IExecutorHelperStruct.MakersDAI));
        uint128 _amount = uint128((uint256(uint128(structData.isRedeemAndAmount)) * newAmount) / oldAmount);

        bool _isRedeem = (structData.isRedeemAndAmount >> 255) == 1;

        // reset and create new variable for isRedeem and amount
        structData.isRedeemAndAmount = 0;
        structData.isRedeemAndAmount |= uint256(uint128(_amount));
        structData.isRedeemAndAmount |= uint256(_isRedeem ? 1 : 0) << 255;

        return abi.encode(structData);
    }

    function newRenzo(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Renzo memory structData = abi.decode(data, (IExecutorHelperStruct.Renzo));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newFrxETH(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.FrxETH memory structData = abi.decode(data, (IExecutorHelperStruct.FrxETH));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newSfrxETH(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.SfrxETH memory structData = abi.decode(data, (IExecutorHelperStruct.SfrxETH));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newSfrxETHConvertor(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.SfrxETHConvertor memory structData = abi.decode(
            data,
            (IExecutorHelperStruct.SfrxETHConvertor)
        );

        uint128 _amount = uint128((uint256(uint128(structData.isDepositAndAmount)) * newAmount) / oldAmount);

        bool _isDeposit = (structData.isDepositAndAmount >> 255) == 1;

        // reset and create new variable for isDeposit and amount
        structData.isDepositAndAmount = 0;
        structData.isDepositAndAmount |= uint256(uint128(_amount));
        structData.isDepositAndAmount |= uint256(_isDeposit ? 1 : 0) << 255;

        return abi.encode(structData);
    }

    function newOriginETH(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.OriginETH memory structData = abi.decode(data, (IExecutorHelperStruct.OriginETH));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newMantleUsd(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 isWrapAndAmount = abi.decode(data, (uint256));

        uint128 _amount = uint128((uint256(uint128(isWrapAndAmount)) * newAmount) / oldAmount);

        bool _isWrap = (isWrapAndAmount >> 255) == 1;

        // reset and create new variable for isWrap and amount
        isWrapAndAmount = 0;
        isWrapAndAmount |= uint256(uint128(_amount));
        isWrapAndAmount |= uint256(_isWrap ? 1 : 0) << 255;

        return abi.encode(isWrapAndAmount);
    }

    function newPufferFinance(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.PufferFinance memory structData = abi.decode(data, (IExecutorHelperStruct.PufferFinance));
        structData.permit.amount = uint128((uint256(structData.permit.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newKyberRfq(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.KyberRFQ memory structData = abi.decode(data, (IExecutorHelperStruct.KyberRFQ));
        structData.amount = (structData.amount * newAmount) / oldAmount;
        return abi.encode(structData);
    }

    function newKyberLimitOrder(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.KyberLimitOrder memory structData = abi.decode(
            data,
            (IExecutorHelperStruct.KyberLimitOrder)
        );
        structData.params.takingAmount = (structData.params.takingAmount * newAmount) / oldAmount;
        structData.params.thresholdAmount = 1;
        return abi.encode(structData);
    }

    function newKyberDSLO(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.KyberDSLO memory structData = abi.decode(data, (IExecutorHelperStruct.KyberDSLO));
        structData.params.takingAmount = (structData.params.takingAmount * newAmount) / oldAmount;
        structData.params.thresholdAmount = 1;
        return abi.encode(structData);
    }

    function newNative(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        require(newAmount < oldAmount, "Native: not support scale up");

        IExecutorHelperStruct.Native memory structData = abi.decode(data, (IExecutorHelperStruct.Native));

        require(structData.multihopAndOffset >> 255 == 0, "Native: Multihop not supported");

        structData.amount = (structData.amount * newAmount) / oldAmount;

        uint256 amountInOffset = uint256(uint64(structData.multihopAndOffset >> 64));
        uint256 amountOutMinOffset = uint256(uint64(structData.multihopAndOffset));
        bytes memory newCallData = structData.data;

        newCallData = newCallData.update(structData.amount, amountInOffset);

        // update amount out min if needed
        if (amountOutMinOffset != 0) {
            newCallData = newCallData.update(1, amountOutMinOffset);
        }

        return abi.encode(structData);
    }

    function newHashflow(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.Hashflow memory structData = abi.decode(data, (IExecutorHelperStruct.Hashflow));
        structData.quote.effectiveBaseTokenAmount = (structData.quote.effectiveBaseTokenAmount * newAmount) / oldAmount;
        return abi.encode(structData);
    }

    function newBebop(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        require(newAmount < oldAmount, "Bebop: not support scale up");

        IExecutorHelperStruct.Bebop memory structData = abi.decode(data, (IExecutorHelperStruct.Bebop));

        structData.amount = (structData.amount * newAmount) / oldAmount;

        // update calldata with new swap amount
        (bytes4 selector, bytes memory callData) = structData.data.splitCalldata();

        (IBebopV3.Single memory s, IBebopV3.MakerSignature memory m, ) = abi.decode(
            callData,
            (IBebopV3.Single, IBebopV3.MakerSignature, uint256)
        );
        structData.data = bytes.concat(bytes4(selector), abi.encode(s, m, structData.amount));

        return abi.encode(structData);
    }

    function newSymbioticLRT(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.SymbioticLRT memory structData = abi.decode(data, (IExecutorHelperStruct.SymbioticLRT));
        structData.amount = (structData.amount * newAmount) / oldAmount;
        return abi.encode(structData);
    }

    function newMaverickV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperStruct.MaverickV2 memory structData = abi.decode(data, (IExecutorHelperStruct.MaverickV2));
        structData.collectAmount = (structData.collectAmount * newAmount) / oldAmount;
        return abi.encode(structData);
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l1-contracts/InputScalingHelper.sol

pragma solidity ^0.8.0;






/* ----------------------------------------
.__   __.   ______   .___________. _______
|  \ |  |  /  __  \  |           ||   ____|
|   \|  | |  |  |  | `---|  |----`|  |__
|  . `  | |  |  |  |     |  |     |   __|
|  |\   | |  `--'  |     |  |     |  |____
|__| \__|  \______/      |__|     |_______|


Please use InputScalingHelperL2 contract for scaling data on Arbitrum, Optimism, Base

---------------------------------------- */

library InputScalingHelper {
    uint256 private constant _PARTIAL_FILL = 0x01;
    uint256 private constant _REQUIRES_EXTRA_ETH = 0x02;
    uint256 private constant _SHOULD_CLAIM = 0x04;
    uint256 private constant _BURN_FROM_MSG_SENDER = 0x08;
    uint256 private constant _BURN_FROM_TX_ORIGIN = 0x10;
    uint256 private constant _SIMPLE_SWAP = 0x20;

    // fee data in case taking in dest token
    struct PositiveSlippageFeeData {
        uint256 partnerPSInfor; // [partnerReceiver (160 bit) + partnerPercent(96bits)]
        uint256 expectedReturnAmount;
    }

    struct Swap {
        bytes data;
        bytes32 selectorAndFlags; // [selector (32 bits) + flags (224 bits)]; selector is 4 most significant bytes; flags are stored in 4 least significant bytes.
    }

    struct SimpleSwapData {
        address[] firstPools;
        uint256[] firstSwapAmounts;
        bytes[] swapDatas;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    struct SwapExecutorDescription {
        Swap[][] swapSequences;
        address tokenIn;
        address tokenOut;
        address to;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    function _getScaledInputData(bytes calldata inputData, uint256 newAmount) internal pure returns (bytes memory) {
        bytes4 selector = bytes4(inputData[:4]);
        bytes calldata dataToDecode = inputData[4:];

        if (selector == IMetaAggregationRouterV2.swap.selector) {
            IMetaAggregationRouterV2.SwapExecutionParams memory params = abi.decode(
                dataToDecode,
                (IMetaAggregationRouterV2.SwapExecutionParams)
            );

            (params.desc, params.targetData) = _getScaledInputDataV2(
                params.desc,
                params.targetData,
                newAmount,
                _flagsChecked(params.desc.flags, _SIMPLE_SWAP)
            );
            return abi.encodeWithSelector(selector, params);
        } else if (selector == IMetaAggregationRouterV2.swapSimpleMode.selector) {
            (
                address callTarget,
                IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
                bytes memory targetData,
                bytes memory clientData
            ) = abi.decode(dataToDecode, (address, IMetaAggregationRouterV2.SwapDescriptionV2, bytes, bytes));

            (desc, targetData) = _getScaledInputDataV2(desc, targetData, newAmount, true);
            return abi.encodeWithSelector(selector, callTarget, desc, targetData, clientData);
        } else {
            revert("InputScalingHelper: Invalid selector");
        }
    }

    function _getScaledInputDataV2(
        IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
        bytes memory executorData,
        uint256 newAmount,
        bool isSimpleMode
    ) internal pure returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory, bytes memory) {
        uint256 oldAmount = desc.amount;
        if (oldAmount == newAmount) {
            return (desc, executorData);
        }

        // simple mode swap
        if (isSimpleMode) {
            return (
                _scaledSwapDescriptionV2(desc, oldAmount, newAmount),
                _scaledSimpleSwapData(executorData, oldAmount, newAmount)
            );
        }

        //normal mode swap
        return (
            _scaledSwapDescriptionV2(desc, oldAmount, newAmount),
            _scaledExecutorCallBytesData(executorData, oldAmount, newAmount)
        );
    }

    /// @dev Scale the swap description
    function _scaledSwapDescriptionV2(
        IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory) {
        desc.minReturnAmount = (desc.minReturnAmount * newAmount) / oldAmount;
        if (desc.minReturnAmount == 0) desc.minReturnAmount = 1;
        desc.amount = newAmount;

        uint256 nReceivers = desc.srcReceivers.length;
        for (uint256 i = 0; i < nReceivers; ) {
            desc.srcAmounts[i] = (desc.srcAmounts[i] * newAmount) / oldAmount;
            unchecked {
                ++i;
            }
        }
        return desc;
    }

    /// @dev Scale the executorData in case swapSimpleMode
    function _scaledSimpleSwapData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        SimpleSwapData memory swapData = abi.decode(data, (SimpleSwapData));

        uint256 nPools = swapData.firstPools.length;
        for (uint256 i = 0; i < nPools; ) {
            swapData.firstSwapAmounts[i] = (swapData.firstSwapAmounts[i] * newAmount) / oldAmount;
            unchecked {
                ++i;
            }
        }
        swapData.positiveSlippageData = _scaledPositiveSlippageFeeData(
            swapData.positiveSlippageData,
            oldAmount,
            newAmount
        );
        return abi.encode(swapData);
    }

    /// @dev Scale the executorData in case normal swap
    function _scaledExecutorCallBytesData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        SwapExecutorDescription memory executorDesc = abi.decode(data, (SwapExecutorDescription));
        executorDesc.positiveSlippageData = _scaledPositiveSlippageFeeData(
            executorDesc.positiveSlippageData,
            oldAmount,
            newAmount
        );

        uint256 nSequences = executorDesc.swapSequences.length;
        for (uint256 i = 0; i < nSequences; ) {
            Swap memory swap = executorDesc.swapSequences[i][0];
            bytes4 functionSelector = bytes4(swap.selectorAndFlags);

            if (
                functionSelector == IExecutorHelper.executeUniswap.selector ||
                functionSelector == IExecutorHelper.executeFrax.selector ||
                functionSelector == IExecutorHelper.executeVelodrome.selector ||
                functionSelector == IExecutorHelper.executeKSClassic.selector
            ) {
                swap.data = ScalingDataLib.newUniSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeStableSwap.selector) {
                swap.data = ScalingDataLib.newStableSwap(swap.data, oldAmount, newAmount);
            } else if (
                functionSelector == IExecutorHelper.executeCurve.selector ||
                functionSelector == IExecutorHelper.executePancakeStableSwap.selector
            ) {
                swap.data = ScalingDataLib.newCurveSwap(swap.data, oldAmount, newAmount);
            } else if (
                functionSelector == IExecutorHelper.executeStEth.selector ||
                functionSelector == IExecutorHelper.executeEtherFieETH.selector ||
                functionSelector == IExecutorHelper.executeWBETH.selector ||
                functionSelector == IExecutorHelper.executeMantleETH.selector ||
                functionSelector == IExecutorHelper.executeSwellETH.selector ||
                functionSelector == IExecutorHelper.executeRswETH.selector ||
                functionSelector == IExecutorHelper.executeBedrockUniETH.selector ||
                functionSelector == IExecutorHelper.executeUsd0PP.selector
            ) {
                swap.data = ScalingDataLib.newStETHSwap(swap.data, oldAmount, newAmount);
            } else if (
                functionSelector == IExecutorHelper.executeFrxETH.selector ||
                functionSelector == IExecutorHelper.executeMaiPSM.selector
            ) {
                swap.data = ScalingDataLib.newFrxETH(swap.data, oldAmount, newAmount);
            } else if (
                functionSelector == IExecutorHelper.executeMantis.selector ||
                functionSelector == IExecutorHelper.executeWombat.selector ||
                functionSelector == IExecutorHelper.executeWooFiV2.selector ||
                functionSelector == IExecutorHelper.executeSmardex.selector ||
                functionSelector == IExecutorHelper.executeSolidlyV2.selector ||
                functionSelector == IExecutorHelper.executeNomiswapStable.selector ||
                functionSelector == IExecutorHelper.executeBancorV3.selector
            ) {
                swap.data = ScalingDataLib.newMantis(swap.data, oldAmount, newAmount);
            } else if (
                functionSelector == IExecutorHelper.executeOriginETH.selector ||
                functionSelector == IExecutorHelper.executePrimeETH.selector
            ) {
                swap.data = ScalingDataLib.newOriginETH(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeUniV3KSElastic.selector) {
                swap.data = ScalingDataLib.newUniV3ProMM(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBalV2.selector) {
                swap.data = ScalingDataLib.newBalancerV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeWrappedstETH.selector) {
                swap.data = ScalingDataLib.newWrappedstETHSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeDODO.selector) {
                swap.data = ScalingDataLib.newDODO(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeGMX.selector) {
                swap.data = ScalingDataLib.newGMX(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSynthetix.selector) {
                swap.data = ScalingDataLib.newSynthetix(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeCamelot.selector) {
                swap.data = ScalingDataLib.newCamelot(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executePSM.selector) {
                swap.data = ScalingDataLib.newPSM(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executePlatypus.selector) {
                swap.data = ScalingDataLib.newPlatypus(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeMaverick.selector) {
                swap.data = ScalingDataLib.newMaverick(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSyncSwap.selector) {
                swap.data = ScalingDataLib.newSyncSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeAlgebraV1.selector) {
                swap.data = ScalingDataLib.newAlgebraV1(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBalancerBatch.selector) {
                swap.data = ScalingDataLib.newBalancerBatch(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeIziSwap.selector) {
                swap.data = ScalingDataLib.newIziSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeTraderJoeV2.selector) {
                swap.data = ScalingDataLib.newTraderJoeV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeLevelFiV2.selector) {
                swap.data = ScalingDataLib.newLevelFiV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeGMXGLP.selector) {
                swap.data = ScalingDataLib.newGMXGLP(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeVooi.selector) {
                swap.data = ScalingDataLib.newVooi(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeVelocoreV2.selector) {
                swap.data = ScalingDataLib.newVelocoreV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeMaticMigrate.selector) {
                swap.data = ScalingDataLib.newMaticMigrate(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeKokonut.selector) {
                swap.data = ScalingDataLib.newKokonut(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBalancerV1.selector) {
                swap.data = ScalingDataLib.newBalancerV1(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeArbswapStable.selector) {
                swap.data = ScalingDataLib.newArbswapStable(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBancorV2.selector) {
                swap.data = ScalingDataLib.newBancorV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeAmbient.selector) {
                swap.data = ScalingDataLib.newAmbient(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeLighterV2.selector) {
                swap.data = ScalingDataLib.newLighterV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeUniV1.selector) {
                swap.data = ScalingDataLib.newUniV1(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeEtherFiWeETH.selector) {
                swap.data = ScalingDataLib.newEtherFiWeETH(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeKelp.selector) {
                swap.data = ScalingDataLib.newKelp(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeEthenaSusde.selector) {
                swap.data = ScalingDataLib.newEthenaSusde(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeRocketPool.selector) {
                swap.data = ScalingDataLib.newRocketPool(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeMakersDAI.selector) {
                swap.data = ScalingDataLib.newMakersDAI(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeRenzo.selector) {
                swap.data = ScalingDataLib.newRenzo(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSfrxETH.selector) {
                swap.data = ScalingDataLib.newSfrxETH(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSfrxETHConvertor.selector) {
                swap.data = ScalingDataLib.newSfrxETHConvertor(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeStaderETHx.selector) {
                swap.data = ScalingDataLib.newEthenaSusde(swap.data, oldAmount, newAmount); // same ethena susde
            } else if (functionSelector == IExecutorHelper.executeMantleUsd.selector) {
                swap.data = ScalingDataLib.newMantleUsd(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executePufferFinance.selector) {
                swap.data = ScalingDataLib.newPufferFinance(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeRfq.selector) {
                swap.data = ScalingDataLib.newKyberRfq(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeKyberLimitOrder.selector) {
                swap.data = ScalingDataLib.newKyberLimitOrder(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeKyberDSLO.selector) {
                swap.data = ScalingDataLib.newKyberDSLO(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeNative.selector) {
                swap.data = ScalingDataLib.newNative(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeHashflow.selector) {
                swap.data = ScalingDataLib.newHashflow(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBebop.selector) {
                swap.data = ScalingDataLib.newBebop(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSymbioticLRT.selector) {
                swap.data = ScalingDataLib.newSymbioticLRT(swap.data, oldAmount, newAmount);
            } else if (
                functionSelector == IExecutorHelper.executeMaverickV2.selector ||
                functionSelector == IExecutorHelper.executeIntegral.selector
            ) {
                swap.data = ScalingDataLib.newMaverickV2(swap.data, oldAmount, newAmount);
            } else {
                // SwaapV2
                revert("AggregationExecutor: Dex type not supported");
            }
            unchecked {
                ++i;
            }
        }
        return abi.encode(executorDesc);
    }

    function _scaledPositiveSlippageFeeData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory newData) {
        if (data.length > 32) {
            PositiveSlippageFeeData memory psData = abi.decode(data, (PositiveSlippageFeeData));
            uint256 left = uint256(psData.expectedReturnAmount >> 128);
            uint256 right = (uint256(uint128(psData.expectedReturnAmount)) * newAmount) / oldAmount;
            require(right <= type(uint128).max, "Exceeded type range");
            psData.expectedReturnAmount = right | (left << 128);
            data = abi.encode(psData);
        } else if (data.length == 32) {
            uint256 expectedReturnAmount = abi.decode(data, (uint256));
            uint256 left = uint256(expectedReturnAmount >> 128);
            uint256 right = (uint256(uint128(expectedReturnAmount)) * newAmount) / oldAmount;
            require(right <= type(uint128).max, "Exceeded type range");
            expectedReturnAmount = right | (left << 128);
            data = abi.encode(expectedReturnAmount);
        }
        return data;
    }

    function _flagsChecked(uint256 number, uint256 flag) internal pure returns (bool) {
        return number & flag != 0;
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/IAggregationExecutorOptimistic.sol

pragma solidity >=0.6.12;

interface IAggregationExecutorOptimistic {
    event Exchange(address pair, uint256 amountOut, address output);

    struct Swap {
        bytes data;
        bytes4 functionSelector;
    }

    struct SwapCallbackData {
        bytes path;
        address payer;
    }

    struct SwapCallbackDataPath {
        address pool;
        address tokenIn;
        address tokenOut;
    }

    struct PositiveSlippageFeeData {
        uint256 partnerPSInfor; // [partnerReceiver (160 bit) + partnerPercent(96bits)]
        uint256 expectedReturnAmount; // [minimumPSAmount (128 bits) + expectedReturnAmount (128 bits)]
    }

    struct SwapExecutorDescription {
        Swap[][] swapSequences;
        address tokenIn;
        address tokenOut;
        address to;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    function rescueFunds(address token, uint256 amount) external;

    function callBytes(bytes calldata data) external payable;

    function swapSingleSequence(bytes calldata data) external;

    function multihopBatchSwapExactIn(
        Swap[][] memory swapSequences,
        address tokenIn,
        address tokenOut,
        address to,
        uint256 deadline,
        bytes memory positiveSlippageData
    ) external payable;

    function finalTransactionProcessing(
        address tokenIn,
        address tokenOut,
        address to,
        bytes calldata destTokenFeeData
    ) external;

    function updateExecutor(bytes4 functionSelector, address executor) external;

    function updateBatchExecutors(bytes4[] memory functionSelectors, address[] memory executors) external;
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/IExecutorHelperL2Struct.sol

pragma solidity ^0.8.0;




interface IExecutorHelperL2Struct {
    struct Swap {
        bytes data;
        bytes4 functionSelector;
    }

    struct SwapExecutorDescription {
        Swap[][] swapSequences;
        address tokenIn;
        address tokenOut;
        uint256 minTotalAmountOut;
        address to;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    struct UniSwap {
        address pool;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 collectAmount; // amount that should be transferred to the pool
        uint32 swapFee;
        uint32 feePrecision;
        uint32 tokenWeightInput;
    }

    struct StableSwap {
        address pool;
        address tokenFrom;
        address tokenTo;
        uint8 tokenIndexFrom;
        uint8 tokenIndexTo;
        uint256 dx;
        uint256 poolLength;
        address poolLp;
        bool isSaddle; // true: saddle, false: stable
    }

    struct CurveSwap {
        address pool;
        address tokenFrom;
        address tokenTo;
        int128 tokenIndexFrom;
        int128 tokenIndexTo;
        uint256 dx;
        bool usePoolUnderlying;
        bool useTriCrypto;
    }

    struct UniswapV3KSElastic {
        address recipient;
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount;
        uint160 sqrtPriceLimitX96;
        bool isUniV3; // true = UniV3, false = KSElastic
    }

    struct SwapCallbackData {
        bytes path;
        address payer;
    }

    struct SwapCallbackDataPath {
        address pool;
        address tokenIn;
        address tokenOut;
    }

    struct BalancerV2 {
        address vault;
        bytes32 poolId;
        address assetIn;
        address assetOut;
        uint256 amount;
    }

    struct DODO {
        address recipient;
        address pool;
        address tokenFrom;
        address tokenTo;
        uint256 amount;
        address sellHelper;
        bool isSellBase;
        bool isVersion2;
    }

    struct GMX {
        address vault;
        address tokenIn;
        address tokenOut;
        uint256 amount;
        address receiver;
    }

    struct Synthetix {
        address synthetixProxy;
        address tokenIn;
        address tokenOut;
        bytes32 sourceCurrencyKey;
        uint256 sourceAmount;
        bytes32 destinationCurrencyKey;
        bool useAtomicExchange;
    }

    struct WSTETH {
        address pool;
        uint256 amount;
        bool isWrapping;
    }

    struct Platypus {
        address pool;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 collectAmount; // amount that should be transferred to the pool
    }

    struct PSM {
        address router;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        address recipient;
    }

    struct Maverick {
        address pool;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 swapAmount;
        uint256 sqrtPriceLimitD18;
    }

    /// @notice Struct for Sync Swap
    /// @param _data encode of (address, address, uint8) : (tokenIn, recipient, withdrawMode)
    ///  Withdraw with mode.
    // 0 = DEFAULT
    // 1 = UNWRAPPED
    // 2 = WRAPPED
    /// @param vault vault contract
    /// @param tokenIn token input to swap
    /// @param pool pool of SyncSwap
    /// @param collectAmount amount that should be transferred to the pool
    struct SyncSwap {
        bytes _data;
        address vault;
        address tokenIn;
        address pool;
        uint256 collectAmount;
    }

    struct AlgebraV1 {
        address recipient;
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount;
        uint160 sqrtPriceLimitX96;
        uint256 senderFeeOnTransfer; // [ FoT_FLAG(1 bit) ... SENDER_ADDRESS(160 bits) ]
    }

    struct BalancerBatch {
        address vault;
        bytes32[] poolIds;
        address[] path; // swap path from assetIn to assetOut
        bytes[] userDatas;
        uint256 amountIn; // assetIn amount
    }

    struct Mantis {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amount;
        address recipient;
    }

    struct IziSwap {
        address pool;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 swapAmount;
        int24 limitPoint;
    }

    struct TraderJoeV2 {
        address recipient;
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 collectAmount; // most significant 1 bit is to determine whether pool is v2.0, else v2.1
    }

    struct LevelFiV2 {
        address pool;
        address fromToken;
        address toToken;
        uint256 amountIn;
        uint256 minAmountOut;
        address recipient; // receive token out
    }

    struct GMXGLP {
        address rewardRouter;
        address stakedGLP;
        address glpManager;
        address yearnVault;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount;
        address recipient;
    }

    struct Vooi {
        address pool;
        address fromToken;
        address toToken;
        uint256 fromID;
        uint256 toID;
        uint256 fromAmount;
        address to;
    }

    struct VelocoreV2 {
        address vault;
        uint256 amount;
        address tokenIn;
        address tokenOut;
        address stablePool; // if not empty then use stable pool
        address wrapToken;
        bool isConvertFirst;
    }

    struct MaticMigrate {
        address pool;
        address tokenAddress; // should be POL
        uint256 amount;
        address recipient; // empty if migrate
    }

    struct Kokonut {
        address pool;
        uint256 dx;
        uint256 tokenIndexFrom;
        address fromToken;
        address toToken;
    }

    struct BalancerV1 {
        address pool;
        uint256 amount;
        address tokenIn;
        address tokenOut;
    }

    struct ArbswapStable {
        address pool;
        uint256 dx;
        uint256 tokenIndexFrom;
        address tokenIn;
        address tokenOut;
    }

    struct BancorV2 {
        address pool;
        address[] swapPath;
        uint256 amount;
        address recipient;
    }

    struct Ambient {
        address pool;
        uint128 qty;
        address base;
        address quote;
        uint256 poolIdx;
        uint8 settleFlags;
    }

    struct LighterV2 {
        address orderBook;
        uint256 amount;
        bool isAsk; // isAsk = orderBook.isAskOrder(orderId);
        address tokenIn;
        address tokenOut;
        address recipient;
    }

    struct FrxETH {
        address pool;
        uint256 amount;
        address tokenOut;
    }

    struct RFQTQuote {
        address pool;
        address externalAccount;
        address trader;
        address effectiveTrader;
        address baseToken;
        address quoteToken;
        uint256 effectiveBaseTokenAmount;
        uint256 baseTokenAmount;
        uint256 quoteTokenAmount;
        uint256 quoteExpiry;
        uint256 nonce;
        bytes32 txid;
        bytes signature;
    }

    struct Hashflow {
        address router;
        RFQTQuote quote;
    }

    struct OrderRFQ {
        // lowest 64 bits is the order id, next 64 bits is the expiration timestamp
        // highest bit is unwrap WETH flag which is set on taker's side
        // [unwrap eth(1 bit) | unused (127 bits) | expiration timestamp(64 bits) | orderId (64 bits)]
        uint256 info;
        address makerAsset;
        address takerAsset;
        address maker;
        address allowedSender; // null address on public orders
        uint256 makingAmount;
        uint256 takingAmount;
    }

    struct KyberRFQ {
        address rfq;
        OrderRFQ order;
        bytes signature;
        uint256 amount;
        address payable target;
    }

    struct Native {
        address target; // txRequest.target from api result
        uint256 amount; // should equal which amount_wei from api request
        bytes data; // txRequest.calldata from api result
        address tokenIn;
        address tokenOut;
        address recipient; // should equal which to_address from api request
        uint256 multihopAndOffset; // [1 bytes multihop + 127 bytes empty + 64 bytes amountInOffset + 64 bytes amountOutMinOffset]
    }

    struct KyberDSLO {
        address kyberLOAddress;
        address makerAsset;
        address takerAsset;
        IKyberDSLO.FillBatchOrdersParams params;
    }

    struct Bebop {
        address pool;
        uint256 amount;
        bytes data;
        address tokenIn;
        address tokenOut;
        address recipient;
    }

    struct KyberLimitOrder {
        address kyberLOAddress;
        address makerAsset;
        address takerAsset;
        IKyberLO.FillBatchOrdersParams params;
    }

    struct Kelp {
        address pool;
        uint256 amount;
        address tokenIn;
        address tokenOut;
    }

    struct SymbioticLRT {
        address vault;
        uint256 amount;
        address tokenIn;
        address recipient;
        bool isVer0;
    }

    struct MaverickV2 {
        address pool;
        uint256 collectAmount; // amount that should be transferred to the pool
        address tokenIn; // not encode for l2
        address tokenOut; // not encode for l2
        address recipient;
    }

    struct Integral {
        address pool;
        uint256 collectAmount;
        address tokenIn; // remove for L2
        address tokenOut;
        address recipient;
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l2-contracts/CalldataReader.sol

pragma solidity ^0.8.0;





library CalldataReader {
    /// @notice read the bytes value of data from a starting position and length
    /// @param data bytes array of data
    /// @param startByte starting position to read
    /// @param length length from starting position
    /// @return retVal value of the bytes
    /// @return (the next position to read from)
    function _calldataVal(
        bytes memory data,
        uint256 startByte,
        uint256 length
    ) internal pure returns (bytes memory retVal, uint256) {
        require(length + startByte <= data.length, "calldataVal trying to read beyond data size");
        uint256 loops = (length + 31) / 32;
        assembly {
            let m := mload(0x40)
            mstore(m, length)
            for {
                let i := 0
            } lt(i, loops) {
                i := add(1, i)
            } {
                mstore(add(m, mul(32, add(1, i))), mload(add(data, add(mul(32, add(1, i)), startByte))))
            }
            mstore(0x40, add(m, add(32, length)))
            retVal := m
        }
        return (retVal, length + startByte);
    }

    function _readRFQTQuote(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (L2Struct.RFQTQuote memory rfqQuote, uint256, uint256 ebtaStartByte) {
        (rfqQuote.pool, startByte) = _readAddress(data, startByte);
        (rfqQuote.externalAccount, startByte) = _readAddress(data, startByte);
        (rfqQuote.trader, startByte) = _readAddress(data, startByte);
        (rfqQuote.effectiveTrader, startByte) = _readAddress(data, startByte);
        // (rfqQuote.baseToken, startByte) = _readAddress(data, startByte);
        (rfqQuote.quoteToken, startByte) = _readAddress(data, startByte);
        ebtaStartByte = startByte;
        (rfqQuote.effectiveBaseTokenAmount, startByte) = _readUint128AsUint256(data, startByte);
        (rfqQuote.baseTokenAmount, startByte) = _readUint128AsUint256(data, startByte);
        (rfqQuote.quoteTokenAmount, startByte) = _readUint128AsUint256(data, startByte);
        (rfqQuote.quoteExpiry, startByte) = _readUint128AsUint256(data, startByte);
        (rfqQuote.nonce, startByte) = _readUint128AsUint256(data, startByte);
        (rfqQuote.txid, startByte) = _readBytes32(data, startByte);
        (rfqQuote.signature, startByte) = _readBytes(data, startByte);
        return (rfqQuote, startByte, ebtaStartByte);
    }

    function _readOrderRFQ(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (L2Struct.OrderRFQ memory orderRfq, uint256) {
        (orderRfq.info, startByte) = _readUint256(data, startByte);

        (orderRfq.makerAsset, startByte) = _readAddress(data, startByte);

        (orderRfq.takerAsset, startByte) = _readAddress(data, startByte);

        (orderRfq.maker, startByte) = _readAddress(data, startByte);

        (orderRfq.allowedSender, startByte) = _readAddress(data, startByte);

        (orderRfq.makingAmount, startByte) = _readUint128AsUint256(data, startByte);

        (orderRfq.takingAmount, startByte) = _readUint128AsUint256(data, startByte);

        return (orderRfq, startByte);
    }

    function _readDSLOFillBatchOrdersParams(
        bytes memory data,
        uint256 startByte
    )
        internal
        pure
        returns (
            IKyberDSLO.FillBatchOrdersParams memory params,
            uint256,
            uint256 takingAmountStartByte,
            uint256 thresholdStartByte
        )
    {
        (params.orders, startByte) = _readDSLOOrderArray(data, startByte);

        (params.signatures, startByte) = _readDSLOSignatureArray(data, startByte);

        (params.opExpireTimes, startByte) = _readUint32Array(data, startByte);

        // read taking amount and start byte to scale
        takingAmountStartByte = startByte;
        (params.takingAmount, startByte) = _readUint128AsUint256(data, startByte);

        // read threshold amount and start byte to update if scale dơn
        thresholdStartByte = startByte;
        (params.thresholdAmount, startByte) = _readUint128AsUint256(data, startByte);

        (params.target, startByte) = _readAddress(data, startByte);
        return (params, startByte, takingAmountStartByte, thresholdStartByte);
    }

    function _readLOFillBatchOrdersParams(
        bytes memory data,
        uint256 startByte
    )
        internal
        pure
        returns (
            IKyberLO.FillBatchOrdersParams memory params,
            uint256,
            uint256 takingAmountStartByte,
            uint256 thresholdStartByte
        )
    {
        (params.orders, startByte) = _readLOOrderArray(data, startByte);

        (params.signatures, startByte) = _readLOSignatureArray(data, startByte);

        takingAmountStartByte = startByte;
        (params.takingAmount, startByte) = _readUint128AsUint256(data, startByte);

        thresholdStartByte = startByte;
        (params.thresholdAmount, startByte) = _readUint128AsUint256(data, startByte);

        (params.target, startByte) = _readAddress(data, startByte);
        return (params, startByte, takingAmountStartByte, thresholdStartByte);
    }

    function _readLOSignatureArray(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (bytes[] memory signatures, uint256) {
        bytes memory ret;

        (ret, startByte) = _calldataVal(data, startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));

        signatures = new bytes[](length);
        for (uint8 i = 0; i < length; ++i) {
            (signatures[i], startByte) = _readBytes(data, startByte);
        }
        return (signatures, startByte);
    }

    function _readDSLOSignatureArray(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (IKyberDSLO.Signature[] memory signatures, uint256) {
        bytes memory ret;

        (ret, startByte) = _calldataVal(data, startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));

        signatures = new IKyberDSLO.Signature[](length);
        for (uint8 i = 0; i < length; ++i) {
            (signatures[i], startByte) = _readDSLOSignature(data, startByte);
        }
        return (signatures, startByte);
    }

    function _readDSLOSignature(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (IKyberDSLO.Signature memory signature, uint256) {
        (signature.orderSignature, startByte) = _readBytes(data, startByte);
        (signature.opSignature, startByte) = _readBytes(data, startByte);
        return (signature, startByte);
    }

    function _readLOOrderArray(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (IKyberLO.Order[] memory orders, uint256) {
        bytes memory ret;

        (ret, startByte) = _calldataVal(data, startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));

        orders = new IKyberLO.Order[](length);
        for (uint8 i = 0; i < length; ++i) {
            (orders[i], startByte) = _readLOOrder(data, startByte);
        }
        return (orders, startByte);
    }

    function _readDSLOOrderArray(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (IKyberDSLO.Order[] memory orders, uint256) {
        bytes memory ret;

        (ret, startByte) = _calldataVal(data, startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));

        orders = new IKyberDSLO.Order[](length);
        for (uint8 i = 0; i < length; ++i) {
            (orders[i], startByte) = _readDSLOOrder(data, startByte);
        }
        return (orders, startByte);
    }

    function _readDSLOOrder(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (IKyberDSLO.Order memory orders, uint256) {
        (orders.salt, startByte) = _readUint128AsUint256(data, startByte);
        (orders.makerAsset, startByte) = _readAddress(data, startByte);
        (orders.takerAsset, startByte) = _readAddress(data, startByte);
        (orders.maker, startByte) = _readAddress(data, startByte);
        (orders.receiver, startByte) = _readAddress(data, startByte);
        (orders.allowedSender, startByte) = _readAddress(data, startByte);
        (orders.makingAmount, startByte) = _readUint128AsUint256(data, startByte);
        (orders.takingAmount, startByte) = _readUint128AsUint256(data, startByte);
        (orders.feeConfig, startByte) = _readUint200(data, startByte);
        (orders.makerAssetData, startByte) = _readBytes(data, startByte);
        (orders.takerAssetData, startByte) = _readBytes(data, startByte);
        (orders.getMakerAmount, startByte) = _readBytes(data, startByte);
        (orders.getTakerAmount, startByte) = _readBytes(data, startByte);
        (orders.predicate, startByte) = _readBytes(data, startByte);
        (orders.interaction, startByte) = _readBytes(data, startByte);
        return (orders, startByte);
    }

    function _readLOOrder(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (IKyberLO.Order memory orders, uint256) {
        (orders.salt, startByte) = _readUint128AsUint256(data, startByte);
        (orders.makerAsset, startByte) = _readAddress(data, startByte);
        (orders.takerAsset, startByte) = _readAddress(data, startByte);
        (orders.maker, startByte) = _readAddress(data, startByte);
        (orders.receiver, startByte) = _readAddress(data, startByte);
        (orders.allowedSender, startByte) = _readAddress(data, startByte);
        (orders.makingAmount, startByte) = _readUint128AsUint256(data, startByte);
        (orders.takingAmount, startByte) = _readUint128AsUint256(data, startByte);
        (orders.feeRecipient, startByte) = _readAddress(data, startByte);
        (orders.makerTokenFeePercent, startByte) = _readUint32(data, startByte);
        (orders.makerAssetData, startByte) = _readBytes(data, startByte);
        (orders.takerAssetData, startByte) = _readBytes(data, startByte);
        (orders.getMakerAmount, startByte) = _readBytes(data, startByte);
        (orders.getTakerAmount, startByte) = _readBytes(data, startByte);
        (orders.predicate, startByte) = _readBytes(data, startByte);
        (orders.permit, startByte) = _readBytes(data, startByte);
        (orders.interaction, startByte) = _readBytes(data, startByte);
        return (orders, startByte);
    }

    function _readBool(bytes memory data, uint256 startByte) internal pure returns (bool, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 1);
        return (bytes1(ret) > 0, startByte);
    }

    function _readUint8(bytes memory data, uint256 startByte) internal pure returns (uint8, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 1);
        return (uint8(bytes1(ret)), startByte);
    }

    function _readUint24(bytes memory data, uint256 startByte) internal pure returns (uint24, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 3);
        return (uint24(bytes3(ret)), startByte);
    }

    function _readUint32(bytes memory data, uint256 startByte) internal pure returns (uint32, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 4);
        return (uint32(bytes4(ret)), startByte);
    }

    function _readUint128(bytes memory data, uint256 startByte) internal pure returns (uint128, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 16);
        return (uint128(bytes16(ret)), startByte);
    }

    function _readUint160(bytes memory data, uint256 startByte) internal pure returns (uint160, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 20);
        return (uint160(bytes20(ret)), startByte);
    }

    function _readUint200(bytes memory data, uint256 startByte) internal pure returns (uint200, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 25);
        return (uint200(bytes25(ret)), startByte);
    }

    function _readUint256(bytes memory data, uint256 startByte) internal pure returns (uint256, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 32);
        return (uint256(bytes32(ret)), startByte);
    }

    /// @dev only when sure that the value of uint256 never exceed uint128
    function _readUint128AsUint256(bytes memory data, uint256 startByte) internal pure returns (uint256, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 16);
        return (uint256(uint128(bytes16(ret))), startByte);
    }

    function _readAddress(bytes memory data, uint256 startByte) internal pure returns (address, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 20);
        return (address(bytes20(ret)), startByte);
    }

    function _readBytes1(bytes memory data, uint256 startByte) internal pure returns (bytes1, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 1);
        return (bytes1(ret), startByte);
    }

    function _readBytes4(bytes memory data, uint256 startByte) internal pure returns (bytes4, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 4);
        return (bytes4(ret), startByte);
    }

    function _readBytes32(bytes memory data, uint256 startByte) internal pure returns (bytes32, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 32);
        return (bytes32(ret), startByte);
    }

    /// @dev length of bytes is currently limited to uint32
    function _readBytes(bytes memory data, uint256 startByte) internal pure returns (bytes memory b, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 4);
        uint256 length = uint256(uint32(bytes4(ret)));
        (b, startByte) = _calldataVal(data, startByte, length);
        return (b, startByte);
    }

    /// @dev length of bytes array is currently limited to uint8
    function _readBytesArray(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (bytes[] memory bytesArray, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));
        bytesArray = new bytes[](length);
        for (uint8 i = 0; i < length; ++i) {
            (bytesArray[i], startByte) = _readBytes(data, startByte);
        }
        return (bytesArray, startByte);
    }

    /// @dev length of address array is currently limited to uint8 to save bytes
    function _readAddressArray(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (address[] memory addrs, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));
        addrs = new address[](length);
        for (uint8 i = 0; i < length; ++i) {
            (addrs[i], startByte) = _readAddress(data, startByte);
        }
        return (addrs, startByte);
    }

    /// @dev length of uint array is currently limited to uint8 to save bytes
    /// @dev same as _readUint128AsUint256, only use when sure that value never exceed uint128
    function _readUint128ArrayAsUint256Array(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (uint256[] memory, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));
        uint256[] memory us = new uint256[](length);
        for (uint8 i = 0; i < length; ++i) {
            (us[i], startByte) = _readUint128AsUint256(data, startByte);
        }
        return (us, startByte);
    }

    function _readUint32Array(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (uint32[] memory arr, uint256) {
        bytes memory ret;
        (ret, startByte) = _calldataVal(data, startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));
        arr = new uint32[](length);
        for (uint8 i = 0; i < length; ++i) {
            (arr[i], startByte) = _readUint32(data, startByte);
        }
        return (arr, startByte);
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/interfaces/IExecutorHelperL2.sol

pragma solidity ^0.8.0;




interface IExecutorHelperL2 is IExecutorHelperL2Struct {
    function executeUniswap(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeKSClassic(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeVelodrome(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeFrax(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeCamelot(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeKyberLimitOrder(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeStableSwap(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeCurve(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeUniV3KSElastic(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeBalV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeDODO(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeGMX(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeSynthetix(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeWrappedstETH(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeStEth(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executePlatypus(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executePSM(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeMaverick(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeSyncSwap(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeAlgebraV1(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeBalancerBatch(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeWombat(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeWooFiV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeMantis(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeIziSwap(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeTraderJoeV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeLevelFiV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeGMXGLP(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executePancakeStableSwap(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeMantleUsd(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeKelp(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeVooi(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeVelocoreV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeSmardex(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeSolidlyV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeKokonut(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeBalancerV1(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeSwaapV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeNomiswapStable(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeArbswapStable(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeBancorV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeBancorV3(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeAmbient(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeLighterV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeMaiPSM(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeNative(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeHashflow(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeRfq(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeKyberDSLO(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeBebop(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeSymbioticLRT(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeMaverickV2(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);

    function executeIntegral(
        uint256 index,
        bytes memory data,
        uint256 previousAmountOut,
        address tokenIn,
        bool getPoolOnly,
        address nextPool
    ) external payable returns (address tokenOut, uint256 tokenAmountOut, address pool);
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l2-contracts/BytesHelper.sol

pragma solidity ^0.8.0;

library BytesHelper {
    function splitCalldata(bytes memory data) internal pure returns (bytes4 selector, bytes memory functionCalldata) {
        require(data.length >= 4, "Calldata too short");

        // Extract the selector
        assembly {
            selector := mload(add(data, 32))
        }
        // Extract the function calldata
        functionCalldata = new bytes(data.length - 4);
        for (uint256 i = 0; i < data.length - 4; i++) {
            functionCalldata[i] = data[i + 4];
        }
    }

    function writeBytes(
        bytes memory originalCalldata,
        uint256 index,
        bytes memory value
    ) internal pure returns (bytes memory) {
        require(index + value.length <= originalCalldata.length, "Offset out of bounds");

        // Update the value length bytes at the specified offset with the new value
        for (uint256 i; i < value.length; ++i) {
            originalCalldata[index + i] = value[i];
        }

        return originalCalldata;
    }

    function write16Bytes(bytes memory original, uint256 index, bytes16 value) internal pure returns (bytes memory) {
        assembly {
            let offset := add(original, add(index, 32))
            let val := mload(offset) // read 32 bytes [index : index + 32]
            val := and(val, not(0xffffffffffffffffffffffffffffffff00000000000000000000000000000000)) // clear [index : index + 16]
            val := or(val, value) // set 16 bytes to val above
            mstore(offset, val) // store to [index : index + 32]
        }
        return original;
    }

    function write16Bytes(bytes memory original, uint256 index, uint128 value) internal pure returns (bytes memory) {
        return write16Bytes(original, index, bytes16(value));
    }

    function write16Bytes(
        bytes memory original,
        uint256 index,
        uint256 value,
        string memory errorMsg
    ) internal pure returns (bytes memory) {
        require(value <= type(uint128).max, string(abi.encodePacked(errorMsg, "/Exceed compressed type range")));
        return write16Bytes(original, index, uint128(value));
    }

    /**
     * @dev Writes a 32-byte value into the specified index of a bytes array.
     * @param original The original bytes array.
     * @param index The index in the bytes array where the 32-byte value should be written.
     * @param value The 32-byte value to write.
     * @return The modified bytes array.
     */
    function write32Bytes(bytes memory original, uint256 index, bytes32 value) internal pure returns (bytes memory) {
        assembly {
            let offset := add(add(original, 32), index)
            mstore(offset, value) // Store the 32-byte value directly at the specified offset
        }
        return original;
    }

    /**
     * @dev Overloaded function to write a uint256 value as a 32-byte value.
     * @param original The original bytes array.
     * @param index The index in the bytes array where the 32-byte value should be written.
     * @param value The uint256 value to write.
     * @return The modified bytes array.
     */
    function write32Bytes(bytes memory original, uint256 index, uint256 value) internal pure returns (bytes memory) {
        return write32Bytes(original, index, bytes32(value));
    }

    function write32Bytes(
        bytes memory original,
        uint256 index,
        uint256 value,
        string memory errorMsg
    ) internal pure returns (bytes memory) {
        require(value <= type(uint128).max, string(abi.encodePacked(errorMsg, "/Exceed compressed type range")));
        return write32Bytes(original, index, value);
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l2-contracts/Common.sol

pragma solidity ^0.8.0;



library Common {
    using CalldataReader for bytes;

    function _readPool(bytes memory data, uint256 startByte) internal pure returns (address, uint256) {
        uint24 poolId;
        address poolAddress;
        (poolId, startByte) = data._readUint24(startByte);
        if (poolId == 0) {
            (poolAddress, startByte) = data._readAddress(startByte);
        }
        return (poolAddress, startByte);
    }

    function _readRecipient(bytes memory data, uint256 startByte) internal pure returns (address, uint256) {
        uint8 recipientFlag;
        address recipient;
        (recipientFlag, startByte) = data._readUint8(startByte);
        if (recipientFlag != 2 && recipientFlag != 1) {
            (recipient, startByte) = data._readAddress(startByte);
        }
        return (recipient, startByte);
    }

    function _readBytes32Array(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (bytes32[] memory bytesArray, uint256) {
        bytes memory ret;
        (ret, startByte) = data._calldataVal(startByte, 1);
        uint256 length = uint256(uint8(bytes1(ret)));
        bytesArray = new bytes32[](length);
        for (uint8 i = 0; i < length; ++i) {
            (bytesArray[i], startByte) = data._readBytes32(startByte);
        }
        return (bytesArray, startByte);
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l2-contracts/DexScaler.sol

pragma solidity ^0.8.0;










/// @title DexScaler
/// @notice Contain functions to scale DEX structs
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
library DexScaler {
    using BytesHelper for bytes;
    using CalldataReader for bytes;
    using Common for bytes;

    function scaleUniSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;
        // decode
        (, startByte) = data._readPool(startByte);
        (, startByte) = data._readRecipient(startByte);
        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleUniSwap");
    }

    function scaleStableSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;
        (, startByte) = data._readPool(startByte);
        (, startByte) = data._readUint8(startByte);
        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return
            data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleStableSwap");
    }

    function scaleCurveSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;
        bool canGetIndex;
        (canGetIndex, startByte) = data._readBool(0);
        (, startByte) = data._readPool(startByte);
        if (!canGetIndex) {
            (, startByte) = data._readAddress(startByte);
            (, startByte) = data._readUint8(startByte);
        }
        (, startByte) = data._readUint8(startByte);
        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return
            data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleCurveSwap");
    }

    function scaleUniswapV3KSElastic(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;
        (, startByte) = data._readRecipient(startByte);
        (, startByte) = data._readPool(startByte);
        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return
            data.write16Bytes(
                startByte,
                oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount,
                "scaleUniswapV3KSElastic"
            );
    }

    function scaleBalancerV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;
        (, startByte) = data._readPool(startByte);
        (, startByte) = data._readBytes32(startByte);
        (, startByte) = data._readUint8(startByte);
        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return
            data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleBalancerV2");
    }

    function scaleDODO(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;
        (, startByte) = data._readRecipient(startByte);
        (, startByte) = data._readPool(startByte);
        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleDODO");
    }

    function scaleGMX(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;
        // decode
        (, startByte) = data._readPool(startByte);

        (, startByte) = data._readAddress(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleGMX");
    }

    function scaleSynthetix(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        // decode
        (, startByte) = data._readPool(startByte);

        (, startByte) = data._readAddress(startByte);
        (, startByte) = data._readBytes32(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return
            data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleSynthetix");
    }

    function scaleWrappedstETH(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        // decode
        (, startByte) = data._readPool(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return
            data.write16Bytes(
                startByte,
                oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount,
                "scaleWrappedstETH"
            );
    }

    function scaleStETH(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        (uint256 swapAmount, ) = data._readUint128AsUint256(0);
        return data.write16Bytes(0, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleStETH");
    }

    function scalePlatypus(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        // decode
        (, startByte) = data._readPool(startByte);

        (, startByte) = data._readAddress(startByte);

        (, startByte) = data._readRecipient(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scalePlatypus");
    }

    function scalePSM(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;

        // decode
        (, startByte) = data._readPool(startByte);

        (, startByte) = data._readAddress(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scalePSM");
    }

    function scaleMaverick(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        // decode
        (, startByte) = data._readPool(startByte);

        (, startByte) = data._readAddress(startByte);

        (, startByte) = data._readRecipient(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleMaverick");
    }

    function scaleSyncSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        // decode
        (, startByte) = data._readBytes(startByte);
        (, startByte) = data._readPool(startByte);

        (, startByte) = data._readAddress(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleSyncSwap");
    }

    function scaleAlgebraV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readRecipient(startByte);

        (, startByte) = data._readPool(startByte);

        (, startByte) = data._readAddress(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);

        return
            data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleAlgebraV1");
    }

    function scaleBalancerBatch(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        // decode
        (, startByte) = data._readPool(startByte);

        (, startByte) = data._readBytes32Array(startByte);
        (, startByte) = data._readAddressArray(startByte);
        (, startByte) = data._readBytesArray(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte);
        return
            data.write16Bytes(
                startByte,
                oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount,
                "scaleBalancerBatch"
            );
    }

    function scaleMantis(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (, startByte) = data._readAddress(startByte); // tokenOut

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte); // amount
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleMantis");
    }

    function scaleIziSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (, startByte) = data._readAddress(startByte); // tokenOut

        // recipient
        (, startByte) = data._readRecipient(startByte);

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte); // amount
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleIziSwap");
    }

    function scaleTraderJoeV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        // recipient
        (, startByte) = data._readRecipient(startByte);

        (, startByte) = data._readPool(startByte); // pool

        (, startByte) = data._readAddress(startByte); // tokenOut

        (, startByte) = data._readBool(startByte); // isV2

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte); // amount
        return
            data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleTraderJoeV2");
    }

    function scaleLevelFiV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (, startByte) = data._readAddress(startByte); // tokenOut

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte); // amount
        return
            data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleLevelFiV2");
    }

    function scaleGMXGLP(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (, startByte) = data._readAddress(startByte); // yearnVault

        uint8 directionFlag;
        (directionFlag, startByte) = data._readUint8(startByte);
        if (directionFlag == 1) (, startByte) = data._readAddress(startByte); // tokenOut

        (uint256 swapAmount, ) = data._readUint128AsUint256(startByte); // amount
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, "scaleGMXGLP");
    }

    function scaleVooi(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (, startByte) = data._readUint8(startByte); // toId

        (uint256 fromAmount, ) = data._readUint128AsUint256(startByte); // amount

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (fromAmount * newAmount) / oldAmount, "scaleVooi");
    }

    function scaleVelocoreV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleVelocoreV2");
    }

    function scaleKokonut(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleKokonut");
    }

    function scaleBalancerV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleBalancerV1");
    }

    function scaleArbswapStable(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (uint256 dx, ) = data._readUint128AsUint256(startByte); // dx

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (dx * newAmount) / oldAmount, "scaleArbswapStable");
    }

    function scaleBancorV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (, startByte) = data._readAddressArray(startByte); // swapPath

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleBancorV2");
    }

    function scaleAmbient(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (uint128 qty, ) = data._readUint128(startByte); // amount

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (qty * newAmount) / oldAmount, "scaleAmbient");
    }

    function scaleLighterV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // orderbook

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleLighterV2");
    }

    function scaleMaiPSM(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;
        (, startByte) = data._readPool(startByte); // pool

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount

        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleMaiPSM");
    }

    function scaleKyberRFQ(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;
        (, startByte) = data._readPool(startByte); // rfq
        (, startByte) = data._readOrderRFQ(startByte); // order
        (, startByte) = data._readBytes(startByte); // signature
        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleKyberRFQ");
    }

    function scaleDSLO(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // kyberLOAddress

        (, startByte) = data._readAddress(startByte); // makerAsset

        // (, startByte) = data._readAddress(startByte); // don't have takerAsset

        (
            IKyberDSLO.FillBatchOrdersParams memory params,
            ,
            uint256 takingAmountStartByte,
            uint256 thresholdStartByte
        ) = data._readDSLOFillBatchOrdersParams(startByte); // FillBatchOrdersParams

        data = data.write16Bytes(
            takingAmountStartByte,
            oldAmount == 0 ? 0 : (params.takingAmount * newAmount) / oldAmount,
            "scaleDSLO"
        );

        return data.write16Bytes(thresholdStartByte, 1, "scaleThreshold");
    }

    function scaleKyberLimitOrder(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // kyberLOAddress

        (, startByte) = data._readAddress(startByte); // makerAsset

        // (, startByte) = data._readAddress(startByte); // takerAsset

        (
            IKyberLO.FillBatchOrdersParams memory params,
            ,
            uint256 takingAmountStartByte,
            uint256 thresholdStartByte
        ) = data._readLOFillBatchOrdersParams(startByte); // FillBatchOrdersParams

        data = data.write16Bytes(
            takingAmountStartByte,
            oldAmount == 0 ? 0 : (params.takingAmount * newAmount) / oldAmount,
            "scaleLO"
        );
        return data.write16Bytes(thresholdStartByte, 1, "scaleThreshold");
    }

    function scaleHashflow(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readAddress(startByte); // router

        (IExecutorHelperL2.RFQTQuote memory rfqQuote, , uint256 ebtaStartByte) = data._readRFQTQuote(startByte); // RFQTQuote

        return
            data.write16Bytes(
                ebtaStartByte,
                oldAmount == 0 ? 0 : (rfqQuote.effectiveBaseTokenAmount * newAmount) / oldAmount,
                "scaleHashflow"
            );
    }

    function scaleNative(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        require(newAmount < oldAmount, "Native: not support scale up");

        uint256 startByte;
        bytes memory strData;
        uint256 amountStartByte;
        uint256 amount;
        uint256 multihopAndOffset;
        uint256 strDataStartByte;

        (, startByte) = data._readAddress(startByte); // target

        amountStartByte = startByte;
        (amount, startByte) = data._readUint128AsUint256(startByte); // amount

        strDataStartByte = startByte;
        (strData, startByte) = data._readBytes(startByte); // data

        (, startByte) = data._readAddress(startByte); // tokenIn
        (, startByte) = data._readAddress(startByte); // tokenOut
        (, startByte) = data._readAddress(startByte); // recipient
        (multihopAndOffset, startByte) = data._readUint256(startByte); // multihopAndOffset

        require(multihopAndOffset >> 255 == 0, "Native: Multihop not supported");

        amount = (amount * newAmount) / oldAmount;

        uint256 amountInOffset = uint256(uint64(multihopAndOffset >> 64));
        uint256 amountOutMinOffset = uint256(uint64(multihopAndOffset));
        // bytes memory newCallData = strData;

        strData = strData.write32Bytes(amountInOffset, amount, "ScaleStructDataAmount");

        // update amount out min if needed
        if (amountOutMinOffset != 0) {
            strData = strData.write32Bytes(amountOutMinOffset, 1, "ScaleStructDataAmountOutMin");
        }

        data.write16Bytes(amountStartByte, amount, "scaleNativeAmount");

        return data.writeBytes(strDataStartByte + 4, strData);
    }

    function scaleBebop(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        require(newAmount < oldAmount, "Bebop: not support scale up");

        uint256 startByte;
        uint256 amount;
        uint256 amountStartByte;
        uint256 txDataStartByte;
        bytes memory txData;

        (, startByte) = data._readPool(startByte); // pool

        amountStartByte = startByte;
        (amount, startByte) = data._readUint128AsUint256(startByte); // amount
        txDataStartByte = startByte;
        (txData, startByte) = data._readBytes(startByte); // data

        amount = (amount * newAmount) / oldAmount;

        {
            // update calldata with new swap amount
            (bytes4 selector, bytes memory callData) = txData.splitCalldata();

            (IBebopV3.Single memory s, IBebopV3.MakerSignature memory m, ) = abi.decode(
                callData,
                (IBebopV3.Single, IBebopV3.MakerSignature, uint256)
            );

            txData = bytes.concat(bytes4(selector), abi.encode(s, m, amount));
        }

        data.write16Bytes(amountStartByte, amount, "scaleBebopAmount");

        return data.writeBytes(txDataStartByte + 4, txData);
    }

    function scaleMantleUsd(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        (uint256 isWrapAndAmount, ) = data._readUint256(0);

        bool _isWrap = isWrapAndAmount >> 255 == 1;
        uint256 _amount = uint256(uint128(isWrapAndAmount));

        //scale amount
        _amount = oldAmount == 0 ? 0 : (_amount * newAmount) / oldAmount;

        // reset and create new variable for isWrap and amount
        isWrapAndAmount = 0;
        isWrapAndAmount |= uint256(uint128(_amount));
        isWrapAndAmount |= uint256(_isWrap ? 1 : 0) << 255;
        return abi.encode(isWrapAndAmount);
    }

    function scaleKelp(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleKelp");
    }

    function scaleSymbioticLRT(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // vault

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleSymbioticLRT");
    }

    function scaleMaverickV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 startByte;

        (, startByte) = data._readPool(startByte); // pool

        (uint256 amount, ) = data._readUint128AsUint256(startByte); // amount
        return data.write16Bytes(startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, "scaleMaverickV2");
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l2-contracts/ScalingDataL2Lib.sol

pragma solidity ^0.8.0;




library ScalingDataL2Lib {
    using DexScaler for bytes;

    function newUniSwap(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleUniSwap(oldAmount, newAmount);
    }

    function newStableSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleStableSwap(oldAmount, newAmount);
    }

    function newCurveSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleCurveSwap(oldAmount, newAmount);
    }

    function newKyberDMM(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleUniSwap(oldAmount, newAmount);
    }

    function newUniswapV3KSElastic(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleUniswapV3KSElastic(oldAmount, newAmount);
    }

    function newBalancerV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleBalancerV2(oldAmount, newAmount);
    }

    function newDODO(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleDODO(oldAmount, newAmount);
    }

    function newVelodrome(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleUniSwap(oldAmount, newAmount);
    }

    function newGMX(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleGMX(oldAmount, newAmount);
    }

    function newSynthetix(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleSynthetix(oldAmount, newAmount);
    }

    function newCamelot(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleUniSwap(oldAmount, newAmount);
    }

    function newPlatypus(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scalePlatypus(oldAmount, newAmount);
    }

    function newWrappedstETHSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleWrappedstETH(oldAmount, newAmount);
    }

    function newPSM(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scalePSM(oldAmount, newAmount);
    }

    function newFrax(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleUniSwap(oldAmount, newAmount);
    }

    function newStETHSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleStETH(oldAmount, newAmount);
    }

    function newMaverick(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleMaverick(oldAmount, newAmount);
    }

    function newSyncSwap(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleSyncSwap(oldAmount, newAmount);
    }

    function newAlgebraV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleAlgebraV1(oldAmount, newAmount);
    }

    function newBalancerBatch(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleBalancerBatch(oldAmount, newAmount);
    }

    function newMantis(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleMantis(oldAmount, newAmount);
    }

    function newIziSwap(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleIziSwap(oldAmount, newAmount);
    }

    function newTraderJoeV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleTraderJoeV2(oldAmount, newAmount);
    }

    function newLevelFiV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleLevelFiV2(oldAmount, newAmount);
    }

    function newGMXGLP(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleGMXGLP(oldAmount, newAmount);
    }

    function newVooi(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleVooi(oldAmount, newAmount);
    }

    function newVelocoreV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleVelocoreV2(oldAmount, newAmount);
    }

    function newKokonut(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleKokonut(oldAmount, newAmount);
    }

    function newBalancerV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleBalancerV1(oldAmount, newAmount);
    }

    function newArbswapStable(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleArbswapStable(oldAmount, newAmount);
    }

    function newBancorV2(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleBancorV2(oldAmount, newAmount);
    }

    function newAmbient(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleAmbient(oldAmount, newAmount);
    }

    function newLighterV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleLighterV2(oldAmount, newAmount);
    }

    function newMaiPSM(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleMaiPSM(oldAmount, newAmount);
    }

    function newNative(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleNative(oldAmount, newAmount);
    }

    function newKyberDSLO(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleDSLO(oldAmount, newAmount);
    }

    function newKyberLimitOrder(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleKyberLimitOrder(oldAmount, newAmount);
    }

    function newHashflow(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleHashflow(oldAmount, newAmount);
    }

    function newKyberRFQ(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleKyberRFQ(oldAmount, newAmount);
    }

    function newBebop(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleBebop(oldAmount, newAmount);
    }

    function newMantleUsd(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleMantleUsd(oldAmount, newAmount);
    }

    function newKelp(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleKelp(oldAmount, newAmount);
    }

    function newSymbioticLRT(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleSymbioticLRT(oldAmount, newAmount);
    }

    function newMaverickV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        return data.scaleMaverickV2(oldAmount, newAmount);
    }

    function newIntegral(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        return data.scaleMaverickV2(oldAmount, newAmount); // using kind of same scaling as MaverickV2
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l2-contracts/ExecutorReader.sol

pragma solidity ^0.8.0;





library ExecutorReader {
    function readSwapExecutorDescription(bytes memory data) internal pure returns (bytes memory) {
        uint256 startByte = 0;
        IAggregationExecutorOptimistic.SwapExecutorDescription memory desc;

        // Swap array
        bytes memory ret;
        (ret, startByte) = CalldataReader._calldataVal(data, startByte, 1);
        uint256 lX = uint256(uint8(bytes1(ret)));
        desc.swapSequences = new IAggregationExecutorOptimistic.Swap[][](lX);
        for (uint8 i = 0; i < lX; ++i) {
            (ret, startByte) = CalldataReader._calldataVal(data, startByte, 1);
            uint256 lY = uint256(uint8(bytes1(ret)));
            desc.swapSequences[i] = new IAggregationExecutorOptimistic.Swap[](lY);
            for (uint8 j = 0; j < lY; ++j) {
                (desc.swapSequences[i][j], startByte) = _readSwap(data, startByte);
            }
        }

        // basic members
        (desc.tokenIn, startByte) = CalldataReader._readAddress(data, startByte);
        (desc.tokenOut, startByte) = CalldataReader._readAddress(data, startByte);
        (desc.to, startByte) = CalldataReader._readAddress(data, startByte);
        (desc.deadline, startByte) = CalldataReader._readUint128AsUint256(data, startByte);
        (desc.positiveSlippageData, startByte) = CalldataReader._readBytes(data, startByte);

        return abi.encode(desc);
    }

    function readSwapSingleSequence(
        bytes memory data
    ) internal pure returns (IAggregationExecutorOptimistic.Swap[] memory swaps, address tokenIn) {
        uint256 startByte = 0;
        bytes memory ret;
        (ret, startByte) = CalldataReader._calldataVal(data, startByte, 1);
        uint256 len = uint256(uint8(bytes1(ret)));
        swaps = new IAggregationExecutorOptimistic.Swap[](len);
        for (uint8 i = 0; i < len; ++i) {
            (swaps[i], startByte) = _readSwap(data, startByte);
        }
        (tokenIn, startByte) = CalldataReader._readAddress(data, startByte);
    }

    function _readSwap(
        bytes memory data,
        uint256 startByte
    ) internal pure returns (IAggregationExecutorOptimistic.Swap memory swap, uint256) {
        (swap.data, startByte) = CalldataReader._readBytes(data, startByte);
        bytes1 t;
        (t, startByte) = CalldataReader._readBytes1(data, startByte);
        swap.functionSelector = bytes4(uint32(uint8(t)));
        return (swap, startByte);
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l2-contracts/CalldataWriter.sol

pragma solidity ^0.8.0;





library CalldataWriter {
    function writeSimpleSwapData(
        IMetaAggregationRouterV2.SimpleSwapData memory simpleSwapData
    ) internal pure returns (bytes memory shortData) {
        shortData = bytes.concat(shortData, _writeAddressArray(simpleSwapData.firstPools));
        shortData = bytes.concat(shortData, _writeUint256ArrayAsUint128Array(simpleSwapData.firstSwapAmounts));
        shortData = bytes.concat(shortData, _writeBytesArray(simpleSwapData.swapDatas));
        shortData = bytes.concat(shortData, bytes16(uint128(simpleSwapData.deadline)));
        shortData = bytes.concat(shortData, _writeBytes(simpleSwapData.positiveSlippageData));
    }

    /*
     ************************ AggregationExecutor ************************
     */
    function writeSwapExecutorDescription(
        IExecutorHelperL2.SwapExecutorDescription memory desc
    ) internal pure returns (bytes memory shortData) {
        // write Swap array
        uint8 lX = uint8(desc.swapSequences.length);
        shortData = bytes.concat(shortData, bytes1(lX));
        for (uint8 i = 0; i < lX; ++i) {
            uint8 lY = uint8(desc.swapSequences[i].length);
            shortData = bytes.concat(shortData, bytes1(lY));
            for (uint8 j = 0; j < lY; ++j) {
                shortData = bytes.concat(shortData, _writeSwap(desc.swapSequences[i][j]));
            }
        }

        // basic members
        shortData = bytes.concat(shortData, bytes20(desc.tokenIn));
        shortData = bytes.concat(shortData, bytes20(desc.tokenOut));
        shortData = bytes.concat(shortData, bytes20(desc.to));
        shortData = bytes.concat(shortData, bytes16(uint128(desc.deadline)));
        shortData = bytes.concat(shortData, _writeBytes(desc.positiveSlippageData));
    }

    function writeSimpleModeSwapDatas(
        bytes[] memory swapDatas,
        address tokenIn
    ) internal pure returns (bytes[] memory shortData) {
        uint8 len = uint8(swapDatas.length);
        for (uint8 i = 0; i < len; ++i) {
            swapDatas[i] = _writeSwapSingleSequence(swapDatas[i], tokenIn);
        }
        return (swapDatas);
    }

    function _writeSwapSingleSequence(
        bytes memory data,
        address tokenIn
    ) internal pure returns (bytes memory shortData) {
        IExecutorHelperL2.Swap[] memory swaps = abi.decode(data, (IExecutorHelperL2.Swap[]));

        uint8 len = uint8(swaps.length);
        shortData = bytes.concat(shortData, bytes1(len));
        for (uint8 i = 0; i < len; ++i) {
            shortData = bytes.concat(shortData, _writeSwap(swaps[i]));
        }
        shortData = bytes.concat(shortData, bytes20(tokenIn));
    }

    function _writeAddressArray(address[] memory addrs) internal pure returns (bytes memory data) {
        uint8 length = uint8(addrs.length);
        data = bytes.concat(data, bytes1(length));
        for (uint8 i = 0; i < length; ++i) {
            data = bytes.concat(data, bytes20(addrs[i]));
        }
        return data;
    }

    function _writeUint256ArrayAsUint128Array(uint256[] memory us) internal pure returns (bytes memory data) {
        uint8 length = uint8(us.length);
        data = bytes.concat(data, bytes1(length));
        for (uint8 i = 0; i < length; ++i) {
            data = bytes.concat(data, bytes16(uint128(us[i])));
        }
        return data;
    }

    function _writeBytes(bytes memory b) internal pure returns (bytes memory data) {
        uint32 length = uint32(b.length);
        data = bytes.concat(data, bytes4(length));
        data = bytes.concat(data, b);
        return data;
    }

    function _writeBytesArray(bytes[] memory bytesArray) internal pure returns (bytes memory data) {
        uint8 x = uint8(bytesArray.length);
        data = bytes.concat(data, bytes1(x));
        for (uint8 i; i < x; ++i) {
            uint32 length = uint32(bytesArray[i].length);
            data = bytes.concat(data, bytes4(length));
            data = bytes.concat(data, bytesArray[i]);
        }
        return data;
    }

    function _writeBytes32Array(bytes32[] memory bytesArray) internal pure returns (bytes memory data) {
        uint8 x = uint8(bytesArray.length);
        data = bytes.concat(data, bytes1(x));
        for (uint8 i; i < x; ++i) {
            data = bytes.concat(data, bytesArray[i]);
        }
        return data;
    }

    function _writeSwap(IExecutorHelperL2.Swap memory swap) internal pure returns (bytes memory shortData) {
        shortData = bytes.concat(shortData, _writeBytes(swap.data));
        shortData = bytes.concat(shortData, bytes1(uint8(uint32(swap.functionSelector))));
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/kyberswap/l2-contracts/InputScalingHelperL2.sol

pragma solidity ^0.8.0;









library InputScalingHelperL2 {
    using ExecutorReader for bytes;

    uint256 private constant _PARTIAL_FILL = 0x01;
    uint256 private constant _REQUIRES_EXTRA_ETH = 0x02;
    uint256 private constant _SHOULD_CLAIM = 0x04;
    uint256 private constant _BURN_FROM_MSG_SENDER = 0x08;
    uint256 private constant _BURN_FROM_TX_ORIGIN = 0x10;
    uint256 private constant _SIMPLE_SWAP = 0x20;

    struct PositiveSlippageFeeData {
        uint256 partnerPSInfor;
        uint256 expectedReturnAmount;
    }

    enum DexIndex {
        UNI,
        KyberDMM,
        Velodrome,
        Fraxswap,
        Camelot,
        KyberLimitOrder, // 5
        KyberRFQ, // 6
        Hashflow, // 7
        StableSwap,
        Curve,
        UniswapV3KSElastic,
        BalancerV2,
        DODO,
        GMX,
        Synthetix,
        wstETH,
        stETH,
        Platypus,
        PSM,
        Maverick,
        SyncSwap,
        AlgebraV1,
        BalancerBatch,
        Mantis,
        Wombat,
        WooFiV2,
        iZiSwap,
        TraderJoeV2, // 27
        KyberDSLO, // 28
        LevelFiV2,
        GMXGLP,
        PancakeStableSwap,
        Vooi,
        VelocoreV2,
        Smardex,
        SolidlyV2,
        Kokonut,
        BalancerV1, // 37
        SwaapV2,
        NomiswapStable,
        ArbswapStable,
        BancorV3,
        BancorV2,
        Ambient,
        Native, // 44
        LighterV2,
        Bebop, // 46
        MantleUsd,
        MaiPSM, // 48
        Kelp,
        SymbioticLRT,
        MaverickV2,
        Integral
    }

    function _getScaledInputData(bytes calldata inputData, uint256 newAmount) internal pure returns (bytes memory) {
        bytes4 selector = bytes4(inputData[:4]);
        bytes calldata dataToDecode = inputData[4:];

        if (selector == IMetaAggregationRouterV2.swap.selector) {
            IMetaAggregationRouterV2.SwapExecutionParams memory params = abi.decode(
                dataToDecode,
                (IMetaAggregationRouterV2.SwapExecutionParams)
            );

            (params.desc, params.targetData) = _getScaledInputDataV2(
                params.desc,
                params.targetData,
                newAmount,
                _flagsChecked(params.desc.flags, _SIMPLE_SWAP)
            );
            return abi.encodeWithSelector(selector, params);
        } else if (selector == IMetaAggregationRouterV2.swapSimpleMode.selector) {
            (
                address callTarget,
                IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
                bytes memory targetData,
                bytes memory clientData
            ) = abi.decode(dataToDecode, (address, IMetaAggregationRouterV2.SwapDescriptionV2, bytes, bytes));

            (desc, targetData) = _getScaledInputDataV2(desc, targetData, newAmount, true);
            return abi.encodeWithSelector(selector, callTarget, desc, targetData, clientData);
        } else {
            revert("InputScalingHelper: Invalid selector");
        }
    }

    function _getScaledInputDataV2(
        IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
        bytes memory executorData,
        uint256 newAmount,
        bool isSimpleMode
    ) internal pure returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory, bytes memory) {
        uint256 oldAmount = desc.amount;
        if (oldAmount == newAmount) {
            return (desc, executorData);
        }

        // simple mode swap
        if (isSimpleMode) {
            return (
                _scaledSwapDescriptionV2(desc, oldAmount, newAmount),
                _scaledSimpleSwapData(executorData, oldAmount, newAmount)
            );
        }

        //normal mode swap
        return (
            _scaledSwapDescriptionV2(desc, oldAmount, newAmount),
            _scaledExecutorCallBytesData(executorData, oldAmount, newAmount)
        );
    }

    /// @dev Scale the swap description
    function _scaledSwapDescriptionV2(
        IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory) {
        desc.minReturnAmount = (desc.minReturnAmount * newAmount) / oldAmount;
        if (desc.minReturnAmount == 0) desc.minReturnAmount = 1;
        desc.amount = (desc.amount * newAmount) / oldAmount;

        uint256 nReceivers = desc.srcReceivers.length;
        for (uint256 i = 0; i < nReceivers; ) {
            desc.srcAmounts[i] = (desc.srcAmounts[i] * newAmount) / oldAmount;
            unchecked {
                ++i;
            }
        }
        return desc;
    }

    /// @dev Scale the executorData in case swapSimpleMode
    function _scaledSimpleSwapData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IMetaAggregationRouterV2.SimpleSwapData memory simpleSwapData = abi.decode(
            data,
            (IMetaAggregationRouterV2.SimpleSwapData)
        );
        uint256 nPools = simpleSwapData.firstPools.length;
        address tokenIn;

        for (uint256 i = 0; i < nPools; ) {
            simpleSwapData.firstSwapAmounts[i] = (simpleSwapData.firstSwapAmounts[i] * newAmount) / oldAmount;

            IExecutorHelperL2.Swap[] memory dexData;

            (dexData, tokenIn) = simpleSwapData.swapDatas[i].readSwapSingleSequence();

            // only need to scale the first dex in each sequence
            if (dexData.length > 0) {
                dexData[0] = _scaleDexData(dexData[0], oldAmount, newAmount);
            }

            simpleSwapData.swapDatas[i] = CalldataWriter._writeSwapSingleSequence(abi.encode(dexData), tokenIn);

            unchecked {
                ++i;
            }
        }

        simpleSwapData.positiveSlippageData = _scaledPositiveSlippageFeeData(
            simpleSwapData.positiveSlippageData,
            oldAmount,
            newAmount
        );

        return abi.encode(simpleSwapData);
    }

    /// @dev Scale the executorData in case normal swap
    function _scaledExecutorCallBytesData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelperL2.SwapExecutorDescription memory executorDesc = abi.decode(
            data.readSwapExecutorDescription(),
            (IExecutorHelperL2.SwapExecutorDescription)
        );

        executorDesc.positiveSlippageData = _scaledPositiveSlippageFeeData(
            executorDesc.positiveSlippageData,
            oldAmount,
            newAmount
        );

        uint256 nSequences = executorDesc.swapSequences.length;
        for (uint256 i = 0; i < nSequences; ) {
            // only need to scale the first dex in each sequence
            IExecutorHelperL2.Swap memory swap = executorDesc.swapSequences[i][0];
            executorDesc.swapSequences[i][0] = _scaleDexData(swap, oldAmount, newAmount);
            unchecked {
                ++i;
            }
        }
        return CalldataWriter.writeSwapExecutorDescription(executorDesc);
    }

    function _scaledPositiveSlippageFeeData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory newData) {
        if (data.length > 32) {
            PositiveSlippageFeeData memory psData = abi.decode(data, (PositiveSlippageFeeData));
            uint256 left = uint256(psData.expectedReturnAmount >> 128);
            uint256 right = (uint256(uint128(psData.expectedReturnAmount)) * newAmount) / oldAmount;
            require(right <= type(uint128).max, "_scaledPositiveSlippageFeeData/Exceeded type range");
            psData.expectedReturnAmount = right | (left << 128);
            data = abi.encode(psData);
        } else if (data.length == 32) {
            uint256 expectedReturnAmount = abi.decode(data, (uint256));
            uint256 left = uint256(expectedReturnAmount >> 128);
            uint256 right = (uint256(uint128(expectedReturnAmount)) * newAmount) / oldAmount;
            require(right <= type(uint128).max, "_scaledPositiveSlippageFeeData/Exceeded type range");
            expectedReturnAmount = right | (left << 128);
            data = abi.encode(expectedReturnAmount);
        }
        return data;
    }

    function _scaleDexData(
        IExecutorHelperL2.Swap memory swap,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (IExecutorHelperL2.Swap memory) {
        uint8 functionSelectorIndex = uint8(uint32(swap.functionSelector));

        if (DexIndex(functionSelectorIndex) == DexIndex.UNI) {
            swap.data = ScalingDataL2Lib.newUniSwap(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.StableSwap) {
            swap.data = ScalingDataL2Lib.newStableSwap(swap.data, oldAmount, newAmount);
        } else if (
            DexIndex(functionSelectorIndex) == DexIndex.Curve ||
            DexIndex(functionSelectorIndex) == DexIndex.PancakeStableSwap
        ) {
            swap.data = ScalingDataL2Lib.newCurveSwap(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.KyberDMM) {
            swap.data = ScalingDataL2Lib.newKyberDMM(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.UniswapV3KSElastic) {
            swap.data = ScalingDataL2Lib.newUniswapV3KSElastic(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.BalancerV2) {
            swap.data = ScalingDataL2Lib.newBalancerV2(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.wstETH) {
            swap.data = ScalingDataL2Lib.newWrappedstETHSwap(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.stETH) {
            swap.data = ScalingDataL2Lib.newStETHSwap(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.DODO) {
            swap.data = ScalingDataL2Lib.newDODO(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Velodrome) {
            swap.data = ScalingDataL2Lib.newVelodrome(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.GMX) {
            swap.data = ScalingDataL2Lib.newGMX(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Synthetix) {
            swap.data = ScalingDataL2Lib.newSynthetix(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Camelot) {
            swap.data = ScalingDataL2Lib.newCamelot(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.PSM) {
            swap.data = ScalingDataL2Lib.newPSM(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Fraxswap) {
            swap.data = ScalingDataL2Lib.newFrax(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Platypus) {
            swap.data = ScalingDataL2Lib.newPlatypus(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Maverick) {
            swap.data = ScalingDataL2Lib.newMaverick(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.SyncSwap) {
            swap.data = ScalingDataL2Lib.newSyncSwap(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.AlgebraV1) {
            swap.data = ScalingDataL2Lib.newAlgebraV1(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.BalancerBatch) {
            swap.data = ScalingDataL2Lib.newBalancerBatch(swap.data, oldAmount, newAmount);
        } else if (
            DexIndex(functionSelectorIndex) == DexIndex.Mantis ||
            DexIndex(functionSelectorIndex) == DexIndex.Wombat ||
            DexIndex(functionSelectorIndex) == DexIndex.WooFiV2 ||
            DexIndex(functionSelectorIndex) == DexIndex.Smardex ||
            DexIndex(functionSelectorIndex) == DexIndex.SolidlyV2 ||
            DexIndex(functionSelectorIndex) == DexIndex.NomiswapStable ||
            DexIndex(functionSelectorIndex) == DexIndex.BancorV3
        ) {
            swap.data = ScalingDataL2Lib.newMantis(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.iZiSwap) {
            swap.data = ScalingDataL2Lib.newIziSwap(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.TraderJoeV2) {
            swap.data = ScalingDataL2Lib.newTraderJoeV2(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.LevelFiV2) {
            swap.data = ScalingDataL2Lib.newLevelFiV2(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.GMXGLP) {
            swap.data = ScalingDataL2Lib.newGMXGLP(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Vooi) {
            swap.data = ScalingDataL2Lib.newVooi(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.VelocoreV2) {
            swap.data = ScalingDataL2Lib.newVelocoreV2(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Kokonut) {
            swap.data = ScalingDataL2Lib.newKokonut(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.BalancerV1) {
            swap.data = ScalingDataL2Lib.newBalancerV1(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.ArbswapStable) {
            swap.data = ScalingDataL2Lib.newArbswapStable(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.BancorV2) {
            swap.data = ScalingDataL2Lib.newBancorV2(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Ambient) {
            swap.data = ScalingDataL2Lib.newAmbient(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.LighterV2) {
            swap.data = ScalingDataL2Lib.newLighterV2(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Bebop) {
            swap.data = ScalingDataL2Lib.newBebop(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.KyberLimitOrder) {
            swap.data = ScalingDataL2Lib.newKyberLimitOrder(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.MaiPSM) {
            swap.data = ScalingDataL2Lib.newMaiPSM(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Native) {
            swap.data = ScalingDataL2Lib.newNative(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.KyberDSLO) {
            swap.data = ScalingDataL2Lib.newKyberDSLO(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Hashflow) {
            swap.data = ScalingDataL2Lib.newHashflow(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.KyberRFQ) {
            swap.data = ScalingDataL2Lib.newKyberRFQ(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.MantleUsd) {
            swap.data = ScalingDataL2Lib.newMantleUsd(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Kelp) {
            swap.data = ScalingDataL2Lib.newKelp(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.SymbioticLRT) {
            swap.data = ScalingDataL2Lib.newSymbioticLRT(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.MaverickV2) {
            swap.data = ScalingDataL2Lib.newMaverickV2(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.Integral) {
            swap.data = ScalingDataL2Lib.newIntegral(swap.data, oldAmount, newAmount);
        } else if (DexIndex(functionSelectorIndex) == DexIndex.SwaapV2) {
            revert("InputScalingHelper: Can not scale SwaapV2 swap");
        } else {
            revert("InputScaleHelper: Dex type not supported");
        }
        return swap;
    }

    function _flagsChecked(uint256 number, uint256 flag) internal pure returns (bool) {
        return number & flag != 0;
    }
}

// File: contracts/pendle/contracts/router/swap-aggregator/PendleSwap.sol

pragma solidity ^0.8.17;






contract PendleSwap is IPSwapAggregator, TokenHelper {
    using Address for address;

    address public immutable KYBER_SCALING_HELPER = 0x2f577A41BeC1BE1152AeEA12e73b7391d15f655D;

    function swap(address tokenIn, uint256 amountIn, SwapData calldata data) external payable {
        _safeApproveInf(tokenIn, data.extRouter);
        data.extRouter.functionCallWithValue(
            data.needScale ? _getScaledInputData(data.swapType, data.extCalldata, amountIn) : data.extCalldata,
            tokenIn == NATIVE ? amountIn : 0
        );

        emit SwapSingle(data.swapType, tokenIn, amountIn);
    }

    function swapMultiOdos(address[] calldata tokensIn, SwapData calldata data) external payable {
        for (uint256 i = 0; i < tokensIn.length; ++i) {
            _safeApproveInf(tokensIn[i], data.extRouter);
        }
        data.extRouter.functionCallWithValue(data.extCalldata, msg.value);
    }

    function _getScaledInputData(
        SwapType swapType,
        bytes calldata rawCallData,
        uint256 amountIn
    ) internal view returns (bytes memory scaledCallData) {
        if (swapType == SwapType.KYBERSWAP) {
            bool isSuccess;
            (isSuccess, scaledCallData) = IKyberScalingHelper(KYBER_SCALING_HELPER).getScaledInputData(
                rawCallData,
                amountIn
            );

            require(isSuccess, "PendleSwap: Kyber scaling failed");
        } else if (swapType == SwapType.ODOS) {
            scaledCallData = _odosScaling(rawCallData, amountIn);
        } else {
            assert(false);
        }
    }

    function _odosScaling(
        bytes calldata rawCallData,
        uint256 amountIn
    ) internal pure returns (bytes memory scaledCallData) {
        bytes4 selector = bytes4(rawCallData[:4]);
        bytes calldata dataToDecode = rawCallData[4:];

        assert(selector == IOdosRouterV2.swap.selector);
        (
            IOdosRouterV2.swapTokenInfo memory tokenInfo,
            bytes memory pathDefinition,
            address executor,
            uint32 referralCode
        ) = abi.decode(dataToDecode, (IOdosRouterV2.swapTokenInfo, bytes, address, uint32));

        tokenInfo.outputQuote = (tokenInfo.outputQuote * amountIn) / tokenInfo.inputAmount;
        tokenInfo.outputMin = (tokenInfo.outputMin * amountIn) / tokenInfo.inputAmount;
        tokenInfo.inputAmount = amountIn;

        return abi.encodeWithSelector(selector, tokenInfo, pathDefinition, executor, referralCode);
    }

    receive() external payable {}
}

interface IKyberScalingHelper {
    function getScaledInputData(
        bytes calldata inputData,
        uint256 newAmount
    ) external view returns (bool isSuccess, bytes memory data);
}

interface IOdosRouterV2 {
    struct swapTokenInfo {
        address inputToken;
        uint256 inputAmount;
        address inputReceiver;
        address outputToken;
        uint256 outputQuote;
        uint256 outputMin;
        address outputReceiver;
    }

    function swap(
        swapTokenInfo memory tokenInfo,
        bytes calldata pathDefinition,
        address executor,
        uint32 referralCode
    ) external payable returns (uint256 amountOut);
}
