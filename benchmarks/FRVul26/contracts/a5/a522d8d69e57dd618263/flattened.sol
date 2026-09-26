// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

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

// File: @openzeppelin/contracts/interfaces/IERC721.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

// File: contracts/libraries/errorTypes.sol

pragma solidity 0.8.21;

library LibsErrorTypes {
    /***********************************|
    |         LiquidityCalcs            | 
    |__________________________________*/

    /// @notice thrown when supply or borrow exchange price is zero at calc token data (token not configured yet)
    uint256 internal constant LiquidityCalcs__ExchangePriceZero = 70001;

    /// @notice thrown when rate data is set to a version that is not implemented
    uint256 internal constant LiquidityCalcs__UnsupportedRateVersion = 70002;

    /// @notice thrown when the calculated borrow rate turns negative. This should never happen.
    uint256 internal constant LiquidityCalcs__BorrowRateNegative = 70003;

    /***********************************|
    |           SafeTransfer            | 
    |__________________________________*/

    /// @notice thrown when safe transfer from for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFromFailed = 71001;

    /// @notice thrown when safe transfer for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFailed = 71002;
}

// File: contracts/libraries/safeTransfer.sol

pragma solidity 0.8.21;



/// @notice provides minimalistic methods for safe transfers, e.g. ERC20 safeTransferFrom
library SafeTransfer {
    uint256 internal constant MAX_NATIVE_TRANSFER_GAS = 20000; // pass max. 20k gas for native transfers

    error FluidSafeTransferError(uint256 errorId_);

    /// @dev Transfer `amount_` of `token_` from `from_` to `to_`, spending the approval given by `from_` to the
    /// calling contract. If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L31-L63
    function safeTransferFrom(address token_, address from_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from_" argument.
            mstore(add(freeMemoryPointer, 36), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 68), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFromFailed);
        }
    }

    /// @dev Transfer `amount_` of `token_` to `to_`.
    /// If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L65-L95
    function safeTransfer(address token_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 36), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }

    /// @dev Transfer `amount_` of ` native token to `to_`.
    /// Minimally modified from Solmate SafeTransferLib (Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L15-L25
    function safeTransferNative(address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not. Pass limited gas
            success_ := call(MAX_NATIVE_TRANSFER_GAS, to_, amount_, 0, 0, 0, 0)
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }
}

// File: @openzeppelin/contracts/proxy/Clones.sol

// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol

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

// File: @openzeppelin/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;



/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
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
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: contracts/protocols/vault/interfaces/iVaultFactory.sol

pragma solidity 0.8.21;



interface IFluidVaultFactory is IERC721Enumerable {
    /// @notice Minting an NFT Vault for the user
    function mint(uint256 vaultId_, address user_) external returns (uint256 tokenId_);

    /// @notice returns owner of Vault which is also an NFT
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /// @notice Global auth is auth for all vaults
    function isGlobalAuth(address auth_) external view returns (bool);

    /// @notice Vault auth is auth for a specific vault
    function isVaultAuth(address vault_, address auth_) external view returns (bool);

    /// @notice Total vaults deployed.
    function totalVaults() external view returns (uint256);

    /// @notice Compute vaultAddress
    function getVaultAddress(uint256 vaultId) external view returns (address);

    /// @notice read uint256 `result_` for a storage `slot_` key
    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);
}

// File: contracts/protocols/vault/interfaces/iVaultT1.sol

pragma solidity 0.8.21;

interface IFluidVaultT1 {
    /// @notice returns the vault id
    function VAULT_ID() external view returns (uint256);

