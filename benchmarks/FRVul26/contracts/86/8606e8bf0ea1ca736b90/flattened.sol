// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/contracts/interfaces/external/curve/IStableSwapNG.sol

pragma solidity 0.8.17;

/* solhint-disable func-name-mixedcase, var-name-mixedcase */
interface IStableSwapNG {
    function token() external returns (address);

    // slither-disable-start naming-convention
    function add_liquidity(uint256[] memory amounts, uint256 min_mint_amount) external payable returns (uint256);

    function remove_liquidity(uint256 amount, uint256[] memory min_amounts) external returns (uint256[] memory);
    // slither-disable-end naming-convention
}

// File: src/contracts/interfaces/external/curve/ICryptoSwapPool.sol

pragma solidity 0.8.17;

/*
 * Lighter version of the Curve ICryptoSwapPool contract.
 * A more extensive version can be found in the core project:
 * v2-core/src/interfaces/external/curve/ICryptoSwapPool.sol
 */

/* solhint-disable func-name-mixedcase, var-name-mixedcase */
interface ICryptoSwapPool {
    function token() external returns (address);

    // slither-disable-start naming-convention
    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external payable returns (uint256);
    function add_liquidity(
        uint256[2] memory amounts,
        uint256 min_mint_amount,
        bool use_eth
    ) external payable returns (uint256);

    function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external payable returns (uint256);
    function add_liquidity(
        uint256[3] memory amounts,
        uint256 min_mint_amount,
        bool use_eth
    ) external payable returns (uint256);

    function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external payable returns (uint256);
    function add_liquidity(
        uint256[4] memory amounts,
        uint256 min_mint_amount,
        bool use_eth
    ) external payable returns (uint256);

    function remove_liquidity(uint256 amount, uint256[2] memory min_amounts) external;

    function remove_liquidity(uint256 amount, uint256[3] memory min_amounts) external;

    function remove_liquidity(uint256 amount, uint256[4] memory min_amounts) external;

    function remove_liquidity_one_coin(uint256 token_amount, uint256 i, uint256 min_amount) external;
    // slither-disable-end naming-convention
}

// File: src/contracts/interfaces/internal/adapters/ICurveAdapter.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

interface ICurveAdapter {
    error UnsupportedNumberOfTokens();

    /**
     * @dev Add liquidity to Curve pool
     * @param poolAddress Curve pool address
     * @param amounts Amounts of tokens to add
     * @param minAmountOut Minimum amount of LP tokens expected to be minted
     * @param useEth Whether to use ETH or not
     */
    function addLiquidity(
        address poolAddress,
        uint256[] memory amounts,
        uint256 minAmountOut,
        bool useEth,
        bool isNg
    ) external returns (uint256);

    /**
     * @dev Remove liquidity from Curve pool
     * @param poolAddress Curve pool address
     * @param lpAmount Amount of LP tokens to remove
     * @param minAmounts Minimum amounts of tokens to receive
     */
    function removeLiquidity(address poolAddress, uint256 lpAmount, uint256[] memory minAmounts, bool isNg) external;
}

// File: src/contracts/adapters/CurveAdapter.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;





