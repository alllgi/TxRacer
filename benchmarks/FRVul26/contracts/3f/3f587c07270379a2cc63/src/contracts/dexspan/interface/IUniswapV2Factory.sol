// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IUniswapV2Exchange.sol";

interface IUniswapV2Factory {
    function getPair(
        IERC20Upgradeable tokenA,
        IERC20Upgradeable tokenB
    ) external view returns (IUniswapV2Exchange pair);
}
