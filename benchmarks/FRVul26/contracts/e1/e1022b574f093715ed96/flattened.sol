// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/ethereum-vault-connector/src/interfaces/IVault.sol

pragma solidity >=0.8.0;

/// @title IVault
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This interface defines the methods for the Vault for the purpose of integration with the Ethereum Vault
/// Connector.
interface IVault {
    /// @notice Disables a controller (this vault) for the authenticated account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults. User calls this function in order for the vault to disable itself
    /// for the account if the conditions are met (i.e. user has repaid debt in full). If the conditions are not met,
    /// the function reverts.
    function disableController() external;

    /// @notice Checks the status of an account.
    /// @dev This function must only deliberately revert if the account status is invalid. If this function reverts due
    /// to any other reason, it may render the account unusable with possibly no way to recover funds.
    /// @param account The address of the account to be checked.
    /// @param collaterals The array of enabled collateral addresses to be considered for the account status check.
    /// @return magicValue Must return the bytes4 magic value 0xb168c58f (which is a selector of this function) when
    /// account status is valid, or revert otherwise.
    function checkAccountStatus(
        address account,
        address[] calldata collaterals
    ) external view returns (bytes4 magicValue);

    /// @notice Checks the status of the vault.
    /// @dev This function must only deliberately revert if the vault status is invalid. If this function reverts due to
    /// any other reason, it may render some accounts unusable with possibly no way to recover funds.
    /// @return magicValue Must return the bytes4 magic value 0x4b3d1223 (which is a selector of this function) when
    /// account status is valid, or revert otherwise.
    function checkVaultStatus() external returns (bytes4 magicValue);
}

// File: lib/euler-vault-kit/src/EVault/IEVault.sol

pragma solidity >=0.8.0;



// Full interface of EVault and all it's modules

/// @title IInitialize
/// @notice Interface of the initialization module of EVault
interface IInitialize {
    /// @notice Initialization of the newly deployed proxy contract
    /// @param proxyCreator Account which created the proxy or should be the initial governor
    function initialize(address proxyCreator) external;
}

/// @title IERC20
/// @notice Interface of the EVault's Initialize module
interface IERC20 {
    /// @notice Vault share token (eToken) name, ie "Euler Vault: DAI"
    /// @return The name of the eToken
    function name() external view returns (string memory);

    /// @notice Vault share token (eToken) symbol, ie "eDAI"
    /// @return The symbol of the eToken
    function symbol() external view returns (string memory);

    /// @notice Decimals, the same as the asset's or 18 if the asset doesn't implement `decimals()`
    /// @return The decimals of the eToken
    function decimals() external view returns (uint8);

    /// @notice Sum of all eToken balances
    /// @return The total supply of the eToken
    function totalSupply() external view returns (uint256);

    /// @notice Balance of a particular account, in eTokens
    /// @param account Address to query
    /// @return The balance of the account
    function balanceOf(address account) external view returns (uint256);

    /// @notice Retrieve the current allowance
    /// @param holder The account holding the eTokens
    /// @param spender Trusted address
    /// @return The allowance from holder for spender
    function allowance(address holder, address spender) external view returns (uint256);

    /// @notice Transfer eTokens to another address
    /// @param to Recipient account
    /// @param amount In shares.
    /// @return True if transfer succeeded
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Transfer eTokens from one address to another
    /// @param from This address must've approved the to address
    /// @param to Recipient account
    /// @param amount In shares
    /// @return True if transfer succeeded
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Allow spender to access an amount of your eTokens
    /// @param spender Trusted address
    /// @param amount Use max uint for "infinite" allowance
    /// @return True if approval succeeded
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @title IToken
/// @notice Interface of the EVault's Token module
interface IToken is IERC20 {
    /// @notice Transfer the full eToken balance of an address to another
    /// @param from This address must've approved the to address
    /// @param to Recipient account
    /// @return True if transfer succeeded
    function transferFromMax(address from, address to) external returns (bool);
}

/// @title IERC4626
/// @notice Interface of an ERC4626 vault
interface IERC4626 {
    /// @notice Vault's underlying asset
    /// @return The vault's underlying asset
    function asset() external view returns (address);

    /// @notice Total amount of managed assets, cash and borrows
    /// @return The total amount of assets
    function totalAssets() external view returns (uint256);

    /// @notice Calculate amount of assets corresponding to the requested shares amount
    /// @param shares Amount of shares to convert
    /// @return The amount of assets
    function convertToAssets(uint256 shares) external view returns (uint256);

    /// @notice Calculate amount of shares corresponding to the requested assets amount
    /// @param assets Amount of assets to convert
    /// @return The amount of shares
    function convertToShares(uint256 assets) external view returns (uint256);

    /// @notice Fetch the maximum amount of assets a user can deposit
    /// @param account Address to query
    /// @return The max amount of assets the account can deposit
    function maxDeposit(address account) external view returns (uint256);

    /// @notice Calculate an amount of shares that would be created by depositing assets
    /// @param assets Amount of assets deposited
    /// @return Amount of shares received
    function previewDeposit(uint256 assets) external view returns (uint256);

    /// @notice Fetch the maximum amount of shares a user can mint
    /// @param account Address to query
    /// @return The max amount of shares the account can mint
    function maxMint(address account) external view returns (uint256);

    /// @notice Calculate an amount of assets that would be required to mint requested amount of shares
    /// @param shares Amount of shares to be minted
    /// @return Required amount of assets
    function previewMint(uint256 shares) external view returns (uint256);

    /// @notice Fetch the maximum amount of assets a user is allowed to withdraw
    /// @param owner Account holding the shares
    /// @return The maximum amount of assets the owner is allowed to withdraw
    function maxWithdraw(address owner) external view returns (uint256);

