// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/interfaces/stats/ILSTStats.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/// @title Return stats on base LSTs
interface ILSTStats {
    struct LSTStatsData {
        uint256 lastSnapshotTimestamp;
        uint256 baseApr;
        int256 discount; // positive number is a discount, negative is a premium
        uint24[10] discountHistory; // 7 decimal precision
        uint40 discountTimestampByPercent; // timestamp that the token reached 1pct discount
    }

    /// @notice Get the current stats for the LST
    /// @dev Returned data is a combination of current data and filtered snapshots
    /// @return lstStatsData current data on the LST
    function current() external returns (LSTStatsData memory lstStatsData);

    /// @notice Get the EthPerToken (or Share) for the LST
    /// @return ethPerShare the backing eth for the LST
    function calculateEthPerToken() external view returns (uint256 ethPerShare);

    /// @notice Returns whether to use the market price when calculating discount
    /// @dev Will be true for rebasing tokens and other non-standard tokens
    function usePriceAsDiscount() external view returns (bool useAsDiscount);
}

// File: src/interfaces/stats/IDexLSTStats.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



/// @title Return stats DEXs with LSTs
interface IDexLSTStats {
    event DexSnapshotTaken(uint256 snapshotTimestamp, uint256 priorFeeApr, uint256 newFeeApr, uint256 unfilteredFeeApr);

    struct StakingIncentiveStats {
        // time-weighted average total supply to prevent spikes/attacks from impacting rebalancing
        uint256 safeTotalSupply;
        // rewardTokens, annualizedRewardAmounts, and periodFinishForRewards will match indexes
        // they are split to workaround an issue with forge having nested structs
        // address of the reward tokens
        address[] rewardTokens;
        // the annualized reward rate for the reward token
        uint256[] annualizedRewardAmounts;
        // the timestamp for when the rewards are set to terminate
        uint40[] periodFinishForRewards;
        // incentive rewards score. max 48, min 0
        uint8 incentiveCredits;
    }

    struct DexLSTStatsData {
        uint256 lastSnapshotTimestamp;
        uint256 feeApr;
        uint256[] reservesInEth;
        StakingIncentiveStats stakingIncentiveStats;
        ILSTStats.LSTStatsData[] lstStatsData;
    }

    /// @notice Get the current stats for the DEX with underlying LST tokens
    /// @dev Returned data is a combination of current data and filtered snapshots
    /// @return dexLSTStatsData current data on the DEX
    function current() external returns (DexLSTStatsData memory dexLSTStatsData);
}

// File: lib/openzeppelin-contracts/contracts/interfaces/IERC3156FlashBorrower.sol

// OpenZeppelin Contracts (last updated v4.7.0) (interfaces/IERC3156FlashBorrower.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC3156 FlashBorrower, as defined in
 * https://eips.ethereum.org/EIPS/eip-3156[ERC-3156].
 *
 * _Available since v4.1._
 */
interface IERC3156FlashBorrower {
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "IERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

// File: src/interfaces/strategy/IStrategy.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



interface IStrategy {
    /* ******************************** */
    /*      Events                      */
    /* ******************************** */
    event DestinationVaultAdded(address destination);
    event DestinationVaultRemoved(address destination);
    event WithdrawalQueueSet(address[] destinations);
    event AddedToRemovalQueue(address destination);
    event RemovedFromRemovalQueue(address destination);

    error InvalidDestinationVault();

    error RebalanceFailed(string message);

    /// @notice gets the list of supported destination vaults for the Autopool/Strategy
    /// @return _destinations List of supported destination vaults
    function getDestinations() external view returns (address[] memory _destinations);

    /// @notice add supported destination vaults for the Autopool/Strategy
    /// @param _destinations The list of destination vaults to add
    function addDestinations(address[] calldata _destinations) external;

    /// @notice remove supported destination vaults for the Autopool/Strategy
    /// @param _destinations The list of destination vaults to remove
    function removeDestinations(address[] calldata _destinations) external;

    /// @param destinationIn The address / lp token of the destination vault that will increase
    /// @param tokenIn The address of the underlyer token that will be provided by the swapper
    /// @param amountIn The amount of the underlying LP tokens that will be received
    /// @param destinationOut The address of the destination vault that will decrease
    /// @param tokenOut The address of the underlyer token that will be received by the swapper
    /// @param amountOut The amount of the tokenOut that will be received by the swapper
    struct RebalanceParams {
        address destinationIn;
        address tokenIn;
        uint256 amountIn;
        address destinationOut;
        address tokenOut;
        uint256 amountOut;
    }

