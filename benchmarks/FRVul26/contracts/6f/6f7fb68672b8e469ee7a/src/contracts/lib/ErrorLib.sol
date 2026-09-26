// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.20;

library ErrorLib {
    error CallerIsNotPoolingManager();
    error CallerIsNotAdmin();
    error InvalidPoolingManager();
    error NotPoolingManager();
    error InvalidUnderlyingToken();
    error InvalidSyUnderlyingToken();
    error PoolNotExist();
    error InvalidSlippage();
    error ErrorStrategyNotExist(address strategy);
    error ErrorBeforeProcessStrategy(address strategy);
    error ErrorDepositStrategy(address strategy);
    error ErrorWithdrawStrategy(address strategy);
    error ErrorAfterWithdrawStrategy(address strategy);
    error InvalidMarket();
    error ZeroAmount();
    error Expired();
    error MinReceivedAmountExceeded();
    error InvalidToken();
    error InvalidSyToken();
    error IncreaseCardinalityRequired();
    error OldestObservationNotSatisfied();
    error InvalidBalancerPool();
    error InvalidUniswapPath();
    error InvalidCurvePool();
}