    /// @notice Calculate the amount of shares that will be burned when withdrawing requested amount of assets
    /// @param assets Amount of assets withdrawn
    /// @return Amount of shares burned
    function previewWithdraw(uint256 assets) external view returns (uint256);

    /// @notice Fetch the maximum amount of shares a user is allowed to redeem for assets
    /// @param owner Account holding the shares
    /// @return The maximum amount of shares the owner is allowed to redeem
    function maxRedeem(address owner) external view returns (uint256);

    /// @notice Calculate the amount of assets that will be transferred when redeeming requested amount of shares
    /// @param shares Amount of shares redeemed
    /// @return Amount of assets transferred
    function previewRedeem(uint256 shares) external view returns (uint256);

    /// @notice Transfer requested amount of underlying tokens from sender to the vault pool in return for shares
    /// @param amount Amount of assets to deposit (use max uint256 for full underlying token balance)
    /// @param receiver An account to receive the shares
    /// @return Amount of shares minted
    /// @dev Deposit will round down the amount of assets that are converted to shares. To prevent losses consider using
    /// mint instead.
    function deposit(uint256 amount, address receiver) external returns (uint256);

    /// @notice Transfer underlying tokens from sender to the vault pool in return for requested amount of shares
    /// @param amount Amount of shares to be minted
    /// @param receiver An account to receive the shares
    /// @return Amount of assets deposited
    function mint(uint256 amount, address receiver) external returns (uint256);

    /// @notice Transfer requested amount of underlying tokens from the vault and decrease account's shares balance
    /// @param amount Amount of assets to withdraw
    /// @param receiver Account to receive the withdrawn assets
    /// @param owner Account holding the shares to burn
    /// @return Amount of shares burned
    function withdraw(uint256 amount, address receiver, address owner) external returns (uint256);

    /// @notice Burn requested shares and transfer corresponding underlying tokens from the vault to the receiver
    /// @param amount Amount of shares to burn (use max uint256 to burn full owner balance)
    /// @param receiver Account to receive the withdrawn assets
    /// @param owner Account holding the shares to burn.
    /// @return Amount of assets transferred
    function redeem(uint256 amount, address receiver, address owner) external returns (uint256);
}

/// @title IVault
/// @notice Interface of the EVault's Vault module
interface IVault is IERC4626 {
    /// @notice Balance of the fees accumulator, in shares
    /// @return The accumulated fees in shares
    function accumulatedFees() external view returns (uint256);

    /// @notice Balance of the fees accumulator, in underlying units
    /// @return The accumulated fees in asset units
    function accumulatedFeesAssets() external view returns (uint256);

    /// @notice Address of the original vault creator
    /// @return The address of the creator
    function creator() external view returns (address);

    /// @notice Creates shares for the receiver, from excess asset balances of the vault (not accounted for in `cash`)
    /// @param amount Amount of assets to claim (use max uint256 to claim all available assets)
    /// @param receiver An account to receive the shares
    /// @return Amount of shares minted
    /// @dev Could be used as an alternative deposit flow in certain scenarios. E.g. swap directly to the vault, call
    /// `skim` to claim deposit.
    function skim(uint256 amount, address receiver) external returns (uint256);
}

/// @title IBorrowing
/// @notice Interface of the EVault's Borrowing module
interface IBorrowing {
    /// @notice Sum of all outstanding debts, in underlying units (increases as interest is accrued)
    /// @return The total borrows in asset units
    function totalBorrows() external view returns (uint256);

    /// @notice Sum of all outstanding debts, in underlying units scaled up by shifting
    /// INTERNAL_DEBT_PRECISION_SHIFT bits
    /// @return The total borrows in internal debt precision
    function totalBorrowsExact() external view returns (uint256);

    /// @notice Balance of vault assets as tracked by deposits/withdrawals and borrows/repays
    /// @return The amount of assets the vault tracks as current direct holdings
    function cash() external view returns (uint256);

    /// @notice Debt owed by a particular account, in underlying units
    /// @param account Address to query
    /// @return The debt of the account in asset units
    function debtOf(address account) external view returns (uint256);

    /// @notice Debt owed by a particular account, in underlying units scaled up by shifting
    /// INTERNAL_DEBT_PRECISION_SHIFT bits
    /// @param account Address to query
    /// @return The debt of the account in internal precision
    function debtOfExact(address account) external view returns (uint256);

    /// @notice Retrieves the current interest rate for an asset
    /// @return The interest rate in yield-per-second, scaled by 10**27
    function interestRate() external view returns (uint256);

    /// @notice Retrieves the current interest rate accumulator for an asset
    /// @return An opaque accumulator that increases as interest is accrued
    function interestAccumulator() external view returns (uint256);

    /// @notice Returns an address of the sidecar DToken
    /// @return The address of the DToken
    function dToken() external view returns (address);

    /// @notice Transfer underlying tokens from the vault to the sender, and increase sender's debt
    /// @param amount Amount of assets to borrow (use max uint256 for all available tokens)
    /// @param receiver Account receiving the borrowed tokens
    /// @return Amount of assets borrowed
    function borrow(uint256 amount, address receiver) external returns (uint256);

    /// @notice Transfer underlying tokens from the sender to the vault, and decrease receiver's debt
    /// @param amount Amount of debt to repay in assets (use max uint256 for full debt)
    /// @param receiver Account holding the debt to be repaid
    /// @return Amount of assets repaid
    function repay(uint256 amount, address receiver) external returns (uint256);

