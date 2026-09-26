// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import {Call} from "../interfaces/IXSwapExecutor.sol";

struct SwapDataOrigin {
    address tokenIn;
    uint256 amountIn;
    address tokenOut;
    uint256 estimatedAmountOut;
    uint256 valueForDestinationGas;
    uint256 valueForInstantCcipRecieve;
    Call[] calls;
    bytes additionalData;
    bytes32 integratorId;
    bytes32 referralId;
}
