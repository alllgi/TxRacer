// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

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

// File: solmate/src/utils/FixedPointMathLib.sol

pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant MAX_UINT256 = 2**256 - 1;

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // Divide x * y by the denominator.
            z := div(mul(x, y), denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // If x * y modulo the denominator is strictly greater than 0,
            // 1 is added to round up the division of x * y by the denominator.
            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Mod x by y. Note this will return
            // 0 instead of reverting if y is zero.
            z := mod(x, y)
        }
    }

    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Divide x by y. Note this will return
            // 0 instead of reverting if y is zero.
            r := div(x, y)
        }
    }

    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Add 1 to x * y if x % y > 0. Note this will
            // return 0 instead of reverting if y is zero.
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}

// File: contracts/libraries/bigMathMinified.sol

pragma solidity 0.8.21;

/// @title library that represents a number in BigNumber(coefficient and exponent) format to store in smaller bits.
/// @notice the number is divided into two parts: a coefficient and an exponent. This comes at a cost of losing some precision
/// at the end of the number because the exponent simply fills it with zeroes. This precision is oftentimes negligible and can
/// result in significant gas cost reduction due to storage space reduction.
/// Also note, a valid big number is as follows: if the exponent is > 0, then coefficient last bits should be occupied to have max precision.
/// @dev roundUp is more like a increase 1, which happens everytime for the same number.
/// roundDown simply sets trailing digits after coefficientSize to zero (floor), only once for the same number.
library BigMathMinified {
    /// @dev constants to use for `roundUp` input param to increase readability
    bool internal constant ROUND_DOWN = false;
    bool internal constant ROUND_UP = true;

    /// @dev converts `normal` number to BigNumber with `exponent` and `coefficient` (or precision).
    /// e.g.:
    /// 5035703444687813576399599 (normal) = (coefficient[32bits], exponent[8bits])[40bits]
    /// 5035703444687813576399599 (decimal) => 10000101010010110100000011111011110010100110100000000011100101001101001101011101111 (binary)
    ///                                     => 10000101010010110100000011111011000000000000000000000000000000000000000000000000000
    ///                                                                        ^-------------------- 51(exponent) -------------- ^
    /// coefficient = 1000,0101,0100,1011,0100,0000,1111,1011               (2236301563)
    /// exponent =                                            0011,0011     (51)
    /// bigNumber =   1000,0101,0100,1011,0100,0000,1111,1011,0011,0011     (572493200179)
    ///
    /// @param normal number which needs to be converted into Big Number
    /// @param coefficientSize at max how many bits of precision there should be (64 = uint64 (64 bits precision))
    /// @param exponentSize at max how many bits of exponent there should be (8 = uint8 (8 bits exponent))
    /// @param roundUp signals if result should be rounded down or up
    /// @return bigNumber converted bigNumber (coefficient << exponent)
    function toBigNumber(
        uint256 normal,
        uint256 coefficientSize,
        uint256 exponentSize,
        bool roundUp
    ) internal pure returns (uint256 bigNumber) {
        assembly {
            let lastBit_
            let number_ := normal
            if gt(number_, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                number_ := shr(0x80, number_)
                lastBit_ := 0x80
            }
            if gt(number_, 0xFFFFFFFFFFFFFFFF) {
                number_ := shr(0x40, number_)
                lastBit_ := add(lastBit_, 0x40)
            }
            if gt(number_, 0xFFFFFFFF) {
                number_ := shr(0x20, number_)
                lastBit_ := add(lastBit_, 0x20)
            }
            if gt(number_, 0xFFFF) {
                number_ := shr(0x10, number_)
                lastBit_ := add(lastBit_, 0x10)
            }
            if gt(number_, 0xFF) {
                number_ := shr(0x8, number_)
                lastBit_ := add(lastBit_, 0x8)
            }
            if gt(number_, 0xF) {
                number_ := shr(0x4, number_)
                lastBit_ := add(lastBit_, 0x4)
            }
            if gt(number_, 0x3) {
                number_ := shr(0x2, number_)
                lastBit_ := add(lastBit_, 0x2)
            }
            if gt(number_, 0x1) {
                lastBit_ := add(lastBit_, 1)
            }
            if gt(number_, 0) {
                lastBit_ := add(lastBit_, 1)
            }
            if lt(lastBit_, coefficientSize) {
                // for throw exception
                lastBit_ := coefficientSize
            }
            let exponent := sub(lastBit_, coefficientSize)
            let coefficient := shr(exponent, normal)
            if and(roundUp, gt(exponent, 0)) {
                // rounding up is only needed if exponent is > 0, as otherwise the coefficient fully holds the original number
                coefficient := add(coefficient, 1)
                if eq(shl(coefficientSize, 1), coefficient) {
                    // case were coefficient was e.g. 111, with adding 1 it became 1000 (in binary) and coefficientSize 3 bits
                    // final coefficient would exceed it's size. -> reduce coefficent to 100 and increase exponent by 1.
                    coefficient := shl(sub(coefficientSize, 1), 1)
                    exponent := add(exponent, 1)
                }
            }
            if iszero(lt(exponent, shl(exponentSize, 1))) {
                // if exponent is >= exponentSize, the normal number is too big to fit within
                // BigNumber with too small sizes for coefficient and exponent
                revert(0, 0)
            }
            bigNumber := shl(exponentSize, coefficient)
            bigNumber := add(bigNumber, exponent)
        }
    }

    /// @dev get `normal` number from `bigNumber`, `exponentSize` and `exponentMask`
    function fromBigNumber(
        uint256 bigNumber,
        uint256 exponentSize,
        uint256 exponentMask
    ) internal pure returns (uint256 normal) {
        assembly {
            let coefficient := shr(exponentSize, bigNumber)
            let exponent := and(bigNumber, exponentMask)
            normal := shl(exponent, coefficient)
        }
    }

    /// @dev gets the most significant bit `lastBit` of a `normal` number (length of given number of binary format).
    /// e.g.
    /// 5035703444687813576399599 = 10000101010010110100000011111011110010100110100000000011100101001101001101011101111
    /// lastBit =                   ^---------------------------------   83   ----------------------------------------^
    function mostSignificantBit(uint256 normal) internal pure returns (uint lastBit) {
        assembly {
            let number_ := normal
            if gt(normal, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                number_ := shr(0x80, number_)
                lastBit := 0x80
            }
            if gt(number_, 0xFFFFFFFFFFFFFFFF) {
                number_ := shr(0x40, number_)
                lastBit := add(lastBit, 0x40)
            }
            if gt(number_, 0xFFFFFFFF) {
                number_ := shr(0x20, number_)
                lastBit := add(lastBit, 0x20)
            }
            if gt(number_, 0xFFFF) {
                number_ := shr(0x10, number_)
                lastBit := add(lastBit, 0x10)
            }
            if gt(number_, 0xFF) {
                number_ := shr(0x8, number_)
                lastBit := add(lastBit, 0x8)
            }
            if gt(number_, 0xF) {
                number_ := shr(0x4, number_)
                lastBit := add(lastBit, 0x4)
            }
            if gt(number_, 0x3) {
                number_ := shr(0x2, number_)
                lastBit := add(lastBit, 0x2)
            }
            if gt(number_, 0x1) {
                lastBit := add(lastBit, 1)
            }
            if gt(number_, 0) {
                lastBit := add(lastBit, 1)
            }
        }
    }
}

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

// File: contracts/libraries/liquiditySlotsLink.sol

pragma solidity 0.8.21;

/// @notice library that helps in reading / working with storage slot data of Fluid Liquidity.
/// @dev as all data for Fluid Liquidity is internal, any data must be fetched directly through manual
/// slot reading through this library or, if gas usage is less important, through the FluidLiquidityResolver.
library LiquiditySlotsLink {
    /// @dev storage slot for status at Liquidity
    uint256 internal constant LIQUIDITY_STATUS_SLOT = 1;
    /// @dev storage slot for auths mapping at Liquidity
    uint256 internal constant LIQUIDITY_AUTHS_MAPPING_SLOT = 2;
    /// @dev storage slot for guardians mapping at Liquidity
    uint256 internal constant LIQUIDITY_GUARDIANS_MAPPING_SLOT = 3;
    /// @dev storage slot for user class mapping at Liquidity
    uint256 internal constant LIQUIDITY_USER_CLASS_MAPPING_SLOT = 4;
    /// @dev storage slot for exchangePricesAndConfig mapping at Liquidity
    uint256 internal constant LIQUIDITY_EXCHANGE_PRICES_MAPPING_SLOT = 5;
    /// @dev storage slot for rateData mapping at Liquidity
    uint256 internal constant LIQUIDITY_RATE_DATA_MAPPING_SLOT = 6;
    /// @dev storage slot for totalAmounts mapping at Liquidity
    uint256 internal constant LIQUIDITY_TOTAL_AMOUNTS_MAPPING_SLOT = 7;
    /// @dev storage slot for user supply double mapping at Liquidity
    uint256 internal constant LIQUIDITY_USER_SUPPLY_DOUBLE_MAPPING_SLOT = 8;
    /// @dev storage slot for user borrow double mapping at Liquidity
    uint256 internal constant LIQUIDITY_USER_BORROW_DOUBLE_MAPPING_SLOT = 9;
    /// @dev storage slot for listed tokens array at Liquidity
    uint256 internal constant LIQUIDITY_LISTED_TOKENS_ARRAY_SLOT = 10;
    /// @dev storage slot for listed tokens array at Liquidity
    uint256 internal constant LIQUIDITY_CONFIGS2_MAPPING_SLOT = 11;

    // --------------------------------
    // @dev stacked uint256 storage slots bits position data for each:

    // ExchangePricesAndConfig
    uint256 internal constant BITS_EXCHANGE_PRICES_BORROW_RATE = 0;
    uint256 internal constant BITS_EXCHANGE_PRICES_FEE = 16;
    uint256 internal constant BITS_EXCHANGE_PRICES_UTILIZATION = 30;
    uint256 internal constant BITS_EXCHANGE_PRICES_UPDATE_THRESHOLD = 44;
    uint256 internal constant BITS_EXCHANGE_PRICES_LAST_TIMESTAMP = 58;
    uint256 internal constant BITS_EXCHANGE_PRICES_SUPPLY_EXCHANGE_PRICE = 91;
    uint256 internal constant BITS_EXCHANGE_PRICES_BORROW_EXCHANGE_PRICE = 155;
    uint256 internal constant BITS_EXCHANGE_PRICES_SUPPLY_RATIO = 219;
    uint256 internal constant BITS_EXCHANGE_PRICES_BORROW_RATIO = 234;
    uint256 internal constant BITS_EXCHANGE_PRICES_USES_CONFIGS2 = 249;

    // RateData:
    uint256 internal constant BITS_RATE_DATA_VERSION = 0;
    // RateData: V1
    uint256 internal constant BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_ZERO = 4;
    uint256 internal constant BITS_RATE_DATA_V1_UTILIZATION_AT_KINK = 20;
    uint256 internal constant BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_KINK = 36;
    uint256 internal constant BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_MAX = 52;
    // RateData: V2
    uint256 internal constant BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_ZERO = 4;
    uint256 internal constant BITS_RATE_DATA_V2_UTILIZATION_AT_KINK1 = 20;
    uint256 internal constant BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_KINK1 = 36;
    uint256 internal constant BITS_RATE_DATA_V2_UTILIZATION_AT_KINK2 = 52;
    uint256 internal constant BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_KINK2 = 68;
    uint256 internal constant BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_MAX = 84;

    // TotalAmounts
    uint256 internal constant BITS_TOTAL_AMOUNTS_SUPPLY_WITH_INTEREST = 0;
    uint256 internal constant BITS_TOTAL_AMOUNTS_SUPPLY_INTEREST_FREE = 64;
    uint256 internal constant BITS_TOTAL_AMOUNTS_BORROW_WITH_INTEREST = 128;
    uint256 internal constant BITS_TOTAL_AMOUNTS_BORROW_INTEREST_FREE = 192;

    // UserSupplyData
    uint256 internal constant BITS_USER_SUPPLY_MODE = 0;
    uint256 internal constant BITS_USER_SUPPLY_AMOUNT = 1;
    uint256 internal constant BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT = 65;
    uint256 internal constant BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_SUPPLY_BASE_WITHDRAWAL_LIMIT = 200;
    uint256 internal constant BITS_USER_SUPPLY_IS_PAUSED = 255;

    // UserBorrowData
    uint256 internal constant BITS_USER_BORROW_MODE = 0;
    uint256 internal constant BITS_USER_BORROW_AMOUNT = 1;
    uint256 internal constant BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT = 65;
    uint256 internal constant BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_BORROW_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_BORROW_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_BORROW_BASE_BORROW_LIMIT = 200;
    uint256 internal constant BITS_USER_BORROW_MAX_BORROW_LIMIT = 218;
    uint256 internal constant BITS_USER_BORROW_IS_PAUSED = 255;

    // Configs2
    uint256 internal constant BITS_CONFIGS2_MAX_UTILIZATION = 0;

    // --------------------------------

    /// @notice Calculating the slot ID for Liquidity contract for single mapping at `slot_` for `key_`
    function calculateMappingStorageSlot(uint256 slot_, address key_) internal pure returns (bytes32) {
        return keccak256(abi.encode(key_, slot_));
    }

    /// @notice Calculating the slot ID for Liquidity contract for double mapping at `slot_` for `key1_` and `key2_`
    function calculateDoubleMappingStorageSlot(
        uint256 slot_,
        address key1_,
        address key2_
    ) internal pure returns (bytes32) {
        bytes32 intermediateSlot_ = keccak256(abi.encode(key1_, slot_));
        return keccak256(abi.encode(key2_, intermediateSlot_));
    }
}

// File: contracts/libraries/liquidityCalcs.sol

pragma solidity 0.8.21;