    /// @notice Pay off liability with shares ("self-repay")
    /// @param amount In asset units (use max uint256 to repay the debt in full or up to the available deposit)
    /// @param receiver Account to remove debt from by burning sender's shares
    /// @return shares Amount of shares burned
    /// @return debt Amount of debt removed in assets
    /// @dev Equivalent to withdrawing and repaying, but no assets are needed to be present in the vault
    /// @dev Contrary to a regular `repay`, if account is unhealthy, the repay amount must bring the account back to
    /// health, or the operation will revert during account status check
    function repayWithShares(uint256 amount, address receiver) external returns (uint256 shares, uint256 debt);

    /// @notice Take over debt from another account
    /// @param amount Amount of debt in asset units (use max uint256 for all the account's debt)
    /// @param from Account to pull the debt from
    /// @dev Due to internal debt precision accounting, the liability reported on either or both accounts after
    /// calling `pullDebt` may not match the `amount` requested precisely
    function pullDebt(uint256 amount, address from) external;

    /// @notice Request a flash-loan. A onFlashLoan() callback in msg.sender will be invoked, which must repay the loan
    /// to the main Euler address prior to returning.
    /// @param amount In asset units
    /// @param data Passed through to the onFlashLoan() callback, so contracts don't need to store transient data in
    /// storage
    function flashLoan(uint256 amount, bytes calldata data) external;

    /// @notice Updates interest accumulator and totalBorrows, credits reserves, re-targets interest rate, and logs
    /// vault status
    function touch() external;
}

/// @title ILiquidation
/// @notice Interface of the EVault's Liquidation module
interface ILiquidation {
    /// @notice Checks to see if a liquidation would be profitable, without actually doing anything
    /// @param liquidator Address that will initiate the liquidation
    /// @param violator Address that may be in collateral violation
    /// @param collateral Collateral which is to be seized
    /// @return maxRepay Max amount of debt that can be repaid, in asset units
    /// @return maxYield Yield in collateral corresponding to max allowed amount of debt to be repaid, in collateral
    /// balance (shares for vaults)
    function checkLiquidation(address liquidator, address violator, address collateral)
        external
        view
        returns (uint256 maxRepay, uint256 maxYield);

    /// @notice Attempts to perform a liquidation
    /// @param violator Address that may be in collateral violation
    /// @param collateral Collateral which is to be seized
    /// @param repayAssets The amount of underlying debt to be transferred from violator to sender, in asset units (use
    /// max uint256 to repay the maximum possible amount). Meant as slippage check together with `minYieldBalance`
    /// @param minYieldBalance The minimum acceptable amount of collateral to be transferred from violator to sender, in
    /// collateral balance units (shares for vaults).  Meant as slippage check together with `repayAssets`
    /// @dev If `repayAssets` is set to max uint256 it is assumed the caller will perform their own slippage checks to
    /// make sure they are not taking on too much debt. This option is mainly meant for smart contract liquidators
    function liquidate(address violator, address collateral, uint256 repayAssets, uint256 minYieldBalance) external;
}

/// @title IRiskManager
/// @notice Interface of the EVault's RiskManager module
interface IRiskManager is IEVCVault {
    /// @notice Retrieve account's total liquidity
    /// @param account Account holding debt in this vault
    /// @param liquidation Flag to indicate if the calculation should be performed in liquidation vs account status
    /// check mode, where different LTV values might apply.
    /// @return collateralValue Total risk adjusted value of all collaterals in unit of account
    /// @return liabilityValue Value of debt in unit of account
    function accountLiquidity(address account, bool liquidation)
        external
        view
        returns (uint256 collateralValue, uint256 liabilityValue);

    /// @notice Retrieve account's liquidity per collateral
    /// @param account Account holding debt in this vault
    /// @param liquidation Flag to indicate if the calculation should be performed in liquidation vs account status
    /// check mode, where different LTV values might apply.
    /// @return collaterals Array of collaterals enabled
    /// @return collateralValues Array of risk adjusted collateral values corresponding to items in collaterals array.
    /// In unit of account
    /// @return liabilityValue Value of debt in unit of account
    function accountLiquidityFull(address account, bool liquidation)
        external
        view
        returns (address[] memory collaterals, uint256[] memory collateralValues, uint256 liabilityValue);

    /// @notice Release control of the account on EVC if no outstanding debt is present
    function disableController() external;

    /// @notice Checks the status of an account and reverts if account is not healthy
    /// @param account The address of the account to be checked
    /// @return magicValue Must return the bytes4 magic value 0xb168c58f (which is a selector of this function) when
    /// account status is valid, or revert otherwise.
    /// @dev Only callable by EVC during status checks
    function checkAccountStatus(address account, address[] calldata collaterals) external view returns (bytes4);

    /// @notice Checks the status of the vault and reverts if caps are exceeded
    /// @return magicValue Must return the bytes4 magic value 0x4b3d1223 (which is a selector of this function) when
    /// account status is valid, or revert otherwise.
    /// @dev Only callable by EVC during status checks
    function checkVaultStatus() external returns (bytes4);
}

/// @title IBalanceForwarder
/// @notice Interface of the EVault's BalanceForwarder module
interface IBalanceForwarder {
    /// @notice Retrieve the address of rewards contract, tracking changes in account's balances
    /// @return The balance tracker address
    function balanceTrackerAddress() external view returns (address);

    /// @notice Retrieves boolean indicating if the account opted in to forward balance changes to the rewards contract
    /// @param account Address to query
    /// @return True if balance forwarder is enabled
    function balanceForwarderEnabled(address account) external view returns (bool);

    /// @notice Enables balance forwarding for the authenticated account
    /// @dev Only the authenticated account can enable balance forwarding for itself
    /// @dev Should call the IBalanceTracker hook with the current account's balance
    function enableBalanceForwarder() external;

