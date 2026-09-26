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

// File: src/interfaces/IMakerPSMRouter.sol

pragma solidity 0.8.22;

// Interfaces


// Types


/// @title IMakerPSMRouter
/// @notice Interface for direct swaps on MakerPSM
interface IMakerPSMRouter is IErrors {
    /*//////////////////////////////////////////////////////////////
                          SWAP EXACT AMOUNT IN
    //////////////////////////////////////////////////////////////*/

    /// @notice Executes a swapExactAmountIn or swapExactAmountOut on Maker PSM
    /// @param makerPSMData Struct containing data for the swap
    /// @param permit Permit data for the swap
    /// @return spentAmount The amount of tokens spent
    /// @return receivedAmount The amount of tokens received
    function swapExactAmountInOutOnMakerPSM(
        MakerPSMData calldata makerPSMData,
        bytes calldata permit
    )
        external
        returns (uint256 spentAmount, uint256 receivedAmount);
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

// File: src/interfaces/IMakerPSM.sol

pragma solidity 0.8.22;

interface IMakerPSM {
    function sellGem(address usr, uint256 gemAmt) external;
    function buyGem(address usr, uint256 gemAmt) external;
}

// File: src/util/MakerPSMUtils.sol

pragma solidity 0.8.22;

// Interfaces


/// @title MakerPSMUtils
abstract contract MakerPSMUtils {
    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev DAI Address
    address public immutable DAI_MAKER; // solhint-disable-line var-name-mixedcase
    /// @dev WAD amount
    uint256 private constant WAD = 10 ** 18;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _daiMaker) {
        DAI_MAKER = _daiMaker;
    }
    /*//////////////////////////////////////////////////////////////
                                 INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Execute a swapExactAmountIn on Maker PSM transfering the recieved tokens to the beneficiary
    function _executeSwapExactAmountInOnMakerPSM(
        address exchange,
        uint256 swapType,
        uint256 toll,
        uint256 to18ConversionFactor,
        uint256 fromAmount,
        address beneficiary
    )
        internal
        returns (uint256 spentAmount, uint256 receivedAmount)
    {
        // If swapType is 0, then we are calling buyGem
        if (swapType == 0) {
            // Calculate the amount to buy
            uint256 gemAmt = (fromAmount * WAD) / ((WAD + toll) * to18ConversionFactor);
            // Call buyGem on exchange
            IMakerPSM(exchange).buyGem(beneficiary, gemAmt);
            return (fromAmount, gemAmt);
        }
        // If swapType is 1, then we are calling sellGem
        else {
            // Call sellGem on exchange
            IMakerPSM(exchange).sellGem(beneficiary, fromAmount);
            // Calculate the amount received
            uint256 gemAmt = fromAmount * to18ConversionFactor;
            uint256 fee = (gemAmt * toll) / WAD;
            receivedAmount = gemAmt - fee;
            return (fromAmount, receivedAmount);
        }
    }

    /// @dev Execute a swapExactAmountOut on Maker PSM transfering the recieved tokens to the beneficiary
    function _executeSwapExactAmountOutOnMakerPSM(
        address exchange,
        uint256 swapType,
        uint256 toll,
        uint256 to18ConversionFactor,
        uint256 toAmount,
        address beneficiary
    )
        internal
    {
        // If swapType is 0, then we are calling buyGem
        if (swapType == 0) {
            IMakerPSM(exchange).buyGem(beneficiary, toAmount);
        }
        // If swapType is 1, then we are calling sellGem
        else {
            // Calculate the amount to sell
            uint256 a = toAmount * WAD;
            uint256 b = (WAD - toll) * to18ConversionFactor;
            uint256 gemAmt = (a + b - 1) / b;
            // Call sellGem
            IMakerPSM(exchange).sellGem(beneficiary, gemAmt);
        }
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

// File: src/facets/MakerPSMRouterFacet.sol

pragma solidity 0.8.22;

// Interfaces



// Libraries


// Types


// Contracts



/// @title MakerPSMRouter
/// @notice A facet for executing direct MakerPSM swaps
contract MakerPSMRouterFacet is IMakerPSMRouter, MakerPSMUtils, Permit2Utils {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _daiMaker, address _permit2) MakerPSMUtils(_daiMaker) Permit2Utils(_permit2) { }

    /*//////////////////////////////////////////////////////////////
                        SWAP EXACT AMOUNT IN/OUT
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IMakerPSMRouter
    function swapExactAmountInOutOnMakerPSM(
        MakerPSMData calldata makerPSMData,
        bytes calldata permit
    )
        external
        returns (uint256 spentAmount, uint256 receivedAmount)
    {
        // Dereference makerPSMData
        IERC20 srcToken = makerPSMData.srcToken;
        uint256 toll = makerPSMData.toll;
        uint256 to18ConversionFactor = makerPSMData.to18ConversionFactor;
        address gemJoinAddress = makerPSMData.gemJoinAddress;
        address exchange = makerPSMData.exchange;
        uint256 fromAmount = makerPSMData.fromAmount;
        uint256 toAmount = makerPSMData.toAmount;
        uint256 beneficiaryDirectionApproveFlag = makerPSMData.beneficiaryDirectionApproveFlag;

        // Decode params
        address beneficiary;
        bool approve;
        bool direction;

        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            // Parse beneficiaryDirectionApproveFlag
            beneficiary := and(beneficiaryDirectionApproveFlag, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            approve := shr(255, beneficiaryDirectionApproveFlag)
            direction := and(1, shr(254, beneficiaryDirectionApproveFlag))
        }

        // Get swap type
        uint256 swapType;
        address dai = DAI_MAKER;

        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            swapType := 0x1 // sellGem(address,uint256)
            if eq(srcToken, dai) { swapType := 0x0 } // buyGem(address,uint256)
        }

        // Check if beneficiary is valid
        if (beneficiary == address(0)) {
            beneficiary = msg.sender;
        }

        // Check if toAmount is valid
        if (toAmount == 0) {
            revert InvalidToAmount();
        }

        // Check the length of the permit field,
        // if < 257 and > 0 we should execute regular permit
        // and if it is >= 257 we execute permit2
        if (permit.length < 257) {
            // Permit if needed
            if (permit.length > 0) {
                srcToken.permit(permit);
            }
            srcToken.safeTransferFrom(msg.sender, address(this), fromAmount);
        } else {
            // Otherwise Permit2.permitTransferFrom
            permit2TransferFrom(permit, address(this), fromAmount);
        }
        // Check if approve is needed
        if (approve) {
            if (address(srcToken) == DAI_MAKER) {
                // Approve exchange
                srcToken.approve(exchange);
            } else {
                // Approve gemJoinAddress
                srcToken.approve(gemJoinAddress);
            }
        }

        // Execute swapExactAmountIn or swapExactAmountOut based on direction
        if (!direction) {
            // Execute swapExactAmountIn on Maker PSM
            return _executeSwapExactAmountInOnMakerPSM(
                exchange, swapType, toll, to18ConversionFactor, fromAmount, beneficiary
            );
        } else {
            // Execute swapExactAmountOut on Maker PSM
            _executeSwapExactAmountOutOnMakerPSM(exchange, swapType, toll, to18ConversionFactor, toAmount, beneficiary);
            // Check remaining balance of srcToken
            uint256 remainingAmount = srcToken.balanceOf(address(this));
            // Transfer remaining balance to msg.sender
            if (remainingAmount > 1) {
                srcToken.safeTransfer(msg.sender, --remainingAmount);
            }
            // Return spentAmount and receivedAmount
            return (fromAmount - remainingAmount, toAmount);
        }
    }
}
