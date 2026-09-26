// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IGenericSwapExactAmountOut } from "../../interfaces/IGenericSwapExactAmountOut.sol";

// Libraries
import { ERC20Utils } from "../../libraries/ERC20Utils.sol";

// Types
import { GenericData } from "../../AugustusV6Types.sol";

// Utils
import { GenericUtils } from "../../util/GenericUtils.sol";

/// @title GenericSwapExactAmountOut
/// @notice Router for executing generic swaps with exact amount out through an executor
abstract contract GenericSwapExactAmountOut is IGenericSwapExactAmountOut, GenericUtils {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                         SWAP EXACT AMOUNT OUT
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IGenericSwapExactAmountOut
    function swapExactAmountOut(
        address executor,
        GenericData calldata swapData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata executorData
    )
        external
        payable
        whenNotPaused
        returns (uint256 spentAmount, uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare)
    {
        // Dereference swapData
        IERC20 destToken = swapData.destToken;
        IERC20 srcToken = swapData.srcToken;
        uint256 maxAmountIn = swapData.fromAmount;
        uint256 amountOut = swapData.toAmount;
        uint256 quotedAmountIn = swapData.quotedAmount;
        address payable beneficiary = swapData.beneficiary;

        // Make sure srcToken and destToken are different
        if (srcToken == destToken) {
            revert ArbitrageNotSupported();
        }

        // Check if beneficiary is valid
        if (beneficiary == address(0)) {
            beneficiary = payable(msg.sender);
        }

        // Check if toAmount is valid
        if (amountOut == 0) {
            revert InvalidToAmount();
        }

        // Check contract balance
        uint256 balanceBefore = srcToken.getBalance(address(this));

        // Check if srcToken is ETH
        // Transfer srcToken to executor if not ETH
        if (srcToken.isETH(maxAmountIn) == 0) {
            // Check the length of the permit field,
            // if < 257 and > 0 we should execute regular permit
            // and if it is >= 257 we execute permit2
            if (permit.length < 257) {
                // Permit if needed
                if (permit.length > 0) {
                    srcToken.permit(permit);
                }
                srcToken.safeTransferFrom(msg.sender, executor, maxAmountIn);
            } else {
                // Otherwise Permit2.permitTransferFrom
                permit2TransferFrom(permit, executor, maxAmountIn);
            }
        } else {
            // If srcToken is ETH, we have to deduct msg.value from balanceBefore
            balanceBefore = balanceBefore - msg.value;
        }

        // Execute swap
        _callSwapExactAmountOutExecutor(executor, executorData, maxAmountIn, amountOut);

        // Check balance of destToken
        receivedAmount = destToken.getBalance(address(this));

        // Check balance of srcToken, deducting the balance before the swap if it is greater than 1
        uint256 remainingAmount = srcToken.getBalance(address(this)) - (balanceBefore > 1 ? balanceBefore : 0);

        // Check if swap succeeded
        if (receivedAmount < amountOut) {
            revert InsufficientReturnAmount();
        }

        // Process fees and transfer destToken and srcToken to beneficiary
        return processSwapExactAmountOutFeesAndTransfer(
            beneficiary,
            srcToken,
            destToken,
            partnerAndFee,
            maxAmountIn,
            remainingAmount,
            receivedAmount,
            quotedAmountIn
        );
    }
}
