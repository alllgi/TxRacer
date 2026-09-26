// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

import { IStableSwapNG } from "src/contracts/interfaces/external/curve/IStableSwapNG.sol";
import { ICryptoSwapPool } from "src/contracts/interfaces/external/curve/ICryptoSwapPool.sol";
import { ICurveAdapter } from "src/contracts/interfaces/internal/adapters/ICurveAdapter.sol";

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
