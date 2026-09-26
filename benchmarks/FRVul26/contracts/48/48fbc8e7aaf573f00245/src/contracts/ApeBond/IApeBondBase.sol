// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IERC20MetadataUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import {IBondTreasury} from "../IBondTreasury.sol";
import {IVestingCurve} from "../curves/IVestingCurve.sol";

interface IApeBondBase {
    /// @notice Details required to create a new bill
    /// @param payoutToken The token in which the payout will be made
    /// @param principalToken The token used to purchase the bill
    /// @param initialOwner The initial owner of the bill
    /// @param vestingCurve The vesting curve contract used for the bill
    /// @param tierCeilings The ceilings of each tier for the bill
    /// @param fees The fees associated with each tier
    /// @param feeInPayout Boolean indicating if the fee is taken from the payout
    struct BondCreationDetails {
        address payoutToken;
        address principalToken;
        address initialOwner;
        IVestingCurve vestingCurve;
        uint256[] tierCeilings;
        uint256[] fees;
        bool feeInPayout;
    }

    /// @notice Important accounts related to a ApeBond
    /// @param feeTo Account which receives the bill fees
    /// @param discountManager Account used to change the discount
    /// @param billNft BillNFT contract which mints the NFTs
    struct BondAccounts {
        address feeTo;
        address discountManager;
        address billNft;
    }

    function customTreasury() external returns (IBondTreasury);

    function claim(uint256 billId) external returns (uint256);

    function pendingVesting(uint256 billId) external view returns (uint256);

    function pendingPayout(uint256 billId) external view returns (uint256);

    function vestingPeriod(uint256 billId) external view returns (uint256 vestingStart_, uint256 vestingEnd_);

    function vestingPayout(uint256 billId) external view returns (uint256 vestingPayout_);

    function vestedPayoutAtTime(uint256 billId, uint256 timestamp) external view returns (uint256 vestedPayout_);

    function claimablePayout(uint256 billId) external view returns (uint256 claimablePayout_);

    function payoutToken() external view returns (IERC20MetadataUpgradeable);

    function principalToken() external view returns (IERC20MetadataUpgradeable);
}
