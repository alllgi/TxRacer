// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: contracts/infiniteProxy/interfaces/iProxy.sol

pragma solidity >=0.8.21 <=0.8.29;

interface IProxy {
    function setAdmin(address newAdmin_) external;

    function setDummyImplementation(address newDummyImplementation_) external;

    function addImplementation(address implementation_, bytes4[] calldata sigs_) external;

    function removeImplementation(address implementation_) external;

    function getAdmin() external view returns (address);

    function getDummyImplementation() external view returns (address);

    function getImplementationSigs(address impl_) external view returns (bytes4[] memory);

    function getSigsImplementation(bytes4 sig_) external view returns (address);

    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);
}

// File: contracts/liquidity/adminModule/structs.sol

pragma solidity >=0.8.21 <=0.8.29;

abstract contract Structs {
    struct AddressBool {
        address addr;
        bool value;
    }

    struct AddressUint256 {
        address addr;
        uint256 value;
    }

    /// @notice struct to set borrow rate data for version 1
    struct RateDataV1Params {
        ///
        /// @param token for rate data
        address token;
        ///
        /// @param kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink usually means slow increase in rate, once utilization is above kink borrow rate increases fast
        uint256 kink;
        ///
        /// @param rateAtUtilizationZero desired borrow rate when utilization is zero. in 1e2: 100% = 10_000; 1% = 100
        /// i.e. constant minimum borrow rate
        /// e.g. at utilization = 0.01% rate could still be at least 4% (rateAtUtilizationZero would be 400 then)
        uint256 rateAtUtilizationZero;
        ///
        /// @param rateAtUtilizationKink borrow rate when utilization is at kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at kink then rateAtUtilizationKink would be 700
        uint256 rateAtUtilizationKink;
        ///
        /// @param rateAtUtilizationMax borrow rate when utilization is maximum at 100%. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 125% at 100% then rateAtUtilizationMax would be 12_500
        uint256 rateAtUtilizationMax;
    }

    /// @notice struct to set borrow rate data for version 2
    struct RateDataV2Params {
        ///
        /// @param token for rate data
        address token;
        ///
        /// @param kink1 first kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink 1 usually means slow increase in rate, once utilization is above kink 1 borrow rate increases faster
        uint256 kink1;
        ///
        /// @param kink2 second kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink 2 usually means slow / medium increase in rate, once utilization is above kink 2 borrow rate increases fast
        uint256 kink2;
        ///
        /// @param rateAtUtilizationZero desired borrow rate when utilization is zero. in 1e2: 100% = 10_000; 1% = 100
        /// i.e. constant minimum borrow rate
        /// e.g. at utilization = 0.01% rate could still be at least 4% (rateAtUtilizationZero would be 400 then)
        uint256 rateAtUtilizationZero;
        ///
        /// @param rateAtUtilizationKink1 desired borrow rate when utilization is at first kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at first kink then rateAtUtilizationKink would be 700
        uint256 rateAtUtilizationKink1;
        ///
        /// @param rateAtUtilizationKink2 desired borrow rate when utilization is at second kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at second kink then rateAtUtilizationKink would be 1_200
        uint256 rateAtUtilizationKink2;
        ///
        /// @param rateAtUtilizationMax desired borrow rate when utilization is maximum at 100%. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 125% at 100% then rateAtUtilizationMax would be 12_500
        uint256 rateAtUtilizationMax;
    }

    /// @notice struct to set token config
    struct TokenConfig {
        ///
        /// @param token address
        address token;
        ///
        /// @param fee charges on borrower's interest. in 1e2: 100% = 10_000; 1% = 100
        uint256 fee;
        ///
        /// @param threshold on when to update the storage slot. in 1e2: 100% = 10_000; 1% = 100
        uint256 threshold;
        ///
        /// @param maxUtilization maximum allowed utilization. in 1e2: 100% = 10_000; 1% = 100
        ///                       set to 100% to disable and have default limit of 100% (avoiding SLOAD).
        uint256 maxUtilization;
    }

    /// @notice struct to set user supply & withdrawal config
    struct UserSupplyConfig {
        ///
        /// @param user address
        address user;
        ///
        /// @param token address
        address token;
        ///
        /// @param mode: 0 = without interest. 1 = with interest
        uint8 mode;
        ///
        /// @param expandPercent withdrawal limit expand percent. in 1e2: 100% = 10_000; 1% = 100
        /// Also used to calculate rate at which withdrawal limit should decrease (instant).
        uint256 expandPercent;
        ///
        /// @param expandDuration withdrawal limit expand duration in seconds.
        /// used to calculate rate together with expandPercent
        uint256 expandDuration;
        ///
        /// @param baseWithdrawalLimit base limit, below this, user can withdraw the entire amount.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 baseWithdrawalLimit;
    }

    /// @notice struct to set user borrow & payback config
    struct UserBorrowConfig {
        ///
        /// @param user address
        address user;
        ///
        /// @param token address
        address token;
        ///
        /// @param mode: 0 = without interest. 1 = with interest
        uint8 mode;
        ///
        /// @param expandPercent debt limit expand percent. in 1e2: 100% = 10_000; 1% = 100
        /// Also used to calculate rate at which debt limit should decrease (instant).
        uint256 expandPercent;
        ///
        /// @param expandDuration debt limit expand duration in seconds.
        /// used to calculate rate together with expandPercent
        uint256 expandDuration;
        ///
        /// @param baseDebtCeiling base borrow limit. until here, borrow limit remains as baseDebtCeiling
        /// (user can borrow until this point at once without stepped expansion). Above this, automated limit comes in place.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 baseDebtCeiling;
        ///
        /// @param maxDebtCeiling max borrow ceiling, maximum amount the user can borrow.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 maxDebtCeiling;
    }
}

