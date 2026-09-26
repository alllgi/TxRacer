// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

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

// File: src/interfaces/IErrors.sol

pragma solidity 0.8.22;

/// @title IErrors
/// @notice Common interface for errors
interface IErrors {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the returned amount is less than the minimum amount
    error InsufficientReturnAmount();

    /// @notice Emitted when the specified toAmount is less than the minimum amount (2)
    error InvalidToAmount();

    /// @notice Emmited when the srcToken and destToken are the same
    error ArbitrageNotSupported();
}

// File: src/AugustusV6Types.sol

pragma solidity 0.8.22;

// Interfaces


/*//////////////////////////////////////////////////////////////
                        GENERIC SWAP DATA
//////////////////////////////////////////////////////////////*/

/// @notice Struct containg data for generic swapExactAmountIn/swapExactAmountOut
/// @param srcToken The token to swap from
/// @param destToken The token to swap to
/// @param fromAmount The amount of srcToken to swap
/// = amountIn for swapExactAmountIn and maxAmountIn for swapExactAmountOut
/// @param toAmount The minimum amount of destToken to receive
/// = minAmountOut for swapExactAmountIn and amountOut for swapExactAmountOut
/// @param quotedAmount The quoted expected amount of destToken/srcToken
/// = quotedAmountOut for swapExactAmountIn and quotedAmountIn for swapExactAmountOut
/// @param metadata Packed uuid and additional metadata
/// @param beneficiary The address to send the swapped tokens to
struct GenericData {
    IERC20 srcToken;
    IERC20 destToken;
    uint256 fromAmount;
    uint256 toAmount;
    uint256 quotedAmount;
    bytes32 metadata;
    address payable beneficiary;
}

/*//////////////////////////////////////////////////////////////
                            UNISWAPV2
//////////////////////////////////////////////////////////////*/

/// @notice Struct for UniswapV2 swapExactAmountIn/swapExactAmountOut data
/// @param srcToken The token to swap from
/// @param destToken The token to swap to
/// @param fromAmount The amount of srcToken to swap
/// = amountIn for swapExactAmountIn and maxAmountIn for swapExactAmountOut
/// @param quotedAmount The quoted expected amount of destToken/srcToken
/// = quotedAmountOut for swapExactAmountIn and quotedAmountIn for swapExactAmountOut
/// @param toAmount The minimum amount of destToken to receive
/// = minAmountOut for swapExactAmountIn and amountOut for swapExactAmountOut
/// @param metadata Packed uuid and additional metadata
/// @param beneficiary The address to send the swapped tokens to
/// @param pools data consisting of concatenated token0 and token1 address for each pool with the direction flag being
/// the right most bit of the packed token0-token1 pair bytes used in the path
struct UniswapV2Data {
    IERC20 srcToken;
    IERC20 destToken;
    uint256 fromAmount;
    uint256 toAmount;
    uint256 quotedAmount;
    bytes32 metadata;
    address payable beneficiary;
    bytes pools;
}

/*//////////////////////////////////////////////////////////////
                            UNISWAPV3
//////////////////////////////////////////////////////////////*/

/// @notice Struct for UniswapV3 swapExactAmountIn/swapExactAmountOut data
/// @param srcToken The token to swap from
/// @param destToken The token to swap to
/// @param fromAmount The amount of srcToken to swap
/// = amountIn for swapExactAmountIn and maxAmountIn for swapExactAmountOut
/// @param quotedAmount The quoted expected amount of destToken/srcToken
/// = quotedAmountOut for swapExactAmountIn and quotedAmountIn for swapExactAmountOut
/// @param toAmount The minimum amount of destToken to receive
/// = minAmountOut for swapExactAmountIn and amountOut for swapExactAmountOut
/// @param metadata Packed uuid and additional metadata
/// @param beneficiary The address to send the swapped tokens to
/// @param pools data consisting of concatenated token0-
/// token1-fee bytes for each pool used in the path, with the direction flag being the left most bit of token0 in the
/// concatenated bytes
struct UniswapV3Data {
    IERC20 srcToken;
    IERC20 destToken;
    uint256 fromAmount;
    uint256 toAmount;
    uint256 quotedAmount;
    bytes32 metadata;
    address payable beneficiary;
    bytes pools;
}

/*//////////////////////////////////////////////////////////////
                            CURVE V1
//////////////////////////////////////////////////////////////*/

/// @notice Struct for CurveV1 swapExactAmountIn data
/// @param curveData Packed data for the Curve pool, first 160 bits is the target exchange address,
/// the 161st bit is the approve flag, bits from (162 - 163) are used for the wrap flag,
//// bits from (164 - 165) are used for the swapType flag and the last 91 bits are unused:
/// Approve Flag - a) 0 -> do not approve b) 1 -> approve
/// Wrap Flag - a) 0 -> do not wrap b) 1 -> wrap native & srcToken == eth
/// c) 2 -> unwrap and destToken == eth d) 3 - >srcToken == eth && do not wrap
/// Swap Type Flag -  a) 0 -> EXCHANGE b) 1 -> EXCHANGE_UNDERLYING
/// @param curveAssets Packed uint128 index i and uint128 index j of the pool
/// The first 128 bits is the index i and the second 128 bits is the index j
/// @param srcToken The token to swap from
/// @param destToken The token to swap to
/// @param fromAmount The amount of srcToken to swap
/// = amountIn for swapExactAmountIn and maxAmountIn for swapExactAmountOut
/// @param toAmount The minimum amount that must be recieved
/// = minAmountOut for swapExactAmountIn and amountOut for swapExactAmountOut
/// @param quotedAmount The expected amount of destToken to be recieved
/// = quotedAmountOut for swapExactAmountIn and quotedAmountIn for swapExactAmountOut
/// @param metadata Packed uuid and additional metadata
/// @param beneficiary The address to send the swapped tokens to
struct CurveV1Data {
    uint256 curveData;
    uint256 curveAssets;
    IERC20 srcToken;
    IERC20 destToken;
    uint256 fromAmount;
    uint256 toAmount;
    uint256 quotedAmount;
    bytes32 metadata;
    address payable beneficiary;
}

/*//////////////////////////////////////////////////////////////
                            CURVE V2
//////////////////////////////////////////////////////////////*/

/// @notice Struct for CurveV2 swapExactAmountIn data
/// @param curveData Packed data for the Curve pool, first 160 bits is the target exchange address,
/// the 161st bit is the approve flag, bits from (162 - 163) are used for the wrap flag,
//// bits from (164 - 165) are used for the swapType flag and the last 91 bits are unused
/// Approve Flag - a) 0 -> do not approve b) 1 -> approve
/// Approve Flag - a) 0 -> do not approve b) 1 -> approve
/// Wrap Flag - a) 0 -> do not wrap b) 1 -> wrap native & srcToken == eth
/// c) 2 -> unwrap and destToken == eth d) 3 - >srcToken == eth && do not wrap
/// Swap Type Flag -  a) 0 -> EXCHANGE b) 1 -> EXCHANGE_UNDERLYING c) 2 -> EXCHANGE_UNDERLYING_FACTORY_ZAP
/// @param i The index of the srcToken
/// @param j The index of the destToken
/// The first 128 bits is the index i and the second 128 bits is the index j
/// @param poolAddress The address of the CurveV2 pool (only used for EXCHANGE_UNDERLYING_FACTORY_ZAP)
/// @param srcToken The token to swap from
/// @param destToken The token to swap to
/// @param fromAmount The amount of srcToken to swap
/// = amountIn for swapExactAmountIn and maxAmountIn for swapExactAmountOut
/// @param toAmount The minimum amount that must be recieved
/// = minAmountOut for swapExactAmountIn and amountOut for swapExactAmountOut
/// @param quotedAmount The expected amount of destToken to be recieved
/// = quotedAmountOut for swapExactAmountIn and quotedAmountIn for swapExactAmountOut
/// @param metadata Packed uuid and additional metadata
/// @param beneficiary The address to send the swapped tokens to
struct CurveV2Data {
    uint256 curveData;
    uint256 i;
    uint256 j;
    address poolAddress;
    IERC20 srcToken;
    IERC20 destToken;
    uint256 fromAmount;
    uint256 toAmount;
    uint256 quotedAmount;
    bytes32 metadata;
    address payable beneficiary;
}

/*//////////////////////////////////////////////////////////////
                            BALANCER V2
//////////////////////////////////////////////////////////////*/

/// @notice Struct for BalancerV2 swapExactAmountIn data
/// @param fromAmount The amount of srcToken to swap
/// = amountIn for swapExactAmountIn and maxAmountIn for swapExactAmountOut
/// @param toAmount The minimum amount of destToken to receive
/// = minAmountOut for swapExactAmountIn and amountOut for swapExactAmountOut
/// @param quotedAmount The quoted expected amount of destToken/srcToken
/// = quotedAmountOut for swapExactAmountIn and quotedAmountIn for swapExactAmountOut
/// @param metadata Packed uuid and additional metadata
/// @param beneficiaryAndApproveFlag The beneficiary address and approve flag packed into one uint256,
/// the first 20 bytes are the beneficiary address and the left most bit is the approve flag
struct BalancerV2Data {
    uint256 fromAmount;
    uint256 toAmount;
    uint256 quotedAmount;
    bytes32 metadata;
    uint256 beneficiaryAndApproveFlag;
}

/*//////////////////////////////////////////////////////////////
                            MAKERPSM
//////////////////////////////////////////////////////////////*/