/// @notice implements calculation methods used for Fluid liquidity such as updated exchange prices,
/// borrow rate, withdrawal / borrow limits, revenue amount.
library LiquidityCalcs {
    error FluidLiquidityCalcsError(uint256 errorId_);

    /// @notice emitted if the calculated borrow rate surpassed max borrow rate (16 bits) and was capped at maximum value 65535
    event BorrowRateMaxCap();

    /// @dev constants as from Liquidity variables.sol
    uint256 internal constant EXCHANGE_PRICES_PRECISION = 1e12;

    /// @dev Ignoring leap years
    uint256 internal constant SECONDS_PER_YEAR = 365 days;
    // constants used for BigMath conversion from and to storage
    uint256 internal constant DEFAULT_EXPONENT_SIZE = 8;
    uint256 internal constant DEFAULT_EXPONENT_MASK = 0xFF;

    uint256 internal constant FOUR_DECIMALS = 1e4;
    uint256 internal constant TWELVE_DECIMALS = 1e12;
    uint256 internal constant X14 = 0x3fff;
    uint256 internal constant X15 = 0x7fff;
    uint256 internal constant X16 = 0xffff;
    uint256 internal constant X18 = 0x3ffff;
    uint256 internal constant X24 = 0xffffff;
    uint256 internal constant X33 = 0x1ffffffff;
    uint256 internal constant X64 = 0xffffffffffffffff;

    ///////////////////////////////////////////////////////////////////////////
    //////////                  CALC EXCHANGE PRICES                  /////////
    ///////////////////////////////////////////////////////////////////////////

    /// @dev calculates interest (exchange prices) for a token given its' exchangePricesAndConfig from storage.
    /// @param exchangePricesAndConfig_ exchange prices and config packed uint256 read from storage
    /// @return supplyExchangePrice_ updated supplyExchangePrice
    /// @return borrowExchangePrice_ updated borrowExchangePrice
    function calcExchangePrices(
        uint256 exchangePricesAndConfig_
    ) internal view returns (uint256 supplyExchangePrice_, uint256 borrowExchangePrice_) {
        // Extracting exchange prices
        supplyExchangePrice_ =
            (exchangePricesAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_SUPPLY_EXCHANGE_PRICE) &
            X64;
        borrowExchangePrice_ =
            (exchangePricesAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_BORROW_EXCHANGE_PRICE) &
            X64;

        if (supplyExchangePrice_ == 0 || borrowExchangePrice_ == 0) {
            revert FluidLiquidityCalcsError(ErrorTypes.LiquidityCalcs__ExchangePriceZero);
        }

        uint256 temp_ = exchangePricesAndConfig_ & X16; // temp_ = borrowRate

        unchecked {
            // last timestamp can not be > current timestamp
            uint256 secondsSinceLastUpdate_ = block.timestamp -
                ((exchangePricesAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_LAST_TIMESTAMP) & X33);

            uint256 borrowRatio_ = (exchangePricesAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_BORROW_RATIO) &
                X15;
            if (secondsSinceLastUpdate_ == 0 || temp_ == 0 || borrowRatio_ == 1) {
                // if no time passed, borrow rate is 0, or no raw borrowings: no exchange price update needed
                // (if borrowRatio_ == 1 means there is only borrowInterestFree, as first bit is 1 and rest is 0)
                return (supplyExchangePrice_, borrowExchangePrice_);
            }

            // calculate new borrow exchange price.
            // formula borrowExchangePriceIncrease: previous price * borrow rate * secondsSinceLastUpdate_.
            // nominator is max uint112 (uint64 * uint16 * uint32). Divisor can not be 0.
            borrowExchangePrice_ +=
                (borrowExchangePrice_ * temp_ * secondsSinceLastUpdate_) /
                (SECONDS_PER_YEAR * FOUR_DECIMALS);

            // FOR SUPPLY EXCHANGE PRICE:
            // all yield paid by borrowers (in mode with interest) goes to suppliers in mode with interest.
            // formula: previous price * supply rate * secondsSinceLastUpdate_.
            // where supply rate = (borrow rate  - revenueFee%) * ratioSupplyYield. And
            // ratioSupplyYield = utilization * supplyRatio * borrowRatio
            //
            // Example:
            // supplyRawInterest is 80, supplyInterestFree is 20. totalSupply is 100. BorrowedRawInterest is 50.
            // BorrowInterestFree is 10. TotalBorrow is 60. borrow rate 40%, revenueFee 10%.
            // yield is 10 (so half a year must have passed).
            // supplyRawInterest must become worth 89. totalSupply must become 109. BorrowedRawInterest must become 60.
            // borrowInterestFree must still be 10. supplyInterestFree still 20. totalBorrow 70.
            // supplyExchangePrice would have to go from 1 to 1,125 (+ 0.125). borrowExchangePrice from 1 to 1,2 (+0.2).
            // utilization is 60%. supplyRatio = 20 / 80 = 25% (only 80% of lenders receiving yield).
            // borrowRatio = 10 / 50 = 20% (only 83,333% of borrowers paying yield):
            // x of borrowers paying yield = 100% - (20 / (100 + 20)) = 100% - 16.6666666% = 83,333%.
            // ratioSupplyYield = 60% * 83,33333% * (100% + 20%) = 62,5%
            // supplyRate = (40% * (100% - 10%)) * = 36% * 62,5% = 22.5%
            // increase in supplyExchangePrice, assuming 100 as previous price.
            // 100 * 22,5% * 1/2 (half a year) = 0,1125.
            // cross-check supplyRawInterest worth = 80 * 1.1125 = 89. totalSupply worth = 89 + 20.

            // -------------- 1. calculate ratioSupplyYield --------------------------------
            // step1: utilization * supplyRatio (or actually part of lenders receiving yield)

            // temp_ => supplyRatio (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
            // if first bit 0 then ratio is supplyInterestFree / supplyWithInterest (supplyWithInterest is bigger)
            // else ratio is supplyWithInterest / supplyInterestFree (supplyInterestFree is bigger)
            temp_ = (exchangePricesAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_SUPPLY_RATIO) & X15;

            if (temp_ == 1) {
                // if no raw supply: no exchange price update needed
                // (if supplyRatio_ == 1 means there is only supplyInterestFree, as first bit is 1 and rest is 0)
                return (supplyExchangePrice_, borrowExchangePrice_);
            }

            // ratioSupplyYield precision is 1e27 as 100% for increased precision when supplyInterestFree > supplyWithInterest
            if (temp_ & 1 == 1) {
                // ratio is supplyWithInterest / supplyInterestFree (supplyInterestFree is bigger)
                temp_ = temp_ >> 1;

                // Note: case where temp_ == 0 (only supplyInterestFree, no yield) already covered by early return
                // in the if statement a little above.

                // based on above example but supplyRawInterest is 20, supplyInterestFree is 80. no fee.
                // supplyRawInterest must become worth 30. totalSupply must become 110.
                // supplyExchangePrice would have to go from 1 to 1,5. borrowExchangePrice from 1 to 1,2.
                // so ratioSupplyYield must come out as 2.5 (250%).
                // supplyRatio would be (20 * 10_000 / 80) = 2500. but must be inverted.
                temp_ = (1e27 * FOUR_DECIMALS) / temp_; // e.g. 1e31 / 2500 = 4e27. (* 1e27 for precision)
                // e.g. 5_000 * (1e27 + 4e27) / 1e27 = 25_000 (=250%).
                temp_ =
                    // utilization * (100% + 100% / supplyRatio)
                    (((exchangePricesAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_UTILIZATION) & X14) *
                        (1e27 + temp_)) / // extract utilization (max 16_383 so there is no way this can overflow).
                    (FOUR_DECIMALS);
                // max possible value of temp_ here is 16383 * (1e27 + 1e31) / 1e4 = ~1.64e31
            } else {
                // ratio is supplyInterestFree / supplyWithInterest (supplyWithInterest is bigger)
                temp_ = temp_ >> 1;
                // if temp_ == 0 then only supplyWithInterest => full yield. temp_ is already 0

                // e.g. 5_000 * 10_000 + (20 * 10_000 / 80) / 10_000 = 5000 * 12500 / 10000 = 6250 (=62.5%).
                temp_ =
                    // 1e27 * utilization * (100% + supplyRatio) / 100%
                    (1e27 *
                        ((exchangePricesAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_UTILIZATION) & X14) * // extract utilization (max 16_383 so there is no way this can overflow).
                        (FOUR_DECIMALS + temp_)) /
                    (FOUR_DECIMALS * FOUR_DECIMALS);
                // max possible temp_ value: 1e27 * 16383 * 2e4 / 1e8 = 3.2766e27
            }
            // from here temp_ => ratioSupplyYield (utilization * supplyRatio part) scaled by 1e27. max possible value ~1.64e31

            // step2 of ratioSupplyYield: add borrowRatio (only x% of borrowers paying yield)
            if (borrowRatio_ & 1 == 1) {
                // ratio is borrowWithInterest / borrowInterestFree (borrowInterestFree is bigger)
                borrowRatio_ = borrowRatio_ >> 1;
                // borrowRatio_ => x of total bororwers paying yield. scale to 1e27.

                // Note: case where borrowRatio_ == 0 (only borrowInterestFree, no yield) already covered
                // at the beginning of the method by early return if `borrowRatio_ == 1`.

                // based on above example but borrowRawInterest is 10, borrowInterestFree is 50. no fee. borrowRatio = 20%.
                // so only 16.66% of borrowers are paying yield. so the 100% - part of the formula is not needed.
                // x of borrowers paying yield = (borrowRatio / (100 + borrowRatio)) = 16.6666666%
                // borrowRatio_ => x of total bororwers paying yield. scale to 1e27.
                borrowRatio_ = (borrowRatio_ * 1e27) / (FOUR_DECIMALS + borrowRatio_);
                // max value here for borrowRatio_ is (1e31 / (1e4 + 1e4))= 5e26 (= 50% of borrowers paying yield).
            } else {
                // ratio is borrowInterestFree / borrowWithInterest (borrowWithInterest is bigger)
                borrowRatio_ = borrowRatio_ >> 1;

                // borrowRatio_ => x of total bororwers paying yield. scale to 1e27.
                // x of borrowers paying yield = 100% - (borrowRatio / (100 + borrowRatio)) = 100% - 16.6666666% = 83,333%.
                borrowRatio_ = (1e27 - ((borrowRatio_ * 1e27) / (FOUR_DECIMALS + borrowRatio_)));
                // borrowRatio can never be > 100%. so max subtraction can be 100% - 100% / 200%.
                // or if borrowRatio_ is 0 -> 100% - 0. or if borrowRatio_ is 1 -> 100% - 1 / 101.
                // max value here for borrowRatio_ is 1e27 - 0 = 1e27 (= 100% of borrowers paying yield).
            }

            // temp_ => ratioSupplyYield. scaled down from 1e25 = 1% each to normal percent precision 1e2 = 1%.
            // max nominator value is ~1.64e31 * 1e27 = 1.64e58. max result = 1.64e8
            temp_ = (FOUR_DECIMALS * temp_ * borrowRatio_) / 1e54;

            // 2. calculate supply rate
            // temp_ => supply rate (borrow rate  - revenueFee%) * ratioSupplyYield.
            // division part is done in next step to increase precision. (divided by 2x FOUR_DECIMALS, fee + borrowRate)
            // Note that all calculation divisions for supplyExchangePrice are rounded down.
            // Note supply rate can be bigger than the borrowRate, e.g. if there are only few lenders with interest
            // but more suppliers not earning interest.
            temp_ = ((exchangePricesAndConfig_ & X16) * // borrow rate
                temp_ * // ratioSupplyYield
                (FOUR_DECIMALS - ((exchangePricesAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_FEE) & X14))); // revenueFee
            // fee can not be > 100%. max possible = 65535 * ~1.64e8 * 1e4 =~1.074774e17.

            // 3. calculate increase in supply exchange price
            supplyExchangePrice_ += ((supplyExchangePrice_ * temp_ * secondsSinceLastUpdate_) /
                (SECONDS_PER_YEAR * FOUR_DECIMALS * FOUR_DECIMALS * FOUR_DECIMALS));
            // max possible nominator = max uint 64 * 1.074774e17 * max uint32 = ~8.52e45. Denominator can not be 0.
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    //////////                     CALC REVENUE                       /////////
    ///////////////////////////////////////////////////////////////////////////

    /// @dev gets the `revenueAmount_` for a token given its' totalAmounts and exchangePricesAndConfig from storage
    /// and the current balance of the Fluid liquidity contract for the token.
    /// @param totalAmounts_ total amounts packed uint256 read from storage
    /// @param exchangePricesAndConfig_ exchange prices and config packed uint256 read from storage
    /// @param liquidityTokenBalance_   current balance of Liquidity contract (IERC20(token_).balanceOf(address(this)))
    /// @return revenueAmount_ collectable revenue amount
    function calcRevenue(
        uint256 totalAmounts_,
        uint256 exchangePricesAndConfig_,
        uint256 liquidityTokenBalance_
    ) internal view returns (uint256 revenueAmount_) {
        // @dev no need to super-optimize this method as it is only used by admin

        // calculate the new exchange prices based on earned interest
        (uint256 supplyExchangePrice_, uint256 borrowExchangePrice_) = calcExchangePrices(exchangePricesAndConfig_);

        // total supply = interest free + with interest converted from raw
        uint256 totalSupply_ = getTotalSupply(totalAmounts_, supplyExchangePrice_);

        if (totalSupply_ > 0) {
            // available revenue: balanceOf(token) + totalBorrowings - totalLendings.
            revenueAmount_ = liquidityTokenBalance_ + getTotalBorrow(totalAmounts_, borrowExchangePrice_);
            // ensure there is no possible case because of rounding etc. where this would revert,
            // explicitly check if >
            revenueAmount_ = revenueAmount_ > totalSupply_ ? revenueAmount_ - totalSupply_ : 0;
            // Note: if utilization > 100% (totalSupply < totalBorrow), then all the amount above 100% utilization
            // can only be revenue.
        } else {
            // if supply is 0, then rest of balance can be withdrawn as revenue so that no amounts get stuck
            revenueAmount_ = liquidityTokenBalance_;
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    //////////                      CALC LIMITS                       /////////
    ///////////////////////////////////////////////////////////////////////////

    /// @dev calculates withdrawal limit before an operate execution:
    /// amount of user supply that must stay supplied (not amount that can be withdrawn).
    /// i.e. if user has supplied 100m and can withdraw 5M, this method returns the 95M, not the withdrawable amount 5M
    /// @param userSupplyData_ user supply data packed uint256 from storage
    /// @param userSupply_ current user supply amount already extracted from `userSupplyData_` and converted from BigMath
    /// @return currentWithdrawalLimit_ current withdrawal limit updated for expansion since last interaction.
    ///         returned value is in raw for with interest mode, normal amount for interest free mode!
    function calcWithdrawalLimitBeforeOperate(
        uint256 userSupplyData_,
        uint256 userSupply_
    ) internal view returns (uint256 currentWithdrawalLimit_) {
        // @dev must support handling the case where timestamp is 0 (config is set but no interactions yet).
        // first tx where timestamp is 0 will enter `if (lastWithdrawalLimit_ == 0)` because lastWithdrawalLimit_ is not set yet.
        // returning max withdrawal allowed, which is not exactly right but doesn't matter because the first interaction must be
        // a deposit anyway. Important is that it would not revert.

        // Note the first time a deposit brings the user supply amount to above the base withdrawal limit, the active limit
        // is the fully expanded limit immediately.

        // extract last set withdrawal limit
        uint256 lastWithdrawalLimit_ = (userSupplyData_ >>
            LiquiditySlotsLink.BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT) & X64;
        lastWithdrawalLimit_ =
            (lastWithdrawalLimit_ >> DEFAULT_EXPONENT_SIZE) <<
            (lastWithdrawalLimit_ & DEFAULT_EXPONENT_MASK);
        if (lastWithdrawalLimit_ == 0) {
            // withdrawal limit is not activated. Max withdrawal allowed
            return 0;
        }

        uint256 maxWithdrawableLimit_;
        uint256 temp_;
        unchecked {
            // extract max withdrawable percent of user supply and
            // calculate maximum withdrawable amount expandPercentage of user supply at full expansion duration elapsed
            // e.g.: if 10% expandPercentage, meaning 10% is withdrawable after full expandDuration has elapsed.

            // userSupply_ needs to be atleast 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            maxWithdrawableLimit_ =
                (((userSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_EXPAND_PERCENT) & X14) * userSupply_) /
                FOUR_DECIMALS;

            // time elapsed since last withdrawal limit was set (in seconds)
            // @dev last process timestamp is guaranteed to exist for withdrawal, as a supply must have happened before.
            // last timestamp can not be > current timestamp
            temp_ =
                block.timestamp -
                ((userSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP) & X33);
        }
        // calculate withdrawable amount of expandPercent that is elapsed of expandDuration.
        // e.g. if 60% of expandDuration has elapsed, then user should be able to withdraw 6% of user supply, down to 94%.
        // Note: no explicit check for this needed, it is covered by setting minWithdrawalLimit_ if needed.
        temp_ =
            (maxWithdrawableLimit_ * temp_) /
            // extract expand duration: After this, decrement won't happen (user can withdraw 100% of withdraw limit)
            ((userSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_EXPAND_DURATION) & X24); // expand duration can never be 0
        // calculate expanded withdrawal limit: last withdrawal limit - withdrawable amount.
        // Note: withdrawable amount here can grow bigger than userSupply if timeElapsed is a lot bigger than expandDuration,
        // which would cause the subtraction `lastWithdrawalLimit_ - withdrawableAmount_` to revert. In that case, set 0
        // which will cause minimum (fully expanded) withdrawal limit to be set in lines below.
        unchecked {
            // underflow explicitly checked & handled
            currentWithdrawalLimit_ = lastWithdrawalLimit_ > temp_ ? lastWithdrawalLimit_ - temp_ : 0;
            // calculate minimum withdrawal limit: minimum amount of user supply that must stay supplied at full expansion.
            // subtraction can not underflow as maxWithdrawableLimit_ is a percentage amount (<=100%) of userSupply_
            temp_ = userSupply_ - maxWithdrawableLimit_;
        }
        // if withdrawal limit is decreased below minimum then set minimum
        // (e.g. when more than expandDuration time has elapsed)
        if (temp_ > currentWithdrawalLimit_) {
            currentWithdrawalLimit_ = temp_;
        }
    }

    /// @dev calculates withdrawal limit after an operate execution:
    /// amount of user supply that must stay supplied (not amount that can be withdrawn).
    /// i.e. if user has supplied 100m and can withdraw 5M, this method returns the 95M, not the withdrawable amount 5M
    /// @param userSupplyData_ user supply data packed uint256 from storage
    /// @param userSupply_ current user supply amount already extracted from `userSupplyData_` and added / subtracted with the executed operate amount
    /// @param newWithdrawalLimit_ current withdrawal limit updated for expansion since last interaction, result from `calcWithdrawalLimitBeforeOperate`
    /// @return withdrawalLimit_ updated withdrawal limit that should be written to storage. returned value is in
    ///                          raw for with interest mode, normal amount for interest free mode!
    function calcWithdrawalLimitAfterOperate(
        uint256 userSupplyData_,
        uint256 userSupply_,
        uint256 newWithdrawalLimit_
    ) internal pure returns (uint256) {
        // temp_ => base withdrawal limit. below this, maximum withdrawals are allowed
        uint256 temp_ = (userSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_BASE_WITHDRAWAL_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        // if user supply is below base limit then max withdrawals are allowed
        if (userSupply_ < temp_) {
            return 0;
        }
        // temp_ => withdrawal limit expandPercent (is in 1e2 decimals)
        temp_ = (userSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_EXPAND_PERCENT) & X14;
        unchecked {
            // temp_ => minimum withdrawal limit: userSupply - max withdrawable limit (userSupply * expandPercent))
            // userSupply_ needs to be atleast 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            // subtraction can not underflow as maxWithdrawableLimit_ is a percentage amount (<=100%) of userSupply_
            temp_ = userSupply_ - ((userSupply_ * temp_) / FOUR_DECIMALS);
        }
        // if new (before operation) withdrawal limit is less than minimum limit then set minimum limit.
        // e.g. can happen on new deposits. withdrawal limit is instantly fully expanded in a scenario where
        // increased deposit amount outpaces withrawals.
        if (temp_ > newWithdrawalLimit_) {
            return temp_;
        }
        return newWithdrawalLimit_;
    }

    /// @dev calculates borrow limit before an operate execution:
    /// total amount user borrow can reach (not borrowable amount in current operation).
    /// i.e. if user has borrowed 50M and can still borrow 5M, this method returns the total 55M, not the borrowable amount 5M
    /// @param userBorrowData_ user borrow data packed uint256 from storage
    /// @param userBorrow_ current user borrow amount already extracted from `userBorrowData_`
    /// @return currentBorrowLimit_ current borrow limit updated for expansion since last interaction. returned value is in
    ///                             raw for with interest mode, normal amount for interest free mode!
    function calcBorrowLimitBeforeOperate(
        uint256 userBorrowData_,
        uint256 userBorrow_
    ) internal view returns (uint256 currentBorrowLimit_) {
        // @dev must support handling the case where timestamp is 0 (config is set but no interactions yet) -> base limit.
        // first tx where timestamp is 0 will enter `if (maxExpandedBorrowLimit_ < baseBorrowLimit_)` because `userBorrow_` and thus
        // `maxExpansionLimit_` and thus `maxExpandedBorrowLimit_` is 0 and `baseBorrowLimit_` can not be 0.

        // temp_ = extract borrow expand percent (is in 1e2 decimals)
        uint256 temp_ = (userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_EXPAND_PERCENT) & X14;

        uint256 maxExpansionLimit_;
        uint256 maxExpandedBorrowLimit_;
        unchecked {
            // calculate max expansion limit: Max amount limit can expand to since last interaction
            // userBorrow_ needs to be atleast 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            maxExpansionLimit_ = ((userBorrow_ * temp_) / FOUR_DECIMALS);

            // calculate max borrow limit: Max point limit can increase to since last interaction
            maxExpandedBorrowLimit_ = userBorrow_ + maxExpansionLimit_;
        }

        // currentBorrowLimit_ = extract base borrow limit
        currentBorrowLimit_ = (userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_BASE_BORROW_LIMIT) & X18;
        currentBorrowLimit_ =
            (currentBorrowLimit_ >> DEFAULT_EXPONENT_SIZE) <<
            (currentBorrowLimit_ & DEFAULT_EXPONENT_MASK);

        if (maxExpandedBorrowLimit_ < currentBorrowLimit_) {
            return currentBorrowLimit_;
        }
        // time elapsed since last borrow limit was set (in seconds)
        unchecked {
            // temp_ = timeElapsed_ (last timestamp can not be > current timestamp)
            temp_ =
                block.timestamp -
                ((userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP) & X33); // extract last update timestamp
        }

        // currentBorrowLimit_ = expandedBorrowableAmount + extract last set borrow limit
        currentBorrowLimit_ =
            // calculate borrow limit expansion since last interaction for `expandPercent` that is elapsed of `expandDuration`.
            // divisor is extract expand duration (after this, full expansion to expandPercentage happened).
            ((maxExpansionLimit_ * temp_) /
                ((userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_EXPAND_DURATION) & X24)) + // expand duration can never be 0
            //  extract last set borrow limit
            BigMathMinified.fromBigNumber(
                (userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT) & X64,
                DEFAULT_EXPONENT_SIZE,
                DEFAULT_EXPONENT_MASK
            );

        // if timeElapsed is bigger than expandDuration, new borrow limit would be > max expansion,
        // so set to `maxExpandedBorrowLimit_` in that case.
        // also covers the case where last process timestamp = 0 (timeElapsed would simply be very big)
        if (currentBorrowLimit_ > maxExpandedBorrowLimit_) {
            currentBorrowLimit_ = maxExpandedBorrowLimit_;
        }
        // temp_ = extract hard max borrow limit. Above this user can never borrow (not expandable above)
        temp_ = (userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_MAX_BORROW_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        if (currentBorrowLimit_ > temp_) {
            currentBorrowLimit_ = temp_;
        }
    }

    /// @dev calculates borrow limit after an operate execution:
    /// total amount user borrow can reach (not borrowable amount in current operation).
    /// i.e. if user has borrowed 50M and can still borrow 5M, this method returns the total 55M, not the borrowable amount 5M
    /// @param userBorrowData_ user borrow data packed uint256 from storage
    /// @param userBorrow_ current user borrow amount already extracted from `userBorrowData_` and added / subtracted with the executed operate amount
    /// @param newBorrowLimit_ current borrow limit updated for expansion since last interaction, result from `calcBorrowLimitBeforeOperate`
    /// @return borrowLimit_ updated borrow limit that should be written to storage.
    ///                      returned value is in raw for with interest mode, normal amount for interest free mode!
    function calcBorrowLimitAfterOperate(
        uint256 userBorrowData_,
        uint256 userBorrow_,
        uint256 newBorrowLimit_
    ) internal pure returns (uint256 borrowLimit_) {
        // temp_ = extract borrow expand percent
        uint256 temp_ = (userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_EXPAND_PERCENT) & X14; // (is in 1e2 decimals)

        unchecked {
            // borrowLimit_ = calculate maximum borrow limit at full expansion.
            // userBorrow_ needs to be at least 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            borrowLimit_ = userBorrow_ + ((userBorrow_ * temp_) / FOUR_DECIMALS);
        }

        // temp_ = extract base borrow limit
        temp_ = (userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_BASE_BORROW_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        if (borrowLimit_ < temp_) {
            // below base limit, borrow limit is always base limit
            return temp_;
        }
        // temp_ = extract hard max borrow limit. Above this user can never borrow (not expandable above)
        temp_ = (userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_MAX_BORROW_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        // make sure fully expanded borrow limit is not above hard max borrow limit
        if (borrowLimit_ > temp_) {
            borrowLimit_ = temp_;
        }
        // if new borrow limit (from before operate) is > max borrow limit, set max borrow limit.
        // (e.g. on a repay shrinking instantly to fully expanded borrow limit from new borrow amount. shrinking is instant)
        if (newBorrowLimit_ > borrowLimit_) {
            return borrowLimit_;
        }
        return newBorrowLimit_;
    }

    ///////////////////////////////////////////////////////////////////////////
    //////////                      CALC RATES                        /////////
    ///////////////////////////////////////////////////////////////////////////

    /// @dev Calculates new borrow rate from utilization for a token
    /// @param rateData_ rate data packed uint256 from storage for the token
    /// @param utilization_ totalBorrow / totalSupply. 1e4 = 100% utilization
    /// @return rate_ rate for that particular token in 1e2 precision (e.g. 5% rate = 500)
    function calcBorrowRateFromUtilization(uint256 rateData_, uint256 utilization_) internal returns (uint256 rate_) {
        // extract rate version: 4 bits (0xF) starting from bit 0
        uint256 rateVersion_ = (rateData_ & 0xF);

        if (rateVersion_ == 1) {
            rate_ = calcRateV1(rateData_, utilization_);
        } else if (rateVersion_ == 2) {
            rate_ = calcRateV2(rateData_, utilization_);
        } else {
            revert FluidLiquidityCalcsError(ErrorTypes.LiquidityCalcs__UnsupportedRateVersion);
        }

        if (rate_ > X16) {
            // hard cap for borrow rate at maximum value 16 bits (65535) to make sure it does not overflow storage space.
            // this is unlikely to ever happen if configs stay within expected levels.
            rate_ = X16;
            // emit event to more easily become aware
            emit BorrowRateMaxCap();
        }
    }

    /// @dev calculates the borrow rate based on utilization for rate data version 1 (with one kink) in 1e2 precision
    /// @param rateData_ rate data packed uint256 from storage for the token
    /// @param utilization_  in 1e2 (100% = 1e4)
    /// @return rate_ rate in 1e2 precision
    function calcRateV1(uint256 rateData_, uint256 utilization_) internal pure returns (uint256 rate_) {
        /// For rate v1 (one kink) ------------------------------------------------------
        /// Next 16  bits =>  4 - 19 => Rate at utilization 0% (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Next 16  bits =>  20- 35 => Utilization at kink1 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Next 16  bits =>  36- 51 => Rate at utilization kink1 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Next 16  bits =>  52- 67 => Rate at utilization 100% (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Last 188 bits =>  68-255 => blank, might come in use in future

        // y = mx + c.
        // y is borrow rate
        // x is utilization
        // m = slope (m can also be negative for declining rates)
        // c is constant (c can be negative)

        uint256 y1_;
        uint256 y2_;
        uint256 x1_;
        uint256 x2_;

        // extract kink1: 16 bits (0xFFFF) starting from bit 20
        // kink is in 1e2, same as utilization, so no conversion needed for direct comparison of the two
        uint256 kink1_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V1_UTILIZATION_AT_KINK) & X16;
        if (utilization_ < kink1_) {
            // if utilization is less than kink
            y1_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_ZERO) & X16;
            y2_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_KINK) & X16;
            x1_ = 0; // 0%
            x2_ = kink1_;
        } else {
            // else utilization is greater than kink
            y1_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_KINK) & X16;
            y2_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_MAX) & X16;
            x1_ = kink1_;
            x2_ = FOUR_DECIMALS; // 100%
        }

        int256 constant_;
        int256 slope_;
        unchecked {
            // calculating slope with twelve decimal precision. m = (y2 - y1) / (x2 - x1).
            // utilization of x2 can not be <= utilization of x1 (so no underflow or 0 divisor)
            // y is in 1e2 so can not overflow when multiplied with TWELVE_DECIMALS
            slope_ = (int256(y2_ - y1_) * int256(TWELVE_DECIMALS)) / int256((x2_ - x1_));

            // calculating constant at 12 decimal precision. slope is already in 12 decimal hence only multiple with y1. c = y - mx.
            // maximum y1_ value is 65535. 65535 * 1e12 can not overflow int256
            // maximum slope is 65535 - 0 * TWELVE_DECIMALS / 1 = 65535 * 1e12;
            // maximum x1_ is 100% (9_999 actually) => slope_ * x1_ can not overflow int256
            // subtraction most extreme case would be  0 - max value slope_ * x1_ => can not underflow int256
            constant_ = int256(y1_ * TWELVE_DECIMALS) - (slope_ * int256(x1_));

            // calculating new borrow rate
            // - slope_ max value is 65535 * 1e12,
            // - utilization max value is let's say 500% (extreme case where borrow rate increases borrow amount without new supply)
            // - constant max value is 65535 * 1e12
            // so max values are 65535 * 1e12 * 50_000 + 65535 * 1e12 -> 3.2768*10^21, which easily fits int256
            // divisor TWELVE_DECIMALS can not be 0
            slope_ = (slope_ * int256(utilization_)) + constant_; // reusing `slope_` as variable for gas savings
            if (slope_ < 0) {
                revert FluidLiquidityCalcsError(ErrorTypes.LiquidityCalcs__BorrowRateNegative);
            }
            rate_ = uint256(slope_) / TWELVE_DECIMALS;
        }
    }

    /// @dev calculates the borrow rate based on utilization for rate data version 2 (with two kinks) in 1e4 precision
    /// @param rateData_ rate data packed uint256 from storage for the token
    /// @param utilization_  in 1e2 (100% = 1e4)
    /// @return rate_ rate in 1e4 precision
    function calcRateV2(uint256 rateData_, uint256 utilization_) internal pure returns (uint256 rate_) {
        /// For rate v2 (two kinks) -----------------------------------------------------
        /// Next 16  bits =>  4 - 19 => Rate at utilization 0% (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Next 16  bits =>  20- 35 => Utilization at kink1 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Next 16  bits =>  36- 51 => Rate at utilization kink1 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Next 16  bits =>  52- 67 => Utilization at kink2 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Next 16  bits =>  68- 83 => Rate at utilization kink2 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Next 16  bits =>  84- 99 => Rate at utilization 100% (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
        /// Last 156 bits => 100-255 => blank, might come in use in future

        // y = mx + c.
        // y is borrow rate
        // x is utilization
        // m = slope (m can also be negative for declining rates)
        // c is constant (c can be negative)

        uint256 y1_;
        uint256 y2_;
        uint256 x1_;
        uint256 x2_;

        // extract kink1: 16 bits (0xFFFF) starting from bit 20
        // kink is in 1e2, same as utilization, so no conversion needed for direct comparison of the two
        uint256 kink1_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V2_UTILIZATION_AT_KINK1) & X16;
        if (utilization_ < kink1_) {
            // if utilization is less than kink1
            y1_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_ZERO) & X16;
            y2_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_KINK1) & X16;
            x1_ = 0; // 0%
            x2_ = kink1_;
        } else {
            // extract kink2: 16 bits (0xFFFF) starting from bit 52
            uint256 kink2_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V2_UTILIZATION_AT_KINK2) & X16;
            if (utilization_ < kink2_) {
                // if utilization is less than kink2
                y1_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_KINK1) & X16;
                y2_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_KINK2) & X16;
                x1_ = kink1_;
                x2_ = kink2_;
            } else {
                // else utilization is greater than kink2
                y1_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_KINK2) & X16;
                y2_ = (rateData_ >> LiquiditySlotsLink.BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_MAX) & X16;
                x1_ = kink2_;
                x2_ = FOUR_DECIMALS;
            }
        }

        int256 constant_;
        int256 slope_;
        unchecked {
            // calculating slope with twelve decimal precision. m = (y2 - y1) / (x2 - x1).
            // utilization of x2 can not be <= utilization of x1 (so no underflow or 0 divisor)
            // y is in 1e2 so can not overflow when multiplied with TWELVE_DECIMALS
            slope_ = (int256(y2_ - y1_) * int256(TWELVE_DECIMALS)) / int256((x2_ - x1_));

            // calculating constant at 12 decimal precision. slope is already in 12 decimal hence only multiple with y1. c = y - mx.
            // maximum y1_ value is 65535. 65535 * 1e12 can not overflow int256
            // maximum slope is 65535 - 0 * TWELVE_DECIMALS / 1 = 65535 * 1e12;
            // maximum x1_ is 100% (9_999 actually) => slope_ * x1_ can not overflow int256
            // subtraction most extreme case would be  0 - max value slope_ * x1_ => can not underflow int256
            constant_ = int256(y1_ * TWELVE_DECIMALS) - (slope_ * int256(x1_));

            // calculating new borrow rate
            // - slope_ max value is 65535 * 1e12,
            // - utilization max value is let's say 500% (extreme case where borrow rate increases borrow amount without new supply)
            // - constant max value is 65535 * 1e12
            // so max values are 65535 * 1e12 * 50_000 + 65535 * 1e12 -> 3.2768*10^21, which easily fits int256
            // divisor TWELVE_DECIMALS can not be 0
            slope_ = (slope_ * int256(utilization_)) + constant_; // reusing `slope_` as variable for gas savings
            if (slope_ < 0) {
                revert FluidLiquidityCalcsError(ErrorTypes.LiquidityCalcs__BorrowRateNegative);
            }
            rate_ = uint256(slope_) / TWELVE_DECIMALS;
        }
    }

    /// @dev reads the total supply out of Liquidity packed storage `totalAmounts_` for `supplyExchangePrice_`
    function getTotalSupply(
        uint256 totalAmounts_,
        uint256 supplyExchangePrice_
    ) internal pure returns (uint256 totalSupply_) {
        // totalSupply_ => supplyInterestFree
        totalSupply_ = (totalAmounts_ >> LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_SUPPLY_INTEREST_FREE) & X64;
        totalSupply_ = (totalSupply_ >> DEFAULT_EXPONENT_SIZE) << (totalSupply_ & DEFAULT_EXPONENT_MASK);

        uint256 totalSupplyRaw_ = totalAmounts_ & X64; // no shifting as supplyRaw is first 64 bits
        totalSupplyRaw_ = (totalSupplyRaw_ >> DEFAULT_EXPONENT_SIZE) << (totalSupplyRaw_ & DEFAULT_EXPONENT_MASK);

        // totalSupply = supplyInterestFree + supplyRawInterest normalized from raw
        totalSupply_ += ((totalSupplyRaw_ * supplyExchangePrice_) / EXCHANGE_PRICES_PRECISION);
    }

    /// @dev reads the total borrow out of Liquidity packed storage `totalAmounts_` for `borrowExchangePrice_`
    function getTotalBorrow(
        uint256 totalAmounts_,
        uint256 borrowExchangePrice_
    ) internal pure returns (uint256 totalBorrow_) {
        // totalBorrow_ => borrowInterestFree
        // no & mask needed for borrow interest free as it occupies the last bits in the storage slot
        totalBorrow_ = (totalAmounts_ >> LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_BORROW_INTEREST_FREE);
        totalBorrow_ = (totalBorrow_ >> DEFAULT_EXPONENT_SIZE) << (totalBorrow_ & DEFAULT_EXPONENT_MASK);

        uint256 totalBorrowRaw_ = (totalAmounts_ >> LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_BORROW_WITH_INTEREST) & X64;
        totalBorrowRaw_ = (totalBorrowRaw_ >> DEFAULT_EXPONENT_SIZE) << (totalBorrowRaw_ & DEFAULT_EXPONENT_MASK);

        // totalBorrow = borrowInterestFree + borrowRawInterest normalized from raw
        totalBorrow_ += ((totalBorrowRaw_ * borrowExchangePrice_) / EXCHANGE_PRICES_PRECISION);
    }
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