    /// @notice Disables balance forwarding for the authenticated account
    /// @dev Only the authenticated account can disable balance forwarding for itself
    /// @dev Should call the IBalanceTracker hook with the account's balance of 0
    function disableBalanceForwarder() external;
}

/// @title IGovernance
/// @notice Interface of the EVault's Governance module
interface IGovernance {
    /// @notice Retrieves the address of the governor
    /// @return The governor address
    function governorAdmin() external view returns (address);

    /// @notice Retrieves address of the governance fee receiver
    /// @return The fee receiver address
    function feeReceiver() external view returns (address);

    /// @notice Retrieves the interest fee in effect for the vault
    /// @return Amount of interest that is redirected as a fee, as a fraction scaled by 1e4
    function interestFee() external view returns (uint16);

    /// @notice Looks up an asset's currently configured interest rate model
    /// @return Address of the interest rate contract or address zero to indicate 0% interest
    function interestRateModel() external view returns (address);

    /// @notice Retrieves the ProtocolConfig address
    /// @return The protocol config address
    function protocolConfigAddress() external view returns (address);

    /// @notice Retrieves the protocol fee share
    /// @return A percentage share of fees accrued belonging to the protocol, in 1e4 scale
    function protocolFeeShare() external view returns (uint256);

    /// @notice Retrieves the address which will receive protocol's fees
    /// @notice The protocol fee receiver address
    function protocolFeeReceiver() external view returns (address);

    /// @notice Retrieves supply and borrow caps in AmountCap format
    /// @return supplyCap The supply cap in AmountCap format
    /// @return borrowCap The borrow cap in AmountCap format
    function caps() external view returns (uint16 supplyCap, uint16 borrowCap);

    /// @notice Retrieves the borrow LTV of the collateral, which is used to determine if the account is healthy during
    /// account status checks.
    /// @param collateral The address of the collateral to query
    /// @return Borrowing LTV in 1e4 scale
    function LTVBorrow(address collateral) external view returns (uint16);

    /// @notice Retrieves the current liquidation LTV, which is used to determine if the account is eligible for
    /// liquidation
    /// @param collateral The address of the collateral to query
    /// @return Liquidation LTV in 1e4 scale
    function LTVLiquidation(address collateral) external view returns (uint16);

    /// @notice Retrieves LTV configuration for the collateral
    /// @param collateral Collateral asset
    /// @return borrowLTV The current value of borrow LTV for originating positions
    /// @return liquidationLTV The value of fully converged liquidation LTV
    /// @return initialLiquidationLTV The initial value of the liquidation LTV, when the ramp began
    /// @return targetTimestamp The timestamp when the liquidation LTV is considered fully converged
    /// @return rampDuration The time it takes for the liquidation LTV to converge from the initial value to the fully
    /// converged value
    function LTVFull(address collateral)
        external
        view
        returns (
            uint16 borrowLTV,
            uint16 liquidationLTV,
            uint16 initialLiquidationLTV,
            uint48 targetTimestamp,
            uint32 rampDuration
        );

    /// @notice Retrieves a list of collaterals with configured LTVs
    /// @return List of asset collaterals
    /// @dev Returned assets could have the ltv disabled (set to zero)
    function LTVList() external view returns (address[] memory);

    /// @notice Retrieves the maximum liquidation discount
    /// @return The maximum liquidation discount in 1e4 scale
    /// @dev The default value, which is zero, is deliberately bad, as it means there would be no incentive to liquidate
    /// unhealthy users. The vault creator must take care to properly select the limit, given the underlying and
    /// collaterals used.
    function maxLiquidationDiscount() external view returns (uint16);

    /// @notice Retrieves liquidation cool-off time, which must elapse after successful account status check before
    /// account can be liquidated
    /// @return The liquidation cool off time in seconds
    function liquidationCoolOffTime() external view returns (uint16);

    /// @notice Retrieves a hook target and a bitmask indicating which operations call the hook target
    /// @return hookTarget Address of the hook target contract
    /// @return hookedOps Bitmask with operations that should call the hooks. See Constants.sol for a list of operations
    function hookConfig() external view returns (address hookTarget, uint32 hookedOps);

    /// @notice Retrieves a bitmask indicating enabled config flags
    /// @return Bitmask with config flags enabled
    function configFlags() external view returns (uint32);

    /// @notice Address of EthereumVaultConnector contract
    /// @return The EVC address
    function EVC() external view returns (address);

    /// @notice Retrieves a reference asset used for liquidity calculations
    /// @return The address of the reference asset
    function unitOfAccount() external view returns (address);

    /// @notice Retrieves the address of the oracle contract
    /// @return The address of the oracle
    function oracle() external view returns (address);

    /// @notice Retrieves the Permit2 contract address
    /// @return The address of the Permit2 contract
    function permit2Address() external view returns (address);

    /// @notice Splits accrued fees balance according to protocol fee share and transfers shares to the governor fee
    /// receiver and protocol fee receiver
    function convertFees() external;

    /// @notice Set a new governor address
    /// @param newGovernorAdmin The new governor address
    /// @dev Set to zero address to renounce privileges and make the vault non-governed
    function setGovernorAdmin(address newGovernorAdmin) external;

    /// @notice Set a new governor fee receiver address
    /// @param newFeeReceiver The new fee receiver address
    function setFeeReceiver(address newFeeReceiver) external;

    /// @notice Set a new LTV config
    /// @param collateral Address of collateral to set LTV for
    /// @param borrowLTV New borrow LTV, for assessing account's health during account status checks, in 1e4 scale
    /// @param liquidationLTV New liquidation LTV after ramp ends in 1e4 scale
    /// @param rampDuration Ramp duration in seconds
    function setLTV(address collateral, uint16 borrowLTV, uint16 liquidationLTV, uint32 rampDuration) external;

