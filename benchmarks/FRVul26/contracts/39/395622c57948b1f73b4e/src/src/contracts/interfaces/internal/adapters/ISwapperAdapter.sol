// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/**
 *
 * @dev Weiroll doesn't support low-level calls, so we need to use a proxy contract to make them.
 */
interface ISwapperAdapter {
    error SwapFailedWithNoReasonError(address target, bytes data);

    function swap(address swapperAddress, bytes calldata data) external;
}