// File: contracts/liquidity/common/variables.sol

pragma solidity 0.8.21;

contract ConstantVariables {
    /// @dev Storage slot with the admin of the contract. Logic from "proxy.sol".
    /// This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is validated in the constructor.
    bytes32 internal constant GOVERNANCE_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    uint256 internal constant EXCHANGE_PRICES_PRECISION = 1e12;

    /// @dev address that is mapped to the chain native token
    address internal constant NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    /// @dev decimals for native token
    // !! Double check compatibility with all code if this ever changes for a deployment !!
    uint8 internal constant NATIVE_TOKEN_DECIMALS = 18;

    /// @dev Minimum token decimals for any token that can be listed at Liquidity (inclusive)
    uint8 internal constant MIN_TOKEN_DECIMALS = 6;
    /// @dev Maximum token decimals for any token that can be listed at Liquidity (inclusive)
    uint8 internal constant MAX_TOKEN_DECIMALS = 18;

    /// @dev Ignoring leap years
    uint256 internal constant SECONDS_PER_YEAR = 365 days;

    /// @dev limit any total amount to be half of type(uint128).max (~3.4e38) at type(int128).max (~1.7e38) as safety
    /// measure for any potential overflows / unexpected outcomes. This is checked for total borrow / supply.
    uint256 internal constant MAX_TOKEN_AMOUNT_CAP = uint256(uint128(type(int128).max));

    /// @dev limit for triggering a revert if sent along excess input amount diff is bigger than this percentage (in 1e2)
    uint256 internal constant MAX_INPUT_AMOUNT_EXCESS = 100; // 1%

    /// @dev if this bytes32 is set in the calldata, then token transfers are skipped as long as Liquidity layer is on the winning side.
    bytes32 internal constant SKIP_TRANSFERS = keccak256(bytes("SKIP_TRANSFERS"));

    /// @dev time after which a write to storage of exchangePricesAndConfig will happen always.
    uint256 internal constant FORCE_STORAGE_WRITE_AFTER_TIME = 1 days;

    /// @dev constants used for BigMath conversion from and to storage
    uint256 internal constant SMALL_COEFFICIENT_SIZE = 10;
    uint256 internal constant DEFAULT_COEFFICIENT_SIZE = 56;
    uint256 internal constant DEFAULT_EXPONENT_SIZE = 8;
    uint256 internal constant DEFAULT_EXPONENT_MASK = 0xFF;

    /// @dev constants to increase readability for using bit masks
    uint256 internal constant FOUR_DECIMALS = 1e4;
    uint256 internal constant TWELVE_DECIMALS = 1e12;
    uint256 internal constant X8 = 0xff;
    uint256 internal constant X14 = 0x3fff;
    uint256 internal constant X15 = 0x7fff;
    uint256 internal constant X16 = 0xffff;
    uint256 internal constant X18 = 0x3ffff;
    uint256 internal constant X24 = 0xffffff;
    uint256 internal constant X33 = 0x1ffffffff;
    uint256 internal constant X64 = 0xffffffffffffffff;
}