    /// @param destination The address / lp token of the destination vault
    /// @param baseApr Base Apr is the yield generated by staking rewards
    /// @param feeApr Yield for pool trading fees
    /// @param incentiveApr Incentives for LP
    /// @param safeTotalSupply Safe supply for LP tokens
    /// @param priceReturn Return from price movement to & away from peg
    /// @param maxDiscount Max discount to peg
    /// @param maxPremium Max premium to peg
    /// @param ownedShares Shares owned for this destination
    /// @param compositeReturn Total return combined from the individual yield components
    /// @param pricePerShare Price per share
    struct SummaryStats {
        address destination;
        uint256 baseApr;
        uint256 feeApr;
        uint256 incentiveApr;
        uint256 safeTotalSupply;
        int256 priceReturn;
        int256 maxDiscount;
        int256 maxPremium;
        uint256 ownedShares;
        int256 compositeReturn;
        uint256 pricePerShare;
    }

    /// @notice rebalance the Autopool from the tokenOut (decrease) to the tokenIn (increase)
    /// This uses a flash loan to receive the tokenOut to reduce the working capital requirements of the swapper
    /// @param receiver The contract receiving the tokens, needs to implement the
    /// `onFlashLoan(address user, address token, uint256 amount, uint256 fee, bytes calldata)` interface
    /// @param params Parameters by which to perform the rebalance
    /// @param data A data parameter to be passed on to the `receiver` for any custom use
    function flashRebalance(
        IERC3156FlashBorrower receiver,
        RebalanceParams calldata params,
        bytes calldata data
    ) external;
}

// File: src/interfaces/strategy/IAutopoolStrategy.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



interface IAutopoolStrategy {
    enum RebalanceDirection {
        In,
        Out
    }

    /// @notice verify that a rebalance (swap between destinations) meets all the strategy constraints
    /// @dev Signature identical to IStrategy.verifyRebalance
    function verifyRebalance(
        IStrategy.RebalanceParams memory,
        IStrategy.SummaryStats memory
    ) external returns (bool, string memory message);

    /// @notice called by the Autopool when NAV is updated
    /// @dev can only be called by the strategy's registered Autopool
    /// @param navPerShare The navPerShare to record
    function navUpdate(uint256 navPerShare) external;

    /// @notice called by the Autopool when a rebalance is completed
    /// @dev can only be called by the strategy's registered Autopool
    /// @param rebalanceParams The parameters for the rebalance that was executed
    function rebalanceSuccessfullyExecuted(IStrategy.RebalanceParams memory rebalanceParams) external;

    /// @notice called by the Autopool during rebalance process
    /// @param rebalanceParams The parameters for the rebalance that was executed
    function getRebalanceOutSummaryStats(IStrategy.RebalanceParams memory rebalanceParams)
        external
        returns (IStrategy.SummaryStats memory outSummary);

    /// @notice Returns stats for a given destination
    /// @dev Used to evaluate the current state of the destinations and decide best action
    /// @param destAddress Destination address. Can be a DestinationVault or the AutoPool
    /// @param direction Direction to evaluate the stats at
    /// @param amount Amount to evaluate the stats at
    function getDestinationSummaryStats(
        address destAddress,
        IAutopoolStrategy.RebalanceDirection direction,
        uint256 amount
    ) external returns (IStrategy.SummaryStats memory);

    /// @notice Returns all hooks registered on strategy
    /// @dev Will return zero addresses for unregistered hooks
    /// @return hooks Array of hook addresses
    function getHooks() external view returns (address[] memory hooks);

    /// @notice the number of days to pause rebalancing due to NAV decay
    function pauseRebalancePeriodInDays() external view returns (uint16);

    /// @notice the number of seconds gap between consecutive rebalances
    function rebalanceTimeGapInSeconds() external view returns (uint256);

    /// @notice destinations trading a premium above maxPremium will be blocked from new capital deployments
    function maxPremium() external view returns (int256); // 100% = 1e18

    /// @notice destinations trading a discount above maxDiscount will be blocked from new capital deployments
    function maxDiscount() external view returns (int256); // 100% = 1e18

