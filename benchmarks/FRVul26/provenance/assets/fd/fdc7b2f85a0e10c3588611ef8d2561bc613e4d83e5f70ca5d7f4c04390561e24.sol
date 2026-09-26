// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DummyFixedSwapRouter {
    using SafeERC20 for IERC20;

    address public tokenOut;
    uint256 public amountOut;

    constructor(address _tokenOut, uint256 _amountOut) {
        tokenOut = _tokenOut;
        amountOut = _amountOut;
    }

    function setAmountOut(uint256 _amountOut) external {
        amountOut = _amountOut;
    }

    function swap(address _tokenIn, uint256 _amountIn) external payable {
        if (_tokenIn == address(0)) {
            require(msg.value == _amountIn, "wrong msg.value");
        } else {
            IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);
        }

        if (tokenOut == address(0)) {
            (bool success, ) = msg.sender.call{value: amountOut}("");
            require(success, "eth transfer failed");
        } else {
            IERC20(tokenOut).safeTransfer(msg.sender, amountOut);
        }
    }

    receive() external payable {}
}
