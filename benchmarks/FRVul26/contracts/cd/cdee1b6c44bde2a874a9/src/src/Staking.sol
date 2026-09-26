// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import "@const/Constants.sol";
import {Eden} from "@core/Eden.sol";
import {Time} from "@utils/Time.sol";
import {Errors} from "@utils/Errors.sol";
import {EdenBloomPool} from "./pools/EdenBloom.sol";
import {wdiv, wmul, sub, wpow} from "@utils/Math.sol";
import {SwapActions, SwapActionParams} from "@actions/SwapActions.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

struct UserRecord {
    uint160 shares;
    uint160 lockedEden;
    uint256 rewardDebt;
    uint32 endTime;
}

/**
 * @title EdenStaking
 * @notice The staking contract of the Eden system, allowing users to stake tokens, earn rewards, and compound earnings.
 * @dev This contract implements staking using ERC721 tokens as proof of staking positions. Users can stake and earn rewards based on locked periods.
 */
contract EdenStaking is ERC721, SwapActions {
    using SafeERC20 for *;

    /**
     * @notice Enum to represent different staking pools with varying durations.
     */
    enum POOLS {
        DAY8, // 8-day pool
        DAY48, // 48-day pool
        DAY88 // 88-day pool

    }

    uint32 public constant MIN_DURATION = 90 days;
    uint32 public constant MAX_DURATION = 1450 days;

    uint32 public immutable startTimestamp;
    EdenBloomPool public immutable edenBloomPool;

    ERC20Burnable public immutable titanX;
    ERC20Burnable public immutable volt;
    Eden public immutable eden;

    uint256 public totalShares;
    uint256 public rewardPerShare;
    uint96 public tokenId;

    uint32 public lastDistributedDay;

    /// @notice -> The minimum amount of shares needed to qualify for eden bloom
    uint256 public minSharesToBloom;

    mapping(POOLS => uint256) public toDistribute;
    mapping(uint256 id => UserRecord record) public userRecords;
    mapping(address user => uint256 totalShares) public userShares;

    //==========ERRORS==========//
    error EdenStaking__InvalidDuration();
    error EdenStaking__NoSharesToClaim();
    error EdenStaking__LockPeriodNotOver();
    error EdenStaking__OnlyMintingAndBurning();

    /**
     * @dev Emitted when a user stakes `eden` tokens for a specific `duration`.
     * @param staker The address of the user staking.
     * @param eden Amount of eden tokens staked.
     * @param id The staking position token ID.
     * @param _shares The number of shares obtained from the staking.
     * @param duration The duration for which the tokens are staked.
     */
    event Staked(address indexed staker, uint256 indexed eden, uint152 indexed id, uint256 _shares, uint32 duration);

    /**
     * @dev Emitted when a user unstakes their tokens.
     * @param shares The number of shares being unstaked.
     * @param edenAmountReceived The amount of eden tokens returned to the user.
     * @param _tokenId The staking position token ID.
     * @param recepient The address receiving the unstaked tokens.
     */
    event Unstaked(
        uint256 indexed shares, uint256 indexed edenAmountReceived, uint256 indexed _tokenId, address recepient
    );

    /**
     * @dev Emitted when a user claims rewards.
     * @param id The staking position token ID.
     * @param rewards The amount of rewards claimed.
     * @param newRewardDebt The updated reward debt for the staking position.
     * @param ownerOfStake The owner of the staking position.
     */
    event Claimed(uint256 indexed id, uint256 indexed rewards, uint256 indexed newRewardDebt, address ownerOfStake);

    /**
     * @dev Emitted when rewards are distributed for a pool.
     * @param pool The pool where rewards are distributed.
     * @param amount The amount of rewards distributed.
     */
    event Distributed(POOLS indexed pool, uint256 indexed amount);

    /**
     * @dev Emitted when rewards are auto compounded
     * @param newShares The additional shares received from the compounding
     * @param stakeId The stake id that had auto compounded the rewards
     * @param ownerOfStake The owner of the stake
     */
    event CompoundedRewards(uint256 indexed newShares, uint160 indexed stakeId, address indexed ownerOfStake);

    constructor(
        uint32 _startTimestamp,
        address _vrfCoordinator,
        uint256 _subscriptionId,
        address _eden,
        address _titanX,
        uint256 _minSharesToBloom,
        address _volt,
        bytes32 _keyHash,
        SwapActionParams memory _params
    ) SwapActions(_params) ERC721("Staking", "STK") {
        startTimestamp = _startTimestamp;

        eden = Eden(_eden);
        titanX = ERC20Burnable(_titanX);
        volt = ERC20Burnable(_volt);
        minSharesToBloom = _minSharesToBloom;

        edenBloomPool = new EdenBloomPool(
            address(this), _vrfCoordinator, _subscriptionId, _titanX, _keyHash, _params._owner, _startTimestamp
        );

        lastDistributedDay = 1;
    }

    function changeMinSharesToBloom(uint256 _newMinShares) external notAmount0(_newMinShares) onlyOwner {
        minSharesToBloom = _newMinShares;
    }

    /**
     * @notice Allows a user to stake a certain amount of Eden tokens for a specific duration.
     * @param _duration The duration (in seconds) to lock the tokens for.
     * @param _edenAmount The amount of Eden tokens to stake.
     * @return _tokenId The ID of the staking position token created.
     * @return shares The number of shares granted for staking.
     */
    function stake(uint32 _duration, uint160 _edenAmount)
        external
        notAmount0(_edenAmount)
        returns (uint96 _tokenId, uint160 shares)
    {
        require(
            MIN_DURATION <= _duration && _duration <= MAX_DURATION && _duration % 24 hours == 0,
            EdenStaking__InvalidDuration()
        );

        updateRewardsIfNecessary();

        _tokenId = ++tokenId;

        shares = convertEdenToShares(_edenAmount, _duration);

        userRecords[_tokenId] = UserRecord({
            endTime: Time.blockTs() + _duration,
            shares: shares,
            rewardDebt: rewardPerShare,
            lockedEden: _edenAmount
        });

        totalShares += shares;

        userShares[msg.sender] += shares;

        emit Staked(msg.sender, _edenAmount, _tokenId, shares, _duration);

        eden.transferFrom(msg.sender, address(this), _edenAmount);

        if (userShares[msg.sender] >= minSharesToBloom) edenBloomPool.participate(msg.sender);

        _mint(msg.sender, _tokenId);
    }

    /**
     * @notice Allows a user to batch check the total claimable rewards for multiple staking positions.
     * @param _ids The array of staking position token IDs.
     * @return toClaim The total amount of claimable rewards.
     */
    function batchClaimableAmount(uint160[] calldata _ids) external view returns (uint256 toClaim) {
        uint32 currentDay = _getCurrentDay();

        uint256 m_rewardsPerShare = rewardPerShare;

        bool distributeDay8 = (currentDay / 8 > lastDistributedDay / 8);
        bool distributeDay48 = (currentDay / 48 > lastDistributedDay / 48);
        bool distributeDay88 = (currentDay / 88 > lastDistributedDay / 88);

        if (distributeDay8) m_rewardsPerShare += wdiv(toDistribute[POOLS.DAY8], totalShares);
        if (distributeDay48) m_rewardsPerShare += wdiv(toDistribute[POOLS.DAY48], totalShares);
        if (distributeDay88) m_rewardsPerShare += wdiv(toDistribute[POOLS.DAY88], totalShares);

        for (uint256 i; i < _ids.length; ++i) {
            uint160 _id = _ids[i];

            UserRecord memory _rec = userRecords[_id];

            toClaim += wmul(_rec.shares, m_rewardsPerShare - _rec.rewardDebt);
        }
    }

    /**
     * @notice Allows a user to unstake their tokens after the staking period has ended.
     * @param _tokenId The staking position token ID.
     * @param _receiver The address to receive the unstaked tokens.
     */
    function unstake(uint160 _tokenId, address _receiver) public notAddress0(_receiver) notAmount0(_tokenId) {
        UserRecord memory record = userRecords[_tokenId];

        require(record.shares != 0, EdenStaking__NoSharesToClaim());
        require(record.endTime <= Time.blockTs(), EdenStaking__LockPeriodNotOver());
        isApprovedOrOwner(_tokenId, msg.sender);

        address ownerOfPosition = ownerOf(_tokenId);

        _claim(_tokenId, _receiver);

        uint256 _locked = record.lockedEden;
        uint256 _shares = record.shares;

        delete userRecords[_tokenId];

        totalShares -= _shares;
        userShares[ownerOfPosition] -= _shares;

        emit Unstaked(_shares, _locked, _tokenId, _receiver);

        eden.transfer(_receiver, _locked);

        if (userShares[ownerOfPosition] <= minSharesToBloom) edenBloomPool.removeParticipant(ownerOfPosition);

        _burn(_tokenId);
    }

    function compoundRewards(uint160 _id, uint256 _amountVoltMin, uint256 _amountEdenMin, uint32 _deadline)
        external
        notExpired(_deadline)
    {
        updateRewardsIfNecessary();

        isApprovedOrOwner(_id, msg.sender);
        UserRecord storage _rec = userRecords[_id];

        uint256 amountToCompound = wmul(_rec.shares, rewardPerShare - _rec.rewardDebt);

        uint256 _voltAmount =
            swapExactInput(address(titanX), address(volt), amountToCompound, _amountVoltMin, _deadline);

        uint256 edenAmount = swapExactInput(address(volt), address(eden), _voltAmount, _amountEdenMin, _deadline);

        _rec.rewardDebt = rewardPerShare;
        _rec.lockedEden += uint160(edenAmount);
        _rec.shares += uint160(edenAmount);

        address _ownerOfPosition = ownerOf(_id);

        userShares[_ownerOfPosition] += edenAmount;

        if (userShares[_ownerOfPosition] >= minSharesToBloom) edenBloomPool.participate(_ownerOfPosition);

        totalShares += edenAmount;

        emit CompoundedRewards(edenAmount, _id, ownerOf(_id));
    }

    function convertEdenToShares(uint160 _amount, uint32 _duration) public pure returns (uint160 shares) {
        shares = _amount;

        shares += uint160(
            wmul(
                uint256(_amount),
                _Erank(_duration, MIN_DURATION, MAX_DURATION, STAKING_ERANK_MINIMUM_BONUS, STAKING_ERANK_MAXIMUM_BONUS)
            )
        );
    }

    // Generic function to calculate the linear interpolation
    function _Erank(
        uint32 _duration,
        uint32 _lowerBoundDays,
        uint32 _upperBoundDays,
        uint256 _lowerMultiplier,
        uint256 _upperMultiplier
    ) private pure returns (uint256) {
        return _lowerMultiplier
            + (_duration - _lowerBoundDays) * (_upperMultiplier - _lowerMultiplier) / (_upperBoundDays - _lowerBoundDays);
    }

    /**
     * @notice Allows batch unstaking of multiple staking positions.
     * @param _ids Array of staking position token IDs.
     * @param _receiver Address to receive the unstaked tokens.
     */
    function batchUnstake(uint160[] calldata _ids, address _receiver) external {
        for (uint256 i; i < _ids.length; ++i) {
            unstake(_ids[i], _receiver);
        }
    }

    /**
     * @notice Allows a user to claim their staking rewards.
     * @param _tokenId The staking position token ID.
     * @param _receiver The address to receive the rewards.
     */
    function claim(uint160 _tokenId, address _receiver) public notAddress0(_receiver) notAmount0(_tokenId) {
        isApprovedOrOwner(_tokenId, msg.sender);
        _claim(_tokenId, _receiver);
    }

    /**
     * @notice Batch claim rewards for multiple staking positions.
     * @param _ids Array of staking position token IDs.
     * @param _receiver Address to receive the claimed rewards.
     */
    function batchClaim(uint160[] calldata _ids, address _receiver) external {
        for (uint256 i; i < _ids.length; ++i) {
            claim(_ids[i], _receiver);
        }
    }

    /**
     * @notice Checks if the user is authorized to operate on a given token.
     * @param _tokenId The staking position token ID.
     * @param _spender The address to check.
     */
    function isApprovedOrOwner(uint256 _tokenId, address _spender) public view {
        _checkAuthorized(ownerOf(_tokenId), _spender, _tokenId);
    }

    /**
     * @notice Distributes rewards into the staking pools.
     * @param _amount The amount of rewards to distribute.
     */
    function distribute(uint256 _amount) external notAmount0(_amount) {
        _distribute(_amount);
    }

    function distributeToSpecificPool(POOLS _pool, uint256 _amount) external notAmount0(_amount) {
        updateRewardsIfNecessary();

        titanX.safeTransferFrom(msg.sender, address(this), _amount);
        toDistribute[_pool] += _amount;
    }

    /**
     * @notice Updates the staking rewards if necessary.
     */
    function updateRewardsIfNecessary() public {
        if (totalShares == 0) return;

        uint32 currentDay = _getCurrentDay();

        bool distributeDay8 = (currentDay / 8 > lastDistributedDay / 8);
        bool distributeDay48 = (currentDay / 48 > lastDistributedDay / 48);
        bool distributeDay88 = (currentDay / 88 > lastDistributedDay / 88);

        if (distributeDay8) _updateRewards(POOLS.DAY8, toDistribute);
        if (distributeDay48) _updateRewards(POOLS.DAY48, toDistribute);
        if (distributeDay88) _updateRewards(POOLS.DAY88, toDistribute);

        lastDistributedDay = currentDay;
    }

    /**
     * @dev Internal function to claim rewards for a staking position.
     * @param _tokenId The staking position token ID.
     * @param _receiver The address to receive the rewards.
     */
    function _claim(uint160 _tokenId, address _receiver) internal {
        UserRecord storage _rec = userRecords[_tokenId];
        updateRewardsIfNecessary();

        uint256 amountToClaim = wmul(_rec.shares, rewardPerShare - _rec.rewardDebt);
        _rec.rewardDebt = rewardPerShare;

        emit Claimed(_tokenId, amountToClaim, rewardPerShare, ownerOf(_tokenId));

        titanX.transfer(_receiver, amountToClaim);
    }

    /**
     * @dev Internal function to distribute rewards into pools.
     * @param amount The amount of rewards to distribute.
     */
    function _distribute(uint256 amount) internal {
        updateRewardsIfNecessary();

        toDistribute[POOLS.DAY8] += wmul(amount, DAY8POOL_DIST);
        toDistribute[POOLS.DAY48] += wmul(amount, DAY48POOL_DIST);
        toDistribute[POOLS.DAY88] += wmul(amount, DAY88POOL_DIST);

        uint256 forEdenBloom = wmul(amount, EDEN_BLOOM_POOL);

        titanX.safeTransferFrom(msg.sender, address(this), amount);

        titanX.safeTransfer(address(edenBloomPool), forEdenBloom);
        edenBloomPool.distributeRewards(uint128(forEdenBloom));
    }

    /**
     * @dev Internal function to update rewards for a given pool.
     * @param pool The pool being updated.
     * @param toDist A reference to the mapping of distributions.
     */
    function _updateRewards(POOLS pool, mapping(POOLS => uint256) storage toDist) internal {
        if (toDist[pool] == 0) return;

        rewardPerShare += wdiv(toDist[pool], totalShares);

        emit Distributed(pool, toDist[pool]);
        toDistribute[pool] = 0;
    }

    /**
     * @dev Returns the current day since the contract started.
     * @return currentDay The current day.
     */
    function _getCurrentDay() internal view returns (uint32 currentDay) {
        if (startTimestamp > Time.blockTs()) return 1;
        currentDay = Time.dayGap(startTimestamp, Time.blockTs()) + 1;
    }

    /**
     * @dev Overrides the _update function from ERC721 to restrict token transfers.
     * @param to The address to update the ownership to.
     * @param _id The ID of the token.
     * @param auth The authorized address for the update.
     * @return The address of the token's previous owner.
     */
    function _update(address to, uint256 _id, address auth) internal override returns (address) {
        address from = _ownerOf(_id);
        require(from == address(0) || to == address(0), EdenStaking__OnlyMintingAndBurning());
        return super._update(to, _id, auth);
    }
}