    /// @notice the allowed staleness of stats data before a revert occurs
    function staleDataToleranceInSeconds() external view returns (uint40);

    /// @notice the swap cost offset period to initialize the strategy with
    function swapCostOffsetInitInDays() external view returns (uint16);

    /// @notice the number of violations required to trigger a tightening of the swap cost offset period (1 to 10)
    function swapCostOffsetTightenThresholdInViolations() external view returns (uint16);

    /// @notice the number of days to decrease the swap offset period for each tightening step
    function swapCostOffsetTightenStepInDays() external view returns (uint16);

    /// @notice the number of days since a rebalance required to trigger a relaxing of the swap cost offset period
    function swapCostOffsetRelaxThresholdInDays() external view returns (uint16);

    /// @notice the number of days to increase the swap offset period for each relaxing step
    function swapCostOffsetRelaxStepInDays() external view returns (uint16);

    // slither-disable-start similar-names
    /// @notice the maximum the swap cost offset period can reach. This is the loosest the strategy will be
    function swapCostOffsetMaxInDays() external view returns (uint16);

    /// @notice the minimum the swap cost offset period can reach. This is the most conservative the strategy will be
    function swapCostOffsetMinInDays() external view returns (uint16);

    /// @notice the number of days for the first NAV decay comparison (e.g., 30 days)
    function navLookback1InDays() external view returns (uint8);

    /// @notice the number of days for the second NAV decay comparison (e.g., 60 days)
    function navLookback2InDays() external view returns (uint8);

    /// @notice the number of days for the third NAV decay comparison (e.g., 90 days)
    function navLookback3InDays() external view returns (uint8);
    // slither-disable-end similar-names

    /// @notice the maximum slippage that is allowed for a normal rebalance
    function maxNormalOperationSlippage() external view returns (uint256); // 100% = 1e18

    /// @notice the maximum amount of slippage to allow when a destination is trimmed due to constraint violations
    /// recommend setting this higher than maxNormalOperationSlippage
    function maxTrimOperationSlippage() external view returns (uint256); // 100% = 1e18

    /// @notice the maximum amount of slippage to allow when a destinationVault has been shutdown
    /// shutdown for a vault is abnormal and means there is an issue at that destination
    /// recommend setting this higher than maxNormalOperationSlippage
    function maxEmergencyOperationSlippage() external view returns (uint256); // 100% = 1e18

    /// @notice the maximum amount of slippage to allow when the Autopool has been shutdown
    function maxShutdownOperationSlippage() external view returns (uint256); // 100% = 1e18

    /// @notice the maximum discount used for price return
    function maxAllowedDiscount() external view returns (int256); // 18 precision

    /// @notice model weight used for LSTs base yield, 1e6 is the highest
    function weightBase() external view returns (uint256);

    /// @notice model weight used for DEX fee yield, 1e6 is the highest
    function weightFee() external view returns (uint256);

    /// @notice model weight used for incentive yield
    function weightIncentive() external view returns (uint256);

    /// @notice model weight applied to an LST discount when exiting the position
    function weightPriceDiscountExit() external view returns (int256);

    /// @notice model weight applied to an LST discount when entering the position
    function weightPriceDiscountEnter() external view returns (int256);

    /// @notice model weight applied to an LST premium when entering or exiting the position
    function weightPricePremium() external view returns (int256);

    /// @notice initial value of the swap cost offset to use
    function swapCostOffsetInit() external view returns (uint16);

    /// @notice initial lst price gap tolerance
    function defaultLstPriceGapTolerance() external view returns (uint256);
}

// File: src/interfaces/stats/IIncentivesPricingStats.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/// @title EWMA pricing for incentive tokens
interface IIncentivesPricingStats {
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);
    event TokenSnapshot(
        address indexed token,
        uint40 lastSnapshot,
        uint256 fastFilterPrice,
        uint256 slowFilterPrice,
        uint256 initCount,
        bool initComplete
    );

    error TokenAlreadyRegistered(address token);
    error TokenNotFound(address token);
    error IncentiveTokenPriceStale(address token);
    error TokenSnapshotNotReady(address token);

    struct TokenSnapshotInfo {
        uint40 lastSnapshot;
        bool _initComplete;
        uint8 _initCount;
        uint256 _initAcc;
        uint256 fastFilterPrice;
        uint256 slowFilterPrice;
    }