// File: contracts/liquidity/interfaces/iLiquidity.sol

pragma solidity >=0.8.21 <=0.8.29;




interface IFluidLiquidityAdmin {
    /// @notice adds/removes auths. Auths generally could be contracts which can have restricted actions defined on contract.
    ///         auths can be helpful in reducing governance overhead where it's not needed.
    /// @param authsStatus_ array of structs setting allowed status for an address.
    ///                     status true => add auth, false => remove auth
    function updateAuths(AdminModuleStructs.AddressBool[] calldata authsStatus_) external;

    /// @notice adds/removes guardians. Only callable by Governance.
    /// @param guardiansStatus_ array of structs setting allowed status for an address.
    ///                         status true => add guardian, false => remove guardian
    function updateGuardians(AdminModuleStructs.AddressBool[] calldata guardiansStatus_) external;

    /// @notice changes the revenue collector address (contract that is sent revenue). Only callable by Governance.
    /// @param revenueCollector_  new revenue collector address
    function updateRevenueCollector(address revenueCollector_) external;

    /// @notice changes current status, e.g. for pausing or unpausing all user operations. Only callable by Auths.
    /// @param newStatus_ new status
    ///        status = 2 -> pause, status = 1 -> resume.
    function changeStatus(uint256 newStatus_) external;

    /// @notice                  update tokens rate data version 1. Only callable by Auths.
    /// @param tokensRateData_   array of RateDataV1Params with rate data to set for each token
    function updateRateDataV1s(AdminModuleStructs.RateDataV1Params[] calldata tokensRateData_) external;

    /// @notice                  update tokens rate data version 2. Only callable by Auths.
    /// @param tokensRateData_   array of RateDataV2Params with rate data to set for each token
    function updateRateDataV2s(AdminModuleStructs.RateDataV2Params[] calldata tokensRateData_) external;

    /// @notice updates token configs: fee charge on borrowers interest & storage update utilization threshold.
    ///         Only callable by Auths.
    /// @param tokenConfigs_ contains token address, fee & utilization threshold
    function updateTokenConfigs(AdminModuleStructs.TokenConfig[] calldata tokenConfigs_) external;

    /// @notice updates user classes: 0 is for new protocols, 1 is for established protocols.
    ///         Only callable by Auths.
    /// @param userClasses_ struct array of uint256 value to assign for each user address
    function updateUserClasses(AdminModuleStructs.AddressUint256[] calldata userClasses_) external;

    /// @notice sets user supply configs per token basis. Eg: with interest or interest-free and automated limits.
    ///         Only callable by Auths.
    ///         Resets decay limit to 0.
    /// @param userSupplyConfigs_ struct array containing user supply config, see `UserSupplyConfig` struct for more info
    function updateUserSupplyConfigs(AdminModuleStructs.UserSupplyConfig[] memory userSupplyConfigs_) external;