contract Variables is ConstantVariables {
    /// @dev address of contract that gets sent the revenue. Configurable by governance
    address internal _revenueCollector;

    // 12 bytes empty

    // ----- storage slot 1 ------

    /// @dev paused status: status = 1 -> normal. status = 2 -> paused.
    /// not tightly packed with revenueCollector address to allow for potential changes later that improve gas more
    /// (revenueCollector is only rarely used by admin methods, where optimization is not as important).
    /// to be replaced with transient storage once EIP-1153 Transient storage becomes available with dencun upgrade.
    uint256 internal _status;

    // ----- storage slot 2 ------

    /// @dev Auths can set most config values. E.g. contracts that automate certain flows like e.g. adding a new fToken.
    /// Governance can add/remove auths.
    /// Governance is auth by default
    mapping(address => uint256) internal _isAuth;

    // ----- storage slot 3 ------

    /// @dev Guardians can pause lower class users
    /// Governance can add/remove guardians
    /// Governance is guardian by default
    mapping(address => uint256) internal _isGuardian;

    // ----- storage slot 4 ------

    /// @dev class defines which protocols can be paused by guardians
    /// Currently there are 2 classes: 0 can be paused by guardians. 1 cannot be paused by guardians.
    /// New protocols are added as class 0 and will be upgraded to 1 over time.
    mapping(address => uint256) internal _userClass;

    // ----- storage slot 5 ------

    /// @dev exchange prices and token config per token: token -> exchange prices & config
    /// First 16 bits =>   0- 15 => borrow rate (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next  14 bits =>  16- 29 => fee on interest from borrowers to lenders (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383). configurable.
    /// Next  14 bits =>  30- 43 => last stored utilization (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
    /// Next  14 bits =>  44- 57 => update on storage threshold (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383). configurable.
    /// Next  33 bits =>  58- 90 => last update timestamp (enough until 16 March 2242 -> max value 8589934591)
    /// Next  64 bits =>  91-154 => supply exchange price (1e12 -> max value 18_446_744,073709551615)
    /// Next  64 bits => 155-218 => borrow exchange price (1e12 -> max value 18_446_744,073709551615)
    /// Next   1 bit  => 219-219 => if 0 then ratio is supplyInterestFree / supplyWithInterest else ratio is supplyWithInterest / supplyInterestFree
    /// Next  14 bits => 220-233 => supplyRatio: supplyInterestFree / supplyWithInterest (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
    /// Next   1 bit  => 234-234 => if 0 then ratio is borrowInterestFree / borrowWithInterest else ratio is borrowWithInterest / borrowInterestFree
    /// Next  14 bits => 235-248 => borrowRatio: borrowInterestFree / borrowWithInterest (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
    /// Next   1 bit  => 249-249 => flag for token uses config storage slot 2. (signals SLOAD for additional config slot is needed during execution)
    /// Last   6 bits => 250-255 => empty for future use
    ///                             if more free bits are needed in the future, update on storage threshold bits could be reduced to 7 bits
    ///                             (can plan to add `MAX_TOKEN_CONFIG_UPDATE_THRESHOLD` but need to adjust more bits)
    ///                             if more bits absolutely needed then we can convert fee, utilization, update on storage threshold,
    ///                             supplyRatio & borrowRatio from 14 bits to 10bits (1023 max number) where 1000 = 100% & 1 = 0.1%
    mapping(address => uint256) internal _exchangePricesAndConfig;

    // ----- storage slot 6 ------

    /// @dev Rate related data per token: token -> rate data
    /// READ (SLOAD): all actions; WRITE (SSTORE): only on set config admin actions
    /// token => rate related data
    /// First 4 bits  =>     0-3 => rate version
    /// rest of the bits are rate dependent:

    /// For rate v1 (one kink) ------------------------------------------------------
    /// Next 16  bits =>  4 - 19 => Rate at utilization 0% (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next 16  bits =>  20- 35 => Utilization at kink1 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next 16  bits =>  36- 51 => Rate at utilization kink1 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next 16  bits =>  52- 67 => Rate at utilization 100% (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Last 188 bits =>  68-255 => empty for future use

    /// For rate v2 (two kinks) -----------------------------------------------------
    /// Next 16  bits =>  4 - 19 => Rate at utilization 0% (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next 16  bits =>  20- 35 => Utilization at kink1 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next 16  bits =>  36- 51 => Rate at utilization kink1 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next 16  bits =>  52- 67 => Utilization at kink2 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next 16  bits =>  68- 83 => Rate at utilization kink2 (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next 16  bits =>  84- 99 => Rate at utilization 100% (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Last 156 bits => 100-255 => empty for future use
    mapping(address => uint256) internal _rateData;

    // ----- storage slot 7 ------

    /// @dev total supply / borrow amounts for with / without interest per token: token -> amounts
    /// First  64 bits =>   0- 63 => total supply with interest in raw (totalSupply = totalSupplyRaw * supplyExchangePrice); BigMath: 56 | 8
    /// Next   64 bits =>  64-127 => total interest free supply in normal token amount (totalSupply = totalSupply); BigMath: 56 | 8
    /// Next   64 bits => 128-191 => total borrow with interest in raw (totalBorrow = totalBorrowRaw * borrowExchangePrice); BigMath: 56 | 8
    /// Next   64 bits => 192-255 => total interest free borrow in normal token amount (totalBorrow = totalBorrow); BigMath: 56 | 8
    mapping(address => uint256) internal _totalAmounts;

    // ----- storage slot 8 ------

    /// @dev user supply data per token: user -> token -> data
    /// First  1 bit  =>       0 => mode: user supply with or without interest
    ///                             0 = without, amounts are in normal (i.e. no need to multiply with exchange price)
    ///                             1 = with interest, amounts are in raw (i.e. must multiply with exchange price to get actual token amounts)
    /// Next  64 bits =>   1- 64 => user supply amount (normal or raw depends on 1st bit); BigMath: 56 | 8
    /// Next  64 bits =>  65-128 => previous user withdrawal limit (normal or raw depends on 1st bit); BigMath: 56 | 8
    /// Next  33 bits => 129-161 => last triggered process timestamp (enough until 16 March 2242 -> max value 8589934591)
    /// Next  14 bits => 162-175 => expand withdrawal limit percentage (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383).
    ///                             @dev shrinking is instant
    /// Next  24 bits => 176-199 => withdrawal limit expand duration in seconds.(Max value 16_777_215; ~4_660 hours, ~194 days)
    /// Next  18 bits => 200-217 => base withdrawal limit: below this, 100% withdrawals can be done (normal or raw depends on 1st bit); BigMath: 10 | 8
    /// Next  37 bits => 218-254 => empty for future use
    /// Last     bit  => 255-255 => is user paused (1 = paused, 0 = not paused)
    mapping(address => mapping(address => uint256)) internal _userSupplyData;

    // ----- storage slot 9 ------

    /// @dev user borrow data per token: user -> token -> data
    /// First  1 bit  =>       0 => mode: user borrow with or without interest
    ///                             0 = without, amounts are in normal (i.e. no need to multiply with exchange price)
    ///                             1 = with interest, amounts are in raw (i.e. must multiply with exchange price to get actual token amounts)
    /// Next  64 bits =>   1- 64 => user borrow amount (normal or raw depends on 1st bit); BigMath: 56 | 8
    /// Next  64 bits =>  65-128 => previous user debt ceiling (normal or raw depends on 1st bit); BigMath: 56 | 8
    /// Next  33 bits => 129-161 => last triggered process timestamp (enough until 16 March 2242 -> max value 8589934591)
    /// Next  14 bits => 162-175 => expand debt ceiling percentage (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
    ///                             @dev shrinking is instant
    /// Next  24 bits => 176-199 => debt ceiling expand duration in seconds (Max value 16_777_215; ~4_660 hours, ~194 days)
    /// Next  18 bits => 200-217 => base debt ceiling: below this, there's no debt ceiling limits (normal or raw depends on 1st bit); BigMath: 10 | 8
    /// Next  18 bits => 218-235 => max debt ceiling: absolute maximum debt ceiling can expand to (normal or raw depends on 1st bit); BigMath: 10 | 8
    /// Next  19 bits => 236-254 => empty for future use
    /// Last     bit  => 255-255 => is user paused (1 = paused, 0 = not paused)
    mapping(address => mapping(address => uint256)) internal _userBorrowData;

    // ----- storage slot 10 ------

    /// @dev list of allowed tokens at Liquidity. tokens that are once configured can never be completely removed. so this
    ///      array is append-only.
    address[] internal _listedTokens;

    // ----- storage slot 11 ------

    /// @dev expanded token configs per token: token -> config data slot 2.
    ///      Use of this is signaled by `_exchangePricesAndConfig` bit 249.
    /// First 14 bits =>   0- 13 => max allowed utilization (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383). configurable.
    /// Last 242 bits =>  14-255 => empty for future use
    mapping(address => uint256) internal _configs2;
}

