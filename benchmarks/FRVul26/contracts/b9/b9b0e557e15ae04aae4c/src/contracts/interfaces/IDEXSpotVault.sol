// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
interface ISpotVault {

 function spotSwap(
        address owner,
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 minReturnAmount,
        bytes calldata exchangeData
    ) external;


    function withdrawERC20(
        address owner,
        address to,
        uint256 amount,
        address token
    )external;
   
}