    /// @notice add a token to snapshot
    /// @dev the token must be configured in the RootPriceOracle before adding here
    /// @param token the address of the token to add
    function setRegisteredToken(address token) external;

    /// @notice remove a token from being snapshot
    /// @param token the address of the token to remove
    function removeRegisteredToken(address token) external;

    /// @notice get the addresses for all currently registered tokens
    /// @return tokens all of the registered token addresses
    function getRegisteredTokens() external view returns (address[] memory tokens);

    /// @notice get all of the registered tokens with the latest snapshot info
    /// @return tokenAddresses token addresses in the same order as info
    /// @return info a list of snapshot info for the tokens
    function getTokenPricingInfo()
        external
        view
        returns (address[] memory tokenAddresses, TokenSnapshotInfo[] memory info);

    /// @notice update the snapshot for the specified tokens
    /// @dev if a token is not ready to be snapshot the entire call will fail
    function snapshot(address[] calldata tokensToSnapshot) external;

    /// @notice get the latest prices for an incentive token. Reverts if token is not registered
    /// @return fastPrice the price based on the faster filter (weighted toward current prices)
    /// @return slowPrice the price based on the slower filter (weighted toward older prices, relative to fast)
    function getPrice(address token, uint40 staleCheck) external view returns (uint256 fastPrice, uint256 slowPrice);

    /// @notice get the latest prices for an incentive token or zero if the token is not registered
    /// @return fastPrice the price based on the faster filter (weighted toward current prices)
    /// @return slowPrice the price based on the slower filter (weighted toward older prices, relative to fast)
    function getPriceOrZero(
        address token,
        uint40 staleCheck
    ) external view returns (uint256 fastPrice, uint256 slowPrice);
}

// File: lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: src/interfaces/vault/IBaseAssetVault.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

interface IBaseAssetVault {
    /// @notice Asset that this Vault primarily manages
    /// @dev Vault decimals should be the same as the baseAsset
    function baseAsset() external view returns (address);
}

// File: src/interfaces/rewarders/IBaseRewarder.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

interface IBaseRewarder {
    error RecoverDurationPending();

    event RewardAdded(
        uint256 reward,
        uint256 rewardRate,
        uint256 lastUpdateBlock,
        uint256 periodInBlockFinish,
        uint256 historicalRewards
    );
    event UserRewardUpdated(
        address indexed user, uint256 amount, uint256 rewardPerTokenStored, uint256 lastUpdateBlock
    );
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed recipient, uint256 reward);
    event QueuedRewardsUpdated(uint256 startingQueuedRewards, uint256 startingNewRewards, uint256 queuedRewards);
    event AddedToWhitelist(address indexed wallet);
    event RemovedFromWhitelist(address indexed wallet);

    event TokeLockDurationUpdated(uint256 newDuration);

    event Recovered(address token, address recipient, uint256 amount);

    /**
     * @notice Claims and transfers all rewards for the specified account
     */
    function getReward() external;

    /**
     * @notice Stakes the specified amount of tokens for the specified account.
     * @param account The address of the account to stake tokens for.
     * @param amount The amount of tokens to stake.
     */
    function stake(address account, uint256 amount) external;

    /**
     * @notice Calculate the earned rewards for an account.
     * @param account Address of the account.
     * @return The earned rewards for the given account.
     */
    function earned(address account) external view returns (uint256);

    /**
     * @notice Calculates the rewards per token for the current block.
     * @dev The total amount of rewards available in the system is fixed, and it needs to be distributed among the users
     * based on their token balances and staking duration.
     * Rewards per token represent the amount of rewards that each token is entitled to receive at the current block.
     * The calculation takes into account the reward rate, the time duration since the last update,
     * and the total supply of tokens in the staking pool.
     * @return The updated rewards per token value for the current block.
     */
    function rewardPerToken() external view returns (uint256);

    /**
     * @notice Get the current reward rate per block.
     * @return The current reward rate per block.
     */
    function rewardRate() external view returns (uint256);

    /**
     * @notice Get the current TOKE lock duration.
     * @return The current TOKE lock duration.
     */
    function tokeLockDuration() external view returns (uint256);

    /**
     * @notice Get the last block where rewards are applicable.
     * @return The last block number where rewards are applicable.
     */
    function lastBlockRewardApplicable() external view returns (uint256);

    /**
     * @notice The total amount of tokens staked
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice The amount of tokens staked for the specified account
     * @param account The address of the account to get the balance of
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Queue new rewards to be distributed.
     * @param newRewards The amount of new rewards to be queued.
     */
    function queueNewRewards(uint256 newRewards) external;

    /**
     * @notice Token distributed as rewards
     * @return reward token address
     */
    function rewardToken() external view returns (address);

    /**
     * @notice Add an address to the whitelist.
     * @param wallet The address to be added to the whitelist.
     */
    function addToWhitelist(address wallet) external;

    /**
     * @notice Remove an address from the whitelist.
     * @param wallet The address to be removed from the whitelist.
     */
    function removeFromWhitelist(address wallet) external;

    /**
     * @notice Recovers tokens from the rewarder. However, a recovery duration of 1 year is applicable for reward token
     * @param token Address of token
     * @param recipient recipient Address of recipient
     */
    function recover(address token, address recipient) external;

    /**
     * @notice Check if an address is whitelisted.
     * @param wallet The address to be checked.
     * @return bool indicating if the address is whitelisted.
     */
    function isWhitelisted(address wallet) external view returns (bool);
}