// File: contracts/liquidity/errorTypes.sol

pragma solidity 0.8.21;

library ErrorTypes {
    /***********************************|
    |         Admin Module              | 
    |__________________________________*/

    /// @notice thrown when an input address is zero
    uint256 internal constant AdminModule__AddressZero = 10001;

    /// @notice thrown when msg.sender is not governance
    uint256 internal constant AdminModule__OnlyGovernance = 10002;

    /// @notice thrown when msg.sender is not auth
    uint256 internal constant AdminModule__OnlyAuths = 10003;

    /// @notice thrown when msg.sender is not guardian
    uint256 internal constant AdminModule__OnlyGuardians = 10004;

    /// @notice thrown when base withdrawal limit, base debt limit or max withdrawal limit is sent as 0
    uint256 internal constant AdminModule__LimitZero = 10005;

    /// @notice thrown whenever an invalid input param is given
    uint256 internal constant AdminModule__InvalidParams = 10006;

    /// @notice thrown if user class 1 is paused (can not be paused)
    uint256 internal constant AdminModule__UserNotPausable = 10007;

    /// @notice thrown if user is tried to be unpaused but is not paused in the first place
    uint256 internal constant AdminModule__UserNotPaused = 10008;

    /// @notice thrown if user is not defined yet: Governance didn't yet set any config for this user on a particular token
    uint256 internal constant AdminModule__UserNotDefined = 10009;

    /// @notice thrown if a token is configured in an invalid order:  1. Set rate config for token 2. Set token config 3. allow any user.
    uint256 internal constant AdminModule__InvalidConfigOrder = 10010;

    /// @notice thrown if revenue is collected when revenue collector address is not set
    uint256 internal constant AdminModule__RevenueCollectorNotSet = 10011;

    /// @notice all ValueOverflow errors below are thrown if a certain input param overflows the allowed storage size
    uint256 internal constant AdminModule__ValueOverflow__RATE_AT_UTIL_ZERO = 10012;
    uint256 internal constant AdminModule__ValueOverflow__RATE_AT_UTIL_KINK = 10013;
    uint256 internal constant AdminModule__ValueOverflow__RATE_AT_UTIL_MAX = 10014;
    uint256 internal constant AdminModule__ValueOverflow__RATE_AT_UTIL_KINK1 = 10015;
    uint256 internal constant AdminModule__ValueOverflow__RATE_AT_UTIL_KINK2 = 10016;
    uint256 internal constant AdminModule__ValueOverflow__RATE_AT_UTIL_MAX_V2 = 10017;
    uint256 internal constant AdminModule__ValueOverflow__FEE = 10018;
    uint256 internal constant AdminModule__ValueOverflow__THRESHOLD = 10019;
    uint256 internal constant AdminModule__ValueOverflow__EXPAND_PERCENT = 10020;
    uint256 internal constant AdminModule__ValueOverflow__EXPAND_DURATION = 10021;
    uint256 internal constant AdminModule__ValueOverflow__EXPAND_PERCENT_BORROW = 10022;
    uint256 internal constant AdminModule__ValueOverflow__EXPAND_DURATION_BORROW = 10023;
    uint256 internal constant AdminModule__ValueOverflow__EXCHANGE_PRICES = 10024;
    uint256 internal constant AdminModule__ValueOverflow__UTILIZATION = 10025;

    /// @notice thrown when an address is not a contract
    uint256 internal constant AdminModule__AddressNotAContract = 10026;

    uint256 internal constant AdminModule__ValueOverflow__MAX_UTILIZATION = 10027;

    /// @notice thrown if a token that is being listed has not between 6 and 18 decimals
    uint256 internal constant AdminModule__TokenInvalidDecimalsRange = 10028;

    /***********************************|
    |          User Module              | 
    |__________________________________*/

    /// @notice thrown when user operations are paused for an interacted token
    uint256 internal constant UserModule__UserNotDefined = 11001;

    /// @notice thrown when user operations are paused for an interacted token
    uint256 internal constant UserModule__UserPaused = 11002;

    /// @notice thrown when user's try to withdraw below withdrawal limit
    uint256 internal constant UserModule__WithdrawalLimitReached = 11003;

    /// @notice thrown when user's try to borrow above borrow limit
    uint256 internal constant UserModule__BorrowLimitReached = 11004;

    /// @notice thrown when user sent supply/withdraw and borrow/payback both as 0
    uint256 internal constant UserModule__OperateAmountsZero = 11005;

    /// @notice thrown when user sent supply/withdraw or borrow/payback both as bigger than 2**128
    uint256 internal constant UserModule__OperateAmountOutOfBounds = 11006;

    /// @notice thrown when the operate amount for supply / withdraw / borrow / payback is below the minimum amount
    /// that would cause a storage difference after BigMath & rounding imprecision. Extremely unlikely to ever happen
    /// for all normal use-cases.
    uint256 internal constant UserModule__OperateAmountInsufficient = 11007;

    /// @notice thrown when withdraw or borrow is executed but withdrawTo or borrowTo is the zero address
    uint256 internal constant UserModule__ReceiverNotDefined = 11008;

    /// @notice thrown when user did send excess or insufficient amount (beyond rounding issues)
    uint256 internal constant UserModule__TransferAmountOutOfBounds = 11009;

    /// @notice thrown when user sent msg.value along for an operation not for the native token
    uint256 internal constant UserModule__MsgValueForNonNativeToken = 11010;

    /// @notice thrown when a borrow operation is done when utilization is above 100%
    uint256 internal constant UserModule__MaxUtilizationReached = 11011;

    /// @notice all ValueOverflow errors below are thrown if a certain input param or calc result overflows the allowed storage size
    uint256 internal constant UserModule__ValueOverflow__EXCHANGE_PRICES = 11012;
    uint256 internal constant UserModule__ValueOverflow__UTILIZATION = 11013;
    uint256 internal constant UserModule__ValueOverflow__TOTAL_SUPPLY = 11014;
    uint256 internal constant UserModule__ValueOverflow__TOTAL_BORROW = 11015;

    /// @notice thrown when SKIP_TRANSFERS is set but the input params are invalid for skipping transfers
    uint256 internal constant UserModule__SkipTransfersInvalid = 11016;

    /***********************************|
    |         LiquidityHelpers          | 
    |__________________________________*/

    /// @notice thrown when a reentrancy happens
    uint256 internal constant LiquidityHelpers__Reentrancy = 12001;
}

// File: contracts/liquidity/error.sol

pragma solidity 0.8.21;

contract Error {
    error FluidLiquidityError(uint256 errorId_);
}

// File: contracts/liquidity/common/helpers.sol

pragma solidity 0.8.21;





/// @dev ReentrancyGuard based on OpenZeppelin implementation.
/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.8/contracts/security/ReentrancyGuard.sol
abstract contract ReentrancyGuard is Variables, Error {
    uint8 internal constant REENTRANCY_NOT_ENTERED = 1;
    uint8 internal constant REENTRANCY_ENTERED = 2;

    constructor() {
        // on logic contracts, switch reentrancy to entered so no call is possible (forces delegatecall)
        _status = REENTRANCY_ENTERED; 
    }

    /// @dev Prevents a contract from calling itself, directly or indirectly.
    /// See OpenZeppelin implementation for more info
    modifier reentrancy() {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == REENTRANCY_ENTERED) {
            revert FluidLiquidityError(ErrorTypes.LiquidityHelpers__Reentrancy);
        }

        // Any calls to nonReentrant after this point will fail
        _status = REENTRANCY_ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = REENTRANCY_NOT_ENTERED;
    }
}

abstract contract CommonHelpers is ReentrancyGuard {
    /// @dev Returns the current admin (governance).
    function _getGovernanceAddr() internal view returns (address governance_) {
        assembly {
            governance_ := sload(GOVERNANCE_SLOT)
        }
    }
}

// File: contracts/liquidity/userModule/events.sol

pragma solidity 0.8.21;

contract Events {
    /// @notice emitted on any `operate()` execution: deposit / supply / withdraw / borrow.
    /// includes info related to the executed operation, new total amounts (packed uint256 of BigMath numbers as in storage)
    /// and exchange prices (packed uint256 as in storage).
    /// @param user protocol that triggered this operation (e.g. via an fToken or via Vault protocol)
    /// @param token token address for which this operation was executed
    /// @param supplyAmount supply amount for the operation. if >0 then a deposit happened, if <0 then a withdrawal happened.
    ///                     if 0 then nothing.
    /// @param borrowAmount borrow amount for the operation. if >0 then a borrow happened, if <0 then a payback happened.
    ///                     if 0 then nothing.
    /// @param withdrawTo   address that funds where withdrawn to (if supplyAmount <0)
    /// @param borrowTo     address that funds where borrowed to (if borrowAmount >0)
    /// @param totalAmounts updated total amounts, stacked uint256 as written to storage:
    /// First  64 bits =>   0- 63 => total supply with interest in raw (totalSupply = totalSupplyRaw * supplyExchangePrice); BigMath: 56 | 8
    /// Next   64 bits =>  64-127 => total interest free supply in normal token amount (totalSupply = totalSupply); BigMath: 56 | 8
    /// Next   64 bits => 128-191 => total borrow with interest in raw (totalBorrow = totalBorrowRaw * borrowExchangePrice); BigMath: 56 | 8
    /// Next   64 bits => 192-255 => total interest free borrow in normal token amount (totalBorrow = totalBorrow); BigMath: 56 | 8
    /// @param exchangePricesAndConfig updated exchange prices and configs storage slot. Contains updated supply & borrow exchange price:
    /// First 16 bits =>   0- 15 => borrow rate (in 1e2: 100% = 10_000; 1% = 100 -> max value 65535)
    /// Next  14 bits =>  16- 29 => fee on interest from borrowers to lenders (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383). configurable.
    /// Next  14 bits =>  30- 43 => last stored utilization (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
    /// Next  14 bits =>  44- 57 => update on storage threshold (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383). configurable.
    /// Next  33 bits =>  58- 90 => last update timestamp (enough until 16 March 2242 -> max value 8589934591)
    /// Next  64 bits =>  91-154 => supply exchange price (1e12 -> max value 18_446_744,073709551615)
    /// Next  64 bits => 155-218 => borrow exchange price (1e12 -> max value 18_446_744,073709551615)
    /// Next   1 bit  => 219-219 => if 0 then ratio is supplyInterestFree / supplyWithInterest else ratio is supplyWithInterest / supplyInterestFree
    /// Next  14 bits => 220-233 => supplyRatio: supplyInterestFree / supplyWithInterest (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
    /// Next   1 bit  => 234-234 => if 0 then ratio is borrowInterestFree / borrowWithInterest else ratio is borrowWithInterest / borrowInterestFree
    /// Next  14 bits => 235-248 => borrowRatio: borrowInterestFree / borrowWithInterest (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
    event LogOperate(
        address indexed user,
        address indexed token,
        int256 supplyAmount,
        int256 borrowAmount,
        address withdrawTo,
        address borrowTo,
        uint256 totalAmounts,
        uint256 exchangePricesAndConfig
    );
}

