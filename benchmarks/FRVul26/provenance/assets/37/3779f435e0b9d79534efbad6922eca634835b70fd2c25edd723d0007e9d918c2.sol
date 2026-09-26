// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./DummyAllowanceHolder.sol";

contract DummyPool {
    using SafeERC20 for IERC20;

    address public tokenA;
    address public tokenB;
    uint256 public feeBps;

    constructor(address _tokenA, address _tokenB, uint256 _feeBps) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        feeBps = _feeBps;
    }

    function setFeeBps(uint256 _feeBps) external {
        feeBps = _feeBps;
    }

    function swap(address tokenIn, uint256 amountIn) external payable {
        _swap(tokenIn, amountIn, msg.sender, true);
    }

    function swap(
        address tokenIn,
        uint256 amountIn,
        address recipient
    ) external payable {
        _swap(tokenIn, amountIn, recipient, true);
    }

    // Special swap function that works with allowance holder
    function swapWithAllowanceHolder(
        address tokenIn,
        uint256 amountIn,
        address allowanceHolder
    ) external payable {
        require(allowanceHolder != address(0), "Invalid allowance holder");
        
        if (tokenIn == address(0)) {
            require(msg.value == amountIn, "Incorrect native token amount");
            _swap(tokenIn, amountIn, msg.sender, true);
        } else {
            require(msg.value == 0, "Native token not expected");
            // Pull tokens through allowance holder
            DummyAllowanceHolder(allowanceHolder).pullTokens(
                tokenIn,
                msg.sender,
                address(this),
                amountIn
            );
            // Skip transferFrom since tokens are already transferred
            _swap(tokenIn, amountIn, msg.sender, false);
        }
    }

    function _swap(
        address tokenIn,
        uint256 amountIn,
        address recipient,
        bool shouldTransfer
    ) internal {
        uint256 amount0In;
        uint256 amount1In;
        address tokenOut;
        if (tokenIn == tokenA) {
            amount0In = amountIn;
            tokenOut = tokenB;
        } else if (tokenIn == tokenB) {
            amount1In = amountIn;
            tokenOut = tokenA;
        } else {
            require(false);
        }

        if (tokenIn == address(0)) {
            require(msg.value == amountIn);
        } else if (shouldTransfer) {
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        }

        (uint256 reserve0, uint256 reserve1, uint256 k) = getReserves();

        reserve0 -= amount0In;
        reserve1 -= amount1In;
        k = reserve0 * reserve1;

        (uint256 amount0Out, uint256 amount1Out) = _calcSwap(
            amount0In,
            amount1In,
            reserve0,
            reserve1,
            k
        );
        uint256 amountOut = amount0Out == 0 ? amount1Out : amount0Out;

        if (tokenOut == address(0)) {
            (bool success, ) = recipient.call{value: amountOut}("");
            require(success);
        } else {
            IERC20(tokenOut).safeTransfer(recipient, amountOut);
        }
    }

    function getReserves()
        public
        view
        returns (uint256 reserve0, uint256 reserve1, uint256 k)
    {
        reserve0 = tokenA == address(0)
            ? address(this).balance
            : IERC20(tokenA).balanceOf(address(this));
        reserve1 = tokenB == address(0)
            ? address(this).balance
            : IERC20(tokenB).balanceOf(address(this));
        k = reserve0 * reserve1;
    }

    function calcSwap(
        uint256 amount0In,
        uint256 amount1In
    ) external view returns (uint256 amount0Out, uint256 amount1Out) {
        (uint256 reserve0, uint256 reserve1, uint256 k) = getReserves();
        return _calcSwap(amount0In, amount1In, reserve0, reserve1, k);
    }

    function _calcSwap(
        uint256 amount0In,
        uint256 amount1In,
        uint256 reserve0,
        uint256 reserve1,
        uint256 k
    ) internal view returns (uint256 amount0Out, uint256 amount1Out) {
        if (amount0In != 0) {
            amount0In = (amount0In * (10000 - feeBps)) / 10000;
            uint256 newReserve0 = reserve0 + amount0In;
            uint256 newReserve1 = k / newReserve0;
            amount1Out = reserve1 - newReserve1;
        } else if (amount1In != 0) {
            amount1In = (amount1In * (10000 - feeBps)) / 10000;
            uint256 newReserve1 = reserve1 + amount1In;
            uint256 newReserve0 = k / newReserve1;
            amount0Out = reserve0 - newReserve0;
        } else {
            require(false, "SHOULD_NOT_HAPPEN");
        }
    }

    receive() external payable {}
}
