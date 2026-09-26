// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IBalancerV2SwapExactAmountIn } from "../../../interfaces/IBalancerV2SwapExactAmountIn.sol";

// Libraries
import { ERC20Utils } from "../../../libraries/ERC20Utils.sol";

// Types
import { BalancerV2Data } from "../../../AugustusV6Types.sol";

// Utils
import { BalancerV2Utils } from "../../../util/BalancerV2Utils.sol";

/// @title BalancerV2SwapExactAmountIn
/// @notice A contract for executing direct swapExactAmountIn on Balancer V2
abstract contract BalancerV2SwapExactAmountIn is IBalancerV2SwapExactAmountIn, BalancerV2Utils {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                          SWAP EXACT AMOUNT IN
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBalancerV2SwapExactAmountIn
    function swapExactAmountInOnBalancerV2(
        BalancerV2Data calldata balancerData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata data
    )
        external
        payable
        whenNotPaused
        returns (uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare)
    {
        // Dereference balancerData
        uint256 quotedAmountOut = balancerData.quotedAmount;
        uint256 beneficiaryAndApproveFlag = balancerData.beneficiaryAndApproveFlag;
        uint256 amountIn = balancerData.fromAmount;
        uint256 minAmountOut = balancerData.toAmount;

        // Decode params
        (IERC20 srcToken, IERC20 destToken, address payable beneficiary, bool approve) =
            _decodeBalancerV2Params(beneficiaryAndApproveFlag, data);

        // Check if toAmount is valid
        if (minAmountOut == 0) {
            revert InvalidToAmount();
        }

        // Check if beneficiary is valid
        if (beneficiary == address(0)) {
            beneficiary = payable(msg.sender);
        }

        // Check if srcToken is ETH
        if (srcToken.isETH(amountIn) == 0) {
            // Check the length of the permit field,
            // if < 257 and > 0 we should execute regular permit
            // and if it is >= 257 we execute permit2
            if (permit.length < 257) {
                // Permit if needed
                if (permit.length > 0) {
                    srcToken.permit(permit);
                }
                srcToken.safeTransferFrom(msg.sender, address(this), amountIn);
            } else {
                // Otherwise Permit2.permitTransferFrom
                permit2TransferFrom(permit, address(this), amountIn);
            }
            // Check if approve is needed
            if (approve) {
                // Approve BALANCER_VAULT to spend srcToken
                srcToken.approve(BALANCER_VAULT);
            }
        }

        // Execute swap
        _callBalancerV2(data);

        // Check balance after swap
        receivedAmount = destToken.getBalance(address(this));

        // Check if swap succeeded
        if (receivedAmount < minAmountOut) {
            revert InsufficientReturnAmount();
        }

        // Process fees and transfer destToken to beneficiary
        return processSwapExactAmountInFeesAndTransfer(
            beneficiary, destToken, partnerAndFee, receivedAmount, quotedAmountOut
        );
    }
}