// File: contracts/liquidity/userModule/main.sol

pragma solidity 0.8.21;













interface IProtocol {
    function liquidityCallback(address token_, uint256 amount_, bytes calldata data_) external;
}

abstract contract CoreInternals is Error, CommonHelpers, Events {
    using BigMathMinified for uint256;

    /// @dev supply or withdraw for both with interest & interest free.
    /// positive `amount_` is deposit, negative `amount_` is withdraw.
    function _supplyOrWithdraw(
        address token_,
        int256 amount_,
        uint256 supplyExchangePrice_
    ) internal returns (int256 newSupplyInterestRaw_, int256 newSupplyInterestFree_) {
        uint256 userSupplyData_ = _userSupplyData[msg.sender][token_];

        if (userSupplyData_ == 0) {
            revert FluidLiquidityError(ErrorTypes.UserModule__UserNotDefined);
        }
        if ((userSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_IS_PAUSED) & 1 == 1) {
            revert FluidLiquidityError(ErrorTypes.UserModule__UserPaused);
        }

        // extract user supply amount
        uint256 userSupply_ = (userSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_AMOUNT) & X64;
        userSupply_ = (userSupply_ >> DEFAULT_EXPONENT_SIZE) << (userSupply_ & DEFAULT_EXPONENT_MASK);

        // calculate current, updated (expanded etc.) withdrawal limit
        uint256 newWithdrawalLimit_ = LiquidityCalcs.calcWithdrawalLimitBeforeOperate(userSupplyData_, userSupply_);

        // calculate updated user supply amount
        if (userSupplyData_ & 1 == 1) {
            // mode: with interest
            if (amount_ > 0) {
                // convert amount from normal to raw (divide by exchange price) -> round down for deposit
                newSupplyInterestRaw_ = (amount_ * int256(EXCHANGE_PRICES_PRECISION)) / int256(supplyExchangePrice_);
                userSupply_ = userSupply_ + uint256(newSupplyInterestRaw_);
            } else {
                // convert amount from normal to raw (divide by exchange price) -> round up for withdraw
                newSupplyInterestRaw_ = -int256(
                    FixedPointMathLib.mulDivUp(uint256(-amount_), EXCHANGE_PRICES_PRECISION, supplyExchangePrice_)
                );
                // if withdrawal is more than user's supply then solidity will throw here
                userSupply_ = userSupply_ - uint256(-newSupplyInterestRaw_);
            }
        } else {
            // mode: without interest
            newSupplyInterestFree_ = amount_;
            if (newSupplyInterestFree_ > 0) {
                userSupply_ = userSupply_ + uint256(newSupplyInterestFree_);
            } else {
                // if withdrawal is more than user's supply then solidity will throw here
                userSupply_ = userSupply_ - uint256(-newSupplyInterestFree_);
            }
        }

        if (amount_ < 0 && userSupply_ < newWithdrawalLimit_) {
            // if withdraw, then check the user supply after withdrawal is above withdrawal limit
            revert FluidLiquidityError(ErrorTypes.UserModule__WithdrawalLimitReached);
        }

        // calculate withdrawal limit to store as previous withdrawal limit in storage
        newWithdrawalLimit_ = LiquidityCalcs.calcWithdrawalLimitAfterOperate(
            userSupplyData_,
            userSupply_,
            newWithdrawalLimit_
        );

        // Converting user's supply into BigNumber
        userSupply_ = userSupply_.toBigNumber(
            DEFAULT_COEFFICIENT_SIZE,
            DEFAULT_EXPONENT_SIZE,
            BigMathMinified.ROUND_DOWN
        );
        if (((userSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_AMOUNT) & X64) == userSupply_) {
            // make sure that operate amount is not so small that it wouldn't affect storage update. if a difference
            // is present then rounding will be in the right direction to avoid any potential manipulation.
            revert FluidLiquidityError(ErrorTypes.UserModule__OperateAmountInsufficient);
        }

        // Converting withdrawal limit into BigNumber
        newWithdrawalLimit_ = newWithdrawalLimit_.toBigNumber(
            DEFAULT_COEFFICIENT_SIZE,
            DEFAULT_EXPONENT_SIZE,
            BigMathMinified.ROUND_DOWN
        );

        // Updating on storage
        _userSupplyData[msg.sender][token_] =
            // mask to update bits 1-161 (supply amount, withdrawal limit, timestamp)
            (userSupplyData_ & 0xfffffffffffffffffffffffc0000000000000000000000000000000000000001) |
            (userSupply_ << LiquiditySlotsLink.BITS_USER_SUPPLY_AMOUNT) | // converted to BigNumber can not overflow
            (newWithdrawalLimit_ << LiquiditySlotsLink.BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT) | // converted to BigNumber can not overflow
            (block.timestamp << LiquiditySlotsLink.BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP);
    }

    /// @dev borrow or payback for both with interest & interest free.
    /// positive `amount_` is borrow, negative `amount_` is payback.
    function _borrowOrPayback(
        address token_,
        int256 amount_,
        uint256 borrowExchangePrice_
    ) internal returns (int256 newBorrowInterestRaw_, int256 newBorrowInterestFree_) {
        uint256 userBorrowData_ = _userBorrowData[msg.sender][token_];

        if (userBorrowData_ == 0) {
            revert FluidLiquidityError(ErrorTypes.UserModule__UserNotDefined);
        }
        if ((userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_IS_PAUSED) & 1 == 1) {
            revert FluidLiquidityError(ErrorTypes.UserModule__UserPaused);
        }

        // extract user borrow amount
        uint256 userBorrow_ = (userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_AMOUNT) & X64;
        userBorrow_ = (userBorrow_ >> DEFAULT_EXPONENT_SIZE) << (userBorrow_ & DEFAULT_EXPONENT_MASK);

        // calculate current, updated (expanded etc.) borrow limit
        uint256 newBorrowLimit_ = LiquidityCalcs.calcBorrowLimitBeforeOperate(userBorrowData_, userBorrow_);

        // calculate updated user borrow amount
        if (userBorrowData_ & 1 == 1) {
            // with interest
            if (amount_ > 0) {
                // convert amount normal to raw (divide by exchange price) -> round up for borrow
                newBorrowInterestRaw_ = int256(
                    FixedPointMathLib.mulDivUp(uint256(amount_), EXCHANGE_PRICES_PRECISION, borrowExchangePrice_)
                );
                userBorrow_ = userBorrow_ + uint256(newBorrowInterestRaw_);
            } else {
                // convert amount from normal to raw (divide by exchange price) -> round down for payback
                newBorrowInterestRaw_ = (amount_ * int256(EXCHANGE_PRICES_PRECISION)) / int256(borrowExchangePrice_);
                userBorrow_ = userBorrow_ - uint256(-newBorrowInterestRaw_);
            }
        } else {
            // without interest
            newBorrowInterestFree_ = amount_;
            if (newBorrowInterestFree_ > 0) {
                // borrowing
                userBorrow_ = userBorrow_ + uint256(newBorrowInterestFree_);
            } else {
                // payback
                userBorrow_ = userBorrow_ - uint256(-newBorrowInterestFree_);
            }
        }

        if (amount_ > 0 && userBorrow_ > newBorrowLimit_) {
            // if borrow, then check the user borrow amount after borrowing is below borrow limit
            revert FluidLiquidityError(ErrorTypes.UserModule__BorrowLimitReached);
        }

        // calculate borrow limit to store as previous borrow limit in storage
        newBorrowLimit_ = LiquidityCalcs.calcBorrowLimitAfterOperate(userBorrowData_, userBorrow_, newBorrowLimit_);

        // Converting user's borrowings into bignumber
        userBorrow_ = userBorrow_.toBigNumber(
            DEFAULT_COEFFICIENT_SIZE,
            DEFAULT_EXPONENT_SIZE,
            BigMathMinified.ROUND_UP
        );

        if (((userBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_AMOUNT) & X64) == userBorrow_) {
            // make sure that operate amount is not so small that it wouldn't affect storage update. if a difference
            // is present then rounding will be in the right direction to avoid any potential manipulation.
            revert FluidLiquidityError(ErrorTypes.UserModule__OperateAmountInsufficient);
        }

        // Converting borrow limit into bignumber
        newBorrowLimit_ = newBorrowLimit_.toBigNumber(
            DEFAULT_COEFFICIENT_SIZE,
            DEFAULT_EXPONENT_SIZE,
            BigMathMinified.ROUND_DOWN
        );

        // Updating on storage
        _userBorrowData[msg.sender][token_] =
            // mask to update bits 1-161 (borrow amount, borrow limit, timestamp)
            (userBorrowData_ & 0xfffffffffffffffffffffffc0000000000000000000000000000000000000001) |
            (userBorrow_ << LiquiditySlotsLink.BITS_USER_BORROW_AMOUNT) | // converted to BigNumber can not overflow
            (newBorrowLimit_ << LiquiditySlotsLink.BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT) | // converted to BigNumber can not overflow
            (block.timestamp << LiquiditySlotsLink.BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP);
    }

    /// @dev checks if `supplyAmount_` & `borrowAmount_` amounts transfers can be skipped (DEX-protocol use-case).
    /// -   Requirements:
    /// -  ` callbackData_` MUST be encoded so that "from" address is the last 20 bytes in the last 32 bytes slot,
    ///     also for native token operations where liquidityCallback is not triggered!
    ///     from address must come at last position if there is more data. I.e. encode like:
    ///     abi.encode(otherVar1, otherVar2, FROM_ADDRESS). Note dynamic types used with abi.encode come at the end
    ///     so if dynamic types are needed, you must use abi.encodePacked to ensure the from address is at the end.
    /// -   this "from" address must match withdrawTo_ or borrowTo_ and must be == `msg.sender`
    /// -   `callbackData_` must in addition to the from address as described above include bytes32 SKIP_TRANSFERS
    ///     in the slot before (bytes 32 to 63)
    /// -   `msg.value` must be 0.
    /// -   Amounts must be either:
    ///     -  supply(+) == borrow(+), withdraw(-) == payback(-).
    ///     -  Liquidity must be on the winning side (deposit < borrow OR payback < withdraw).
    function _isInOutBalancedOut(
        int256 supplyAmount_,
        int256 borrowAmount_,
        address withdrawTo_,
        address borrowTo_,
        bytes memory callbackData_
    ) internal view returns (bool) {
        // callbackData_ being at least > 63 in length is already verified before calling this method.

        // 1. SKIP_TRANSFERS must be set in callbackData_ 32 bytes before last 32 bytes
        bytes32 skipTransfers_;
        assembly {
            skipTransfers_ := mload(
                add(
                    // add padding for length as present for dynamic arrays in memory
                    add(callbackData_, 32),
                    // Load from memory offset of 2 slots (64 bytes): 1 slot: bytes32 skipTransfers_ + 2 slot: address inFrom_
                    sub(mload(callbackData_), 64)
                )
            )
        }
        if (skipTransfers_ != SKIP_TRANSFERS) {
            return false;
        }
        // after here, if invalid, protocol intended to skip transfers, but something is invalid. so we don't just
        // NOT skip transfers, we actually revert because there must be something wrong on protocol side.

        // 2. amounts must be
        // a) equal: supply(+) == borrow(+), withdraw(-) == payback(-) OR
        // b) Liquidity must be on the winning side.
        // EITHER:
        // deposit and borrow, both positive. there must be more borrow than deposit.
        // so supply amount must be less, e.g. 80 deposit and 100 borrow.
        // OR:
        // withdraw and payback, both negative. there must be more withdraw than payback.
        // so supplyAmount must be less (e.g. -100 withdraw and -80 payback )
        if (
            msg.value != 0 || // no msg.value should be sent along when trying to skip transfers.
            supplyAmount_ == 0 ||
            borrowAmount_ == 0 || // it must be a 2 actions operation, not just e.g. only deposit or only payback.
            supplyAmount_ > borrowAmount_ // allow case a) and b): supplyAmount must be <=
        ) {
            revert FluidLiquidityError(ErrorTypes.UserModule__SkipTransfersInvalid);
        }

        // 3. inFrom_ must be in last 32 bytes and must match receiver
        address inFrom_;
        assembly {
            inFrom_ := mload(
                add(
                    // add padding for length as present for dynamic arrays in memory
                    add(callbackData_, 32),
                    // assembly expects address with leading zeros / left padded so need to use 32 as length here
                    sub(mload(callbackData_), 32)
                )
            )
        }

        if (supplyAmount_ > 0) {
            // deposit and borrow
            if (!(inFrom_ == borrowTo_ && inFrom_ == msg.sender)) {
                revert FluidLiquidityError(ErrorTypes.UserModule__SkipTransfersInvalid);
            }
        } else {
            // withdraw and payback
            if (!(inFrom_ == withdrawTo_ && inFrom_ == msg.sender)) {
                revert FluidLiquidityError(ErrorTypes.UserModule__SkipTransfersInvalid);
            }
        }

        return true;
    }
}

interface IZtakingPool {
    ///@notice Stake a specified amount of a particular supported token into the Ztaking Pool
    ///@param _token The token to deposit/stake in the Ztaking Pool
    ///@param _for The user to deposit/stake on behalf of
    ///@param _amount The amount of token to deposit/stake into the Ztaking Pool
    function depositFor(address _token, address _for, uint256 _amount) external;

    ///@notice Withdraw a specified amount of a particular supported token previously staked into the Ztaking Pool
    ///@param _token The token to withdraw from the Ztaking Pool
    ///@param _amount The amount of token to withdraw from the Ztaking Pool
    function withdraw(address _token, uint256 _amount) external;
}

