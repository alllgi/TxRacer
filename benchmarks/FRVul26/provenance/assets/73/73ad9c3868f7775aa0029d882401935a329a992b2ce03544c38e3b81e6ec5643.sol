// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../DeBridgeRouter.sol";

contract DummySwapCaller {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event ActualAmountOut(uint256 actualAmountOut);

    function callSwap(
        DeBridgeRouter _deBridgeRouter,
        address _tokenIn,
        uint256 _amountIn,
        bytes memory _tokenInPermitEnvelope,
        DeBridgeRouter.SameChainSwapDetails calldata _swapDetails,
        uint32 _referralCode
    ) external payable {
        if (_tokenIn == address(0)) {
            require(msg.value == _amountIn, "Incorrect native token amount sent");
        } else {
            require(msg.value == 0, "Native token sent with ERC20 swap");
            // Ensure the contract has enough allowance to transfer tokens
            _lazyApprove(_tokenIn, address(_deBridgeRouter), _amountIn);
            // Transfer the tokens from the caller to this contract
            IERC20Upgradeable(_tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                _amountIn
            );
        }

        uint256 actualAmountOut = _deBridgeRouter.swap{value: msg.value}(
            _tokenIn,
            _amountIn,
            _tokenInPermitEnvelope,
            _swapDetails,
            _referralCode
        );

        emit ActualAmountOut(actualAmountOut);
    }

    function _lazyApprove(
        address _tokenAddress,
        address _spender,
        uint256 _amount
    ) private {
        IERC20Upgradeable token = IERC20Upgradeable(_tokenAddress);
        uint256 currentAllowance = token.allowance(address(this), _spender);

        if (currentAllowance < _amount) {
            // if an approval was issued before
            token.safeApprove(_spender, 0);
            // create permanent approve
            token.safeApprove(_spender, type(uint256).max);
        }
    }
}