// File: src/interfaces/rewarders/IExtraRewarder.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



interface IExtraRewarder is IBaseRewarder {
    /**
     * @notice Withdraws the specified amount of tokens from the vault for the specified account.
     * @param account The address of the account to withdraw tokens for.
     * @param amount The amount of tokens to withdraw.
     */
    function withdraw(address account, uint256 amount) external;

    /**
     * @notice Claims and transfers all rewards for the specified account from this contract.
     * @param account The address of the account to claim rewards for.
     * @param recipient The address to send the rewards to.
     */
    function getReward(address account, address recipient) external;
}

// File: src/interfaces/rewarders/IMainRewarder.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;




interface IMainRewarder is IBaseRewarder {
    error ExtraRewardsNotAllowed();
    error MaxExtraRewardsReached();

    /// @notice Extra rewards can be added, but not removed, ref: https://github.com/Tokemak/v2-core/issues/659
    event ExtraRewardAdded(address reward);

    /**
     * @notice Adds an ExtraRewarder contract address to the extraRewards array.
     * @param reward The address of the ExtraRewarder contract.
     */
    function addExtraReward(address reward) external;

    /**
     * @notice Withdraws the specified amount of tokens from the vault for the specified account, and transfers all
     * rewards for the account from this contract and any linked extra reward contracts.
     * @param account The address of the account to withdraw tokens and claim rewards for.
     * @param amount The amount of tokens to withdraw.
     * @param claim If true, claims all rewards for the account from this contract and any linked extra reward
     * contracts.
     */
    function withdraw(address account, uint256 amount, bool claim) external;

    /**
     * @notice Claims and transfers all rewards for the specified account from this contract and any linked extra reward
     * contracts.
     * @dev If claimExtras is true, also claims all rewards from linked extra reward contracts.
     * @param account The address of the account to claim rewards for.
     * @param recipient The address to send the rewards to.
     * @param claimExtras If true, claims rewards from linked extra reward contracts.
     */
    function getReward(address account, address recipient, bool claimExtras) external;

    /**
     * @notice Number of extra rewards currently registered
     */
    function extraRewardsLength() external view returns (uint256);

    /**
     * @notice Get the extra rewards array values
     */
    function extraRewards() external view returns (address[] memory);

    /**
     * @notice Get the rewarder at the specified index
     */
    function getExtraRewarder(uint256 index) external view returns (IExtraRewarder);
}

// File: src/interfaces/ISystemComponent.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/// @notice Stores a reference to the registry for this system
interface ISystemComponent {
    /// @notice The system instance this contract is tied to
    function getSystemRegistry() external view returns (address registry);
}

// File: src/interfaces/vault/IDestinationVault.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;








interface IDestinationVault is ISystemComponent, IBaseAssetVault, IERC20 {
    enum VaultShutdownStatus {
        Active,
        Deprecated,
        Exploit
    }

    error LogicDefect();
    error BaseAmountReceived(uint256 amount);

    /* ******************************** */
    /* View                             */
    /* ******************************** */

