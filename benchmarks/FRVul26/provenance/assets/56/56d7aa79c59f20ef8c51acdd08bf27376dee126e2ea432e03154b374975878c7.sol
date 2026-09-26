// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

interface IMasterOracle {
    function quote(address tokenIn_, address tokenOut_, uint256 amountIn_) external view returns (uint256 _amountOut);

    function getPriceInUsd(address token_) external view returns (uint256 _priceInUsd);
}
