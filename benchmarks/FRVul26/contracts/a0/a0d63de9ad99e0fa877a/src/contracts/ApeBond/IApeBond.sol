// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IApeBondBase, IVestingCurve, IBondTreasury, IERC20MetadataUpgradeable} from "./IApeBondBase.sol";

interface IApeBond is IApeBondBase {
    /// @notice Info for bill holder
    /// @param payout Total payout value
    /// @param payoutClaimed Amount of payout claimed
    /// @param vesting Seconds left until vesting is complete
    /// @param vestingTerm Length of vesting in seconds
    /// @param vestingStartTimestamp Timestamp at start of vesting
    /// @param lastClaimTimestamp Last timestamp interaction
    /// @param truePricePaid Price paid (principal tokens per payout token) in ten-millionths - 4000000 = 0.4
    struct Bill {
        uint256 payout;
        uint256 payoutClaimed;
        uint256 vesting;
        uint256 vestingTerm;
        uint256 vestingStartTimestamp;
        uint256 lastClaimTimestamp;
        uint256 truePricePaid;
    }

    struct BondTerms {
        uint256 controlVariable;
        uint256 vestingTerm;
        uint256 minimumPrice;
        uint256 maxPayout;
        uint256 maxDebt;
        uint256 maxTotalPayout;
        uint256 initialDebt;
    }

    function initialize(
        IBondTreasury _customTreasury,
        BondCreationDetails memory _billCreationDetails,
        BondTerms memory _billTerms,
        BondAccounts memory _billAccounts,
        address[] memory _billOperators
    ) external;

    function getBillInfo(uint256 billId) external view returns (Bill memory);
}
