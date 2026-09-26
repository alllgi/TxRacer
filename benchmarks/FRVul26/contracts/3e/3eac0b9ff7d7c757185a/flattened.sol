// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

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

// File: contracts/protocols/dex/poolT1/common/variables.sol

pragma solidity 0.8.21;

abstract contract Variables {
    /*//////////////////////////////////////////////////////////////
                          STORAGE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// First 1 bit  => 0 => re-entrancy. If 0 then allow transaction to go, else throw.
    /// Next 40 bits => 1-40 => last to last stored price. BigNumber (32 bits precision, 8 bits exponent)
    /// Next 40 bits => 41-80 => last stored price of pool. BigNumber (32 bits precision, 8 bits exponent)
    /// Next 40 bits => 81-120 => center price. Center price from where the ranges will be calculated. BigNumber (32 bits precision, 8 bits exponent)
    /// Next 33 bits => 121-153 => last interaction time stamp
    /// Next 22 bits => 154-175 => max 4194303 seconds (~1165 hrs, ~48.5 days), time difference between last to last and last price stored
    /// Next 3 bits  => 176-178 => oracle checkpoint, if 0 then first slot, if 7 then last slot
    /// Next 16 bits => 179-194 => current mapping or oracle, after every 8 transaction it will increase by 1. Max capacity is 65535 but it can be lower than that check dexVariables2
    /// Next 1 bit  => 195 => is oracle active?
    uint internal dexVariables;

    /// Next  1 bit  => 0 => is smart collateral enabled?
    /// Next  1 bit  => 1 => is smart debt enabled?
    /// Next 17 bits => 2-18 => fee (1% = 10000, max value: 100000 = 10%, fee should not be more than 10%)
    /// Next  7 bits => 19-25 => revenue cut from fee (1 = 1%, 100 = 100%). If fee is 1000 = 0.1% and revenue cut is 10 = 10% then governance get 0.01% of every swap
    /// Next  1 bit  => 26 => percent active change going on or not, 0 = false, 1 = true, if true than that means governance has updated the below percents and the update should happen with a specified time.
    /// Next 20 bits => 27-46 => upperPercent (1% = 10000, max value: 104.8575%) upperRange - upperRange * upperPercent = centerPrice. Hence, upperRange = centerPrice / (1 - upperPercent)
    /// Next 20 bits => 47-66 => lowerPercent. lowerRange = centerPrice - centerPrice * lowerPercent.
    /// Next  1 bit  => 67 => threshold percent active change going on or not, 0 = false, 1 = true, if true than that means governance has updated the below percents and the update should happen with a specified time.
    /// Next 10 bits => 68-77 => upper shift threshold percent, 1 = 0.1%. 1000 = 100%. if currentPrice > (centerPrice + (upperRange - centerPrice) * (1000 - upperShiftThresholdPercent) / 1000) then trigger shift
    /// Next 10 bits => 78-87 => lower shift threshold percent, 1 = 0.1%. 1000 = 100%. if currentPrice < (centerPrice - (centerPrice - lowerRange) * (1000 - lowerShiftThresholdPercent) / 1000) then trigger shift
    /// Next 24 bits => 88-111 => Shifting time (~194 days) (rate = (% up + % down) / time ?)
    /// Next 30 bits => 112-131 => Address of center price if center price should be fetched externally, for example, for wstETH <> ETH pool, fetch wstETH exchange rate into stETH from wstETH contract.
    /// Why fetch it externally? Because let's say pool width is 0.1% and wstETH temporarily got depeg of 0.5% then pool will start to shift to newer pricing
    /// but we don't want pool to shift to 0.5% because we know the depeg will recover so to avoid the loss for users.
    /// Next 30 bits => 142-171 => Hooks bits, calculate hook address by storing deployment nonce from factory.
    /// Next 28 bits => 172-199 => max center price. BigNumber (20 bits precision, 8 bits exponent)
    /// Next 28 bits => 200-227 => min center price. BigNumber (20 bits precision, 8 bits exponent)
    /// Next 10 bits => 228-237 => utilization limit of token0. Max value 1000 = 100%, if 100% then no need to check the utilization.
    /// Next 10 bits => 238-247 => utilization limit of token1. Max value 1000 = 100%, if 100% then no need to check the utilization.
    /// Next 1  bit  => 248     => is center price shift active
    /// Last 1  bit  => 255     => Pause swap & arbitrage (only perfect functions will be usable), if we need to pause entire DEX then that can be done through pausing DEX on Liquidity Layer
    uint internal dexVariables2;

    /// first 128 bits => 0-127 => total supply shares
    /// last 128 bits => 128-255 => max supply shares
    uint internal _totalSupplyShares;

    /// @dev user supply data: user -> data
    /// Aside from 1st bit, entire bits here are same as liquidity layer _userSupplyData. Hence exact same supply & borrow limit library can be used
    /// First  1 bit  =>       0 => is user allowed to supply? 0 = not allowed, 1 = allowed
    /// Next  64 bits =>   1- 64 => user supply amount/shares; BigMath: 56 | 8
    /// Next  64 bits =>  65-128 => previous user withdrawal limit; BigMath: 56 | 8
    /// Next  33 bits => 129-161 => last triggered process timestamp (enough until 16 March 2242 -> max value 8589934591)
    /// Next  14 bits => 162-175 => expand withdrawal limit percentage (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383).
    ///                             @dev shrinking is instant
    /// Next  24 bits => 176-199 => withdrawal limit expand duration in seconds.(Max value 16_777_215; ~4_660 hours, ~194 days)
    /// Next  18 bits => 200-217 => base withdrawal limit: below this, 100% withdrawals can be done (aka shares can be burned); BigMath: 10 | 8
    /// Next  38 bits => 218-255 => empty for future use
    mapping(address => uint) internal _userSupplyData;

    /// first 128 bits => 0-127 => total borrow shares
    /// last 128 bits => 128-255 => max borrow shares
    uint internal _totalBorrowShares;

    /// @dev user borrow data: user -> data
    /// Aside from 1st bit, entire bits here are same as liquidity layer _userBorrowData. Hence exact same supply & borrow limit library function can be used
    /// First  1 bit  =>       0 => is user allowed to borrow? 0 = not allowed, 1 = allowed
    /// Next  64 bits =>   1- 64 => user debt amount/shares; BigMath: 56 | 8
    /// Next  64 bits =>  65-128 => previous user debt ceiling; BigMath: 56 | 8
    /// Next  33 bits => 129-161 => last triggered process timestamp (enough until 16 March 2242 -> max value 8589934591)
    /// Next  14 bits => 162-175 => expand debt ceiling percentage (in 1e2: 100% = 10_000; 1% = 100 -> max value 16_383)
    ///                             @dev shrinking is instant
    /// Next  24 bits => 176-199 => debt ceiling expand duration in seconds (Max value 16_777_215; ~4_660 hours, ~194 days)
    /// Next  18 bits => 200-217 => base debt ceiling: below this, there's no debt ceiling limits; BigMath: 10 | 8
    /// Next  18 bits => 218-235 => max debt ceiling: absolute maximum debt ceiling can expand to; BigMath: 10 | 8
    /// Next  20 bits => 236-255 => empty for future use
    mapping(address => uint) internal _userBorrowData;

    /// Price difference between last swap of last block & last swap of new block
    /// If last swap happened at Block B - 4 and next swap happened after 4 blocks at Block B then it will store that difference
    /// considering time difference between these 4 blocks is 48 seconds, hence time will be stored as 48
    /// New oracle update:
    /// time to 9 bits and precision to 22 bits
    /// if time exceeds 9 bits which is 511 sec or ~8.5 min then we will use 2 oracle slot to store the data
    /// we will leave the both time slot as 0 and on first sign + precision slot we will store time and
    /// on second sign + precision slot we will store sign & precision
    /// First 9 bits =>   0-  8 => time, 511 seconds
    /// Next   1 bit  =>  9     => sign of percent in change, if 1 then 0 or positive, else negative
    /// Next  22 bits =>  10- 31 => 4194303, change in price, max change is capped to 5%, so 4194303 = 5%, 1 = 0.0000011920931797249746%
    /// Next  9 bits =>  32- 40 => time, 511 seconds
    /// Next   1 bit  =>  41     => sign of percent in change, if 1 then 0 or positive, else negative
    /// Next  22 bits =>  42- 63 => 4194303, change in price, max change is capped to 5%, so 4194303 = 5%, 1 = 0.0000011920931797249746%
    /// Next  9 bits =>  64- 72 => time, 511 seconds
    /// Next   1 bit  =>  73     => sign of percent in change, if 1 then 0 or positive, else negative
    /// Next  22 bits =>  74- 95 => 4194303, change in price, max change is capped to 5%, so 4194303 = 5%, 1 = 0.0000011920931797249746%
    /// Next  9 bits =>  96-104 => time, 511 seconds
    /// Next   1 bit  => 105     => sign of percent in change, if 1 then 0 or positive, else negative
    /// Next  22 bits => 106-127 => 4194303, change in price, max change is capped to 5%, so 4194303 = 5%, 1 = 0.0000011920931797249746%
    /// Next  9 bits => 128-136 => time, 511 seconds
    /// Next   1 bit  => 137     => sign of percent in change, if 1 then 0 or positive, else negative
    /// Next  22 bits => 138-159 => 4194303, change in price, max change is capped to 5%, so 4194303 = 5%, 1 = 0.0000011920931797249746%
    /// Next  9 bits => 160-168 => time, 511 seconds
    /// Next   1 bit  => 169     => sign of percent in change, if 1 then 0 or positive, else negative
    /// Next  22 bits => 170-191 => 4194303, change in price, max change is capped to 5%, so 4194303 = 5%, 1 = 0.0000011920931797249746%
    /// Next  9 bits => 192-200 => time, 511 seconds
    /// Next   1 bit  => 201     => sign of percent in change, if 1 then 0 or positive, else negative
    /// Next  22 bits => 202-223 => 4194303, change in price, max change is capped to 5%, so 4194303 = 5%, 1 = 0.0000011920931797249746%
    /// Next  9 bits => 224-232 => time, 511 seconds
    /// Next   1 bit  => 233     => sign of percent in change, if 1 then 0 or positive, else negative
    /// Next  22 bits => 234-255 => 4194303, change in price, max change is capped to 5%, so 4194303 = 5%, 1 = 0.0000011920931797249746%
    mapping(uint => uint) internal _oracle;

    /// First 20 bits =>  0-19 => old upper shift
    /// Next  20 bits => 20-39 => old lower shift
    /// Next  20 bits => 40-59 => in seconds, ~12 days max, shift can last for max ~12 days
    /// Next  33 bits => 60-92 => timestamp of when the shift has started.
    uint128 internal _rangeShift;

    /// First 10 bits =>  0- 9 => old upper shift
    /// Next  10 bits => 10-19 => empty so we can use same helper function
    /// Next  10 bits => 20-29 => old lower shift
    /// Next  10 bits => 30-39 => empty so we can use same helper function
    /// Next  20 bits => 40-59 => in seconds, ~12 days max, shift can last for max ~12 days
    /// Next  33 bits => 60-92 => timestamp of when the shift has started.
    /// Next  24 bits => 93-116 => old threshold time
    uint128 internal _thresholdShift;

    /// Shifting is fuzzy and with time it'll keep on getting closer and then eventually get over
    /// First 33 bits => 0 -32 => starting timestamp
    /// Next  20 bits => 33-52 => % shift
    /// Next  20 bits => 53-72 => time to shift that percent
    uint256 internal _centerPriceShift;
}

// File: contracts/infiniteProxy/interfaces/iProxy.sol

pragma solidity 0.8.21;

interface IProxy {
    function setAdmin(address newAdmin_) external;

    function setDummyImplementation(address newDummyImplementation_) external;

    function addImplementation(address implementation_, bytes4[] calldata sigs_) external;

    function removeImplementation(address implementation_) external;

    function getAdmin() external view returns (address);

    function getDummyImplementation() external view returns (address);

    function getImplementationSigs(address impl_) external view returns (bytes4[] memory);

    function getSigsImplementation(bytes4 sig_) external view returns (address);

    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);
}

// File: contracts/liquidity/adminModule/structs.sol

pragma solidity 0.8.21;

abstract contract Structs {
    struct AddressBool {
        address addr;
        bool value;
    }

    struct AddressUint256 {
        address addr;
        uint256 value;
    }

    /// @notice struct to set borrow rate data for version 1
    struct RateDataV1Params {
        ///
        /// @param token for rate data
        address token;
        ///
        /// @param kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink usually means slow increase in rate, once utilization is above kink borrow rate increases fast
        uint256 kink;
        ///
        /// @param rateAtUtilizationZero desired borrow rate when utilization is zero. in 1e2: 100% = 10_000; 1% = 100
        /// i.e. constant minimum borrow rate
        /// e.g. at utilization = 0.01% rate could still be at least 4% (rateAtUtilizationZero would be 400 then)
        uint256 rateAtUtilizationZero;
        ///
        /// @param rateAtUtilizationKink borrow rate when utilization is at kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at kink then rateAtUtilizationKink would be 700
        uint256 rateAtUtilizationKink;
        ///
        /// @param rateAtUtilizationMax borrow rate when utilization is maximum at 100%. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 125% at 100% then rateAtUtilizationMax would be 12_500
        uint256 rateAtUtilizationMax;
    }

    /// @notice struct to set borrow rate data for version 2
    struct RateDataV2Params {
        ///
        /// @param token for rate data
        address token;
        ///
        /// @param kink1 first kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink 1 usually means slow increase in rate, once utilization is above kink 1 borrow rate increases faster
        uint256 kink1;
        ///
        /// @param kink2 second kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink 2 usually means slow / medium increase in rate, once utilization is above kink 2 borrow rate increases fast
        uint256 kink2;
        ///
        /// @param rateAtUtilizationZero desired borrow rate when utilization is zero. in 1e2: 100% = 10_000; 1% = 100
        /// i.e. constant minimum borrow rate
        /// e.g. at utilization = 0.01% rate could still be at least 4% (rateAtUtilizationZero would be 400 then)
        uint256 rateAtUtilizationZero;
        ///
        /// @param rateAtUtilizationKink1 desired borrow rate when utilization is at first kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at first kink then rateAtUtilizationKink would be 700
        uint256 rateAtUtilizationKink1;
        ///
        /// @param rateAtUtilizationKink2 desired borrow rate when utilization is at second kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at second kink then rateAtUtilizationKink would be 1_200
        uint256 rateAtUtilizationKink2;
        ///
        /// @param rateAtUtilizationMax desired borrow rate when utilization is maximum at 100%. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 125% at 100% then rateAtUtilizationMax would be 12_500
        uint256 rateAtUtilizationMax;
    }

    /// @notice struct to set token config
    struct TokenConfig {
        ///
        /// @param token address
        address token;
        ///
        /// @param fee charges on borrower's interest. in 1e2: 100% = 10_000; 1% = 100
        uint256 fee;
        ///
        /// @param threshold on when to update the storage slot. in 1e2: 100% = 10_000; 1% = 100
        uint256 threshold;
        ///
        /// @param maxUtilization maximum allowed utilization. in 1e2: 100% = 10_000; 1% = 100
        ///                       set to 100% to disable and have default limit of 100% (avoiding SLOAD).
        uint256 maxUtilization;
    }

    /// @notice struct to set user supply & withdrawal config
    struct UserSupplyConfig {
        ///
        /// @param user address
        address user;
        ///
        /// @param token address
        address token;
        ///
        /// @param mode: 0 = without interest. 1 = with interest
        uint8 mode;
        ///
        /// @param expandPercent withdrawal limit expand percent. in 1e2: 100% = 10_000; 1% = 100
        /// Also used to calculate rate at which withdrawal limit should decrease (instant).
        uint256 expandPercent;
        ///
        /// @param expandDuration withdrawal limit expand duration in seconds.
        /// used to calculate rate together with expandPercent
        uint256 expandDuration;
        ///
        /// @param baseWithdrawalLimit base limit, below this, user can withdraw the entire amount.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 baseWithdrawalLimit;
    }

    /// @notice struct to set user borrow & payback config
    struct UserBorrowConfig {
        ///
        /// @param user address
        address user;
        ///
        /// @param token address
        address token;
        ///
        /// @param mode: 0 = without interest. 1 = with interest
        uint8 mode;
        ///
        /// @param expandPercent debt limit expand percent. in 1e2: 100% = 10_000; 1% = 100
        /// Also used to calculate rate at which debt limit should decrease (instant).
        uint256 expandPercent;
        ///
        /// @param expandDuration debt limit expand duration in seconds.
        /// used to calculate rate together with expandPercent
        uint256 expandDuration;
        ///
        /// @param baseDebtCeiling base borrow limit. until here, borrow limit remains as baseDebtCeiling
        /// (user can borrow until this point at once without stepped expansion). Above this, automated limit comes in place.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 baseDebtCeiling;
        ///
        /// @param maxDebtCeiling max borrow ceiling, maximum amount the user can borrow.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 maxDebtCeiling;
    }
}

// File: contracts/liquidity/interfaces/iLiquidity.sol

pragma solidity 0.8.21;




interface IFluidLiquidityAdmin {
    /// @notice adds/removes auths. Auths generally could be contracts which can have restricted actions defined on contract.
    ///         auths can be helpful in reducing governance overhead where it's not needed.
    /// @param authsStatus_ array of structs setting allowed status for an address.
    ///                     status true => add auth, false => remove auth
    function updateAuths(AdminModuleStructs.AddressBool[] calldata authsStatus_) external;

    /// @notice adds/removes guardians. Only callable by Governance.
    /// @param guardiansStatus_ array of structs setting allowed status for an address.
    ///                         status true => add guardian, false => remove guardian
    function updateGuardians(AdminModuleStructs.AddressBool[] calldata guardiansStatus_) external;

    /// @notice changes the revenue collector address (contract that is sent revenue). Only callable by Governance.
    /// @param revenueCollector_  new revenue collector address
    function updateRevenueCollector(address revenueCollector_) external;

    /// @notice changes current status, e.g. for pausing or unpausing all user operations. Only callable by Auths.
    /// @param newStatus_ new status
    ///        status = 2 -> pause, status = 1 -> resume.
    function changeStatus(uint256 newStatus_) external;

    /// @notice                  update tokens rate data version 1. Only callable by Auths.
    /// @param tokensRateData_   array of RateDataV1Params with rate data to set for each token
    function updateRateDataV1s(AdminModuleStructs.RateDataV1Params[] calldata tokensRateData_) external;

    /// @notice                  update tokens rate data version 2. Only callable by Auths.
    /// @param tokensRateData_   array of RateDataV2Params with rate data to set for each token
    function updateRateDataV2s(AdminModuleStructs.RateDataV2Params[] calldata tokensRateData_) external;

    /// @notice updates token configs: fee charge on borrowers interest & storage update utilization threshold.
    ///         Only callable by Auths.
    /// @param tokenConfigs_ contains token address, fee & utilization threshold
    function updateTokenConfigs(AdminModuleStructs.TokenConfig[] calldata tokenConfigs_) external;

    /// @notice updates user classes: 0 is for new protocols, 1 is for established protocols.
    ///         Only callable by Auths.
    /// @param userClasses_ struct array of uint256 value to assign for each user address
    function updateUserClasses(AdminModuleStructs.AddressUint256[] calldata userClasses_) external;

    /// @notice sets user supply configs per token basis. Eg: with interest or interest-free and automated limits.
    ///         Only callable by Auths.
    /// @param userSupplyConfigs_ struct array containing user supply config, see `UserSupplyConfig` struct for more info
    function updateUserSupplyConfigs(AdminModuleStructs.UserSupplyConfig[] memory userSupplyConfigs_) external;

    /// @notice sets a new withdrawal limit as the current limit for a certain user
    /// @param user_ user address for which to update the withdrawal limit
    /// @param token_ token address for which to update the withdrawal limit
    /// @param newLimit_ new limit until which user supply can decrease to.
    ///                  Important: input in raw. Must account for exchange price in input param calculation.
    ///                  Note any limit that is < max expansion or > current user supply will set max expansion limit or
    ///                  current user supply as limit respectively.
    ///                  - set 0 to make maximum possible withdrawable: instant full expansion, and if that goes
    ///                  below base limit then fully down to 0.
    ///                  - set type(uint256).max to make current withdrawable 0 (sets current user supply as limit).
    function updateUserWithdrawalLimit(address user_, address token_, uint256 newLimit_) external;

    /// @notice setting user borrow configs per token basis. Eg: with interest or interest-free and automated limits.
    ///         Only callable by Auths.
    /// @param userBorrowConfigs_ struct array containing user borrow config, see `UserBorrowConfig` struct for more info
    function updateUserBorrowConfigs(AdminModuleStructs.UserBorrowConfig[] memory userBorrowConfigs_) external;

    /// @notice pause operations for a particular user in class 0 (class 1 users can't be paused by guardians).
    /// Only callable by Guardians.
    /// @param user_          address of user to pause operations for
    /// @param supplyTokens_  token addresses to pause withdrawals for
    /// @param borrowTokens_  token addresses to pause borrowings for
    function pauseUser(address user_, address[] calldata supplyTokens_, address[] calldata borrowTokens_) external;

    /// @notice unpause operations for a particular user in class 0 (class 1 users can't be paused by guardians).
    /// Only callable by Guardians.
    /// @param user_          address of user to unpause operations for
    /// @param supplyTokens_  token addresses to unpause withdrawals for
    /// @param borrowTokens_  token addresses to unpause borrowings for
    function unpauseUser(address user_, address[] calldata supplyTokens_, address[] calldata borrowTokens_) external;

    /// @notice         collects revenue for tokens to configured revenueCollector address.
    /// @param tokens_  array of tokens to collect revenue for
    /// @dev            Note that this can revert if token balance is < revenueAmount (utilization > 100%)
    function collectRevenue(address[] calldata tokens_) external;

    /// @notice gets the current updated exchange prices for n tokens and updates all prices, rates related data in storage.
    /// @param tokens_ tokens to update exchange prices for
    /// @return supplyExchangePrices_ new supply rates of overall system for each token
    /// @return borrowExchangePrices_ new borrow rates of overall system for each token
    function updateExchangePrices(
        address[] calldata tokens_
    ) external returns (uint256[] memory supplyExchangePrices_, uint256[] memory borrowExchangePrices_);
}

interface IFluidLiquidityLogic is IFluidLiquidityAdmin {
    /// @notice Single function which handles supply, withdraw, borrow & payback
    /// @param token_ address of token (0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE for native)
    /// @param supplyAmount_ if +ve then supply, if -ve then withdraw, if 0 then nothing
    /// @param borrowAmount_ if +ve then borrow, if -ve then payback, if 0 then nothing
    /// @param withdrawTo_ if withdrawal then to which address
    /// @param borrowTo_ if borrow then to which address
    /// @param callbackData_ callback data passed to `liquidityCallback` method of protocol
    /// @return memVar3_ updated supplyExchangePrice
    /// @return memVar4_ updated borrowExchangePrice
    /// @dev to trigger skipping in / out transfers (gas optimization):
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
    function operate(
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_,
        address withdrawTo_,
        address borrowTo_,
        bytes calldata callbackData_
    ) external payable returns (uint256 memVar3_, uint256 memVar4_);
}

interface IFluidLiquidity is IProxy, IFluidLiquidityLogic {}

// File: contracts/protocols/dex/poolT1/coreModule/structs.sol

pragma solidity 0.8.21;

abstract contract Structs {
    struct PricesAndExchangePrice {
        uint lastStoredPrice; // last stored price in 1e27 decimals
        uint centerPrice; // last stored price in 1e27 decimals
        uint upperRange; // price at upper range in 1e27 decimals
        uint lowerRange; // price at lower range in 1e27 decimals
        uint geometricMean; // geometric mean of upper range & lower range in 1e27 decimals
        uint supplyToken0ExchangePrice;
        uint borrowToken0ExchangePrice;
        uint supplyToken1ExchangePrice;
        uint borrowToken1ExchangePrice;
    }

    struct ExchangePrices {
        uint supplyToken0ExchangePrice;
        uint borrowToken0ExchangePrice;
        uint supplyToken1ExchangePrice;
        uint borrowToken1ExchangePrice;
    }

    struct CollateralReserves {
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    struct CollateralReservesSwap {
        uint tokenInRealReserves;
        uint tokenOutRealReserves;
        uint tokenInImaginaryReserves;
        uint tokenOutImaginaryReserves;
    }

    struct DebtReserves {
        uint token0Debt;
        uint token1Debt;
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    struct DebtReservesSwap {
        uint tokenInDebt;
        uint tokenOutDebt;
        uint tokenInRealReserves;
        uint tokenOutRealReserves;
        uint tokenInImaginaryReserves;
        uint tokenOutImaginaryReserves;
    }

    struct SwapInMemory {
        address tokenIn;
        address tokenOut;
        uint256 amtInAdjusted;
        address withdrawTo;
        address borrowTo;
        uint price; // price of pool after swap
        uint fee; // fee of pool
        uint revenueCut; // revenue cut of pool
        bool swap0to1;
        int swapRoutingAmt;
        bytes data; // just added to avoid stack-too-deep error
    }

    struct SwapOutMemory {
        address tokenIn;
        address tokenOut;
        uint256 amtOutAdjusted;
        address withdrawTo;
        address borrowTo;
        uint price; // price of pool after swap
        uint fee;
        uint revenueCut; // revenue cut of pool
        bool swap0to1;
        int swapRoutingAmt;
        bytes data; // just added to avoid stack-too-deep error
        uint msgValue;
    }

    struct DepositColMemory {
        uint256 token0AmtAdjusted;
        uint256 token1AmtAdjusted;
        uint256 token0ReservesInitial;
        uint256 token1ReservesInitial;
    }

    struct WithdrawColMemory {
        uint256 token0AmtAdjusted;
        uint256 token1AmtAdjusted;
        uint256 token0ReservesInitial;
        uint256 token1ReservesInitial;
        address to;
    }

    struct BorrowDebtMemory {
        uint256 token0AmtAdjusted;
        uint256 token1AmtAdjusted;
        uint256 token0DebtInitial;
        uint256 token1DebtInitial;
        address to;
    }

    struct PaybackDebtMemory {
        uint256 token0AmtAdjusted;
        uint256 token1AmtAdjusted;
        uint256 token0DebtInitial;
        uint256 token1DebtInitial;
    }

    struct OraclePriceMemory {
        uint lowestPrice1by0;
        uint highestPrice1by0;
        uint oracleSlot;
        uint oracleMap;
        uint oracle;
    }

    struct Oracle {
        uint twap1by0; // TWAP price
        uint lowestPrice1by0; // lowest price point
        uint highestPrice1by0; // highest price point
        uint twap0by1; // TWAP price
        uint lowestPrice0by1; // lowest price point
        uint highestPrice0by1; // highest price point
    }

    struct Implementations {
        address shift;
        address admin;
        address colOperations;
        address debtOperations;
        address perfectOperationsAndSwapOut;
    }

    struct ConstantViews {
        uint256 dexId;
        address liquidity;
        address factory;
        Implementations implementations;
        address deployerContract;
        address token0;
        address token1;
        bytes32 supplyToken0Slot;
        bytes32 borrowToken0Slot;
        bytes32 supplyToken1Slot;
        bytes32 borrowToken1Slot;
        bytes32 exchangePriceToken0Slot;
        bytes32 exchangePriceToken1Slot;
        uint256 oracleMapping;
    }

    struct ConstantViews2 {
        uint token0NumeratorPrecision;
        uint token0DenominatorPrecision;
        uint token1NumeratorPrecision;
        uint token1DenominatorPrecision;
    }
}

// File: contracts/libraries/storageRead.sol

pragma solidity 0.8.21;

/// @notice implements a method to read uint256 data from storage at a bytes32 storage slot key.
contract StorageRead {
    function readFromStorage(bytes32 slot_) public view returns (uint256 result_) {
        assembly {
            result_ := sload(slot_) // read value from the storage slot
        }
    }
}

// File: contracts/protocols/dex/poolT1/common/constantVariables.sol

pragma solidity 0.8.21;



interface ITokenDecimals {
    function decimals() external view returns (uint8);
}

abstract contract ConstantVariables is StorageRead {
    /*//////////////////////////////////////////////////////////////
                          CONSTANTS / IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    address internal constant TEAM_MULTISIG = 0x4F6F977aCDD1177DCD81aB83074855EcB9C2D49e;

    address internal constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 internal constant NATIVE_TOKEN_DECIMALS = 18;
    address internal constant ADDRESS_DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 internal constant TOKENS_DECIMALS_PRECISION = 12;
    uint256 internal constant TOKENS_DECIMALS = 1e12;

    uint256 internal constant SMALL_COEFFICIENT_SIZE = 10;
    uint256 internal constant DEFAULT_COEFFICIENT_SIZE = 56;
    uint256 internal constant DEFAULT_EXPONENT_SIZE = 8;
    uint256 internal constant DEFAULT_EXPONENT_MASK = 0xFF;

    uint256 internal constant X2 = 0x3;
    uint256 internal constant X3 = 0x7;
    uint256 internal constant X5 = 0x1f;
    uint256 internal constant X7 = 0x7f;
    uint256 internal constant X8 = 0xff;
    uint256 internal constant X9 = 0x1ff;
    uint256 internal constant X10 = 0x3ff;
    uint256 internal constant X11 = 0x7ff;
    uint256 internal constant X14 = 0x3fff;
    uint256 internal constant X16 = 0xffff;
    uint256 internal constant X17 = 0x1ffff;
    uint256 internal constant X18 = 0x3ffff;
    uint256 internal constant X20 = 0xfffff;
    uint256 internal constant X22 = 0x3fffff;
    uint256 internal constant X23 = 0x7fffff;
    uint256 internal constant X24 = 0xffffff;
    uint256 internal constant X28 = 0xfffffff;
    uint256 internal constant X30 = 0x3fffffff;
    uint256 internal constant X32 = 0xffffffff;
    uint256 internal constant X33 = 0x1ffffffff;
    uint256 internal constant X40 = 0xffffffffff;
    uint256 internal constant X64 = 0xffffffffffffffff;
    uint256 internal constant X96 = 0xffffffffffffffffffffffff;
    uint256 internal constant X128 = 0xffffffffffffffffffffffffffffffff;

    uint256 internal constant TWO_DECIMALS = 1e2;
    uint256 internal constant THREE_DECIMALS = 1e3;
    uint256 internal constant FOUR_DECIMALS = 1e4;
    uint256 internal constant FIVE_DECIMALS = 1e5;
    uint256 internal constant SIX_DECIMALS = 1e6;
    uint256 internal constant EIGHT_DECIMALS = 1e8;
    uint256 internal constant NINE_DECIMALS = 1e9;

    uint256 internal constant PRICE_PRECISION = 1e27;

    uint256 internal constant ORACLE_PRECISION = 1e18; // 100%
    uint256 internal constant ORACLE_LIMIT = 5 * 1e16; // 5%

    /// after swap token0 reserves should not be less than token1InToken0 / MINIMUM_LIQUIDITY_SWAP
    /// after swap token1 reserves should not be less than token0InToken1 / MINIMUM_LIQUIDITY_SWAP
    uint256 internal constant MINIMUM_LIQUIDITY_SWAP = 1e4;

    /// after user operations (deposit, withdraw, borrow, payback) token0 reserves should not be less than token1InToken0 / MINIMUM_LIQUIDITY_USER_OPERATIONS
    /// after user operations (deposit, withdraw, borrow, payback) token1 reserves should not be less than token0InToken0 / MINIMUM_LIQUIDITY_USER_OPERATIONS
    uint256 internal constant MINIMUM_LIQUIDITY_USER_OPERATIONS = 1e6;

    /// To skip transfers in liquidity layer if token in & out is same and liquidity layer is on the winning side
    bytes32 internal constant SKIP_TRANSFERS = keccak256(bytes("SKIP_TRANSFERS"));

    function _decimals(address token_) internal view returns (uint256) {
        return (token_ == NATIVE_TOKEN) ? NATIVE_TOKEN_DECIMALS : ITokenDecimals(token_).decimals();
    }
}