    /// @notice A full unit of this vault
    // solhint-disable-next-line func-name-mixedcase
    function ONE() external view returns (uint256);

    /// @notice The asset that is deposited into the vault
    function underlying() external view returns (address);

    /// @notice The total supply of the underlying asset
    function underlyingTotalSupply() external view returns (uint256);

    /// @notice The asset that rewards and withdrawals to the Autopool are denominated in
    /// @inheritdoc IBaseAssetVault
    function baseAsset() external view override returns (address);

    /// @notice Debt balance of underlying asset that is in contract.  This
    ///     value includes only assets that are known as debt by the rest of the
    ///     system (i.e. transferred in on rebalance), and does not include
    ///     extraneous amounts of underlyer that may have ended up in this contract.
    function internalDebtBalance() external view returns (uint256);

    /// @notice Debt balance of underlying asset staked externally.  This value only
    ///     includes assets known as debt to the rest of the system, and does not include
    ///     any assets staked on behalf of the DV in external contracts.
    function externalDebtBalance() external view returns (uint256);

    /// @notice Returns true value of _underlyer in DV.  Debt + tokens that may have
    ///     been transferred into the contract outside of rebalance.
    function internalQueriedBalance() external view returns (uint256);

    /// @notice Returns true value of staked _underlyer in external contract.  This
    ///     will include any _underlyer that has been staked on behalf of the DV.
    function externalQueriedBalance() external view returns (uint256);

    /// @notice Balance of underlying debt, sum of `externalDebtBalance()` and `internalDebtBalance()`.
    function balanceOfUnderlyingDebt() external view returns (uint256);

    /// @notice Rewarder for this vault
    function rewarder() external view returns (address);

    /// @notice Exchange this destination vault points to
    function exchangeName() external view returns (string memory);

    /// @notice The type of pool associated with this vault
    function poolType() external view returns (string memory);

    /// @notice If the pool only deals in ETH when adding or removing liquidity
    function poolDealInEth() external view returns (bool);

    /// @notice Tokens that base asset can be swapped into
    function underlyingTokens() external view returns (address[] memory);

    /// @notice Gets the reserves of the underlying tokens
    function underlyingReserves() external view returns (address[] memory tokens, uint256[] memory amounts);

    /* ******************************** */
    /* Events                           */
    /* ******************************** */

    event Donated(address sender, uint256 amount);
    event Withdraw(
        uint256 target, uint256 actual, uint256 debtLoss, uint256 claimLoss, uint256 fromIdle, uint256 fromDebt
    );
    event UpdateSignedMessage(bytes32 hash, bool flag);

    /* ******************************** */
    /* Errors                           */
    /* ******************************** */

    error ZeroAddress(string paramName);
    error InvalidShutdownStatus(VaultShutdownStatus status);

    /* ******************************** */
    /* Functions                        */
    /* ******************************** */

    /// @notice Setup the contract. These will be cloned so no constructor
    /// @param baseAsset_ Base asset of the system. WETH/USDC/etc
    /// @param underlyer_ Underlying asset the vault will wrap
    /// @param rewarder_ Reward tracker for this vault
    /// @param incentiveCalculator_ Incentive calculator for this vault
    /// @param additionalTrackedTokens_ Additional tokens that should be considered 'tracked'
    /// @param params_ Any extra parameters needed to setup the contract
    function initialize(
        IERC20 baseAsset_,
        IERC20 underlyer_,
        IMainRewarder rewarder_,
        address incentiveCalculator_,
        address[] memory additionalTrackedTokens_,
        bytes memory params_
    ) external;

    function getRangePricesLP() external returns (uint256 spotPrice, uint256 safePrice, bool isSpotSafe);

    /// @notice Calculates the current value of a portion of the debt based on shares
    /// @dev Queries the current value of all tokens we have deployed, whether its a single place, multiple, staked, etc
    /// @param shares The number of shares to value
    /// @return value The current value of our debt in terms of the baseAsset
    function debtValue(uint256 shares) external returns (uint256 value);

    /// @notice Collects any earned rewards from staking, incentives, etc. Transfers to sender
    /// @dev Should be limited to LIQUIDATOR_MANAGER. Rewards must be collected before claimed
    /// @return amounts amount of rewards claimed for each token
    /// @return tokens tokens claimed
    function collectRewards() external returns (uint256[] memory amounts, address[] memory tokens);