    /// @notice Set a new maximum liquidation discount
    /// @param newDiscount New maximum liquidation discount in 1e4 scale
    /// @dev If the discount is zero (the default), the liquidators will not be incentivized to liquidate unhealthy
    /// accounts
    function setMaxLiquidationDiscount(uint16 newDiscount) external;

    /// @notice Set a new liquidation cool off time, which must elapse after successful account status check before
    /// account can be liquidated
    /// @param newCoolOffTime The new liquidation cool off time in seconds
    /// @dev Setting cool off time to zero allows liquidating the account in the same block as the last successful
    /// account status check
    function setLiquidationCoolOffTime(uint16 newCoolOffTime) external;

    /// @notice Set a new interest rate model contract
    /// @param newModel The new IRM address
    /// @dev If the new model reverts, perhaps due to governor error, the vault will silently use a zero interest
    /// rate. Governor should make sure the new interest rates are computed as expected.
    function setInterestRateModel(address newModel) external;

    /// @notice Set a new hook target and a new bitmap indicating which operations should call the hook target.
    /// Operations are defined in Constants.sol.
    /// @param newHookTarget The new hook target address. Use address(0) to simply disable hooked operations
    /// @param newHookedOps Bitmask with the new hooked operations
    /// @dev All operations are initially disabled in a newly created vault. The vault creator must set their
    /// own configuration to make the vault usable
    function setHookConfig(address newHookTarget, uint32 newHookedOps) external;

    /// @notice Set new bitmap indicating which config flags should be enabled. Flags are defined in Constants.sol
    /// @param newConfigFlags Bitmask with the new config flags
    function setConfigFlags(uint32 newConfigFlags) external;

    /// @notice Set new supply and borrow caps in AmountCap format
    /// @param supplyCap The new supply cap in AmountCap fromat
    /// @param borrowCap The new borrow cap in AmountCap fromat
    function setCaps(uint16 supplyCap, uint16 borrowCap) external;

    /// @notice Set a new interest fee
    /// @param newFee The new interest fee
    function setInterestFee(uint16 newFee) external;
}

/// @title IEVault
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Interface of the EVault, an EVC enabled lending vault
interface IEVault is
    IInitialize,
    IToken,
    IVault,
    IBorrowing,
    ILiquidation,
    IRiskManager,
    IBalanceForwarder,
    IGovernance
{
    /// @notice Fetch address of the `Initialize` module
    function MODULE_INITIALIZE() external view returns (address);
    /// @notice Fetch address of the `Token` module
    function MODULE_TOKEN() external view returns (address);
    /// @notice Fetch address of the `Vault` module
    function MODULE_VAULT() external view returns (address);
    /// @notice Fetch address of the `Borrowing` module
    function MODULE_BORROWING() external view returns (address);
    /// @notice Fetch address of the `Liquidation` module
    function MODULE_LIQUIDATION() external view returns (address);
    /// @notice Fetch address of the `RiskManager` module
    function MODULE_RISKMANAGER() external view returns (address);
    /// @notice Fetch address of the `BalanceForwarder` module
    function MODULE_BALANCE_FORWARDER() external view returns (address);
    /// @notice Fetch address of the `Governance` module
    function MODULE_GOVERNANCE() external view returns (address);
}

// File: lib/euler-vault-kit/src/EVault/shared/Errors.sol

pragma solidity ^0.8.0;

/// @title Errors
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Contract implementing EVault's custom errors
contract Errors {
    error E_Initialized();
    error E_ProxyMetadata();
    error E_SelfTransfer();
    error E_InsufficientAllowance();
    error E_InsufficientCash();
    error E_InsufficientAssets();
    error E_InsufficientBalance();
    error E_InsufficientDebt();
    error E_FlashLoanNotRepaid();
    error E_Reentrancy();
    error E_OperationDisabled();
    error E_OutstandingDebt();
    error E_AmountTooLargeToEncode();
    error E_DebtAmountTooLargeToEncode();
    error E_RepayTooMuch();
    error E_TransientState();
    error E_SelfLiquidation();
    error E_ControllerDisabled();
    error E_CollateralDisabled();
    error E_ViolatorLiquidityDeferred();
    error E_LiquidationCoolOff();
    error E_ExcessiveRepayAmount();
    error E_MinYield();
    error E_BadAddress();
    error E_ZeroAssets();
    error E_ZeroShares();
    error E_Unauthorized();
    error E_CheckUnauthorized();
    error E_NotSupported();
    error E_EmptyError();
    error E_BadBorrowCap();
    error E_BadSupplyCap();
    error E_BadCollateral();
    error E_AccountLiquidity();
    error E_NoLiability();
    error E_NotController();
    error E_BadFee();
    error E_SupplyCapExceeded();
    error E_BorrowCapExceeded();
    error E_InvalidLTVAsset();
    error E_NoPriceOracle();
    error E_ConfigAmountTooLargeToEncode();
    error E_BadAssetReceiver();
    error E_BadSharesOwner();
    error E_BadSharesReceiver();
    error E_BadMaxLiquidationDiscount();
    error E_LTVBorrow();
    error E_LTVLiquidation();
    error E_NotHookTarget();
}

// File: lib/euler-vault-kit/src/EVault/shared/lib/RevertBytes.sol

pragma solidity ^0.8.0;



/// @title RevertBytes Library
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice The library provides a helper function for bubbling up errors
library RevertBytes {
    function revertBytes(bytes memory errMsg) internal pure {
        if (errMsg.length > 0) {
            assembly {
                revert(add(32, errMsg), mload(errMsg))
            }
        }

        revert Errors.E_EmptyError();
    }
}

// File: lib/euler-vault-kit/src/interfaces/IPermit2.sol

pragma solidity >=0.8.0;

/// @title IPermit2
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice A minimal interface of the Uniswap's Permit2 contract
interface IPermit2 {
    /// @notice Transfer tokens between two accounts
    /// @param from The account to send the tokens from
    /// @param to The account to send the tokens to
    /// @param amount Amount of tokens to send
    /// @param token Address of the token contract
    function transferFrom(address from, address to, uint160 amount, address token) external;
}

// File: lib/euler-vault-kit/src/EVault/shared/lib/SafeERC20Lib.sol

pragma solidity ^0.8.0;





/// @title SafeERC20Lib Library
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice The library provides helpers for ERC20 transfers, including Permit2 support
library SafeERC20Lib {
    error E_TransferFromFailed(bytes errorPermit2, bytes errorTransferFrom);

    // If no code exists under the token address, the function will succeed. EVault ensures this is not the case in
    // `initialize`.
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value)
        internal
        returns (bool, bytes memory)
    {
        (bool success, bytes memory data) = address(token).call(abi.encodeCall(IERC20.transferFrom, (from, to, value)));

        return isEmptyOrTrueReturn(success, data) ? (true, bytes("")) : (false, data);
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value, address permit2) internal {
        bool success;
        bytes memory permit2Data;
        bytes memory transferData;

        if (permit2 != address(0) && value <= type(uint160).max) {
            // it's safe to down-cast value to uint160
            (success, permit2Data) =
                permit2.call(abi.encodeCall(IPermit2.transferFrom, (from, to, uint160(value), address(token))));
        }

        if (!success) {
            (success, transferData) = trySafeTransferFrom(token, from, to, value);
        }

        if (!success) revert E_TransferFromFailed(permit2Data, transferData);
    }

