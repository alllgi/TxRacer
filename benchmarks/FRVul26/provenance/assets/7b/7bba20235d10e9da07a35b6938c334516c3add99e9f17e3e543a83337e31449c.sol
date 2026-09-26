// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IMakerPSMRouter } from "../interfaces/IMakerPSMRouter.sol";

// Libraries
import { ERC20Utils } from "../libraries/ERC20Utils.sol";

// Types
import { MakerPSMData } from "../AugustusV6Types.sol";

// Contracts
import { MakerPSMUtils } from "../util/MakerPSMUtils.sol";
import { Permit2Utils } from "../util/Permit2Utils.sol";

/// @title MakerPSMRouter
/// @notice A facet for executing direct MakerPSM swaps
contract MakerPSMRouterFacet is IMakerPSMRouter, MakerPSMUtils, Permit2Utils {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _daiMaker, address _permit2) MakerPSMUtils(_daiMaker) Permit2Utils(_permit2) { }

    /*//////////////////////////////////////////////////////////////
                        SWAP EXACT AMOUNT IN/OUT
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IMakerPSMRouter
    function swapExactAmountInOutOnMakerPSM(
        MakerPSMData calldata makerPSMData,
        bytes calldata permit
    )
        external
        returns (uint256 spentAmount, uint256 receivedAmount)
    {
        // Dereference makerPSMData
        IERC20 srcToken = makerPSMData.srcToken;
        uint256 toll = makerPSMData.toll;
        uint256 to18ConversionFactor = makerPSMData.to18ConversionFactor;
        address gemJoinAddress = makerPSMData.gemJoinAddress;
        address exchange = makerPSMData.exchange;
        uint256 fromAmount = makerPSMData.fromAmount;
        uint256 toAmount = makerPSMData.toAmount;
        uint256 beneficiaryDirectionApproveFlag = makerPSMData.beneficiaryDirectionApproveFlag;

        // Decode params
        address beneficiary;
        bool approve;
        bool direction;

        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            // Parse beneficiaryDirectionApproveFlag
            beneficiary := and(beneficiaryDirectionApproveFlag, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            approve := shr(255, beneficiaryDirectionApproveFlag)
            direction := and(1, shr(254, beneficiaryDirectionApproveFlag))
        }

        // Get swap type
        uint256 swapType;
        address dai = DAI_MAKER;

        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            swapType := 0x1 // sellGem(address,uint256)
            if eq(srcToken, dai) { swapType := 0x0 } // buyGem(address,uint256)
        }

        // Check if beneficiary is valid
        if (beneficiary == address(0)) {
            beneficiary = msg.sender;
        }

        // Check if toAmount is valid
        if (toAmount == 0) {
            revert InvalidToAmount();
        }

        // Check the length of the permit field,
        // if < 257 and > 0 we should execute regular permit
        // and if it is >= 257 we execute permit2
        if (permit.length < 257) {
            // Permit if needed
            if (permit.length > 0) {
                srcToken.permit(permit);
            }
            srcToken.safeTransferFrom(msg.sender, address(this), fromAmount);
        } else {
            // Otherwise Permit2.permitTransferFrom
            permit2TransferFrom(permit, address(this), fromAmount);
        }
        // Check if approve is needed
        if (approve) {
            if (address(srcToken) == DAI_MAKER) {
                // Approve exchange
                srcToken.approve(exchange);
            } else {
                // Approve gemJoinAddress
                srcToken.approve(gemJoinAddress);
            }
        }

        // Execute swapExactAmountIn or swapExactAmountOut based on direction
        if (!direction) {
            // Execute swapExactAmountIn on Maker PSM
            return _executeSwapExactAmountInOnMakerPSM(
                exchange, swapType, toll, to18ConversionFactor, fromAmount, beneficiary
            );
        } else {
            // Execute swapExactAmountOut on Maker PSM
            _executeSwapExactAmountOutOnMakerPSM(exchange, swapType, toll, to18ConversionFactor, toAmount, beneficiary);
            // Check remaining balance of srcToken
            uint256 remainingAmount = srcToken.balanceOf(address(this));
            // Transfer remaining balance to msg.sender
            if (remainingAmount > 1) {
                srcToken.safeTransfer(msg.sender, --remainingAmount);
            }
            // Return spentAmount and receivedAmount
            return (fromAmount - remainingAmount, toAmount);
        }
    }
}