/// @title  Fluid Liquidity UserModule
/// @notice Fluid Liquidity public facing endpoint logic contract that implements the `operate()` method.
///         operate can be used to deposit, withdraw, borrow & payback funds, given that they have the necessary
///         user config allowance. Interacting users must be allowed via the Fluid Liquidity AdminModule first.
///         Intended users are thus allow-listed protocols, e.g. the Lending protocol (fTokens), Vault protocol etc.
/// @dev For view methods / accessing data, use the "LiquidityResolver" periphery contract.
contract FluidLiquidityUserModule is CoreInternals {
    using BigMathMinified for uint256;

    address private constant WEETH = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;
    address private constant WEETHS = 0x917ceE801a67f933F2e6b33fC0cD1ED2d5909D88;
    IZtakingPool private constant ZIRCUIT = IZtakingPool(0xF047ab4c75cebf0eB9ed34Ae2c186f3611aEAfa6);

    /// @dev struct for vars used in operate() that would otherwise cause a Stack too deep error
    struct OperateMemoryVars {
        bool skipTransfers;
        uint256 supplyExchangePrice;
        uint256 borrowExchangePrice;
        uint256 supplyRawInterest;
        uint256 supplyInterestFree;
        uint256 borrowRawInterest;
        uint256 borrowInterestFree;
        uint256 totalAmounts;
        uint256 exchangePricesAndConfig;
    }

    /// @notice inheritdoc IFluidLiquidity
    function operate(
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_,
        address withdrawTo_,
        address borrowTo_,
        bytes calldata callbackData_
    ) external payable reentrancy returns (uint256 memVar3_, uint256 memVar4_) {
        if (supplyAmount_ == 0 && borrowAmount_ == 0) {
            revert FluidLiquidityError(ErrorTypes.UserModule__OperateAmountsZero);
        }
        if (
            supplyAmount_ < type(int128).min ||
            supplyAmount_ > type(int128).max ||
            borrowAmount_ < type(int128).min ||
            borrowAmount_ > type(int128).max
        ) {
            revert FluidLiquidityError(ErrorTypes.UserModule__OperateAmountOutOfBounds);
        }
        if ((supplyAmount_ < 0 && withdrawTo_ == address(0)) || (borrowAmount_ > 0 && borrowTo_ == address(0))) {
            revert FluidLiquidityError(ErrorTypes.UserModule__ReceiverNotDefined);
        }
        if (token_ != NATIVE_TOKEN_ADDRESS && msg.value > 0) {
            // revert: there should not be msg.value if the token is not the native token
            revert FluidLiquidityError(ErrorTypes.UserModule__MsgValueForNonNativeToken);
        }

        OperateMemoryVars memory o_;

        // @dev temporary memory variables used as helper in between to avoid assigning new memory variables
        uint256 memVar_;
        // memVar2_ => operateAmountIn: deposit + payback
        uint256 memVar2_ = uint256((supplyAmount_ > 0 ? supplyAmount_ : int256(0))) +
            uint256((borrowAmount_ < 0 ? -borrowAmount_ : int256(0)));

        // check if token transfers can be skipped. see `_isInOutBalancedOut` for details.
        if (
            callbackData_.length > 63 &&
            _isInOutBalancedOut(supplyAmount_, borrowAmount_, withdrawTo_, borrowTo_, callbackData_)
        ) {
            memVar2_ = 0; // set to 0 to skip transfers IN
            o_.skipTransfers = true; // set flag to true to skip transfers OUT
        }
        if (token_ == NATIVE_TOKEN_ADDRESS) {
            unchecked {
                // check supply and payback amount is covered by available sent msg.value and
                // protection that msg.value is not unintentionally way more than actually used in operate()
                if (
                    memVar2_ > msg.value ||
                    msg.value > (memVar2_ * (FOUR_DECIMALS + MAX_INPUT_AMOUNT_EXCESS)) / FOUR_DECIMALS
                ) {
                    revert FluidLiquidityError(ErrorTypes.UserModule__TransferAmountOutOfBounds);
                }
            }
            memVar2_ = 0; // set to 0 to skip transfers IN more gas efficient. No need for native token.
        }
        // if supply or payback or both -> transfer token amount from sender to here.
        // for native token this is already covered by msg.value checks in operate(). memVar2_ is set to 0
        // for same amounts in same operate(): supply(+) == borrow(+), withdraw(-) == payback(-). memVar2_ is set to 0
        if (memVar2_ > 0) {
            // memVar_ => initial token balance of this contract
            memVar_ = IERC20(token_).balanceOf(address(this));
            // trigger protocol to send token amount and pass callback data
            IProtocol(msg.sender).liquidityCallback(token_, memVar2_, callbackData_);
            // memVar_ => current token balance of this contract - initial balance
            memVar_ = IERC20(token_).balanceOf(address(this)) - memVar_;
            unchecked {
                if (
                    memVar_ < memVar2_ ||
                    memVar_ > (memVar2_ * (FOUR_DECIMALS + MAX_INPUT_AMOUNT_EXCESS)) / FOUR_DECIMALS
                ) {
                    // revert if protocol did not send enough to cover supply / payback
                    // or if protocol sent more than expected, with 1% tolerance for any potential rounding issues (and for DEX revenue cut)
                    revert FluidLiquidityError(ErrorTypes.UserModule__TransferAmountOutOfBounds);
                }
            }

            // ---------- temporary code start -----------------------
            // temporary addition for weETH & weETHs: if token is weETH or weETHs -> deposit to Zircuit
            if (token_ == WEETH) {
                if (IERC20(WEETH).allowance(address(this), address(ZIRCUIT)) > 0) {
                    ZIRCUIT.depositFor(WEETH, address(this), memVar_);
                }
            } else if (token_ == WEETHS) {
                if ((IERC20(WEETHS).allowance(address(this), address(ZIRCUIT)) > 0)) {
                    ZIRCUIT.depositFor(WEETHS, address(this), memVar_);
                }
            }
            // temporary code also includes: WEETH, WEETHS & ZIRCUIT constant, IZtakingPool interface
            // ---------- temporary code end -----------------------
        }

        o_.exchangePricesAndConfig = _exchangePricesAndConfig[token_];

        // calculate updated exchange prices
        (o_.supplyExchangePrice, o_.borrowExchangePrice) = LiquidityCalcs.calcExchangePrices(
            o_.exchangePricesAndConfig
        );

        // Extract total supply / borrow amounts for the token
        o_.totalAmounts = _totalAmounts[token_];
        memVar_ = o_.totalAmounts & X64;
        o_.supplyRawInterest = (memVar_ >> DEFAULT_EXPONENT_SIZE) << (memVar_ & DEFAULT_EXPONENT_MASK);
        memVar_ = (o_.totalAmounts >> LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_SUPPLY_INTEREST_FREE) & X64;
        o_.supplyInterestFree = (memVar_ >> DEFAULT_EXPONENT_SIZE) << (memVar_ & DEFAULT_EXPONENT_MASK);
        memVar_ = (o_.totalAmounts >> LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_BORROW_WITH_INTEREST) & X64;
        o_.borrowRawInterest = (memVar_ >> DEFAULT_EXPONENT_SIZE) << (memVar_ & DEFAULT_EXPONENT_MASK);
        // no & mask needed for borrow interest free as it occupies the last bits in the storage slot
        memVar_ = (o_.totalAmounts >> LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_BORROW_INTEREST_FREE);
        o_.borrowInterestFree = (memVar_ >> DEFAULT_EXPONENT_SIZE) << (memVar_ & DEFAULT_EXPONENT_MASK);

        if (supplyAmount_ != 0) {
            // execute supply or withdraw and update total amounts
            {
                uint256 totalAmountsBefore_ = o_.totalAmounts;
                (int256 newSupplyInterestRaw_, int256 newSupplyInterestFree_) = _supplyOrWithdraw(
                    token_,
                    supplyAmount_,
                    o_.supplyExchangePrice
                );
                // update total amounts. this is done here so that values are only written to storage once
                // if a borrow / payback also happens in the same `operate()` call
                if (newSupplyInterestFree_ == 0) {
                    // Note newSupplyInterestFree_ can ONLY be 0 if mode is with interest,
                    // easy to check as that variable is NOT the result of a dvision etc.
                    // supply or withdraw with interest -> raw amount
                    if (newSupplyInterestRaw_ > 0) {
                        o_.supplyRawInterest += uint256(newSupplyInterestRaw_);
                    } else {
                        unchecked {
                            o_.supplyRawInterest = o_.supplyRawInterest > uint256(-newSupplyInterestRaw_)
                                ? o_.supplyRawInterest - uint256(-newSupplyInterestRaw_)
                                : 0; // withdraw amount is > total supply -> withdraw total supply down to 0
                            // Note no risk here as if the user withdraws more than supplied it would revert already
                            // earlier. Total amounts can end up < sum of user amounts because of rounding
                        }
                    }

                    // Note check for revert {UserModule}__ValueOverflow__TOTAL_SUPPLY is further down when we anyway
                    // calculate the normal amount from raw

                    // Converting the updated total amount into big number for storage
                    memVar_ = o_.supplyRawInterest.toBigNumber(
                        DEFAULT_COEFFICIENT_SIZE,
                        DEFAULT_EXPONENT_SIZE,
                        BigMathMinified.ROUND_DOWN
                    );
                    // update total supply with interest at total amounts in storage (only update changed values)
                    o_.totalAmounts =
                        // mask to update bits 0-63
                        (o_.totalAmounts & 0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000) |
                        memVar_; // converted to BigNumber can not overflow
                } else {
                    // supply or withdraw interest free -> normal amount
                    if (newSupplyInterestFree_ > 0) {
                        o_.supplyInterestFree += uint256(newSupplyInterestFree_);
                    } else {
                        unchecked {
                            o_.supplyInterestFree = o_.supplyInterestFree > uint256(-newSupplyInterestFree_)
                                ? o_.supplyInterestFree - uint256(-newSupplyInterestFree_)
                                : 0; // withdraw amount is > total supply -> withdraw total supply down to 0
                            // Note no risk here as if the user withdraws more than supplied it would revert already
                            // earlier. Total amounts can end up < sum of user amounts because of rounding
                        }
                    }
                    if (o_.supplyInterestFree > MAX_TOKEN_AMOUNT_CAP) {
                        // only withdrawals allowed if total supply interest free reaches MAX_TOKEN_AMOUNT_CAP
                        revert FluidLiquidityError(ErrorTypes.UserModule__ValueOverflow__TOTAL_SUPPLY);
                    }
                    // Converting the updated total amount into big number for storage
                    memVar_ = o_.supplyInterestFree.toBigNumber(
                        DEFAULT_COEFFICIENT_SIZE,
                        DEFAULT_EXPONENT_SIZE,
                        BigMathMinified.ROUND_DOWN
                    );
                    // update total supply interest free at total amounts in storage (only update changed values)
                    o_.totalAmounts =
                        // mask to update bits 64-127
                        (o_.totalAmounts & 0xffffffffffffffffffffffffffffffff0000000000000000ffffffffffffffff) |
                        (memVar_ << LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_SUPPLY_INTEREST_FREE); // converted to BigNumber can not overflow
                }
                if (totalAmountsBefore_ == o_.totalAmounts) {
                    // make sure that operate amount is not so small that it wouldn't affect storage update. if a difference
                    // is present then rounding will be in the right direction to avoid any potential manipulation.
                    revert FluidLiquidityError(ErrorTypes.UserModule__OperateAmountInsufficient);
                }
            }
        }
        if (borrowAmount_ != 0) {
            // execute borrow or payback and update total amounts
            {
                uint256 totalAmountsBefore_ = o_.totalAmounts;
                (int256 newBorrowInterestRaw_, int256 newBorrowInterestFree_) = _borrowOrPayback(
                    token_,
                    borrowAmount_,
                    o_.borrowExchangePrice
                );
                // update total amounts. this is done here so that values are only written to storage once
                // if a supply / withdraw also happens in the same `operate()` call
                if (newBorrowInterestFree_ == 0) {
                    // Note newBorrowInterestFree_ can ONLY be 0 if mode is with interest,
                    // easy to check as that variable is NOT the result of a dvision etc.
                    // borrow or payback with interest -> raw amount
                    if (newBorrowInterestRaw_ > 0) {
                        o_.borrowRawInterest += uint256(newBorrowInterestRaw_);
                    } else {
                        unchecked {
                            o_.borrowRawInterest = o_.borrowRawInterest > uint256(-newBorrowInterestRaw_)
                                ? o_.borrowRawInterest - uint256(-newBorrowInterestRaw_)
                                : 0; // payback amount is > total borrow -> payback total borrow down to 0
                        }
                    }

                    // Note check for revert UserModule__ValueOverflow__TOTAL_BORROW is further down when we anyway
                    // calculate the normal amount from raw

                    // Converting the updated total amount into big number for storage
                    memVar_ = o_.borrowRawInterest.toBigNumber(
                        DEFAULT_COEFFICIENT_SIZE,
                        DEFAULT_EXPONENT_SIZE,
                        BigMathMinified.ROUND_UP
                    );
                    // update total borrow with interest at total amounts in storage (only update changed values)
                    o_.totalAmounts =
                        // mask to update bits 128-191
                        (o_.totalAmounts & 0xffffffffffffffff0000000000000000ffffffffffffffffffffffffffffffff) |
                        (memVar_ << LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_BORROW_WITH_INTEREST); // converted to BigNumber can not overflow
                } else {
                    // borrow or payback interest free -> normal amount
                    if (newBorrowInterestFree_ > 0) {
                        o_.borrowInterestFree += uint256(newBorrowInterestFree_);
                    } else {
                        unchecked {
                            o_.borrowInterestFree = o_.borrowInterestFree > uint256(-newBorrowInterestFree_)
                                ? o_.borrowInterestFree - uint256(-newBorrowInterestFree_)
                                : 0; // payback amount is > total borrow -> payback total borrow down to 0
                        }
                    }
                    if (o_.borrowInterestFree > MAX_TOKEN_AMOUNT_CAP) {
                        // only payback allowed if total borrow interest free reaches MAX_TOKEN_AMOUNT_CAP
                        revert FluidLiquidityError(ErrorTypes.UserModule__ValueOverflow__TOTAL_BORROW);
                    }
                    // Converting the updated total amount into big number for storage
                    memVar_ = o_.borrowInterestFree.toBigNumber(
                        DEFAULT_COEFFICIENT_SIZE,
                        DEFAULT_EXPONENT_SIZE,
                        BigMathMinified.ROUND_UP
                    );
                    // update total borrow interest free at total amounts in storage (only update changed values)
                    o_.totalAmounts =
                        // mask to update bits 192-255
                        (o_.totalAmounts & 0x0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff) |
                        (memVar_ << LiquiditySlotsLink.BITS_TOTAL_AMOUNTS_BORROW_INTEREST_FREE); // converted to BigNumber can not overflow
                }
                if (totalAmountsBefore_ == o_.totalAmounts) {
                    // make sure that operate amount is not so small that it wouldn't affect storage update. if a difference
                    // is present then rounding will be in the right direction to avoid any potential manipulation.
                    revert FluidLiquidityError(ErrorTypes.UserModule__OperateAmountInsufficient);
                }
            }
        }
        // Updating total amounts on storage
        _totalAmounts[token_] = o_.totalAmounts;
        {
            // update exchange prices / utilization / ratios
            // exchangePricesAndConfig is only written to storage if either utilization, supplyRatio or borrowRatio
            // change is above the required storageUpdateThreshold config value or if the last write was > 1 day ago.

            // 1. calculate new supply ratio, borrow ratio & utilization.
            // 2. check if last storage write was > 1 day ago.
            // 3. If false -> check if utilization is above update threshold
            // 4. If false -> check if supply ratio is above update threshold
            // 5. If false -> check if borrow ratio is above update threshold
            // 6. If any true, then update on storage

            // ########## calculating supply ratio ##########
            // supplyWithInterest in normal amount
            memVar3_ = ((o_.supplyRawInterest * o_.supplyExchangePrice) / EXCHANGE_PRICES_PRECISION);
            if (memVar3_ > MAX_TOKEN_AMOUNT_CAP && supplyAmount_ > 0) {
                // only withdrawals allowed if total supply raw reaches MAX_TOKEN_AMOUNT_CAP
                revert FluidLiquidityError(ErrorTypes.UserModule__ValueOverflow__TOTAL_SUPPLY);
            }
            // memVar_ => total supply. set here so supplyWithInterest (memVar3_) is only calculated once. For utilization
            memVar_ = o_.supplyInterestFree + memVar3_;
            if (memVar3_ > o_.supplyInterestFree) {
                // memVar3_ is ratio with 1 bit as 0 as supply interest raw is bigger
                memVar3_ = ((o_.supplyInterestFree * FOUR_DECIMALS) / memVar3_) << 1;
                // because of checking to divide by bigger amount, ratio can never be > 100%
            } else if (memVar3_ < o_.supplyInterestFree) {
                // memVar3_ is ratio with 1 bit as 1 as supply interest free is bigger
                memVar3_ = (((memVar3_ * FOUR_DECIMALS) / o_.supplyInterestFree) << 1) | 1;
                // because of checking to divide by bigger amount, ratio can never be > 100%
            } else if (memVar_ > 0) {
                // supplies match exactly (memVar3_  == o_.supplyInterestFree) and total supplies are not 0
                // -> set ratio to 1 (with first bit set to 0, doesn't matter)
                memVar3_ = FOUR_DECIMALS << 1;
            } // else if total supply = 0, memVar3_ (supplyRatio) is already 0.

            // ########## calculating borrow ratio ##########
            // borrowWithInterest in normal amount
            memVar4_ = ((o_.borrowRawInterest * o_.borrowExchangePrice) / EXCHANGE_PRICES_PRECISION);
            if (memVar4_ > MAX_TOKEN_AMOUNT_CAP && borrowAmount_ > 0) {
                // only payback allowed if total borrow raw reaches MAX_TOKEN_AMOUNT_CAP
                revert FluidLiquidityError(ErrorTypes.UserModule__ValueOverflow__TOTAL_BORROW);
            }
            // memVar2_ => total borrow. set here so borrowWithInterest (memVar4_) is only calculated once. For utilization
            memVar2_ = o_.borrowInterestFree + memVar4_;
            if (memVar4_ > o_.borrowInterestFree) {
                // memVar4_ is ratio with 1 bit as 0 as borrow interest raw is bigger
                memVar4_ = ((o_.borrowInterestFree * FOUR_DECIMALS) / memVar4_) << 1;
                // because of checking to divide by bigger amount, ratio can never be > 100%
            } else if (memVar4_ < o_.borrowInterestFree) {
                // memVar4_ is ratio with 1 bit as 1 as borrow interest free is bigger
                memVar4_ = (((memVar4_ * FOUR_DECIMALS) / o_.borrowInterestFree) << 1) | 1;
                // because of checking to divide by bigger amount, ratio can never be > 100%
            } else if (memVar2_ > 0) {
                // borrows match exactly (memVar4_  == o_.borrowInterestFree) and total borrows are not 0
                // -> set ratio to 1 (with first bit set to 0, doesn't matter)
                memVar4_ = FOUR_DECIMALS << 1;
            } // else if total borrow = 0, memVar4_ (borrowRatio) is already 0.

            // calculate utilization. If there is no supply, utilization must be 0 (avoid division by 0)
            uint256 utilization_;
            if (memVar_ > 0) {
                utilization_ = ((memVar2_ * FOUR_DECIMALS) / memVar_);

                // for borrow operations, ensure max utilization is not reached
                if (borrowAmount_ > 0) {
                    // memVar_ => max utilization
                    // if any max utilization other than 100% is set, the flag usesConfigs2 in
                    // exchangePricesAndConfig is 1. (optimized to avoid SLOAD if not needed).
                    memVar_ = (o_.exchangePricesAndConfig >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_USES_CONFIGS2) &
                        1 ==
                        1
                        ? (_configs2[token_] & X14) // read configured max utilization
                        : FOUR_DECIMALS; // default max utilization = 100%

                    if (utilization_ > memVar_) {
                        revert FluidLiquidityError(ErrorTypes.UserModule__MaxUtilizationReached);
                    }
                }
            }

            // check if time difference is big enough (> 1 day)
            unchecked {
                if (
                    block.timestamp >
                    // extract last update timestamp + 1 day
                    (((o_.exchangePricesAndConfig >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_LAST_TIMESTAMP) & X33) +
                        FORCE_STORAGE_WRITE_AFTER_TIME)
                ) {
                    memVar_ = 1; // set write to storage flag
                } else {
                    memVar_ = 0;
                }
            }

            if (memVar_ == 0) {
                // time difference is not big enough to cause storage write -> check utilization

                // memVar_ => extract last utilization
                memVar_ = (o_.exchangePricesAndConfig >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_UTILIZATION) & X14;
                // memVar2_ => storage update threshold in percent
                memVar2_ =
                    (o_.exchangePricesAndConfig >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_UPDATE_THRESHOLD) &
                    X14;
                unchecked {
                    // set memVar_ to 1 if current utilization to previous utilization difference is > update storage threshold
                    memVar_ = (utilization_ > memVar_ ? utilization_ - memVar_ : memVar_ - utilization_) > memVar2_
                        ? 1
                        : 0;
                    if (memVar_ == 0) {
                        // utilization & time difference is not big enough -> check supplyRatio difference
                        // memVar_ => extract last supplyRatio
                        memVar_ =
                            (o_.exchangePricesAndConfig >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_SUPPLY_RATIO) &
                            X15;
                        // set memVar_ to 1 if current supplyRatio to previous supplyRatio difference is > update storage threshold
                        if ((memVar_ & 1) == (memVar3_ & 1)) {
                            memVar_ = memVar_ >> 1;
                            memVar_ = (
                                (memVar3_ >> 1) > memVar_ ? (memVar3_ >> 1) - memVar_ : memVar_ - (memVar3_ >> 1)
                            ) > memVar2_
                                ? 1
                                : 0; // memVar3_ = supplyRatio, memVar_ = previous supplyRatio, memVar2_ = update storage threshold
                        } else {
                            // if inverse bit is changing then always update on storage
                            memVar_ = 1;
                        }
                        if (memVar_ == 0) {
                            // utilization, time, and supplyRatio difference is not big enough -> check borrowRatio difference
                            // memVar_ => extract last borrowRatio
                            memVar_ =
                                (o_.exchangePricesAndConfig >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_BORROW_RATIO) &
                                X15;
                            // set memVar_ to 1 if current borrowRatio to previous borrowRatio difference is > update storage threshold
                            if ((memVar_ & 1) == (memVar4_ & 1)) {
                                memVar_ = memVar_ >> 1;
                                memVar_ = (
                                    (memVar4_ >> 1) > memVar_ ? (memVar4_ >> 1) - memVar_ : memVar_ - (memVar4_ >> 1)
                                ) > memVar2_
                                    ? 1
                                    : 0; // memVar4_ = borrowRatio, memVar_ = previous borrowRatio, memVar2_ = update storage threshold
                            } else {
                                // if inverse bit is changing then always update on storage
                                memVar_ = 1;
                            }
                        }
                    }
                }
            }

            // memVar_ is 1 if either time diff was enough or if
            // utilization, supplyRatio or borrowRatio difference was > update storage threshold
            if (memVar_ == 1) {
                // memVar_ => calculate new borrow rate for utilization. includes value overflow check.
                memVar_ = LiquidityCalcs.calcBorrowRateFromUtilization(_rateData[token_], utilization_);
                // ensure values written to storage do not exceed the dedicated bit space in packed uint256 slots
                if (o_.supplyExchangePrice > X64 || o_.borrowExchangePrice > X64) {
                    revert FluidLiquidityError(ErrorTypes.UserModule__ValueOverflow__EXCHANGE_PRICES);
                }
                if (utilization_ > X14) {
                    revert FluidLiquidityError(ErrorTypes.UserModule__ValueOverflow__UTILIZATION);
                }
                o_.exchangePricesAndConfig =
                    (o_.exchangePricesAndConfig &
                        // mask to update bits: 0-15 (borrow rate), 30-43 (utilization), 58-248 (timestamp, exchange prices, ratios)
                        0xfe000000000000000000000000000000000000000000000003fff0003fff0000) |
                    memVar_ | // calcBorrowRateFromUtilization already includes an overflow check
                    (utilization_ << LiquiditySlotsLink.BITS_EXCHANGE_PRICES_UTILIZATION) |
                    (block.timestamp << LiquiditySlotsLink.BITS_EXCHANGE_PRICES_LAST_TIMESTAMP) |
                    (o_.supplyExchangePrice << LiquiditySlotsLink.BITS_EXCHANGE_PRICES_SUPPLY_EXCHANGE_PRICE) |
                    (o_.borrowExchangePrice << LiquiditySlotsLink.BITS_EXCHANGE_PRICES_BORROW_EXCHANGE_PRICE) |
                    // ratios can never be > 100%, no overflow check needed
                    (memVar3_ << LiquiditySlotsLink.BITS_EXCHANGE_PRICES_SUPPLY_RATIO) | // supplyRatio (memVar3_ holds that value)
                    (memVar4_ << LiquiditySlotsLink.BITS_EXCHANGE_PRICES_BORROW_RATIO); // borrowRatio (memVar4_ holds that value)
                // Updating on storage
                _exchangePricesAndConfig[token_] = o_.exchangePricesAndConfig;
            } else {
                // do not update in storage but update o_.exchangePricesAndConfig for updated exchange prices at
                // event emit of LogOperate
                o_.exchangePricesAndConfig =
                    (o_.exchangePricesAndConfig &
                        // mask to update bits: 91-218 (exchange prices)
                        0xfffffffffc00000000000000000000000000000007ffffffffffffffffffffff) |
                    (o_.supplyExchangePrice << LiquiditySlotsLink.BITS_EXCHANGE_PRICES_SUPPLY_EXCHANGE_PRICE) |
                    (o_.borrowExchangePrice << LiquiditySlotsLink.BITS_EXCHANGE_PRICES_BORROW_EXCHANGE_PRICE);
            }
        }
        // sending tokens to user at the end after updating everything
        // only transfer to user in case of withdraw or borrow.
        // do not transfer for same amounts in same operate(): supply(+) == borrow(+), withdraw(-) == payback(-). (DEX protocol use-case)
        if ((supplyAmount_ < 0 || borrowAmount_ > 0) && !o_.skipTransfers) {
            // sending tokens to user at the end after updating everything
            // set memVar2_ to borrowAmount (if borrow) or reset memVar2_ var to 0 because
            // it is used with > 0 check below to transfer withdraw / borrow / both
            memVar2_ = borrowAmount_ > 0 ? uint256(borrowAmount_) : 0;
            if (supplyAmount_ < 0) {
                unchecked {
                    memVar_ = uint256(-supplyAmount_);
                }
            } else {
                memVar_ = 0;
            }
            if (memVar_ > 0 && memVar2_ > 0 && withdrawTo_ == borrowTo_) {
                // if user is doing borrow & withdraw together and address for both is the same
                // then transfer tokens of borrow & withdraw together to save on gas
                if (token_ == NATIVE_TOKEN_ADDRESS) {
                    SafeTransfer.safeTransferNative(withdrawTo_, memVar_ + memVar2_);
                } else {
                    SafeTransfer.safeTransfer(token_, withdrawTo_, memVar_ + memVar2_);
                }
            } else {
                if (token_ == NATIVE_TOKEN_ADDRESS) {
                    // if withdraw
                    if (memVar_ > 0) {
                        SafeTransfer.safeTransferNative(withdrawTo_, memVar_);
                    }
                    // if borrow
                    if (memVar2_ > 0) {
                        SafeTransfer.safeTransferNative(borrowTo_, memVar2_);
                    }
                } else {
                    // if withdraw
                    if (memVar_ > 0) {
                        // ---------- temporary code start -----------------------
                        // temporary addition for weETH & weETHs: if token is weETH or weETHs -> withdraw from Zircuit
                        if (token_ == WEETH) {
                            if ((IERC20(WEETH).balanceOf(address(this)) < memVar_)) {
                                ZIRCUIT.withdraw(WEETH, memVar_);
                            }
                        } else if (token_ == WEETHS) {
                            if ((IERC20(WEETHS).balanceOf(address(this)) < memVar_)) {
                                ZIRCUIT.withdraw(WEETHS, memVar_);
                            }
                        }
                        // temporary code also includes: WEETH, WEETHS & ZIRCUIT constant, IZtakingPool interface
                        // ---------- temporary code end -----------------------

                        SafeTransfer.safeTransfer(token_, withdrawTo_, memVar_);
                    }
                    // if borrow
                    if (memVar2_ > 0) {
                        SafeTransfer.safeTransfer(token_, borrowTo_, memVar2_);
                    }
                }
            }
        }
        // emit Operate event
        emit LogOperate(
            msg.sender,
            token_,
            supplyAmount_,
            borrowAmount_,
            withdrawTo_,
            borrowTo_,
            o_.totalAmounts,
            o_.exchangePricesAndConfig
        );
        // set return values
        memVar3_ = o_.supplyExchangePrice;
        memVar4_ = o_.borrowExchangePrice;
    }
}