    /// @notice Pull any non-tracked token to the specified destination
    /// @dev Should be limited to TOKEN_RECOVERY_MANAGER
    function recover(address[] calldata tokens, uint256[] calldata amounts, address[] calldata destinations) external;

    /// @notice Recovers any extra underlying both in DV and staked externally not tracked as debt.
    /// @dev Should be limited to TOKEN_SAVER_ROLE.
    /// @param destination The address to send excess underlyer to.
    function recoverUnderlying(address destination) external;

    /// @notice Deposit underlying to receive destination vault shares
    /// @param amount amount of base lp asset to deposit
    function depositUnderlying(uint256 amount) external returns (uint256 shares);

    /// @notice Withdraw underlying by burning destination vault shares
    /// @param shares amount of destination vault shares to burn
    /// @param to destination of the underlying asset
    /// @return amount underlyer amount 'to' received
    function withdrawUnderlying(uint256 shares, address to) external returns (uint256 amount);

    /// @notice Burn specified shares for underlyer swapped to base asset
    /// @param shares amount of vault shares to burn
    /// @param to destination of the base asset
    /// @return amount base asset amount 'to' received
    /// @return tokens the tokens burned to get the base asset
    /// @return tokenAmounts the amount of the tokens burned to get the base asset
    function withdrawBaseAsset(
        uint256 shares,
        address to
    ) external returns (uint256 amount, address[] memory tokens, uint256[] memory tokenAmounts);

    /// @notice Mark this vault as shutdown so that autoPools can react
    function shutdown(VaultShutdownStatus reason) external;

    /// @notice True if the vault has been shutdown
    function isShutdown() external view returns (bool);

    /// @notice Returns the reason for shutdown (or `Active` if not shutdown)
    function shutdownStatus() external view returns (VaultShutdownStatus);

    /// @notice Stats contract for this vault
    function getStats() external view returns (IDexLSTStats);

    /// @notice get the marketplace rewards
    /// @return rewardTokens list of reward token addresses
    /// @return rewardRates list of reward rates
    function getMarketplaceRewards() external returns (uint256[] memory rewardTokens, uint256[] memory rewardRates);

    /// @notice Get the address of the underlying pool the vault points to
    /// @return poolAddress address of the underlying pool
    function getPool() external view returns (address poolAddress);

    /// @notice Gets the spot price of the underlying LP token
    /// @dev Price validated to be inside our tolerance against safe price. Will revert if outside.
    /// @return price Value of 1 unit of the underlying LP token in terms of the base asset
    function getValidatedSpotPrice() external returns (uint256 price);

    /// @notice Gets the safe price of the underlying LP token
    /// @dev Price validated to be inside our tolerance against spot price. Will revert if outside.
    /// @return price Value of 1 unit of the underlying LP token in terms of the base asset
    function getValidatedSafePrice() external returns (uint256 price);

    /// @notice Get the lowest price we can get for the LP token
    /// @dev This price can be attacked is not validate to be in any range
    /// @return price Value of 1 unit of the underlying LP token in terms of the base asset
    function getUnderlyerFloorPrice() external returns (uint256 price);

    /// @notice Get the highest price we can get for the LP token
    /// @dev This price can be attacked is not validate to be in any range
    /// @return price Value of 1 unit of the underlying LP token in terms of the base asset
    function getUnderlyerCeilingPrice() external returns (uint256 price);

    /// @notice Set or unset  a hash as a signed message
    /// @dev Should be limited to DESTINATION_VAULTS_UPDATER. The set hash is used to validate a signature.
    /// This signature can be potentially used to claim offchain rewards earned by Destination Vaults.
    /// @param hash bytes32 hash of a payload
    /// @param flag boolean flag to indicate a validity of hash
    function setMessage(bytes32 hash, bool flag) external;

    /// @notice Allows to change the incentive calculator of destination vault
    /// @dev Only works when vault is shutdown, also validates the calculator before updating
    /// @param incentiveCalculator address of the new incentive calculator
    function setIncentiveCalculator(address incentiveCalculator) external;

    /// @notice Allows to change the extension contract
    /// @dev Should be limited to DESTINATION_VAULT_MANAGER
    /// @param extension contract address
    function setExtension(address extension) external;