    // If no code exists under the token address, the function will succeed. EVault ensures this is not the case in
    // `initialize`.
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeCall(IERC20.transfer, (to, value)));
        if (!isEmptyOrTrueReturn(success, data)) RevertBytes.revertBytes(data);
    }

    function isEmptyOrTrueReturn(bool callSuccess, bytes memory data) private pure returns (bool) {
        return callSuccess && (data.length == 0 || (data.length >= 32 && abi.decode(data, (bool))));
    }
}

// File: src/Swaps/ISwapper.sol

pragma solidity >=0.8.0;

/// @title ISwapper
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Interface of helper contracts, which handle swapping of assets for Euler Vault Kit
interface ISwapper {
    /// @title SwapParams
    /// @notice This struct holds all the parameters needed to carry out a swap
    struct SwapParams {
        // An id of the swap handler to use
        bytes32 handler;
        // Swap mode to execute
        // 0 - exact input swap
        // 1 - exect output swap
        // 2 - exact output swap and repay, targeting a debt amount of an account
        uint256 mode;
        // An EVC compatible account address, used e.g. as receiver of repay in swap and repay mode
        address account;
        // Sold asset
        address tokenIn;
        // Bought asset
        address tokenOut;
        // Vault to which the unused input in exact output swap will be deposited back
        address vaultIn;
        // An EVC compatible account address, to which the unused input in exact output swap will be deposited back
        address accountIn;
        // In swapping modes (0 and 1) - address of the intended recipient of the bought tokens
        // In swap and repay mode (2) - address of the liability vault of the account, where to repay debt
        // Note that if the swap uses off-chain encoded payload, the receiver might be ignored. The user
        // should verify the assets are in fact in the receiver address after the swap
        address receiver;
        // In exact input mode (0) - ignored
        // In exact output mode (1) - amount of `tokenOut` to buy
        // In swap and repay mode (2) - amount of debt the account should have after swap and repay.
        //    To repay all debt without leaving any dust, set this to zero.
        uint256 amountOut;
        // Auxiliary payload for swap providers. For GenericHandler it's an abi encoded tuple: target contract address
        // and call data
        bytes data;
    }

    /// @notice Execute a swap (and possibly repay or deposit) according to the SwapParams configuration
    /// @param params Configuration of the swap
    function swap(SwapParams calldata params) external;

    /// @notice Use the contract's token balance to repay debt of the account in a lending vault
    /// @param token The asset that is borrowed
    /// @param vault The lending vault where the debt is tracked
    /// @param repayAmount Amount of debt to repay
    /// @param account Receiver of the repay
    /// @dev If contract's balance is lower than requested repay amount, repay only the balance
    function repay(address token, address vault, uint256 repayAmount, address account) external;

    /// @notice Use the contract's token balance to repay debt of the account in a lending vault
    /// and deposit any remaining balance for the account in that same vault
    /// @param token The asset that is borrowed
    /// @param vault The lending vault where the debt is tracked
    /// @param repayAmount Amount of debt to repay
    /// @param account Receiver of the repay
    /// @dev If contract's balance is lower than requested repay amount, repay only the balance
    function repayAndDeposit(address token, address vault, uint256 repayAmount, address account) external;

    /// @notice Use all of the contract's token balance to execute a deposit for an account
    /// @param token Asset to deposit
    /// @param vault Vault to deposit the token to
    /// @param amountMin A minimum amount of tokens to deposit. If unavailable, the operation is a no-op
    /// @param account Receiver of the repay
    /// @dev Use amountMin to ignore dust
    function deposit(address token, address vault, uint256 amountMin, address account) external;

    /// @notice Transfer all tokens held by the contract
    /// @param token Token to transfer
    /// @param amountMin Minimum amount of tokens to transfer. If unavailable, the operation is a no-op
    /// @param to Address to send the tokens to
    function sweep(address token, uint256 amountMin, address to) external;

    /// @notice Call multiple functions of the contract
    /// @param calls Array of encoded payloads
    /// @dev Calls itself with regular external calls
    function multicall(bytes[] memory calls) external;
}

// File: src/Swaps/handlers/BaseHandler.sol

