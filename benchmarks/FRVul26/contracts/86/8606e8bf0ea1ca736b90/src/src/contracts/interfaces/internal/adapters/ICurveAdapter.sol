// SPDX-License-Identifier: UNLICENSED
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