// File: contracts/protocols/dex/interfaces/iDexFactory.sol

pragma solidity 0.8.21;

interface IFluidDexFactory {
    /// @notice Global auth is auth for all dexes
    function isGlobalAuth(address auth_) external view returns (bool);

    /// @notice Dex auth is auth for a specific dex
    function isDexAuth(address vault_, address auth_) external view returns (bool);

    /// @notice Total dexes deployed.
    function totalDexes() external view returns (uint256);

    /// @notice Compute dexAddress
    function getDexAddress(uint256 dexId_) external view returns (address);

    /// @notice read uint256 `result_` for a storage `slot_` key
    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);
}

// File: contracts/protocols/dex/error.sol

pragma solidity 0.8.21;



abstract contract Error {
    error FluidDexError(uint256 errorId_);

    error FluidDexFactoryError(uint256 errorId);

    /// @notice used to simulate swap to find the output amount
    error FluidDexSwapResult(uint256 amountOut);

    error FluidDexPerfectLiquidityOutput(uint256 token0Amt, uint token1Amt);

    error FluidDexSingleTokenOutput(uint256 tokenAmt);

    error FluidDexLiquidityOutput(uint256 shares_);

    error FluidDexPricesAndExchangeRates(Structs.PricesAndExchangePrice pex_);
}

// File: contracts/protocols/dex/errorTypes.sol

pragma solidity 0.8.21;

library ErrorTypes {
    /***********************************|
    |             DexT1                 | 
    |__________________________________*/

    /// @notice thrown at reentrancy
    uint256 internal constant DexT1__AlreadyEntered = 51001;

    uint256 internal constant DexT1__NotAnAuth = 51002;

    uint256 internal constant DexT1__SmartColNotEnabled = 51003;

    uint256 internal constant DexT1__SmartDebtNotEnabled = 51004;

    uint256 internal constant DexT1__PoolNotInitialized = 51005;

    uint256 internal constant DexT1__TokenReservesTooLow = 51006;

    uint256 internal constant DexT1__EthAndAmountInMisMatch = 51007;

    uint256 internal constant DexT1__EthSentForNonNativeSwap = 51008;

    uint256 internal constant DexT1__NoSwapRoute = 51009;

    uint256 internal constant DexT1__NotEnoughAmountOut = 51010;

    uint256 internal constant DexT1__LiquidityLayerTokenUtilizationCapReached = 51011;

    uint256 internal constant DexT1__HookReturnedFalse = 51012;

    // Either user's config are not set or user is paused
    uint256 internal constant DexT1__UserSupplyInNotOn = 51013;

    // Either user's config are not set or user is paused
    uint256 internal constant DexT1__UserDebtInNotOn = 51014;

    // Thrown when contract asks for more token0 or token1 than what user's wants to give on deposit
    uint256 internal constant DexT1__AboveDepositMax = 51015;

    uint256 internal constant DexT1__MsgValueLowOnDepositOrPayback = 51016;

    uint256 internal constant DexT1__WithdrawLimitReached = 51017;

    // Thrown when contract gives less token0 or token1 than what user's wants on withdraw
    uint256 internal constant DexT1__BelowWithdrawMin = 51018;

    uint256 internal constant DexT1__DebtLimitReached = 51019;

    // Thrown when contract gives less token0 or token1 than what user's wants on borrow
    uint256 internal constant DexT1__BelowBorrowMin = 51020;

    // Thrown when contract asks for more token0 or token1 than what user's wants on payback
    uint256 internal constant DexT1__AbovePaybackMax = 51021;

    uint256 internal constant DexT1__InvalidDepositAmts = 51022;

    uint256 internal constant DexT1__DepositAmtsZero = 51023;

    uint256 internal constant DexT1__SharesMintedLess = 51024;

    uint256 internal constant DexT1__WithdrawalNotEnough = 51025;

    uint256 internal constant DexT1__InvalidWithdrawAmts = 51026;

    uint256 internal constant DexT1__WithdrawAmtsZero = 51027;

    uint256 internal constant DexT1__WithdrawExcessSharesBurn = 51028;

    uint256 internal constant DexT1__InvalidBorrowAmts = 51029;

    uint256 internal constant DexT1__BorrowAmtsZero = 51030;

    uint256 internal constant DexT1__BorrowExcessSharesMinted = 51031;

    uint256 internal constant DexT1__PaybackAmtTooHigh = 51032;

    uint256 internal constant DexT1__InvalidPaybackAmts = 51033;

    uint256 internal constant DexT1__PaybackAmtsZero = 51034;

    uint256 internal constant DexT1__PaybackSharedBurnedLess = 51035;

    uint256 internal constant DexT1__NothingToArbitrage = 51036;

    uint256 internal constant DexT1__MsgSenderNotLiquidity = 51037;

    // On liquidity callback reentrancy bit should be on
    uint256 internal constant DexT1__ReentrancyBitShouldBeOn = 51038;

    // Thrown is reentrancy is already on and someone tries to fetch oracle price. Should not be possible to this
    uint256 internal constant DexT1__OraclePriceFetchAlreadyEntered = 51039;

    // Thrown when swap changes the current price by more than 5%
    uint256 internal constant DexT1__OracleUpdateHugeSwapDiff = 51040;

    uint256 internal constant DexT1__Token0ShouldBeSmallerThanToken1 = 51041;

    uint256 internal constant DexT1__OracleMappingOverflow = 51042;

    /// @notice thrown if governance has paused the swapping & arbitrage so only perfect functions are usable
    uint256 internal constant DexT1__SwapAndArbitragePaused = 51043;

    uint256 internal constant DexT1__ExceedsAmountInMax = 51044;

    /// @notice thrown if amount in is too high or too low
    uint256 internal constant DexT1__SwapInLimitingAmounts = 51045;

    /// @notice thrown if amount out is too high or too low
    uint256 internal constant DexT1__SwapOutLimitingAmounts = 51046;

    uint256 internal constant DexT1__MintAmtOverflow = 51047;

    uint256 internal constant DexT1__BurnAmtOverflow = 51048;

    uint256 internal constant DexT1__LimitingAmountsSwapAndNonPerfectActions = 51049;

    uint256 internal constant DexT1__InsufficientOracleData = 51050;

    uint256 internal constant DexT1__SharesAmountInsufficient = 51051;

    uint256 internal constant DexT1__CenterPriceOutOfRange = 51052;

    uint256 internal constant DexT1__DebtReservesTooLow = 51053;

    uint256 internal constant DexT1__SwapAndDepositTooLowOrTooHigh = 51054;

    uint256 internal constant DexT1__WithdrawAndSwapTooLowOrTooHigh = 51055;

    uint256 internal constant DexT1__BorrowAndSwapTooLowOrTooHigh = 51056;

    uint256 internal constant DexT1__SwapAndPaybackTooLowOrTooHigh = 51057;

    uint256 internal constant DexT1__InvalidImplementation = 51058;

    uint256 internal constant DexT1__OnlyDelegateCallAllowed = 51059;

    uint256 internal constant DexT1__IncorrectDataLength = 51060;

    uint256 internal constant DexT1__AmountToSendLessThanAmount = 51061;

    uint256 internal constant DexT1__InvalidCollateralReserves = 51062;

    uint256 internal constant DexT1__InvalidDebtReserves = 51063;

    uint256 internal constant DexT1__SupplySharesOverflow = 51064;

    uint256 internal constant DexT1__BorrowSharesOverflow = 51065;

    uint256 internal constant DexT1__OracleNotActive = 51066;

    /***********************************|
    |            DEX Admin              | 
    |__________________________________*/

    /// @notice thrown when pool is not initialized
    uint256 internal constant DexT1Admin__PoolNotInitialized = 52001;

    uint256 internal constant DexT1Admin__SmartColIsAlreadyOn = 52002;

    uint256 internal constant DexT1Admin__SmartDebtIsAlreadyOn = 52003;

    /// @notice thrown when any of the configs value overflow the maximum limit
    uint256 internal constant DexT1Admin__ConfigOverflow = 52004;

    uint256 internal constant DexT1Admin__AddressNotAContract = 52005;

    uint256 internal constant DexT1Admin__InvalidParams = 52006;

    uint256 internal constant DexT1Admin__UserNotDefined = 52007;

    uint256 internal constant DexT1Admin__OnlyDelegateCallAllowed = 52008;

    uint256 internal constant DexT1Admin__UnexpectedPoolState = 52009;

    /// @notice thrown when trying to pause or unpause but user is already in the target pause state
    uint256 internal constant DexT1Admin__InvalidPauseToggle = 52009;

    /***********************************|
    |            DEX Factory            | 
    |__________________________________*/

    uint256 internal constant DexFactory__InvalidOperation = 53001;
    uint256 internal constant DexFactory__Unauthorized = 53002;
    uint256 internal constant DexFactory__SameTokenNotAllowed = 53003;
    uint256 internal constant DexFactory__TokenConfigNotProper = 53004;
    uint256 internal constant DexFactory__InvalidParams = 53005;
    uint256 internal constant DexFactory__OnlyDelegateCallAllowed = 53006;
    uint256 internal constant DexFactory__InvalidDexAddress = 53007;
}

