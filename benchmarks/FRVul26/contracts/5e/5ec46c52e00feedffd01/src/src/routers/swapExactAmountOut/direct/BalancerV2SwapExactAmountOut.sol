// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IBalancerV2SwapExactAmountOut } from "../../../interfaces/IBalancerV2SwapExactAmountOut.sol";

// Libraries
import { ERC20Utils } from "../../../libraries/ERC20Utils.sol";

// Types
import { BalancerV2Data } from "../../../AugustusV6Types.sol";

// Utils
import { BalancerV2Utils } from "../../../util/BalancerV2Utils.sol";

/// @title BalancerV2SwapExactAmountOut
/// @notice A contract for executing direct swapExactAmountOut on BalancerV2 pools
abstract contract BalancerV2SwapExactAmountOut is IBalancerV2SwapExactAmountOut, BalancerV2Utils {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                         SWAP EXACT AMOUNT OUT
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBalancerV2SwapExactAmountOut
    function swapExactAmountOutOnBalancerV2(
        BalancerV2Data calldata balancerData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata data
    )
        external
        payable
        whenNotPaused
        returns (uint256 spentAmount, uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare)
    {
        // Dereference balancerData
        uint256 quotedAmountIn = balancerData.quotedAmount;
        uint256 beneficiaryAndApproveFlag = balancerData.beneficiaryAndApproveFlag;
        uint256 maxAmountIn = balancerData.fromAmount;
        uint256 amountOut = balancerData.toAmount;

        // Decode params
        (IERC20 srcToken, IERC20 destToken, address payable beneficiary, bool approve) =
            _decodeBalancerV2Params(beneficiaryAndApproveFlag, data);

        // Make sure srcToken and destToken are different
        if (srcToken == destToken) {
            revert ArbitrageNotSupported();
        }

        // Check if toAmount is valid
        if (amountOut == 0) {
            revert InvalidToAmount();
        }

        // Check if beneficiary is valid
        if (beneficiary == address(0)) {
            beneficiary = payable(msg.sender);
        }

        // Check contract balance
        uint256 balanceBefore = srcToken.getBalance(address(this));

        // Check if srcToken is ETH
        if (srcToken.isETH(maxAmountIn) == 0) {
            // Check the length of the permit field,
            // if < 257 and > 0 we should execute regular permit
            // and if it is >= 257 we execute permit2
            if (permit.length < 257) {
                // Permit if needed
                if (permit.length > 0) {
                    srcToken.permit(permit);
                }
                srcToken.safeTransferFrom(msg.sender, address(this), maxAmountIn);
            } else {
                // Otherwise Permit2.permitTransferFrom
                permit2TransferFrom(permit, address(this), maxAmountIn);
            }
            // Check if approve is needed
            if (approve) {
                // Approve BALANCER_VAULT to spend srcToken
                srcToken.approve(BALANCER_VAULT);
            }
        } else {
            // If srcToken is ETH, we have to deduct msg.value from balanceBefore
            balanceBefore = balanceBefore - msg.value;
        }

        // Execute swap
        _callBalancerV2(data);

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
