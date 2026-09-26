// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { IErrors } from "./IErrors.sol";
import { GenericData } from "../AugustusV6Types.sol";

/// @title IProPartnerFacet
/// @notice Interface for swaps with custom fee model: partner gets 100% of fixed fees, protocol gets 50% of surplus
/// @dev Fee Distribution Model:
///      - Partner receives: 100% of the fixed fee (calculated on quotedAmount + surplus)
///      - Protocol receives: 50% of remaining surplus (after fixed fee is taken)
///      - User receives: Everything else
interface IProPartnerFacet is IErrors {
    /// @notice Execute a swap with exact input amount using custom fee model
    /// @dev Fee split: Partner gets 100% of fixed fees, ParaSwap gets 50% of remaining surplus
    /// @param executor The address of the executor contract to use
    /// @param swapData Generic data containing the swap information
    /// @param partnerAndFee Packed uint256 with partner address and fee configuration
    /// @param permit The permit data for token approval
    /// @param executorData The data to execute on the executor
    /// @return receivedAmount The amount of destToken the user receives (after all fees)
    /// @return paraswapShare Protocol's fee share (50% of remaining surplus after fixed fee)
    /// @return partnerShare Partner's fee share (100% of the fixed fee)
    function swapExactAmountInPro(
        address executor,
        GenericData calldata swapData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata executorData
    )
        external
        payable
        returns (uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare);

    /// @notice Execute a swap with exact output amount using custom fee model
    /// @dev Fee split: Partner gets 100% of fixed fees, ParaSwap gets 50% of surplus (spending less)
    /// @param executor The address of the executor contract to use
    /// @param swapData Generic data containing the swap information
    /// @param partnerAndFee Packed uint256 with partner address and fee configuration
    /// @param permit The permit data for token approval
    /// @param executorData The data to execute on the executor
    /// @return spentAmount The actual amount of srcToken spent in the swap
    /// @return receivedAmount The amount of destToken the user receives
    /// @return paraswapShare Protocol's fee share (50% of surplus from spending less)
    /// @return partnerShare Partner's fee share (100% of the fixed fee)
    function swapExactAmountOutPro(
        address executor,
        GenericData calldata swapData,
        uint256 partnerAndFee,
        bytes calldata permit,
        bytes calldata executorData
    )
        external
        payable
        returns (uint256 spentAmount, uint256 receivedAmount, uint256 paraswapShare, uint256 partnerShare);
}