// File: contracts/protocols/dex/poolT1/coreModule/immutableVariables.sol

pragma solidity 0.8.21;








abstract contract ImmutableVariables is ConstantVariables, Structs, Error {
    /*//////////////////////////////////////////////////////////////
                          CONSTANTS / IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    uint256 public immutable DEX_ID;

    /// @dev Address of token 0
    address internal immutable TOKEN_0;

    /// @dev Address of token 1
    address internal immutable TOKEN_1;

    address internal immutable THIS_CONTRACT;

    uint256 internal immutable TOKEN_0_NUMERATOR_PRECISION;
    uint256 internal immutable TOKEN_0_DENOMINATOR_PRECISION;
    uint256 internal immutable TOKEN_1_NUMERATOR_PRECISION;
    uint256 internal immutable TOKEN_1_DENOMINATOR_PRECISION;

    /// @dev Address of liquidity contract
    IFluidLiquidity internal immutable LIQUIDITY;

    /// @dev Address of DEX factory contract
    IFluidDexFactory internal immutable DEX_FACTORY;

    /// @dev Address of Shift implementation
    address internal immutable SHIFT_IMPLEMENTATION;

    /// @dev Address of Admin implementation
    address internal immutable ADMIN_IMPLEMENTATION;

    /// @dev Address of Col Operations implementation
    address internal immutable COL_OPERATIONS_IMPLEMENTATION;

    /// @dev Address of Debt Operations implementation
    address internal immutable DEBT_OPERATIONS_IMPLEMENTATION;

    /// @dev Address of Perfect Operations and Swap Out implementation
    address internal immutable PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION;

    /// @dev Address of contract used for deploying center price & hook related contract
    address internal immutable DEPLOYER_CONTRACT;

    /// @dev Liquidity layer slots
    bytes32 internal immutable SUPPLY_TOKEN_0_SLOT;
    bytes32 internal immutable BORROW_TOKEN_0_SLOT;
    bytes32 internal immutable SUPPLY_TOKEN_1_SLOT;
    bytes32 internal immutable BORROW_TOKEN_1_SLOT;
    bytes32 internal immutable EXCHANGE_PRICE_TOKEN_0_SLOT;
    bytes32 internal immutable EXCHANGE_PRICE_TOKEN_1_SLOT;
    uint256 internal immutable TOTAL_ORACLE_MAPPING;

    function _calcNumeratorAndDenominator(
        address token_
    ) private view returns (uint256 numerator_, uint256 denominator_) {
        uint256 decimals_ = _decimals(token_);
        if (decimals_ > TOKENS_DECIMALS_PRECISION) {
            numerator_ = 1;
            denominator_ = 10 ** (decimals_ - TOKENS_DECIMALS_PRECISION);
        } else {
            numerator_ = 10 ** (TOKENS_DECIMALS_PRECISION - decimals_);
            denominator_ = 1;
        }
    }

    constructor(ConstantViews memory constants_) {
        THIS_CONTRACT = address(this);

        DEX_ID = constants_.dexId;
        LIQUIDITY = IFluidLiquidity(constants_.liquidity);
        DEX_FACTORY = IFluidDexFactory(constants_.factory);

        TOKEN_0 = constants_.token0;
        TOKEN_1 = constants_.token1;

        if (TOKEN_0 >= TOKEN_1) revert FluidDexError(ErrorTypes.DexT1__Token0ShouldBeSmallerThanToken1);

        (TOKEN_0_NUMERATOR_PRECISION, TOKEN_0_DENOMINATOR_PRECISION) = _calcNumeratorAndDenominator(TOKEN_0);
        (TOKEN_1_NUMERATOR_PRECISION, TOKEN_1_DENOMINATOR_PRECISION) = _calcNumeratorAndDenominator(TOKEN_1);

        if (constants_.implementations.shift != address(0)) {
            SHIFT_IMPLEMENTATION = constants_.implementations.shift;
        } else {
            SHIFT_IMPLEMENTATION = address(this);
        }
        if (constants_.implementations.admin != address(0)) {
            ADMIN_IMPLEMENTATION = constants_.implementations.admin;
        } else {
            ADMIN_IMPLEMENTATION = address(this);
        }
        if (constants_.implementations.colOperations != address(0)) {
            COL_OPERATIONS_IMPLEMENTATION = constants_.implementations.colOperations;
        } else {
            COL_OPERATIONS_IMPLEMENTATION = address(this);
        }
        if (constants_.implementations.debtOperations != address(0)) {
            DEBT_OPERATIONS_IMPLEMENTATION = constants_.implementations.debtOperations;
        } else {
            DEBT_OPERATIONS_IMPLEMENTATION = address(this);
        }
        if (constants_.implementations.perfectOperationsAndSwapOut != address(0)) {
            PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION = constants_.implementations.perfectOperationsAndSwapOut;
        } else {
            PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION = address(this);
        }

        DEPLOYER_CONTRACT = constants_.deployerContract;

        SUPPLY_TOKEN_0_SLOT = constants_.supplyToken0Slot;
        BORROW_TOKEN_0_SLOT = constants_.borrowToken0Slot;
        SUPPLY_TOKEN_1_SLOT = constants_.supplyToken1Slot;
        BORROW_TOKEN_1_SLOT = constants_.borrowToken1Slot;
        EXCHANGE_PRICE_TOKEN_0_SLOT = constants_.exchangePriceToken0Slot;
        EXCHANGE_PRICE_TOKEN_1_SLOT = constants_.exchangePriceToken1Slot;

        if (constants_.oracleMapping > X16) revert FluidDexError(ErrorTypes.DexT1__OracleMappingOverflow);

        TOTAL_ORACLE_MAPPING = constants_.oracleMapping;
    }
}

// File: contracts/protocols/dex/poolT1/coreModule/events.sol

pragma solidity 0.8.21;

abstract contract Events {
    /// @notice Emitted on token swaps
    /// @param swap0to1 Indicates whether the swap is from token0 to token1 or vice-versa.
    /// @param amountIn The amount of tokens to be sent to the vault to swap.
    /// @param amountOut The amount of tokens user got from the swap.
    /// @param to Recepient of swapped tokens.
    event Swap(bool swap0to1, uint256 amountIn, uint256 amountOut, address to);

    /// @notice Emitted when liquidity is added with shares specified.
    /// @param shares Expected exact shares to be received.
    /// @param token0Amt Amount of token0 deposited.
    /// @param token0Amt Amount of token1 deposited.
    event LogDepositPerfectColLiquidity(uint shares, uint token0Amt, uint token1Amt);

    /// @notice Emitted when liquidity is withdrawn with shares specified.
    /// @param shares shares burned
    /// @param token0Amt Amount of token0 withdrawn.
    /// @param token1Amt Amount of token1 withdrawn.
    event LogWithdrawPerfectColLiquidity(uint shares, uint token0Amt, uint token1Amt);

    /// @notice Emitted when liquidity is borrowed with shares specified.
    /// @param shares shares minted
    /// @param token0Amt Amount of token0 borrowed.
    /// @param token1Amt Amount of token1 borrowed.
    event LogBorrowPerfectDebtLiquidity(uint shares, uint token0Amt, uint token1Amt);

    /// @notice Emitted when liquidity is paid back with shares specified.
    /// @param shares shares burned
    /// @param token0Amt Amount of token0 paid back.
    /// @param token1Amt Amount of token1 paid back.
    event LogPaybackPerfectDebtLiquidity(uint shares, uint token0Amt, uint token1Amt);

    /// @notice Emitted when liquidity is deposited with specified token0 & token1 amount
    /// @param amount0 Amount of token0 deposited.
    /// @param amount1 Amount of token1 deposited.
    /// @param shares Amount of shares minted.
    event LogDepositColLiquidity(uint amount0, uint amount1, uint shares);

    /// @notice Emitted when liquidity is withdrawn with specified token0 & token1 amount
    /// @param amount0 Amount of token0 withdrawn.
    /// @param amount1 Amount of token1 withdrawn.
    /// @param shares Amount of shares burned.
    event LogWithdrawColLiquidity(uint amount0, uint amount1, uint shares);

    /// @notice Emitted when liquidity is borrowed with specified token0 & token1 amount
    /// @param amount0 Amount of token0 borrowed.
    /// @param amount1 Amount of token1 borrowed.
    /// @param shares Amount of shares minted.
    event LogBorrowDebtLiquidity(uint amount0, uint amount1, uint shares);

    /// @notice Emitted when liquidity is paid back with specified token0 & token1 amount
    /// @param amount0 Amount of token0 paid back.
    /// @param amount1 Amount of token1 paid back.
    /// @param shares Amount of shares burned.
    event LogPaybackDebtLiquidity(uint amount0, uint amount1, uint shares);

    /// @notice Emitted when liquidity is withdrawn with shares specified into one token only.
    /// @param shares shares burned
    /// @param token0Amt Amount of token0 withdrawn.
    /// @param token1Amt Amount of token1 withdrawn.
    event LogWithdrawColInOneToken(uint shares, uint token0Amt, uint token1Amt);

    /// @notice Emitted when liquidity is paid back with shares specified from one token only.
    /// @param shares shares burned
    /// @param token0Amt Amount of token0 paid back.
    /// @param token1Amt Amount of token1 paid back.
    event LogPaybackDebtInOneToken(uint shares, uint token0Amt, uint token1Amt);

    /// @notice Emitted when internal arbitrage between 2 pools happen
    /// @param routing if positive then routing is amtIn of token0 in deposit & borrow else token0 withdraw & payback
    /// @param amtOut if routing is positive then token1 withdraw & payback amount else token1 deposit & borrow
    event LogArbitrage(int routing, uint amtOut);
}

// File: contracts/protocols/dex/poolT1/coreModule/interfaces.sol

pragma solidity 0.8.21;

interface IHook {
    /// @notice Hook function to check for liquidation opportunities before external swaps
    /// @dev The primary use of this hook is to check if a particular pair vault has liquidation available.
    ///      If liquidation is available, it gives priority to the liquidation process before allowing external swaps.
    ///      In most cases, this hook will not be set.
    /// @param id_ Identifier for the operation type: 1 for swap, 2 for internal arbitrage
    /// @param swap0to1_ Direction of the swap: true if swapping token0 for token1, false otherwise
    /// @param token0_ Address of the first token in the pair
    /// @param token1_ Address of the second token in the pair
    /// @param price_ The price ratio of token1 to token0, expressed with 27 decimal places
    /// @return isOk_ Boolean indicating whether the operation should proceed
    function dexPrice(
        uint id_,
        bool swap0to1_,
        address token0_,
        address token1_,
        uint price_
    ) external returns (bool isOk_);
}

interface ICenterPrice {
    /// @notice Retrieves the center price for the pool
    /// @dev This function is marked as non-constant (potentially state-changing) to allow flexibility in price fetching mechanisms.
    ///      While typically used as a read-only operation, this design permits write operations if needed for certain token pairs
    ///      (e.g., fetching up-to-date exchange rates that may require state changes).
    /// @return price The current price ratio of token1 to token0, expressed with 27 decimal places
    function centerPrice() external returns (uint price);
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

// File: contracts/libraries/dexSlotsLink.sol

pragma solidity 0.8.21;

/// @notice library that helps in reading / working with storage slot data of Fluid Dex.
/// @dev as all data for Fluid Dex is internal, any data must be fetched directly through manual
/// slot reading through this library or, if gas usage is less important, through the FluidDexResolver.
library DexSlotsLink {
    /// @dev storage slot for variables at Dex
    uint256 internal constant DEX_VARIABLES_SLOT = 0;
    /// @dev storage slot for variables2 at Dex
    uint256 internal constant DEX_VARIABLES2_SLOT = 1;
    /// @dev storage slot for total supply shares at Dex
    uint256 internal constant DEX_TOTAL_SUPPLY_SHARES_SLOT = 2;
    /// @dev storage slot for user supply mapping at Dex
    uint256 internal constant DEX_USER_SUPPLY_MAPPING_SLOT = 3;
    /// @dev storage slot for total borrow shares at Dex
    uint256 internal constant DEX_TOTAL_BORROW_SHARES_SLOT = 4;
    /// @dev storage slot for user borrow mapping at Dex
    uint256 internal constant DEX_USER_BORROW_MAPPING_SLOT = 5;
    /// @dev storage slot for oracle mapping at Dex
    uint256 internal constant DEX_ORACLE_MAPPING_SLOT = 6;
    /// @dev storage slot for range and threshold shifts at Dex
    uint256 internal constant DEX_RANGE_THRESHOLD_SHIFTS_SLOT = 7;
    /// @dev storage slot for center price shift at Dex
    uint256 internal constant DEX_CENTER_PRICE_SHIFT_SLOT = 8;

    // --------------------------------
    // @dev stacked uint256 storage slots bits position data for each:

    // UserSupplyData
    uint256 internal constant BITS_USER_SUPPLY_ALLOWED = 0;
    uint256 internal constant BITS_USER_SUPPLY_AMOUNT = 1;
    uint256 internal constant BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT = 65;
    uint256 internal constant BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_SUPPLY_BASE_WITHDRAWAL_LIMIT = 200;

    // UserBorrowData
    uint256 internal constant BITS_USER_BORROW_ALLOWED = 0;
    uint256 internal constant BITS_USER_BORROW_AMOUNT = 1;
    uint256 internal constant BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT = 65;
    uint256 internal constant BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_BORROW_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_BORROW_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_BORROW_BASE_BORROW_LIMIT = 200;
    uint256 internal constant BITS_USER_BORROW_MAX_BORROW_LIMIT = 218;

    // --------------------------------

    /// @notice Calculating the slot ID for Dex contract for single mapping at `slot_` for `key_`
    function calculateMappingStorageSlot(uint256 slot_, address key_) internal pure returns (bytes32) {
        return keccak256(abi.encode(key_, slot_));
    }

    /// @notice Calculating the slot ID for Dex contract for double mapping at `slot_` for `key1_` and `key2_`
    function calculateDoubleMappingStorageSlot(
        uint256 slot_,
        address key1_,
        address key2_
    ) internal pure returns (bytes32) {
        bytes32 intermediateSlot_ = keccak256(abi.encode(key1_, slot_));
        return keccak256(abi.encode(key2_, intermediateSlot_));
    }
}

// File: contracts/libraries/dexCalcs.sol

pragma solidity 0.8.21;




// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// @DEV ATTENTION: ON ANY CHANGES HERE, MAKE SURE THAT LOGIC IN VAULTS WILL STILL BE VALID.
// SOME CODE THERE ASSUMES DEXCALCS == LIQUIDITYCALCS.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

/// @notice implements calculation methods used for Fluid Dex such as updated withdrawal / borrow limits.
library DexCalcs {
    // constants used for BigMath conversion from and to storage
    uint256 internal constant DEFAULT_EXPONENT_SIZE = 8;
    uint256 internal constant DEFAULT_EXPONENT_MASK = 0xFF;

    uint256 internal constant FOUR_DECIMALS = 1e4;
    uint256 internal constant X14 = 0x3fff;
    uint256 internal constant X18 = 0x3ffff;
    uint256 internal constant X24 = 0xffffff;
    uint256 internal constant X33 = 0x1ffffffff;
    uint256 internal constant X64 = 0xffffffffffffffff;

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
        uint256 lastWithdrawalLimit_ = (userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT) &
            X64;
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
                (((userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_EXPAND_PERCENT) & X14) * userSupply_) /
                FOUR_DECIMALS;

            // time elapsed since last withdrawal limit was set (in seconds)
            // @dev last process timestamp is guaranteed to exist for withdrawal, as a supply must have happened before.
            // last timestamp can not be > current timestamp
            temp_ = block.timestamp - ((userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP) & X33);
        }
        // calculate withdrawable amount of expandPercent that is elapsed of expandDuration.
        // e.g. if 60% of expandDuration has elapsed, then user should be able to withdraw 6% of user supply, down to 94%.
        // Note: no explicit check for this needed, it is covered by setting minWithdrawalLimit_ if needed.
        temp_ =
            (maxWithdrawableLimit_ * temp_) /
            // extract expand duration: After this, decrement won't happen (user can withdraw 100% of withdraw limit)
            ((userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_EXPAND_DURATION) & X24); // expand duration can never be 0
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
        uint256 temp_ = (userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_BASE_WITHDRAWAL_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        // if user supply is below base limit then max withdrawals are allowed
        if (userSupply_ < temp_) {
            return 0;
        }
        // temp_ => withdrawal limit expandPercent (is in 1e2 decimals)
        temp_ = (userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_EXPAND_PERCENT) & X14;
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
        uint256 temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_EXPAND_PERCENT) & X14;

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
        currentBorrowLimit_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_BASE_BORROW_LIMIT) & X18;
        currentBorrowLimit_ =
            (currentBorrowLimit_ >> DEFAULT_EXPONENT_SIZE) <<
            (currentBorrowLimit_ & DEFAULT_EXPONENT_MASK);

        if (maxExpandedBorrowLimit_ < currentBorrowLimit_) {
            return currentBorrowLimit_;
        }
        // time elapsed since last borrow limit was set (in seconds)
        unchecked {
            // temp_ = timeElapsed_ (last timestamp can not be > current timestamp)
            temp_ = block.timestamp - ((userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP) & X33); // extract last update timestamp
        }

        // currentBorrowLimit_ = expandedBorrowableAmount + extract last set borrow limit
        currentBorrowLimit_ =
            // calculate borrow limit expansion since last interaction for `expandPercent` that is elapsed of `expandDuration`.
            // divisor is extract expand duration (after this, full expansion to expandPercentage happened).
            ((maxExpansionLimit_ * temp_) /
                ((userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_EXPAND_DURATION) & X24)) + // expand duration can never be 0
            //  extract last set borrow limit
            BigMathMinified.fromBigNumber(
                (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT) & X64,
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
        temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_MAX_BORROW_LIMIT) & X18;
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
        uint256 temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_EXPAND_PERCENT) & X14; // (is in 1e2 decimals)

        unchecked {
            // borrowLimit_ = calculate maximum borrow limit at full expansion.
            // userBorrow_ needs to be at least 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            borrowLimit_ = userBorrow_ + ((userBorrow_ * temp_) / FOUR_DECIMALS);
        }

        // temp_ = extract base borrow limit
        temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_BASE_BORROW_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        if (borrowLimit_ < temp_) {
            // below base limit, borrow limit is always base limit
            return temp_;
        }
        // temp_ = extract hard max borrow limit. Above this user can never borrow (not expandable above)
        temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_MAX_BORROW_LIMIT) & X18;
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
}

// File: contracts/libraries/addressCalcs.sol

pragma solidity 0.8.21;

/// @notice implements calculation of address for contracts deployed through CREATE.
/// Accepts contract deployed from which address & nonce
library AddressCalcs {

    /// @notice                         Computes the address of a contract based
    /// @param deployedFrom_            Address from which the contract was deployed
    /// @param nonce_                   Nonce at which the contract was deployed
    /// @return contract_               Address of deployed contract
    function addressCalc(address deployedFrom_, uint nonce_) internal pure returns (address contract_) {
        // @dev based on https://ethereum.stackexchange.com/a/61413

        // nonce of smart contract always starts with 1. so, with nonce 0 there won't be any deployment
        // hence, nonce of vault deployment starts with 1.
        bytes memory data;
        if (nonce_ == 0x00) {
            return address(0);
        } else if (nonce_ <= 0x7f) {
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployedFrom_, uint8(nonce_));
        } else if (nonce_ <= 0xff) {
            data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), deployedFrom_, bytes1(0x81), uint8(nonce_));
        } else if (nonce_ <= 0xffff) {
            data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), deployedFrom_, bytes1(0x82), uint16(nonce_));
        } else if (nonce_ <= 0xffffff) {
            data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), deployedFrom_, bytes1(0x83), uint24(nonce_));
        } else {
            data = abi.encodePacked(bytes1(0xda), bytes1(0x94), deployedFrom_, bytes1(0x84), uint32(nonce_));
        }

        return address(uint160(uint256(keccak256(data))));
    }

}

// File: contracts/protocols/dex/poolT1/coreModule/helpers/coreHelpers.sol

pragma solidity 0.8.21;















interface IShifting {
    /// @dev Calculates the new upper and lower range values during an active range shift
    /// @param upperRange_ The target upper range value
    /// @param lowerRange_ The target lower range value
    /// @param dexVariables2_ needed in case shift is ended and we need to update dexVariables2
    /// @return The updated upper range, lower range, and dexVariables2
    function _calcRangeShifting(
        uint upperRange_,
        uint lowerRange_,
        uint dexVariables2_
    ) external payable returns (uint, uint, uint);

    /// @dev Calculates the new threshold values during an active threshold shift
    /// @param upperThreshold_ The target upper threshold value
    /// @param lowerThreshold_ The target lower threshold value
    /// @param dexVariables2_ needed in case shift is ended and we need to update dexVariables2
    /// @return The updated upper threshold, lower threshold, and dexVariables2
    function _calcThresholdShifting(
        uint upperThreshold_,
        uint lowerThreshold_,
        uint dexVariables2_
    ) external payable returns (uint, uint, uint);

    /// @dev Calculates the new center price during an active center price shift
    /// @param dexVariables_ The current state of dex variables
    /// @param dexVariables2_ Additional dex variables
    /// @return The updated center price
    function _calcCenterPrice(
        uint dexVariables_,
        uint dexVariables2_
    ) external payable returns (uint);
}

abstract contract CoreHelpers is Variables, ImmutableVariables, Events {
    using BigMathMinified for uint256;

    /// @dev            do any arbitrary call
    /// @param target_  Address to which the call needs to be delegated
    /// @param data_    Data to execute at the delegated address
    function _spell(address target_, bytes memory data_) internal returns (bytes memory response_) {
        assembly {
            let succeeded := delegatecall(gas(), target_, add(data_, 0x20), mload(data_), 0, 0)
            let size := returndatasize()

            response_ := mload(0x40)
            mstore(0x40, add(response_, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response_, size)
            returndatacopy(add(response_, 0x20), 0, size)

            if iszero(succeeded) {
                // throw if delegatecall failed
                returndatacopy(0x00, 0x00, size)
                revert(0x00, size)
            }
        }
    }

    /// @dev Given an input amount of asset and pair reserves, returns the maximum output amount of the other asset
    /// @param amountIn_ The amount of input asset.
    /// @param iReserveIn_ Imaginary token reserve with input amount.
    /// @param iReserveOut_ Imaginary token reserve of output amount.
    function _getAmountOut(
        uint256 amountIn_,
        uint iReserveIn_,
        uint iReserveOut_
    ) internal pure returns (uint256 amountOut_) {
        unchecked {
            // Both numerator and denominator are scaled to 1e6 to factor in fee scaling.
            uint256 numerator_ = amountIn_ * iReserveOut_;
            uint256 denominator_ = iReserveIn_ + amountIn_;

            // Using the swap formula: (AmountIn * iReserveY) / (iReserveX + AmountIn)
            amountOut_ = numerator_ / denominator_;
        }
    }

    /// @dev Given an output amount of asset and pair reserves, returns the input amount of the other asset
    /// @param amountOut_ Desired output amount of the asset.
    /// @param iReserveIn_ Imaginary token reserve of input amount.
    /// @param iReserveOut_ Imaginary token reserve of output amount.
    function _getAmountIn(
        uint256 amountOut_,
        uint iReserveIn_,
        uint iReserveOut_
    ) internal pure returns (uint256 amountIn_) {
        // Both numerator and denominator are scaled to 1e6 to factor in fee scaling.
        uint256 numerator_ = amountOut_ * iReserveIn_;
        uint256 denominator_ = iReserveOut_ - amountOut_;

        // Using the swap formula: (AmountOut * iReserveX) / (iReserveY - AmountOut)
        amountIn_ = numerator_ / denominator_;
    }

    /// @param t total amount in
    /// @param x imaginary reserves of token out of collateral
    /// @param y imaginary reserves of token in of collateral
    /// @param x2 imaginary reserves of token out of debt
    /// @param y2 imaginary reserves of token in of debt
    /// @return a_ how much swap should go through collateral pool. Remaining will go from debt
    /// note if a < 0 then entire trade route through debt pool and debt pool arbitrage with col pool
    /// note if a > t then entire trade route through col pool and col pool arbitrage with debt pool
    /// note if a > 0 & a < t then swap will route through both pools
    function _swapRoutingIn(uint t, uint x, uint y, uint x2, uint y2) internal pure returns (int a_) {
        // Main equations:
        // 1. out = x * a / (y + a)
        // 2. out2 = x2 * (t - a) / (y2 + (t - a))
        // final price should be same
        // 3. (y + a) / (x - out) = (y2 + (t - a)) / (x2 - out2)
        // derivation: https://chatgpt.com/share/dce6f381-ee5f-4d5f-b6ea-5996e84d5b57

        // adding 1e18 precision
        uint xyRoot_ = FixedPointMathLib.sqrt(x * y * 1e18);
        uint x2y2Root_ = FixedPointMathLib.sqrt(x2 * y2 * 1e18);

        a_ = (int(y2 * xyRoot_ + t * xyRoot_) - int(y * x2y2Root_)) / int(xyRoot_ + x2y2Root_);
    }

    /// @param t total amount out
    /// @param x imaginary reserves of token in of collateral
    /// @param y imaginary reserves of token out of collateral
    /// @param x2 imaginary reserves of token in of debt
    /// @param y2 imaginary reserves of token out of debt
    /// @return a_ how much swap should go through collateral pool. Remaining will go from debt
    /// note if a < 0 then entire trade route through debt pool and debt pool arbitrage with col pool
    /// note if a > t then entire trade route through col pool and col pool arbitrage with debt pool
    /// note if a > 0 & a < t then swap will route through both pools
    function _swapRoutingOut(uint t, uint x, uint y, uint x2, uint y2) internal pure returns (int a_) {
        // Main equations:
        // 1. in = (x * a) / (y - a)
        // 2. in2 = (x2 * (t - a)) / (y2 - (t - a))
        // final price should be same
        // 3. (y - a) / (x + in) = (y2 - (t - a)) / (x2 + in2)
        // derivation: https://chatgpt.com/share/6585bc28-841f-49ec-aea2-1e5c5b7f4fa9

        // adding 1e18 precision
        uint xyRoot_ = FixedPointMathLib.sqrt(x * y * 1e18);
        uint x2y2Root_ = FixedPointMathLib.sqrt(x2 * y2 * 1e18);

        // 1e18 precision gets cancelled out in division
        a_ = (int(t * xyRoot_ + y * x2y2Root_) - int(y2 * xyRoot_)) / int(xyRoot_ + x2y2Root_);
    }

    function _utilizationVerify(uint utilizationLimit_, bytes32 exchangePriceSlot_) internal view {
        if (utilizationLimit_ < THREE_DECIMALS) {
            utilizationLimit_ = utilizationLimit_ * 10;
            // extracting utilization of token from liquidity layer
            uint liquidityLayerUtilization_ = LIQUIDITY.readFromStorage(exchangePriceSlot_);
            liquidityLayerUtilization_ =
                (liquidityLayerUtilization_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_UTILIZATION) &
                X14;
            // Note: this can go slightly above the utilization limit if no update is written to storage at liquidity layer
            // if swap was not big enough to go far enough above or any other storage update threshold write cause there
            // so just to keep in mind when configuring the actual limit reachable can be utilizationLimit_ + storageUpdateThreshold at Liquidity
            if (liquidityLayerUtilization_ > utilizationLimit_)
                revert FluidDexError(ErrorTypes.DexT1__LiquidityLayerTokenUtilizationCapReached);
        }
    }

    function _check(uint dexVariables_, uint dexVariables2_) internal {
        if (dexVariables_ & 1 == 1) revert FluidDexError(ErrorTypes.DexT1__AlreadyEntered);
        if (dexVariables2_ & 3 == 0) revert FluidDexError(ErrorTypes.DexT1__PoolNotInitialized);
        // enabling re-entrancy
        dexVariables = dexVariables_ | 1;
    }

    /// @dev if token0 reserves are too low w.r.t token1 then revert, this is to avoid edge case scenario and making sure that precision on calculations should be high enough
    function _verifyToken0Reserves(
        uint token0Reserves_,
        uint token1Reserves_,
        uint centerPrice_,
        uint minLiquidity_
    ) internal pure {
        if (((token0Reserves_) < ((token1Reserves_ * 1e27) / (centerPrice_ * minLiquidity_)))) {
            revert FluidDexError(ErrorTypes.DexT1__TokenReservesTooLow);
        }
    }

    /// @dev if token1 reserves are too low w.r.t token0 then revert, this is to avoid edge case scenario and making sure that precision on calculations should be high enough
    function _verifyToken1Reserves(
        uint token0Reserves_,
        uint token1Reserves_,
        uint centerPrice_,
        uint minLiquidity_
    ) internal pure {
        if (((token1Reserves_) < ((token0Reserves_ * centerPrice_) / (1e27 * minLiquidity_)))) {
            revert FluidDexError(ErrorTypes.DexT1__TokenReservesTooLow);
        }
    }

    function _verifySwapAndNonPerfectActions(uint amountAdjusted_, uint amount_) internal pure {
        // after shifting amount should not become 0
        // limiting to six decimals which means in case of USDC, USDT it's 1 wei, for WBTC 100 wei, for ETH 1000 gwei
        if (amountAdjusted_ < SIX_DECIMALS || amountAdjusted_ > X96 || amount_ < TWO_DECIMALS || amount_ > X128)
            revert FluidDexError(ErrorTypes.DexT1__LimitingAmountsSwapAndNonPerfectActions);
    }

    /// @dev Calculates the new upper and lower range values during an active range shift
    /// @param upperRange_ The target upper range value
    /// @param lowerRange_ The target lower range value
    /// @param dexVariables2_ needed in case shift is ended and we need to update dexVariables2
    /// @return The updated upper range, lower range, and dexVariables2
    /// @notice This function handles the gradual shifting of range values over time
    /// @notice If the shift is complete, it updates the state and clears the shift data
    function _calcRangeShifting(
        uint upperRange_,
        uint lowerRange_,
        uint dexVariables2_
    ) internal returns (uint, uint, uint) {
        return
            abi.decode(
                _spell(
                    SHIFT_IMPLEMENTATION,
                    abi.encodeWithSelector(
                        IShifting._calcRangeShifting.selector,
                        upperRange_,
                        lowerRange_,
                        dexVariables2_
                    )
                ),
                (uint, uint, uint)
            );
    }

    /// @dev Calculates the new upper and lower threshold values during an active threshold shift
    /// @param upperThreshold_ The target upper threshold value
    /// @param lowerThreshold_ The target lower threshold value
    /// @param thresholdTime_ The time passed since shifting started
    /// @return The updated upper threshold, lower threshold, and threshold time
    /// @notice This function handles the gradual shifting of threshold values over time
    /// @notice If the shift is complete, it updates the state and clears the shift data
    function _calcThresholdShifting(
        uint upperThreshold_,
        uint lowerThreshold_,
        uint thresholdTime_
    ) internal returns (uint, uint, uint) {
        return
            abi.decode(
                _spell(
                    SHIFT_IMPLEMENTATION,
                    abi.encodeWithSelector(
                        IShifting._calcThresholdShifting.selector,
                        upperThreshold_,
                        lowerThreshold_,
                        thresholdTime_
                    )
                ),
                (uint, uint, uint)
            );
    }

    /// @dev Calculates the new center price during an active price shift
    /// @param dexVariables_ The current state of dex variables
    /// @param dexVariables2_ Additional dex variables
    /// @return newCenterPrice_ The updated center price
    /// @notice This function gradually shifts the center price towards a new target price over time
    /// @notice It uses an external price source (via ICenterPrice) to determine the target price
    /// @notice The shift continues until the current price reaches the target, or the shift duration ends
    /// @notice Once the shift is complete, it updates the state and clears the shift data
    /// @notice The shift rate is dynamic and depends on:
    /// @notice - Time remaining in the shift duration
    /// @notice - The new center price (fetched externally, which may change)
    /// @notice - The current (old) center price
    /// @notice This results in a fuzzy shifting mechanism where the rate can change as these parameters evolve
    /// @notice The externally fetched new center price is expected to not differ significantly from the last externally fetched center price
    function _calcCenterPrice(uint dexVariables_, uint dexVariables2_) internal returns (uint newCenterPrice_) {
        return
            abi.decode(
                _spell(
                    SHIFT_IMPLEMENTATION,
                    abi.encodeWithSelector(IShifting._calcCenterPrice.selector, dexVariables_, dexVariables2_)
                ),
                (uint)
            );
    }

    /// @notice Calculates and returns the current prices and exchange prices for the pool
    /// @param dexVariables_ The first set of DEX variables containing various pool parameters
    /// @param dexVariables2_ The second set of DEX variables containing additional pool parameters
    /// @return pex_ A struct containing the calculated prices and exchange prices:
    ///         - pex_.lastStoredPrice: The last stored price in 1e27 decimals
    ///         - pex_.centerPrice: The calculated or fetched center price in 1e27 decimals
    ///         - pex_.upperRange: The upper range price limit in 1e27 decimals
    ///         - pex_.lowerRange: The lower range price limit in 1e27 decimals
    ///         - pex_.geometricMean: The geometric mean of upper range & lower range in 1e27 decimals
    ///         - pex_.supplyToken0ExchangePrice: The current exchange price for supplying token0
    ///         - pex_.borrowToken0ExchangePrice: The current exchange price for borrowing token0
    ///         - pex_.supplyToken1ExchangePrice: The current exchange price for supplying token1
    ///         - pex_.borrowToken1ExchangePrice: The current exchange price for borrowing token1
    /// @dev This function performs the following operations:
    ///      1. Determines the center price (either from storage, external source, or calculated)
    ///      2. Retrieves the last stored price from dexVariables_
    ///      3. Calculates the upper and lower range prices based on the center price and range percentages
    ///      4. Checks if rebalancing is needed based on threshold settings
    ///      5. Adjusts prices if necessary based on the time elapsed and threshold conditions
    ///      6. Update the dexVariables2_ if changes were made
    ///      7. Returns the calculated prices and exchange prices in the PricesAndExchangePrice struct
    function _getPricesAndExchangePrices(
        uint dexVariables_,
        uint dexVariables2_
    ) internal returns (PricesAndExchangePrice memory pex_) {
        uint centerPrice_;

        if (((dexVariables2_ >> 248) & 1) == 0) {
            // centerPrice_ => center price hook
            centerPrice_ = (dexVariables2_ >> 112) & X30;
            if (centerPrice_ == 0) {
                centerPrice_ = (dexVariables_ >> 81) & X40;
                centerPrice_ = (centerPrice_ >> DEFAULT_EXPONENT_SIZE) << (centerPrice_ & DEFAULT_EXPONENT_MASK);
            } else {
                // center price should be fetched from external source. For exmaple, in case of wstETH <> ETH pool,
                // we would want the center price to be pegged to wstETH exchange rate into ETH
                centerPrice_ = ICenterPrice(AddressCalcs.addressCalc(DEPLOYER_CONTRACT, centerPrice_)).centerPrice();
            }
        } else {
            // an active centerPrice_ shift is going on
            centerPrice_ = _calcCenterPrice(dexVariables_, dexVariables2_);
        }

        uint lastStoredPrice_ = (dexVariables_ >> 41) & X40;
        lastStoredPrice_ = (lastStoredPrice_ >> DEFAULT_EXPONENT_SIZE) << (lastStoredPrice_ & DEFAULT_EXPONENT_MASK);

        uint upperRange_ = ((dexVariables2_ >> 27) & X20);
        uint lowerRange_ = ((dexVariables2_ >> 47) & X20);
        if (((dexVariables2_ >> 26) & 1) == 1) {
            // an active range shift is going on
            (upperRange_, lowerRange_, dexVariables2_) = _calcRangeShifting(upperRange_, lowerRange_, dexVariables2_);
        }

        unchecked {
            // adding into unchecked because upperRange_ & lowerRange_ can only be > 0 & < SIX_DECIMALS
            // 1% = 1e4, 100% = 1e6
            upperRange_ = (centerPrice_ * SIX_DECIMALS) / (SIX_DECIMALS - upperRange_);
            // 1% = 1e4, 100% = 1e6
            lowerRange_ = (centerPrice_ * (SIX_DECIMALS - lowerRange_)) / SIX_DECIMALS;
        }

        bool changed_;
        {
            // goal will be to keep threshold percents 0 if center price is fetched from external source
            // checking if threshold are set non 0 then only rebalancing is on
            if (((dexVariables2_ >> 68) & X20) > 0) {
                uint upperThreshold_ = (dexVariables2_ >> 68) & X10;
                uint lowerThreshold_ = (dexVariables2_ >> 78) & X10;
                uint shiftingTime_ = (dexVariables2_ >> 88) & X24;
                if (((dexVariables2_ >> 67) & 1) == 1) {
                    // if active shift is going on for threshold then calculate threshold real time
                    (upperThreshold_, lowerThreshold_, shiftingTime_) = _calcThresholdShifting(
                        upperThreshold_,
                        lowerThreshold_,
                        shiftingTime_
                    );
                }

                unchecked {
                    if (
                        lastStoredPrice_ >
                        (centerPrice_ +
                            ((upperRange_ - centerPrice_) * (THREE_DECIMALS - upperThreshold_)) /
                            THREE_DECIMALS)
                    ) {
                        uint timeElapsed_ = block.timestamp - ((dexVariables_ >> 121) & X33);
                        // price shifting towards upper range
                        if (timeElapsed_ < shiftingTime_) {
                            centerPrice_ = centerPrice_ + ((upperRange_ - centerPrice_) * timeElapsed_) / shiftingTime_;
                        } else {
                            // 100% price shifted
                            centerPrice_ = upperRange_;
                        }
                        changed_ = true;
                    } else if (
                        lastStoredPrice_ <
                        (centerPrice_ -
                            ((centerPrice_ - lowerRange_) * (THREE_DECIMALS - lowerThreshold_)) /
                            THREE_DECIMALS)
                    ) {
                        uint timeElapsed_ = block.timestamp - ((dexVariables_ >> 121) & X33);
                        // price shifting towards lower range
                        if (timeElapsed_ < shiftingTime_) {
                            centerPrice_ = centerPrice_ - ((centerPrice_ - lowerRange_) * timeElapsed_) / shiftingTime_;
                        } else {
                            // 100% price shifted
                            centerPrice_ = lowerRange_;
                        }
                        changed_ = true;
                    }
                }
            }
        }

        // temp_ => max center price
        uint temp_ = (dexVariables2_ >> 172) & X28;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);
        if (centerPrice_ > temp_) {
            // if center price is greater than max center price
            centerPrice_ = temp_;
            changed_ = true;
        } else {
            // check if center price is less than min center price
            // temp_ => min center price
            temp_ = (dexVariables2_ >> 200) & X28;
            temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);
            if (centerPrice_ < temp_) {
                centerPrice_ = temp_;
                changed_ = true;
            }
        }

        // if centerPrice_ is changed then calculating upper and lower range again
        if (changed_) {
            upperRange_ = ((dexVariables2_ >> 27) & X20);
            lowerRange_ = ((dexVariables2_ >> 47) & X20);
            if (((dexVariables2_ >> 26) & 1) == 1) {
                (upperRange_, lowerRange_, dexVariables2_) = _calcRangeShifting(
                    upperRange_,
                    lowerRange_,
                    dexVariables2_
                );
            }

            unchecked {
                // adding into unchecked because upperRange_ & lowerRange_ can only be > 0 & < SIX_DECIMALS
                // 1% = 1e4, 100% = 1e6
                upperRange_ = (centerPrice_ * SIX_DECIMALS) / (SIX_DECIMALS - upperRange_);
                // 1% = 1e4, 100% = 1e6
                lowerRange_ = (centerPrice_ * (SIX_DECIMALS - lowerRange_)) / SIX_DECIMALS;
            }
        }

        pex_.lastStoredPrice = lastStoredPrice_;
        pex_.centerPrice = centerPrice_;
        pex_.upperRange = upperRange_;
        pex_.lowerRange = lowerRange_;

        unchecked {
            if (upperRange_ < 1e38) {
                // 1e38 * 1e38 = 1e76 which is less than max uint limit
                pex_.geometricMean = FixedPointMathLib.sqrt(upperRange_ * lowerRange_);
            } else {
                // upperRange_ price is pretty large hence lowerRange_ will also be pretty large
                pex_.geometricMean = FixedPointMathLib.sqrt((upperRange_ / 1e18) * (lowerRange_ / 1e18)) * 1e18;
            }
        }

        // Exchange price will remain same as Liquidity Layer
        (pex_.supplyToken0ExchangePrice, pex_.borrowToken0ExchangePrice) = LiquidityCalcs.calcExchangePrices(
            LIQUIDITY.readFromStorage(EXCHANGE_PRICE_TOKEN_0_SLOT)
        );

        (pex_.supplyToken1ExchangePrice, pex_.borrowToken1ExchangePrice) = LiquidityCalcs.calcExchangePrices(
            LIQUIDITY.readFromStorage(EXCHANGE_PRICE_TOKEN_1_SLOT)
        );
    }

    /// @dev getting reserves outside range.
    /// @param gp_ is geometric mean pricing of upper percent & lower percent
    /// @param pa_ price of upper range or lower range
    /// @param rx_ real reserves of token0 or token1
    /// @param ry_ whatever is rx_ the other will be ry_
    function _calculateReservesOutsideRange(
        uint gp_,
        uint pa_,
        uint rx_,
        uint ry_
    ) internal pure returns (uint xa_, uint yb_) {
        // equations we have:
        // 1. x*y = k
        // 2. xa*ya = k
        // 3. xb*yb = k
        // 4. Pa = ya / xa = upperRange_ (known)
        // 5. Pb = yb / xb = lowerRange_ (known)
        // 6. x - xa = rx = real reserve of x (known)
        // 7. y - yb = ry = real reserve of y (known)
        // With solving we get:
        // ((Pa*Pb)^(1/2) - Pa)*xa^2 + (rx * (Pa*Pb)^(1/2) + ry)*xa + rx*ry = 0
        // yb = yb = xa * (Pa * Pb)^(1/2)

        // xa = (GP⋅rx + ry + (-rx⋅ry⋅4⋅(GP - Pa) + (GP⋅rx + ry)^2)^0.5) / (2Pa - 2GP)
        // multiply entire equation by 1e27 to remove the price decimals precision of 1e27
        // xa = (GP⋅rx + ry⋅1e27 + (rx⋅ry⋅4⋅(Pa - GP)⋅1e27 + (GP⋅rx + ry⋅1e27)^2)^0.5) / 2*(Pa - GP)
        // dividing the equation with 2*(Pa - GP). Pa is always > GP so answer will be positive.
        // xa = (((GP⋅rx + ry⋅1e27) / 2*(Pa - GP)) + (((rx⋅ry⋅4⋅(Pa - GP)⋅1e27) / 4*(Pa - GP)^2) + ((GP⋅rx + ry⋅1e27) / 2*(Pa - GP))^2)^0.5)
        // xa = (((GP⋅rx + ry⋅1e27) / 2*(Pa - GP)) + (((rx⋅ry⋅1e27) / (Pa - GP)) + ((GP⋅rx + ry⋅1e27) / 2*(Pa - GP))^2)^0.5)

        // dividing in 3 parts for simplification:
        // part1 = (Pa - GP)
        // part2 = (GP⋅rx + ry⋅1e27) / (2*part1)
        // part3 = rx⋅ry
        // note: part1 will almost always be < 1e28 but in case it goes above 1e27 then it's extremely unlikely it'll go above > 1e29
        uint p1_ = pa_ - gp_;
        uint p2_ = ((gp_ * rx_) + (ry_ * 1e27)) / (2 * p1_);
        uint p3_ = rx_ * ry_;
        // to avoid overflowing
        p3_ = (p3_ < 1e50) ? ((p3_ * 1e27) / p1_) : (p3_ / p1_) * 1e27;

        // xa = part2 + (part3 + (part2 * part2))^(1/2)
        // yb = xa_ * gp_
        xa_ = p2_ + FixedPointMathLib.sqrt((p3_ + (p2_ * p2_)));
        yb_ = (xa_ * gp_) / 1e27;
    }

    /// @dev Retrieves collateral amount from liquidity layer for a given token
    /// @param supplyTokenSlot_ The storage slot for the supply token data
    /// @param tokenExchangePrice_ The exchange price of the token
    /// @param isToken0_ Boolean indicating if the token is token0 (true) or token1 (false)
    /// @return tokenSupply_ The calculated liquidity collateral amount
    function _getLiquidityCollateral(
        bytes32 supplyTokenSlot_,
        uint tokenExchangePrice_,
        bool isToken0_
    ) internal view returns (uint tokenSupply_) {
        uint tokenSupplyData_ = LIQUIDITY.readFromStorage(supplyTokenSlot_);
        tokenSupply_ = (tokenSupplyData_ >> LiquiditySlotsLink.BITS_USER_SUPPLY_AMOUNT) & X64;
        tokenSupply_ = (tokenSupply_ >> DEFAULT_EXPONENT_SIZE) << (tokenSupply_ & DEFAULT_EXPONENT_MASK);

        if (tokenSupplyData_ & 1 == 1) {
            // supply with interest is on
            unchecked {
                tokenSupply_ = (tokenSupply_ * tokenExchangePrice_) / LiquidityCalcs.EXCHANGE_PRICES_PRECISION;
            }
        }

        unchecked {
            tokenSupply_ = isToken0_
                ? ((tokenSupply_ * TOKEN_0_NUMERATOR_PRECISION) / TOKEN_0_DENOMINATOR_PRECISION)
                : ((tokenSupply_ * TOKEN_1_NUMERATOR_PRECISION) / TOKEN_1_DENOMINATOR_PRECISION);
        }
    }

    /// @notice Calculates the real and imaginary reserves for collateral tokens
    /// @dev This function retrieves the supply of both tokens from the liquidity layer,
    ///      adjusts them based on exchange prices, and calculates imaginary reserves
    ///      based on the geometric mean and price range
    /// @param geometricMean_ The geometric mean of the token prices
    /// @param upperRange_ The upper price range
    /// @param lowerRange_ The lower price range
    /// @param token0SupplyExchangePrice_ The exchange price for token0 from liquidity layer
    /// @param token1SupplyExchangePrice_ The exchange price for token1 from liquidity layer
    /// @return c_ A struct containing the calculated real and imaginary reserves for both tokens:
    ///         - token0RealReserves: The real reserves of token0
    ///         - token1RealReserves: The real reserves of token1
    ///         - token0ImaginaryReserves: The imaginary reserves of token0
    ///         - token1ImaginaryReserves: The imaginary reserves of token1
    function _getCollateralReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0SupplyExchangePrice_,
        uint token1SupplyExchangePrice_
    ) internal view returns (CollateralReserves memory c_) {
        uint token0Supply_ = _getLiquidityCollateral(SUPPLY_TOKEN_0_SLOT, token0SupplyExchangePrice_, true);
        uint token1Supply_ = _getLiquidityCollateral(SUPPLY_TOKEN_1_SLOT, token1SupplyExchangePrice_, false);

        if (geometricMean_ < 1e27) {
            (c_.token0ImaginaryReserves, c_.token1ImaginaryReserves) = _calculateReservesOutsideRange(
                geometricMean_,
                upperRange_,
                token0Supply_,
                token1Supply_
            );
        } else {
            // inversing, something like `xy = k` so for calculation we are making everything related to x into y & y into x
            // 1 / geometricMean for new geometricMean
            // 1 / lowerRange will become upper range
            // 1 / upperRange will become lower range
            (c_.token1ImaginaryReserves, c_.token0ImaginaryReserves) = _calculateReservesOutsideRange(
                (1e54 / geometricMean_),
                (1e54 / lowerRange_),
                token1Supply_,
                token0Supply_
            );
        }

        c_.token0RealReserves = token0Supply_;
        c_.token1RealReserves = token1Supply_;
        unchecked {
            c_.token0ImaginaryReserves += token0Supply_;
            c_.token1ImaginaryReserves += token1Supply_;
        }
    }

    /// @notice Calculates the real and imaginary debt reserves for both tokens
    /// @dev This function uses a quadratic equation to determine the debt reserves
    ///      based on the geometric mean price and the current debt amounts
    /// @param gp_ The geometric mean price of upper range & lower range
    /// @param pb_ The price of lower range
    /// @param dx_ The debt amount of one token
    /// @param dy_ The debt amount of the other token
    /// @return rx_ The real debt reserve of the first token
    /// @return ry_ The real debt reserve of the second token
    /// @return irx_ The imaginary debt reserve of the first token
    /// @return iry_ The imaginary debt reserve of the second token
    function _calculateDebtReserves(
        uint gp_,
        uint pb_,
        uint dx_,
        uint dy_
    ) internal pure returns (uint rx_, uint ry_, uint irx_, uint iry_) {
        // Assigning letter to knowns:
        // c = debtA
        // d = debtB
        // e = upperPrice
        // f = lowerPrice
        // g = upperPrice^1/2
        // h = lowerPrice^1/2

        // c = 1
        // d = 2000
        // e = 2222.222222
        // f = 1800
        // g = 2222.222222^1/2
        // h = 1800^1/2

        // Assigning letter to unknowns:
        // w = realDebtReserveA
        // x = realDebtReserveB
        // y = imaginaryDebtReserveA
        // z = imaginaryDebtReserveB
        // k = k

        // below quadratic will give answer of realDebtReserveB
        // A, B, C of quadratic equation:
        // A = h
        // B = dh - cfg
        // C = -cfdh

        // A = lowerPrice^1/2
        // B = debtB⋅lowerPrice^1/2 - debtA⋅lowerPrice⋅upperPrice^1/2
        // C = -(debtA⋅lowerPrice⋅debtB⋅lowerPrice^1/2)

        // x = (cfg − dh + (4cdf(h^2)+(cfg−dh)^2))^(1/2)) / 2h
        // simplifying dividing by h, note h = f^1/2
        // x = ((c⋅g⋅(f^1/2) − d) / 2 + ((4⋅c⋅d⋅f⋅f) / (4h^2) + ((c⋅f⋅g) / 2h − (d⋅h) / 2h)^2))^(1/2))
        // x = ((c⋅g⋅(f^1/2) − d) / 2 + ((c⋅d⋅f) + ((c⋅g⋅(f^1/2) − d) / 2)^2))^(1/2))

        // dividing in 3 parts for simplification:
        // part1 = (c⋅g⋅(f^1/2) − d) / 2
        // part2 = (c⋅d⋅f)
        // x = (part1 + (part2 + part1^2)^(1/2))
        // note: part1 will almost always be < 1e27 but in case it goes above 1e27 then it's extremely unlikely it'll go above > 1e28

        // part1 = ((debtA * upperPrice^1/2 * lowerPrice^1/2) - debtB) / 2
        // note: upperPrice^1/2 * lowerPrice^1/2 = geometric mean
        // part1 = ((debtA * geometricMean) - debtB) / 2
        // part2 = debtA * debtB * lowerPrice

        // converting decimals properly as price is in 1e27 decimals
        // part1 = ((debtA * geometricMean) - (debtB * 1e27)) / (2 * 1e27)
        // part2 = (debtA * debtB * lowerPrice) / 1e27
        // final x equals:
        // x = (part1 + (part2 + part1^2)^(1/2))
        int p1_ = (int(dx_ * gp_) - int(dy_ * 1e27)) / (2 * 1e27);
        uint p2_ = (dx_ * dy_);
        p2_ = p2_ < 1e50 ? (p2_ * pb_) / 1e27 : (p2_ / 1e27) * pb_;
        ry_ = uint(p1_ + int(FixedPointMathLib.sqrt((p2_ + uint(p1_ * p1_)))));

        // finding z:
        // x^2 - zx + cfz = 0
        // z*(x - cf) = x^2
        // z = x^2 / (x - cf)
        // z = x^2 / (x - debtA * lowerPrice)
        // converting decimals properly as price is in 1e27 decimals
        // z = (x^2 * 1e27) / ((x * 1e27) - (debtA * lowerPrice))

        iry_ = ((ry_ * 1e27) - (dx_ * pb_));
        if (iry_ < SIX_DECIMALS) {
            // almost impossible situation to ever get here
            revert FluidDexError(ErrorTypes.DexT1__DebtReservesTooLow);
        }
        if (ry_ < 1e25) {
            iry_ = (ry_ * ry_ * 1e27) / iry_;
        } else {
            // note: it can never result in negative as final result will always be in positive
            iry_ = (ry_ * ry_) / (iry_ / 1e27);
        }

        // finding y
        // x = z * c / (y + c)
        // y + c = z * c / x
        // y = (z * c / x) - c
        // y = (z * debtA / x) - debtA
        irx_ = ((iry_ * dx_) / ry_) - dx_;

        // finding w
        // w = y * d / (z + d)
        // w = (y * debtB) / (z + debtB)
        rx_ = (irx_ * dy_) / (iry_ + dy_);
    }

    /// @notice Calculates the debt amount for a given token from liquidity layer
    /// @param borrowTokenSlot_ The storage slot for the token's borrow data
    /// @param tokenExchangePrice_ The current exchange price of the token
    /// @param isToken0_ Boolean indicating if this is for token0 (true) or token1 (false)
    /// @return tokenDebt_ The calculated debt amount for the token
    function _getLiquidityDebt(
        bytes32 borrowTokenSlot_,
        uint tokenExchangePrice_,
        bool isToken0_
    ) internal view returns (uint tokenDebt_) {
        uint tokenBorrowData_ = LIQUIDITY.readFromStorage(borrowTokenSlot_);

        tokenDebt_ = (tokenBorrowData_ >> LiquiditySlotsLink.BITS_USER_BORROW_AMOUNT) & X64;
        tokenDebt_ = (tokenDebt_ >> 8) << (tokenDebt_ & X8);

        if (tokenBorrowData_ & 1 == 1) {
            // borrow with interest is on
            unchecked {
                tokenDebt_ = (tokenDebt_ * tokenExchangePrice_) / LiquidityCalcs.EXCHANGE_PRICES_PRECISION;
            }
        }

        unchecked {
            tokenDebt_ = isToken0_
                ? ((tokenDebt_ * TOKEN_0_NUMERATOR_PRECISION) / TOKEN_0_DENOMINATOR_PRECISION)
                : ((tokenDebt_ * TOKEN_1_NUMERATOR_PRECISION) / TOKEN_1_DENOMINATOR_PRECISION);
        }
    }

    /// @notice Calculates the debt reserves for both tokens
    /// @param geometricMean_ The geometric mean of the upper and lower price ranges
    /// @param upperRange_ The upper price range
    /// @param lowerRange_ The lower price range
    /// @param token0BorrowExchangePrice_ The exchange price of token0 from liquidity layer
    /// @param token1BorrowExchangePrice_ The exchange price of token1 from liquidity layer
    /// @return d_ The calculated debt reserves for both tokens, containing:
    ///         - token0Debt: The debt amount of token0
    ///         - token1Debt: The debt amount of token1
    ///         - token0RealReserves: The real reserves of token0 derived from token1 debt
    ///         - token1RealReserves: The real reserves of token1 derived from token0 debt
    ///         - token0ImaginaryReserves: The imaginary debt reserves of token0
    ///         - token1ImaginaryReserves: The imaginary debt reserves of token1
    function _getDebtReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0BorrowExchangePrice_,
        uint token1BorrowExchangePrice_
    ) internal view returns (DebtReserves memory d_) {
        uint token0Debt_ = _getLiquidityDebt(BORROW_TOKEN_0_SLOT, token0BorrowExchangePrice_, true);
        uint token1Debt_ = _getLiquidityDebt(BORROW_TOKEN_1_SLOT, token1BorrowExchangePrice_, false);

        d_.token0Debt = token0Debt_;
        d_.token1Debt = token1Debt_;

        if (geometricMean_ < 1e27) {
            (
                d_.token0RealReserves,
                d_.token1RealReserves,
                d_.token0ImaginaryReserves,
                d_.token1ImaginaryReserves
            ) = _calculateDebtReserves(geometricMean_, lowerRange_, token0Debt_, token1Debt_);
        } else {
            // inversing, something like `xy = k` so for calculation we are making everything related to x into y & y into x
            // 1 / geometricMean for new geometricMean
            // 1 / lowerRange will become upper range
            // 1 / upperRange will become lower range
            (
                d_.token1RealReserves,
                d_.token0RealReserves,
                d_.token1ImaginaryReserves,
                d_.token0ImaginaryReserves
            ) = _calculateDebtReserves((1e54 / geometricMean_), (1e54 / upperRange_), token1Debt_, token0Debt_);
        }
    }

    function _priceDiffCheck(uint oldPrice_, uint newPrice_) internal pure returns (int priceDiff_) {
        // check newPrice_ & oldPrice_ difference should not be more than 5%
        // old price w.r.t new price
        priceDiff_ = int(ORACLE_PRECISION) - int((oldPrice_ * ORACLE_PRECISION) / newPrice_);

        unchecked {
            if ((priceDiff_ > int(ORACLE_LIMIT)) || (priceDiff_ < -int(ORACLE_LIMIT))) {
                // if oracle price difference is more than 5% then revert
                // in 1 swap price should only change by <= 5%
                // if a total fall by let's say 8% then in current block price can only fall by 5% and
                // in next block it'll fall the remaining 3%
                revert FluidDexError(ErrorTypes.DexT1__OracleUpdateHugeSwapDiff);
            }
        }
    }

    function _updateOracle(uint newPrice_, uint centerPrice_, uint dexVariables_) internal returns (uint) {
        // time difference between last & current swap
        uint timeDiff_ = block.timestamp - ((dexVariables_ >> 121) & X33);
        uint temp_;
        uint temp2_;
        uint temp3_;

        if (timeDiff_ == 0) {
            // doesn't matter if oracle is on or off when timediff = 0 code for both is same

            // temp_ => oldCenterPrice
            temp_ = (dexVariables_ >> 81) & X40;
            temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

            // Ensure that the center price is within the acceptable range of the old center price if it's not the first swap in the same block
            unchecked {
                if (
                    (centerPrice_ < (((EIGHT_DECIMALS - 1) * temp_) / EIGHT_DECIMALS)) ||
                    (centerPrice_ > (((EIGHT_DECIMALS + 1) * temp_) / EIGHT_DECIMALS))
                ) {
                    revert FluidDexError(ErrorTypes.DexT1__CenterPriceOutOfRange);
                }
            }

            // olderPrice_ => temp_
            temp_ = (dexVariables_ >> 1) & X40;
            temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

            _priceDiffCheck(temp_, newPrice_);

            // 2nd swap in same block no need to update anything around oracle, only need to update last swap price in dexVariables
            return ((dexVariables_ & 0xfffffffffffffffffffffffffffffffffffffffffffe0000000001ffffffffff) |
                (newPrice_.toBigNumber(32, 8, BigMathMinified.ROUND_DOWN) << 41));
        }

        if (((dexVariables_ >> 195) & 1) == 0) {
            // if oracle is not active then just returning updated DEX variable
            temp_ = ((dexVariables_ >> 41) & X40);
            temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

            _priceDiffCheck(temp_, newPrice_);
            
            return ((dexVariables_ & 0xfffffffffffffffffffffffffc00000000000000000000000000000000000001) |
                (((dexVariables_ >> 41) & X40) << 1) |
                (newPrice_.toBigNumber(32, 8, BigMathMinified.ROUND_DOWN) << 41) |
                (centerPrice_.toBigNumber(32, 8, BigMathMinified.ROUND_DOWN) << 81) |
                (block.timestamp << 121));
        } else {
            // oracle is active hence update oracle

            // olderPrice_ => temp_
            temp_ = (dexVariables_ >> 1) & X40;
            temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

            // oldPrice_ => temp2_
            temp2_ = (dexVariables_ >> 41) & X40;
            temp2_ = (temp2_ >> DEFAULT_EXPONENT_SIZE) << (temp2_ & DEFAULT_EXPONENT_MASK);

            int priceDiff_ = _priceDiffCheck(temp2_, newPrice_);

            unchecked {
                // older price w.r.t old price
                priceDiff_ = int(ORACLE_PRECISION) - int((temp_ * ORACLE_PRECISION) / temp2_);
            }

            // priceDiffInPercentAndSign_ => temp3_
            // priceDiff_ will always be lower than ORACLE_LIMIT due to above check
            unchecked {
                if (priceDiff_ < 0) {
                    temp3_ = ((uint(-priceDiff_) * X22) / ORACLE_LIMIT) << 1;
                } else {
                    // if greater than or equal to 0 then make sign flag 1
                    temp3_ = (((uint(priceDiff_) * X22) / ORACLE_LIMIT) << 1) | 1;
                }
            }

            if (timeDiff_ > X22) {
                // if time difference is this then that means DEX has been inactive ~45 days
                // that means oracle price of this DEX should not be used.
                timeDiff_ = X22;
            }

            // temp_ => lastTimeDiff_
            temp_ = (dexVariables_ >> 154) & X22;
            uint nextOracleSlot_ = ((dexVariables_ >> 176) & X3);
            uint oracleMap_ = (dexVariables_ >> 179) & X16;
            if (temp_ > X9) {
                if (nextOracleSlot_ > 0) {
                    // if greater than 0 then current slot has 2 or more oracle slot empty
                    // First 9 bits are of time, so not using that
                    temp3_ = (temp3_ << 41) | (temp_ << 9);
                    _oracle[oracleMap_] = _oracle[oracleMap_] | (temp3_ << (--nextOracleSlot_ * 32));
                    if (nextOracleSlot_ > 0) {
                        --nextOracleSlot_;
                    } else {
                        // if == 0 that means the oracle slots will get filled and shift to next oracle map
                        nextOracleSlot_ = 7;
                        unchecked {
                            oracleMap_ = (oracleMap_ + 1) % TOTAL_ORACLE_MAPPING;
                        }
                        _oracle[oracleMap_] = 0;
                    }
                } else {
                    // if == 0
                    // then seconds will be in last map
                    // precision will be in last map + 1
                    // Storing precision & sign slot in first precision & sign slot and leaving time slot empty
                    temp3_ = temp3_ << 9;
                    _oracle[oracleMap_] = _oracle[oracleMap_] | temp3_;
                    nextOracleSlot_ = 6; // storing 6 here as 7 is going to occupied right now
                    unchecked {
                        oracleMap_ = (oracleMap_ + 1) % TOTAL_ORACLE_MAPPING;
                    }
                    // Storing time in 2nd precision & sign and leaving time slot empty
                    _oracle[oracleMap_] = temp_ << ((7 * 32) + 9);
                }
            } else {
                temp3_ = (temp3_ << 9) | temp_;
                unchecked {
                    if (nextOracleSlot_ < 7) {
                        _oracle[oracleMap_] = _oracle[oracleMap_] | (temp3_ << (nextOracleSlot_ * 32));
                    } else {
                        _oracle[oracleMap_] = temp3_ << ((7 * 32));
                    }
                }
                if (nextOracleSlot_ > 0) {
                    --nextOracleSlot_;
                } else {
                    nextOracleSlot_ = 7;
                    unchecked {
                        oracleMap_ = (oracleMap_ + 1) % TOTAL_ORACLE_MAPPING;
                    }
                    _oracle[oracleMap_] = 0;
                }
            }

            // doing this due to stack too deep error when using params memory variables
            temp_ = newPrice_;
            temp2_ = centerPrice_;
            temp3_ = dexVariables_;

            // then update last price
            return ((temp3_ & 0xfffffffffffffff8000000000000000000000000000000000000000000000001) |
                (((temp3_ >> 41) & X40) << 1) |
                (temp_.toBigNumber(32, 8, BigMathMinified.ROUND_DOWN) << 41) |
                (temp2_.toBigNumber(32, 8, BigMathMinified.ROUND_DOWN) << 81) |
                (block.timestamp << 121) |
                (timeDiff_ << 154) |
                (nextOracleSlot_ << 176) |
                (oracleMap_ << 179));
        }
    }

    function _hookVerify(uint hookAddress_, uint mode_, bool swap0to1_, uint price_) internal {
        try
            IHook(AddressCalcs.addressCalc(DEPLOYER_CONTRACT, hookAddress_)).dexPrice(
                mode_,
                swap0to1_,
                TOKEN_0,
                TOKEN_1,
                price_
            )
        returns (bool isOk_) {
            if (!isOk_) revert FluidDexError(ErrorTypes.DexT1__HookReturnedFalse);
        } catch (bytes memory /*lowLevelData*/) {
            // skip checking hook nothing
        }
    }

    function _updateSupplyShares(uint newTotalShares_) internal {
        uint totalSupplyShares_ = _totalSupplyShares;

        // new total shares are greater than old total shares && new total shares are greater than max supply shares
        if (
            (newTotalShares_ > (totalSupplyShares_ & X128)) && 
            newTotalShares_ > (totalSupplyShares_ >> 128)
        ) {
            revert FluidDexError(ErrorTypes.DexT1__SupplySharesOverflow);
        }

        // keeping max supply shares intact
        _totalSupplyShares = ((totalSupplyShares_ >> 128) << 128) | newTotalShares_;
    }

    function _updateBorrowShares(uint newTotalShares_) internal {
        uint totalBorrowShares_ = _totalBorrowShares;

        // new total shares are greater than old total shares && new total shares are greater than max borrow shares
        if (
            (newTotalShares_ > (totalBorrowShares_ & X128)) && 
            newTotalShares_ > (totalBorrowShares_ >> 128)
        ) {
            revert FluidDexError(ErrorTypes.DexT1__BorrowSharesOverflow);
        }

        // keeping max borrow shares intact
        _totalBorrowShares = ((totalBorrowShares_ >> 128) << 128) | newTotalShares_;
    }

    constructor(ConstantViews memory constantViews_) ImmutableVariables(constantViews_) {}
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

