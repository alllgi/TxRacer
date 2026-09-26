// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IUniswapExchange.sol";

interface IUniswapFactory {
    function getExchange(
        IERC20Upgradeable token
    ) external view returns (IUniswapExchange exchange);
}
