// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IProPartnerFacet } from "../interfaces/IProPartnerFacet.sol";

// Libraries
import { ERC20Utils } from "../libraries/ERC20Utils.sol";

// Contracts
import { AugustusFees } from "../fees/AugustusFees.sol";
import { GenericUtils } from "../util/GenericUtils.sol";
import { Permit2Utils } from "../util/Permit2Utils.sol";

// Types
import { GenericData } from "../AugustusV6Types.sol";

/// @title ProPartnerFacet
/// @notice Facet for swaps with custom fee model: partner gets 100% of fixed fees, protocol gets 50% of surplus
/// @dev Fee Distribution:
///      1. Partner receives: 100% of fixed fee (calculated on quotedAmount + surplus)
///      2. Protocol receives: 50% of remaining surplus (after fixed fee is taken)
///      3. User receives: Everything else
contract ProPartnerFacet is IProPartnerFacet, GenericUtils {
    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Initialize the facet with immutable variables
    /// @param _feeVault Address of the AugustusFeeVault contract
    /// @param _permit2 Address of the Permit2 contract
    constructor(address _feeVault, address _permit2) AugustusFees(_feeVault) Permit2Utils(_permit2) { }

    /*//////////////////////////////////////////////////////////////
                            SWAP FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IProPartnerFacet
    function swapExactAmountInPro(
        address executor,
        GenericData calldata swapData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata executorData
    )
        external
        payable
        whenNotPaused
        returns (uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare)
    {
        // Dereference swapData
        IERC20 destToken = swapData.destToken;
        IERC20 srcToken = swapData.srcToken;
        uint256 amountIn = swapData.fromAmount;
        uint256 minAmountOut = swapData.toAmount;
        uint256 quotedAmountOut = swapData.quotedAmount;
        address payable beneficiary = swapData.beneficiary;

        // Check if beneficiary is valid
        if (beneficiary == address(0)) {
            beneficiary = payable(msg.sender);
        }

        // Check if toAmount is valid
        if (minAmountOut == 0) {
            revert InvalidToAmount();
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
                srcToken.safeTransferFrom(msg.sender, executor, amountIn);
            } else {
                // Otherwise Permit2.permitTransferFrom
                permit2TransferFrom(permit, executor, amountIn);
            }
        }

        // Execute swap
        _callSwapExactAmountInExecutor(executor, executorData, amountIn);

        // Check balance after swap
        receivedAmount = destToken.getBalance(address(this));

        // Check if swap succeeded
        if (receivedAmount < minAmountOut) {
            revert InsufficientReturnAmount();
        }

        // Use custom fee processing: partner gets full fixed fee, protocol gets surplus
        return processSwapExactAmountInPro(beneficiary, destToken, partnerAndFee, receivedAmount, quotedAmountOut);
    }

    /// @inheritdoc IProPartnerFacet
    function swapExactAmountOutPro(
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

        // Check contract balances
        uint256 srcTokenBalanceBefore = srcToken.getBalance(address(this));
        uint256 destTokenBalanceBefore = destToken.getBalance(address(this));

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
            // If srcToken is ETH, we have to deduct msg.value from srcTokenBalanceBefore
            srcTokenBalanceBefore = srcTokenBalanceBefore - msg.value;
        }

        // Execute swap
        _callSwapExactAmountOutExecutor(executor, executorData, maxAmountIn, amountOut);

        // Check balance of destToken (subtract balance before to preserve dust from previous transactions)
        receivedAmount = destToken.getBalance(address(this)) - destTokenBalanceBefore;

        // Check balance of srcToken, deducting the balance before the swap if it is greater than 1
        uint256 remainingAmount =
            srcToken.getBalance(address(this)) - (srcTokenBalanceBefore > 1 ? srcTokenBalanceBefore : 0);

        // Check if swap succeeded
        if (receivedAmount < amountOut) {
            revert InsufficientReturnAmount();
        }

        // Process fees and transfer destToken and srcToken to beneficiary
        return processSwapExactAmountOutPro(
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