// File: contracts/protocols/dex/interfaces/iDexT1.sol

pragma solidity 0.8.21;

interface IFluidDexT1 {
    error FluidDexError(uint256 errorId);

    /// @notice used to simulate swap to find the output amount
    error FluidDexSwapResult(uint256 amountOut);

    error FluidDexPerfectLiquidityOutput(uint256 token0Amt, uint token1Amt);

    error FluidDexSingleTokenOutput(uint256 tokenAmt);

    error FluidDexLiquidityOutput(uint256 shares);

    error FluidDexPricesAndExchangeRates(PricesAndExchangePrice pex_);

    /// @notice returns the dex id
    function DEX_ID() external view returns (uint256);

    /// @notice reads uint256 data `result_` from storage at a bytes32 storage `slot_` key.
    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);

    struct Implementations {
        address shift;
        address admin;
        address colOperations;
        address debtOperations;
        address perfectOperationsAndOracle;
    }

    struct ConstantViews {
        uint256 dexId;
        address liquidity;
        address factory;
        Implementations implementations;
        address deployerContract;
        address token0;
        address token1;
        bytes32 supplyToken0Slot;
        bytes32 borrowToken0Slot;
        bytes32 supplyToken1Slot;
        bytes32 borrowToken1Slot;
        bytes32 exchangePriceToken0Slot;
        bytes32 exchangePriceToken1Slot;
        uint256 oracleMapping;
    }

    struct ConstantViews2 {
        uint token0NumeratorPrecision;
        uint token0DenominatorPrecision;
        uint token1NumeratorPrecision;
        uint token1DenominatorPrecision;
    }

    struct PricesAndExchangePrice {
        uint lastStoredPrice; // last stored price in 1e27 decimals
        uint centerPrice; // last stored price in 1e27 decimals
        uint upperRange; // price at upper range in 1e27 decimals
        uint lowerRange; // price at lower range in 1e27 decimals
        uint geometricMean; // geometric mean of upper range & lower range in 1e27 decimals
        uint supplyToken0ExchangePrice;
        uint borrowToken0ExchangePrice;
        uint supplyToken1ExchangePrice;
        uint borrowToken1ExchangePrice;
    }

    struct CollateralReserves {
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    struct DebtReserves {
        uint token0Debt;
        uint token1Debt;
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    function getCollateralReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0SupplyExchangePrice_,
        uint token1SupplyExchangePrice_
    ) external view returns (CollateralReserves memory c_);

    function getDebtReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0BorrowExchangePrice_,
        uint token1BorrowExchangePrice_
    ) external view returns (DebtReserves memory d_);

    // reverts with FluidDexPricesAndExchangeRates(pex_);
    function getPricesAndExchangePrices() external;

    function constantsView() external view returns (ConstantViews memory constantsView_);

    function constantsView2() external view returns (ConstantViews2 memory constantsView2_);

    struct Oracle {
        uint twap1by0; // TWAP price
        uint lowestPrice1by0; // lowest price point
        uint highestPrice1by0; // highest price point
        uint twap0by1; // TWAP price
        uint lowestPrice0by1; // lowest price point
        uint highestPrice0by1; // highest price point
    }

    /// @dev This function allows users to swap a specific amount of input tokens for output tokens
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountIn_ The exact amount of input tokens to swap
    /// @param amountOutMin_ The minimum amount of output tokens the user is willing to accept
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountOut_
    /// @return amountOut_ The amount of output tokens received from the swap
    function swapIn(
        bool swap0to1_,
        uint256 amountIn_,
        uint256 amountOutMin_,
        address to_
    ) external payable returns (uint256 amountOut_);

    /// @dev Swap tokens with perfect amount out
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountOut_ The exact amount of tokens to receive after swap
    /// @param amountInMax_ Maximum amount of tokens to swap in
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountIn_
    /// @return amountIn_ The amount of input tokens used for the swap
    function swapOut(
        bool swap0to1_,
        uint256 amountOut_,
        uint256 amountInMax_,
        address to_
    ) external payable returns (uint256 amountIn_);

    /// @dev Deposit tokens in equal proportion to the current pool ratio
    /// @param shares_ The number of shares to mint
    /// @param maxToken0Deposit_ Maximum amount of token0 to deposit
    /// @param maxToken1Deposit_ Maximum amount of token1 to deposit
    /// @param estimate_ If true, function will revert with estimated deposit amounts without executing the deposit
    /// @return token0Amt_ Amount of token0 deposited
    /// @return token1Amt_ Amount of token1 deposited
    function depositPerfect(
        uint shares_,
        uint maxToken0Deposit_,
        uint maxToken1Deposit_,
        bool estimate_
    ) external payable returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to withdraw a perfect amount of collateral liquidity
    /// @param shares_ The number of shares to withdraw
    /// @param minToken0Withdraw_ The minimum amount of token0 the user is willing to accept
    /// @param minToken1Withdraw_ The minimum amount of token1 the user is willing to accept
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with token0Amt_ & token1Amt_
    /// @return token0Amt_ The amount of token0 withdrawn
    /// @return token1Amt_ The amount of token1 withdrawn
    function withdrawPerfect(
        uint shares_,
        uint minToken0Withdraw_,
        uint minToken1Withdraw_,
        address to_
    ) external returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to borrow tokens in equal proportion to the current debt pool ratio
    /// @param shares_ The number of shares to borrow
    /// @param minToken0Borrow_ Minimum amount of token0 to borrow
    /// @param minToken1Borrow_ Minimum amount of token1 to borrow
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with token0Amt_ & token1Amt_
    /// @return token0Amt_ Amount of token0 borrowed
    /// @return token1Amt_ Amount of token1 borrowed
    function borrowPerfect(
        uint shares_,
        uint minToken0Borrow_,
        uint minToken1Borrow_,
        address to_
    ) external returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to pay back borrowed tokens in equal proportion to the current debt pool ratio
    /// @param shares_ The number of shares to pay back
    /// @param maxToken0Payback_ Maximum amount of token0 to pay back
    /// @param maxToken1Payback_ Maximum amount of token1 to pay back
    /// @param estimate_ If true, function will revert with estimated payback amounts without executing the payback
    /// @return token0Amt_ Amount of token0 paid back
    /// @return token1Amt_ Amount of token1 paid back
    function paybackPerfect(
        uint shares_,
        uint maxToken0Payback_,
        uint maxToken1Payback_,
        bool estimate_
    ) external payable returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to deposit tokens in any proportion into the col pool
    /// @param token0Amt_ The amount of token0 to deposit
    /// @param token1Amt_ The amount of token1 to deposit
    /// @param minSharesAmt_ The minimum amount of shares the user expects to receive
    /// @param estimate_ If true, function will revert with estimated shares without executing the deposit
    /// @return shares_ The amount of shares minted for the deposit
    function deposit(
        uint token0Amt_,
        uint token1Amt_,
        uint minSharesAmt_,
        bool estimate_
    ) external payable returns (uint shares_);

    /// @dev This function allows users to withdraw tokens in any proportion from the col pool
    /// @param token0Amt_ The amount of token0 to withdraw
    /// @param token1Amt_ The amount of token1 to withdraw
    /// @param maxSharesAmt_ The maximum number of shares the user is willing to burn
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return shares_ The number of shares burned for the withdrawal
    function withdraw(
        uint token0Amt_,
        uint token1Amt_,
        uint maxSharesAmt_,
        address to_
    ) external returns (uint shares_);

    /// @dev This function allows users to borrow tokens in any proportion from the debt pool
    /// @param token0Amt_ The amount of token0 to borrow
    /// @param token1Amt_ The amount of token1 to borrow
    /// @param maxSharesAmt_ The maximum amount of shares the user is willing to receive
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return shares_ The amount of borrow shares minted to represent the borrowed amount
    function borrow(
        uint token0Amt_,
        uint token1Amt_,
        uint maxSharesAmt_,
        address to_
    ) external returns (uint shares_);

    /// @dev This function allows users to payback tokens in any proportion to the debt pool
    /// @param token0Amt_ The amount of token0 to payback
    /// @param token1Amt_ The amount of token1 to payback
    /// @param minSharesAmt_ The minimum amount of shares the user expects to burn
    /// @param estimate_ If true, function will revert with estimated shares without executing the payback
    /// @return shares_ The amount of borrow shares burned for the payback
    function payback(
        uint token0Amt_,
        uint token1Amt_,
        uint minSharesAmt_,
        bool estimate_
    ) external payable returns (uint shares_);

    /// @dev This function allows users to withdraw their collateral with perfect shares in one token
    /// @param shares_ The number of shares to burn for withdrawal
    /// @param minToken0_ The minimum amount of token0 the user expects to receive (set to 0 if withdrawing in token1)
    /// @param minToken1_ The minimum amount of token1 the user expects to receive (set to 0 if withdrawing in token0)
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with withdrawAmt_
    /// @return withdrawAmt_ The amount of tokens withdrawn in the chosen token
    function withdrawPerfectInOneToken(
        uint shares_,
        uint minToken0_,
        uint minToken1_,
        address to_
    ) external returns (
        uint withdrawAmt_
    );

    /// @dev This function allows users to payback their debt with perfect shares in one token
    /// @param shares_ The number of shares to burn for payback
    /// @param maxToken0_ The maximum amount of token0 the user is willing to pay (set to 0 if paying back in token1)
    /// @param maxToken1_ The maximum amount of token1 the user is willing to pay (set to 0 if paying back in token0)
    /// @param estimate_ If true, the function will revert with the estimated payback amount without executing the payback
    /// @return paybackAmt_ The amount of tokens paid back in the chosen token
    function paybackPerfectInOneToken(
        uint shares_,
        uint maxToken0_,
        uint maxToken1_,
        bool estimate_
    ) external payable returns (
        uint paybackAmt_
    );

    /// @dev the oracle assumes last set price of pool till the next swap happens.
    /// There's a possibility that during that time some interest is generated hence the last stored price is not the 100% correct price for the whole duration
    /// but the difference due to interest will be super low so this difference is ignored
    /// For example 2 swaps happened 10min (600 seconds) apart and 1 token has 10% higher interest than other.
    /// then that token will accrue about 10% * 600 / secondsInAYear = ~0.0002%
    /// @param secondsAgos_ array of seconds ago for which TWAP is needed. If user sends [10, 30, 60] then twaps_ will return [10-0, 30-10, 60-30]
    /// @return twaps_ twap price, lowest price (aka minima) & highest price (aka maxima) between secondsAgo checkpoints
    /// @return currentPrice_ price of pool after the most recent swap
    function oraclePrice(
        uint[] memory secondsAgos_
    ) external view returns (
        Oracle[] memory twaps_,
        uint currentPrice_
    );
}

