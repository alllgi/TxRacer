// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Call {
    address to;
    bytes data;
    uint256 value;
}

struct ZapERC20Params {
    // Token to zap
    IERC20 tokenIn;
    // Total amount to zap / pull from user
    uint256 amountIn;
    
    // Weiroll code to execute to produce 'amountOut' of 'tokenOut'
    bytes32[] commands;
    bytes[] state;
    IERC20[] tokens;

    // RTokens the user requested
    uint256 amountOut;
    // RToken to issue
    IERC20 tokenOut;
}

interface FacadeRead {
    function maxIssuable(RToken rToken, address account) external returns (uint256);
}

interface RToken {
    function issueTo(address recipient, uint256 amount) external;
}