pragma solidity ^0.8.0;





/// @title BaseHandler
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Base contract for swap handlers - contracts interfacing with swap providers
abstract contract BaseHandler is ISwapper {
    // exact input swaps - unknown amount of tokens bought for exact amount of tokens sold
    uint256 internal constant MODE_EXACT_IN = 0;
    // exact output swaps - exact amount of tokens bought for unknown amount of tokens sold
    uint256 internal constant MODE_EXACT_OUT = 1;
    // target debt swap and repay - the amount requested is the debt amount the account should have after swap and repay
    uint256 internal constant MODE_TARGET_DEBT = 2;
    // swap modes delimiter
    uint256 internal constant MODE_MAX_VALUE = 3;

    error Swapper_UnsupportedMode();
    error Swapper_TargetDebt();
    error Swapper_SwapError(address swapProvider, bytes rawError);

    function resolveParams(SwapParams memory params) internal view returns (uint256 amountOut, address receiver) {
        amountOut = params.amountOut;
        receiver = params.receiver;

        if (params.mode == MODE_EXACT_IN) return (amountOut, receiver);

        uint256 balanceOut = IERC20(params.tokenOut).balanceOf(address(this));

        // for combined exact output swaps, which accumulate the output in the swapper, check how much is already
        // available
        if (params.mode == MODE_EXACT_OUT && params.receiver == address(this)) {
            unchecked {
                amountOut = balanceOut >= amountOut ? 0 : amountOut - balanceOut;
            }

            return (amountOut, receiver);
        }

        if (params.mode == MODE_TARGET_DEBT) {
            uint256 debt = IEVault(params.receiver).debtOf(params.account);

            // amountOut is the target debt
            if (amountOut > debt) revert Swapper_TargetDebt();

            unchecked {
                // reuse params.amountOut to hold repay
                amountOut = params.amountOut = debt - amountOut;

                // check if balance is already sufficient to repay
                amountOut = balanceOut >= amountOut ? 0 : amountOut - balanceOut;
            }

            // collect output in the swapper for repay
            receiver = address(this);
        }
    }

    function setMaxAllowance(address token, address spender) internal {
        safeApproveWithRetry(token, spender, type(uint256).max);
    }

    function trySafeApprove(address token, address to, uint256 value) internal returns (bool, bytes memory) {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))), data);
    }

    function safeApproveWithRetry(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = trySafeApprove(token, to, value);

        // some tokens, like USDT, require the allowance to be set to 0 first
        if (!success) {
            (success,) = trySafeApprove(token, to, 0);
            if (success) {
                (success,) = trySafeApprove(token, to, value);
            }
        }

        if (!success) RevertBytes.revertBytes(data);
    }
}

// File: src/Swaps/handlers/GenericHandler.sol

pragma solidity ^0.8.0;



/// @title GenericHandler
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Swap handler executing arbitrary trades on arbitrary target
abstract contract GenericHandler is BaseHandler {
    /// @dev the handler expects SwapParams.data to contain an abi encoded tuple: target contract address and call data
    function swapGeneric(SwapParams memory params) internal virtual {
        (address target, bytes memory payload) = abi.decode(params.data, (address, bytes));

        if (params.mode == MODE_TARGET_DEBT) resolveParams(params); // set repay amount in params.amountOut

        setMaxAllowance(params.tokenIn, target);

        (bool success, bytes memory result) = target.call(payload);
        if (!success) revert Swapper_SwapError(target, result);
    }
}

// File: src/Swaps/vendor/ISwapRouterV2.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface ISwapRouterV2 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: src/Swaps/handlers/UniswapV2Handler.sol

pragma solidity ^0.8.0;




/// @title UniswapV2Handler
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Swap handler executing exact output trades on Uniswap V2
abstract contract UniswapV2Handler is BaseHandler {
    address public immutable uniswapRouterV2;

    error UniswapV2Handler_InvalidPath();

    constructor(address _uniswapRouterV2) {
        uniswapRouterV2 = _uniswapRouterV2;
    }

    function swapUniswapV2(SwapParams memory params) internal virtual {
        if (params.mode == MODE_EXACT_IN) revert Swapper_UnsupportedMode();
        if (params.data.length < 64 || params.data.length % 32 != 0) revert UniswapV2Handler_InvalidPath();

        setMaxAllowance(params.tokenIn, uniswapRouterV2);
        // process params according to the mode and current state
        (uint256 amountOut, address receiver) = resolveParams(params);

        if (amountOut > 0) {
            (bool success, bytes memory result) = uniswapRouterV2.call(
                abi.encodeCall(
                    IUniswapV2Router01.swapTokensForExactTokens,
                    (amountOut, type(uint256).max, abi.decode(params.data, (address[])), receiver, block.timestamp)
                )
            );
            if (!success) revert Swapper_SwapError(uniswapRouterV2, result);
        }
    }
}

// File: src/Swaps/vendor/IUniswapV3SwapCallback.sol

pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
}

// File: src/Swaps/vendor/ISwapRouterV3.sol

pragma solidity >=0.7.5;
pragma abicoder v2;



/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouterV3 is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

// File: src/Swaps/handlers/UniswapV3Handler.sol

pragma solidity ^0.8.0;




