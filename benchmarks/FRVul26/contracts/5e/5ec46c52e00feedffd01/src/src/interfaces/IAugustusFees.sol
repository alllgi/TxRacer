// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title IAugustusFees
/// @notice Interface for the AugustusFees contract, which handles the fees for the Augustus aggregator
interface IAugustusFees {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error emmited when the balance is not enough to pay the fees
    error InsufficientBalanceToPayFees();

    /// @notice Error emmited when the quotedAmount is bigger than the fromAmount
    error InvalidQuotedAmount();

    /*//////////////////////////////////////////////////////////////
                                 PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Parses the `partnerAndFee` parameter to extract the partner address and fee data.
    /// @dev `partnerAndFee` is a uint256 value where data is packed in a specific bit layout.
    ///
    ///      The bit layout for `partnerAndFee` is as follows:
    ///      - The most significant 160 bits (positions 255 to 96) represent the partner address.
    ///      - Bits 95 to 92 are reserved for flags indicating various fee processing conditions:
    ///          - 95th bit: `IS_TAKE_SURPLUS_MASK` - Partner takes surplus
    ///          - 94th bit: `IS_REFERRAL_MASK` - Referral takes surplus
    ///          - 93rd bit: `IS_SKIP_BLACKLIST_MASK` - Bypass token blacklist when processing fees
    ///          - 92nd bit: `IS_CAP_SURPLUS_MASK` - Cap surplus to 1% of quoted amount
    ///      - The least significant 16 bits (positions 15 to 0) encode the fee percentage.
    ///
    /// @param partnerAndFee Packed uint256 containing both partner address and fee data.
    /// @return partner The extracted partner address as a payable address.
    /// @return feeData The extracted fee data containing the fee percentage and flags.
    function parsePartnerAndFeeData(uint256 partnerAndFee)
        external
        pure
        returns (address payable partner, uint256 feeData);
}