// slither-disable-start similar-names,cyclomatic-complexity
contract CurveAdapter is ICurveAdapter {
    /// @inheritdoc ICurveAdapter
    function addLiquidity(
        address poolAddress,
        uint256[] memory amounts,
        uint256 minLpMintAmount,
        bool useEth,
        bool isNg
    ) external returns (uint256 deployed) {
        if (isNg) {
            IStableSwapNG pool = IStableSwapNG(poolAddress);
            deployed = pool.add_liquidity(amounts, minLpMintAmount);
        } else {
            ICryptoSwapPool pool = ICryptoSwapPool(poolAddress);

            uint256 nTokens = amounts.length;

            if (useEth) {
                // slither-disable-start arbitrary-send-eth
                if (_isStableSwap(poolAddress)) {
                    if (nTokens == 2) {
                        uint256[2] memory staticParamArray = [amounts[0], amounts[1]];
                        deployed = pool.add_liquidity{ value: amounts[0] }(staticParamArray, minLpMintAmount);
                    } else if (nTokens == 3) {
                        uint256[3] memory staticParamArray = [amounts[0], amounts[1], amounts[2]];
                        deployed = pool.add_liquidity{ value: amounts[0] }(staticParamArray, minLpMintAmount);
                    } else if (nTokens == 4) {
                        uint256[4] memory staticParamArray = [amounts[0], amounts[1], amounts[2], amounts[3]];
                        deployed = pool.add_liquidity{ value: amounts[0] }(staticParamArray, minLpMintAmount);
                    }
                } else {
                    if (nTokens == 2) {
                        uint256[2] memory staticParamArray = [amounts[0], amounts[1]];
                        deployed = pool.add_liquidity{ value: amounts[0] }(staticParamArray, minLpMintAmount, true);
                    } else if (nTokens == 3) {
                        uint256[3] memory staticParamArray = [amounts[0], amounts[1], amounts[2]];
                        deployed = pool.add_liquidity{ value: amounts[0] }(staticParamArray, minLpMintAmount, true);
                    } else if (nTokens == 4) {
                        uint256[4] memory staticParamArray = [amounts[0], amounts[1], amounts[2], amounts[3]];
                        deployed = pool.add_liquidity{ value: amounts[0] }(staticParamArray, minLpMintAmount, true);
                    }
                }
                // slither-disable-end arbitrary-send-eth
            } else {
                if (nTokens == 2) {
                    uint256[2] memory staticParamArray = [amounts[0], amounts[1]];
                    deployed = pool.add_liquidity(staticParamArray, minLpMintAmount);
                } else if (nTokens == 3) {
                    uint256[3] memory staticParamArray = [amounts[0], amounts[1], amounts[2]];
                    deployed = pool.add_liquidity(staticParamArray, minLpMintAmount);
                } else if (nTokens == 4) {
                    uint256[4] memory staticParamArray = [amounts[0], amounts[1], amounts[2], amounts[3]];
                    deployed = pool.add_liquidity(staticParamArray, minLpMintAmount);
                }
            }
        }
    }

    /// @inheritdoc ICurveAdapter
    function removeLiquidity(address poolAddress, uint256 lpAmount, uint256[] memory minAmounts, bool isNg) external {
        if (isNg) {
            IStableSwapNG pool = IStableSwapNG(poolAddress);
            pool.remove_liquidity(lpAmount, minAmounts);
        } else {
            ICryptoSwapPool pool = ICryptoSwapPool(poolAddress);

            uint256 nTokens = minAmounts.length;

            if (nTokens == 2) {
                uint256[2] memory staticParamArray = [minAmounts[0], minAmounts[1]];
                pool.remove_liquidity(lpAmount, staticParamArray);
            } else if (nTokens == 3) {
                uint256[3] memory staticParamArray = [minAmounts[0], minAmounts[1], minAmounts[2]];
                pool.remove_liquidity(lpAmount, staticParamArray);
            } else if (nTokens == 4) {
                uint256[4] memory staticParamArray = [minAmounts[0], minAmounts[1], minAmounts[2], minAmounts[3]];
                pool.remove_liquidity(lpAmount, staticParamArray);
            } else {
                revert UnsupportedNumberOfTokens();
            }
        }
    }

    function _isStableSwap(address poolAddress) internal view returns (bool) {
        // Using the presence of a gamma() fn as an indicator of pool type
        // slither-disable-start low-level-calls,missing-zero-check,unchecked-lowlevel
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = poolAddress.staticcall(abi.encodeWithSignature("gamma()"));
        // slither-disable-end low-level-calls,missing-zero-check,unchecked-lowlevel

        return !success;
    }
}
// slither-disable-end similar-names