/// @title UniswapV3Handler
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Swap handler executing exact output trades on Uniswap V3
abstract contract UniswapV3Handler is BaseHandler {
    address public immutable uniswapRouterV3;

    error UniswapV3Handler_InvalidPath();

    constructor(address _uniswapRouterV3) {
        uniswapRouterV3 = _uniswapRouterV3;
    }

    function swapUniswapV3(SwapParams memory params) internal virtual {
        if (params.mode == MODE_EXACT_IN) revert Swapper_UnsupportedMode();
        unchecked {
            if (params.data.length < 43 || (params.data.length - 20) % 23 != 0) revert UniswapV3Handler_InvalidPath();
        }

        setMaxAllowance(params.tokenIn, uniswapRouterV3);
        // update amountOut and receiver according to the mode and current state
        (uint256 amountOut, address receiver) = resolveParams(params);

        if (amountOut > 0) {
            (bool success, bytes memory result) = uniswapRouterV3.call(
                abi.encodeCall(
                    ISwapRouterV3.exactOutput,
                    ISwapRouterV3.ExactOutputParams({
                        path: params.data,
                        recipient: receiver,
                        amountOut: amountOut,
                        amountInMaximum: type(uint256).max,
                        deadline: block.timestamp
                    })
                )
            );
            if (!success) revert Swapper_SwapError(uniswapRouterV3, result);
        }
    }
}

// File: src/Swaps/Swapper.sol

pragma solidity ^0.8.0;











/// @title Swapper
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Untrusted helper contract for EVK for performing swaps and swaps to repay
contract Swapper is GenericHandler, UniswapV2Handler, UniswapV3Handler {
    bytes32 public constant HANDLER_GENERIC = bytes32("Generic");
    bytes32 public constant HANDLER_UNISWAP_V2 = bytes32("UniswapV2");
    bytes32 public constant HANDLER_UNISWAP_V3 = bytes32("UniswapV3");

    uint256 internal constant REENTRANCYLOCK_UNLOCKED = 1;
    uint256 internal constant REENTRANCYLOCK_LOCKED = 2;

    uint256 private reentrancyLock;

    error Swapper_UnknownMode();
    error Swapper_UnknownHandler();
    error Swapper_Reentrancy();

    // In the locked state, allow contract to call itself, but block all external calls
    modifier externalLock() {
        bool isExternal = msg.sender != address(this);

        if (isExternal) {
            if (reentrancyLock == REENTRANCYLOCK_LOCKED) revert Swapper_Reentrancy();
            reentrancyLock = REENTRANCYLOCK_LOCKED;
        }

        _;

        if (isExternal) reentrancyLock = REENTRANCYLOCK_UNLOCKED;
    }

    constructor(address uniswapRouterV2, address uniswapRouterV3)
        UniswapV2Handler(uniswapRouterV2)
        UniswapV3Handler(uniswapRouterV3)
    {}

    /// @inheritdoc ISwapper
    function swap(SwapParams memory params) public externalLock {
        if (params.mode >= MODE_MAX_VALUE) revert Swapper_UnknownMode();

        if (params.handler == HANDLER_GENERIC) {
            swapGeneric(params);
        } else if (params.handler == HANDLER_UNISWAP_V2) {
            swapUniswapV2(params);
        } else if (params.handler == HANDLER_UNISWAP_V3) {
            swapUniswapV3(params);
        } else {
            revert Swapper_UnknownHandler();
        }

        if (params.mode == MODE_EXACT_IN) return;

        // swapping to target debt is only useful for repaying
        if (params.mode == MODE_TARGET_DEBT) {
            // at this point amountOut holds the required repay amount
            _repayAndDeposit(params.tokenOut, params.receiver, params.amountOut, params.account);
        }

        // return unused input token after exact output swap
        _deposit(params.tokenIn, params.vaultIn, 0, params.accountIn);
    }

    /// @inheritdoc ISwapper
    /// @dev in case of over-swapping to repay, pass max uint amount
    function repay(address token, address vault, uint256 repayAmount, address account) public externalLock {
        setMaxAllowance(token, vault);
        uint256 balance = IERC20(token).balanceOf(address(this));
        repayAmount = _capRepayToBalance(repayAmount, balance);

        IEVault(vault).repay(repayAmount, account);
    }

    /// @inheritdoc ISwapper
    function repayAndDeposit(address token, address vault, uint256 repayAmount, address account) public externalLock {
        _repayAndDeposit(token, vault, repayAmount, account);
    }

    /// @inheritdoc ISwapper
    function deposit(address token, address vault, uint256 amountMin, address account) public externalLock {
        _deposit(token, vault, amountMin, account);
    }

    /// @inheritdoc ISwapper
    function sweep(address token, uint256 amountMin, address to) public externalLock {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance >= amountMin) {
            SafeERC20Lib.safeTransfer(IERC20(token), to, balance);
        }
    }

    /// @inheritdoc ISwapper
    function multicall(bytes[] memory calls) external externalLock {
        for (uint256 i; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).call(calls[i]);
            if (!success) RevertBytes.revertBytes(result);
        }
    }

    // internal

    function _deposit(address token, address vault, uint256 amountMin, address account) internal {
        setMaxAllowance(token, vault);
        uint256 balance = IERC20(token).balanceOf(address(this));

        if (balance >= amountMin) {
            IEVault(vault).deposit(balance, account);
        }
    }

    function _repayAndDeposit(address token, address vault, uint256 repayAmount, address account) internal {
        setMaxAllowance(token, vault);
        uint256 balance = IERC20(token).balanceOf(address(this));
        repayAmount = _capRepayToBalance(repayAmount, balance);

        repayAmount = IEVault(vault).repay(repayAmount, account);

        if (balance > repayAmount) {
            IEVault(vault).deposit(type(uint256).max, account);
        }
    }

    // Adjust repay to the available balance. It is needed when exact output swaps are not exact in reality.
    // It is user's responsibility to verify the debt is within accepted limits after the call to Swapper
    function _capRepayToBalance(uint256 repayAmount, uint256 balance) internal pure returns (uint256) {
        if (repayAmount != type(uint256).max && repayAmount > balance) {
            repayAmount = balance;
        }

        return repayAmount;
    }
}