    /// @notice reads uint256 data `result_` from storage at a bytes32 storage `slot_` key.
    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);

    struct ConstantViews {
        address liquidity;
        address factory;
        address adminImplementation;
        address secondaryImplementation;
        address supplyToken;
        address borrowToken;
        uint8 supplyDecimals;
        uint8 borrowDecimals;
        uint vaultId;
        bytes32 liquiditySupplyExchangePriceSlot;
        bytes32 liquidityBorrowExchangePriceSlot;
        bytes32 liquidityUserSupplySlot;
        bytes32 liquidityUserBorrowSlot;
    }

    /// @notice returns all Vault constants
    function constantsView() external view returns (ConstantViews memory constantsView_);

    /// @notice fetches the latest user position after a liquidation
    function fetchLatestPosition(
        int256 positionTick_,
        uint256 positionTickId_,
        uint256 positionRawDebt_,
        uint256 tickData_
    )
        external
        view
        returns (
            int256, // tick
            uint256, // raw debt
            uint256, // raw collateral
            uint256, // branchID_
            uint256 // branchData_
        );

    /// @notice calculates the updated vault exchange prices
    function updateExchangePrices(
        uint256 vaultVariables2_
    )
        external
        view
        returns (
            uint256 liqSupplyExPrice_,
            uint256 liqBorrowExPrice_,
            uint256 vaultSupplyExPrice_,
            uint256 vaultBorrowExPrice_
        );

    /// @notice calculates the updated vault exchange prices and writes them to storage
    function updateExchangePricesOnStorage()
        external
        returns (
            uint256 liqSupplyExPrice_,
            uint256 liqBorrowExPrice_,
            uint256 vaultSupplyExPrice_,
            uint256 vaultBorrowExPrice_
        );

    /// @notice returns the liquidity contract address
    function LIQUIDITY() external view returns (address);

    function operate(
        uint256 nftId_, // if 0 then new position
        int256 newCol_, // if negative then withdraw
        int256 newDebt_, // if negative then payback
        address to_ // address at which the borrow & withdraw amount should go to. If address(0) then it'll go to msg.sender
    )
        external
        payable
        returns (
            uint256, // nftId_
            int256, // final supply amount. if - then withdraw
            int256 // final borrow amount. if - then payback
        );

    function liquidate(
        uint256 debtAmt_,
        uint256 colPerUnitDebt_, // min collateral needed per unit of debt in 1e18
        address to_,
        bool absorb_
    ) external payable returns (uint actualDebtAmt_, uint actualColAmt_);

    function absorb() external;

    function rebalance() external payable returns (int supplyAmt_, int borrowAmt_);

    error FluidLiquidateResult(uint256 colLiquidated, uint256 debtLiquidated);
}

// File: contracts/protocols/vault/interfaces/iVault.sol

pragma solidity 0.8.21;

/// @notice common Fluid vaults interface, some methods only available for vaults > T1 (type, simulateLiquidate, rebalance is different)
interface IFluidVault {
    /// @notice returns the vault id
    function VAULT_ID() external view returns (uint256);

    /// @notice returns the vault id
    function TYPE() external view returns (uint256);

