// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IErrors } from "./IErrors.sol";

// Types
import { MakerPSMData } from "../AugustusV6Types.sol";

/// @title IMakerPSMRouter
/// @notice Interface for direct swaps on MakerPSM
interface IMakerPSMRouter is IErrors {
    /*//////////////////////////////////////////////////////////////
                          SWAP EXACT AMOUNT IN
    //////////////////////////////////////////////////////////////*/

    /// @notice Executes a swapExactAmountIn or swapExactAmountOut on Maker PSM
    /// @param makerPSMData Struct containing data for the swap
    /// @param permit Permit data for the swap
    /// @return spentAmount The amount of tokens spent
    /// @return receivedAmount The amount of tokens received
    function swapExactAmountInOutOnMakerPSM(
        MakerPSMData calldata makerPSMData,
        bytes calldata permit
    )
        external
        returns (uint256 spentAmount, uint256 receivedAmount);
}