// File: contracts/protocols/dex/poolT1/coreModule/core/main.sol

pragma solidity 0.8.21;









interface IDexCallback {
    function dexCallback(address token_, uint256 amount_) external;
}

/// @title FluidDexT1
/// @notice Implements core logics for Fluid Dex protocol.
/// Note Token transfers happen directly from user to Liquidity contract and vice-versa.
contract FluidDexT1 is CoreHelpers {
    using BigMathMinified for uint256;

    constructor(ConstantViews memory constantViews_) CoreHelpers(constantViews_) {
        // any implementations should not be zero
        if (
            constantViews_.implementations.shift == address(0) ||
            constantViews_.implementations.admin == address(0) ||
            constantViews_.implementations.colOperations == address(0) ||
            constantViews_.implementations.debtOperations == address(0) ||
            constantViews_.implementations.perfectOperationsAndSwapOut == address(0)
        ) {
            revert FluidDexError(ErrorTypes.DexT1__InvalidImplementation);
        }
    }

    struct SwapInExtras {
        address to;
        uint amountOutMin;
        bool isCallback;
    }

    /// @dev This function allows users to swap a specific amount of input tokens for output tokens
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountIn_ The exact amount of input tokens to swap
    /// @param extras_ Additional parameters for the swap:
    ///   - to: Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountOut_
    ///   - amountOutMin: The minimum amount of output tokens the user expects to receive
    ///   - isCallback: If true, indicates that the input tokens should be transferred via a callback
    /// @return amountOut_ The amount of output tokens received from the swap
    function _swapIn(
        bool swap0to1_,
        uint256 amountIn_,
        SwapInExtras memory extras_
    ) internal returns (uint256 amountOut_) {
        uint dexVariables_ = dexVariables;
        uint dexVariables2_ = dexVariables2;

        if ((dexVariables2_ >> 255) == 1) revert FluidDexError(ErrorTypes.DexT1__SwapAndArbitragePaused);

        _check(dexVariables_, dexVariables2_);

        if (extras_.to == address(0)) extras_.to = msg.sender;

        SwapInMemory memory s_;

        if (swap0to1_) {
            (s_.tokenIn, s_.tokenOut) = (TOKEN_0, TOKEN_1);
            unchecked {
                s_.amtInAdjusted = (amountIn_ * TOKEN_0_NUMERATOR_PRECISION) / TOKEN_0_DENOMINATOR_PRECISION;
            }
        } else {
            (s_.tokenIn, s_.tokenOut) = (TOKEN_1, TOKEN_0);
            unchecked {
                s_.amtInAdjusted = (amountIn_ * TOKEN_1_NUMERATOR_PRECISION) / TOKEN_1_DENOMINATOR_PRECISION;
            }
        }

        _verifySwapAndNonPerfectActions(s_.amtInAdjusted, amountIn_);

        PricesAndExchangePrice memory pex_ = _getPricesAndExchangePrices(dexVariables_, dexVariables2_);

        if (msg.value > 0) {
            if (msg.value != amountIn_) revert FluidDexError(ErrorTypes.DexT1__EthAndAmountInMisMatch);
            if (s_.tokenIn != NATIVE_TOKEN) revert FluidDexError(ErrorTypes.DexT1__EthSentForNonNativeSwap);
        }

        // is smart collateral pool enabled
        uint temp_ = dexVariables2_ & 1;
        // is smart debt pool enabled
        uint temp2_ = (dexVariables2_ >> 1) & 1;

        uint temp3_;
        uint temp4_;

        // extracting fee
        temp3_ = ((dexVariables2_ >> 2) & X17);
        unchecked {
            // revenueCut in 6 decimals, to have proper precision
            // if fee = 1% and revenue cut = 10% then revenueCut = 1e8 - (10000 * 10) = 99900000
            s_.revenueCut = EIGHT_DECIMALS - ((((dexVariables2_ >> 19) & X7) * temp3_));
            // fee in 4 decimals
            // 1 - fee. If fee is 1% then withoutFee will be 1e6 - 1e4
            // s_.fee => 1 - withdraw fee
            s_.fee = SIX_DECIMALS - temp3_;
        }

        CollateralReservesSwap memory cs_;
        DebtReservesSwap memory ds_;
        if (temp_ == 1) {
            // smart collateral is enabled
            {
                CollateralReserves memory c_ = _getCollateralReserves(
                    pex_.geometricMean,
                    pex_.upperRange,
                    pex_.lowerRange,
                    pex_.supplyToken0ExchangePrice,
                    pex_.supplyToken1ExchangePrice
                );
                if (swap0to1_) {
                    (
                        cs_.tokenInRealReserves,
                        cs_.tokenOutRealReserves,
                        cs_.tokenInImaginaryReserves,
                        cs_.tokenOutImaginaryReserves
                    ) = (
                        c_.token0RealReserves,
                        c_.token1RealReserves,
                        c_.token0ImaginaryReserves,
                        c_.token1ImaginaryReserves
                    );
                } else {
                    (
                        cs_.tokenInRealReserves,
                        cs_.tokenOutRealReserves,
                        cs_.tokenInImaginaryReserves,
                        cs_.tokenOutImaginaryReserves
                    ) = (
                        c_.token1RealReserves,
                        c_.token0RealReserves,
                        c_.token1ImaginaryReserves,
                        c_.token0ImaginaryReserves
                    );
                }
            }
        }

        if (temp2_ == 1) {
            // smart debt is enabled
            {
                DebtReserves memory d_ = _getDebtReserves(
                    pex_.geometricMean,
                    pex_.upperRange,
                    pex_.lowerRange,
                    pex_.borrowToken0ExchangePrice,
                    pex_.borrowToken1ExchangePrice
                );
                if (swap0to1_) {
                    (
                        ds_.tokenInDebt,
                        ds_.tokenOutDebt,
                        ds_.tokenInRealReserves,
                        ds_.tokenOutRealReserves,
                        ds_.tokenInImaginaryReserves,
                        ds_.tokenOutImaginaryReserves
                    ) = (
                        d_.token0Debt,
                        d_.token1Debt,
                        d_.token0RealReserves,
                        d_.token1RealReserves,
                        d_.token0ImaginaryReserves,
                        d_.token1ImaginaryReserves
                    );
                } else {
                    (
                        ds_.tokenInDebt,
                        ds_.tokenOutDebt,
                        ds_.tokenInRealReserves,
                        ds_.tokenOutRealReserves,
                        ds_.tokenInImaginaryReserves,
                        ds_.tokenOutImaginaryReserves
                    ) = (
                        d_.token1Debt,
                        d_.token0Debt,
                        d_.token1RealReserves,
                        d_.token0RealReserves,
                        d_.token1ImaginaryReserves,
                        d_.token0ImaginaryReserves
                    );
                }
            }
        }

        // limiting amtInAdjusted to be not more than 50% of both (collateral & debt) imaginary tokenIn reserves combined
        // basically, if this throws that means user is trying to swap 0.5x tokenIn if current tokenIn imaginary reserves is x
        // let's take x as token0 here, that means, initially the pool pricing might be:
        // token1Reserve / x and new pool pricing will become token1Reserve / 1.5x (token1Reserve will decrease after swap but for simplicity ignoring that)
        // So pool price is decreased by ~33.33% (oracle will throw error in this case as it only allows 5% price difference but better to limit it before hand)
        unchecked {
            if (s_.amtInAdjusted > ((cs_.tokenInImaginaryReserves + ds_.tokenInImaginaryReserves) / 2))
                revert FluidDexError(ErrorTypes.DexT1__SwapInLimitingAmounts);
        }

        if (temp_ == 1 && temp2_ == 1) {
            // unless both pools are enabled s_.swapRoutingAmt will be 0
            s_.swapRoutingAmt = _swapRoutingIn(
                s_.amtInAdjusted,
                cs_.tokenOutImaginaryReserves,
                cs_.tokenInImaginaryReserves,
                ds_.tokenOutImaginaryReserves,
                ds_.tokenInImaginaryReserves
            );
        }

        // In below if else statement temps are:
        // temp_ => deposit amt
        // temp2_ => withdraw amt
        // temp3_ => payback amt
        // temp4_ => borrow amt
        if (int(s_.amtInAdjusted) > s_.swapRoutingAmt && s_.swapRoutingAmt > 0) {
            // swap will route from the both pools
            // temp_ = amountInCol_
            temp_ = uint(s_.swapRoutingAmt);
            unchecked {
                // temp3_ = amountInDebt_
                temp3_ = s_.amtInAdjusted - temp_;
            }

            (temp2_, temp4_) = (0, 0);

            // debt pool price will be the same as collateral pool after the swap
            s_.withdrawTo = extras_.to;
            s_.borrowTo = extras_.to;
        } else if ((temp_ == 1 && temp2_ == 0) || (s_.swapRoutingAmt >= int(s_.amtInAdjusted))) {
            // entire swap will route through collateral pool
            (temp_, temp2_, temp3_, temp4_) = (s_.amtInAdjusted, 0, 0, 0);
            // price can slightly differ from debt pool but difference will be very small. Probably <0.01% for active DEX pools.
            s_.withdrawTo = extras_.to;
        } else if ((temp_ == 0 && temp2_ == 1) || (s_.swapRoutingAmt <= 0)) {
            // entire swap will route through debt pool
            (temp_, temp2_, temp3_, temp4_) = (0, 0, s_.amtInAdjusted, 0);
            // price can slightly differ from collateral pool but difference will be very small. Probably <0.01% for active DEX pools.
            s_.borrowTo = extras_.to;
        } else {
            // swap should never reach this point but if it does then reverting
            revert FluidDexError(ErrorTypes.DexT1__NoSwapRoute);
        }

        if (temp_ > 0) {
            // temp2_ = amountOutCol_
            temp2_ = _getAmountOut(
                ((temp_ * s_.fee) / SIX_DECIMALS),
                cs_.tokenInImaginaryReserves,
                cs_.tokenOutImaginaryReserves
            );
            swap0to1_
                ? _verifyToken1Reserves(
                    (cs_.tokenInRealReserves + temp_),
                    (cs_.tokenOutRealReserves - temp2_),
                    pex_.centerPrice,
                    MINIMUM_LIQUIDITY_SWAP
                )
                : _verifyToken0Reserves(
                    (cs_.tokenOutRealReserves - temp2_),
                    (cs_.tokenInRealReserves + temp_),
                    pex_.centerPrice,
                    MINIMUM_LIQUIDITY_SWAP
                );
        }
        if (temp3_ > 0) {
            // temp4_ = amountOutDebt_
            temp4_ = _getAmountOut(
                ((temp3_ * s_.fee) / SIX_DECIMALS),
                ds_.tokenInImaginaryReserves,
                ds_.tokenOutImaginaryReserves
            );
            swap0to1_
                ? _verifyToken1Reserves(
                    (ds_.tokenInRealReserves + temp3_),
                    (ds_.tokenOutRealReserves - temp4_),
                    pex_.centerPrice,
                    MINIMUM_LIQUIDITY_SWAP
                )
                : _verifyToken0Reserves(
                    (ds_.tokenOutRealReserves - temp4_),
                    (ds_.tokenInRealReserves + temp3_),
                    pex_.centerPrice,
                    MINIMUM_LIQUIDITY_SWAP
                );
        }

        // (temp_ + temp3_) == amountIn_ == msg.value (for native token), if there is revenue cut then this statement is not true
        temp_ = (temp_ * s_.revenueCut) / EIGHT_DECIMALS;
        temp3_ = (temp3_ * s_.revenueCut) / EIGHT_DECIMALS;

        // from whatever pool higher amount of swap is routing we are taking that as final price, does not matter much because both pools final price should be same
        if (temp_ > temp3_) {
            // new pool price from col pool
            s_.price = swap0to1_
                ? ((cs_.tokenOutImaginaryReserves - temp2_) * 1e27) / (cs_.tokenInImaginaryReserves + temp_)
                : ((cs_.tokenInImaginaryReserves + temp_) * 1e27) / (cs_.tokenOutImaginaryReserves - temp2_);
        } else {
            // new pool price from debt pool
            s_.price = swap0to1_
                ? ((ds_.tokenOutImaginaryReserves - temp4_) * 1e27) / (ds_.tokenInImaginaryReserves + temp3_)
                : ((ds_.tokenInImaginaryReserves + temp3_) * 1e27) / (ds_.tokenOutImaginaryReserves - temp4_);
        }

        // converting into normal token amounts
        if (swap0to1_) {
            temp_ = ((temp_ * TOKEN_0_DENOMINATOR_PRECISION) / TOKEN_0_NUMERATOR_PRECISION);
            temp3_ = ((temp3_ * TOKEN_0_DENOMINATOR_PRECISION) / TOKEN_0_NUMERATOR_PRECISION);
            // only adding uncheck in out amount
            unchecked {
                temp2_ = ((temp2_ * TOKEN_1_DENOMINATOR_PRECISION) / TOKEN_1_NUMERATOR_PRECISION);
                temp4_ = ((temp4_ * TOKEN_1_DENOMINATOR_PRECISION) / TOKEN_1_NUMERATOR_PRECISION);
            }
        } else {
            temp_ = ((temp_ * TOKEN_1_DENOMINATOR_PRECISION) / TOKEN_1_NUMERATOR_PRECISION);
            temp3_ = ((temp3_ * TOKEN_1_DENOMINATOR_PRECISION) / TOKEN_1_NUMERATOR_PRECISION);
            // only adding uncheck in out amount
            unchecked {
                temp2_ = ((temp2_ * TOKEN_0_DENOMINATOR_PRECISION) / TOKEN_0_NUMERATOR_PRECISION);
                temp4_ = ((temp4_ * TOKEN_0_DENOMINATOR_PRECISION) / TOKEN_0_NUMERATOR_PRECISION);
            }
        }

        unchecked {
            amountOut_ = temp2_ + temp4_;
        }

        // if address dead then reverting with amountOut
        if (extras_.to == ADDRESS_DEAD) revert FluidDexSwapResult(amountOut_);

        if (amountOut_ < extras_.amountOutMin) revert FluidDexError(ErrorTypes.DexT1__NotEnoughAmountOut);

        // allocating to avoid stack-too-deep error
        // not setting in the callbackData as last 2nd to avoid SKIP_TRANSFERS clashing
        s_.data = abi.encode(amountIn_, extras_.isCallback, msg.sender); // true/false is to decide if dex should do callback or directly transfer from user
        // deposit & payback token in at liquidity
        LIQUIDITY.operate{ value: msg.value }(s_.tokenIn, int(temp_), -int(temp3_), address(0), address(0), s_.data);
        // withdraw & borrow token out at liquidity
        LIQUIDITY.operate(s_.tokenOut, -int(temp2_), int(temp4_), s_.withdrawTo, s_.borrowTo, new bytes(0));

        // if hook exists then calling hook
        temp_ = (dexVariables2_ >> 142) & X30;
        if (temp_ > 0) {
            s_.swap0to1 = swap0to1_;
            _hookVerify(temp_, 1, s_.swap0to1, s_.price);
        }

        swap0to1_
            ? _utilizationVerify(((dexVariables2_ >> 238) & X10), EXCHANGE_PRICE_TOKEN_1_SLOT)
            : _utilizationVerify(((dexVariables2_ >> 228) & X10), EXCHANGE_PRICE_TOKEN_0_SLOT);

        dexVariables = _updateOracle(s_.price, pex_.centerPrice, dexVariables_);

        emit Swap(swap0to1_, amountIn_, amountOut_, extras_.to);
    }

    /// @dev Swap tokens with perfect amount in
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountIn_ The exact amount of tokens to swap in
    /// @param amountOutMin_ The minimum amount of tokens to receive after swap
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountOut_
    /// @return amountOut_ The amount of output tokens received from the swap
    function swapIn(
        bool swap0to1_,
        uint256 amountIn_,
        uint256 amountOutMin_,
        address to_
    ) public payable returns (uint256 amountOut_) {
        return _swapIn(swap0to1_, amountIn_, SwapInExtras(to_, amountOutMin_, false));
    }

    /// @dev Swap tokens with perfect amount in and callback functionality
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountIn_ The exact amount of tokens to swap in
    /// @param amountOutMin_ The minimum amount of tokens to receive after swap
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountOut_
    /// @return amountOut_ The amount of output tokens received from the swap
    function swapInWithCallback(
        bool swap0to1_,
        uint256 amountIn_,
        uint256 amountOutMin_,
        address to_
    ) public payable returns (uint256 amountOut_) {
        return _swapIn(swap0to1_, amountIn_, SwapInExtras(to_, amountOutMin_, true));
    }

    /// @dev Swap tokens with perfect amount out
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountOut_ The exact amount of tokens to receive after swap
    /// @param amountInMax_ Maximum amount of tokens to swap in
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountIn_
    /// @return amountIn_ The amount of input tokens used for the swap
    function swapOut(
        bool swap0to1_,
        uint256 amountOut_,
        uint256 amountInMax_,
        address to_
    ) public payable returns (uint256 amountIn_) {
        return abi.decode(_spell(PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION, msg.data), (uint256));
    }

    /// @dev Swap tokens with perfect amount out and callback functionality
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountOut_ The exact amount of tokens to receive after swap
    /// @param amountInMax_ Maximum amount of tokens to swap in
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountIn_
    /// @return amountIn_ The amount of input tokens used for the swap
    function swapOutWithCallback(
        bool swap0to1_,
        uint256 amountOut_,
        uint256 amountInMax_,
        address to_
    ) public payable returns (uint256 amountIn_) {
        return abi.decode(_spell(PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION, msg.data), (uint256));
    }

    /// @dev Deposit tokens in equal proportion to the current pool ratio
    /// @param shares_ The number of shares to mint
    /// @param maxToken0Deposit_ Maximum amount of token0 to deposit
    /// @param maxToken1Deposit_ Maximum amount of token1 to deposit
    /// @param estimate_ If true, function will revert with estimated deposit amounts without executing the deposit
    /// @return token0Amt_ Amount of token0 deposited
    /// @return token1Amt_ Amount of token1 deposited
    function depositPerfect(
        uint shares_,
        uint maxToken0Deposit_,
        uint maxToken1Deposit_,
        bool estimate_
    ) public payable returns (uint token0Amt_, uint token1Amt_) {
        return abi.decode(_spell(PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION, msg.data), (uint256, uint256));
    }

    /// @dev This function allows users to withdraw a perfect amount of collateral liquidity
    /// @param shares_ The number of shares to withdraw
    /// @param minToken0Withdraw_ The minimum amount of token0 the user is willing to accept
    /// @param minToken1Withdraw_ The minimum amount of token1 the user is willing to accept
    /// @param to_ Recipient of withdrawn tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with token0Amt_ & token1Amt_
    /// @return token0Amt_ The amount of token0 withdrawn
    /// @return token1Amt_ The amount of token1 withdrawn
    function withdrawPerfect(
        uint shares_,
        uint minToken0Withdraw_,
        uint minToken1Withdraw_,
        address to_
    ) public returns (uint token0Amt_, uint token1Amt_) {
        return abi.decode(_spell(PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION, msg.data), (uint256, uint256));
    }

    /// @dev This function allows users to borrow tokens in equal proportion to the current debt pool ratio
    /// @param shares_ The number of shares to borrow
    /// @param minToken0Borrow_ Minimum amount of token0 to borrow
    /// @param minToken1Borrow_ Minimum amount of token1 to borrow
    /// @param to_ Recipient of borrowed tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with token0Amt_ & token1Amt_
    /// @return token0Amt_ Amount of token0 borrowed
    /// @return token1Amt_ Amount of token1 borrowed
    function borrowPerfect(
        uint shares_,
        uint minToken0Borrow_,
        uint minToken1Borrow_,
        address to_
    ) public returns (uint token0Amt_, uint token1Amt_) {
        return abi.decode(_spell(PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION, msg.data), (uint256, uint256));
    }

    /// @dev This function allows users to pay back borrowed tokens in equal proportion to the current debt pool ratio
    /// @param shares_ The number of shares to pay back
    /// @param maxToken0Payback_ Maximum amount of token0 to pay back
    /// @param maxToken1Payback_ Maximum amount of token1 to pay back
    /// @param estimate_ If true, function will revert with estimated payback amounts without executing the payback
    /// @return token0Amt_ Amount of token0 paid back
    /// @return token1Amt_ Amount of token1 paid back
    function paybackPerfect(
        uint shares_,
        uint maxToken0Payback_,
        uint maxToken1Payback_,
        bool estimate_
    ) public payable returns (uint token0Amt_, uint token1Amt_) {
        return abi.decode(_spell(PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION, msg.data), (uint256, uint256));
    }

    /// @dev This function allows users to deposit tokens in any proportion into the col pool
    /// @param token0Amt_ The amount of token0 to deposit
    /// @param token1Amt_ The amount of token1 to deposit
    /// @param minSharesAmt_ The minimum amount of shares the user expects to receive
    /// @param estimate_ If true, function will revert with estimated shares without executing the deposit
    /// @return shares_ The amount of shares minted for the deposit
    function deposit(
        uint token0Amt_,
        uint token1Amt_,
        uint minSharesAmt_,
        bool estimate_
    ) public payable returns (uint shares_) {
        return abi.decode(_spell(COL_OPERATIONS_IMPLEMENTATION, msg.data), (uint256));
    }

    /// @dev This function allows users to withdraw tokens in any proportion from the col pool
    /// @param token0Amt_ The amount of token0 to withdraw
    /// @param token1Amt_ The amount of token1 to withdraw
    /// @param maxSharesAmt_ The maximum number of shares the user is willing to burn
    /// @param to_ Recipient of withdrawn tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return shares_ The number of shares burned for the withdrawal
    function withdraw(
        uint token0Amt_,
        uint token1Amt_,
        uint maxSharesAmt_,
        address to_
    ) public returns (uint shares_) {
        return abi.decode(_spell(COL_OPERATIONS_IMPLEMENTATION, msg.data), (uint256));
    }

    /// @dev This function allows users to borrow tokens in any proportion from the debt pool
    /// @param token0Amt_ The amount of token0 to borrow
    /// @param token1Amt_ The amount of token1 to borrow
    /// @param maxSharesAmt_ The maximum amount of shares the user is willing to receive
    /// @param to_ Recipient of borrowed tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return shares_ The amount of borrow shares minted to represent the borrowed amount
    function borrow(
        uint token0Amt_,
        uint token1Amt_,
        uint maxSharesAmt_,
        address to_
    ) public returns (uint shares_) {
        return abi.decode(_spell(DEBT_OPERATIONS_IMPLEMENTATION, msg.data), (uint256));
    }

    /// @dev This function allows users to payback tokens in any proportion to the debt pool
    /// @param token0Amt_ The amount of token0 to payback
    /// @param token1Amt_ The amount of token1 to payback
    /// @param minSharesAmt_ The minimum amount of shares the user expects to burn
    /// @param estimate_ If true, function will revert with estimated shares without executing the payback
    /// @return shares_ The amount of borrow shares burned for the payback
    function payback(
        uint token0Amt_,
        uint token1Amt_,
        uint minSharesAmt_,
        bool estimate_
    ) public payable returns (uint shares_) {
        return abi.decode(_spell(DEBT_OPERATIONS_IMPLEMENTATION, msg.data), (uint256));
    }

    /// @dev This function allows users to withdraw their collateral with perfect shares in one token
    /// @param shares_ The number of shares to burn for withdrawal
    /// @param minToken0_ The minimum amount of token0 the user expects to receive (set to 0 if withdrawing in token1)
    /// @param minToken1_ The minimum amount of token1 the user expects to receive (set to 0 if withdrawing in token0)
    /// @param to_ Recipient of withdrawn tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with withdrawAmt_
    /// @return withdrawAmt_ The amount of tokens withdrawn in the chosen token
    function withdrawPerfectInOneToken(
        uint shares_,
        uint minToken0_,
        uint minToken1_,
        address to_
    ) public returns (uint withdrawAmt_) {
        return abi.decode(_spell(COL_OPERATIONS_IMPLEMENTATION, msg.data), (uint256));
    }

    /// @dev This function allows users to payback their debt with perfect shares in one token
    /// @param shares_ The number of shares to burn for payback
    /// @param maxToken0_ The maximum amount of token0 the user is willing to pay (set to 0 if paying back in token1)
    /// @param maxToken1_ The maximum amount of token1 the user is willing to pay (set to 0 if paying back in token0)
    /// @param estimate_ If true, the function will revert with the estimated payback amount without executing the payback
    /// @return paybackAmt_ The amount of tokens paid back in the chosen token
    function paybackPerfectInOneToken(
        uint shares_,
        uint maxToken0_,
        uint maxToken1_,
        bool estimate_
    ) public payable returns (uint paybackAmt_) {
        return abi.decode(_spell(DEBT_OPERATIONS_IMPLEMENTATION, msg.data), (uint256));
    }

    /// @dev liquidity callback for cheaper token transfers in case of deposit or payback.
    /// only callable by Liquidity during an operation.
    function liquidityCallback(address token_, uint amount_, bytes calldata data_) external {
        if (msg.sender != address(LIQUIDITY)) revert FluidDexError(ErrorTypes.DexT1__MsgSenderNotLiquidity);
        if (dexVariables & 1 == 0) revert FluidDexError(ErrorTypes.DexT1__ReentrancyBitShouldBeOn);
        if (data_.length != 96) revert FluidDexError(ErrorTypes.DexT1__IncorrectDataLength);

        (uint amountToSend_, bool isCallback_, address from_) = abi.decode(data_, (uint, bool, address));

        if (amountToSend_ < amount_) revert FluidDexError(ErrorTypes.DexT1__AmountToSendLessThanAmount);

        if (isCallback_) {
            IDexCallback(from_).dexCallback(token_, amountToSend_);
        } else {
            SafeTransfer.safeTransferFrom(token_, from_, address(LIQUIDITY), amountToSend_);
        }
    }

    /// @dev the oracle assumes last set price of pool till the next swap happens.
    /// There's a possibility that during that time some interest is generated hence the last stored price is not the 100% correct price for the whole duration
    /// but the difference due to interest will be super low so this difference is ignored
    /// For example 2 swaps happened 10min (600 seconds) apart and 1 token has 10% higher interest than other.
    /// then that token will accrue about 10% * 600 / secondsInAYear = ~0.0002%
    /// @param secondsAgos_ array of seconds ago for which TWAP is needed. If user sends [10, 30, 60] then twaps_ will return [10-0, 30-10, 60-30]
    /// @return twaps_ twap price, lowest price (aka minima) & highest price (aka maxima) between secondsAgo checkpoints
    /// @return currentPrice_ price of pool after the most recent swap
    function oraclePrice(
        uint[] memory secondsAgos_
    ) external view returns (Oracle[] memory twaps_, uint currentPrice_) {
        OraclePriceMemory memory o_;

        uint dexVariables_ = dexVariables;

        if ((dexVariables_ >> 195) & 1 == 0) {
            revert FluidDexError(ErrorTypes.DexT1__OracleNotActive);
        }

        twaps_ = new Oracle[](secondsAgos_.length);

        uint totalTime_;
        uint time_;

        uint i;
        uint secondsAgo_ = secondsAgos_[0];

        currentPrice_ = (dexVariables_ >> 41) & X40;
        currentPrice_ = (currentPrice_ >> DEFAULT_EXPONENT_SIZE) << (currentPrice_ & DEFAULT_EXPONENT_MASK);
        uint price_ = currentPrice_;
        o_.lowestPrice1by0 = currentPrice_;
        o_.highestPrice1by0 = currentPrice_;

        uint twap1by0_;
        uint twap0by1_;

        uint j;

        o_.oracleSlot = (dexVariables_ >> 176) & X3;
        o_.oracleMap = (dexVariables_ >> 179) & X16;
        // if o_.oracleSlot == 7 then it'll enter the if statement in the below while loop
        o_.oracle = o_.oracleSlot < 7 ? _oracle[o_.oracleMap] : 0;

        uint slotData_;
        uint percentDiff_;

        if (((dexVariables_ >> 121) & X33) < block.timestamp) {
            // last swap didn't occured in this block.
            // hence last price is current price of pool & also the last price
            time_ = block.timestamp - ((dexVariables_ >> 121) & X33);
        } else {
            // last swap occured in this block, that means current price is active for 0 secs. Hence TWAP for it will be 0.
            ++j;
        }

        while (true) {
            if (j == 2) {
                if (++o_.oracleSlot == 8) {
                    o_.oracleSlot = 0;
                    if (o_.oracleMap == 0) {
                        o_.oracleMap = TOTAL_ORACLE_MAPPING;
                    }
                    o_.oracle = _oracle[--o_.oracleMap];
                }

                slotData_ = (o_.oracle >> (o_.oracleSlot * 32)) & X32;
                if (slotData_ > 0) {
                    time_ = slotData_ & X9;
                    if (time_ == 0) {
                        // time is in precision & sign bits
                        time_ = slotData_ >> 9;
                        // if o_.oracleSlot is 7 then precision & bits and stored in 1 less map
                        if (o_.oracleSlot == 7) {
                            o_.oracleSlot = 0;
                            if (o_.oracleMap == 0) {
                                o_.oracleMap = TOTAL_ORACLE_MAPPING;
                            }
                            o_.oracle = _oracle[--o_.oracleMap];
                            slotData_ = o_.oracle & X32;
                        } else {
                            ++o_.oracleSlot;
                            slotData_ = (o_.oracle >> (o_.oracleSlot * 32)) & X32;
                        }
                    }
                    percentDiff_ = slotData_ >> 10;
                    percentDiff_ = (ORACLE_LIMIT * percentDiff_) / X22;
                    if (((slotData_ >> 9) & 1 == 1)) {
                        // if positive then old price was lower than current hence subtracting
                        price_ = price_ - (price_ * percentDiff_) / ORACLE_PRECISION;
                    } else {
                        // if negative then old price was higher than current hence adding
                        price_ = price_ + (price_ * percentDiff_) / ORACLE_PRECISION;
                    }
                } else {
                    // oracle data does not exist. Probably due to pool recently got initialized and not have much swaps.
                    revert FluidDexError(ErrorTypes.DexT1__InsufficientOracleData);
                }
            } else if (j == 1) {
                // last & last to last price
                price_ = (dexVariables_ >> 1) & X40;
                price_ = (price_ >> DEFAULT_EXPONENT_SIZE) << (price_ & DEFAULT_EXPONENT_MASK);
                time_ = (dexVariables_ >> 154) & X22;
                ++j;
            } else if (j == 0) {
                ++j;
            }

            totalTime_ += time_;
            if (o_.lowestPrice1by0 > price_) o_.lowestPrice1by0 = price_;
            if (o_.highestPrice1by0 < price_) o_.highestPrice1by0 = price_;
            if (totalTime_ < secondsAgo_) {
                twap1by0_ += price_ * time_;
                twap0by1_ += (1e54 / price_) * time_;
            } else {
                time_ = time_ + secondsAgo_ - totalTime_;
                twap1by0_ += price_ * time_;
                twap0by1_ += (1e54 / price_) * time_;
                // also auto checks that secondsAgos_ should not be == 0
                twap1by0_ = twap1by0_ / secondsAgo_;
                twap0by1_ = twap0by1_ / secondsAgo_;

                twaps_[i] = Oracle(
                    twap1by0_,
                    o_.lowestPrice1by0,
                    o_.highestPrice1by0,
                    twap0by1_,
                    (1e54 / o_.highestPrice1by0),
                    (1e54 / o_.lowestPrice1by0)
                );

                // TWAP for next secondsAgo will start with price_
                o_.lowestPrice1by0 = price_;
                o_.highestPrice1by0 = price_;

                while (++i < secondsAgos_.length) {
                    // secondsAgo_ = [60, 15, 0]
                    time_ = totalTime_ - secondsAgo_;
                    // updating total time as new seconds ago started
                    totalTime_ = time_;
                    // also auto checks that secondsAgos_[i + 1] > secondsAgos_[i]
                    secondsAgo_ = secondsAgos_[i] - secondsAgos_[i - 1];
                    if (totalTime_ < secondsAgo_) {
                        twap1by0_ = price_ * time_;
                        twap0by1_ = (1e54 / price_) * time_;
                        // if time_ comes out as 0 here then lowestPrice & highestPrice should not be price_, it should be next price_ that we will calculate
                        if (time_ == 0) {
                            o_.lowestPrice1by0 = type(uint).max;
                            o_.highestPrice1by0 = 0;
                        }
                        break;
                    } else {
                        time_ = time_ + secondsAgo_ - totalTime_;
                        // twap1by0_ = price_ here
                        twap1by0_ = price_ * time_;
                        // twap0by1_ = (1e54 / price_) * time_;
                        twap0by1_ = (1e54 / price_) * time_;
                        twap1by0_ = twap1by0_ / secondsAgo_;
                        twap0by1_ = twap0by1_ / secondsAgo_;
                        twaps_[i] = Oracle(
                            twap1by0_,
                            o_.lowestPrice1by0,
                            o_.highestPrice1by0,
                            twap0by1_,
                            (1e54 / o_.highestPrice1by0),
                            (1e54 / o_.lowestPrice1by0)
                        );
                    }
                }
                if (i == secondsAgos_.length) return (twaps_, currentPrice_); // oracle fetch over
            }
        }
    }

    function getPricesAndExchangePrices() public {
        uint dexVariables_ = dexVariables;
        uint dexVariables2_ = dexVariables2;

        _check(dexVariables_, dexVariables2_);

        PricesAndExchangePrice memory pex_ = _getPricesAndExchangePrices(dexVariables, dexVariables2);

        revert FluidDexPricesAndExchangeRates(pex_);
    }

    /// @dev Internal fallback function to handle calls to non-existent functions
    /// @notice This function is called when a transaction is sent to the contract without matching any other function
    /// @notice It checks if the caller is authorized, enables re-entrancy protection, delegates the call to the admin implementation, and then disables re-entrancy protection
    /// @notice Only authorized callers (global or dex auth) can trigger this function
    /// @notice This function uses assembly to perform a delegatecall to the admin implementation to update configs related to DEX
    function _fallback() private {
        if (!(DEX_FACTORY.isGlobalAuth(msg.sender) || DEX_FACTORY.isDexAuth(address(this), msg.sender))) {
            revert FluidDexError(ErrorTypes.DexT1__NotAnAuth);
        }

        uint dexVariables_ = dexVariables;
        if (dexVariables_ & 1 == 1) revert FluidDexError(ErrorTypes.DexT1__AlreadyEntered);
        // enabling re-entrancy
        dexVariables = dexVariables_ | 1;

        // Delegate the current call to `ADMIN_IMPLEMENTATION`.
        _spell(ADMIN_IMPLEMENTATION, msg.data);

        // disabling re-entrancy
        // directly fetching from storage so updates from Admin module will get auto covered
        dexVariables = dexVariables & ~uint(1);
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        if (msg.sig != 0x00000000) {
            _fallback();
        }
    }

    /// @notice returns all Vault constants
    function constantsView() external view returns (ConstantViews memory constantsView_) {
        constantsView_.dexId = DEX_ID;
        constantsView_.liquidity = address(LIQUIDITY);
        constantsView_.factory = address(DEX_FACTORY);
        constantsView_.token0 = TOKEN_0;
        constantsView_.token1 = TOKEN_1;
        constantsView_.implementations.shift = SHIFT_IMPLEMENTATION;
        constantsView_.implementations.admin = ADMIN_IMPLEMENTATION;
        constantsView_.implementations.colOperations = COL_OPERATIONS_IMPLEMENTATION;
        constantsView_.implementations.debtOperations = DEBT_OPERATIONS_IMPLEMENTATION;
        constantsView_.implementations.perfectOperationsAndSwapOut = PERFECT_OPERATIONS_AND_SWAP_OUT_IMPLEMENTATION;
        constantsView_.deployerContract = DEPLOYER_CONTRACT;
        constantsView_.supplyToken0Slot = SUPPLY_TOKEN_0_SLOT;
        constantsView_.borrowToken0Slot = BORROW_TOKEN_0_SLOT;
        constantsView_.supplyToken1Slot = SUPPLY_TOKEN_1_SLOT;
        constantsView_.borrowToken1Slot = BORROW_TOKEN_1_SLOT;
        constantsView_.exchangePriceToken0Slot = EXCHANGE_PRICE_TOKEN_0_SLOT;
        constantsView_.exchangePriceToken1Slot = EXCHANGE_PRICE_TOKEN_1_SLOT;
        constantsView_.oracleMapping = TOTAL_ORACLE_MAPPING;
    }

    /// @notice returns all Vault constants
    function constantsView2() external view returns (ConstantViews2 memory constantsView2_) {
        constantsView2_.token0NumeratorPrecision = TOKEN_0_NUMERATOR_PRECISION;
        constantsView2_.token0DenominatorPrecision = TOKEN_0_DENOMINATOR_PRECISION;
        constantsView2_.token1NumeratorPrecision = TOKEN_1_NUMERATOR_PRECISION;
        constantsView2_.token1DenominatorPrecision = TOKEN_1_DENOMINATOR_PRECISION;
    }

    /// @notice Calculates the real and imaginary reserves for collateral tokens
    /// @dev This function retrieves the supply of both tokens from the liquidity layer,
    ///      adjusts them based on exchange prices, and calculates imaginary reserves
    ///      based on the geometric mean and price range
    /// @param geometricMean_ The geometric mean of the token prices
    /// @param upperRange_ The upper price range
    /// @param lowerRange_ The lower price range
    /// @param token0SupplyExchangePrice_ The exchange price for token0 from liquidity layer
    /// @param token1SupplyExchangePrice_ The exchange price for token1 from liquidity layer
    /// @return c_ A struct containing the calculated real and imaginary reserves for both tokens:
    ///         - token0RealReserves: The real reserves of token0
    ///         - token1RealReserves: The real reserves of token1
    ///         - token0ImaginaryReserves: The imaginary reserves of token0
    ///         - token1ImaginaryReserves: The imaginary reserves of token1
    function getCollateralReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0SupplyExchangePrice_,
        uint token1SupplyExchangePrice_
    ) public view returns (CollateralReserves memory c_) {
        return
            _getCollateralReserves(
                geometricMean_,
                upperRange_,
                lowerRange_,
                token0SupplyExchangePrice_,
                token1SupplyExchangePrice_
            );
    }

    /// @notice Calculates the debt reserves for both tokens
    /// @param geometricMean_ The geometric mean of the upper and lower price ranges
    /// @param upperRange_ The upper price range
    /// @param lowerRange_ The lower price range
    /// @param token0BorrowExchangePrice_ The exchange price of token0 from liquidity layer
    /// @param token1BorrowExchangePrice_ The exchange price of token1 from liquidity layer
    /// @return d_ The calculated debt reserves for both tokens, containing:
    ///         - token0Debt: The debt amount of token0
    ///         - token1Debt: The debt amount of token1
    ///         - token0RealReserves: The real reserves of token0 derived from token1 debt
    ///         - token1RealReserves: The real reserves of token1 derived from token0 debt
    ///         - token0ImaginaryReserves: The imaginary debt reserves of token0
    ///         - token1ImaginaryReserves: The imaginary debt reserves of token1
    function getDebtReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0BorrowExchangePrice_,
        uint token1BorrowExchangePrice_
    ) public view returns (DebtReserves memory d_) {
        return
            _getDebtReserves(
                geometricMean_,
                upperRange_,
                lowerRange_,
                token0BorrowExchangePrice_,
                token1BorrowExchangePrice_
            );
    }
}
