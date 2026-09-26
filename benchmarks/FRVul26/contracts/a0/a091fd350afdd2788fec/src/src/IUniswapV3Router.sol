// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISwapRouter} from "./ISwapRouter.sol";

interface IUniswapV3Router is ISwapRouter {
    function factory() external pure returns (address);
    function weth() external pure returns (address);
}