    /// @notice sets a new withdrawal limit as the current limit for a certain user. Resets decay limit to 0
    /// @param user_ user address for which to update the withdrawal limit
    /// @param token_ token address for which to update the withdrawal limit
    /// @param newLimit_ new limit until which user supply can decrease to.
    ///                  Important: input in raw. Must account for exchange price in input param calculation.
    ///                  Note any limit that is < max expansion or > current user supply will set max expansion limit or
    ///                  current user supply as limit respectively.
    ///                  - set 0 to make maximum possible withdrawable: instant full expansion, and if that goes
    ///                  below base limit then fully down to 0.
    ///                  - set type(uint256).max to make current withdrawable 0 (sets current user supply as limit).
    function updateUserWithdrawalLimit(address user_, address token_, uint256 newLimit_) external;

    /// @notice setting user borrow configs per token basis. Eg: with interest or interest-free and automated limits.
    ///         Only callable by Auths.
    /// @param userBorrowConfigs_ struct array containing user borrow config, see `UserBorrowConfig` struct for more info
    function updateUserBorrowConfigs(AdminModuleStructs.UserBorrowConfig[] memory userBorrowConfigs_) external;

    /// @notice pause operations for a particular user in class 0 (class 1 users can't be paused by guardians).
    /// Only callable by Guardians.
    /// @param user_          address of user to pause operations for
    /// @param supplyTokens_  token addresses to pause withdrawals for
    /// @param borrowTokens_  token addresses to pause borrowings for
    function pauseUser(address user_, address[] calldata supplyTokens_, address[] calldata borrowTokens_) external;

    /// @notice unpause operations for a particular user in class 0 (class 1 users can't be paused by guardians).
    /// Only callable by Guardians.
    /// @param user_          address of user to unpause operations for
    /// @param supplyTokens_  token addresses to unpause withdrawals for
    /// @param borrowTokens_  token addresses to unpause borrowings for
    function unpauseUser(address user_, address[] calldata supplyTokens_, address[] calldata borrowTokens_) external;

    /// @notice pause all operations for the given tokens by setting bit 255 of exchangePricesAndConfig.
    /// Only callable by Guardians.
    /// @param tokens_ token addresses to pause
    function pauseTokens(address[] calldata tokens_) external;

    /// @notice unpause operations for the given tokens by clearing bit 255 of exchangePricesAndConfig.
    /// Only callable by Guardians.
    /// @param tokens_ token addresses to unpause
    function unpauseTokens(address[] calldata tokens_) external;

    /// @notice         collects revenue for tokens to configured revenueCollector address.
    /// @param tokens_  array of tokens to collect revenue for
    /// @dev            Note that this can revert if token balance is < revenueAmount (utilization > 100%)
    function collectRevenue(address[] calldata tokens_) external;

    /// @notice gets the current updated exchange prices for n tokens and updates all prices, rates related data in storage.
    /// @param tokens_ tokens to update exchange prices for
    /// @return supplyExchangePrices_ new supply rates of overall system for each token
    /// @return borrowExchangePrices_ new borrow rates of overall system for each token
    function updateExchangePrices(
        address[] calldata tokens_
    ) external returns (uint256[] memory supplyExchangePrices_, uint256[] memory borrowExchangePrices_);
}

interface IFluidLiquidityLogic is IFluidLiquidityAdmin {
    /// @notice Single function which handles supply, withdraw, borrow & payback
    /// @param token_ address of token (0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE for native)
    /// @param supplyAmount_ if +ve then supply, if -ve then withdraw, if 0 then nothing
    /// @param borrowAmount_ if +ve then borrow, if -ve then payback, if 0 then nothing
    /// @param withdrawTo_ if withdrawal then to which address
    /// @param borrowTo_ if borrow then to which address
    /// @param callbackData_ callback data passed to `liquidityCallback` method of protocol
    /// @return memVar3_ updated supplyExchangePrice
    /// @return memVar4_ updated borrowExchangePrice
    /// @dev to trigger skipping in / out transfers (gas optimization):
    /// -  ` callbackData_` MUST be encoded so that "from" address is the last 20 bytes in the last 32 bytes slot,
    ///     also for native token operations where liquidityCallback is not triggered!
    ///     from address must come at last position if there is more data. I.e. encode like:
    ///     abi.encode(otherVar1, otherVar2, FROM_ADDRESS). Note dynamic types used with abi.encode come at the end
    ///     so if dynamic types are needed, you must use abi.encodePacked to ensure the from address is at the end.
    /// -   this "from" address must match withdrawTo_ or borrowTo_ and must be == `msg.sender`
    /// -   `callbackData_` must in addition to the from address as described above include bytes32 SKIP_TRANSFERS
    ///     in the slot before (bytes 32 to 63)
    /// -   `msg.value` must be 0.
    /// -   Amounts must be either:
    ///     -  supply(+) == borrow(+), withdraw(-) == payback(-).
    ///     -  Liquidity must be on the winning side (deposit < borrow OR payback < withdraw).
    function operate(
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_,
        address withdrawTo_,
        address borrowTo_,
        bytes calldata callbackData_
    ) external payable returns (uint256 memVar3_, uint256 memVar4_);

