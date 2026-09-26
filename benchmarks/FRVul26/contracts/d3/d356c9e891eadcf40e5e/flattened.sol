// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/libs/Roles.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;

library Roles {
    // Naming Conventions:
    // - Use MANAGER, CREATOR, UPDATER, ..., for roles primarily managing on-chain activities.
    // - Use EXECUTOR for roles that trigger off-chain initiated actions.
    // - Group roles by functional area for clarity.

    // Destination Vault Management
    bytes32 public constant DESTINATION_VAULT_FACTORY_MANAGER = keccak256("CREATE_DESTINATION_VAULT_ROLE");
    bytes32 public constant DESTINATION_VAULT_REGISTRY_MANAGER = keccak256("DESTINATION_VAULT_REGISTRY_MANAGER");
    bytes32 public constant DESTINATION_VAULT_MANAGER = keccak256("DESTINATION_VAULT_MANAGER");

    // Auto Pool Factory and Registry Management
    bytes32 public constant AUTO_POOL_REGISTRY_UPDATER = keccak256("REGISTRY_UPDATER");
    bytes32 public constant AUTO_POOL_FACTORY_MANAGER = keccak256("AUTO_POOL_FACTORY_MANAGER");
    bytes32 public constant AUTO_POOL_FACTORY_VAULT_CREATOR = keccak256("CREATE_POOL_ROLE");

    // Auto Pool Management
    bytes32 public constant AUTO_POOL_DESTINATION_UPDATER = keccak256("DESTINATION_VAULTS_UPDATER");
    bytes32 public constant AUTO_POOL_FEE_UPDATER = keccak256("AUTO_POOL_FEE_SETTER_ROLE");
    bytes32 public constant AUTO_POOL_PERIODIC_FEE_UPDATER = keccak256("AUTO_POOL_PERIODIC_FEE_SETTER_ROLE");
    bytes32 public constant AUTO_POOL_REWARD_MANAGER = keccak256("AUTO_POOL_REWARD_MANAGER_ROLE");
    bytes32 public constant AUTO_POOL_MANAGER = keccak256("AUTO_POOL_ADMIN");
    bytes32 public constant REBALANCER = keccak256("REBALANCER_ROLE");
    bytes32 public constant STATS_HOOK_POINTS_ADMIN = keccak256("STATS_HOOK_POINTS_ADMIN");

    // Reward Management
    bytes32 public constant LIQUIDATOR_MANAGER = keccak256("LIQUIDATOR_ROLE");
    bytes32 public constant DV_REWARD_MANAGER = keccak256("DV_REWARD_MANAGER_ROLE");
    bytes32 public constant REWARD_LIQUIDATION_MANAGER = keccak256("REWARD_LIQUIDATION_MANAGER");
    bytes32 public constant EXTRA_REWARD_MANAGER = keccak256("EXTRA_REWARD_MANAGER_ROLE");
    bytes32 public constant REWARD_LIQUIDATION_EXECUTOR = keccak256("REWARD_LIQUIDATION_EXECUTOR");

    // Statistics and Reporting
    bytes32 public constant STATS_CALC_REGISTRY_MANAGER = keccak256("STATS_CALC_REGISTRY_MANAGER");
    bytes32 public constant STATS_CALC_FACTORY_MANAGER = keccak256("CREATE_STATS_CALC_ROLE");
    bytes32 public constant STATS_CALC_FACTORY_TEMPLATE_MANAGER = keccak256("STATS_CALC_TEMPLATE_MGMT_ROLE");

    bytes32 public constant STATS_SNAPSHOT_EXECUTOR = keccak256("STATS_SNAPSHOT_ROLE");
    bytes32 public constant STATS_INCENTIVE_TOKEN_UPDATER = keccak256("STATS_INCENTIVE_TOKEN_UPDATER");
    bytes32 public constant STATS_GENERAL_MANAGER = keccak256("STATS_GENERAL_MANAGER");
    bytes32 public constant STATS_LST_ETH_TOKEN_EXECUTOR = keccak256("STATS_LST_ETH_TOKEN_EXECUTOR");

    // Emergency Management
    bytes32 public constant EMERGENCY_PAUSER = keccak256("EMERGENCY_PAUSER");
    bytes32 public constant SEQUENCER_OVERRIDE_MANAGER = keccak256("SEQUENCER_OVERRIDE_MANAGER");

    // Miscellaneous Roles
    bytes32 public constant SOLVER = keccak256("SOLVER_ROLE");
    bytes32 public constant AUTO_POOL_REPORTING_EXECUTOR = keccak256("AUTO_POOL_UPDATE_DEBT_REPORTING_ROLE");

    // Swapper Roles
    bytes32 public constant SWAP_ROUTER_MANAGER = keccak256("SWAP_ROUTER_MANAGER");

    // Price Oracles Roles
    bytes32 public constant ORACLE_MANAGER = keccak256("ORACLE_MANAGER_ROLE");
    bytes32 public constant CUSTOM_ORACLE_EXECUTOR = keccak256("CUSTOM_ORACLE_EXECUTOR");
    bytes32 public constant MAVERICK_FEE_ORACLE_EXECUTOR = keccak256("MAVERICK_FEE_ORACLE_MANAGER");

    // AccToke Roles
    bytes32 public constant ACC_TOKE_MANAGER = keccak256("ACC_TOKE_MANAGER");

    // Admin Roles
    bytes32 public constant TOKEN_RECOVERY_MANAGER = keccak256("TOKEN_RECOVERY_ROLE");
    bytes32 public constant INFRASTRUCTURE_MANAGER = keccak256("INFRASTRUCTURE_MANAGER");

    // Cross chain communications roles
    bytes32 public constant MESSAGE_PROXY_MANAGER = keccak256("MESSAGE_PROXY_MANAGER");
    bytes32 public constant MESSAGE_PROXY_EXECUTOR = keccak256("MESSAGE_PROXY_EXECUTOR");
    bytes32 public constant RECEIVING_ROUTER_MANAGER = keccak256("RECEIVING_ROUTER_MANAGER");
    bytes32 public constant RECEIVING_ROUTER_EXECUTOR = keccak256("RECEIVING_ROUTER_EXECUTOR");
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

// File: src/interfaces/utils/IWETH9.sol

pragma solidity ^0.8.7;



interface IWETH9 is IERC20 {
    function symbol() external view returns (string memory);

    function deposit() external payable;
    function withdraw(uint256 amount) external;
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

// File: src/interfaces/staking/IAccToke.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



interface IAccToke {
    ///////////////////////////////////////////////////////////////////
    //                        Variables
    ///////////////////////////////////////////////////////////////////

    function startEpoch() external view returns (uint256);
    function minStakeDuration() external view returns (uint256);

    struct Lockup {
        uint128 amount;
        uint128 end;
        uint256 points;
    }

    function getLockups(address user) external view returns (Lockup[] memory);
    function toke() external view returns (IERC20Metadata);

    ///////////////////////////////////////////////////////////////////
    //                        Errors
    ///////////////////////////////////////////////////////////////////

    error ZeroAddress();
    error StakingDurationTooShort();
    error StakingDurationTooLong();
    error StakingPointsExceeded();
    error IncorrectStakingAmount();
    error InsufficientFunds();
    error LockupDoesNotExist();
    error NotUnlockableYet();
    error AlreadyUnlocked();
    error ExtendDurationTooShort();
    error TransfersDisabled();
    error TransferFailed();
    error NoRewardsToClaim();
    error InsufficientAmount();
    error InvalidLockupIds();
    error InvalidDurationLength();
    error InvalidMinStakeDuration();

    ///////////////////////////////////////////////////////////////////
    //                        Events
    ///////////////////////////////////////////////////////////////////
    event SetMaxStakeDuration(uint256 oldDuration, uint256 newDuration);
    event Stake(address indexed user, uint256 lockupId, uint256 amount, uint256 end, uint256 points);
    event Unstake(address indexed user, uint256 lockupId, uint256 amount, uint256 end, uint256 points);
    event Extend(
        address indexed user,
        uint256 lockupId,
        uint256 amount,
        uint256 oldEnd,
        uint256 newEnd,
        uint256 oldPoints,
        uint256 newPoints
    );
    event RewardsAdded(uint256 amount, uint256 accRewardPerShare);
    event RewardsCollected(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);

    ///////////////////////////////////////////////////////////////////
    //
    //                        Staking Methods
    //
    ///////////////////////////////////////////////////////////////////

    /**
     * @notice Stake TOKE to an address that may not be the same as the sender of the funds. This can be used to give
     * staked funds to someone else.
     *
     * If staking before the start of staking (epoch), then the lockup start and end dates are shifted forward so that
     * the lockup starts at the epoch.
     *
     * @param amount TOKE to lockup in the stake
     * @param duration in seconds for the stake
     * @param to address to receive ownership of the stake
     */
    function stake(uint256 amount, uint256 duration, address to) external;

    /**
     * @notice Stake TOKE
     *
     * If staking before the start of staking (epoch), then the lockup start and end dates are shifted forward so that
     * the lockup starts at the epoch.
     *
     * @notice Stake TOKE for myself.
     * @param amount TOKE to lockup in the stake
     * @param duration in seconds for the stake
     */
    function stake(uint256 amount, uint256 duration) external;

    /**
     * @notice Collect staked TOKE for a lockup and any earned rewards.
     * @param lockupIds the id of the lockup to unstake
     */
    function unstake(uint256[] memory lockupIds) external;

    /**
     * @notice Extend a stake lockup for additional points.
     *
     * The stake end time is computed from the current time + duration, just like it is for new stakes. So a new stake
     * for seven days duration and an old stake extended with a seven days duration would have the same end.
     *
     * If an extend is made before the start of staking, the start time for the new stake is shifted forwards to the
     * start of staking, which also shifts forward the end date.
     *
     * @param lockupIds the id of the old lockup to extend
     * @param durations number of seconds from now to stake for
     */
    function extend(uint256[] memory lockupIds, uint256[] memory durations) external;

    ///////////////////////////////////////////////////////////////////
    //
    //                        Rewards
    //
    ///////////////////////////////////////////////////////////////////

    /// @notice The total amount of rewards earned for all stakes
    function totalRewardsEarned() external returns (uint256);

    /// @notice Total rewards claimed by all stakers
    function totalRewardsClaimed() external returns (uint256);

    /// @notice Rewards claimed by a specific wallet
    /// @param user Address of the wallet to check
    function rewardsClaimed(address user) external returns (uint256);

    /**
     * @notice Preview the number of points that would be returned for the
     * given amount and duration.
     *
     * @param amount TOKE to be staked
     * @param duration number of seconds to stake for
     * @return points staking points that would be returned
     * @return end staking period end date
     */
    function previewPoints(uint256 amount, uint256 duration) external view returns (uint256, uint256);

    /// @notice Preview the reward amount a caller can claim
    function previewRewards() external view returns (uint256);

    /// @notice Preview the reward amount a specified wallet can claim
    function previewRewards(address user) external view returns (uint256);

    /// @notice Claim rewards for the caller
    function collectRewards() external returns (uint256);

    /// @notice Check if amount can be staked
    function isStakeableAmount(uint256 amount) external pure returns (bool);
}

// File: src/interfaces/vault/IAutopoolRegistry.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/// @title Keep track of Vaults created through the Vault Factory
interface IAutopoolRegistry {
    ///////////////////////////////////////////////////////////////////
    //                        Errors
    ///////////////////////////////////////////////////////////////////

    error VaultNotFound(address vaultAddress);
    error VaultAlreadyExists(address vaultAddress);

    ///////////////////////////////////////////////////////////////////
    //                        Events
    ///////////////////////////////////////////////////////////////////
    event VaultAdded(address indexed asset, address indexed vault);
    event VaultRemoved(address indexed asset, address indexed vault);

    ///////////////////////////////////////////////////////////////////
    //                        Functions
    ///////////////////////////////////////////////////////////////////

    /// @notice Checks if an address is a valid vault
    /// @param vaultAddress Vault address to be added
    function isVault(address vaultAddress) external view returns (bool);

    /// @notice Registers a vault
    /// @param vaultAddress Vault address to be added
    function addVault(address vaultAddress) external;

    /// @notice Removes vault registration
    /// @param vaultAddress Vault address to be removed
    function removeVault(address vaultAddress) external;

    /// @notice Returns a list of all registered vaults
    function listVaults() external view returns (address[] memory);

    /// @notice Returns a list of all registered vaults for a given asset
    /// @param asset Asset address
    function listVaultsForAsset(address asset) external view returns (address[] memory);

    /// @notice Returns a list of all registered vaults for a given type
    /// @param _vaultType Vault type
    function listVaultsForType(bytes32 _vaultType) external view returns (address[] memory);
}

// File: lib/openzeppelin-contracts/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: lib/openzeppelin-contracts/contracts/access/IAccessControlEnumerable.sol

// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;



/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// File: src/interfaces/security/IAccessController.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



interface IAccessController is IAccessControlEnumerable {
    error AccessDenied();

    /**
     * @notice Setup a role for an account
     * @param role The role to setup
     * @param account The account to setup the role for
     */
    function setupRole(bytes32 role, address account) external;

    /**
     * @notice Verify if an account is an owner. Reverts if not
     * @param account The account to verify
     */
    function verifyOwner(address account) external view;
}

// File: src/interfaces/swapper/ISyncSwapper.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



interface ISyncSwapper {
    error DataMismatch(string element);
    error InvalidIndex();

    /**
     * @notice Returns address of swap router that can access SyncSwapper contract
     */
    function router() external view returns (ISwapRouter);

    /**
     * @notice Swaps sellToken for buyToken
     * @param pool The address of the pool for the swapper
     * @param sellTokenAddress The address of the token to sell
     * @param sellAmount The amount of sellToken to sell
     * @param buyTokenAddress The address of the token to buy
     * @param minBuyAmount The minimum amount of buyToken expected
     * @param data Additional data used differently by the different swappers
     * @return actualBuyAmount The actual amount received from the swap
     */
    function swap(
        address pool,
        address sellTokenAddress,
        uint256 sellAmount,
        address buyTokenAddress,
        uint256 minBuyAmount,
        bytes memory data
    ) external returns (uint256 actualBuyAmount);

    /**
     * @notice Validates that the swapData contains the correct information, ensuring that the encoded data contains the
     * correct 'fromAddress' and 'toAddress' (swapData.token), and verifies that these tokens are in the pool
     * @dev This function should revert with a DataMismatch error if the swapData is invalid
     * @param fromAddress The address from which the swap originates
     * @param swapData The data associated with the swap that needs to be validated
     */
    function validate(address fromAddress, ISwapRouter.SwapData memory swapData) external view;
}

// File: src/interfaces/swapper/ISwapRouter.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



interface ISwapRouter {
    struct SwapData {
        address token;
        address pool;
        ISyncSwapper swapper;
        bytes data;
    }

    error MaxSlippageExceeded();
    error SwapRouteLookupFailed(address from, address to);
    error SwapFailed();

    event SwapRouteSet(address indexed token, SwapData[] routes);
    event SwapForQuoteSuccessful(
        address indexed assetToken,
        uint256 sellAmount,
        address indexed quoteToken,
        uint256 minBuyAmount,
        uint256 buyAmount
    );

    /**
     * @notice Sets a new swap route for a given asset token.
     * @param assetToken The asset token for which the swap route is being set.
     * @param _swapRoute The new swap route as an array of SwapData. The last element represents the quoteToken.
     * @dev Each 'hop' in the swap route is validated using the respective swapper's validate function. The validate
     * function ensures that the encoded data contains the correct 'fromAddress' and 'toAddress' (swapData.token), and
     * verifies that these tokens are in the pool.
     */
    function setSwapRoute(address assetToken, SwapData[] calldata _swapRoute) external;

    /**
     * @notice Swaps the asset token for the quote token.
     * @dev We're adopting an "exact in, variable out" model for all our swaps. This ensures that the entire sellAmount
     * is used, eliminating the need for additional balance checks and refunds. This model is expected to be followed by
     * all swapper implementations to maintain consistency and to optimize for gas efficiency.
     * @param assetToken The address of the asset token to swap.
     * @param sellAmount The exact amount of the asset token to swap.
     * @param quoteToken The address of the quote token.
     * @param minBuyAmount The minimum amount of the quote token expected to be received from the swap.
     * @return The amount received from the swap.
     */
    function swapForQuote(
        address assetToken,
        uint256 sellAmount,
        address quoteToken,
        uint256 minBuyAmount
    ) external returns (uint256);
}

// File: src/interfaces/utils/ICurveResolver.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;

interface ICurveResolver {
    /// @notice Resolve details of a Curve pool regardless of type or version
    /// @dev This resolves tokens without unwrapping to underlying in the case of meta pools.
    /// @param poolAddress pool address to lookup
    /// @return tokens tokens that make up the pool
    /// @return numTokens the number of tokens. tokens are not unwrapped.
    /// @return isStableSwap is this a StableSwap pool. false = CryptoSwap
    function resolve(address poolAddress)
        external
        view
        returns (address[8] memory tokens, uint256 numTokens, bool isStableSwap);

    /// @notice Resolve details of a Curve pool regardless of type or version
    /// @dev This resolves tokens without unwrapping to underlying in the case of meta pools.
    /// @dev Use the isStableSwap value to differentiate between StableSwap (V1) and CryptoSwap (V2) pools.
    /// @param poolAddress pool address to lookup
    /// @return tokens tokens that make up the pool
    /// @return numTokens the number of tokens. tokens are not unwrapped
    /// @return lpToken lp token of the pool
    /// @return isStableSwap is this a StableSwap pool. false = CryptoSwap
    function resolveWithLpToken(address poolAddress)
        external
        view
        returns (address[8] memory tokens, uint256 numTokens, address lpToken, bool isStableSwap);

    /// @notice Get the lp token of a Curve pool
    /// @param poolAddress pool address to lookup
    function getLpToken(address poolAddress) external view returns (address);

    /// @notice Get the reserves of a Curve pools' tokens
    /// @dev Actual balances length might differ from 8 and should be verified by the caller
    /// @param poolAddress pool address to lookup
    /// @return balances reserves of the pool tokens
    function getReservesInfo(address poolAddress) external view returns (uint256[8] memory balances);
}

// File: lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: src/interfaces/ISystemComponent.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/// @notice Stores a reference to the registry for this system
interface ISystemComponent {
    /// @notice The system instance this contract is tied to
    function getSystemRegistry() external view returns (address registry);
}

// File: src/utils/Errors.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;




// solhint-disable max-line-length
library Errors {
    using Address for address;
    ///////////////////////////////////////////////////////////////////
    //                       Set errors
    ///////////////////////////////////////////////////////////////////

    error AccessDenied();
    error ZeroAddress(string paramName);
    error ZeroAmount();
    error InsufficientBalance(address token);
    error AssetNotAllowed(address token);
    error NotImplemented();
    error InvalidAddress(address addr);
    error InvalidParam(string paramName);
    error InvalidParams();
    error UnsafePrice(address token, uint256 spotPrice, uint256 safePrice);
    error AlreadySet(string param);
    error AlreadyRegistered(address param);
    error SlippageExceeded(uint256 expected, uint256 actual);
    error ArrayLengthMismatch(uint256 length1, uint256 length2, string details);

    error ItemNotFound();
    error ItemExists();
    error MissingRole(bytes32 role, address user);
    error RegistryItemMissing(string item);
    error NotRegistered();
    // Used to check storage slot is empty before setting.
    error MustBeZero();
    // Used to check storage slot set before deleting.
    error MustBeSet();

    error ApprovalFailed(address token);
    error FlashLoanFailed(address token, uint256 amount);

    error SystemMismatch(address source1, address source2);

    error InvalidToken(address token);
    error UnreachableError();

    error InvalidSigner(address signer);

    error InvalidChainId(uint256 chainId);

    error SenderMismatch(address recipient, address sender);

    error UnsupportedMessage(bytes32 messageType, bytes message);

    error NotSupported();

    error InvalidConfiguration();

    error InvalidDataReturned();

    function verifyNotZero(address addr, string memory paramName) internal pure {
        if (addr == address(0)) {
            revert ZeroAddress(paramName);
        }
    }

    function verifyNotZero(bytes32 key, string memory paramName) internal pure {
        if (key == bytes32(0)) {
            revert InvalidParam(paramName);
        }
    }

    function verifyNotEmpty(string memory val, string memory paramName) internal pure {
        if (bytes(val).length == 0) {
            revert InvalidParam(paramName);
        }
    }

    function verifyNotZero(uint256 num, string memory paramName) internal pure {
        if (num == 0) {
            revert InvalidParam(paramName);
        }
    }

    function verifySystemsMatch(address component1, address component2) internal view {
        address registry1 =
            abi.decode(component1.functionStaticCall(abi.encodeCall(ISystemComponent.getSystemRegistry, ())), (address));
        address registry2 =
            abi.decode(component2.functionStaticCall(abi.encodeCall(ISystemComponent.getSystemRegistry, ())), (address));

        if (registry1 != registry2) {
            revert SystemMismatch(component1, component2);
        }
    }

    function verifyArrayLengths(uint256 length1, uint256 length2, string memory details) internal pure {
        if (length1 != length2) {
            revert ArrayLengthMismatch(length1, length2, details);
        }
    }
}

// File: lib/openzeppelin-contracts/contracts/token/ERC20/extensions/draft-IERC20Permit.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: src/libs/LibAdapter.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;




library LibAdapter {
    using SafeERC20 for IERC20;

    address public constant CURVE_REGISTRY_ETH_ADDRESS_POINTER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    error MinLpAmountNotReached();
    error LpTokenAmountMismatch();
    error NoNonZeroAmountProvided();
    error InvalidBalanceChange();

    // Utils
    function _approve(IERC20 token, address spender, uint256 amount) internal {
        uint256 currentAllowance = token.allowance(address(this), spender);
        if (currentAllowance > 0) {
            token.safeDecreaseAllowance(spender, currentAllowance);
        }
        token.safeIncreaseAllowance(spender, amount);
    }
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

// File: lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
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

// File: src/strategy/StructuredLinkedList.sol

pragma solidity =0.8.17;

/**
 * @title StructuredLinkedList
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev An utility library for using sorted linked list data structures in your Solidity project.
 * @notice Adapted from
 * https://github.com/Layr-Labs/eigenlayer-contracts/blob/master/src/contracts/libraries/StructuredLinkedList.sol
 */
library StructuredLinkedList {
    uint256 private constant _NULL = 0;
    uint256 private constant _HEAD = 0;

    bool private constant _PREV = false;
    bool private constant _NEXT = true;

    struct List {
        uint256 size;
        mapping(uint256 => mapping(bool => uint256)) list;
    }

    /**
     * @dev Checks if the list exists
     * @param self stored linked list from contract
     * @return bool true if list exists, false otherwise
     */
    function listExists(List storage self) public view returns (bool) {
        // if the head nodes previous or next pointers both point to itself, then there are no items in the list
        if (self.list[_HEAD][_PREV] != _HEAD || self.list[_HEAD][_NEXT] != _HEAD) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Checks if the node exists
     * @param self stored linked list from contract
     * @param _node a node to search for
     * @return bool true if node exists, false otherwise
     */
    function nodeExists(List storage self, uint256 _node) public view returns (bool) {
        if (self.list[_node][_PREV] == _HEAD && self.list[_node][_NEXT] == _HEAD) {
            if (self.list[_HEAD][_NEXT] == _node) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Returns the number of elements in the list
     * @param self stored linked list from contract
     * @return uint256
     */
    // slither-disable-next-line dead-code
    function sizeOf(List storage self) public view returns (uint256) {
        return self.size;
    }

    /**
     * @dev Gets the head of the list
     * @param self stored linked list from contract
     * @return uint256 the head of the list
     */
    function getHead(List storage self) public view returns (uint256) {
        return self.list[_HEAD][_NEXT];
    }

    /**
     * @dev Gets the head of the list
     * @param self stored linked list from contract
     * @return uint256 the head of the list
     */
    function getTail(List storage self) public view returns (uint256) {
        return self.list[_HEAD][_PREV];
    }

    /**
     * @dev Returns the links of a node as a tuple
     * @param self stored linked list from contract
     * @param _node id of the node to get
     * @return bool, uint256, uint256 true if node exists or false otherwise, previous node, next node
     */
    // slither-disable-next-line dead-code
    function getNode(List storage self, uint256 _node) public view returns (bool, uint256, uint256) {
        if (!nodeExists(self, _node)) {
            return (false, 0, 0);
        } else {
            return (true, self.list[_node][_PREV], self.list[_node][_NEXT]);
        }
    }

    /**
     * @dev Returns the link of a node `_node` in direction `_direction`.
     * @param self stored linked list from contract
     * @param _node id of the node to step from
     * @param _direction direction to step in
     * @return bool, uint256 true if node exists or false otherwise, node in _direction
     */
    // slither-disable-next-line dead-code
    function getAdjacent(List storage self, uint256 _node, bool _direction) public view returns (bool, uint256) {
        if (!nodeExists(self, _node)) {
            return (false, 0);
        } else {
            uint256 adjacent = self.list[_node][_direction];
            return (adjacent != _HEAD, adjacent);
        }
    }

    /**
     * @dev Returns the link of a node `_node` in direction `_NEXT`.
     * @param self stored linked list from contract
     * @param _node id of the node to step from
     * @return bool, uint256 true if node exists or false otherwise, next node
     */
    // slither-disable-next-line dead-code
    function getNextNode(List storage self, uint256 _node) public view returns (bool, uint256) {
        return getAdjacent(self, _node, _NEXT);
    }

    /**
     * @dev Returns the link of a node `_node` in direction `_PREV`.
     * @param self stored linked list from contract
     * @param _node id of the node to step from
     * @return bool, uint256 true if node exists or false otherwise, previous node
     */
    // slither-disable-next-line dead-code
    function getPreviousNode(List storage self, uint256 _node) public view returns (bool, uint256) {
        return getAdjacent(self, _node, _PREV);
    }

    /**
     * @dev Insert node `_new` beside existing node `_node` in direction `_NEXT`.
     * @param self stored linked list from contract
     * @param _node existing node
     * @param _new  new node to insert
     * @return bool true if success, false otherwise
     */
    // slither-disable-next-line dead-code
    function insertAfter(List storage self, uint256 _node, uint256 _new) public returns (bool) {
        return _insert(self, _node, _new, _NEXT);
    }

    /**
     * @dev Insert node `_new` beside existing node `_node` in direction `_PREV`.
     * @param self stored linked list from contract
     * @param _node existing node
     * @param _new  new node to insert
     * @return bool true if success, false otherwise
     */
    // slither-disable-next-line dead-code
    function insertBefore(List storage self, uint256 _node, uint256 _new) public returns (bool) {
        return _insert(self, _node, _new, _PREV);
    }

    /**
     * @dev Removes an entry from the linked list
     * @param self stored linked list from contract
     * @param _node node to remove from the list
     * @return uint256 the removed node
     */
    function remove(List storage self, uint256 _node) public returns (uint256) {
        if ((_node == _NULL) || (!nodeExists(self, _node))) {
            return 0;
        }
        _createLink(self, self.list[_node][_PREV], self.list[_node][_NEXT], _NEXT);
        delete self.list[_node][_PREV];
        delete self.list[_node][_NEXT];

        self.size -= 1;

        return _node;
    }

    /**
     * @dev Pushes an entry to the head of the linked list
     * @param self stored linked list from contract
     * @param _node new entry to push to the head
     * @return bool true if success, false otherwise
     */
    function pushFront(List storage self, uint256 _node) public returns (bool) {
        return _push(self, _node, _NEXT);
    }

    /**
     * @dev Pushes an entry to the tail of the linked list
     * @param self stored linked list from contract
     * @param _node new entry to push to the tail
     * @return bool true if success, false otherwise
     */
    function pushBack(List storage self, uint256 _node) public returns (bool) {
        return _push(self, _node, _PREV);
    }

    /**
     * @dev Pops the first entry from the head of the linked list
     * @param self stored linked list from contract
     * @return uint256 the removed node
     */
    // slither-disable-next-line dead-code
    function popFront(List storage self) public returns (uint256) {
        return _pop(self, _NEXT);
    }

    /**
     * @dev Pops the first entry from the tail of the linked list
     * @param self stored linked list from contract
     * @return uint256 the removed node
     */
    // slither-disable-next-line dead-code
    function popBack(List storage self) public returns (uint256) {
        return _pop(self, _PREV);
    }

    /**
     * @dev Pushes an entry to the head of the linked list
     * @param self stored linked list from contract
     * @param _node new entry to push to the head
     * @param _direction push to the head (_NEXT) or tail (_PREV)
     * @return bool true if success, false otherwise
     */
    function _push(List storage self, uint256 _node, bool _direction) private returns (bool) {
        return _insert(self, _HEAD, _node, _direction);
    }

    /**
     * @dev Pops the first entry from the linked list
     * @param self stored linked list from contract
     * @param _direction pop from the head (_NEXT) or the tail (_PREV)
     * @return uint256 the removed node
     */
    // slither-disable-next-line dead-code
    function _pop(List storage self, bool _direction) private returns (uint256) {
        uint256 adj;
        (, adj) = getAdjacent(self, _HEAD, _direction);
        return remove(self, adj);
    }

    /**
     * @dev Insert node `_new` beside existing node `_node` in direction `_direction`.
     * @param self stored linked list from contract
     * @param _node existing node
     * @param _new  new node to insert
     * @param _direction direction to insert node in
     * @return bool true if success, false otherwise
     */
    function _insert(List storage self, uint256 _node, uint256 _new, bool _direction) private returns (bool) {
        if (!nodeExists(self, _new) && nodeExists(self, _node)) {
            uint256 c = self.list[_node][_direction];
            _createLink(self, _node, _new, _direction);
            _createLink(self, _new, c, _direction);

            self.size += 1;

            return true;
        }

        return false;
    }

    /**
     * @dev Creates a bidirectional link between two nodes on direction `_direction`
     * @param self stored linked list from contract
     * @param _node existing node
     * @param _link node to link to in the _direction
     * @param _direction direction to insert node in
     */
    function _createLink(List storage self, uint256 _node, uint256 _link, bool _direction) private {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }
}

// File: src/strategy/WithdrawalQueue.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17; // their version was using 8.12?



// https://github.com/Layr-Labs/eigenlayer-contracts/blob/master/src/contracts/libraries/StructuredLinkedList.sol
library WithdrawalQueue {
    using StructuredLinkedList for StructuredLinkedList.List;

    error CannotInsertZeroAddress();
    error UnexpectedNodeRemoved();
    error AddToHeadFailed();
    error AddToTailFailed();
    error NodeDoesNotExist();

    /// @notice Returns true if the address is in the queue.
    function addressExists(StructuredLinkedList.List storage queue, address addr) public view returns (bool) {
        return StructuredLinkedList.nodeExists(queue, _addressToUint(addr));
    }

    /// @notice Returns the current head.
    function peekHead(StructuredLinkedList.List storage queue) public view returns (address) {
        return _uintToAddress(StructuredLinkedList.getHead(queue));
    }

    /// @notice Returns the current tail.
    function peekTail(StructuredLinkedList.List storage queue) public view returns (address) {
        return _uintToAddress(StructuredLinkedList.getTail(queue));
    }

    /// @notice Returns the number of items in the queue
    function sizeOf(StructuredLinkedList.List storage queue) public view returns (uint256) {
        return StructuredLinkedList.sizeOf(queue);
    }

    /// @notice Return all items in the queue
    /// @dev Enumerates from head to tail
    function getList(StructuredLinkedList.List storage self) public view returns (address[] memory list) {
        uint256 size = self.sizeOf();
        list = new address[](size);

        if (size > 0) {
            uint256 lastNode = self.getHead();
            list[0] = _uintToAddress(lastNode);
            for (uint256 i = 1; i < size; ++i) {
                (bool exists, uint256 node) = self.getAdjacent(lastNode, true);

                if (!exists) {
                    revert NodeDoesNotExist();
                }

                list[i] = _uintToAddress(node);
                lastNode = node;
            }
        }
    }

    /// @notice Returns the current tail.
    function popHead(StructuredLinkedList.List storage queue) public returns (address) {
        return _uintToAddress(StructuredLinkedList.popFront(queue));
    }

    /// @notice remove address toRemove from queue if it exists.
    function popAddress(StructuredLinkedList.List storage queue, address toRemove) public {
        uint256 addrAsUint = _addressToUint(toRemove);
        uint256 _removedNode = StructuredLinkedList.remove(queue, addrAsUint);
        if (!((_removedNode == addrAsUint) || (_removedNode == 0))) {
            revert UnexpectedNodeRemoved();
        }
    }

    /// @notice returns true if there are no addresses in queue.
    function isEmpty(StructuredLinkedList.List storage queue) public view returns (bool) {
        return !StructuredLinkedList.listExists(queue);
    }

    /// @notice if addr in queue, move it to the top
    // if addr not in queue, add it to the top of the queue.
    // if queue is empty, make a new queue with addr as the only node
    function addToHead(StructuredLinkedList.List storage queue, address addr) public {
        if (addr == address(0)) {
            revert CannotInsertZeroAddress();
        }
        popAddress(queue, addr);
        bool success = StructuredLinkedList.pushFront(queue, _addressToUint(addr));
        if (!success) {
            revert AddToHeadFailed();
        }
    }

    function getAdjacent(
        StructuredLinkedList.List storage queue,
        address addr,
        bool direction
    ) public view returns (address) {
        (bool exists, uint256 addrNum) = queue.getAdjacent(_addressToUint(addr), direction);
        if (!exists) {
            return address(0);
        }
        return _uintToAddress(addrNum);
    }

    /// @notice if addr in queue, move it to the end
    // if addr not in queue, add it to the end of the queue.
    // if queue is empty, make a new queue with addr as the only node
    function addToTail(StructuredLinkedList.List storage queue, address addr) public {
        if (addr == address(0)) {
            revert CannotInsertZeroAddress();
        }

        popAddress(queue, addr);
        bool success = StructuredLinkedList.pushBack(queue, _addressToUint(addr));
        if (!success) {
            revert AddToTailFailed();
        }
    }

    function _addressToUint(address addr) private pure returns (uint256) {
        return uint256(uint160(addr));
    }

    function _uintToAddress(uint256 x) private pure returns (address) {
        return address(uint160(x));
    }
}

// File: lib/openzeppelin-contracts/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;



/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;



/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// File: src/vault/libs/AutopoolToken.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;




/// @notice ERC20 token functionality converted into a library. Based on OZ's v5
/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/ERC20.sol
library AutopoolToken {
    struct TokenData {
        /// @notice Token balances
        /// @dev account => balance
        mapping(address => uint256) balances;
        /// @notice Account spender allowances
        /// @dev account => spender => allowance
        mapping(address => mapping(address => uint256)) allowances;
        /// @notice Total supply of the pool. Be careful when using this directly from the struct. The pool itself
        /// modifies this number based on unlocked profited shares
        uint256 totalSupply;
        /// @notice ERC20 Permit nonces
        /// @dev account -> nonce. Exposed via `nonces(owner)`
        mapping(address => uint256) nonces;
    }

    /// @notice EIP2612 permit type hash
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /// @notice EIP712 domain type hash
    bytes32 public constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
    /// @param sender Address whose tokens are being transferred.
    /// @param balance Current balance for the interacting account.
    /// @param needed Minimum amount required to perform a transfer.
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /// @dev Indicates a failure with the token `sender`. Used in transfers.
    /// @param sender Address whose tokens are being transferred.
    error ERC20InvalidSender(address sender);

    /// @dev Indicates a failure with the token `receiver`. Used in transfers.
    /// @param receiver Address to which tokens are being transferred.
    error ERC20InvalidReceiver(address receiver);

    /// @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
    ///@param spender Address that may be allowed to operate on tokens without being their owner.
    /// @param allowance Amount of tokens a `spender` is allowed to operate with.
    ///@param needed Minimum amount required to perform a transfer.
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /// @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
    /// @param approver Address initiating an approval operation.
    error ERC20InvalidApprover(address approver);

    /// @dev Indicates a failure with the `spender` to be approved. Used in approvals.
    /// @param spender Address that may be allowed to operate on tokens without being their owner.
    error ERC20InvalidSpender(address spender);

    /// @dev Permit deadline has expired.
    error ERC2612ExpiredSignature(uint256 deadline);
    /// @dev Mismatched signature.
    error ERC2612InvalidSigner(address signer, address owner);
    /// @dev The nonce used for an `account` is not the expected current nonce.
    error InvalidAccountNonce(address account, uint256 currentNonce);

    /// @dev Emitted when `value` tokens are moved from one account `from` to another `to`.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}.
    /// `value` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @dev Sets a `value` amount of tokens as the allowance of `spender` over the caller's tokens.
    function approve(TokenData storage data, address spender, uint256 value) external returns (bool) {
        address owner = msg.sender;
        approve(data, owner, spender, value);
        return true;
    }

    /// @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
    function approve(TokenData storage data, address owner, address spender, uint256 value) public {
        _approve(data, owner, spender, value, true);
    }

    function transfer(TokenData storage data, address to, uint256 value) external returns (bool) {
        address owner = msg.sender;
        _transfer(data, owner, to, value);
        return true;
    }

    /// @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism.
    /// value` is then deducted from the caller's allowance.
    function transferFrom(TokenData storage data, address from, address to, uint256 value) external returns (bool) {
        address spender = msg.sender;
        _spendAllowance(data, from, spender, value);
        _transfer(data, from, to, value);
        return true;
    }

    /// @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
    function mint(TokenData storage data, address account, uint256 value) external {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(data, address(0), account, value);
    }

    /// @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
    function burn(TokenData storage data, address account, uint256 value) external {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(data, account, address(0), value);
    }

    function permit(
        TokenData storage data,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        uint256 nonce;
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here. Nonces starts at 0
            nonce = data.nonces[owner]++;
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));

        bytes32 hash = ECDSA.toTypedDataHash(IERC20Permit(address(this)).DOMAIN_SEPARATOR(), structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        approve(data, owner, spender, value);
    }

    /// @dev Moves a `value` amount of tokens from `from` to `to`.
    function _transfer(TokenData storage data, address from, address to, uint256 value) private {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(data, from, to, value);
    }

    /// @dev Updates `owner` s allowance for `spender` based on spent `value`.
    function _spendAllowance(TokenData storage data, address owner, address spender, uint256 value) private {
        uint256 currentAllowance = data.allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(data, owner, spender, currentAllowance - value, false);
            }
        }
    }

    /// @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
    /// (or `to`) is the zero address.
    function _update(TokenData storage data, address from, address to, uint256 value) private {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            data.totalSupply += value;
        } else {
            uint256 fromBalance = data.balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                data.balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                data.totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                data.balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /// @dev Variant of `_approve` with an optional flag to enable or disable the Approval event.
    function _approve(TokenData storage data, address owner, address spender, uint256 value, bool emitEvent) private {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        data.allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }
}

// File: src/interfaces/oracles/IRootPriceOracle.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;

/// @notice Retrieve a price for any token used in the system
interface IRootPriceOracle {
    /// @notice Returns a fair price for the provided token in ETH
    /// @param token token to get the price of
    /// @return price the price of the token in ETH
    function getPriceInEth(address token) external returns (uint256 price);

    /// @notice Returns a spot price for the provided token in ETH, utilizing specified liquidity pool
    /// @param token token to get the spot price of
    /// @param pool liquidity pool to be used for price determination
    /// @return price the spot price of the token in ETH based on the provided pool
    function getSpotPriceInEth(address token, address pool) external returns (uint256);

    /// @notice Returns a price for base token in quote token.
    /// @dev Requires both tokens to be registered.
    /// @param base Address of base token.
    /// @param quote Address of quote token.
    /// @return price Price of the base token in quote token.
    function getPriceInQuote(address base, address quote) external returns (uint256 price);

    /// @notice Retrieve the price of LP token based on the reserves
    /// @param lpToken LP token to get the price of
    /// @param pool liquidity pool to be used for price determination
    /// @param quoteToken token to quote the price in
    function getRangePricesLP(
        address lpToken,
        address pool,
        address quoteToken
    ) external returns (uint256 spotPriceInQuote, uint256 safePriceInQuote, bool isSpotSafe);

    /// @notice Returns floor or ceiling price of the supplied lp token in terms of requested quote.
    /// @dev  Floor price: the minimum price among all the spot prices and safe prices of the tokens in the pool.
    ///       Ceiling price: the maximum price among all the spot prices and safe prices of the tokens in the pool.
    /// @param pool Address of pool to get spot pricing from.
    /// @param lpToken Address of the lp token to price.
    /// @param inQuote Address of desired quote token.
    /// @param ceiling Bool indicating whether to get floor or ceiling price.
    /// @return floorOrCeilingPerLpToken Floor or ceiling price of the lp token.
    function getFloorCeilingPrice(
        address pool,
        address lpToken,
        address inQuote,
        bool ceiling
    ) external returns (uint256 floorOrCeilingPerLpToken);

    function getFloorPrice(address, address, address) external returns (uint256 price);

    function getCeilingPrice(address, address, address) external returns (uint256 price);
}

// File: src/vault/libs/AutopoolDebt.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;



















library AutopoolDebt {
    using Math for uint256;
    using SafeERC20 for IERC20;
    using WithdrawalQueue for StructuredLinkedList.List;
    using EnumerableSet for EnumerableSet.AddressSet;
    using AutopoolToken for AutopoolToken.TokenData;

    /// @notice Max time a cached debt report can be used
    uint256 public constant MAX_DEBT_REPORT_AGE_SECONDS = 1 days;

    error VaultShutdown();
    error WithdrawShareCalcInvalid(uint256 currentShares, uint256 cachedShares);
    error RebalanceDestinationsMatch(address destinationVault);
    error RebalanceFailed(string message);
    error InvalidPrices();
    error InvalidTotalAssetPurpose();
    error InvalidDestination(address destination);
    error TooFewAssets(uint256 requested, uint256 actual);
    error SharesAndAssetsReceived(uint256 assets, uint256 shares);
    error AmountExceedsAllowance(uint256 shares, uint256 allowed);
    error PositivePriceRecoupNotCovered(uint256 remaining);

    event DestinationDebtReporting(
        address destination, AutopoolDebt.IdleDebtUpdates debtInfo, uint256 claimed, uint256 claimGasUsed
    );
    event NewNavShareFeeMark(uint256 navPerShare, uint256 timestamp);
    event Nav(uint256 idle, uint256 debt, uint256 totalSupply);
    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    struct DestinationInfo {
        /// @notice Current underlying value at the destination vault
        /// @dev Used for calculating totalDebt, mid point of min and max
        uint256 cachedDebtValue;
        /// @notice Current minimum underlying value at the destination vault
        /// @dev Used for calculating totalDebt during withdrawal
        uint256 cachedMinDebtValue;
        /// @notice Current maximum underlying value at the destination vault
        /// @dev Used for calculating totalDebt of the deposit
        uint256 cachedMaxDebtValue;
        /// @notice Last block timestamp this info was updated
        uint256 lastReport;
        /// @notice How many shares of the destination vault we owned at last report
        uint256 ownedShares;
    }

    struct IdleDebtUpdates {
        bool pricesWereSafe;
        uint256 totalIdleDecrease;
        uint256 totalIdleIncrease;
        uint256 totalDebtIncrease;
        uint256 totalDebtDecrease;
        uint256 totalMinDebtIncrease;
        uint256 totalMinDebtDecrease;
        uint256 totalMaxDebtIncrease;
        uint256 totalMaxDebtDecrease;
    }

    struct RebalanceOutParams {
        /// Address that will received the withdrawn underlyer
        address receiver;
        /// The "out" destination vault
        address destinationOut;
        /// The amount of tokenOut that will be withdrawn
        uint256 amountOut;
        /// The underlyer for destinationOut
        address tokenOut;
        IERC20 _baseAsset;
        bool _shutdown;
    }

    /// @dev In memory struct only for managing vars in _withdraw
    struct WithdrawInfo {
        uint256 currentIdle;
        uint256 assetsFromIdle;
        uint256 totalAssetsToPull;
        uint256 assetsToPull;
        uint256 assetsPulled;
        uint256 idleIncrease;
        uint256 debtDecrease;
        uint256 debtMinDecrease;
        uint256 debtMaxDecrease;
        uint256 totalMinDebt;
        uint256 destinationRound;
        uint256 lastRoundSlippage;
        uint256 expectedAssets;
        uint256 remainingRecoup;
    }

    struct FlashRebalanceParams {
        uint256 totalIdle;
        uint256 totalDebt;
        IERC20 baseAsset;
        bool shutdown;
    }

    struct FlashResultInfo {
        uint256 tokenInBalanceBefore;
        uint256 tokenInBalanceAfter;
        bytes32 flashResult;
    }

    function flashRebalance(
        DestinationInfo storage destInfoOut,
        DestinationInfo storage destInfoIn,
        IERC3156FlashBorrower receiver,
        IStrategy.RebalanceParams memory params,
        IStrategy.SummaryStats memory destSummaryOut,
        IAutopoolStrategy autoPoolStrategy,
        FlashRebalanceParams memory flashParams,
        bytes calldata data
    ) external returns (IdleDebtUpdates memory result) {
        // Handle decrease (shares going "Out", cashing in shares and sending underlying back to swapper)
        // If the tokenOut is _asset we assume they are taking idle
        // which is already in the contract
        result = _handleRebalanceOut(
            AutopoolDebt.RebalanceOutParams({
                receiver: address(receiver),
                destinationOut: params.destinationOut,
                amountOut: params.amountOut,
                tokenOut: params.tokenOut,
                _baseAsset: flashParams.baseAsset,
                _shutdown: flashParams.shutdown
            }),
            destInfoOut
        );

        if (!result.pricesWereSafe) {
            revert InvalidPrices();
        }

        // Handle increase (shares coming "In", getting underlying from the swapper and trading for new shares)
        if (params.amountIn > 0) {
            FlashResultInfo memory flashResultInfo;
            // get "before" counts
            flashResultInfo.tokenInBalanceBefore = IERC20(params.tokenIn).balanceOf(address(this));

            // Give control back to the solver so they can make use of the "out" assets
            // and get our "in" asset
            flashResultInfo.flashResult = receiver.onFlashLoan(msg.sender, params.tokenIn, params.amountIn, 0, data);

            // We assume the solver will send us the assets
            flashResultInfo.tokenInBalanceAfter = IERC20(params.tokenIn).balanceOf(address(this));

            // Make sure the call was successful and verify we have at least the assets we think
            // we were getting
            if (
                flashResultInfo.flashResult != keccak256("ERC3156FlashBorrower.onFlashLoan")
                    || flashResultInfo.tokenInBalanceAfter < flashResultInfo.tokenInBalanceBefore + params.amountIn
            ) {
                revert Errors.FlashLoanFailed(params.tokenIn, params.amountIn);
            }

            {
                // make sure we have a valid path
                (bool success, string memory message) = autoPoolStrategy.verifyRebalance(params, destSummaryOut);
                if (!success) {
                    revert RebalanceFailed(message);
                }
            }

            if (params.tokenIn != address(flashParams.baseAsset)) {
                IdleDebtUpdates memory inDebtResult = _handleRebalanceIn(
                    destInfoIn,
                    IDestinationVault(params.destinationIn),
                    params.tokenIn,
                    flashResultInfo.tokenInBalanceAfter
                );
                if (!inDebtResult.pricesWereSafe) {
                    revert InvalidPrices();
                }
                result.totalDebtDecrease += inDebtResult.totalDebtDecrease;
                result.totalDebtIncrease += inDebtResult.totalDebtIncrease;
                result.totalMinDebtDecrease += inDebtResult.totalMinDebtDecrease;
                result.totalMinDebtIncrease += inDebtResult.totalMinDebtIncrease;
                result.totalMaxDebtDecrease += inDebtResult.totalMaxDebtDecrease;
                result.totalMaxDebtIncrease += inDebtResult.totalMaxDebtIncrease;
            } else {
                result.totalIdleIncrease += flashResultInfo.tokenInBalanceAfter - flashResultInfo.tokenInBalanceBefore;
            }
        }
    }

    /// @notice Perform deposit and debt info update for the "in" destination during a rebalance
    /// @dev This "in" function performs less validations than its "out" version
    /// @param dvIn The "in" destination vault
    /// @param tokenIn The underlyer for dvIn
    /// @param depositAmount The amount of tokenIn that will be deposited
    /// @return result Changes in debt values
    function _handleRebalanceIn(
        DestinationInfo storage destInfo,
        IDestinationVault dvIn,
        address tokenIn,
        uint256 depositAmount
    ) private returns (IdleDebtUpdates memory result) {
        LibAdapter._approve(IERC20(tokenIn), address(dvIn), depositAmount);

        // Snapshot our current shares so we know how much to back out
        uint256 originalShareBal = dvIn.balanceOf(address(this));

        // deposit to dv
        uint256 newShares = dvIn.depositUnderlying(depositAmount);

        // Update the debt info snapshot
        result = _recalculateDestInfo(destInfo, dvIn, originalShareBal, originalShareBal + newShares);
    }

    /**
     * @notice Perform withdraw and debt info update for the "out" destination during a rebalance
     * @dev This "out" function performs more validations and handles idle as opposed to "in" which does not
     *  debtDecrease The previous amount of debt destinationOut accounted for in totalDebt
     *  debtIncrease The current amount of debt destinationOut should account for in totalDebt
     *  idleDecrease Amount of baseAsset that was sent from the vault. > 0 only when tokenOut == baseAsset
     *  idleIncrease Amount of baseAsset that was claimed from Destination Vault
     * @param params Rebalance out params
     * @param destOutInfo The "out" destination vault info
     * @return assetChange debt and idle change data
     */
    function _handleRebalanceOut(
        RebalanceOutParams memory params,
        DestinationInfo storage destOutInfo
    ) private returns (IdleDebtUpdates memory assetChange) {
        // Handle decrease (shares going "Out", cashing in shares and sending underlying back to swapper)
        // If the tokenOut is _asset we assume they are taking idle
        // which is already in the contract
        if (params.amountOut > 0) {
            if (params.tokenOut != address(params._baseAsset)) {
                IDestinationVault dvOut = IDestinationVault(params.destinationOut);

                // Snapshot our current shares so we know how much to back out
                uint256 originalShareBal = dvOut.balanceOf(address(this));

                // Burning our shares will claim any pending baseAsset
                // rewards and send them to us.
                // Get our starting balance
                uint256 beforeBaseAssetBal = params._baseAsset.balanceOf(address(this));

                // Withdraw underlying from the destination vault
                // Shares are sent directly to the flashRebalance receiver
                // slither-disable-next-line unused-return
                dvOut.withdrawUnderlying(params.amountOut, params.receiver);

                // Update the debt info snapshot
                assetChange =
                    _recalculateDestInfo(destOutInfo, dvOut, originalShareBal, originalShareBal - params.amountOut);

                // Capture any rewards we may have claimed as part of withdrawing
                assetChange.totalIdleIncrease = params._baseAsset.balanceOf(address(this)) - beforeBaseAssetBal;
            } else {
                // If we are shutdown then the only operations we should be performing are those that get
                // the base asset back to the vault. We shouldn't be sending out more

                if (params._shutdown) {
                    revert VaultShutdown();
                }
                // Working with idle baseAsset which should be in the vault already
                // Just send it out
                IERC20(params.tokenOut).safeTransfer(params.receiver, params.amountOut);
                assetChange.totalIdleDecrease = params.amountOut;

                // We weren't dealing with any debt or pricing, just idle, so we can just mark
                // it as safe
                assetChange.pricesWereSafe = true;
            }
        }
    }

    function recalculateDestInfo(
        DestinationInfo storage destInfo,
        IDestinationVault destVault,
        uint256 originalShares,
        uint256 currentShares
    ) external returns (IdleDebtUpdates memory result) {
        result = _recalculateDestInfo(destInfo, destVault, originalShares, currentShares);
    }

    /// @dev Will not revert on unsafe prices. Up to the caller.
    function _recalculateDestInfo(
        DestinationInfo storage destInfo,
        IDestinationVault destVault,
        uint256 originalShares,
        uint256 currentShares
    ) private returns (IdleDebtUpdates memory result) {
        // Figure out what to back out of our totalDebt number.
        // We could have had withdraws since the last snapshot which means our
        // cached currentDebt number should be decreased based on the remaining shares
        // totalDebt is decreased using the same proportion of shares method during withdrawals
        // so this should represent whatever is remaining.

        // Prices are per LP token and whether or not the prices are safe to use
        // If they aren't safe then just continue and we'll get it on the next go around
        (uint256 spotPrice, uint256 safePrice, bool isSpotSafe) = destVault.getRangePricesLP();

        // Calculate what we're backing out based on the original shares
        uint256 minPrice = spotPrice > safePrice ? safePrice : spotPrice;
        uint256 maxPrice = spotPrice > safePrice ? spotPrice : safePrice;

        // If we previously had shares, calculate how much of our cached numbers
        // still remain as this will be deducted from the overall debt numbers
        // over time
        uint256 prevOwnedShares = destInfo.ownedShares;
        if (prevOwnedShares > 0) {
            result.totalDebtDecrease = (destInfo.cachedDebtValue * originalShares) / prevOwnedShares;
            result.totalMinDebtDecrease = (destInfo.cachedMinDebtValue * originalShares) / prevOwnedShares;
            result.totalMaxDebtDecrease = (destInfo.cachedMaxDebtValue * originalShares) / prevOwnedShares;
        }

        // The overall debt value is the mid point of min and max
        uint256 div = 10 ** destVault.decimals();
        uint256 newDebtValue = (minPrice * currentShares + maxPrice * currentShares) / (div * 2);

        result.pricesWereSafe = isSpotSafe;
        result.totalDebtIncrease = newDebtValue;
        result.totalMinDebtIncrease = minPrice * currentShares / div;
        result.totalMaxDebtIncrease = maxPrice * currentShares / div;

        // Save our current new values
        destInfo.cachedDebtValue = newDebtValue;
        destInfo.cachedMinDebtValue = result.totalMinDebtIncrease;
        destInfo.cachedMaxDebtValue = result.totalMaxDebtIncrease;
        destInfo.lastReport = block.timestamp;
        destInfo.ownedShares = currentShares;
    }

    function totalAssetsTimeChecked(
        StructuredLinkedList.List storage debtReportQueue,
        mapping(address => AutopoolDebt.DestinationInfo) storage destinationInfo,
        IAutopool.TotalAssetPurpose purpose
    ) external returns (uint256) {
        IDestinationVault destVault = IDestinationVault(debtReportQueue.peekHead());
        uint256 recalculatedTotalAssets = IAutopool(address(this)).totalAssets(purpose);

        while (address(destVault) != address(0)) {
            uint256 lastReport = destinationInfo[address(destVault)].lastReport;

            if (lastReport + MAX_DEBT_REPORT_AGE_SECONDS > block.timestamp) {
                // Its not stale

                // This report is OK, we don't need to recalculate anything
                break;
            } else {
                // It is stale, recalculate

                //slither-disable-next-line unused-return
                uint256 currentShares = destVault.balanceOf(address(this));
                uint256 staleDebt;
                uint256 extremePrice;

                // Figure out exactly which price to use based on its purpose
                if (purpose == IAutopool.TotalAssetPurpose.Deposit) {
                    // We use max value so that anything deposited is worth less
                    extremePrice = destVault.getUnderlyerCeilingPrice();

                    // Round down. We are subtracting this value out of the total so some left
                    // behind just increases the value which is what we want
                    staleDebt = destinationInfo[address(destVault)].cachedMaxDebtValue.mulDiv(
                        currentShares, destinationInfo[address(destVault)].ownedShares, Math.Rounding.Down
                    );
                } else if (purpose == IAutopool.TotalAssetPurpose.Withdraw) {
                    // We use min value so that we value the shares as worth less
                    extremePrice = destVault.getUnderlyerFloorPrice();
                    // Round up. We are subtracting this value out of the total so if we take a little
                    // extra it just decreases the value which is what we want
                    staleDebt = destinationInfo[address(destVault)].cachedMinDebtValue.mulDiv(
                        currentShares, destinationInfo[address(destVault)].ownedShares, Math.Rounding.Up
                    );
                } else {
                    revert InvalidTotalAssetPurpose();
                }

                // Back out our stale debt, add in its new value
                // Our goal is to find the most conservative value in each situation. If the current
                // value we have represents that, then use it. Otherwise, use the new one.
                uint256 newValue = (currentShares * extremePrice) / destVault.ONE();

                if (purpose == IAutopool.TotalAssetPurpose.Deposit && staleDebt > newValue) {
                    newValue = staleDebt;
                } else if (purpose == IAutopool.TotalAssetPurpose.Withdraw && staleDebt < newValue) {
                    newValue = staleDebt;
                }

                recalculatedTotalAssets = recalculatedTotalAssets + newValue - staleDebt;
            }

            destVault = IDestinationVault(debtReportQueue.getAdjacent(address(destVault), true));
        }

        return recalculatedTotalAssets;
    }

    function _updateDebtReporting(
        StructuredLinkedList.List storage debtReportQueue,
        mapping(address => AutopoolDebt.DestinationInfo) storage destinationInfo,
        uint256 numToProcess
    ) external returns (IdleDebtUpdates memory result) {
        numToProcess = Math.min(numToProcess, debtReportQueue.sizeOf());

        for (uint256 i = 0; i < numToProcess; ++i) {
            IDestinationVault destVault = IDestinationVault(debtReportQueue.popHead());

            // Get the reward value we've earned. DV rewards are always in terms of base asset
            // We track the gas used purely for off-chain stats purposes
            // Main rewarder on DV's store the earned and liquidated rewards
            // Extra rewarders are disabled at the DV level
            uint256 claimGasUsed = gasleft();
            uint256 beforeBaseAsset = IERC20(IAutopool(address(this)).asset()).balanceOf(address(this));
            IMainRewarder(destVault.rewarder()).getReward(address(this), address(this), false);
            uint256 claimedRewardValue =
                IERC20(IAutopool(address(this)).asset()).balanceOf(address(this)) - beforeBaseAsset;
            result.totalIdleIncrease += claimedRewardValue;

            // Recalculate the debt info figuring out the change in
            // total debt value we can roll up later
            uint256 currentShareBalance = destVault.balanceOf(address(this));

            AutopoolDebt.IdleDebtUpdates memory debtResult = _recalculateDestInfo(
                destinationInfo[address(destVault)], destVault, currentShareBalance, currentShareBalance
            );

            result.totalDebtDecrease += debtResult.totalDebtDecrease;
            result.totalDebtIncrease += debtResult.totalDebtIncrease;
            result.totalMinDebtDecrease += debtResult.totalMinDebtDecrease;
            result.totalMinDebtIncrease += debtResult.totalMinDebtIncrease;
            result.totalMaxDebtDecrease += debtResult.totalMaxDebtDecrease;
            result.totalMaxDebtIncrease += debtResult.totalMaxDebtIncrease;

            // If we no longer have shares, then there's no reason to continue reporting on the destination.
            // The strategy will only call for the info if its moving "out" of the destination
            // and that will only happen if we have shares.
            // A rebalance where we move "in" to the position will refresh the data at that time
            if (currentShareBalance > 0) {
                debtReportQueue.addToTail(address(destVault));
            }

            claimGasUsed -= gasleft();

            emit DestinationDebtReporting(address(destVault), debtResult, claimedRewardValue, claimGasUsed);
        }
    }

    function _initiateWithdrawInfo(
        uint256 assets,
        IAutopool.AssetBreakdown storage assetBreakdown
    ) private view returns (WithdrawInfo memory) {
        uint256 idle = assetBreakdown.totalIdle;
        WithdrawInfo memory info = WithdrawInfo({
            currentIdle: idle,
            // If idle can cover the full amount, then we want to pull all assets from there
            // Otherwise, we want to pull from the market and only get idle if we exhaust the market
            assetsFromIdle: assets > idle ? 0 : assets,
            totalAssetsToPull: 0,
            assetsToPull: 0,
            assetsPulled: 0,
            idleIncrease: 0,
            debtDecrease: 0,
            debtMinDecrease: 0,
            debtMaxDecrease: 0,
            totalMinDebt: assetBreakdown.totalDebtMin,
            destinationRound: 0,
            lastRoundSlippage: 0,
            expectedAssets: 0,
            remainingRecoup: 0
        });

        info.totalAssetsToPull = assets - info.assetsFromIdle;

        // This var we use to track our progress later
        info.assetsToPull = assets - info.assetsFromIdle;

        // Idle + minDebt is the maximum amount of assets/debt we could burn during a withdraw.
        // If the user is request more than that (like during a withdraw) we can just revert
        // early without trying
        if (info.totalAssetsToPull > info.currentIdle + info.totalMinDebt) {
            revert TooFewAssets(assets, info.currentIdle + info.totalMinDebt);
        }

        return info;
    }

    function withdraw(
        uint256 assets,
        uint256 applicableTotalAssets,
        IAutopool.AssetBreakdown storage assetBreakdown,
        StructuredLinkedList.List storage withdrawalQueue,
        mapping(address => AutopoolDebt.DestinationInfo) storage destinationInfo
    ) public returns (uint256 actualAssets, uint256 actualShares, uint256 debtBurned) {
        WithdrawInfo memory info = _initiateWithdrawInfo(assets, assetBreakdown);

        // Pull the market if there aren't enough funds in idle to cover the entire amount

        // This flow is not bounded by a set number of shares. The user has requested X assets
        // and a variable number of shares to burn so we don't have easy break out points like we do
        // during redeem (like using debt burned). When we get slippage here and don't meet the requested assets
        // we need to keep going if we can. This is tricky if we consider that (most of) our destinations are
        // LP positions and we'll be swapping assets, so we can expect some slippage. Even
        // if our minDebtValue numbers are up to date and perfectly accurate slippage could ensure we
        // are always receiving less than we expect/calculate and we never hit the requested assets
        // even though the owner would have shares to cover it. Under normal/expected conditions, our
        // minDebtValue is lower than actual and we expect overall value to be going up, so we burn a tad
        // more than we should and receive a tad more than we expect. This should cover us. However,
        // in other conditions we have to be sure we aren't endlessly trying to approach 0 so we are tracking
        // the slippage we received on the last pull, repricing, and applying an increasing multiplier until we either
        // pull enough to cover or pull them all and/or move to the next destination.

        uint256 dvSharesToBurn;
        while (info.assetsToPull > 0) {
            IDestinationVault destVault = IDestinationVault(withdrawalQueue.peekHead());

            // We've run out of destinations
            if (address(destVault) == address(0)) {
                break;
            }

            uint256 dvShares = destVault.balanceOf(address(this));
            {
                uint256 dvSharesValue;
                if (info.destinationRound == 0) {
                    // First time pulling

                    // We use the min debt value here because its a withdrawal and we're trying to cover an amount
                    // of assets. Undervaluing the shares may mean we pull more but given that we expect slippage
                    // that is desirable.
                    dvSharesValue = destinationInfo[address(destVault)].cachedMinDebtValue * dvShares
                        / destinationInfo[address(destVault)].ownedShares;
                } else {
                    // When we've pulled from this destination before, i.e. destinationRound > 0, then we
                    // know a more accurate exchange rate and its worse than we were expecting.
                    // We even will pad it a bit as we want to account for any additional slippage we
                    // may receive by say being farther down an AMM curve.

                    // dvSharesToBurn is the last value we used when pulling from this destination
                    // info.expectedAssets is how much we expected to get on that last pull
                    // info.expectedAssets - info.lastRoundSlippage is how much we actually received

                    uint256 paddedSlippage = info.lastRoundSlippage * (info.destinationRound + 10_000) / 10_000;

                    if (paddedSlippage < info.expectedAssets) {
                        dvSharesValue = (info.expectedAssets - paddedSlippage) * dvShares / dvSharesToBurn;
                    } else {
                        // This will just mean we pull all shares
                        dvSharesValue = 0;
                    }
                }

                if (dvSharesValue > info.assetsToPull) {
                    dvSharesToBurn = (dvShares * info.assetsToPull) / dvSharesValue;

                    // On withdraw, we are trying to meet a specific number of assets without a limit
                    // on the debt we can burn. Burning 0 due to the valuations here would be an automatic failure
                    // as we still have assets to satisfy and debt to burn. We at least have to burn 1 even if it
                    // results in a larger over pull
                    if (dvSharesToBurn == 0) {
                        dvSharesToBurn = 1;
                    }

                    // Only need to set it here because the only time we'll use it is if
                    // we don't exhaust all shares and have to try the destination again
                    info.expectedAssets = info.assetsToPull;
                } else {
                    dvSharesToBurn = dvShares;
                }
            }

            uint256 pulledAssets;
            uint256 debtValueBurned;
            // Get the base asset back from the Destination. Also performs a check that we aren't receiving
            // poor execution on our swaps based on safe prices
            (info, pulledAssets, debtValueBurned) = _withdrawAssets(info, destinationInfo, destVault, dvSharesToBurn);

            info.assetsPulled += pulledAssets;

            if (info.remainingRecoup > 0) {
                // If the destination is so severely undervalued that it can't cover its own recoup then we have no
                // recourse but to burn the entire destination and the user would to have to cover the full overage
                // from the next destinations can get nothing from this one. Should not be allowed.
                revert PositivePriceRecoupNotCovered(info.remainingRecoup);
            }

            // If we've exhausted all shares we can remove the withdrawal from the queue
            // We need to leave it in the debt report queue though so that our destination specific
            // debt tracking values can be updated
            if (dvShares == dvSharesToBurn) {
                withdrawalQueue.popAddress(address(destVault));
                info.destinationRound = 0;
                info.lastRoundSlippage = 0;
            } else {
                // If we didn't burn all the shares and we received enough to cover our
                // expected that means we'll break out below as we've hit our target
                unchecked {
                    if (pulledAssets < info.expectedAssets) {
                        info.lastRoundSlippage = info.expectedAssets - pulledAssets;
                        if (info.destinationRound == 0) {
                            info.destinationRound = 100;
                        } else {
                            info.destinationRound *= 2;
                        }
                    }
                }
            }

            // It's possible we'll get back more assets than we anticipate from a swap
            // so if we do, throw it in idle and stop processing. You don't get more than we've calculated
            if (info.assetsPulled >= info.totalAssetsToPull) {
                info.idleIncrease += info.assetsPulled - info.totalAssetsToPull;
                info.assetsPulled = info.totalAssetsToPull;
                info.assetsToPull = 0;
                break;
            }

            info.assetsToPull -= pulledAssets;
        }

        // We didn't get enough assets from the debt pull
        // See if we can get the rest from idle
        if (info.assetsPulled < assets && info.currentIdle > 0) {
            uint256 remaining = assets - info.assetsPulled;
            if (remaining <= info.currentIdle) {
                info.assetsFromIdle = remaining;
            }
            // We don't worry about the else case because if currentIdle can't
            // cover remaining then we'll fail the `actualAssets < assets`
            // check below and revert
        }

        debtBurned = info.assetsFromIdle + info.debtMinDecrease;
        actualAssets = info.assetsFromIdle + info.assetsPulled;

        if (actualAssets < assets) {
            revert TooFewAssets(assets, actualAssets);
        }

        actualShares = IAutopool(address(this)).convertToShares(
            Math.max(actualAssets, debtBurned),
            applicableTotalAssets,
            IAutopool(address(this)).totalSupply(),
            Math.Rounding.Up
        );

        // Subtract what's taken out of idle from totalIdle
        // We may also have some increase to account for it we over pulled
        // or received better execution than we were anticipating
        // slither-disable-next-line events-maths
        assetBreakdown.totalIdle = info.currentIdle + info.idleIncrease - info.assetsFromIdle;

        // Save off our various debt numbers
        if (info.debtDecrease > assetBreakdown.totalDebt) {
            assetBreakdown.totalDebt = 0;
        } else {
            assetBreakdown.totalDebt -= info.debtDecrease;
        }

        if (info.debtMinDecrease > info.totalMinDebt) {
            assetBreakdown.totalDebtMin = 0;
        } else {
            assetBreakdown.totalDebtMin -= info.debtMinDecrease;
        }

        if (info.debtMaxDecrease > assetBreakdown.totalDebtMax) {
            assetBreakdown.totalDebtMax = 0;
        } else {
            assetBreakdown.totalDebtMax -= info.debtMaxDecrease;
        }
    }

    function _withdrawAssets(
        WithdrawInfo memory info,
        mapping(address => AutopoolDebt.DestinationInfo) storage destinationInfo,
        IDestinationVault destVault,
        uint256 dvSharesToBurn
    ) internal returns (WithdrawInfo memory, uint256 pulledAssets, uint256 debtValueBurned) {
        if (dvSharesToBurn > 0) {
            address[] memory tokensBurned;
            uint256[] memory amountsBurned;

            // Destination Vaults always burn the exact amount we instruct them to
            (pulledAssets, tokensBurned, amountsBurned) = destVault.withdrawBaseAsset(dvSharesToBurn, address(this));

            // Calculate the totalDebt we'll need to remove based on the shares we're burning
            // We're rounding up here so take care when actually applying to totalDebt
            debtValueBurned = destinationInfo[address(destVault)].cachedMinDebtValue.mulDiv(
                dvSharesToBurn, destinationInfo[address(destVault)].ownedShares, Math.Rounding.Up
            );
            info.debtMinDecrease += debtValueBurned;

            info.debtDecrease += destinationInfo[address(destVault)].cachedDebtValue.mulDiv(
                dvSharesToBurn, destinationInfo[address(destVault)].ownedShares, Math.Rounding.Up
            );

            uint256 maxDebtBurned = destinationInfo[address(destVault)].cachedMaxDebtValue.mulDiv(
                dvSharesToBurn, destinationInfo[address(destVault)].ownedShares, Math.Rounding.Up
            );
            info.debtMaxDecrease += maxDebtBurned;

            // See if we received a reasonable amount of the base asset back based on the value
            // of the tokens that were burned.
            uint256 totalValueBurned;
            {
                uint256 tokenLen = tokensBurned.length;
                IRootPriceOracle rootPriceOracle = ISystemRegistry(destVault.getSystemRegistry()).rootPriceOracle();
                for (uint256 i = 0; i < tokenLen;) {
                    totalValueBurned += amountsBurned[i] * rootPriceOracle.getPriceInEth(tokensBurned[i])
                        / (10 ** IERC20(tokensBurned[i]).decimals());
                    unchecked {
                        ++i;
                    }
                }
            }

            // How much, if any, should be dropping into idle?
            // Anything pulled over debtValueBurned goes to idle, user can't get more than we think its worth.
            // However, if we pulled less than the current value of the tokens we burned, so long as
            // that value is greater than debt min, we need to recoup that as well and put it into idle

            uint256 amountToRecoup;
            if (totalValueBurned > debtValueBurned) {
                // The shares we burned are worth more than we'll be recouping from the debt burn
                // the difference we still need to get
                amountToRecoup = totalValueBurned - debtValueBurned;

                uint256 maxCreditBps = destVault.recoupMaxCredit();
                uint256 gapCredit = maxDebtBurned - debtValueBurned;
                uint256 credit = Math.min(gapCredit, debtValueBurned * maxCreditBps / 10_000);

                if (credit > amountToRecoup) {
                    amountToRecoup = 0;
                } else {
                    amountToRecoup -= credit;
                }
            }

            // This is done regardless of whether we were under valued. User can still only
            // get what we've valued it at.
            if (pulledAssets > debtValueBurned) {
                uint256 overDebtValue = pulledAssets - debtValueBurned;
                info.idleIncrease += overDebtValue;
                pulledAssets -= overDebtValue;

                // Since this is going to idle it goes to satisfy the recoup as well
                if (amountToRecoup > 0) {
                    if (amountToRecoup > overDebtValue) {
                        amountToRecoup -= overDebtValue;
                    } else {
                        amountToRecoup = 0;
                    }
                }
            }

            // If we still have a value we need to recoup it means that the debt range credit
            // as well as what was pulled over the min debt value wasn't enough to cover
            // the under valued burn. Now we have to try and take it from what is going back
            // to the user
            if (amountToRecoup > 0) {
                if (amountToRecoup > pulledAssets) {
                    // Recoup is more than we pulled so we'll have some recoup left over
                    amountToRecoup -= pulledAssets;

                    // Everything that was pulled goes to idle
                    info.idleIncrease += pulledAssets;
                    pulledAssets = 0;

                    // We'll have to try and get the remaining amount from another destination
                    info.remainingRecoup += amountToRecoup;
                } else {
                    // We pulled enough assets to cover the recoup
                    pulledAssets -= amountToRecoup;

                    // Ensure the recoup goes to idle
                    info.idleIncrease += amountToRecoup;
                }
            }
        }

        return (info, pulledAssets, debtValueBurned);
    }

    /// @notice Perform a removal of assets via the redeem path where the shares are the limiting factor.
    /// This means we break out whenever we reach either `assets` retrieved or debt value equivalent to `assets` burned
    function redeem(
        uint256 assets,
        uint256 applicableTotalAssets,
        IAutopool.AssetBreakdown storage assetBreakdown,
        StructuredLinkedList.List storage withdrawalQueue,
        mapping(address => AutopoolDebt.DestinationInfo) storage destinationInfo
    ) public returns (uint256 actualAssets, uint256 actualShares, uint256 debtBurned) {
        WithdrawInfo memory info = _initiateWithdrawInfo(assets, assetBreakdown);

        // If not enough funds in idle, then pull what we need from destinations
        bool exhaustedDestinations = false;
        while (info.assetsToPull > 0) {
            IDestinationVault destVault = IDestinationVault(withdrawalQueue.peekHead());
            if (address(destVault) == address(0)) {
                exhaustedDestinations = true;
                break;
            }

            uint256 dvShares = destVault.balanceOf(address(this));
            uint256 dvSharesToBurn = dvShares;
            {
                // Valuing these shares higher, rounding up, will result in us burning less of them
                // in the event we don't burn all of them. Good thing.
                uint256 dvSharesValue = destinationInfo[address(destVault)].cachedMinDebtValue.mulDiv(
                    dvSharesToBurn, destinationInfo[address(destVault)].ownedShares, Math.Rounding.Up
                );

                // If the dv shares we own are worth more than we need, limit the shares to burn
                // Any extra we get will be dropped into idle
                if (dvSharesValue > info.assetsToPull) {
                    uint256 limitedShares = (dvSharesToBurn * info.assetsToPull) / dvSharesValue;

                    // Final set for the actual shares we'll burn later
                    dvSharesToBurn = limitedShares;
                }
            }

            uint256 pulledAssets;
            uint256 debtValueBurned;
            // Get the base asset back from the Destination. Also performs a check that we aren't receiving
            // poor execution on our swaps based on safe prices
            // slither-disable-next-line unused-return
            (info, pulledAssets, debtValueBurned) = _withdrawAssets(info, destinationInfo, destVault, dvSharesToBurn);

            // If we've exhausted all shares we can remove the destination from the withdrawal queue
            // We need to leave it in the debt report queue though so that our destination specific
            // debt tracking values can be updated
            if (dvShares == dvSharesToBurn) {
                withdrawalQueue.popAddress(address(destVault));
            }

            info.assetsPulled += pulledAssets;

            // Any deficiency in the amount we received is slippage.
            // There is a round up on debtValueBurned so just making sure it never under flows here
            // _withdrawAssets ensures that pulledAssets is always lte debtValueBurned and we always
            // want to debit the max so we just use debtValueBurned
            if (debtValueBurned > info.assetsToPull) {
                info.assetsToPull = 0;
            } else {
                info.assetsToPull -= debtValueBurned;
            }

            // We either have enough assets, or we've burned the max debt we're allowed
            if (info.assetsToPull == 0) {
                break;
            }

            // If we didn't exhaust all of the shares from the destination it means we
            // assume we will get everything we need from there and everything else is slippage
            if (dvShares != dvSharesToBurn) {
                info.assetsToPull = 0;
                break;
            }
        }

        // See if we can pull the remaining recoup from other destinations we may have pulled from
        if (info.remainingRecoup > 0) {
            if (info.remainingRecoup > info.assetsPulled) {
                info.remainingRecoup -= info.assetsPulled;
                info.idleIncrease += info.assetsPulled;
                info.assetsPulled = 0;
            } else {
                info.assetsPulled -= info.remainingRecoup;
                info.idleIncrease += info.remainingRecoup;
                info.remainingRecoup = 0;
            }
        }

        // We didn't get enough assets from the debt pull
        // See if we can get the rest from idle
        if (info.assetsToPull > 0 && info.currentIdle > 0 && exhaustedDestinations) {
            if (info.assetsToPull < info.currentIdle) {
                info.assetsFromIdle = info.assetsToPull;
            } else {
                info.assetsFromIdle = info.currentIdle;
            }
        }

        debtBurned = info.assetsFromIdle + info.debtMinDecrease;
        actualAssets = info.assetsFromIdle + info.assetsPulled;

        // If we took from idle, and we have remaining assets to recoup
        // we need to put some back in idle
        if (info.remainingRecoup > 0 && info.assetsFromIdle > 0) {
            // We only need to do this if the idle assets can cover the remaining recoup fully because
            // we'll be reverting otherwise
            if (info.assetsFromIdle >= info.remainingRecoup) {
                // We still need to charge for the recoup so we're going to leave it in debtBurned
                // but we'll take it back out of actualAssets so it stays in idle. We need to lower
                // assetsFromIdle as well so that the final numbers get updated too
                actualAssets -= info.remainingRecoup;
                info.assetsFromIdle -= info.remainingRecoup;
                info.remainingRecoup = 0;
            } else {
                // Just updating this number so we get an accurate value in the revert below
                info.remainingRecoup -= info.assetsFromIdle;
            }
        }

        // We took everything we could and still can't cover, time to revert
        if (info.remainingRecoup > 0) {
            revert PositivePriceRecoupNotCovered(info.remainingRecoup);
        }

        actualShares = IAutopool(address(this)).convertToShares(
            debtBurned, applicableTotalAssets, IAutopool(address(this)).totalSupply(), Math.Rounding.Up
        );

        // Subtract what's taken out of idle from totalIdle
        // We may also have some increase to account for it we over pulled
        // or received better execution than we were anticipating
        // slither-disable-next-line events-maths
        assetBreakdown.totalIdle = info.currentIdle + info.idleIncrease - info.assetsFromIdle;

        // Save off our various debt numbers
        if (info.debtDecrease > assetBreakdown.totalDebt) {
            assetBreakdown.totalDebt = 0;
        } else {
            assetBreakdown.totalDebt -= info.debtDecrease;
        }

        if (info.debtMinDecrease > info.totalMinDebt) {
            assetBreakdown.totalDebtMin = 0;
        } else {
            assetBreakdown.totalDebtMin -= info.debtMinDecrease;
        }

        if (info.debtMaxDecrease > assetBreakdown.totalDebtMax) {
            assetBreakdown.totalDebtMax = 0;
        } else {
            assetBreakdown.totalDebtMax -= info.debtMaxDecrease;
        }
    }

    /**
     * @notice Function to complete a withdrawal or redeem.  This runs after shares to be burned and assets to be
     *    transferred are calculated.
     * @param assets Amount of assets to be transferred to receiver.
     * @param shares Amount of shares to be burned from owner.
     * @param owner Owner of shares, user to burn shares from.
     * @param receiver The receiver of the baseAsset.
     * @param baseAsset Base asset of the Autopool.
     * @param assetBreakdown Asset breakdown for the Autopool.
     * @param tokenData Token data for the Autopool.
     */
    function completeWithdrawal(
        uint256 assets,
        uint256 shares,
        address owner,
        address receiver,
        IERC20 baseAsset,
        IAutopool.AssetBreakdown storage assetBreakdown,
        AutopoolToken.TokenData storage tokenData
    ) external {
        if (msg.sender != owner) {
            uint256 allowed = IAutopool(address(this)).allowance(owner, msg.sender);
            if (allowed != type(uint256).max) {
                if (shares > allowed) revert AmountExceedsAllowance(shares, allowed);

                unchecked {
                    tokenData.approve(owner, msg.sender, allowed - shares);
                }
            }
        }

        tokenData.burn(owner, shares);

        uint256 ts = IAutopool(address(this)).totalSupply();

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        emit Nav(assetBreakdown.totalIdle, assetBreakdown.totalDebt, ts);

        baseAsset.safeTransfer(receiver, assets);
    }

    /**
     * @notice A helper function to get estimates of what would happen on a withdraw or redeem.
     * @dev Reverts all changing state.
     * @param previewWithdraw Bool denoting whether to preview a redeem or withdrawal.
     * @param assets Assets to be withdrawn or redeemed.
     * @param applicableTotalAssets Operation dependent assets in the Autopool.
     * @param functionCallEncoded Abi encoded function signature for recursive call.
     * @param assetBreakdown Breakdown of vault assets from Autopool storage.
     * @param withdrawalQueue Destination vault withdrawal queue from Autopool storage.
     * @param destinationInfo Mapping of information for destinations.
     * @return assetsAmount Preview of amount of assets to send to receiver.
     * @return sharesAmount Preview of amount of assets to burn from owner.
     */
    function preview(
        bool previewWithdraw,
        uint256 assets,
        uint256 applicableTotalAssets,
        bytes memory functionCallEncoded,
        IAutopool.AssetBreakdown storage assetBreakdown,
        StructuredLinkedList.List storage withdrawalQueue,
        mapping(address => AutopoolDebt.DestinationInfo) storage destinationInfo
    ) external returns (uint256 assetsAmount, uint256 sharesAmount) {
        if (msg.sender != address(this)) {
            // Perform a recursive call the function in `funcCallEncoded`.  This will result in a call back to
            // the Autopool, and then this function. The intention is to reach the "else" block in this function.
            // solhint-disable avoid-low-level-calls
            // slither-disable-next-line missing-zero-check,low-level-calls
            (bool success, bytes memory returnData) = address(this).call(functionCallEncoded);
            // solhint-enable avoid-low-level-calls

            // If the recursive call is successful, it means an unintended code path was taken.
            if (success) {
                revert Errors.UnreachableError();
            }

            bytes4 sharesAmountSig = bytes4(keccak256("SharesAndAssetsReceived(uint256,uint256)"));

            // Extract the error signature (first 4 bytes) from the revert reason.
            bytes4 errorSignature;
            // solhint-disable no-inline-assembly
            assembly {
                errorSignature := mload(add(returnData, 0x20))
            }

            // If the error matches the expected signature, extract the amount from the revert reason and return.
            if (errorSignature == sharesAmountSig) {
                // Extract subsequent bytes for uint256.
                assembly {
                    assetsAmount := mload(add(returnData, 0x24))
                    sharesAmount := mload(add(returnData, 0x44))
                }
            } else {
                // If the error is not the expected one, forward the original revert reason.
                assembly {
                    revert(add(32, returnData), mload(returnData))
                }
            }
            // solhint-enable no-inline-assembly
        }
        // This branch is taken during the recursive call.
        else {
            // Perform the actual withdrawal or redeem logic to compute the amount. This will be reverted to
            // simulate the action.
            uint256 previewAssets;
            uint256 previewShares;
            if (previewWithdraw) {
                (previewAssets, previewShares,) =
                    withdraw(assets, applicableTotalAssets, assetBreakdown, withdrawalQueue, destinationInfo);
            } else {
                (previewAssets, previewShares,) =
                    redeem(assets, applicableTotalAssets, assetBreakdown, withdrawalQueue, destinationInfo);
            }

            // Revert with the computed amount as an error.
            revert SharesAndAssetsReceived(previewAssets, previewShares);
        }
    }
}

// File: src/interfaces/vault/IERC4626.sol

pragma solidity 0.8.17;



/// @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in https://eips.ethereum.org/EIPS/eip-4626
/// @dev Due to the nature of obtaining estimates for previewing withdraws and redeems, a few functions are not
///     view and therefore do not conform to eip 4626.  These functions use state changing operations
///     to get accurate estimates, reverting after the preview amounts have been obtained.
interface IERC4626 is IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    /// @notice Returns the address of the underlying token used for the Vault for accounting, depositing, and
    /// withdrawing.
    /// @dev
    /// - MUST be an ERC-20 token contract.
    /// - MUST NOT revert.
    function asset() external view returns (address assetTokenAddress);

    /// @notice Returns the total amount of the underlying asset that is “managed” by Vault.
    /// @dev
    /// - SHOULD include any compounding that occurs from yield.
    /// - MUST be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT revert.
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /// @notice Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an
    /// ideal
    /// scenario where all the conditions are met.
    /// @dev
    /// - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT show any variations depending on the caller.
    /// - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
    /// - MUST NOT revert.
    ///
    /// NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
    /// “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
    /// from.
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /// @notice Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an
    /// ideal
    /// scenario where all the conditions are met.
    /// @dev
    /// - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT show any variations depending on the caller.
    /// - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
    /// - MUST NOT revert.
    ///
    /// NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
    /// “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
    /// from.
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /// @notice Returns the maximum amount of the underlying asset that can be deposited into the Vault for the
    /// receiver,
    /// through a deposit call.
    /// @dev
    /// - MUST return a limited value if receiver is subject to some deposit limit.
    /// - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
    /// - MUST NOT revert.
    function maxDeposit(address receiver) external returns (uint256 maxAssets);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block,
    /// given
    /// current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
    ///   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
    ///   in the same transaction.
    /// - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
    ///   deposit would be accepted, regardless if the user has enough tokens approved, etc.
    /// - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by depositing.
    function previewDeposit(uint256 assets) external returns (uint256 shares);

    /// @notice Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
    /// @dev
    /// - MUST emit the Deposit event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   deposit execution, and are accounted for during deposit.
    /// - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
    ///   approving enough underlying tokens to the Vault contract, etc).
    ///
    /// NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /// @notice Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
    /// @dev
    /// - MUST return a limited value if receiver is subject to some mint limit.
    /// - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
    /// - MUST NOT revert.
    function maxMint(address receiver) external returns (uint256 maxShares);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
    /// current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
    ///   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
    ///   same transaction.
    /// - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
    ///   would be accepted, regardless if the user has enough tokens approved, etc.
    /// - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by minting.
    function previewMint(uint256 shares) external returns (uint256 assets);

    /// @notice Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
    /// @dev
    /// - MUST emit the Deposit event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
    ///   execution, and are accounted for during mint.
    /// - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
    ///   approving enough underlying tokens to the Vault contract, etc).
    ///
    /// NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /// @notice Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
    /// Vault, through a withdraw call.
    /// @dev
    /// - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
    /// - MUST NOT revert.
    function maxWithdraw(address owner) external returns (uint256 maxAssets);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
    /// given current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
    ///   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
    ///   called
    ///   in the same transaction.
    /// - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
    ///   the withdrawal would be accepted, regardless if the user has enough shares, etc.
    /// - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by depositing.
    function previewWithdraw(uint256 assets) external returns (uint256 shares);

    /// @notice Burns shares from owner and sends exactly assets of underlying tokens to receiver.
    /// @dev
    /// - MUST emit the Withdraw event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   withdraw execution, and are accounted for during withdraw.
    /// - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
    ///   not having enough shares, etc).
    ///
    /// Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
    /// Those methods should be performed separately.
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /// @notice Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
    /// through a redeem call.
    /// @dev
    /// - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
    /// - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
    /// - MUST NOT revert.
    function maxRedeem(address owner) external returns (uint256 maxShares);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
    /// given current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
    ///   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
    ///   same transaction.
    /// - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
    ///   redemption would be accepted, regardless if the user has enough shares, etc.
    /// - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by redeeming.
    function previewRedeem(uint256 shares) external returns (uint256 assets);

    /// @notice Burns exactly shares from owner and sends assets of underlying tokens to receiver.
    /// @dev
    /// - MUST emit the Withdraw event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   redeem execution, and are accounted for during redeem.
    /// - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
    ///   not having enough shares, etc).
    ///
    /// NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
    /// Those methods should be performed separately.
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}

// File: src/interfaces/vault/IAutopool.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;








interface IAutopool is IERC4626, IERC20Permit {
    enum VaultShutdownStatus {
        Active,
        Deprecated,
        Exploit
    }

    /// @param unlockPeriodInSeconds Time it takes for profit to unlock in seconds
    /// @param fullProfitUnlockTime Time at which all profit will have been unlocked
    /// @param lastProfitUnlockTime Last time profits were unlocked
    /// @param profitUnlockRate Per second rate at which profit shares unlocks. Rate when calculated is denominated in
    /// MAX_BPS_PROFIT. TODO: Get into uint112
    struct ProfitUnlockSettings {
        uint48 unlockPeriodInSeconds;
        uint48 fullProfitUnlockTime;
        uint48 lastProfitUnlockTime;
        uint256 profitUnlockRate;
    }

    /// @param feeSink Where claimed fees are sent
    /// @param totalAssetsHighMark The last totalAssets amount we took fees at
    /// @param totalAssetsHighMarkTimestamp The last timestamp we updated the high water mark
    /// @param lastPeriodicFeeTake Timestamp of when the last periodic fee was taken.
    /// @param periodicFeeSink Address that receives periodic fee.
    /// @param periodicFeeBps Current periodic fee.  100% == 10000.
    /// @param streamingFeeBps Current streaming fee taken on profit. 100% == 10000
    /// @param navPerShareLastFeeMark The last nav/share height we took fees at
    /// @param navPerShareLastFeeMarkTimestamp The last timestamp we took fees at
    /// @param rebalanceFeeHighWaterMarkEnabled Returns whether the nav/share high water mark is enabled for the
    /// rebalance fee
    struct AutopoolFeeSettings {
        address feeSink;
        uint256 totalAssetsHighMark;
        uint256 totalAssetsHighMarkTimestamp;
        uint256 lastPeriodicFeeTake;
        address periodicFeeSink;
        uint256 periodicFeeBps;
        uint256 streamingFeeBps;
        uint256 navPerShareLastFeeMark;
        uint256 navPerShareLastFeeMarkTimestamp;
        bool rebalanceFeeHighWaterMarkEnabled;
    }

    /// @param totalIdle The amount of baseAsset deposited into the contract pending deployment
    /// @param totalDebt The current (though cached) value of assets we've deployed
    /// @param totalDebtMin The current (though cached) value of assets we use for valuing during deposits
    /// @param totalDebtMax The current (though cached) value of assets we use for valuing during withdrawals
    struct AssetBreakdown {
        uint256 totalIdle;
        uint256 totalDebt;
        uint256 totalDebtMin;
        uint256 totalDebtMax;
    }

    enum TotalAssetPurpose {
        Global,
        Deposit,
        Withdraw
    }

    /* ******************************** */
    /*      Events                      */
    /* ******************************** */
    event TokensPulled(address[] tokens, uint256[] amounts, address[] destinations);
    event TokensRecovered(address[] tokens, uint256[] amounts, address[] destinations);
    event Nav(uint256 idle, uint256 debt, uint256 totalSupply);
    event RewarderSet(address newRewarder, address oldRewarder);
    event DestinationDebtReporting(address destination, uint256 debtValue, uint256 claimed, uint256 claimGasUsed);
    event FeeCollected(uint256 fees, address feeSink, uint256 mintedShares, uint256 profit, uint256 idle, uint256 debt);
    event PeriodicFeeCollected(uint256 fees, address feeSink, uint256 mintedShares);
    event Shutdown(VaultShutdownStatus reason);

    /* ******************************** */
    /*      Errors                      */
    /* ******************************** */

    error ERC4626MintExceedsMax(uint256 shares, uint256 maxMint);
    error ERC4626DepositExceedsMax(uint256 assets, uint256 maxDeposit);
    error ERC4626ExceededMaxWithdraw(address owner, uint256 assets, uint256 max);
    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);
    error InvalidShutdownStatus(VaultShutdownStatus status);

    error WithdrawalFailed();
    error DepositFailed();
    error InsufficientFundsInDestinations(uint256 deficit);
    error WithdrawalIncomplete();
    error ValueSharesMismatch(uint256 value, uint256 shares);

    /// @notice A full unit of this pool
    // solhint-disable-next-line func-name-mixedcase
    function ONE() external view returns (uint256);

    /// @notice Query the type of vault
    function vaultType() external view returns (bytes32);

    /// @notice Strategy governing the pools rebalances
    function autoPoolStrategy() external view returns (IAutopoolStrategy);

    /// @notice Allow token recoverer to collect dust / unintended transfers (non-tracked assets only)
    function recover(address[] calldata tokens, uint256[] calldata amounts, address[] calldata destinations) external;

    /// @notice Set the order of destination vaults used for withdrawals
    // NOTE: will be done going directly to strategy (IStrategy) vault points to.
    //       How it'll delegate is still being decided
    // function setWithdrawalQueue(address[] calldata destinations) external;

    /// @notice Get a list of destination vaults with pending assets to clear out
    function getRemovalQueue() external view returns (address[] memory);

    function getFeeSettings() external view returns (AutopoolFeeSettings memory);

    /// @notice Initiate the shutdown procedures for this vault
    function shutdown(VaultShutdownStatus reason) external;

    /// @notice True if the vault has been shutdown
    function isShutdown() external view returns (bool);

    /// @notice Returns the reason for shutdown (or `Active` if not shutdown)
    function shutdownStatus() external view returns (VaultShutdownStatus);

    /// @notice gets the list of supported destination vaults for the Autopool/Strategy
    /// @return _destinations List of supported destination vaults
    function getDestinations() external view returns (address[] memory _destinations);

    function convertToShares(
        uint256 assets,
        uint256 totalAssetsForPurpose,
        uint256 supply,
        Math.Rounding rounding
    ) external view returns (uint256 shares);

    function convertToAssets(
        uint256 shares,
        uint256 totalAssetsForPurpose,
        uint256 supply,
        Math.Rounding rounding
    ) external view returns (uint256 assets);

    function totalAssets(TotalAssetPurpose purpose) external view returns (uint256);

    function getAssetBreakdown() external view returns (AssetBreakdown memory);

    /// @notice get a destinations last reported debt value
    /// @param destVault the address of the target destination
    /// @return destinations last reported debt value
    function getDestinationInfo(address destVault) external view returns (AutopoolDebt.DestinationInfo memory);

    /// @notice check if a destination is registered with the vault
    function isDestinationRegistered(address destination) external view returns (bool);

    /// @notice get if a destinationVault is queued for removal by the AutopoolETH
    function isDestinationQueuedForRemoval(address destination) external view returns (bool);

    /// @notice Returns instance of vault rewarder.
    function rewarder() external view returns (IMainRewarder);

    /// @notice Returns all past rewarders.
    function getPastRewarders() external view returns (address[] memory _pastRewarders);

    /// @notice Returns boolean telling whether address passed in is past rewarder.
    function isPastRewarder(address _pastRewarder) external view returns (bool);
}

// File: src/interfaces/vault/IAutopilotRouterBase.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity >=0.8.7;





/**
 * @title AutopoolETH Router Base Interface
 * @notice A canonical router between AutopoolETHs
 *
 * The base router is a multicall style router inspired by Uniswap v3 with built-in features for permit,
 * WETH9 wrap/unwrap, and ERC20 token pulling/sweeping/approving. It includes methods for the four mutable
 * ERC4626 functions deposit/mint/withdraw/redeem as well.
 *
 * These can all be arbitrarily composed using the multicall functionality of the router.
 *
 * NOTE the router is capable of pulling any approved token from your wallet. This is only possible when
 * your address is msg.sender, but regardless be careful when interacting with the router or ERC4626 Vaults.
 * The router makes no special considerations for unique ERC20 implementations such as fee on transfer.
 * There are no built in protections for unexpected behavior beyond enforcing the minSharesOut is received.
 */
interface IAutopilotRouterBase {
    /// @notice thrown when amount of assets received is below the min set by caller
    error MinAmountError();

    /// @notice thrown when amount of shares received is below the min set by caller
    error MinSharesError();

    /// @notice thrown when amount of assets received is above the max set by caller
    error MaxAmountError();

    /// @notice thrown when amount of shares received is above the max set by caller
    error MaxSharesError();

    /// @notice thrown when timestamp is too old
    error TimestampTooOld();

    /**
     * @notice mint `shares` from an ERC4626 vault.
     * @param vault The AutopoolETH to mint shares from.
     * @param to The destination of ownership shares.
     * @param shares The amount of shares to mint from `vault`.
     * @param maxAmountIn The max amount of assets used to mint.
     * @return amountIn the amount of assets used to mint by `to`.
     * @dev throws MaxAmountError
     */
    function mint(
        IAutopool vault,
        address to,
        uint256 shares,
        uint256 maxAmountIn
    ) external payable returns (uint256 amountIn);

    /**
     * @notice deposit `amount` to an ERC4626 vault.
     * @param vault The AutopoolETH to deposit assets to.
     * @param to The destination of ownership shares.
     * @param amount The amount of assets to deposit to `vault`.
     * @param minSharesOut The min amount of `vault` shares received by `to`.
     * @return sharesOut the amount of shares received by `to`.
     * @dev throws MinSharesError
     */
    function deposit(
        IAutopool vault,
        address to,
        uint256 amount,
        uint256 minSharesOut
    ) external payable returns (uint256 sharesOut);

    /**
     * @notice withdraw `amount` from an ERC4626 vault.
     * @param vault The AutopoolETH to withdraw assets from.
     * @param to The destination of assets.
     * @param amount The amount of assets to withdraw from vault.
     * @param maxSharesOut The max amount of shares burned for assets requested.
     * @return sharesOut the amount of shares received by `to`.
     * @dev throws MaxSharesError
     */
    function withdraw(
        IAutopool vault,
        address to,
        uint256 amount,
        uint256 maxSharesOut
    ) external payable returns (uint256 sharesOut);

    /**
     * @notice redeem `shares` shares from a AutopoolETH
     * @param vault The AutopoolETH to redeem shares from.
     * @param to The destination of assets.
     * @param shares The amount of shares to redeem from vault.
     * @param minAmountOut The min amount of assets received by `to`.
     * @return amountOut the amount of assets received by `to`.
     * @dev throws MinAmountError
     */
    function redeem(
        IAutopool vault,
        address to,
        uint256 shares,
        uint256 minAmountOut
    ) external payable returns (uint256 amountOut);

    /// @notice Stakes vault token to corresponding rewarder.
    /// @param vault IERC20 instance of an Autopool to stake to.
    /// @param maxAmount Maximum amount for user to stake.  Amount > balanceOf(user) will stake all present tokens.
    /// @return staked Returns total amount staked.
    function stakeVaultToken(IERC20 vault, uint256 maxAmount) external payable returns (uint256 staked);

    /// @notice Unstakes vault token from corresponding rewarder.
    /// @param vault IAutopool instance of the vault token to withdraw.
    /// @param rewarder Rewarder to withdraw from.
    /// @param maxAmount Amount of vault token to withdraw Amount > balanceOf(user) will withdraw all owned tokens.
    /// @param claim Claiming rewards or not on unstaking.
    /// @return withdrawn Amount of vault token withdrawn.
    function withdrawVaultToken(
        IAutopool vault,
        IMainRewarder rewarder,
        uint256 maxAmount,
        bool claim
    ) external payable returns (uint256 withdrawn);

    /// @notice Claims rewards on user stake of vault token.
    /// @param vault IAutopool instance of vault token to claim rewards for.
    /// @param rewarder Rewarder to claim rewards from.
    /// @param recipient Address to claim rewards for.
    function claimAutopoolRewards(IAutopool vault, IMainRewarder rewarder, address recipient) external payable;

    /// @notice Checks if timestamp is expired. Purpose is to check the execution deadline with the multicall.
    /// @param timestamp Timestamp to check.
    /// @dev throws TimestampTooOld. Payable to allow for multicall.
    function expiration(uint256 timestamp) external payable;
}

// File: src/interfaces/rewarders/IRewards.sol

// Copyright (c) 2024 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



/**
 *  @title Validates and distributes Vault token rewards based on the
 *  the signed and submitted payloads
 */
interface IRewards {
    struct Recipient {
        uint256 chainId;
        uint256 cycle;
        address wallet;
        uint256 amount;
    }

    event SignerSet(address newSigner);
    event Claimed(uint256 cycle, address recipient, uint256 amount);

    /// @notice Get the underlying token rewards are paid in
    /// @return Token address
    function vaultToken() external view returns (IERC20);

    /// @notice Get the current payload signer;
    /// @return Signer address
    function rewardsSigner() external view returns (address);

    /// @notice Check the amount an account has already claimed
    /// @param account Account to check
    /// @return Amount already claimed
    function claimedAmounts(address account) external view returns (uint256);

    /// @notice Get the amount that is claimable based on the provided payload
    /// @param recipient Published rewards payload
    /// @return Amount claimable if the payload is signed
    function getClaimableAmount(Recipient calldata recipient) external view returns (uint256);

    /// @notice Change the signer used to validate payloads
    /// @param newSigner The new address that will be signing rewards payloads
    function setSigner(address newSigner) external;

    /// @notice Claim your rewards
    /// @param recipient Published rewards payload
    /// @param v v component of the payload signature
    /// @param r r component of the payload signature
    /// @param s s component of the payload signature
    function claim(Recipient calldata recipient, uint8 v, bytes32 r, bytes32 s) external returns (uint256);

    /// @notice Claim rewards on behalf of another account , invoked primarily by the router
    /// @param recipient Published rewards payload
    /// @param v v component of the payload signature
    /// @param r r component of the payload signature
    /// @param s s component of the payload signature
    function claimFor(Recipient calldata recipient, uint8 v, bytes32 r, bytes32 s) external returns (uint256);

    /// @notice Generate the hash of the payload
    /// @param recipient Published rewards payload
    /// @return Hash of the payload
    function genHash(Recipient memory recipient) external view returns (bytes32);
}

// File: src/interfaces/liquidation/IAsyncSwapper.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

struct SwapParams {
    /// @dev The address of the token to be sold.
    address sellTokenAddress;
    /// @dev The amount of tokens to be sold.
    uint256 sellAmount;
    /// @dev The address of the token to be bought.
    address buyTokenAddress;
    /// @dev The expected minimum amount of tokens to be bought.
    uint256 buyAmount;
    /// @dev Data payload to be used for complex swap operations.
    bytes data;
    /// @dev Extra data payload reserved for future development. This field allows for additional information
    /// or functionality to be added without changing the struct and interface.
    bytes extraData;
    /// @dev Execution deadline in timestamp format
    uint256 deadline;
}

interface IAsyncSwapper {
    error TokenAddressZero();
    error SwapFailed();
    error InsufficientBuyAmountReceived(uint256 buyTokenAmountReceived, uint256 buyAmount);
    error InsufficientSellAmount();
    error InsufficientBuyAmount();
    error InsufficientBalance(uint256 balanceNeeded, uint256 balanceAvailable);

    event Swapped(
        address indexed sellTokenAddress,
        address indexed buyTokenAddress,
        uint256 sellAmount,
        uint256 buyAmount,
        uint256 buyTokenAmountReceived
    );

    /**
     * @notice Swaps sellToken for buyToken
     * @param swapParams Encoded swap data
     * @return buyTokenAmountReceived The amount of buyToken received from the swap
     */
    function swap(SwapParams memory swapParams) external returns (uint256 buyTokenAmountReceived);
}

// File: src/interfaces/vault/IAutopilotRouter.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;






/**
 * @title IAutopilotRouter Interface
 * @notice Extends the IAutopilotRouterBase with specific flows to save gas
 */
interface IAutopilotRouter is IAutopilotRouterBase {
    /**
     * ***************************   Deposit ********************************
     */

    /**
     * @notice deposit available asset balance to a AutopoolETH.
     * @param vault The AutopoolETH to deposit assets to.
     * @param to The destination of ownership shares.
     * @param minSharesOut The min amount of `vault` shares received by `to`.
     * @return sharesOut the amount of shares received by `to`.
     * @dev throws MinSharesError
     */
    function depositBalance(
        IAutopool vault,
        address to,
        uint256 minSharesOut
    ) external payable returns (uint256 sharesOut);

    /**
     * @notice deposit max assets to a AutopoolETH.
     * @param vault The AutopoolETH to deposit assets to.
     * @param to The destination of ownership shares.
     * @param minSharesOut The min amount of `vault` shares received by `to`.
     * @return sharesOut the amount of shares received by `to`.
     * @dev throws MinSharesError
     */
    function depositMax(
        IAutopool vault,
        address to,
        uint256 minSharesOut
    ) external payable returns (uint256 sharesOut);

    /**
     * *************************   Withdraw   **********************************
     */

    /**
     * @notice withdraw `amount` to a AutopoolETH.
     * @param fromVault The AutopoolETH to withdraw assets from.
     * @param toVault The AutopoolETH to deposit assets to.
     * @param to The destination of ownership shares.
     * @param amount The amount of assets to withdraw from fromVault.
     * @param maxSharesIn The max amount of fromVault shares withdrawn by caller.
     * @param minSharesOut The min amount of toVault shares received by `to`.
     * @return sharesOut the amount of shares received by `to`.
     * @dev throws MaxSharesError, MinSharesError
     */
    function withdrawToDeposit(
        IAutopool fromVault,
        IAutopool toVault,
        address to,
        uint256 amount,
        uint256 maxSharesIn,
        uint256 minSharesOut
    ) external payable returns (uint256 sharesOut);

    /**
     * *************************   Redeem    ********************************
     */

    /**
     * @notice redeem `shares` to a AutopoolETH.
     * @param fromVault The AutopoolETH to redeem shares from.
     * @param toVault The AutopoolETH to deposit assets to.
     * @param to The destination of ownership shares.
     * @param shares The amount of shares to redeem from fromVault.
     * @param minSharesOut The min amount of toVault shares received by `to`.
     * @return sharesOut the amount of shares received by `to`.
     * @dev throws MinAmountError, MinSharesError
     */
    function redeemToDeposit(
        IAutopool fromVault,
        IAutopool toVault,
        address to,
        uint256 shares,
        uint256 minSharesOut
    ) external payable returns (uint256 sharesOut);

    /**
     * @notice redeem max shares to a AutopoolETH.
     * @param vault The AutopoolETH to redeem shares from.
     * @param to The destination of assets.
     * @param minAmountOut The min amount of assets received by `to`.
     * @return amountOut the amount of assets received by `to`.
     * @dev throws MinAmountError
     */
    function redeemMax(
        IAutopool vault,
        address to,
        uint256 minAmountOut
    ) external payable returns (uint256 amountOut);

    /**
     * @notice swaps token
     * @param swapper Address of the swapper to use
     * @param swapParams  Parameters for the swap
     * @return amountReceived Swap output amount
     */
    function swapToken(
        address swapper,
        SwapParams memory swapParams
    ) external payable returns (uint256 amountReceived);

    /**
     * @notice claims vault token rewards
     * @param rewarder Address of the rewarder to claim from
     * @param recipient Struct containing recipient details
     * @return amountReceived Swap output amount
     */
    function claimRewards(
        IRewards rewarder,
        IRewards.Recipient calldata recipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable returns (uint256);

    /**
     * @notice swaps Exact token balance in the contract
     * @param swapper Address of the swapper to use
     * @param swapParams  Parameters for the swap
     * @return amountReceived Swap output amount
     * @dev sets the sellAmount to the balance of the contract
     */
    function swapTokenBalance(
        address swapper,
        SwapParams memory swapParams
    ) external payable returns (uint256 amountReceived);
}

// File: src/interfaces/vault/IAutopoolFactory.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

interface IAutopoolFactory {
    ///////////////////////////////////////////////////////////////////
    //                        Vault Creation
    ///////////////////////////////////////////////////////////////////

    /**
     * @notice Spin up a new AutopoolETH
     * @param strategy Strategy template address
     * @param symbolSuffix Symbol suffix of the new token
     * @param descPrefix Description prefix of the new token
     * @param salt Vault creation salt
     * @param extraParams Any extra data needed for the vault
     */
    function createVault(
        address strategy,
        string memory symbolSuffix,
        string memory descPrefix,
        bytes32 salt,
        bytes calldata extraParams
    ) external payable returns (address newVaultAddress);

    function addStrategyTemplate(address strategyTemplate) external;

    function removeStrategyTemplate(address strategyTemplate) external;

    /// @notice Returns the template used to create Autopools
    function template() external returns (address);
}

// File: src/interfaces/security/ISystemSecurity.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

interface ISystemSecurity {
    /// @notice Get the number of NAV/share operations currently in progress
    /// @return Number of operations
    function navOpsInProgress() external view returns (uint256);

    /// @notice Called at the start of any NAV/share changing operation
    function enterNavOperation() external;

    /// @notice Called at the end of any NAV/share changing operation
    function exitNavOperation() external;

    /// @notice Whether or not the system as a whole is paused
    function isSystemPaused() external returns (bool);
}

// File: src/interfaces/destinations/IDestinationAdapter.sol

pragma solidity 0.8.17;

/**
 * @title IDestinationAdapter
 * @dev This is a super-interface to unify different types of adapters to be registered in Destination Registry.
 *      Specific interface type is defined by extending from this interface.
 */
interface IDestinationAdapter {
    error MustBeMoreThanZero();
    error ArraysLengthMismatch();
    error BalanceMustIncrease();
    error MinLpAmountNotReached();
    error LpTokenAmountMismatch();
    error NoNonZeroAmountProvided();
    error InvalidBalanceChange();
    error InvalidAddress(address);
}

// File: src/interfaces/destinations/IDestinationRegistry.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



interface IDestinationRegistry {
    event Register(bytes32[] indexed destinationTypes, address[] indexed targets);
    event Replace(bytes32[] indexed destinationTypes, address[] indexed targets);
    event Unregister(bytes32[] indexed destinationTypes);

    event Whitelist(bytes32[] indexed destinationTypes);
    event RemoveFromWhitelist(bytes32[] indexed destinationTypes);

    error InvalidAddress(address addr);
    error NotAllowedDestination();
    error DestinationAlreadySet();

    /**
     * @notice Adds a new addresses of the given destination types
     * @dev Fails if trying to overwrite previous value of the same destination type
     * @param destinationTypes Ones from the destination type whitelist
     * @param targets addresses of the deployed DestinationAdapters, cannot be 0
     */
    function register(bytes32[] calldata destinationTypes, address[] calldata targets) external;

    /**
     * @notice Replaces an addresses of the given destination types
     * @dev Fails if given destination type was not set previously
     * @param destinationTypes Ones from the destination type whitelist
     * @param targets addresses of the deployed DestinationAdapters, cannot be 0
     */
    function replace(bytes32[] calldata destinationTypes, address[] calldata targets) external;

    /**
     * @notice Removes an addresses of the given pre-registered destination types
     * @param destinationTypes Ones from the destination types whitelist
     */
    function unregister(bytes32[] calldata destinationTypes) external;

    /**
     * @notice Gives an address of the given destination type
     * @dev Should revert on missing destination
     * @param destination One from the destination type whitelist
     */
    function getAdapter(bytes32 destination) external returns (IDestinationAdapter);

    /**
     * @notice Adds given destination types to the whitelist
     * @param destinationTypes Types to whitelist
     */
    function addToWhitelist(bytes32[] calldata destinationTypes) external;

    /**
     * @notice Removes given pre-whitelisted destination types
     * @param destinationTypes Ones from the destination type whitelist
     */
    function removeFromWhitelist(bytes32[] calldata destinationTypes) external;

    /**
     * @notice Checks if the given destination type is whitelisted
     * @param destinationType Type to verify
     */
    function isWhitelistedDestination(bytes32 destinationType) external view returns (bool);
}

// File: src/interfaces/vault/IDestinationVaultFactory.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



/// @notice Creates and registers Destination Vaults for the system
interface IDestinationVaultFactory is ISystemComponent {
    /// @notice Creates a vault of the specified type
    /// @dev vaultType will be bytes32 encoded and checked that a template is registered
    /// @param vaultType human readable key of the vault template
    /// @param baseAsset Base asset of the system. WETH/USDC/etc
    /// @param underlyer Underlying asset the vault will wrap
    /// @param incentiveCalculator Incentive calculator of the vault
    /// @param additionalTrackedTokens Any tokens in addition to base and underlyer that should be tracked
    /// @param salt Contracts are created via CREATE2 with this value
    /// @param params params to be passed to vaults initialize function
    /// @return vault address of the newly created destination vault
    function create(
        string memory vaultType,
        address baseAsset,
        address underlyer,
        address incentiveCalculator,
        address[] memory additionalTrackedTokens,
        bytes32 salt,
        bytes memory params
    ) external returns (address vault);

    /// @notice Sets the default reward ratio
    /// @param rewardRatio new default reward ratio
    function setDefaultRewardRatio(uint256 rewardRatio) external;

    /// @notice Sets the default reward block duration
    /// @param blockDuration new default reward block duration
    function setDefaultRewardBlockDuration(uint256 blockDuration) external;
}

// File: src/interfaces/vault/IDestinationVaultRegistry.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



/// @notice Tracks valid Destination Vaults for the system
interface IDestinationVaultRegistry {
    /// @notice Determines if a given address is a valid Destination Vault in the system
    /// @param destinationVault address to check
    /// @return True if vault is registered
    function isRegistered(address destinationVault) external view returns (bool);

    /// @notice Registers a new Destination Vault
    /// @dev Should be locked down to only a factory
    /// @param newDestinationVault Address of the new vault
    function register(address newDestinationVault) external;

    /// @notice Checks if an address is a valid Destination Vault and reverts if not
    /// @param destinationVault Destination Vault address to checked
    function verifyIsRegistered(address destinationVault) external view;

    /// @notice Returns a list of all registered vaults
    function listVaults() external view returns (address[] memory);

    /// @notice Factory that is allowed to create and registry Destination Vaults
    function factory() external view returns (IDestinationVaultFactory);
}

// File: src/interfaces/stats/IStatsCalculator.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/// @title Capture information about a pool or destination
interface IStatsCalculator {
    /// @notice thrown when no snapshot is taken
    error NoSnapshotTaken();

    /// @notice The id for this instance of a calculator
    function getAprId() external view returns (bytes32);

    /// @notice The id of the underlying asset/pool/destination this calculator represents
    /// @dev This may be a generated address
    function getAddressId() external view returns (address);

    /// @notice Setup the calculator after it has been copied
    /// @dev Should only be executed one time
    /// @param dependentAprIds apr ids that cover the dependencies of this calculator
    /// @param initData setup data specific to this type of calculator
    function initialize(bytes32[] calldata dependentAprIds, bytes calldata initData) external;

    /// @notice Capture stat data about this setup
    function snapshot() external;

    /// @notice Indicates if a snapshot should be taken
    /// @return takeSnapshot if true then a snapshot should be taken. If false, calling snapshot will do nothing
    function shouldSnapshot() external view returns (bool takeSnapshot);

    /// @dev Enum representing the snapshot status for a given rewarder (Convex and Aura) or reward token (Maverick)
    enum SnapshotStatus {
        noSnapshot, // Indicates that no snapshot has been taken yet for the rewarder.
        tooSoon, // Indicates that it's too soon to take another snapshot since the last one.
        shouldFinalize, // Indicates that the conditions are met for finalizing a snapshot.
        shouldRestart // Indicates that the conditions are met for restarting a snapshot.

    }
}

// File: src/interfaces/stats/IStatsCalculatorRegistry.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



/// @notice Track stat calculators for this instance of the system
interface IStatsCalculatorRegistry {
    /// @notice Get a registered calculator
    /// @dev Should revert if missing
    /// @param aprId key of the calculator to get
    /// @return calculator instance of the calculator
    function getCalculator(bytes32 aprId) external view returns (IStatsCalculator calculator);

    /// @notice List all calculator addresses registered
    function listCalculators() external view returns (bytes32[] memory, address[] memory);

    /// @notice Register a new stats calculator
    /// @param calculator address of the calculator
    function register(address calculator) external;

    /// @notice Remove a stats calculator
    /// @param aprId key of the calculator to remove
    function removeCalculator(bytes32 aprId) external;

    /// @notice Set the factory that can register calculators
    /// @param factory address of the factory
    function setCalculatorFactory(address factory) external;
}

// File: src/interfaces/liquidation/IAsyncSwapperRegistry.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

interface IAsyncSwapperRegistry {
    event SwapperAdded(address indexed item);
    event SwapperRemoved(address indexed item);

    /// @notice Registers an item
    /// @param item Item address to be added
    function register(address item) external;

    /// @notice Removes item registration
    /// @param item Item address to be removed
    function unregister(address item) external;

    /// @notice Returns a list of all registered items
    function list() external view returns (address[] memory);

    /// @notice Checks if an address is a valid item
    /// @param item Item address to be checked
    function isRegistered(address item) external view returns (bool);

    /// @notice Checks if an address is a valid swapper and reverts if not
    /// @param item Swapper address to be checked
    function verifyIsRegistered(address item) external view;
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

// File: src/interfaces/messageProxy/IMessageProxy.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/// @title Send messages to our systems on other chains
interface IMessageProxy {
    function sendMessage(bytes32 messageType, bytes memory message) external;
}

// File: src/interfaces/ISystemRegistry.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;




















/// @notice Root most registry contract for the system
interface ISystemRegistry {
    /// @notice Get the TOKE contract for the system
    /// @return toke instance of TOKE used in the system
    function toke() external view returns (IERC20Metadata);

    /// @notice Get the referenced WETH contract for the system
    /// @return weth contract pointer
    function weth() external view returns (IWETH9);

    /// @notice Get the AccToke staking contract
    /// @return accToke instance of the accToke contract for the system
    function accToke() external view returns (IAccToke);

    /// @notice Get the AutopoolRegistry for this system
    /// @return registry instance of the registry for this system
    function autoPoolRegistry() external view returns (IAutopoolRegistry registry);

    /// @notice Get the destination Vault registry for this system
    /// @return registry instance of the registry for this system
    function destinationVaultRegistry() external view returns (IDestinationVaultRegistry registry);

    /// @notice Get the access Controller for this system
    /// @return controller instance of the access controller for this system
    function accessController() external view returns (IAccessController controller);

    /// @notice Get the destination template registry for this system
    /// @return registry instance of the registry for this system
    function destinationTemplateRegistry() external view returns (IDestinationRegistry registry);

    /// @notice Auto Pilot Router
    /// @return router instance of the system
    function autoPoolRouter() external view returns (IAutopilotRouter router);

    /// @notice Vault factory lookup by type
    /// @return vaultFactory instance of the vault factory for this vault type
    function getAutopoolFactoryByType(bytes32 vaultType) external view returns (IAutopoolFactory vaultFactory);

    /// @notice Get the stats calculator registry for this system
    /// @return registry instance of the registry for this system
    function statsCalculatorRegistry() external view returns (IStatsCalculatorRegistry registry);

    /// @notice Get the root price oracle for this system
    /// @return oracle instance of the root price oracle for this system
    function rootPriceOracle() external view returns (IRootPriceOracle oracle);

    /// @notice Get the async swapper registry for this system
    /// @return registry instance of the registry for this system
    function asyncSwapperRegistry() external view returns (IAsyncSwapperRegistry registry);

    /// @notice Get the swap router for this system
    /// @return router instance of the swap router for this system
    function swapRouter() external view returns (ISwapRouter router);

    /// @notice Get the curve resolver for this system
    /// @return resolver instance of the curve resolver for this system
    function curveResolver() external view returns (ICurveResolver resolver);

    /// @notice Verify if given address is registered as Reward Token
    /// @param rewardToken token address to verify
    /// @return bool that indicates true if token is registered and false if not
    function isRewardToken(address rewardToken) external view returns (bool);

    /// @notice Get the system security instance for this system
    /// @return security instance of system security for this system
    function systemSecurity() external view returns (ISystemSecurity security);

    /// @notice Get the Incentive Pricing Stats
    /// @return incentivePricing the incentive pricing contract
    function incentivePricing() external view returns (IIncentivesPricingStats);

    /// @notice Get the Message Proxy
    /// @return Message proxy contract
    function messageProxy() external view returns (IMessageProxy);

    /// @notice Get the receiving router contract.
    /// @return Receiving router contract
    function receivingRouter() external view returns (address);

    /// @notice Check if an additional contract of type is valid in the system
    /// @return True if the contract is a valid for the given type
    function isValidContract(bytes32 contractType, address contractAddress) external view returns (bool);

    /// @notice Returns the additional contract of the given type
    /// @dev Revert if not set
    function getUniqueContract(bytes32 contractType) external view returns (address);

    /// @notice Returns all unique contracts configured
    function listUniqueContracts() external view returns (bytes32[] memory contractTypes, address[] memory addresses);

    /// @notice Returns all additional contract types configured
    function listAdditionalContractTypes() external view returns (bytes32[] memory);

    /// @notice Returns configured additional contracts by type
    /// @param contractType Type of contract to list
    function listAdditionalContracts(bytes32 contractType) external view returns (address[] memory);
}

// File: lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// File: src/security/SecurityBase.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;




contract SecurityBase {
    IAccessController public immutable accessController;

    error UndefinedAddress();

    constructor(address _accessController) {
        if (_accessController == address(0)) revert UndefinedAddress();

        accessController = IAccessController(_accessController);
    }

    modifier onlyOwner() {
        accessController.verifyOwner(msg.sender);
        _;
    }

    modifier hasRole(bytes32 role) {
        if (!accessController.hasRole(role, msg.sender)) revert Errors.AccessDenied();
        _;
    }

    ///////////////////////////////////////////////////////////////////
    //
    //  Forward all the regular methods to central security module
    //
    ///////////////////////////////////////////////////////////////////

    function _hasRole(bytes32 role, address account) internal view returns (bool) {
        return accessController.hasRole(role, account);
    }
}

// File: src/strategy/ViolationTracking.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

library ViolationTracking {
    uint16 internal constant TAIL_MASK = 1 << 9;
    uint16 internal constant HEAD_MASK = 1;

    struct State {
        uint8 violationCount;
        uint8 len;
        uint16 violations;
    }

    function insert(State storage self, bool isViolation) internal {
        bool tailValue = (self.violations & TAIL_MASK) > 0;

        // push new spot into the queue (default false)
        self.violations <<= 1;

        // flip the bit to true and increment counter if it is a violation
        if (isViolation) {
            self.violations |= HEAD_MASK;
            self.violationCount += 1;
        }

        // if we're dropping a violation then decrement the counter
        if (tailValue) {
            self.violationCount -= 1;
        }

        if (self.len < 10) {
            self.len += 1;
        }
    }

    function reset(State storage self) internal {
        self.violationCount = 0;
        self.violations = 0;
        self.len = 0;
    }
}

// File: src/strategy/NavTracking.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

library NavTracking {
    uint8 internal constant MAX_NAV_TRACKING = 91;

    error NavHistoryInsufficient();
    error InvalidNavTimestamp(uint40 current, uint40 provided);

    event NavHistoryInsert(uint256 navPerShare, uint40 timestamp);

    struct State {
        uint8 len;
        uint8 currentIndex;
        uint40 lastFinalizedTimestamp;
        uint256[MAX_NAV_TRACKING] history;
    }

    function insert(State storage self, uint256 navPerShare, uint40 timestamp) internal {
        if (timestamp < self.lastFinalizedTimestamp) revert InvalidNavTimestamp(self.lastFinalizedTimestamp, timestamp);

        // if it's been a day since the last finalized value, then finalize the current value
        // otherwise continue to overwrite the currentIndex
        if (timestamp - self.lastFinalizedTimestamp >= 1 days) {
            if (self.lastFinalizedTimestamp > 0) {
                self.currentIndex = (self.currentIndex + 1) % MAX_NAV_TRACKING;
            }
            self.lastFinalizedTimestamp = timestamp;
        }

        self.history[self.currentIndex] = navPerShare;
        if (self.len < MAX_NAV_TRACKING) {
            self.len += 1;
        }

        emit NavHistoryInsert(navPerShare, timestamp);
    }

    // the way this information is used, it is ok for it to not perfectly be daily
    // gaps of a few days are acceptable and do not materially degrade the NAV decay checks
    function getDaysAgo(State memory self, uint8 daysAgo) internal pure returns (uint256) {
        if (daysAgo >= self.len) revert NavHistoryInsufficient();

        uint8 targetIndex = (MAX_NAV_TRACKING + self.currentIndex - daysAgo) % MAX_NAV_TRACKING;
        return self.history[targetIndex];
    }
}

// File: src/strategy/AutopoolETHStrategyConfig.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



library AutopoolETHStrategyConfig {
    uint256 private constant WEIGHT_MAX = 1e6;
    int256 private constant WEIGHT_MAX_I = 1e6;

    error InvalidConfig(string paramName);

    // TODO: switch swapCostOffset from days to seconds; possibly pauseRebalance too
    struct StrategyConfig {
        SwapCostOffsetConfig swapCostOffset;
        NavLookbackConfig navLookback;
        SlippageConfig slippage;
        ModelWeights modelWeights;
        // number of days to pause rebalancing if a long-term nav decay is detected
        uint16 pauseRebalancePeriodInDays;
        // number of seconds before next rebalance can occur
        uint256 rebalanceTimeGapInSeconds;
        // destinations trading a premium above maxPremium will be blocked from new capital deployments
        int256 maxPremium; // 100% = 1e18
        // destinations trading a discount above maxDiscount will be blocked from new capital deployments
        int256 maxDiscount; // 100% = 1e18
        // if any stats data is older than this, rebalancing will revert
        uint40 staleDataToleranceInSeconds;
        // the maximum discount incorporated in price return
        int256 maxAllowedDiscount;
        // the maximum deviation between spot & safe price for individual LSTs
        uint256 lstPriceGapTolerance;
        // Array of hooks.  Up to five hooks on AutopoolEth strategy, can be address(0)
        address[5] hooks;
    }

    struct SwapCostOffsetConfig {
        // the swap cost offset period to initialize the strategy with
        uint16 initInDays;
        // the number of violations required to trigger a tightening of the swap cost offset period (1 to 10)
        uint16 tightenThresholdInViolations;
        // the number of days to decrease the swap offset period for each tightening step
        uint16 tightenStepInDays;
        // the number of days since a rebalance required to trigger a relaxing of the swap cost offset period
        uint16 relaxThresholdInDays;
        // the number of days to increase the swap offset period for each relaxing step
        uint16 relaxStepInDays;
        // the maximum the swap cost offset period can reach. This is the loosest the strategy will be
        uint16 maxInDays;
        // the minimum the swap cost offset period can reach. This is the most conservative the strategy will be
        uint16 minInDays;
    }

    struct NavLookbackConfig {
        // the number of days for the first NAV decay comparison (e.g., 30 days)
        uint8 lookback1InDays;
        // the number of days for the second NAV decay comparison (e.g., 60 days)
        uint8 lookback2InDays;
        // the number of days for the third NAV decay comparison (e.g., 90 days)
        uint8 lookback3InDays;
    }

    struct SlippageConfig {
        // the maximum slippage that is allowed for a normal rebalance
        // under normal circumstances this will not be triggered because the swap offset logic is the primary gate
        // but this ensures a sensible slippage level will never be exceeded
        uint256 maxNormalOperationSlippage; // 100% = 1e18
        // the maximum amount of slippage to allow when a destination is trimmed due to constraint violations
        // recommend setting this higher than maxNormalOperationSlippage
        uint256 maxTrimOperationSlippage; // 100% = 1e18
        // the maximum amount of slippage to allow when a destinationVault has been shutdown
        // shutdown for a vault is abnormal and means there is an issue at that destination
        // recommend setting this higher than maxNormalOperationSlippage
        uint256 maxEmergencyOperationSlippage; // 100% = 1e18
        // the maximum amount of slippage to allow when the Autopool has been shutdown
        uint256 maxShutdownOperationSlippage; // 100% = 1e18
    }

    struct ModelWeights {
        uint256 baseYield;
        uint256 feeYield;
        uint256 incentiveYield;
        int256 priceDiscountExit;
        int256 priceDiscountEnter;
        int256 pricePremium;
    }

    // slither-disable-start cyclomatic-complexity

    function validate(StrategyConfig memory config) internal pure {
        // Swap Cost Offset Config

        if (
            config.swapCostOffset.initInDays < config.swapCostOffset.minInDays
                || config.swapCostOffset.initInDays > config.swapCostOffset.maxInDays
                || config.swapCostOffset.initInDays < 7 || config.swapCostOffset.initInDays > 90
        ) {
            revert InvalidConfig("swapCostOffset_initInDays");
        }

        if (
            config.swapCostOffset.tightenThresholdInViolations < 1
                || config.swapCostOffset.tightenThresholdInViolations > 10
        ) {
            revert InvalidConfig("swapCostOffset_tightenThresholdInViolations");
        }

        if (config.swapCostOffset.tightenStepInDays < 1 || config.swapCostOffset.tightenStepInDays > 7) {
            revert InvalidConfig("swapCostOffset_tightenStepInDays");
        }

        if (config.swapCostOffset.relaxThresholdInDays < 14 || config.swapCostOffset.relaxThresholdInDays > 90) {
            revert InvalidConfig("swapCostOffset_relaxThresholdInDays");
        }

        if (config.swapCostOffset.relaxStepInDays < 1 || config.swapCostOffset.relaxStepInDays > 7) {
            revert InvalidConfig("swapCostOffset_relaxStepInDays");
        }

        if (
            config.swapCostOffset.maxInDays <= config.swapCostOffset.minInDays || config.swapCostOffset.maxInDays < 8
                || config.swapCostOffset.maxInDays > 90
        ) {
            revert InvalidConfig("swapCostOffset_maxInDays");
        }

        if (config.swapCostOffset.minInDays < 7 || config.swapCostOffset.minInDays > 90) {
            revert InvalidConfig("swapCostOffset_minInDays");
        }

        // NavLookback

        _validateNotZero(config.navLookback.lookback1InDays, "navLookback_lookback1InDays");

        // the 91st spot holds current (0 days ago), so the farthest back that can be retrieved is 90 days ago
        if (
            config.navLookback.lookback1InDays >= NavTracking.MAX_NAV_TRACKING
                || config.navLookback.lookback2InDays >= NavTracking.MAX_NAV_TRACKING
                || config.navLookback.lookback3InDays > NavTracking.MAX_NAV_TRACKING
        ) {
            revert InvalidConfig("navLookback_max");
        }

        // lookback should be configured smallest to largest and should not be equal
        if (
            config.navLookback.lookback1InDays >= config.navLookback.lookback2InDays
                || config.navLookback.lookback2InDays >= config.navLookback.lookback3InDays
        ) {
            revert InvalidConfig("navLookback_steps");
        }

        // Slippage

        _ensureNotGt25PctE18(config.slippage.maxShutdownOperationSlippage, "slippage_maxShutdownOperationSlippage");
        _ensureNotGt25PctE18(config.slippage.maxEmergencyOperationSlippage, "slippage_maxEmergencyOperationSlippage");
        _ensureNotGt25PctE18(config.slippage.maxTrimOperationSlippage, "slippage_maxTrimOperationSlippage");
        _ensureNotGt25PctE18(config.slippage.maxNormalOperationSlippage, "slippage_maxNormalOperationSlippage");

        // Model Weights

        if (config.modelWeights.baseYield > WEIGHT_MAX) {
            revert InvalidConfig("modelWeights_baseYield");
        }

        if (config.modelWeights.feeYield > WEIGHT_MAX) {
            revert InvalidConfig("modelWeights_feeYield");
        }

        if (config.modelWeights.incentiveYield > WEIGHT_MAX) {
            revert InvalidConfig("modelWeights_incentiveYield");
        }

        if (config.modelWeights.priceDiscountExit > WEIGHT_MAX_I) {
            revert InvalidConfig("modelWeights_priceDiscountExit");
        }

        if (config.modelWeights.priceDiscountEnter > WEIGHT_MAX_I) {
            revert InvalidConfig("modelWeights_priceDiscountEnter");
        }

        if (config.modelWeights.pricePremium > WEIGHT_MAX_I) {
            revert InvalidConfig("modelWeights_pricePremium");
        }

        // Top Level Config

        if (config.pauseRebalancePeriodInDays < 7 || config.pauseRebalancePeriodInDays > 90) {
            revert InvalidConfig("pauseRebalancePeriodInDays");
        }

        if (config.rebalanceTimeGapInSeconds < 1 hours || config.rebalanceTimeGapInSeconds > 30 days) {
            revert InvalidConfig("rebalanceTimeGapInSeconds");
        }

        _ensureNotGt25PctE18OrLtZero(config.maxPremium, "maxPremium");
        _ensureNotGt25PctE18OrLtZero(config.maxDiscount, "maxPremium");

        if (config.staleDataToleranceInSeconds < 1 hours || config.staleDataToleranceInSeconds > 7 days) {
            revert InvalidConfig("staleDataToleranceInSeconds");
        }

        if (config.maxAllowedDiscount < 0 || config.maxAllowedDiscount > 0.5e18) {
            revert InvalidConfig("maxAllowedDiscount");
        }

        if (config.lstPriceGapTolerance > 500) {
            revert InvalidConfig("lstPriceGapTolerance");
        }

        _validateHooks(config.hooks);
    }

    // slither-disable-end cyclomatic-complexity

    function _validateNotZero(uint256 val, string memory err) private pure {
        if (val == 0) {
            revert InvalidConfig(err);
        }
    }

    function _ensureNotGt25PctE18(uint256 value, string memory err) private pure {
        if (value > 0.25e18) {
            revert InvalidConfig(err);
        }
    }

    function _ensureNotGt25PctE18OrLtZero(int256 value, string memory err) private pure {
        if (value > 0.25e18 || value < 0) {
            revert InvalidConfig(err);
        }
    }

    // Checks to make sure that there are no zero address gaps in hooks array
    function _validateHooks(address[5] memory hooks) private pure {
        // slither-disable-next-line uninitialized-local
        bool zeroAddressReached;
        for (uint256 i = 0; i < 5; ++i) {
            address currentHook = hooks[i];

            // If we reach a zero address for the first time, flip flag to true
            if (currentHook == address(0) && !zeroAddressReached) {
                zeroAddressReached = true;
            }

            // If this gets triggered there is a set hook after a zero address hook.  Revert as this
            // is not an expected state
            if (zeroAddressReached && currentHook != address(0)) {
                revert InvalidConfig("hooks");
            }
        }
    }
}

// File: src/strategy/libs/StrategyUtils.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;

library StrategyUtils {
    error CannotConvertUintToInt();

    function convertUintToInt(uint256 value) internal pure returns (int256) {
        // slither-disable-next-line timestamp
        if (value > uint256(type(int256).max)) revert CannotConvertUintToInt();
        return int256(value);
    }
}

// File: src/strategy/libs/SubSaturateMath.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;

library SubSaturateMath {
    function subSaturate(uint256 self, uint256 other) internal pure returns (uint256) {
        if (other >= self) return 0;
        return self - other;
    }

    function subSaturate(int256 self, int256 other) internal pure returns (int256) {
        if (other >= self) return 0;
        return self - other;
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

// File: src/strategy/libs/PriceReturn.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;






library PriceReturn {
    function calculateWeightedPriceReturn(
        int256 priceReturn,
        uint256 reserveValue,
        IAutopoolStrategy.RebalanceDirection direction
    ) external view returns (int256) {
        IAutopoolStrategy strategy = IAutopoolStrategy(address(this));

        // slither-disable-next-line timestamp
        if (priceReturn > 0) {
            // LST trading at a discount
            if (direction == IAutopoolStrategy.RebalanceDirection.Out) {
                return priceReturn * StrategyUtils.convertUintToInt(reserveValue) * strategy.weightPriceDiscountExit()
                    / 1e6;
            } else {
                return priceReturn * StrategyUtils.convertUintToInt(reserveValue) * strategy.weightPriceDiscountEnter()
                    / 1e6;
            }
        } else {
            // LST trading at 0 or a premium
            return priceReturn * StrategyUtils.convertUintToInt(reserveValue) * strategy.weightPricePremium() / 1e6;
        }
    }

    function calculatePriceReturns(IDexLSTStats.DexLSTStatsData memory stats) external view returns (int256[] memory) {
        IAutopoolStrategy strategy = IAutopoolStrategy(address(this));

        ILSTStats.LSTStatsData[] memory lstStatsData = stats.lstStatsData;

        uint256 numLsts = lstStatsData.length;
        int256[] memory priceReturns = new int256[](numLsts);
        int256 maxDiscount = strategy.maxAllowedDiscount();

        for (uint256 i = 0; i < numLsts; ++i) {
            ILSTStats.LSTStatsData memory data = lstStatsData[i];

            uint256 scalingFactor = 1e18; // default scalingFactor is 1

            int256 discount = data.discount;
            if (discount > maxDiscount) {
                discount = maxDiscount;
            }

            // discount value that is negative indicates LST price premium
            // scalingFactor = 1e18 for premiums and discounts that are small
            // discountTimestampByPercent holds the timestamp for 1% discount
            uint40 discountTimestampByPercent = data.discountTimestampByPercent;

            // 1e16 means a 1% LST discount where full scale is 1e18.
            if ((discount > 1e16) && (discountTimestampByPercent > 0)) {
                // linear approximation for exponential function with approx. half life of 30 days
                uint256 halfLifeSec = 30 * 24 * 60 * 60;
                // current timestamp should be strictly >= timestamp in discountTimestampByPercent
                uint256 timeSinceDiscountSec = uint256(uint40(block.timestamp) - discountTimestampByPercent);
                scalingFactor >>= (timeSinceDiscountSec / halfLifeSec);
                // slither-disable-next-line weak-prng
                timeSinceDiscountSec %= halfLifeSec;
                scalingFactor -= scalingFactor * timeSinceDiscountSec / halfLifeSec / 2;
            }
            priceReturns[i] = discount * StrategyUtils.convertUintToInt(scalingFactor) / 1e18;
        }

        return priceReturns;
    }
}

// File: src/interfaces/strategy/ISummaryStatsHook.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;





/// @title An interface for hooks for IStrategy.SummaryStats manipulations
interface ISummaryStatsHook {
    /**
     * @notice Used to execute hook that will modify IStrategy.SummaryStats struct
     * @param stats IStrategy.SummaryStats struct for destination stats
     * @param autoPool Address of autopool that rebalance is happening for
     * @param destAddress Address of destination
     * @param price Price per share
     * @param direction Rebalance direction, in or out
     * @param amount Amount of asset that stats are evaluated at
     * @return IStrategy.SummaryStats struct
     */
    function execute(
        IStrategy.SummaryStats memory stats,
        IAutopool autoPool,
        address destAddress,
        uint256 price,
        IAutopoolStrategy.RebalanceDirection direction,
        uint256 amount
    ) external returns (IStrategy.SummaryStats memory);
}

// File: src/strategy/libs/SummaryStats.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;



















library SummaryStats {
    using SubSaturateMath for uint256;

    error StaleData(string name);
    error LstStatsReservesMismatch();

    event InLSTPriceGap(address token, uint256 priceSafe, uint256 priceSpot);
    event OutLSTPriceGap(address token, uint256 priceSafe, uint256 priceSpot);

    struct InterimStats {
        uint256 baseApr;
        int256 priceReturn;
        int256 maxDiscount;
        int256 maxPremium;
        uint256 reservesTotal;
        int256[] priceReturns;
        uint256 numLstStats;
    }

    struct RebalanceValueStats {
        uint256 inPrice;
        uint256 outPrice;
        uint256 inEthValue;
        uint256 outEthValue;
        uint256 swapCost;
        uint256 slippage;
    }

    function getDestinationSummaryStats(
        IAutopool autoPool,
        IIncentivesPricingStats incentivePricing,
        address destAddress,
        uint256 price,
        IAutopoolStrategy.RebalanceDirection direction,
        uint256 amount
    ) external returns (IStrategy.SummaryStats memory) {
        // NOTE: creating this as empty to save on variables later
        // has the distinct downside that if you forget to update a value, you get the zero value
        // slither-disable-next-line uninitialized-local
        IStrategy.SummaryStats memory result;

        if (destAddress == address(autoPool)) {
            result.destination = destAddress;
            result.ownedShares = autoPool.getAssetBreakdown().totalIdle;
            result.pricePerShare = price;
            return result;
        }

        IDestinationVault dest = IDestinationVault(destAddress);
        IDexLSTStats.DexLSTStatsData memory stats = dest.getStats().current();

        ensureNotStaleData("DexStats", stats.lastSnapshotTimestamp);

        // temporary holder to reduce variables
        InterimStats memory interimStats;

        interimStats.numLstStats = stats.lstStatsData.length;
        if (interimStats.numLstStats != stats.reservesInEth.length) revert LstStatsReservesMismatch();

        interimStats.priceReturns = PriceReturn.calculatePriceReturns(stats);

        for (uint256 i = 0; i < interimStats.numLstStats; ++i) {
            uint256 reserveValue = stats.reservesInEth[i];
            interimStats.reservesTotal += reserveValue;

            if (interimStats.priceReturns[i] != 0) {
                interimStats.priceReturn +=
                    PriceReturn.calculateWeightedPriceReturn(interimStats.priceReturns[i], reserveValue, direction);
            }

            // For tokens like WETH/ETH who have no data, tokens we've configured as NO_OP's in the
            // destinations/calculators, we can just skip the rest of these calcs as they have no stats
            if (stats.lstStatsData[i].baseApr == 0 && stats.lstStatsData[i].lastSnapshotTimestamp == 0) {
                continue;
            }

            ensureNotStaleData("lstData", stats.lstStatsData[i].lastSnapshotTimestamp);

            interimStats.baseApr += stats.lstStatsData[i].baseApr * reserveValue;

            int256 discount = stats.lstStatsData[i].discount;
            // slither-disable-next-line timestamp
            if (discount < interimStats.maxPremium) {
                interimStats.maxPremium = discount;
            }
            // slither-disable-next-line timestamp
            if (discount > interimStats.maxDiscount) {
                interimStats.maxDiscount = discount;
            }
        }

        // if reserves are 0, then leave baseApr + priceReturn as 0
        if (interimStats.reservesTotal > 0) {
            result.baseApr = interimStats.baseApr / interimStats.reservesTotal;
            result.priceReturn = interimStats.priceReturn / StrategyUtils.convertUintToInt(interimStats.reservesTotal);
        }

        result.destination = destAddress;
        result.feeApr = stats.feeApr;
        result.incentiveApr = Incentives.calculateIncentiveApr(
            incentivePricing, stats.stakingIncentiveStats, direction, destAddress, amount, price
        );
        result.safeTotalSupply = stats.stakingIncentiveStats.safeTotalSupply;
        result.ownedShares = dest.balanceOf(address(autoPool));
        result.pricePerShare = price;
        result.maxPremium = interimStats.maxPremium;
        result.maxDiscount = interimStats.maxDiscount;

        // Manipulate SummaryStats by hooks if there are registered hooks.  If not this returns result as is
        result = _getHookResults(result, autoPool, destAddress, price, direction, amount);

        uint256 returnExPrice = (
            result.baseApr * IAutopoolStrategy(address(this)).weightBase() / 1e6
                + result.feeApr * IAutopoolStrategy(address(this)).weightFee() / 1e6
                + result.incentiveApr * IAutopoolStrategy(address(this)).weightIncentive() / 1e6
        );

        // price already weighted
        result.compositeReturn = StrategyUtils.convertUintToInt(returnExPrice) + result.priceReturn;

        return result;
    }

    function getRebalanceValueStats(
        IStrategy.RebalanceParams memory params,
        address autoPoolAddress
    ) external returns (RebalanceValueStats memory) {
        uint8 tokenOutDecimals = IERC20Metadata(params.tokenOut).decimals();
        uint8 tokenInDecimals = IERC20Metadata(params.tokenIn).decimals();

        // Prices are all in terms of the base asset, so when its a rebalance back to the vault
        // or out of the vault, We can just take things as 1:1

        // Get the price of one unit of the underlying lp token, the params.tokenOut/tokenIn
        // Prices are calculated using the spot of price of the constituent tokens
        // validated to be within a tolerance of the safe price of those tokens
        uint256 outPrice = params.destinationOut != autoPoolAddress
            ? IDestinationVault(params.destinationOut).getValidatedSpotPrice()
            : 10 ** tokenOutDecimals;

        uint256 inPrice = params.destinationIn != autoPoolAddress
            ? IDestinationVault(params.destinationIn).getValidatedSpotPrice()
            : 10 ** tokenInDecimals;

        // prices are 1e18 and we want values in 1e18, so divide by token decimals
        uint256 outEthValue = params.destinationOut != autoPoolAddress
            ? outPrice * params.amountOut / 10 ** tokenOutDecimals
            : params.amountOut;

        // amountIn is a minimum to receive, but it is OK if we receive more
        uint256 inEthValue = params.destinationIn != autoPoolAddress
            ? inPrice * params.amountIn / 10 ** tokenInDecimals
            : params.amountIn;

        uint256 swapCost = outEthValue.subSaturate(inEthValue);
        uint256 slippage = outEthValue == 0 ? 0 : swapCost * 1e18 / outEthValue;

        return RebalanceValueStats({
            inPrice: inPrice,
            outPrice: outPrice,
            inEthValue: inEthValue,
            outEthValue: outEthValue,
            swapCost: swapCost,
            slippage: slippage
        });
    }

    // Calculate the largest difference between spot & safe price for the underlying LST tokens.
    // This does not support Curve meta pools
    function verifyLSTPriceGap(
        IAutopool autoPool,
        IStrategy.RebalanceParams memory params,
        uint256 tolerance
    ) external returns (bool) {
        // Pricer
        ISystemRegistry registry = ISystemRegistry(ISystemComponent(address(this)).getSystemRegistry());
        IRootPriceOracle pricer = registry.rootPriceOracle();

        IDestinationVault dest;
        address[] memory lstTokens;
        uint256 numLsts;
        address dvPoolAddress;

        // Out Destination
        if (params.destinationOut != address(autoPool)) {
            dest = IDestinationVault(params.destinationOut);
            lstTokens = dest.underlyingTokens();
            numLsts = lstTokens.length;
            dvPoolAddress = dest.getPool();
            for (uint256 i = 0; i < numLsts; ++i) {
                uint256 priceSafe = pricer.getPriceInEth(lstTokens[i]);
                uint256 priceSpot = pricer.getSpotPriceInEth(lstTokens[i], dvPoolAddress);
                // slither-disable-next-line reentrancy-events
                emit OutLSTPriceGap(lstTokens[i], priceSafe, priceSpot);
                // For out destination, the pool tokens should not be lower than safe price by tolerance
                if ((priceSafe == 0) || (priceSpot == 0)) {
                    return false;
                } else if (priceSafe > priceSpot) {
                    if (((priceSafe * 1.0e18 / priceSpot - 1.0e18) * 10_000) / 1.0e18 > tolerance) {
                        return false;
                    }
                }
            }
        }

        // In Destination
        dest = IDestinationVault(params.destinationIn);
        lstTokens = dest.underlyingTokens();
        numLsts = lstTokens.length;
        dvPoolAddress = dest.getPool();
        for (uint256 i = 0; i < numLsts; ++i) {
            uint256 priceSafe = pricer.getPriceInEth(lstTokens[i]);
            uint256 priceSpot = pricer.getSpotPriceInEth(lstTokens[i], dvPoolAddress);
            // slither-disable-next-line reentrancy-events
            emit InLSTPriceGap(lstTokens[i], priceSafe, priceSpot);
            // For in destination, the pool tokens should not be higher than safe price by tolerance
            if ((priceSafe == 0) || (priceSpot == 0)) {
                return false;
            } else if (priceSpot > priceSafe) {
                if (((priceSpot * 1.0e18 / priceSafe - 1.0e18) * 10_000) / 1.0e18 > tolerance) {
                    return false;
                }
            }
        }

        return true;
    }

    function ensureNotStaleData(string memory name, uint256 dataTimestamp) internal view {
        // slither-disable-next-line timestamp
        if (block.timestamp - dataTimestamp > IAutopoolStrategy(address(this)).staleDataToleranceInSeconds()) {
            revert StaleData(name);
        }
    }

    /// @dev Used to apply any manipulations to destinations stats via hooks
    function _getHookResults(
        IStrategy.SummaryStats memory _result,
        IAutopool autopool,
        address destAddress,
        uint256 price,
        IAutopoolStrategy.RebalanceDirection direction,
        uint256 amount
    ) private returns (IStrategy.SummaryStats memory result) {
        result = _result;

        address[] memory hooks = IAutopoolStrategy(address(this)).getHooks();
        for (uint256 i = 0; i < hooks.length; ++i) {
            address currentHook = hooks[i];
            if (currentHook == address(0)) break;

            result = ISummaryStatsHook(currentHook).execute(result, autopool, destAddress, price, direction, amount);
        }
    }
}

// File: src/SystemComponent.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;





contract SystemComponent is ISystemComponent {
    ISystemRegistry internal immutable systemRegistry;

    constructor(ISystemRegistry _systemRegistry) {
        Errors.verifyNotZero(address(_systemRegistry), "_systemRegistry");
        systemRegistry = _systemRegistry;
    }

    /// @inheritdoc ISystemComponent
    function getSystemRegistry() external view returns (address) {
        return address(systemRegistry);
    }
}

// File: src/strategy/AutopoolETHStrategy.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;


























contract AutopoolETHStrategy is SystemComponent, Initializable, IAutopoolStrategy, SecurityBase {
    using ViolationTracking for ViolationTracking.State;
    using NavTracking for NavTracking.State;
    using SubSaturateMath for uint256;
    using SubSaturateMath for int256;
    using Math for uint256;

    /* ******************************** */
    /* Immutable Config                 */
    /* ******************************** */

    /// @notice the number of days to pause rebalancing due to NAV decay
    uint16 public immutable pauseRebalancePeriodInDays;

    /// @notice the number of seconds gap between consecutive rebalances
    uint256 public immutable rebalanceTimeGapInSeconds;

    /// @notice destinations trading a premium above maxPremium will be blocked from new capital deployments
    int256 public immutable maxPremium; // 100% = 1e18

    /// @notice destinations trading a discount above maxDiscount will be blocked from new capital deployments
    int256 public immutable maxDiscount; // 100% = 1e18

    /// @notice the allowed staleness of stats data before a revert occurs
    uint40 public immutable staleDataToleranceInSeconds;

    /// @notice the swap cost offset period to initialize the strategy with
    uint16 public immutable swapCostOffsetInitInDays;

    /// @notice the number of violations required to trigger a tightening of the swap cost offset period (1 to 10)
    uint16 public immutable swapCostOffsetTightenThresholdInViolations;

    /// @notice the number of days to decrease the swap offset period for each tightening step
    uint16 public immutable swapCostOffsetTightenStepInDays;

    /// @notice the number of days since a rebalance required to trigger a relaxing of the swap cost offset period
    uint16 public immutable swapCostOffsetRelaxThresholdInDays;

    /// @notice the number of days to increase the swap offset period for each relaxing step
    uint16 public immutable swapCostOffsetRelaxStepInDays;

    // slither-disable-start similar-names
    /// @notice the maximum the swap cost offset period can reach. This is the loosest the strategy will be
    uint16 public immutable swapCostOffsetMaxInDays;

    /// @notice the minimum the swap cost offset period can reach. This is the most conservative the strategy will be
    uint16 public immutable swapCostOffsetMinInDays;

    /// @notice the number of days for the first NAV decay comparison (e.g., 30 days)
    uint8 public immutable navLookback1InDays;

    /// @notice the number of days for the second NAV decay comparison (e.g., 60 days)
    uint8 public immutable navLookback2InDays;

    /// @notice the number of days for the third NAV decay comparison (e.g., 90 days)
    uint8 public immutable navLookback3InDays;
    // slither-disable-end similar-names

    /// @notice the maximum slippage that is allowed for a normal rebalance
    uint256 public immutable maxNormalOperationSlippage; // 100% = 1e18

    /// @notice the maximum amount of slippage to allow when a destination is trimmed due to constraint violations
    /// recommend setting this higher than maxNormalOperationSlippage
    uint256 public immutable maxTrimOperationSlippage; // 100% = 1e18

    /// @notice the maximum amount of slippage to allow when a destinationVault has been shutdown
    /// shutdown for a vault is abnormal and means there is an issue at that destination
    /// recommend setting this higher than maxNormalOperationSlippage
    uint256 public immutable maxEmergencyOperationSlippage; // 100% = 1e18

    /// @notice the maximum amount of slippage to allow when the AutopoolETH has been shutdown
    uint256 public immutable maxShutdownOperationSlippage; // 100% = 1e18

    /// @notice the maximum discount used for price return
    int256 public immutable maxAllowedDiscount; // 18 precision

    /// @notice model weight used for LSTs base yield, 1e6 is the highest
    uint256 public immutable weightBase;

    /// @notice model weight used for DEX fee yield, 1e6 is the highest
    uint256 public immutable weightFee;

    /// @notice model weight used for incentive yield
    uint256 public immutable weightIncentive;

    /// @notice model weight applied to an LST discount when exiting the position
    int256 public immutable weightPriceDiscountExit;

    /// @notice model weight applied to an LST discount when entering the position
    int256 public immutable weightPriceDiscountEnter;

    /// @notice model weight applied to an LST premium when entering or exiting the position
    int256 public immutable weightPricePremium;

    /// @notice initial value of the swap cost offset to use
    uint16 public immutable swapCostOffsetInit;

    uint256 public immutable defaultLstPriceGapTolerance;

    /// @notice Addresses of hook contracts
    address private immutable hook1;
    address private immutable hook2;
    address private immutable hook3;
    address private immutable hook4;
    address private immutable hook5;

    /* ******************************** */
    /* State Variables                  */
    /* ******************************** */

    /// @notice model weight applied to an LST premium when entering or exiting the position
    uint256 public lstPriceGapTolerance;

    /// @notice Dust position portions
    /// @dev Value is determined as 1/f then truncated to a integer value, where f is a fractional value < 1.0.
    /// For ex. f = 0.02 means a position < 0.02 will be treated as a dust position
    uint256 public dustPositionPortions;

    /// @notice Idle Threshold Low
    /// @dev Fractional value < 1.0 represented in 18 decimals
    /// For ex. a value = 4e16 means 4% of total assets in the vault
    uint256 public idleLowThreshold;

    /// @notice Idle Threshold High
    /// @dev Fractional value < 1.0 represented in 18 decimals
    /// For ex. a value = 7e16 means 7% of total assets in the vault
    /// Low & high idle thresholds trigger different behaviors. When idle is less than low threshold, idle level must be
    /// brought up to high threshold. Any amount > high threshold is free to be deployed to destinations. When idle lies
    /// between low & high threshold, it does not trigger new idle to be added.
    uint256 public idleHighThreshold;

    /// @notice The AutopoolETH that this strategy is associated with
    IAutopool public autoPool;

    /// @notice The timestamp for when rebalancing was last paused
    uint40 public lastPausedTimestamp;

    /// @notice The last timestamp that a destination was added to
    mapping(address => uint40) public lastAddTimestampByDestination;

    /// @notice The last timestamp a rebalance was completed
    uint40 public lastRebalanceTimestamp;

    /// @notice Rebalance violation tracking state
    ViolationTracking.State public violationTrackingState;

    /// @notice NAV tracking state
    NavTracking.State public navTrackingState;

    uint16 private _swapCostOffsetPeriod;

    /* ******************************** */
    /* Events                           */
    /* ******************************** */

    enum RebalanceToIdleReasonEnum {
        DestinationIsShutdown,
        AutopoolETHIsShutdown,
        TrimDustPosition,
        DestinationIsQueuedForRemoval,
        DestinationViolatedConstraint,
        ReplenishIdlePosition,
        UnknownReason
    }

    event RebalanceToIdleReason(RebalanceToIdleReasonEnum reason, uint256 maxSlippage, uint256 slippage);

    event DestTrimRebalanceDetails(
        uint256 assetIndex, uint256 numViolationsOne, uint256 numViolationsTwo, int256 discount
    );
    event DestViolationMaxTrimAmount(uint256 trimAmount);
    event RebalanceToIdle(
        SummaryStats.RebalanceValueStats valueStats, IStrategy.SummaryStats outSummary, IStrategy.RebalanceParams params
    );

    event RebalanceBetweenDestinations(
        SummaryStats.RebalanceValueStats valueStats,
        IStrategy.RebalanceParams params,
        IStrategy.SummaryStats outSummaryStats,
        IStrategy.SummaryStats inSummaryStats,
        uint256 swapOffsetPeriod,
        int256 predictedAnnualizedGain
    );

    event SuccessfulRebalanceBetweenDestinations(
        address destinationOut,
        uint40 lastRebalanceTimestamp,
        uint40 lastTimestampAddedToDestination,
        uint40 swapCostOffsetPeriod
    );

    event PauseStart(uint256 navPerShare, uint256 nav1, uint256 nav2, uint256 nav3);
    event PauseStop();

    event LstPriceGapSet(uint256 newPriceGap);
    event DustPositionPortionSet(uint256 newValue);
    event IdleThresholdsSet(uint256 newLowValue, uint256 newHighValue);

    /* ******************************** */
    /* Errors                           */
    /* ******************************** */
    error NotAutopoolETH();
    error StrategyPaused();
    error RebalanceTimeGapNotMet();
    error RebalanceDestinationsMatch();
    error RebalanceDestinationUnderlyerMismatch(address destination, address trueUnderlyer, address providedUnderlyer);

    error StaleData(string name);
    error SwapCostExceeded();
    error MaxSlippageExceeded();
    error MaxDiscountExceeded();
    error MaxPremiumExceeded();
    error OnlyRebalanceToIdleAvailable();
    error InvalidRebalanceToIdle();
    error CannotConvertUintToInt();
    error InsufficientAssets(address asset);
    error SystemRegistryMismatch();
    error UnregisteredDestination(address dest);
    error LSTPriceGapToleranceExceeded();
    error InconsistentIdleThresholds();
    error IdleHighThresholdViolated();

    modifier onlyAutopool() {
        if (msg.sender != address(autoPool)) revert NotAutopoolETH();
        _;
    }

    constructor(
        ISystemRegistry _systemRegistry,
        AutopoolETHStrategyConfig.StrategyConfig memory conf
    ) SystemComponent(_systemRegistry) SecurityBase(address(_systemRegistry.accessController())) {
        AutopoolETHStrategyConfig.validate(conf);

        rebalanceTimeGapInSeconds = conf.rebalanceTimeGapInSeconds;
        pauseRebalancePeriodInDays = conf.pauseRebalancePeriodInDays;
        maxPremium = conf.maxPremium;
        maxDiscount = conf.maxDiscount;
        staleDataToleranceInSeconds = conf.staleDataToleranceInSeconds;
        swapCostOffsetInitInDays = conf.swapCostOffset.initInDays;
        swapCostOffsetTightenThresholdInViolations = conf.swapCostOffset.tightenThresholdInViolations;
        swapCostOffsetTightenStepInDays = conf.swapCostOffset.tightenStepInDays;
        swapCostOffsetRelaxThresholdInDays = conf.swapCostOffset.relaxThresholdInDays;
        swapCostOffsetRelaxStepInDays = conf.swapCostOffset.relaxStepInDays;
        swapCostOffsetMaxInDays = conf.swapCostOffset.maxInDays;
        swapCostOffsetMinInDays = conf.swapCostOffset.minInDays;
        navLookback1InDays = conf.navLookback.lookback1InDays;
        navLookback2InDays = conf.navLookback.lookback2InDays;
        navLookback3InDays = conf.navLookback.lookback3InDays;
        maxNormalOperationSlippage = conf.slippage.maxNormalOperationSlippage;
        maxTrimOperationSlippage = conf.slippage.maxTrimOperationSlippage;
        maxEmergencyOperationSlippage = conf.slippage.maxEmergencyOperationSlippage;
        maxShutdownOperationSlippage = conf.slippage.maxShutdownOperationSlippage;
        maxAllowedDiscount = conf.maxAllowedDiscount;
        weightBase = conf.modelWeights.baseYield;
        weightFee = conf.modelWeights.feeYield;
        weightIncentive = conf.modelWeights.incentiveYield;
        weightPriceDiscountExit = conf.modelWeights.priceDiscountExit;
        weightPriceDiscountEnter = conf.modelWeights.priceDiscountEnter;
        weightPricePremium = conf.modelWeights.pricePremium;
        defaultLstPriceGapTolerance = conf.lstPriceGapTolerance;
        swapCostOffsetInit = conf.swapCostOffset.initInDays;
        hook1 = conf.hooks[0];
        hook2 = conf.hooks[1];
        hook3 = conf.hooks[2];
        hook4 = conf.hooks[3];
        hook5 = conf.hooks[4];

        _disableInitializers();
    }

    function initialize(address _autoPool) external virtual initializer {
        _initialize(_autoPool);
    }

    function _initialize(address _autoPool) internal virtual {
        Errors.verifyNotZero(_autoPool, "_autoPool");

        if (ISystemComponent(_autoPool).getSystemRegistry() != address(systemRegistry)) {
            revert SystemRegistryMismatch();
        }

        autoPool = IAutopool(_autoPool);

        lastRebalanceTimestamp = uint40(block.timestamp) - uint40(rebalanceTimeGapInSeconds);
        _swapCostOffsetPeriod = swapCostOffsetInit;
        lstPriceGapTolerance = defaultLstPriceGapTolerance;
        dustPositionPortions = 50;
        idleLowThreshold = 0;
        idleHighThreshold = 0;
    }

    /// @notice Sets the LST price gap tolerance to the provided value
    function setLstPriceGapTolerance(uint256 priceGapTolerance) external hasRole(Roles.AUTO_POOL_MANAGER) {
        lstPriceGapTolerance = priceGapTolerance;

        emit LstPriceGapSet(priceGapTolerance);
    }

    /// @notice Sets the dust position portions to the provided value
    function setDustPositionPortions(uint256 newValue) external hasRole(Roles.AUTO_POOL_MANAGER) {
        dustPositionPortions = newValue;

        emit DustPositionPortionSet(newValue);
    }

    /// @notice Sets the Idle low/high threshold
    function setIdleThresholds(uint256 newLowValue, uint256 newHighValue) external hasRole(Roles.AUTO_POOL_MANAGER) {
        idleLowThreshold = newLowValue;
        idleHighThreshold = newHighValue;

        // Check for consistency in values i.e. low threshold should be strictly < high threshold
        if (((idleLowThreshold > 0 && idleHighThreshold > 0)) && (idleLowThreshold >= idleHighThreshold)) {
            revert InconsistentIdleThresholds();
        }
        // Setting both thresholds to 0 allows no minimum requirement for idle
        if ((idleLowThreshold == 0 && idleHighThreshold != 0) || (idleLowThreshold != 0 && idleHighThreshold == 0)) {
            revert InconsistentIdleThresholds();
        }

        emit IdleThresholdsSet(newLowValue, newHighValue);
    }

    /// @inheritdoc IAutopoolStrategy
    function verifyRebalance(
        IStrategy.RebalanceParams memory params,
        IStrategy.SummaryStats memory outSummary
    ) external returns (bool success, string memory message) {
        SummaryStats.RebalanceValueStats memory valueStats =
            SummaryStats.getRebalanceValueStats(params, address(autoPool));

        // moves from a destination back to eth only happen under specific scenarios
        // if the move is valid, the constraints are different than if assets are moving to a normal destination
        if (params.destinationIn == address(autoPool)) {
            verifyRebalanceToIdle(params, valueStats.slippage);
            // slither-disable-next-line reentrancy-events
            emit RebalanceToIdle(valueStats, outSummary, params);
            // exit early b/c the remaining constraints only apply when moving to a normal destination
            return (true, "");
        }

        // rebalances back to idle are allowed even when a strategy is paused
        // all other rebalances should be blocked in a paused state
        ensureNotPaused();

        // Ensure enough time has passed between rebalances
        if ((uint40(block.timestamp) - lastRebalanceTimestamp) < rebalanceTimeGapInSeconds) {
            revert RebalanceTimeGapNotMet();
        }

        // ensure that we're not exceeding top-level max slippage
        if (valueStats.slippage > maxNormalOperationSlippage) {
            revert MaxSlippageExceeded();
        }

        // ensure that idle is not depleted below the high threshold if we are pulling from Idle assets
        // totalAssets will be reduced by swap cost amount.
        if (params.destinationOut == address(autoPool)) {
            uint256 totalAssets = autoPool.totalAssets().subSaturate(valueStats.swapCost);
            if (autoPool.getAssetBreakdown().totalIdle < valueStats.outEthValue) {
                revert IdleHighThresholdViolated();
            } else if (
                (autoPool.getAssetBreakdown().totalIdle - valueStats.outEthValue)
                    < ((totalAssets * idleHighThreshold) / 1e18)
            ) {
                revert IdleHighThresholdViolated();
            }
        }

        IStrategy.SummaryStats memory inSummary = getRebalanceInSummaryStats(params);

        // ensure that the destination that is being added to doesn't exceed top-level premium/discount constraints
        if (inSummary.maxDiscount > maxDiscount) revert MaxDiscountExceeded();
        if (-inSummary.maxPremium > maxPremium) revert MaxPremiumExceeded();

        uint256 swapOffsetPeriod = swapCostOffsetPeriodInDays();

        // if the swap is only moving lp tokens from one destination to another
        // make the swap offset period more conservative b/c the gas costs/complexity is lower
        // Discard the fractional part resulting from div by 2 to be conservative
        if (params.tokenIn == params.tokenOut) {
            swapOffsetPeriod = swapOffsetPeriod / 2;
        }
        // slither-disable-start divide-before-multiply
        // equation is `compositeReturn * ethValue` / 1e18, which is multiply before divide
        // compositeReturn and ethValue are both 1e18 precision
        int256 predictedAnnualizedGain = (
            inSummary.compositeReturn * StrategyUtils.convertUintToInt(valueStats.inEthValue)
        ).subSaturate(outSummary.compositeReturn * StrategyUtils.convertUintToInt(valueStats.outEthValue)) / 1e18;

        // slither-disable-end divide-before-multiply
        int256 predictedGainAtOffsetEnd =
            (predictedAnnualizedGain * StrategyUtils.convertUintToInt(swapOffsetPeriod) / 365);

        // if the predicted gain in Eth by the end of the swap offset period is less than
        // the swap cost then revert b/c the vault will not offset slippage in sufficient time
        // slither-disable-next-line timestamp
        if (predictedGainAtOffsetEnd <= StrategyUtils.convertUintToInt(valueStats.swapCost)) revert SwapCostExceeded();
        // slither-disable-next-line reentrancy-events
        emit RebalanceBetweenDestinations(
            valueStats, params, outSummary, inSummary, swapOffsetPeriod, predictedAnnualizedGain
        );

        return (true, "");
    }

    function expiredRewardTolerance() external pure returns (uint256) {
        return Incentives.EXPIRED_REWARD_TOLERANCE;
    }

    /// @inheritdoc IAutopoolStrategy
    function getDestinationSummaryStats(
        address destAddress,
        IAutopoolStrategy.RebalanceDirection direction,
        uint256 amount
    ) external returns (IStrategy.SummaryStats memory) {
        address token =
            destAddress == address(autoPool) ? autoPool.asset() : IDestinationVault(destAddress).underlying();
        uint256 outPrice = _getInOutTokenPriceInEth(token, destAddress);
        return SummaryStats.getDestinationSummaryStats(
            autoPool, systemRegistry.incentivePricing(), destAddress, outPrice, direction, amount
        );
    }

    function validateRebalanceParams(IStrategy.RebalanceParams memory params) internal view {
        Errors.verifyNotZero(params.destinationIn, "destinationIn");
        Errors.verifyNotZero(params.destinationOut, "destinationOut");
        Errors.verifyNotZero(params.tokenIn, "tokenIn");
        Errors.verifyNotZero(params.tokenOut, "tokenOut");
        Errors.verifyNotZero(params.amountIn, "amountIn");
        Errors.verifyNotZero(params.amountOut, "amountOut");

        ensureDestinationRegistered(params.destinationIn);
        ensureDestinationRegistered(params.destinationOut);

        // when a vault is shutdown, rebalancing can only pull assets from destinations back to the vault
        if (autoPool.isShutdown() && params.destinationIn != address(autoPool)) revert OnlyRebalanceToIdleAvailable();

        if (params.destinationIn == params.destinationOut) revert RebalanceDestinationsMatch();

        address baseAsset = autoPool.asset();

        // if the in/out destination is the AutopoolETH then the in/out token must be the baseAsset
        // if the in/out is not the AutopoolETH then the in/out token must match the destinations underlying token
        if (params.destinationIn == address(autoPool)) {
            if (params.tokenIn != baseAsset) {
                revert RebalanceDestinationUnderlyerMismatch(params.destinationIn, params.tokenIn, baseAsset);
            }
        } else {
            IDestinationVault inDest = IDestinationVault(params.destinationIn);
            if (params.tokenIn != inDest.underlying()) {
                revert RebalanceDestinationUnderlyerMismatch(params.destinationIn, inDest.underlying(), params.tokenIn);
            }
        }

        if (params.destinationOut == address(autoPool)) {
            if (params.tokenOut != baseAsset) {
                revert RebalanceDestinationUnderlyerMismatch(params.destinationOut, params.tokenOut, baseAsset);
            }
            if (params.amountOut > autoPool.getAssetBreakdown().totalIdle) {
                revert InsufficientAssets(params.tokenOut);
            }
        } else {
            IDestinationVault outDest = IDestinationVault(params.destinationOut);
            if (params.tokenOut != outDest.underlying()) {
                revert RebalanceDestinationUnderlyerMismatch(
                    params.destinationOut, outDest.underlying(), params.tokenOut
                );
            }
            if (params.amountOut > outDest.balanceOf(address(autoPool))) {
                revert InsufficientAssets(params.tokenOut);
            }
        }
    }

    function ensureDestinationRegistered(address dest) private view {
        if (dest == address(autoPool)) return;
        if (!(autoPool.isDestinationRegistered(dest) || autoPool.isDestinationQueuedForRemoval(dest))) {
            revert UnregisteredDestination(dest);
        }
    }

    function verifyRebalanceToIdle(IStrategy.RebalanceParams memory params, uint256 slippage) internal {
        IDestinationVault outDest = IDestinationVault(params.destinationOut);

        // multiple scenarios can be active at a given time. We want to use the highest
        // slippage among the active scenarios.
        uint256 maxSlippage = 0;
        RebalanceToIdleReasonEnum reason = RebalanceToIdleReasonEnum.UnknownReason;
        // Scenario 1: the destination has been shutdown -- done when a fast exit is required
        if (outDest.isShutdown()) {
            reason = RebalanceToIdleReasonEnum.DestinationIsShutdown;
            maxSlippage = maxEmergencyOperationSlippage;
        }

        // Scenario 2: the AutopoolETH has been shutdown
        if (autoPool.isShutdown() && maxShutdownOperationSlippage > maxSlippage) {
            reason = RebalanceToIdleReasonEnum.AutopoolETHIsShutdown;
            maxSlippage = maxShutdownOperationSlippage;
        }

        // Scenario 3: Replenishing Idle requires trimming destination
        if (verifyIdleUpOperation(params) && maxNormalOperationSlippage > maxSlippage) {
            reason = RebalanceToIdleReasonEnum.ReplenishIdlePosition;
            maxSlippage = maxNormalOperationSlippage;
        }

        // Scenario 4: position is a dust position and should be trimmed
        if (verifyCleanUpOperation(params) && maxNormalOperationSlippage > maxSlippage) {
            reason = RebalanceToIdleReasonEnum.TrimDustPosition;
            maxSlippage = maxNormalOperationSlippage;
        }

        // Scenario 5: the destination has been moved out of the Autopools active destinations
        if (autoPool.isDestinationQueuedForRemoval(params.destinationOut) && maxNormalOperationSlippage > maxSlippage) {
            reason = RebalanceToIdleReasonEnum.DestinationIsQueuedForRemoval;
            maxSlippage = maxNormalOperationSlippage;
        }

        // Scenario 6: the destination needs to be trimmed because it violated a constraint
        if (maxTrimOperationSlippage > maxSlippage) {
            reason = RebalanceToIdleReasonEnum.DestinationViolatedConstraint;
            uint256 trimAmount = getDestinationTrimAmount(outDest); // this is expensive, can it be refactored?
            if (trimAmount < 1e18 && verifyTrimOperation(params, trimAmount)) {
                maxSlippage = maxTrimOperationSlippage;
            }
            // slither-disable-next-line reentrancy-events
            emit DestViolationMaxTrimAmount(trimAmount);
        }
        // slither-disable-next-line reentrancy-events
        emit RebalanceToIdleReason(reason, maxSlippage, slippage);

        // if none of the scenarios are active then this rebalance is invalid
        if (maxSlippage == 0) revert InvalidRebalanceToIdle();

        if (slippage > maxSlippage) revert MaxSlippageExceeded();
    }

    function verifyCleanUpOperation(IStrategy.RebalanceParams memory params) internal view returns (bool) {
        IDestinationVault outDest = IDestinationVault(params.destinationOut);

        AutopoolDebt.DestinationInfo memory destInfo = autoPool.getDestinationInfo(params.destinationOut);
        // revert if information is too old
        ensureNotStaleData("DestInfo", destInfo.lastReport);
        // shares of the destination currently held by the AutopoolETH
        uint256 currentShares = outDest.balanceOf(address(autoPool));
        // withdrawals reduce totalAssets, but do not update the destinationInfo
        // adjust the current debt based on the currently owned shares
        uint256 currentDebt =
            destInfo.ownedShares == 0 ? 0 : destInfo.cachedDebtValue * currentShares / destInfo.ownedShares;

        // If the current position is the minimum portion, trim to idle is allowed
        // slither-disable-next-line divide-before-multiply
        if ((currentDebt * 1e18) < ((autoPool.totalAssets() * 1e18) / dustPositionPortions)) {
            return true;
        }

        return false;
    }

    function verifyIdleUpOperation(IStrategy.RebalanceParams memory params) internal view returns (bool) {
        AutopoolDebt.DestinationInfo memory destInfo = autoPool.getDestinationInfo(params.destinationOut);
        // revert if information is too old
        ensureNotStaleData("DestInfo", destInfo.lastReport);
        uint256 currentIdle = autoPool.getAssetBreakdown().totalIdle;
        uint256 newIdle = currentIdle + params.amountIn;
        uint256 totalAssets = autoPool.totalAssets();
        // If idle is below low threshold, then allow replinishing Idle. New idle after rebalance should be above high
        // threshold. While totalAssets after this rebalance will be lower by swap loss, the ratio idle / total assets
        // as used is conservative.
        // Idle thresholds (both low & high) use 18 decimals
        // slither-disable-next-line divide-before-multiply
        if ((currentIdle * 1e18) / totalAssets < idleLowThreshold) {
            // Allow small margin to exceed high threshold to avoid precision issues & pricing differences
            if ((newIdle * 1e18) / totalAssets < idleHighThreshold + 1e16) {
                return true;
            }
        }

        return false;
    }

    function verifyTrimOperation(IStrategy.RebalanceParams memory params, uint256 trimAmount) internal returns (bool) {
        // if the position can be trimmed to zero, then no checks are necessary
        if (trimAmount == 0) {
            return true;
        }

        IDestinationVault outDest = IDestinationVault(params.destinationOut);

        AutopoolDebt.DestinationInfo memory destInfo = autoPool.getDestinationInfo(params.destinationOut);
        // revert if information is too old
        ensureNotStaleData("DestInfo", destInfo.lastReport);

        // shares of the destination currently held by the AutopoolETH
        uint256 currentShares = outDest.balanceOf(address(autoPool));

        // withdrawals reduce totalAssets, but do not update the destinationInfo
        // adjust the current debt based on the currently owned shares
        uint256 currentDebt =
            destInfo.ownedShares == 0 ? 0 : destInfo.cachedDebtValue * currentShares / destInfo.ownedShares;

        // prior validation ensures that currentShares >= amountOut
        uint256 sharesAfterRebalance = currentShares - params.amountOut;

        // current value of the destination shares, not cached from debt reporting
        uint256 destValueAfterRebalance = outDest.debtValue(sharesAfterRebalance);

        // calculate the total value of the autoPool after the rebalance is made
        // note that only the out destination value is adjusted to current
        // amountIn is a minimum to receive, but it is OK if we receive more
        uint256 autoPoolAssetsAfterRebalance =
            (autoPool.totalAssets() + params.amountIn + destValueAfterRebalance - currentDebt);

        // trimming may occur over multiple rebalances, so we only want to ensure we aren't removing too much
        if (autoPoolAssetsAfterRebalance > 0) {
            return destValueAfterRebalance * 1e18 / autoPoolAssetsAfterRebalance >= trimAmount;
        } else {
            // Autopool assets after rebalance are 0
            return true;
        }
    }

    function getDestinationTrimAmount(IDestinationVault dest) internal returns (uint256) {
        uint256 discountThresholdOne = 3e5; // 3% 1e7 precision, discount required to consider trimming
        uint256 discountDaysThreshold = 7; // number of last 10 days that it was >= discountThreshold
        uint256 discountThresholdTwo = 5e5; // 5% 1e7 precision, discount required to completely exit

        // this is always the out destination and guaranteed not to be the AutopoolETH idle asset
        IDexLSTStats.DexLSTStatsData memory stats = dest.getStats().current();

        ILSTStats.LSTStatsData[] memory lstStats = stats.lstStatsData;
        uint256 numLsts = lstStats.length;

        uint256 minTrim = 1e18; // 100% -- no trim required
        for (uint256 i = 0; i < numLsts; ++i) {
            ILSTStats.LSTStatsData memory targetLst = lstStats[i];
            (uint256 numViolationsOne, uint256 numViolationsTwo) =
                getDiscountAboveThreshold(targetLst.discountHistory, discountThresholdOne, discountThresholdTwo);

            // slither-disable-next-line reentrancy-events
            emit DestTrimRebalanceDetails(i, numViolationsOne, numViolationsTwo, targetLst.discount);

            if (targetLst.discount >= int256(discountThresholdTwo * 1e11) && numViolationsTwo >= discountDaysThreshold)
            {
                // this is the worst possible trim, so we can exit without checking other LSTs

                return 0;
            }

            // discountThreshold is 1e7 precision for the discount history, but here it is compared to a 1e18, so pad it
            if (targetLst.discount >= int256(discountThresholdOne * 1e11) && numViolationsOne >= discountDaysThreshold)
            {
                minTrim = minTrim.min(1e17); // 10%
            }
        }

        return minTrim;
    }

    function getDiscountAboveThreshold(
        uint24[10] memory discountHistory,
        uint256 threshold1,
        uint256 threshold2
    ) internal pure returns (uint256 count1, uint256 count2) {
        count1 = 0;
        count2 = 0;
        uint256 len = discountHistory.length;
        for (uint256 i = 0; i < len; ++i) {
            if (discountHistory[i] >= threshold1) {
                count1 += 1;
            }
            if (discountHistory[i] >= threshold2) {
                count2 += 1;
            }
        }
    }

    /// @inheritdoc IAutopoolStrategy
    function getRebalanceOutSummaryStats(IStrategy.RebalanceParams memory rebalanceParams)
        external
        returns (IStrategy.SummaryStats memory outSummary)
    {
        validateRebalanceParams(rebalanceParams);
        // Verify spot & safe price for the individual tokens in the pool are not far apart.
        // Call to verify before remove/add liquidity to the dest in the rebalance txn
        // if the in dest is not the Autopool i.e. this is not a rebalance to idle txn, verify price tolerance
        if (rebalanceParams.destinationIn != address(autoPool)) {
            if (!SummaryStats.verifyLSTPriceGap(autoPool, rebalanceParams, lstPriceGapTolerance)) {
                revert LSTPriceGapToleranceExceeded();
            }
        }
        outSummary = _getRebalanceOutSummaryStats(rebalanceParams);
    }

    function _getRebalanceOutSummaryStats(IStrategy.RebalanceParams memory rebalanceParams)
        internal
        virtual
        returns (IStrategy.SummaryStats memory outSummary)
    {
        // Use safe price
        uint256 outPrice = _getInOutTokenPriceInEth(rebalanceParams.tokenOut, rebalanceParams.destinationOut);
        outSummary = (
            SummaryStats.getDestinationSummaryStats(
                autoPool,
                systemRegistry.incentivePricing(),
                rebalanceParams.destinationOut,
                outPrice,
                RebalanceDirection.Out,
                rebalanceParams.amountOut
            )
        );
    }

    /// @dev Price the tokens from rebalance params with the appropriate method
    function _getInOutTokenPriceInEth(address token, address destination) private returns (uint256) {
        IRootPriceOracle pricer = systemRegistry.rootPriceOracle();
        if (destination == address(autoPool)) {
            // When the destination is the autoPool then the token is the underlying asset
            // which means its not an LP token so we use this pricing fn
            return pricer.getPriceInEth(token);
        } else {
            // Otherwise we know its a real destination and so we can get the price directly from there
            return IDestinationVault(destination).getValidatedSafePrice();
        }
    }

    // Summary stats for destination In
    function getRebalanceInSummaryStats(IStrategy.RebalanceParams memory rebalanceParams)
        internal
        virtual
        returns (IStrategy.SummaryStats memory inSummary)
    {
        // Use safe price
        uint256 inPrice = _getInOutTokenPriceInEth(rebalanceParams.tokenIn, rebalanceParams.destinationIn);
        inSummary = (
            SummaryStats.getDestinationSummaryStats(
                autoPool,
                systemRegistry.incentivePricing(),
                rebalanceParams.destinationIn,
                inPrice,
                RebalanceDirection.In,
                rebalanceParams.amountIn
            )
        );
    }

    /// @inheritdoc IAutopoolStrategy
    function navUpdate(uint256 navPerShare) external onlyAutopool {
        uint40 blockTime = uint40(block.timestamp);
        navTrackingState.insert(navPerShare, blockTime);

        clearExpiredPause();

        // check if the strategy needs to be paused due to NAV decay
        // the check only happens after there are enough data points
        // skip the check if the strategy is already paused
        // slither-disable-next-line timestamp
        if (navTrackingState.len > navLookback3InDays && !paused()) {
            uint256 nav1 = navTrackingState.getDaysAgo(navLookback1InDays);
            uint256 nav2 = navTrackingState.getDaysAgo(navLookback2InDays);
            uint256 nav3 = navTrackingState.getDaysAgo(navLookback3InDays);

            if (navPerShare < nav1 && navPerShare < nav2 && navPerShare < nav3) {
                lastPausedTimestamp = blockTime;
                emit PauseStart(navPerShare, nav1, nav2, nav3);
            }
        }
    }

    /// @inheritdoc IAutopoolStrategy
    function rebalanceSuccessfullyExecuted(IStrategy.RebalanceParams memory params) external onlyAutopool {
        // clearExpirePause sets _swapCostOffsetPeriod, so skip when possible to avoid double write
        if (!clearExpiredPause()) _swapCostOffsetPeriod = swapCostOffsetPeriodInDays();

        address autoPoolAddress = address(autoPool);

        // update the destination that had assets added
        // moves into idle are not tracked for violations
        if (params.destinationIn != autoPoolAddress) {
            // Update to lastRebalanceTimestamp excludes rebalances to idle as those skip swapCostOffset logic
            lastRebalanceTimestamp = uint40(block.timestamp);
            lastAddTimestampByDestination[params.destinationIn] = lastRebalanceTimestamp;
        }

        // violations are only tracked when moving between non-idle assets
        if (params.destinationOut != autoPoolAddress && params.destinationIn != autoPoolAddress) {
            uint40 lastAddForRemoveDestination = lastAddTimestampByDestination[params.destinationOut];
            uint40 swapCostOffsetPeriod = uint40(swapCostOffsetPeriodInDays());
            if (
                // slither-disable-start timestamp
                lastRebalanceTimestamp - lastAddForRemoveDestination < swapCostOffsetPeriod * 1 days
            ) {
                // slither-disable-end timestamp

                violationTrackingState.insert(true);
            } else {
                violationTrackingState.insert(false);
            }
            emit SuccessfulRebalanceBetweenDestinations(
                params.destinationOut, lastRebalanceTimestamp, lastAddForRemoveDestination, swapCostOffsetPeriod
            );
        }

        // tighten if X of the last 10 rebalances were violations
        if (
            violationTrackingState.len == 10
                && violationTrackingState.violationCount >= swapCostOffsetTightenThresholdInViolations
        ) {
            tightenSwapCostOffset();
            violationTrackingState.reset();
        }
    }

    /// @inheritdoc IAutopoolStrategy
    function getHooks() public view virtual override returns (address[] memory hooks) {
        hooks = new address[](5);
        hooks[0] = hook1;
        hooks[1] = hook2;
        hooks[2] = hook3;
        hooks[3] = hook4;
        hooks[4] = hook5;
    }

    function swapCostOffsetPeriodInDays() public view returns (uint16) {
        // if the system is in an expired pause state then ensure that swap cost offset
        // is set to the most conservative value (shortest number of days)
        if (expiredPauseState()) {
            return swapCostOffsetMinInDays;
        }

        // truncation is desirable because we only want the number of times it has exceeded the threshold
        // slither-disable-next-line divide-before-multiply
        uint40 numRelaxPeriods = swapCostOffsetRelaxThresholdInDays == 0
            ? 0
            : (uint40(block.timestamp) - lastRebalanceTimestamp) / 1 days / uint40(swapCostOffsetRelaxThresholdInDays);
        uint40 relaxDays = numRelaxPeriods * uint40(swapCostOffsetRelaxStepInDays);
        uint40 newSwapCostOffset = uint40(_swapCostOffsetPeriod) + relaxDays;

        // slither-disable-next-line timestamp
        if (newSwapCostOffset > swapCostOffsetMaxInDays) {
            return swapCostOffsetMaxInDays;
        }

        return uint16(newSwapCostOffset);
    }

    function tightenSwapCostOffset() internal {
        uint16 currentSwapOffset = swapCostOffsetPeriodInDays();
        uint16 newSwapCostOffset = 0;

        if (currentSwapOffset > swapCostOffsetTightenStepInDays) {
            newSwapCostOffset = currentSwapOffset - swapCostOffsetTightenStepInDays;
        }

        // slither-disable-next-line timestamp
        if (newSwapCostOffset < swapCostOffsetMinInDays) {
            _swapCostOffsetPeriod = swapCostOffsetMinInDays;
        } else {
            _swapCostOffsetPeriod = newSwapCostOffset;
        }
    }

    function paused() public view returns (bool) {
        // slither-disable-next-line incorrect-equality,timestamp
        if (lastPausedTimestamp == 0) return false;
        uint40 pauseRebalanceInSeconds = uint40(pauseRebalancePeriodInDays) * 1 days;

        // slither-disable-next-line timestamp
        return uint40(block.timestamp) - lastPausedTimestamp <= pauseRebalanceInSeconds;
    }

    function ensureNotPaused() internal view {
        if (paused()) revert StrategyPaused();
    }

    function expiredPauseState() internal view returns (bool) {
        // slither-disable-next-line timestamp
        return lastPausedTimestamp > 0 && !paused();
    }

    function clearExpiredPause() internal returns (bool) {
        if (!expiredPauseState()) return false;

        lastPausedTimestamp = 0;
        emit PauseStop();
        _swapCostOffsetPeriod = swapCostOffsetMinInDays;
        return true;
    }

    function ensureNotStaleData(string memory name, uint256 dataTimestamp) internal view {
        // slither-disable-next-line timestamp
        if (block.timestamp - dataTimestamp > staleDataToleranceInSeconds) revert StaleData(name);
    }
}