    /// @notice reads uint256 data `result_` from storage at a bytes32 storage `slot_` key.
    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);

    struct Tokens {
        address token0;
        address token1;
    }

    struct ConstantViews {
        address liquidity;
        address factory;
        address operateImplementation;
        address adminImplementation;
        address secondaryImplementation;
        address deployer; // address which deploys oracle
        address supply; // either liquidity layer or DEX protocol
        address borrow; // either liquidity layer or DEX protocol
        Tokens supplyToken; // if smart collateral then address of token0 & token1 else just supply token address at token0 and token1 as empty
        Tokens borrowToken; // if smart debt then address of token0 & token1 else just borrow token address at token0 and token1 as empty
        uint256 vaultId;
        uint256 vaultType;
        bytes32 supplyExchangePriceSlot; // if smart collateral then slot is from DEX protocol else from liquidity layer
        bytes32 borrowExchangePriceSlot; // if smart debt then slot is from DEX protocol else from liquidity layer
        bytes32 userSupplySlot; // if smart collateral then slot is from DEX protocol else from liquidity layer
        bytes32 userBorrowSlot; // if smart debt then slot is from DEX protocol else from liquidity layer
    }

    /// @notice returns all Vault constants
    function constantsView() external view returns (ConstantViews memory constantsView_);

    /// @notice fetches the latest user position after a liquidation
    function fetchLatestPosition(
        int256 positionTick_,
        uint256 positionTickId_,
        uint256 positionRawDebt_,
        uint256 tickData_
    )
        external
        view
        returns (
            int256, // tick
            uint256, // raw debt
            uint256, // raw collateral
            uint256, // branchID_
            uint256 // branchData_
        );

    /// @notice calculates the updated vault exchange prices
    function updateExchangePrices(
        uint256 vaultVariables2_
    )
        external
        view
        returns (
            uint256 liqSupplyExPrice_,
            uint256 liqBorrowExPrice_,
            uint256 vaultSupplyExPrice_,
            uint256 vaultBorrowExPrice_
        );

    /// @notice calculates the updated vault exchange prices and writes them to storage
    function updateExchangePricesOnStorage()
        external
        returns (
            uint256 liqSupplyExPrice_,
            uint256 liqBorrowExPrice_,
            uint256 vaultSupplyExPrice_,
            uint256 vaultBorrowExPrice_
        );

    /// @notice returns the liquidity contract address
    function LIQUIDITY() external view returns (address);

    error FluidLiquidateResult(uint256 colLiquidated, uint256 debtLiquidated);

    function rebalance(
        int colToken0MinMax_,
        int colToken1MinMax_,
        int debtToken0MinMax_,
        int debtToken1MinMax_
    ) external returns (int supplyAmt_, int borrowAmt_);

    /// @notice reverts with FluidLiquidateResult
    function simulateLiquidate(uint debtAmt_, bool absorb_) external;
}

// File: contracts/periphery/wallet/wallet/main.sol

pragma solidity 0.8.21;














interface IFluidWalletFactory {
    function WALLET_PROXY() external view returns(address);
}

interface InstaFlashReceiverInterface {
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata _data
    ) external returns (bool);
}

abstract contract FluidWalletVariables {
    /***********************************|
    |   Constants/Immutables            |
    |__________________________________*/
    string public constant VERSION = "1.1.0";
    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 internal constant X32 = 0xffffffff;

    address public immutable VAULT_FACTORY;
    address public immutable FLUID_WALLET_FACTORY;

    /***********************************|
    |           Slot 0                  |
    |__________________________________*/
    /// @dev owner address of this wallet. It is initialized while deploying the wallet for the user.
    address public owner;

    /***********************************|
    |           Slot 1                  |
    |__________________________________*/
    /// @dev transient allow hash used to signal allowing certain entry into methods such as executeOperation etc.
    bytes32 internal _transientAllowHash;
    
    function _resetTransientStorage() internal {
        assembly {
            sstore(1, 1) // Store 1 in the transient storage 1
        }
    }
}

contract FluidWalletErrorsAndEvents {
    error FluidWallet__NotAllowed();
    error FluidWallet__ToHexDigit();
    error FluidWallet__Unauthorized();

    event Executed(
        address indexed owner,
        uint256 indexed tokenId
    );

    event ExecutedCast(address indexed owner);

    struct Action {
        address target;
        bytes data;
        uint256 value;
        uint8 operation;
    }
}