/// @notice Struct for Maker PSM swapExactAmountIn data
/// @param srcToken The token to swap from
/// @param destToken The token to swap to
/// @param fromAmount The amount of srcToken to swap
/// = amountIn for swapExactAmountIn and maxAmountIn for swapExactAmountOut
/// @param toAmount The minimum amount of destToken to receive
/// = minAmountOut for swapExactAmountIn and amountOut for swapExactAmountOut
/// @param toll Used to calculate gem amount for the swapExactAmountIn
/// @param to18ConversionFactor Used to calculate gem amount for the swapExactAmountIn
/// @param gemJoinAddress The address of the gemJoin contract
/// @param exchange The address of the exchange contract
/// @param metadata Packed uuid and additional metadata
/// @param beneficiaryDirectionApproveFlag The beneficiary address, swap direction and approve flag packed
/// into one uint256, the first 20 bytes are the beneficiary address, the left most bit is the approve flag and the
/// second left most bit is the swap direction flag, 0 for swapExactAmountIn and 1 for swapExactAmountOut
struct MakerPSMData {
    IERC20 srcToken;
    IERC20 destToken;
    uint256 fromAmount;
    uint256 toAmount;
    uint256 toll;
    uint256 to18ConversionFactor;
    address exchange;
    address gemJoinAddress;
    bytes32 metadata;
    uint256 beneficiaryDirectionApproveFlag;
}

/*//////////////////////////////////////////////////////////////
                            AUGUSTUS RFQ
//////////////////////////////////////////////////////////////*/

/// @notice Order struct for Augustus RFQ
/// @param nonceAndMeta The nonce and meta data packed into one uint256,
/// the first 160 bits is the user address and the last 96 bits is the nonce
/// @param expiry The expiry of the order
/// @param makerAsset The address of the maker asset
/// @param takerAsset The address of the taker asset
/// @param maker The address of the maker
/// @param taker The address of the taker, if the taker is address(0) anyone can take the order
/// @param makerAmount The amount of makerAsset
/// @param takerAmount The amount of takerAsset
struct Order {
    uint256 nonceAndMeta;
    uint128 expiry;
    address makerAsset;
    address takerAsset;
    address maker;
    address taker;
    uint256 makerAmount;
    uint256 takerAmount;
}

/// @notice Struct containing order info for Augustus RFQ
/// @param order The order struct
/// @param signature The signature for the order
/// @param takerTokenFillAmount The amount of takerToken to fill
/// @param permitTakerAsset The permit data for the taker asset
/// @param permitMakerAsset The permit data for the maker asset
struct OrderInfo {
    Order order;
    bytes signature;
    uint256 takerTokenFillAmount;
    bytes permitTakerAsset;
    bytes permitMakerAsset;
}

/// @notice Struct containing common data for executing swaps on Augustus RFQ
/// @param fromAmount The amount of srcToken to swap
/// = amountIn for swapExactAmountIn and maxAmountIn for swapExactAmountOut
/// @param toAmount The minimum amount of destToken to receive
/// = minAmountOut for swapExactAmountIn and amountOut for swapExactAmountOut
/// @param wrapApproveDirection The wrap, approve and direction flag packed into one uint8,
/// the first 2 bits is wrap flag (10 for wrap dest, 01 for wrap src, 00 for no wrap), the next bit is the approve flag
/// (1 for approve, 0 for no approve) and the last bit is the direction flag (0 for swapExactAmountIn and 1 for
/// swapExactAmountOut)
/// @param metadata Packed uuid and additional metadata
struct AugustusRFQData {
    uint256 fromAmount;
    uint256 toAmount;
    uint8 wrapApproveDirection;
    bytes32 metadata;
    address payable beneficiary;
}

// File: src/interfaces/IProPartnerFacet.sol

pragma solidity 0.8.22;




/// @title IProPartnerFacet
/// @notice Interface for swaps with custom fee model: partner gets 100% of fixed fees, protocol gets 50% of surplus
/// @dev Fee Distribution Model:
///      - Partner receives: 100% of the fixed fee (calculated on quotedAmount + surplus)
///      - Protocol receives: 50% of remaining surplus (after fixed fee is taken)
///      - User receives: Everything else
interface IProPartnerFacet is IErrors {
    /// @notice Execute a swap with exact input amount using custom fee model
    /// @dev Fee split: Partner gets 100% of fixed fees, ParaSwap gets 50% of remaining surplus
    /// @param executor The address of the executor contract to use
    /// @param swapData Generic data containing the swap information
    /// @param partnerAndFee Packed uint256 with partner address and fee configuration
    /// @param permit The permit data for token approval
    /// @param executorData The data to execute on the executor
    /// @return receivedAmount The amount of destToken the user receives (after all fees)
    /// @return paraswapShare Protocol's fee share (50% of remaining surplus after fixed fee)
    /// @return partnerShare Partner's fee share (100% of the fixed fee)
    function swapExactAmountInPro(
        address executor,
        GenericData calldata swapData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata executorData
    )
        external
        payable
        returns (uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare);

    /// @notice Execute a swap with exact output amount using custom fee model
    /// @dev Fee split: Partner gets 100% of fixed fees, ParaSwap gets 50% of surplus (spending less)
    /// @param executor The address of the executor contract to use
    /// @param swapData Generic data containing the swap information
    /// @param partnerAndFee Packed uint256 with partner address and fee configuration
    /// @param permit The permit data for token approval
    /// @param executorData The data to execute on the executor
    /// @return spentAmount The actual amount of srcToken spent in the swap
    /// @return receivedAmount The amount of destToken the user receives
    /// @return paraswapShare Protocol's fee share (50% of surplus from spending less)
    /// @return partnerShare Partner's fee share (100% of the fixed fee)
    function swapExactAmountOutPro(
        address executor,
        GenericData calldata swapData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata executorData
    )
        external
        payable
        returns (uint256 spentAmount, uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare);
}

// File: src/libraries/ERC20Utils.sol

pragma solidity 0.8.22;

// Interfaces


