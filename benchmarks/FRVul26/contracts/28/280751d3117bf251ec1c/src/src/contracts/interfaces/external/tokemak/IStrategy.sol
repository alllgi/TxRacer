// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

import { IERC3156FlashBorrower } from "openzeppelin-contracts/interfaces/IERC3156FlashBorrower.sol";

/*
 * Lighter version of the Tokemak IStrategy interface.
 * A more extensive version can be found in the core project:
 * v2-core/src/interfaces/strategy/IStrategy.sol
 */
interface IStrategy {
    /// @param destinationIn The address / lp token of the destination vault that will increase
    /// @param tokenIn The address of the underlyer token that will be provided by the swapper
    /// @param amountIn The amount of the underlying LP tokens that will be received
    /// @param destinationOut The address of the destination vault that will decrease
    /// @param tokenOut The address of the underlyer token that will be received by the swapper
    /// @param amountOut The amount of the tokenOut that will be received by the swapper
    struct RebalanceParams {
        address destinationIn;
        address tokenIn;
        uint256 amountIn;
        address destinationOut;
        address tokenOut;
        uint256 amountOut;
    }

    /// @notice rebalance the LMP from the tokenOut (decrease) to the tokenIn (increase)
    /// This uses a flash loan to receive the tokenOut to reduce the working capital requirements of the swapper
    /// @param receiver The contract receiving the tokens, needs to implement the
    /// `onFlashLoan(address user, address token, uint256 amount, uint256 fee, bytes calldata)` interface
    /// @param params Parameters by which to perform the rebalance
    /// @param data A data parameter to be passed on to the `receiver` for any custom use
    function flashRebalance(
        IERC3156FlashBorrower receiver,
        RebalanceParams calldata params,
        bytes calldata data
    ) external;
}
