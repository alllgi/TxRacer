// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import {Call} from "../interfaces/IXSwapExecutor.sol";

struct SwapDataDestination {
    address receiver;
    address tokenOut;
    uint256 estimatedAmountOut;
    Call[] calls;
}
