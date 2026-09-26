// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILotusStaking is IERC721 {
    // Structs
    struct UserRecord {
        uint160 shares;
        uint160 lockedLotus;
        uint128 rewardDebt;
        uint32 endTime;
    }

    // Enums
    enum POOLS {
        DAY8,
        DAY48,
        DAY88
    }

    // Constants
    function MIN_DURATION() external view returns (uint32);
    function MAX_DURATION() external view returns (uint32);

    // Immutable Variables
    function startTimestamp() external view returns (uint32);
    function lotusBloomPool() external view returns (address);
    function titanX() external view returns (address);
    function volt() external view returns (address);
    function lotus() external view returns (address);
    function minSharesToBloom() external view returns (uint256);

    // State Variables
    function totalShares() external view returns (uint256);
    function rewardPerShare() external view returns (uint128);
    function tokenId() external view returns (uint96);
    function lastDistributedDay() external view returns (uint32);
    function toDistribute(POOLS pool) external view returns (uint256);
    function userRecords(uint256 id) external view returns (UserRecord memory);
    function userShares(address user) external view returns (uint256);

    // Functions
    function changeMinSharesToBloom(uint256 newMinShares) external;
    function stake(uint32 duration, uint160 lotusAmount) external returns (uint96 tokenId, uint160 shares);
    function batchClaimableAmount(uint160[] calldata ids) external view returns (uint256 toClaim);
    function unstake(uint160 tokenId, address receiver) external;
    function compoundRewards(uint160 id, uint256 amountVoltMin, uint256 amountLotusMin, uint32 deadline) external;
    function convertLotusToShares(uint160 amount, uint32 duration) external pure returns (uint160 shares);
    function batchUnstake(uint160[] calldata ids, address receiver) external;
    function claim(uint160 tokenId, address receiver) external;
    function batchClaim(uint160[] calldata ids, address receiver) external;
    function isApprovedOrOwner(uint256 tokenId, address spender) external view;
    function distribute(uint256 amount) external;
    function updateRewardsIfNecessary() external;
}