    /// @notice Same as `operate` but executes against `onBehalf_`'s position instead of msg.sender's.
    ///         Only callable by auths or governance. Token transfers still come from msg.sender:
    ///         native token uses msg.value, while ERC20 still pulls funds via msg.sender.liquidityCallback().
    ///         Only supply (+ve supplyAmount) and payback (-ve borrowAmount) are allowed; no withdrawals or borrows.
    ///         Bypasses user pause status: deposits and paybacks can be made even when the target user is paused.
    /// @param onBehalf_ the address (protocol) whose position to operate on. Must be != address(0)
    ///                   and must have a configured position (via admin) for the given token.
    /// @param token_ address of token (0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE for native)
    /// @param supplyAmount_ if +ve then supply, if 0 then nothing. Must be >= 0.
    /// @param borrowAmount_ if -ve then payback, if 0 then nothing. Must be <= 0.
    ///                      At least one of supplyAmount_ or borrowAmount_ must be non-zero.
    /// @param callbackData_ must be empty (length 0). Custom callbackData-powered transfer shortcuts like
    ///                      SKIP_TRANSFERS / NET_TRANSFERS are not supported for onBehalfOf.
    /// @return memVar3_ updated supplyExchangePrice
    /// @return memVar4_ updated borrowExchangePrice
    function operateOnBehalfOf(
        address onBehalf_,
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_,
        bytes calldata callbackData_
    ) external payable returns (uint256 memVar3_, uint256 memVar4_);
}

interface IFluidLiquidity is IProxy, IFluidLiquidityLogic {}

// File: contracts/liquidity/dummyImpl.sol

pragma solidity >=0.8.21 <=0.8.29;




/// @notice Liquidity dummy implementation used for Fluid Liquidity infinite proxy.
/// @dev see https://github.com/Instadapp/infinite-proxy?tab=readme-ov-file#dummy-implementation
contract FluidLiquidityDummyImpl is IFluidLiquidityLogic {
    /// @inheritdoc IFluidLiquidityAdmin
    function updateAuths(AdminModuleStructs.AddressBool[] calldata authsStatus_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateGuardians(AdminModuleStructs.AddressBool[] calldata guardiansStatus_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateRevenueCollector(address revenueCollector_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function changeStatus(uint256 newStatus_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateRateDataV1s(AdminModuleStructs.RateDataV1Params[] calldata tokensRateData_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateRateDataV2s(AdminModuleStructs.RateDataV2Params[] calldata tokensRateData_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateTokenConfigs(AdminModuleStructs.TokenConfig[] calldata tokenConfigs_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateUserClasses(AdminModuleStructs.AddressUint256[] calldata userClasses_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateUserSupplyConfigs(AdminModuleStructs.UserSupplyConfig[] memory userSupplyConfigs_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateUserWithdrawalLimit(address user_, address token_, uint256 newLimit_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateUserBorrowConfigs(AdminModuleStructs.UserBorrowConfig[] memory userBorrowConfigs_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function pauseUser(address user_, address[] calldata supplyTokens_, address[] calldata borrowTokens_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function unpauseUser(address user_, address[] calldata supplyTokens_, address[] calldata borrowTokens_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function pauseTokens(address[] calldata tokens_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function unpauseTokens(address[] calldata tokens_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function collectRevenue(address[] calldata tokens_) external {}

    /// @inheritdoc IFluidLiquidityAdmin
    function updateExchangePrices(
        address[] calldata tokens_
    ) external returns (uint256[] memory supplyExchangePrices_, uint256[] memory borrowExchangePrices_) {}

    /// @inheritdoc IFluidLiquidityLogic
    function operate(
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_,
        address withdrawTo_,
        address borrowTo_,
        bytes calldata callbackData_
    ) external payable returns (uint256 memVar3_, uint256 memVar4_) {}

    /// @inheritdoc IFluidLiquidityLogic
    function operateOnBehalfOf(
        address onBehalf_,
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_,
        bytes calldata callbackData_
    ) external payable returns (uint256 memVar3_, uint256 memVar4_) {}
}