/// @title ERC20Utils
/// @notice Optimized functions for ERC20 tokens
library ERC20Utils {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error IncorrectEthAmount();
    error PermitFailed();
    error TransferFromFailed();
    error TransferFailed();
    error ApprovalFailed();

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    IERC20 internal constant ETH = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /*//////////////////////////////////////////////////////////////
                                APPROVE
    //////////////////////////////////////////////////////////////*/

    /// @dev Vendored from Solady by @vectorized - SafeTransferLib.approveWithRetry
    /// https://github.com/Vectorized/solady/src/utils/SafeTransferLib.sol#L325
    /// Instead of approving a specific amount, this function approves for uint256(-1) (type(uint256).max).
    function approve(IERC20 token, address to) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) // Store the `amount`
                // argument (type(uint256).max).
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) // Store 0 for the `amount`.
                mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                mstore(0x34, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) // Store
                    // type(uint256).max for the `amount`.
                // Retry the approval, reverting upon failure.
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0, 0x8164f84200000000000000000000000000000000000000000000000000000000)
                    // store the selector (error ApprovalFailed())
                    revert(0, 4) // revert with error selector
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /*//////////////////////////////////////////////////////////////
                                PERMIT
    //////////////////////////////////////////////////////////////*/

    /// @dev Executes an ERC20 permit and reverts if invalid length is provided
    function permit(IERC20 token, bytes calldata data) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            // check the permit length
            switch data.length
            // 32 * 7 = 224 EIP2612 Permit
            case 224 {
                let x := mload(64) // get the free memory pointer
                mstore(x, 0xd505accf00000000000000000000000000000000000000000000000000000000) // store the selector
                    // function permit(address owner, address spender, uint256
                    // amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
                calldatacopy(add(x, 4), data.offset, 224) // store the args
                pop(call(gas(), token, 0, x, 228, 0, 32)) // call ERC20 permit, skip checking return data
            }
            // 32 * 8 = 256 DAI-Style Permit
            case 256 {
                let x := mload(64) // get the free memory pointer
                mstore(x, 0x8fcbaf0c00000000000000000000000000000000000000000000000000000000) // store the selector
                    // function permit(address holder, address spender, uint256
                    // nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s)
                calldatacopy(add(x, 4), data.offset, 256) // store the args
                pop(call(gas(), token, 0, x, 260, 0, 32)) // call ERC20 permit, skip checking return data
            }
            default {
                mstore(0, 0xb78cb0dd00000000000000000000000000000000000000000000000000000000) // store the selector
                    // (error PermitFailed())
                revert(0, 4)
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                                 ETH
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns 1 if the token is ETH, 0 if not ETH
    function isETH(IERC20 token, uint256 amount) internal view returns (uint256 fromETH) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            // If token is ETH
            if eq(token, 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                // if msg.value is not equal to fromAmount, then revert
                if xor(amount, callvalue()) {
                    mstore(0, 0x8b6ebb4d00000000000000000000000000000000000000000000000000000000) // store the selector
                        // (error IncorrectEthAmount())
                    revert(0, 4) // revert with error selector
                }
                // return 1 if ETH
                fromETH := 1
            }
            // If token is not ETH
            if xor(token, 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                // if msg.value is not equal to 0, then revert
                if gt(callvalue(), 0) {
                    mstore(0, 0x8b6ebb4d00000000000000000000000000000000000000000000000000000000) // store the selector
                    // (error IncorrectEthAmount())
                    revert(0, 4) // revert with error selector
                }
            }
        }
        // return 0 if not ETH
    }

    /*//////////////////////////////////////////////////////////////
                                TRANSFER
    //////////////////////////////////////////////////////////////*/

    /// @dev Executes transfer and reverts if it fails, works for both ETH and ERC20 transfers
    function safeTransfer(IERC20 token, address recipient, uint256 amount) internal returns (bool success) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            switch eq(token, 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
            // ETH
            case 1 {
                // transfer ETH
                // Cap gas at 10000 to avoid reentrancy
                success := call(10000, recipient, amount, 0, 0, 0, 0)
            }
            // ERC20
            default {
                let x := mload(64) // get the free memory pointer
                mstore(x, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // store the selector
                    // (function transfer(address recipient, uint256 amount))
                mstore(add(x, 4), recipient) // store the recipient
                mstore(add(x, 36), amount) // store the amount
                success := call(gas(), token, 0, x, 68, 0, 32) // call transfer
                if success {
                    switch returndatasize()
                    // check the return data size
                    case 0 { success := gt(extcodesize(token), 0) }
                    default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
                }
            }
            if iszero(success) {
                mstore(0, 0x90b8ec1800000000000000000000000000000000000000000000000000000000) // store the selector
                    // (error TransferFailed())
                revert(0, 4) // revert with error selector
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                             TRANSFER FROM
    //////////////////////////////////////////////////////////////*/

    /// @dev Executes transferFrom and reverts if it fails
    function safeTransferFrom(
        IERC20 srcToken,
        address sender,
        address recipient,
        uint256 amount
    )
        internal
        returns (bool success)
    {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let x := mload(64) // get the free memory pointer
            mstore(x, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // store the selector
                // (function transferFrom(address sender, address recipient,
                // uint256 amount))
            mstore(add(x, 4), sender) // store the sender
            mstore(add(x, 36), recipient) // store the recipient
            mstore(add(x, 68), amount) // store the amount
            success := call(gas(), srcToken, 0, x, 100, 0, 32) // call transferFrom
            if success {
                switch returndatasize()
                // check the return data size
                case 0 { success := gt(extcodesize(srcToken), 0) }
                default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
            }
            if iszero(success) {
                mstore(x, 0x7939f42400000000000000000000000000000000000000000000000000000000) // store the selector
                    // (error TransferFromFailed())
                revert(x, 4) // revert with error selector
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                                BALANCE
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns the balance of an account, works for both ETH and ERC20 tokens
    function getBalance(IERC20 token, address account) internal view returns (uint256 balanceOf) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            switch eq(token, 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
            // ETH
            case 1 { balanceOf := balance(account) }
            // ERC20
            default {
                let x := mload(64) // get the free memory pointer
                mstore(x, 0x70a0823100000000000000000000000000000000000000000000000000000000) // store the selector
                    // (function balanceOf(address account))
                mstore(add(x, 4), account) // store the account
                let success := staticcall(gas(), token, x, 36, x, 32) // call balanceOf
                if success { balanceOf := mload(x) } // load the balance
            }
        }
    }
}

// File: src/interfaces/IAugustusFeeVault.sol

pragma solidity 0.8.22;

// Interfaces


/// @title IAugustusFeeVault
/// @notice Interface for the AugustusFeeVault contract
interface IAugustusFeeVault {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error emitted when withdraw amount is zero or exceeds the stored amount
    error InvalidWithdrawAmount();

    /// @notice Error emmitted when caller is not an approved augustus contract
    error UnauthorizedCaller();

    /// @notice Error emitted when an invalid parameter length is passed
    error InvalidParameterLength();

    /// @notice Error emitted when batch withdraw fails
    error BatchCollectFailed();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an augustus contract approval status is set
    /// @param augustus The augustus contract address
    /// @param approved The approval status
    event AugustusApprovalSet(address indexed augustus, bool approved);

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Struct to register fees
    /// @param addresses The addresses to register fees for
    /// @param token The token to register fees for
    /// @param fees The fees to register
    struct FeeRegistration {
        address[] addresses;
        IERC20 token;
        uint256[] fees;
    }

    /*//////////////////////////////////////////////////////////////
                                COLLECT
    //////////////////////////////////////////////////////////////*/

    /// @notice Allows partners to withdraw fees allocated to them and stored in the vault
    /// @param token The token to withdraw fees in
    /// @param amount The amount of fees to withdraw
    /// @param recipient The address to send the fees to
    /// @return success Whether the transfer was successful or not
    function withdrawSomeERC20(IERC20 token, uint256 amount, address recipient) external returns (bool success);

    /// @notice Allows partners to withdraw all fees allocated to them and stored in the vault for a given token
    /// @param token The token to withdraw fees in
    /// @param recipient The address to send the fees to
    /// @return success Whether the transfer was successful or not
    function withdrawAllERC20(IERC20 token, address recipient) external returns (bool success);

    /// @notice Allows partners to withdraw all fees allocated to them and stored in the vault for multiple tokens
    /// @param tokens The tokens to withdraw fees i
    /// @param recipient The address to send the fees to
    /// @return success Whether the transfer was successful or not
    function batchWithdrawAllERC20(IERC20[] calldata tokens, address recipient) external returns (bool success);

    /// @notice Allows partners to withdraw fees allocated to them and stored in the vault
    /// @param tokens The tokens to withdraw fees in
    /// @param amounts The amounts of fees to withdraw
    /// @param recipient The address to send the fees to
    /// @return success Whether the transfer was successful or not
    function batchWithdrawSomeERC20(
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    )
        external
        returns (bool success);

    /*//////////////////////////////////////////////////////////////
                            BALANCE GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the balance of a given token for a given partner
    /// @param token The token to get the balance of
    /// @param partner The partner to get the balance for
    /// @return feeBalance The balance of the given token for the given partner
    function getBalance(IERC20 token, address partner) external view returns (uint256 feeBalance);

    /// @notice Get the balances of a given partner for multiple tokens
    /// @param tokens The tokens to get the balances of
    /// @param partner The partner to get the balances for
    /// @return feeBalances The balances of the given tokens for the given partner
    function batchGetBalance(
        IERC20[] calldata tokens,
        address partner
    )
        external
        view
        returns (uint256[] memory feeBalances);

    /// @notice Returns the unallocated fees for a given token
    /// @param token The token to get the unallocated fees for
    /// @return unallocatedFees The unallocated fees for the given token
    function getUnallocatedFees(IERC20 token) external view returns (uint256 unallocatedFees);

    /*//////////////////////////////////////////////////////////////
                                 OWNER
    //////////////////////////////////////////////////////////////*/

    /// @notice Registers the given feeData to the vault
    /// @param feeData The fee registration data
    function registerFees(FeeRegistration memory feeData) external;

    /// @notice Sets the augustus contract approval status
    /// @param augustus The augustus contract address
    /// @param approved The approval status
    function setAugustusApproval(address augustus, bool approved) external;

    /// @notice Sets the contract pause state
    /// @param _isPaused The new pause state
    function setContractPauseState(bool _isPaused) external;
}

// File: src/interfaces/IAugustusFees.sol

pragma solidity 0.8.22;

/// @title IAugustusFees
/// @notice Interface for the AugustusFees contract, which handles the fees for the Augustus aggregator
interface IAugustusFees {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error emmited when the balance is not enough to pay the fees
    error InsufficientBalanceToPayFees();

    /// @notice Error emmited when the quotedAmount is bigger than the fromAmount
    error InvalidQuotedAmount();

    /*//////////////////////////////////////////////////////////////
                                 PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Parses the `partnerAndFee` parameter to extract the partner address and fee data.
    /// @dev `partnerAndFee` is a uint256 value where data is packed in a specific bit layout.
    ///
    ///      The bit layout for `partnerAndFee` is as follows:
    ///      - The most significant 160 bits (positions 255 to 96) represent the partner address.
    ///      - Bits 95 to 92 are reserved for flags indicating various fee processing conditions:
    ///          - 95th bit: `IS_TAKE_SURPLUS_MASK` - Partner takes surplus
    ///          - 94th bit: `IS_REFERRAL_MASK` - Referral takes surplus
    ///          - 93rd bit: `IS_SKIP_BLACKLIST_MASK` - Bypass token blacklist when processing fees
    ///          - 92nd bit: `IS_CAP_SURPLUS_MASK` - Cap surplus to 1% of quoted amount
    ///      - The least significant 16 bits (positions 15 to 0) encode the fee percentage.
    ///
    /// @param partnerAndFee Packed uint256 containing both partner address and fee data.
    /// @return partner The extracted partner address as a payable address.
    /// @return feeData The extracted fee data containing the fee percentage and flags.
    function parsePartnerAndFeeData(uint256 partnerAndFee)
        external
        pure
        returns (address payable partner, uint256 feeData);
}

// File: src/storage/AugustusStorage.sol

pragma solidity 0.8.22;

// Interfaces


// @title AugustusStorage
// @notice Inherited storage layout for AugustusV6,
// contracts should inherit this contract to access the storage layout
contract AugustusStorage {
    /*//////////////////////////////////////////////////////////////
                               FEES
    //////////////////////////////////////////////////////////////*/

    // @dev Mapping of tokens to boolean indicating if token is blacklisted for fee collection
    mapping(IERC20 token => bool isBlacklisted) public blacklistedTokens;

    // @dev Fee wallet to directly transfer paraswap share to
    address payable public feeWallet;

    // @dev Fee wallet address to register the paraswap share to in the fee vault
    address payable public feeWalletDelegate;

    /*//////////////////////////////////////////////////////////////
                                CONTROL
    //////////////////////////////////////////////////////////////*/

    // @dev Contract paused state
    bool public paused;
}

// File: src/fees/AugustusFees.sol

pragma solidity 0.8.22;

// Interfaces




// Libraries


// Storage


/// @title AugustusFees
/// @notice Contract for handling fees
contract AugustusFees is AugustusStorage, IAugustusFees {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Fee share constants
    uint256 public constant PARTNER_SHARE_PERCENT = 8500;
    uint256 public constant MAX_FEE_PERCENT = 200;
    uint256 public constant SURPLUS_PERCENT = 100;
    uint256 public constant PARASWAP_REFERRAL_SHARE = 5000;
    uint256 public constant PARTNER_REFERRAL_SHARE = 2500;
    uint256 public constant PARASWAP_SURPLUS_SHARE = 5000;
    uint256 public constant PARASWAP_SLIPPAGE_SHARE = 10_000;
    uint256 public constant MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI = 11;

    /// @dev Masks for unpacking feeData
    uint256 internal constant FEE_PERCENT_IN_BASIS_POINTS_MASK = 0x3FFF;
    uint256 private constant IS_USER_SURPLUS_MASK = 1 << 90;
    uint256 internal constant IS_DIRECT_TRANSFER_MASK = 1 << 91;
    uint256 internal constant IS_CAP_SURPLUS_MASK = 1 << 92;
    uint256 internal constant IS_SKIP_BLACKLIST_MASK = 1 << 93;
    uint256 private constant IS_REFERRAL_MASK = 1 << 94;
    uint256 private constant IS_TAKE_SURPLUS_MASK = 1 << 95;

    /// @dev A contact that stores fees collected by the protocol
    IAugustusFeeVault public immutable FEE_VAULT; // solhint-disable-line var-name-mixedcase

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _feeVault) {
        FEE_VAULT = IAugustusFeeVault(_feeVault);
    }

    /*//////////////////////////////////////////////////////////////
                       SWAP EXACT AMOUNT IN FEES
    //////////////////////////////////////////////////////////////*/

    /// @notice Process swapExactAmountIn fees and transfer the received amount to the beneficiary
    /// @param destToken The received token from the swapExactAmountIn
    /// @param partnerAndFee Packed partner and fee data
    /// @param receivedAmount The amount of destToken received from the swapExactAmountIn
    /// @param quotedAmount The quoted expected amount of destToken
    /// @return returnAmount The amount of destToken transfered to the beneficiary
    /// @return paraswapFeeShare The share of the fees for Paraswap
    /// @return partnerFeeShare The share of the fees for the partner
    function processSwapExactAmountInFeesAndTransfer(
        address beneficiary,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 receivedAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 returnAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // initialize the surplus
        uint256 surplus;

        // parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // calculate the surplus, we expect there to be 1 wei dust left which we should
        // not take into account when determining if there is surplus, we only take the
        // surplus if it is greater than MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (receivedAmount > quotedAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = receivedAmount - quotedAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // calculate remainingAmount
        uint256 remainingAmount = receivedAmount - surplus;

        // if partner address is not 0x0
        if (partner != address(0x0)) {
            // Check if skip blacklist flag is true
            bool skipBlacklist = feeData & IS_SKIP_BLACKLIST_MASK != 0;
            // Check if token is blacklisted
            bool isBlacklisted = blacklistedTokens[destToken];
            // If the token is blacklisted and the skipBlacklist flag is false,
            // send the received amount to the beneficiary, we won't process fees
            if (!skipBlacklist && isBlacklisted) {
                // transfer the received amount to the beneficiary, keeping 1 wei dust
                _transferAndLeaveDust(destToken, beneficiary, receivedAmount);
                return (receivedAmount - 1, 0, 0);
            }
            // Check if direct transfer flag is true
            bool isDirectTransfer = feeData & IS_DIRECT_TRANSFER_MASK != 0;
            // partner takes fixed fees feePercent is greater than 0
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // fee base = min (receivedAmount, quotedAmount + surplus)
                uint256 feeBase = receivedAmount > quotedAmount + surplus ? quotedAmount + surplus : receivedAmount;
                // calculate fixed fees
                uint256 fee = (feeBase * feePercent) / 10_000;
                partnerFeeShare = (fee * PARTNER_SHARE_PERCENT) / 10_000;
                paraswapFeeShare = fee - partnerFeeShare;
                // distrubite fees from destToken
                returnAmount = _distributeFees(
                    receivedAmount,
                    destToken,
                    partner,
                    partnerFeeShare,
                    paraswapFeeShare,
                    skipBlacklist,
                    isBlacklisted,
                    isDirectTransfer
                );
                // transfer the return amount to the beneficiary, keeping 1 wei dust
                _transferAndLeaveDust(destToken, beneficiary, returnAmount);
                return (returnAmount - 1, paraswapFeeShare, partnerFeeShare);
            }
            // if slippage is postive and referral flag is true
            else if (feeData & IS_REFERRAL_MASK != 0) {
                if (surplus > 0) {
                    // the split is 50% for paraswap, 25% for the referrer and 25% for the user
                    paraswapFeeShare = (surplus * PARASWAP_REFERRAL_SHARE) / 10_000;
                    partnerFeeShare = (surplus * PARTNER_REFERRAL_SHARE) / 10_000;
                    // distribute fees from destToken
                    returnAmount = _distributeFees(
                        receivedAmount,
                        destToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the return amount to the beneficiary, keeping 1 wei dust
                    _transferAndLeaveDust(destToken, beneficiary, returnAmount);
                    return (returnAmount - 1, paraswapFeeShare, partnerFeeShare);
                }
            }
            // if slippage is positive and takeSurplus flag is true
            else if (feeData & IS_TAKE_SURPLUS_MASK != 0) {
                if (surplus > 0) {
                    // paraswap takes 50% of the surplus and partner takes the other 50%
                    paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;
                    partnerFeeShare = surplus - paraswapFeeShare;
                    // If user surplus flag is true, transfer the partner share to the user instead of the partner
                    if (feeData & IS_USER_SURPLUS_MASK != 0) {
                        partnerFeeShare = 0;
                        // Transfer the paraswap share directly to the fee wallet
                        isDirectTransfer = true;
                    }
                    // distrubite fees from destToken, partner takes 50% of the surplus
                    // and paraswap takes the other 50%
                    returnAmount = _distributeFees(
                        receivedAmount,
                        destToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the return amount to the beneficiary, keeping 1 wei dust
                    _transferAndLeaveDust(destToken, beneficiary, returnAmount);
                    return (returnAmount - 1, paraswapFeeShare, partnerFeeShare);
                }
            }
        }

        // if slippage is positive and partner address is 0x0 or fee percent is 0
        // paraswap will take the surplus and transfer the rest to the beneficiary
        // if there is no positive slippage, transfer the received amount to the beneficiary
        if (surplus > 0) {
            // If the token is blacklisted, send the received amount to the beneficiary
            // we won't process fees
            if (blacklistedTokens[destToken]) {
                // transfer the received amount to the beneficiary, keeping 1 wei dust
                _transferAndLeaveDust(destToken, beneficiary, receivedAmount);
                return (receivedAmount - 1, 0, 0);
            }
            // transfer the remaining amount to the beneficiary, keeping 1 wei dust
            _transferAndLeaveDust(destToken, beneficiary, remainingAmount);
            // transfer the surplus to the fee wallet
            destToken.safeTransfer(feeWallet, surplus);
            return (remainingAmount - 1, surplus, 0);
        } else {
            // transfer the received amount to the beneficiary, keeping 1 wei dust
            _transferAndLeaveDust(destToken, beneficiary, receivedAmount);
            return (receivedAmount - 1, 0, 0);
        }
    }

    /// @notice Process swapExactAmountIn fees and transfer the received amount to the beneficiary
    /// @param destToken The received token from the swapExactAmountIn
    /// @param partnerAndFee Packed partner and fee data
    /// @param receivedAmount The amount of destToken received from the swapExactAmountIn
    /// @param quotedAmount The quoted expected amount of destToken
    /// @return returnAmount The amount of destToken transfered to the beneficiary
    /// @return paraswapFeeShare The share of the fees for Paraswap
    /// @return partnerFeeShare The share of the fees for the partner
    function processSwapExactAmountInFeesAndTransferUniV3(
        address beneficiary,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 receivedAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 returnAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // initialize the surplus
        uint256 surplus;

        // parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // calculate the surplus, we do not take the surplus into account if it is less than
        // MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (receivedAmount > quotedAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = receivedAmount - quotedAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // calculate remainingAmount
        uint256 remainingAmount = receivedAmount - surplus;

        // if partner address is not 0x0
        if (partner != address(0x0)) {
            // Check if skip blacklist flag is true
            bool skipBlacklist = feeData & IS_SKIP_BLACKLIST_MASK != 0;
            // Check if token is blacklisted
            bool isBlacklisted = blacklistedTokens[destToken];
            // If the token is blacklisted and the skipBlacklist flag is false,
            // send the received amount to the beneficiary, we won't process fees
            if (!skipBlacklist && isBlacklisted) {
                // transfer the received amount to the beneficiary
                destToken.safeTransfer(beneficiary, receivedAmount);
                return (receivedAmount, 0, 0);
            }
            // Check if direct transfer flag is true
            bool isDirectTransfer = feeData & IS_DIRECT_TRANSFER_MASK != 0;
            // partner takes fixed fees feePercent is greater than 0
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // fee base = min (receivedAmount, quotedAmount + surplus)
                uint256 feeBase = receivedAmount > quotedAmount + surplus ? quotedAmount + surplus : receivedAmount;
                // calculate fixed fees
                uint256 fee = (feeBase * feePercent) / 10_000;
                partnerFeeShare = (fee * PARTNER_SHARE_PERCENT) / 10_000;
                paraswapFeeShare = fee - partnerFeeShare;
                // distrubite fees from destToken
                returnAmount = _distributeFees(
                    receivedAmount,
                    destToken,
                    partner,
                    partnerFeeShare,
                    paraswapFeeShare,
                    skipBlacklist,
                    isBlacklisted,
                    isDirectTransfer
                );
                // transfer the return amount to the beneficiary
                destToken.safeTransfer(beneficiary, returnAmount);
                return (returnAmount, paraswapFeeShare, partnerFeeShare);
            }
            // if slippage is postive and referral flag is true
            else if (feeData & IS_REFERRAL_MASK != 0) {
                if (surplus > 0) {
                    // the split is 50% for paraswap, 25% for the referrer and 25% for the user
                    paraswapFeeShare = (surplus * PARASWAP_REFERRAL_SHARE) / 10_000;
                    partnerFeeShare = (surplus * PARTNER_REFERRAL_SHARE) / 10_000;
                    // distribute fees from destToken
                    returnAmount = _distributeFees(
                        receivedAmount,
                        destToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the return amount to the beneficiary
                    destToken.safeTransfer(beneficiary, returnAmount);
                    return (returnAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
            // if slippage is positive and takeSurplus flag is true
            else if (feeData & IS_TAKE_SURPLUS_MASK != 0) {
                if (surplus > 0) {
                    // paraswap takes 50% of the surplus and partner takes the other 50%
                    paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;
                    partnerFeeShare = surplus - paraswapFeeShare;
                    // If user surplus flag is true, transfer the partner share to the user instead of the partner
                    if (feeData & IS_USER_SURPLUS_MASK != 0) {
                        partnerFeeShare = 0;
                        // Transfer the paraswap share directly to the fee wallet
                        isDirectTransfer = true;
                    }
                    // distrubite fees from destToken, partner takes 50% of the surplus
                    // and paraswap takes the other 50%
                    returnAmount = _distributeFees(
                        receivedAmount,
                        destToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the return amount to the beneficiary,
                    destToken.safeTransfer(beneficiary, returnAmount);
                    return (returnAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
        }

        // if slippage is positive and partner address is 0x0 or fee percent is 0
        // paraswap will take the surplus and transfer the rest to the beneficiary
        // if there is no positive slippage, transfer the received amount to the beneficiary
        if (surplus > 0) {
            // If the token is blacklisted, send the received amount to the beneficiary
            // we won't process fees
            if (blacklistedTokens[destToken]) {
                // transfer the received amount to the beneficiary
                destToken.safeTransfer(beneficiary, receivedAmount);
                return (receivedAmount, 0, 0);
            }
            // transfer the remaining amount to the beneficiary
            destToken.safeTransfer(beneficiary, remainingAmount);
            // transfer the surplus to the fee wallet
            destToken.safeTransfer(feeWallet, surplus);
            return (remainingAmount, surplus, 0);
        } else {
            // transfer the received amount to the beneficiary
            destToken.safeTransfer(beneficiary, receivedAmount);
            return (receivedAmount, 0, 0);
        }
    }

    /*//////////////////////////////////////////////////////////////
                       SWAP EXACT AMOUNT OUT FEES
    //////////////////////////////////////////////////////////////*/

    /// @notice Process swapExactAmountOut fees and transfer the received amount and remaining amount to the
    /// beneficiary
    /// @param srcToken The token used to swapExactAmountOut
    /// @param destToken The token received from the swapExactAmountOut
    /// @param partnerAndFee Packed partner and fee data
    /// @param maxAmountIn The amount of srcToken passed to the swapExactAmountOut
    /// @param receivedAmount The amount of destToken received from the swapExactAmountOut
    /// @param quotedAmount The quoted expected amount of srcToken to be used to swapExactAmountOut
    /// @return spentAmount The amount of srcToken used to swapExactAmountOut
    /// @return outAmount The amount of destToken transfered to the beneficiary
    /// @return paraswapFeeShare The share of the fees for Paraswap
    /// @return partnerFeeShare The share of the fees for the partner
    function processSwapExactAmountOutFeesAndTransfer(
        address beneficiary,
        IERC20 srcToken,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 maxAmountIn,
        uint256 remainingAmount,
        uint256 receivedAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 spentAmount, uint256 outAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // calculate the amount used to swapExactAmountOut
        spentAmount = maxAmountIn - (remainingAmount > 0 ? remainingAmount - 1 : remainingAmount);

        // initialize the surplus
        uint256 surplus;

        // initialize the return amount
        uint256 returnAmount;

        // parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // check if the quotedAmount is bigger than the maxAmountIn
        if (quotedAmount > maxAmountIn) {
            revert InvalidQuotedAmount();
        }

        // calculate the surplus, we do not take the surplus into account if it is less than
        // MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (quotedAmount > spentAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = quotedAmount - spentAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // if partner address is not 0x0
        if (partner != address(0x0)) {
            // Check if skip blacklist flag is true
            bool skipBlacklist = feeData & IS_SKIP_BLACKLIST_MASK != 0;
            // Check if token is blacklisted
            bool isBlacklisted = blacklistedTokens[srcToken];
            // If the token is blacklisted and the skipBlacklist flag is false,
            // send the remaining amount to the msg.sender, we won't process fees
            if (!skipBlacklist && isBlacklisted) {
                // transfer the remaining amount to msg.sender
                returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount);
                // transfer the received amount of destToken to the beneficiary
                destToken.safeTransfer(beneficiary, --receivedAmount);
                return (maxAmountIn - returnAmount, receivedAmount, 0, 0);
            }
            // Check if direct transfer flag is true
            bool isDirectTransfer = feeData & IS_DIRECT_TRANSFER_MASK != 0;
            // partner takes fixed fees feePercent is greater than 0
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // fee base = min (spentAmount, quotedAmount)
                uint256 feeBase = spentAmount < quotedAmount ? spentAmount : quotedAmount;
                // calculate fixed fees
                uint256 fee = (feeBase * feePercent) / 10_000;
                partnerFeeShare = (fee * PARTNER_SHARE_PERCENT) / 10_000;
                paraswapFeeShare = fee - partnerFeeShare;
                // distrubite fees from srcToken
                returnAmount = _distributeFees(
                    remainingAmount,
                    srcToken,
                    partner,
                    partnerFeeShare,
                    paraswapFeeShare,
                    skipBlacklist,
                    isBlacklisted,
                    isDirectTransfer
                );
                // transfer the rest to msg.sender
                returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, returnAmount);
                // transfer the received amount of destToken to the beneficiary
                destToken.safeTransfer(beneficiary, --receivedAmount);
                return (maxAmountIn - returnAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
            }
            // if slippage is postive and referral flag is true
            if (feeData & IS_REFERRAL_MASK != 0) {
                if (surplus > 0) {
                    // the split is 50% for paraswap, 25% for the referrer and 25% for the user
                    paraswapFeeShare = (surplus * PARASWAP_REFERRAL_SHARE) / 10_000;
                    partnerFeeShare = (surplus * PARTNER_REFERRAL_SHARE) / 10_000;
                    // distribute fees from srcToken
                    returnAmount = _distributeFees(
                        remainingAmount,
                        srcToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the rest to msg.sender
                    returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, returnAmount);
                    // transfer the received amount of destToken to the beneficiary
                    destToken.safeTransfer(beneficiary, --receivedAmount);
                    return (maxAmountIn - returnAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
            // if slippage is positive and takeSurplus flag is true
            else if (feeData & IS_TAKE_SURPLUS_MASK != 0) {
                if (surplus > 0) {
                    // paraswap takes 50% of the surplus and partner takes the other 50%
                    paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;
                    partnerFeeShare = surplus - paraswapFeeShare;
                    // If user surplus flag is true, transfer the partner share to the user instead of the partner
                    if (feeData & IS_USER_SURPLUS_MASK != 0) {
                        partnerFeeShare = 0;
                        // Transfer the paraswap share directly to the fee wallet
                        isDirectTransfer = true;
                    }
                    // distrubite fees from srcToken, partner takes 50% of the surplus
                    // and paraswap takes the other 50%
                    returnAmount = _distributeFees(
                        remainingAmount,
                        srcToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the rest to msg.sender
                    returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, returnAmount);
                    // transfer the received amount of destToken to the beneficiary
                    destToken.safeTransfer(beneficiary, --receivedAmount);
                    return (maxAmountIn - returnAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
        }

        // transfer the received amount of destToken to the beneficiary
        destToken.safeTransfer(beneficiary, --receivedAmount);

        // if slippage is positive and partner address is 0x0 or fee percent is 0
        // paraswap will take the surplus, and transfer the rest to msg.sender
        // if there is no positive slippage, transfer the remaining amount to msg.sender
        if (surplus > 0) {
            // If the token is blacklisted, send the remaining amount to the msg.sender
            // we won't process fees
            if (blacklistedTokens[srcToken]) {
                // transfer the remaining amount to msg.sender
                returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount);
                return (maxAmountIn - returnAmount, receivedAmount, 0, 0);
            }
            // transfer the surplus to the fee wallet
            srcToken.safeTransfer(feeWallet, surplus);
            // transfer the remaining amount to msg.sender
            returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount - surplus);
            return (maxAmountIn - returnAmount, receivedAmount, surplus, 0);
        } else {
            // transfer the remaining amount to msg.sender
            returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount);
            return (maxAmountIn - returnAmount, receivedAmount, 0, 0);
        }
    }

    /// @notice Process swapExactAmountOut fees for UniV3 swapExactAmountOut, doing a transferFrom user to the fee
    /// vault or partner and feeWallet
    /// @param beneficiary The user's address
    /// @param srcToken The token used to swapExactAmountOut
    /// @param destToken The token received from the swapExactAmountOut
    /// @param partnerAndFee Packed partner and fee data
    /// @param maxAmountIn The amount of srcToken passed to the swapExactAmountOut
    /// @param receivedAmount The amount of destToken received from the swapExactAmountOut
    /// @param spentAmount The amount of srcToken used to swapExactAmountOut
    /// @param quotedAmount The quoted expected amount of srcToken to be used to swapExactAmountOut
    /// @return totalSpentAmount The total amount of srcToken used to swapExactAmountOut
    /// @return returnAmount The amount of destToken transfered to the beneficiary
    /// @return paraswapFeeShare The share of the fees for Paraswap
    /// @return partnerFeeShare The share of the fees for the partner
    function processSwapExactAmountOutFeesAndTransferUniV3(
        address beneficiary,
        IERC20 srcToken,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 maxAmountIn,
        uint256 receivedAmount,
        uint256 spentAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 totalSpentAmount, uint256 returnAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // initialize the surplus
        uint256 surplus;

        // calculate remaining amount
        uint256 remainingAmount = maxAmountIn - spentAmount;

        // parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // check if the quotedAmount is bigger than the fromAmount
        if (quotedAmount > maxAmountIn) {
            revert InvalidQuotedAmount();
        }

        // calculate the surplus, we do not take the surplus into account if it is less than
        // MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (quotedAmount > spentAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = quotedAmount - spentAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // if partner address is not 0x0
        if (partner != address(0x0)) {
            // Check if skip blacklist flag is true
            bool skipBlacklist = feeData & IS_SKIP_BLACKLIST_MASK != 0;
            // Check if token is blacklisted
            bool isBlacklisted = blacklistedTokens[srcToken];
            // If the token is blacklisted and the skipBlacklist flag is false,
            // we won't process fees
            if (!skipBlacklist && isBlacklisted) {
                // transfer the received amount of destToken to the beneficiary
                destToken.safeTransfer(beneficiary, receivedAmount);
                return (spentAmount, receivedAmount, 0, 0);
            }
            // Check if direct transfer flag is true
            bool isDirectTransfer = feeData & IS_DIRECT_TRANSFER_MASK != 0;
            // partner takes fixed fees feePercent is greater than 0
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // fee base = min (spentAmount, quotedAmount)
                uint256 feeBase = spentAmount < quotedAmount ? spentAmount : quotedAmount;
                // calculate fixed fees
                uint256 fee = (feeBase * feePercent) / 10_000;
                partnerFeeShare = (fee * PARTNER_SHARE_PERCENT) / 10_000;
                paraswapFeeShare = fee - partnerFeeShare;
                // distrubite fees from srcToken
                totalSpentAmount = _distributeFeesUniV3(
                    remainingAmount,
                    msg.sender,
                    srcToken,
                    partner,
                    partnerFeeShare,
                    paraswapFeeShare,
                    skipBlacklist,
                    isBlacklisted,
                    isDirectTransfer
                ) + spentAmount;
                // transfer the received amount of destToken to the beneficiary
                destToken.safeTransfer(beneficiary, receivedAmount);
                return (totalSpentAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
            }
            // if slippage is postive and referral flag is true
            else if (feeData & IS_REFERRAL_MASK != 0) {
                if (surplus > 0) {
                    // the split is 50% for paraswap, 25% for the referrer and 25% for the user
                    paraswapFeeShare = (surplus * PARASWAP_REFERRAL_SHARE) / 10_000;
                    partnerFeeShare = (surplus * PARTNER_REFERRAL_SHARE) / 10_000;
                    // distribute fees from srcToken
                    totalSpentAmount = _distributeFeesUniV3(
                        remainingAmount,
                        msg.sender,
                        srcToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    ) + spentAmount;
                    // transfer the received amount of destToken to the beneficiary
                    destToken.safeTransfer(beneficiary, receivedAmount);
                    return (totalSpentAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
            // if slippage is positive and takeSurplus flag is true
            else if (feeData & IS_TAKE_SURPLUS_MASK != 0) {
                if (surplus > 0) {
                    // paraswap takes 50% of the surplus and partner takes the other 50%
                    paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;
                    partnerFeeShare = surplus - paraswapFeeShare;
                    // If user surplus flag is true, transfer the partner share to the user instead of the partner
                    if (feeData & IS_USER_SURPLUS_MASK != 0) {
                        partnerFeeShare = 0;
                        // Transfer the paraswap share directly to the fee wallet
                        isDirectTransfer = true;
                    }
                    //  partner takes 50% of the surplus and paraswap takes the other 50%
                    // distrubite fees from srcToken
                    totalSpentAmount = _distributeFeesUniV3(
                        remainingAmount,
                        msg.sender,
                        srcToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    ) + spentAmount;
                    // transfer the received amount of destToken to the beneficiary
                    destToken.safeTransfer(beneficiary, receivedAmount);
                    return (totalSpentAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
        }

        // transfer the received amount of destToken to the beneficiary
        destToken.safeTransfer(beneficiary, receivedAmount);

        // if slippage is positive and partner address is 0x0 or fee percent is 0
        // paraswap will take the surplus
        if (surplus > 0) {
            // If the token is blacklisted, we won't process fees
            if (blacklistedTokens[srcToken]) {
                return (spentAmount, receivedAmount, 0, 0);
            }
            // transfer the surplus to the fee wallet
            srcToken.safeTransferFrom(msg.sender, feeWallet, surplus);
        }
        return (spentAmount + surplus, receivedAmount, surplus, 0);
    }

    /*//////////////////////////////////////////////////////////////
                                 PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAugustusFees
    function parsePartnerAndFeeData(uint256 partnerAndFee)
        public
        pure
        returns (address payable partner, uint256 feeData)
    {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            partner := shr(96, partnerAndFee)
            feeData := and(partnerAndFee, 0xFFFFFFFFFFFFFFFFFFFFFFFF)
        }
    }

    /*//////////////////////////////////////////////////////////////
                                PRIVATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Distribute fees to the partner and paraswap
    /// @param currentBalance The current balance of the token before distributing the fees
    /// @param token The token to distribute the fees for
    /// @param partner The partner address
    /// @param partnerShare The partner share
    /// @param paraswapShare The paraswap share
    /// @param skipBlacklist Whether to skip the blacklist and transfer the fees directly to the partner
    /// @param isBlacklisted Whether the token is blacklisted
    /// @param directTransfer Whether to transfer the fees directly to the partner instead of the fee vault
    /// @return newBalance The new balance of the token after distributing the fees
    function _distributeFees(
        uint256 currentBalance,
        IERC20 token,
        address payable partner,
        uint256 partnerShare,
        uint256 paraswapShare,
        bool skipBlacklist,
        bool isBlacklisted,
        bool directTransfer
    )
        private
        returns (uint256 newBalance)
    {
        uint256 totalFees = partnerShare + paraswapShare;
        if (totalFees == 0) {
            return currentBalance;
        } else {
            if (skipBlacklist && isBlacklisted) {
                // totalFees should be just the partner share, paraswap does not take fees
                // on blacklisted tokens, the rest of the fees are sent to sender based on
                // newBalance = currentBalance - totalFees
                totalFees = partnerShare;
                // revert if the balance is not enough to pay the fees
                if (totalFees > currentBalance) {
                    revert InsufficientBalanceToPayFees();
                }
                if (partnerShare > 0) {
                    token.safeTransfer(partner, partnerShare);
                }
            } else {
                // revert if the balance is not enough to pay the fees
                if (totalFees > currentBalance) {
                    revert InsufficientBalanceToPayFees();
                }
                if (directTransfer) {
                    // transfer the fees directly to the partner and paraswap
                    if (paraswapShare > 0) {
                        token.safeTransfer(feeWallet, paraswapShare);
                    }
                    if (partnerShare > 0) {
                        token.safeTransfer(partner, partnerShare);
                    }
                } else {
                    // transfer the fees to the fee vault
                    token.safeTransfer(address(FEE_VAULT), totalFees);
                    // Setup fee registration data
                    address[] memory feeAddresses = new address[](2);
                    uint256[] memory feeAmounts = new uint256[](2);
                    feeAddresses[0] = partner;
                    feeAmounts[0] = partnerShare;
                    feeAddresses[1] = feeWalletDelegate;
                    feeAmounts[1] = paraswapShare;
                    IAugustusFeeVault.FeeRegistration memory feeData =
                        IAugustusFeeVault.FeeRegistration({ token: token, addresses: feeAddresses, fees: feeAmounts });
                    // Register the fees
                    FEE_VAULT.registerFees(feeData);
                }
            }
        }
        newBalance = currentBalance - totalFees;
    }

    /// @notice Distribute fees for UniV3
    /// @param currentBalance The current balance of the token before distributing the fees
    /// @param payer The user's address
    /// @param token The token to distribute the fees for
    /// @param partner The partner address
    /// @param partnerShare The partner share
    /// @param paraswapShare The paraswap share
    /// @param skipBlacklist Whether to skip the blacklist and transfer the fees directly to the partner
    /// @param isBlacklisted Whether the token is blacklisted
    /// @param directTransfer Whether to transfer the fees directly to the partner instead of the fee vault
    /// @return totalFees The total fees distributed
    function _distributeFeesUniV3(
        uint256 currentBalance,
        address payer,
        IERC20 token,
        address payable partner,
        uint256 partnerShare,
        uint256 paraswapShare,
        bool skipBlacklist,
        bool isBlacklisted,
        bool directTransfer
    )
        private
        returns (uint256 totalFees)
    {
        totalFees = partnerShare + paraswapShare;
        if (totalFees != 0) {
            if (skipBlacklist && isBlacklisted) {
                // totalFees should be just the partner share, paraswap does not take fees
                // on blacklisted tokens, the rest of the fees will remain on the payer's address
                totalFees = partnerShare;
                // revert if the balance is not enough to pay the fees
                if (totalFees > currentBalance) {
                    revert InsufficientBalanceToPayFees();
                }
                // transfer the fees to the partner
                if (partnerShare > 0) {
                    // transfer the fees to the partner
                    token.safeTransferFrom(payer, partner, partnerShare);
                }
            } else {
                // revert if the balance is not enough to pay the fees
                if (totalFees > currentBalance) {
                    revert InsufficientBalanceToPayFees();
                }
                if (directTransfer) {
                    // transfer the fees directly to the partner and paraswap
                    if (paraswapShare > 0) {
                        token.safeTransferFrom(payer, feeWallet, paraswapShare);
                    }
                    if (partnerShare > 0) {
                        token.safeTransferFrom(payer, partner, partnerShare);
                    }
                } else {
                    // transfer the fees to the fee vault
                    token.safeTransferFrom(payer, address(FEE_VAULT), totalFees);
                    // Setup fee registration data
                    address[] memory feeAddresses = new address[](2);
                    uint256[] memory feeAmounts = new uint256[](2);
                    feeAddresses[0] = partner;
                    feeAmounts[0] = partnerShare;
                    feeAddresses[1] = feeWalletDelegate;
                    feeAmounts[1] = paraswapShare;
                    IAugustusFeeVault.FeeRegistration memory feeData =
                        IAugustusFeeVault.FeeRegistration({ token: token, addresses: feeAddresses, fees: feeAmounts });
                    // Register the fees
                    FEE_VAULT.registerFees(feeData);
                }
            }
            // othwerwise do not transfer the fees
        }
        return totalFees;
    }

    /// @notice Get the adjusted fee percent by masking feePercent with FEE_PERCENT_IN_BASIS_POINTS_MASK,
    /// if the fee percent is bigger than MAX_FEE_PERCENT, then set it to MAX_FEE_PERCENT
    /// @param feePercent The fee percent
    /// @return adjustedFeePercent The adjusted fee percent
    function _getAdjustedFeePercent(uint256 feePercent) internal pure returns (uint256) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            feePercent := and(feePercent, FEE_PERCENT_IN_BASIS_POINTS_MASK)
            // if feePercent is bigger than MAX_FEE_PERCENT, then set it to MAX_FEE_PERCENT
            if gt(feePercent, MAX_FEE_PERCENT) { feePercent := MAX_FEE_PERCENT }
        }
        return feePercent;
    }

    /// @notice Transfers amount to recipient if the amount is bigger than 1, leaving 1 wei dust on the contract
    /// @param token The token to transfer
    /// @param recipient The address to transfer to
    /// @param amount The amount to transfer
    function _transferIfGreaterThanOne(
        IERC20 token,
        address recipient,
        uint256 amount
    )
        private
        returns (uint256 amountOut)
    {
        if (amount > 1) {
            unchecked {
                --amount;
            }
            token.safeTransfer(recipient, amount);
            return amount;
        }
        return 0;
    }

    /// @notice Transfer amount to beneficiary, leaving 1 wei dust on the contract
    /// @param token The token to transfer
    /// @param beneficiary The address to transfer to
    /// @param amount The amount to transfer
    function _transferAndLeaveDust(IERC20 token, address beneficiary, uint256 amount) internal {
        unchecked {
            --amount;
        }
        token.safeTransfer(beneficiary, amount);
    }

    /*//////////////////////////////////////////////////////////////
            PARTNER FIXED FEE & PROTOCOL SURPLUS SHARING
    //////////////////////////////////////////////////////////////*/

    /// @notice Process swapExactAmountIn with custom fee split: partner gets full fixed fee, protocol gets surplus
    /// @dev Fee Distribution Model (for swapExactAmountIn with PartnerFullFee):
    ///      1. Calculate surplus: receivedAmount - quotedAmount
    ///      2. Partner receives: feePercent * (quotedAmount + cappedSurplus) - partner gets their FULL fee %
    ///      3. Protocol receives: 50% of remaining surplus after partner takes fixed fee
    ///      4. User receives: Everything else (minus 1 wei dust left in contract)
    /// @dev Fees are taken from destToken. Always leaves 1 wei dust in contract for gas optimization.
    /// @param beneficiary The address that will receive the tokens after fees
    /// @param destToken The token received from the swap (destination token)
    /// @param partnerAndFee Packed data containing partner address and fee configuration
    /// @param receivedAmount The total amount of destToken received from the swap
    /// @param quotedAmount The quoted expected amount of destToken
    /// @return returnAmount The amount of destToken transferred to the beneficiary (minus 1 wei dust)
    /// @return paraswapFeeShare The protocol's share (50% of remaining surplus)
    /// @return partnerFeeShare The partner's share (100% of their fee percentage)
    function processSwapExactAmountInPro(
        address beneficiary,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 receivedAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 returnAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // Parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // Extract flags
        bool skipBlacklist = (feeData & IS_SKIP_BLACKLIST_MASK) != 0;
        bool isDirectTransfer = (feeData & IS_DIRECT_TRANSFER_MASK) != 0;
        bool isBlacklisted = blacklistedTokens[destToken];

        // Handle blacklisted tokens
        if (!skipBlacklist && isBlacklisted) {
            // No fees on blacklisted tokens - user gets everything (minus dust)
            _transferAndLeaveDust(destToken, beneficiary, receivedAmount);
            return (receivedAmount - 1, 0, 0);
        }

        // Calculate surplus first (protocol ALWAYS takes 50% of surplus if it exists)
        uint256 surplus;
        // calculate the surplus, we expect there to be 1 wei dust left which we should
        // not take into account when determining if there is surplus, we only take the
        // surplus if it is greater than MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (receivedAmount > quotedAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = receivedAmount - quotedAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // Protocol ALWAYS takes 50% of surplus first (if there is surplus)
        paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;

        // Partner takes fixed fee on the remaining amount (if partner exists with non-zero fee)
        if (partner != address(0)) {
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                partnerFeeShare = (receivedAmount - paraswapFeeShare) * feePercent / 10_000;
            }
        }

        // Distribute fees to partner and protocol (single call handles all cases)
        // Note: _distributeFees handles the blacklisted token case internally - if skipBlacklist && isBlacklisted,
        // it will only transfer partnerFeeShare and return receivedAmount - partnerFeeShare
        returnAmount = _distributeFees(
            receivedAmount,
            destToken,
            partner,
            partnerFeeShare,
            paraswapFeeShare,
            skipBlacklist,
            isBlacklisted,
            isDirectTransfer
        );

        // Transfer remaining amount to beneficiary, keeping 1 wei dust
        _transferAndLeaveDust(destToken, beneficiary, returnAmount);
        return (returnAmount - 1, paraswapFeeShare, partnerFeeShare);
    }

    /// @notice Process swapExactAmountOut with custom fee split: partner gets full fixed fee, protocol gets surplus
    /// @dev Fee Distribution Model (for swapExactAmountOut with PartnerFullFee):
    ///      1. Calculate surplus: quotedAmount - spentAmount (spending LESS is good)
    ///      2. Partner receives: feePercent * spentAmount (with surplus) or quotedAmount (no surplus)
    ///      3. Protocol receives: 50% of surplus (what we saved)
    ///      4. User receives: Everything else from remaining srcToken (minus 1 wei dust)
    /// @dev Fees are taken from srcToken (the remaining/unspent amount). Always leaves 1 wei dust.
    /// @param beneficiary The address that will receive the remaining srcToken and all destToken
    /// @param srcToken The token spent in the swap (source token) - fees taken from remaining amount
    /// @param destToken The token received from the swap (sent to beneficiary)
    /// @param partnerAndFee Packed data containing partner address and fee configuration
    /// @param maxAmountIn The maximum amount of srcToken user was willing to spend
    /// @param remainingAmount The remaining srcToken balance after swap (before fees)
    /// @param receivedAmount The amount of destToken received (sent to beneficiary)
    /// @param quotedAmount The quoted expected amount of srcToken to spend
    /// @return spentAmount The actual amount of srcToken spent
    /// @return outAmount The amount of destToken transferred to beneficiary
    /// @return paraswapFeeShare The protocol's share (50% of surplus saved)
    /// @return partnerFeeShare The partner's share (100% of their fee percentage)
    function processSwapExactAmountOutPro(
        address beneficiary,
        IERC20 srcToken,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 maxAmountIn,
        uint256 remainingAmount,
        uint256 receivedAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 spentAmount, uint256 outAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // calculate the amount used to swapExactAmountOut
        spentAmount = maxAmountIn - (remainingAmount > 0 ? remainingAmount - 1 : remainingAmount);

        // Parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // check if the quotedAmount is bigger than the maxAmountIn
        if (quotedAmount > maxAmountIn) {
            revert InvalidQuotedAmount();
        }

        // Extract flags
        bool skipBlacklist = (feeData & IS_SKIP_BLACKLIST_MASK) != 0;
        bool isDirectTransfer = (feeData & IS_DIRECT_TRANSFER_MASK) != 0;
        bool isBlacklisted = blacklistedTokens[srcToken];

        uint256 returnAmount;

        // Handle blacklisted tokens
        if (!skipBlacklist && isBlacklisted) {
            // transfer the remaining amount to msg.sender
            returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount);
            // transfer the received amount of destToken to the beneficiary
            destToken.safeTransfer(beneficiary, receivedAmount);
            return (maxAmountIn - returnAmount, receivedAmount, 0, 0);
        }

        // Calculate surplus (for swapOut: surplus = spending LESS than quoted)
        uint256 surplus;
        if (quotedAmount > spentAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = quotedAmount - spentAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // Protocol ALWAYS takes 50% of surplus first (if there is surplus)
        paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;

        // Partner fee calculation
        if (partner != address(0)) {
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // If there is surplus: partner fee is based on spentAmount
                // If no surplus: partner fee is based on quotedAmount
                uint256 feeBase = surplus > 0 ? spentAmount : quotedAmount;
                partnerFeeShare = (feeBase * feePercent) / 10_000;

                // Ensure partner fee doesn't exceed remaining amount after protocol fee
                uint256 maxPartnerFee = remainingAmount - paraswapFeeShare;
                if (partnerFeeShare > maxPartnerFee) {
                    partnerFeeShare = maxPartnerFee;
                }
            }
        }

        // Distribute fees from the remaining srcToken
        returnAmount = _distributeFees(
            remainingAmount,
            srcToken,
            partner,
            partnerFeeShare,
            paraswapFeeShare,
            skipBlacklist,
            isBlacklisted,
            isDirectTransfer
        );

        // transfer the rest to msg.sender (keeping 1 wei dust in contract)
        returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, returnAmount);
        // transfer the received amount of destToken to the beneficiary
        destToken.safeTransfer(beneficiary, receivedAmount);

        return (maxAmountIn - returnAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
    }
}

// File: src/util/Permit2Utils.sol

pragma solidity 0.8.22;

/// @title Permit2Utils
/// @notice A contract containing common utilities for Permit2
abstract contract Permit2Utils {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error Permit2Failed();

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Permit2 address
    address public immutable PERMIT2; // solhint-disable-line var-name-mixedcase

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _permit2) {
        PERMIT2 = _permit2;
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Parses data and executes permit2.permitTransferFrom, reverts if it fails
    function permit2TransferFrom(bytes calldata data, address recipient, uint256 amount) internal {
        address targetAddress = PERMIT2;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Get free memory pointer
            let ptr := mload(64)
            // Store function selector
            mstore(ptr, 0x30f28b7a00000000000000000000000000000000000000000000000000000000) // permitTransferFrom()
            // Copy data to memory
            calldatacopy(add(ptr, 4), data.offset, data.length)
            // Store recipient
            mstore(add(ptr, 132), recipient)
            // Store amount
            mstore(add(ptr, 164), amount)
            // Store owner
            mstore(add(ptr, 196), caller())
            // Call permit2.permitTransferFrom and revert if call failed
            if iszero(call(gas(), targetAddress, 0, ptr, add(data.length, 4), 0, 0)) {
                mstore(0, 0x6b836e6b00000000000000000000000000000000000000000000000000000000) // Store error selector
                    // error Permit2Failed()
                revert(0, 4)
            }
        }
    }
}

// File: src/util/PauseUtils.sol

pragma solidity 0.8.22;

// Storage


/// @title PauseUtils
/// @notice Provides a modifier to check if the contract is paused
abstract contract PauseUtils is AugustusStorage {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error emitted when the contract is paused
    error ContractPaused();

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    // Check if the contract is paused, if it is, revert
    modifier whenNotPaused() {
        if (paused) {
            revert ContractPaused();
        }
        _;
    }
}

// File: src/util/GenericUtils.sol

pragma solidity 0.8.22;

// Contracts


// Utils



/// @title GenericUtils
/// @notice A contract containing common utilities for Generic swaps
abstract contract GenericUtils is AugustusFees, Permit2Utils, PauseUtils {
    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Call executor with executorData and amountIn
    function _callSwapExactAmountInExecutor(
        address executor,
        bytes calldata executorData,
        uint256 amountIn
    )
        internal
    {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // get the length of the executorData
            // + 4 bytes for the selector
            // + 32 bytes for fromAmount
            // + 32 bytes for sender
            let totalLength := add(executorData.length, 68)
            calldatacopy(add(0x7c, 4), executorData.offset, executorData.length) // store the executorData
            mstore(add(0x7c, add(4, executorData.length)), amountIn) // store the amountIn
            mstore(add(0x7c, add(36, executorData.length)), caller()) // store the sender
            // call executor and forward call value
            if iszero(call(gas(), executor, callvalue(), 0x7c, totalLength, 0, 0)) {
                returndatacopy(0x7c, 0, returndatasize()) // copy the revert data to memory
                revert(0x7c, returndatasize()) // revert with the revert data
            }
        }
    }

    /// @dev Call executor with executorData, maxAmountIn, amountOut
    function _callSwapExactAmountOutExecutor(
        address executor,
        bytes calldata executorData,
        uint256 maxAmountIn,
        uint256 amountOut
    )
        internal
    {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // get the length of the executorData
            // + 4 bytes for the selector
            // + 32 bytes for fromAmount
            // + 32 bytes for toAmount
            // + 32 bytes for sender
            let totalLength := add(executorData.length, 100)
            calldatacopy(add(0x7c, 4), executorData.offset, executorData.length) // store the executorData
            mstore(add(0x7c, add(4, executorData.length)), maxAmountIn) // store the maxAmountIn
            mstore(add(0x7c, add(36, executorData.length)), amountOut) // store the amountOut
            mstore(add(0x7c, add(68, executorData.length)), caller()) // store the sender
            // call executor and forward call value
            if iszero(call(gas(), executor, callvalue(), 0x7c, totalLength, 0, 0)) {
                returndatacopy(0x7c, 0, returndatasize()) // copy the revert data to memory
                revert(0x7c, returndatasize()) // revert with the revert data
            }
        }
    }
}

// File: src/facets/ProPartnerFacet.sol

pragma solidity 0.8.22;

// Interfaces



// Libraries


// Contracts




// Types


/// @title ProPartnerFacet
/// @notice Facet for swaps with custom fee model: partner gets 100% of fixed fees, protocol gets 50% of surplus
/// @dev Fee Distribution:
///      1. Partner receives: 100% of fixed fee (calculated on quotedAmount + surplus)
///      2. Protocol receives: 50% of remaining surplus (after fixed fee is taken)
///      3. User receives: Everything else
contract ProPartnerFacet is IProPartnerFacet, GenericUtils {
    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Initialize the facet with immutable variables
    /// @param _feeVault Address of the AugustusFeeVault contract
    /// @param _permit2 Address of the Permit2 contract
    constructor(address _feeVault, address _permit2) AugustusFees(_feeVault) Permit2Utils(_permit2) { }

    /*//////////////////////////////////////////////////////////////
                            SWAP FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IProPartnerFacet
    function swapExactAmountInPro(
        address executor,
        GenericData calldata swapData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata executorData
    )
        external
        payable
        whenNotPaused
        returns (uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare)
    {
        // Dereference swapData
        IERC20 destToken = swapData.destToken;
        IERC20 srcToken = swapData.srcToken;
        uint256 amountIn = swapData.fromAmount;
        uint256 minAmountOut = swapData.toAmount;
        uint256 quotedAmountOut = swapData.quotedAmount;
        address payable beneficiary = swapData.beneficiary;

        // Check if beneficiary is valid
        if (beneficiary == address(0)) {
            beneficiary = payable(msg.sender);
        }

        // Check if toAmount is valid
        if (minAmountOut == 0) {
            revert InvalidToAmount();
        }

        // Check if srcToken is ETH
        if (srcToken.isETH(amountIn) == 0) {
            // Check the length of the permit field,
            // if < 257 and > 0 we should execute regular permit
            // and if it is >= 257 we execute permit2
            if (permit.length < 257) {
                // Permit if needed
                if (permit.length > 0) {
                    srcToken.permit(permit);
                }
                srcToken.safeTransferFrom(msg.sender, executor, amountIn);
            } else {
                // Otherwise Permit2.permitTransferFrom
                permit2TransferFrom(permit, executor, amountIn);
            }
        }

        // Execute swap
        _callSwapExactAmountInExecutor(executor, executorData, amountIn);

        // Check balance after swap
        receivedAmount = destToken.getBalance(address(this));

        // Check if swap succeeded
        if (receivedAmount < minAmountOut) {
            revert InsufficientReturnAmount();
        }

        // Use custom fee processing: partner gets full fixed fee, protocol gets surplus
        return processSwapExactAmountInPro(beneficiary, destToken, partnerAndFee, receivedAmount, quotedAmountOut);
    }

    /// @inheritdoc IProPartnerFacet
    function swapExactAmountOutPro(
        address executor,
        GenericData calldata swapData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata executorData
    )
        external
        payable
        whenNotPaused
        returns (uint256 spentAmount, uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare)
    {
        // Dereference swapData
        IERC20 destToken = swapData.destToken;
        IERC20 srcToken = swapData.srcToken;
        uint256 maxAmountIn = swapData.fromAmount;
        uint256 amountOut = swapData.toAmount;
        uint256 quotedAmountIn = swapData.quotedAmount;
        address payable beneficiary = swapData.beneficiary;

        // Make sure srcToken and destToken are different
        if (srcToken == destToken) {
            revert ArbitrageNotSupported();
        }

        // Check if beneficiary is valid
        if (beneficiary == address(0)) {
            beneficiary = payable(msg.sender);
        }

        // Check if toAmount is valid
        if (amountOut == 0) {
            revert InvalidToAmount();
        }

        // Check contract balances
        uint256 srcTokenBalanceBefore = srcToken.getBalance(address(this));
        uint256 destTokenBalanceBefore = destToken.getBalance(address(this));

        // Check if srcToken is ETH
        // Transfer srcToken to executor if not ETH
        if (srcToken.isETH(maxAmountIn) == 0) {
            // Check the length of the permit field,
            // if < 257 and > 0 we should execute regular permit
            // and if it is >= 257 we execute permit2
            if (permit.length < 257) {
                // Permit if needed
                if (permit.length > 0) {
                    srcToken.permit(permit);
                }
                srcToken.safeTransferFrom(msg.sender, executor, maxAmountIn);
            } else {
                // Otherwise Permit2.permitTransferFrom
                permit2TransferFrom(permit, executor, maxAmountIn);
            }
        } else {
            // If srcToken is ETH, we have to deduct msg.value from srcTokenBalanceBefore
            srcTokenBalanceBefore = srcTokenBalanceBefore - msg.value;
        }

        // Execute swap
        _callSwapExactAmountOutExecutor(executor, executorData, maxAmountIn, amountOut);

        // Check balance of destToken (subtract balance before to preserve dust from previous transactions)
        receivedAmount = destToken.getBalance(address(this)) - destTokenBalanceBefore;

        // Check balance of srcToken, deducting the balance before the swap if it is greater than 1
        uint256 remainingAmount =
            srcToken.getBalance(address(this)) - (srcTokenBalanceBefore > 1 ? srcTokenBalanceBefore : 0);

        // Check if swap succeeded
        if (receivedAmount < amountOut) {
            revert InsufficientReturnAmount();
        }

        // Process fees and transfer destToken and srcToken to beneficiary
        return processSwapExactAmountOutPro(
            beneficiary,
            srcToken,
            destToken,
            partnerAndFee,
            maxAmountIn,
            remainingAmount,
            receivedAmount,
            quotedAmountIn
        );
    }
}