contract FluidWalletImplementation is FluidWalletVariables, FluidWalletErrorsAndEvents {
    
    constructor(
        address vaultFactory_,
        address fluidWalletFactory_
    ) {
        VAULT_FACTORY = vaultFactory_;
        FLUID_WALLET_FACTORY = fluidWalletFactory_;
    }

    /// @dev                    ERC721 callback used Fluid Vault Factory and executes actions encoded in `data_`
    ///                         Caller should be Fluid Wallet Factory.
    /// @param operator_        operator_ caller to transfer the the given token ID
    /// @param from_            from_ previous owner of the given token ID
    /// @param tokenId_         tokenId_ id of the ERC721
    /// @param data_            data bytes containing the `abi.encoded()` actions that are executed like in `Action[]` & `owner`
    function onERC721Received(
        address operator_,
        address from_,
        uint256 tokenId_,
        bytes calldata data_
    ) external returns (bytes4) {
        if (msg.sender != address(VAULT_FACTORY)) revert FluidWallet__NotAllowed();
        if (operator_ != from_) revert FluidWallet__NotAllowed();
        if (operator_ != FLUID_WALLET_FACTORY) revert FluidWallet__NotAllowed();

        (address owner_, Action[] memory actions_) = abi.decode(data_, (address, Action[]));

        /// @dev validate owner by computing wallet address.
        _validateOwner(owner_);

        /// @dev execute actions.
        _executeActions(actions_);

        /// @dev reset _transientAllowHash to prevent reentrancy
        _resetTransientStorage();

        // Transfer tokenId back to main owner
        if (IERC721(VAULT_FACTORY).ownerOf(tokenId_) == address(this)) {
            IERC721(VAULT_FACTORY).transferFrom(address(this), owner_, tokenId_);
        }

        // sweep vault specific tokens to owner address
        _sweepTokens(owner_, tokenId_);

        emit Executed(owner_, tokenId_);

        return this.onERC721Received.selector;
    }

    function cast(
        Action[] memory actions_
    ) public {
        /// @dev validate owner by computing wallet address.
        _validateOwner(msg.sender);

        /// @dev execute actions.
        _executeActions(actions_);

        /// @dev reset _transientAllowHash to prevent reentrancy
        _resetTransientStorage();

        emit ExecutedCast(msg.sender);
    }
    

    /***********************************|
    |         FLASHLOAN CALLBACK        |
    |__________________________________*/

    /// @dev                    callback used by Instadapp Flashloan Aggregator, executes operations while owning
    ///                         the flashloaned amounts. `data_` must contain actions, one of them must pay back flashloan
    // /// @param assets_       assets_ received a flashloan for
    // /// @param amounts_      flashloaned amounts for each asset
    // /// @param premiums_     fees to pay for the flashloan
    /// @param initiator_       flashloan initiator -> must be this contract
    /// @param data_            data bytes containing the `abi.encoded()` actions that are executed like in `CastParams.actions`

    function executeOperation(
        address[] calldata /* assets */,
        uint256[] calldata /* amounts */,
        uint256[] calldata /* premiums */,
        address initiator_,
        bytes calldata data_
    ) external returns (bool) {
        if (
            !(_transientAllowHash ==
                bytes32(keccak256(abi.encode(data_, block.timestamp))) &&
                initiator_ == address(this))
        ) {
            revert FluidWallet__Unauthorized();
        }

        _executeActions(abi.decode(data_, (Action[])));

        return true;
    }

    /***********************************|
    |         INTERNAL HELPERS          |
    |__________________________________*/

    /// @notice Calculating the slot ID for Liquidity contract for single mapping
    function _calculateStorageSlotUintMapping(uint256 slot_, uint key_) internal pure returns (bytes32) {
        return keccak256(abi.encode(key_, slot_));
    }

    struct VaultConstants {
        address supplyToken0;
        address supplyToken1;
        address borrowToken0;
        address borrowToken1;
    }

    function _sweepTokens(address owner_, uint256 tokenId_) internal {
        uint256 tokenConfig_ = IFluidVaultFactory(VAULT_FACTORY).readFromStorage(_calculateStorageSlotUintMapping(3, tokenId_));
        address vaultAddress_ = IFluidVaultFactory(VAULT_FACTORY).getVaultAddress((tokenConfig_ >> 192) & X32);

        VaultConstants memory constants_ = _getVaultConstants(vaultAddress_);

        _flushTokens(constants_.supplyToken0, owner_);
        _flushTokens(constants_.supplyToken1, owner_);
        _flushTokens(constants_.borrowToken0, owner_);
        _flushTokens(constants_.borrowToken1, owner_);
    }

    function _getVaultConstants(address vault_) internal view returns (VaultConstants memory constants_) {
        if (vault_.code.length == 0) {
            return constants_;
        }
        try IFluidVault(vault_).TYPE() returns (uint256 type_) {
            IFluidVault.ConstantViews memory vaultConstants_ = IFluidVault(vault_).constantsView();

            constants_.supplyToken0 = vaultConstants_.supplyToken.token0;
            constants_.supplyToken1 = vaultConstants_.supplyToken.token1;
            constants_.borrowToken0 = vaultConstants_.borrowToken.token0;
            constants_.borrowToken1 = vaultConstants_.borrowToken.token1;
        } catch {
            IFluidVaultT1.ConstantViews memory vaultConstants_ = IFluidVaultT1(vault_).constantsView();
            
            constants_.supplyToken0 = vaultConstants_.supplyToken;
            constants_.supplyToken1 = address(0);
            constants_.borrowToken0 = vaultConstants_.borrowToken;
            constants_.borrowToken1 = address(0);
        }
    }

    function _flushTokens(address token_, address owner_) internal {
        if (token_ == address(0)) return;

        if (token_ == ETH_ADDRESS) {
            uint256 balance_ = address(this).balance;
            
            if (balance_ > 0) SafeTransfer.safeTransferNative(payable(owner_), balance_);
        } else {
            uint256 balance_ = IERC20(token_).balanceOf(address(this));

            if (balance_ > 0) SafeTransfer.safeTransfer(token_, owner_, balance_);
        }
    }

    /// @dev validate `owner` by recomputing fluid address.
    function _validateOwner(address owner_) internal view {
        address wallet_ = Clones.predictDeterministicAddress(
            IFluidWalletFactory(FLUID_WALLET_FACTORY).WALLET_PROXY(),
            keccak256(abi.encode(owner_)),
            FLUID_WALLET_FACTORY
        );
        if (wallet_ != address(this)) revert FluidWallet__NotAllowed();
    }

    /// @dev executes `actions_` with respective target, calldata, operation etc.
    function _executeActions(Action[] memory actions_) internal {
       uint256 actionsLength_ = actions_.length;
        for (uint256 i; i < actionsLength_; ) {
            Action memory action_ = actions_[i];

            // execute action
            bool success_;
            bytes memory result_;
            if (action_.operation == 0) {
                // call (operation = 0)

                // low-level call will return success true also if action target is not even a contract.
                // we do not explicitly check for this, default interaction is via UI which can check and handle this.
                // Also applies to delegatecall etc.
                (success_, result_) = action_.target.call{ value: action_.value }(action_.data);

                // handle action failure right after external call to better detect out of gas errors
                if (!success_) {
                    _handleActionFailure(i, result_);
                }
            } else if (action_.operation == 1) {
                // delegatecall (operation = 1)

                (success_, result_) = action_.target.delegatecall(action_.data);

                // reset _transientAllowHash to make sure it can not be set up in any way for reentrancy
                _resetTransientStorage();

                // handle action failure right after external call to better detect out of gas errors
                if (!success_) {
                    _handleActionFailure(i, result_);
                }
            } else if (action_.operation == 2) {
                // flashloan (operation = 2)
                // flashloan is always executed via .call, flashloan aggregator uses `msg.sender`, so .delegatecall
                // wouldn't send funds to this contract but rather to the original sender.

                bytes memory data_ = action_.data;
                assembly {
                    data_ := add(data_, 4) // Skip function selector (4 bytes)
                }
                // get actions data from calldata action_.data. Only supports InstaFlashAggregatorInterface
                (, , , data_, ) = abi.decode(data_, (address[], uint256[], uint256, bytes, bytes));

                // set allowHash to signal allowed entry into executeOperation()
                _transientAllowHash = bytes32(
                    keccak256(abi.encode(data_, block.timestamp))
                );

                // handle action failure right after external call to better detect out of gas errors
                (success_, result_) = action_.target.call{ value: action_.value }(action_.data);

                if (!success_) {
                    _handleActionFailure(i, result_);
                }

                // reset _transientAllowHash to prevent reentrancy during actions execution
                _resetTransientStorage();
            } else {
                // either operation does not exist or the id was not set according to what the action wants to execute
                revert(string.concat(Strings.toString(i), "_FLUID__INVALID_ID_OR_OPERATION"));
            }

            unchecked {
                ++i;
            }
        }
    }

    /// @dev handles failure of an action execution depending on error cause,
    /// decoding and reverting with `result_` as reason string.
    function _handleActionFailure(uint256 i_, bytes memory result_) internal pure {
        revert(string.concat(Strings.toString(i_), _getRevertReasonFromReturnedData(result_)));
    }

    uint256 internal constant REVERT_REASON_MAX_LENGTH = 250;

    /// @dev Get the revert reason from the returnedData (supports Panic, Error & Custom Errors).
    /// Based on https://github.com/superfluid-finance/protocol-monorepo/blob/dev/packages/ethereum-contracts/contracts/libs/CallUtils.sol
    /// This is needed in order to provide some human-readable revert message from a call.
    /// @param returnedData_ revert data of the call
    /// @return reason_      revert reason
    function _getRevertReasonFromReturnedData(
        bytes memory returnedData_
    ) internal pure returns (string memory reason_) {
        if (returnedData_.length < 4) {
            // case 1: catch all
            return "_REASON_NOT_DEFINED";
        }

        bytes4 errorSelector_;
        assembly {
            errorSelector_ := mload(add(returnedData_, 0x20))
        }
        if (errorSelector_ == bytes4(0x4e487b71)) {
            // case 2: Panic(uint256), selector 0x4e487b71 (Defined since 0.8.0)
            // ref: https://docs.soliditylang.org/en/v0.8.0/control-structures.html#panic-via-assert-and-error-via-require)

            // convert last byte to hex digits -> string to decode the panic code
            bytes memory result_ = new bytes(2);
            result_[0] = _toHexDigit(uint8(returnedData_[returnedData_.length - 1]) / 16);
            result_[1] = _toHexDigit(uint8(returnedData_[returnedData_.length - 1]) % 16);
            reason_ = string.concat("_TARGET_PANICKED: 0x", string(result_));
        } else if (errorSelector_ == bytes4(0x08c379a0)) {
            // case 3: Error(string), selector 0x08c379a0 (Defined at least since 0.7.0)
            // based on https://ethereum.stackexchange.com/a/83577
            assembly {
                returnedData_ := add(returnedData_, 0x04)
            }
            reason_ = string.concat("_", abi.decode(returnedData_, (string)));
        } else {
            // case 4: Custom errors (Defined since 0.8.0)

            // convert bytes4 selector to string, params are ignored...
            // based on https://ethereum.stackexchange.com/a/111876
            bytes memory result_ = new bytes(8);
            for (uint256 i; i < 4; ) {
                // use unchecked as i is < 4 and division. also errorSelector can not underflow
                unchecked {
                    result_[2 * i] = _toHexDigit(uint8(errorSelector_[i]) / 16);
                    result_[2 * i + 1] = _toHexDigit(uint8(errorSelector_[i]) % 16);
                    ++i;
                }
            }
            reason_ = string.concat("_CUSTOM_ERROR: 0x", string(result_));
        }

        {
            // truncate reason_ string to REVERT_REASON_MAX_LENGTH for reserveGas used to ensure Cast event is emitted
            if (bytes(reason_).length > REVERT_REASON_MAX_LENGTH) {
                bytes memory reasonBytes_ = bytes(reason_);
                uint256 maxLength_ = REVERT_REASON_MAX_LENGTH + 1; // cheaper than <= in each loop
                bytes memory truncatedRevertReason_ = new bytes(maxLength_);
                for (uint256 i; i < maxLength_; ) {
                    truncatedRevertReason_[i] = reasonBytes_[i];

                    unchecked {
                        ++i;
                    }
                }
                reason_ = string(truncatedRevertReason_);
            }
        }
    }

    /// @dev used to convert bytes4 selector to string
    function _toHexDigit(uint8 d) internal pure returns (bytes1) {
        // use unchecked as the operations with d can not over / underflow
        unchecked {
            if (d < 10) {
                return bytes1(uint8(bytes1("0")) + d);
            }
            if (d < 16) {
                return bytes1(uint8(bytes1("a")) + d - 10);
            }
        }
        revert FluidWallet__ToHexDigit();
    }
}