    /// @notice Calls the execute function of the extension contract
    /// @dev Should be limited to DESTINATION_VAULT_MANAGER
    /// @dev Special care should be taken to ensure that balances hasn't been manipulated
    /// @param data any data that the extension contract needs
    function executeExtension(bytes calldata data) external;

    /// @notice Returns the max recoup credit given during the withdraw of an undervalued destination
    function recoupMaxCredit() external view returns (uint256);
}

// File: lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// File: src/strategy/libs/Incentives.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;








library Incentives {
    using Math for uint256;

    // when removing liquidity, rewards can be expired by this amount if the pool as incentive credits
    uint256 public constant EXPIRED_REWARD_TOLERANCE = 7 days;

    function calculateIncentiveApr(
        IIncentivesPricingStats pricing,
        IDexLSTStats.StakingIncentiveStats memory stats,
        IAutopoolStrategy.RebalanceDirection direction,
        address destAddress,
        uint256 lpAmountToAddOrRemove,
        uint256 lpPrice
    ) external view returns (uint256) {
        uint40 staleDataToleranceInSeconds = IAutopoolStrategy(address(this)).staleDataToleranceInSeconds();

        bool hasCredits = stats.incentiveCredits > 0;
        uint256 totalRewards = 0;

        uint256 numRewards = stats.annualizedRewardAmounts.length;
        for (uint256 i = 0; i < numRewards; ++i) {
            address rewardToken = stats.rewardTokens[i];
            // Move ahead only if the rewardToken is not 0
            if (rewardToken != address(0)) {
                uint256 tokenPrice = getIncentivePrice(staleDataToleranceInSeconds, pricing, rewardToken);

                // skip processing if the token is worthless or unregistered
                if (tokenPrice == 0) continue;

                uint256 periodFinish = stats.periodFinishForRewards[i];
                uint256 rewardRate = stats.annualizedRewardAmounts[i];
                uint256 rewardDivisor = 10 ** IERC20Metadata(rewardToken).decimals();

                if (direction == IAutopoolStrategy.RebalanceDirection.Out) {
                    // if the destination has credits then extend the periodFinish by the expiredTolerance
                    // this allows destinations that consistently had rewards some leniency
                    if (hasCredits) {
                        periodFinish += EXPIRED_REWARD_TOLERANCE;
                    }

                    // slither-disable-next-line timestamp
                    if (periodFinish > block.timestamp) {
                        // tokenPrice is 1e18 and we want 1e18 out, so divide by the token decimals
                        totalRewards += rewardRate * tokenPrice / rewardDivisor;
                    }
                } else {
                    // when adding to a destination, count incentives only when either of the following conditions are
                    // met:
                    // 1) the incentive lasts at least 3 days
                    // 2) the incentive are allowed 2 expired days when dest has a positive incentive credit balance
                    if (
                        // slither-disable-next-line timestamp
                        periodFinish >= block.timestamp + 3 days
                            || (hasCredits && periodFinish + 2 days > block.timestamp)
                    ) {
                        // tokenPrice is 1e18 and we want 1e18 out, so divide by the token decimals
                        totalRewards += rewardRate * tokenPrice / rewardDivisor;
                    }
                }
            }
        }

        if (totalRewards == 0) {
            return 0;
        }

        uint256 lpTokenDivisor = 10 ** IDestinationVault(destAddress).decimals();
        uint256 totalSupplyInEth = 0;
        // When comparing in & out destinations, we want to consider the supply with our allocation
        // included to estimate the resulting incentive rate
        if (direction == IAutopoolStrategy.RebalanceDirection.Out) {
            totalSupplyInEth = stats.safeTotalSupply * lpPrice / lpTokenDivisor;
        } else {
            totalSupplyInEth = (stats.safeTotalSupply + lpAmountToAddOrRemove) * lpPrice / lpTokenDivisor;
        }

        // Adjust for totalSupplyInEth is 0
        if (totalSupplyInEth != 0) {
            return (totalRewards * 1e18) / totalSupplyInEth;
        } else {
            return (totalRewards);
        }
    }

    function getIncentivePrice(
        uint40 staleDataToleranceInSeconds,
        IIncentivesPricingStats pricing,
        address token
    ) public view returns (uint256) {
        (uint256 fastPrice, uint256 slowPrice) = pricing.getPriceOrZero(token, staleDataToleranceInSeconds);
        return fastPrice.min(slowPrice);
    }
}
