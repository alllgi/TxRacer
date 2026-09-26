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

// File: lib/euler-vault-kit/src/EVault/shared/types/LTVConfig.sol

pragma solidity ^0.8.0;



/// @title LTVConfig
/// @notice This packed struct is used to store LTV configuration of a collateral
struct LTVConfig {
    // Packed slot: 2 + 2 + 2 + 6 + 4 = 16
    // The value of borrow LTV for originating positions
    ConfigAmount borrowLTV;
    // The value of fully converged liquidation LTV
    ConfigAmount liquidationLTV;
    // The initial value of liquidation LTV, when the ramp began
    ConfigAmount initialLiquidationLTV;
    // The timestamp when the liquidation LTV is considered fully converged
    uint48 targetTimestamp;
    // The time it takes for the liquidation LTV to converge from the initial value to the fully converged value
    uint32 rampDuration;
}

/// @title LTVConfigLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Library for getting and setting the LTV configurations
library LTVConfigLib {
    // Is the collateral considered safe to liquidate
    function isRecognizedCollateral(LTVConfig memory self) internal pure returns (bool) {
        return self.targetTimestamp != 0;
    }

    // Get current LTV of the collateral. When liquidation LTV is lowered, it is ramped down to the target value over a
    // period of time.
    function getLTV(LTVConfig memory self, bool liquidation) internal view returns (ConfigAmount) {
        if (!liquidation) {
            return self.borrowLTV;
        }

        if (block.timestamp >= self.targetTimestamp || self.liquidationLTV >= self.initialLiquidationLTV) {
            return self.liquidationLTV;
        }

        uint256 currentLiquidationLTV = self.initialLiquidationLTV.toUint16();

        unchecked {
            uint256 targetLiquidationLTV = self.liquidationLTV.toUint16();
            uint256 timeRemaining = self.targetTimestamp - block.timestamp;

            // targetLiquidationLTV < initialLiquidationLTV and timeRemaining <= rampDuration
            currentLiquidationLTV = targetLiquidationLTV
                + (currentLiquidationLTV - targetLiquidationLTV) * timeRemaining / self.rampDuration;
        }

        // because ramping happens only when liquidation LTV decreases, it's safe to down-cast the new value
        return ConfigAmount.wrap(uint16(currentLiquidationLTV));
    }

    function setLTV(LTVConfig memory self, ConfigAmount borrowLTV, ConfigAmount liquidationLTV, uint32 rampDuration)
        internal
        view
        returns (LTVConfig memory newLTV)
    {
        newLTV.borrowLTV = borrowLTV;
        newLTV.liquidationLTV = liquidationLTV;
        newLTV.initialLiquidationLTV = self.getLTV(true);
        newLTV.targetTimestamp = uint48(block.timestamp + rampDuration);
        newLTV.rampDuration = rampDuration;
    }
}

using LTVConfigLib for LTVConfig global;

// File: lib/euler-vault-kit/src/EVault/shared/types/UserStorage.sol

pragma solidity ^0.8.0;



/// @dev Custom type for holding shares and debt balances of an account, packed with balance forwarder opt-in flag
type PackedUserSlot is uint256;

/// @title UserStorage
/// @notice This struct is used to store user account data
struct UserStorage {
    // Shares and debt balances, balance forwarder opt-in
    PackedUserSlot data;
    // Snapshot of the interest accumulator from the last change to account's liability
    uint256 interestAccumulator;
    // A mapping with allowances for the vault shares token (eToken)
    mapping(address spender => uint256 allowance) eTokenAllowance;
}

/// @title UserStorageLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Library for working with the UserStorage struct
library UserStorageLib {
    uint256 private constant BALANCE_FORWARDER_MASK = 0x8000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant OWED_MASK = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000;
    uint256 private constant SHARES_MASK = 0x000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant OWED_OFFSET = 112;

    function isBalanceForwarderEnabled(UserStorage storage self) internal view returns (bool) {
        return unpackBalanceForwarder(self.data);
    }

    function getOwed(UserStorage storage self) internal view returns (Owed) {
        return Owed.wrap(uint144((PackedUserSlot.unwrap(self.data) & OWED_MASK) >> OWED_OFFSET));
    }

    function getBalance(UserStorage storage self) internal view returns (Shares) {
        return unpackBalance(self.data);
    }

    function getBalanceAndBalanceForwarder(UserStorage storage self) internal view returns (Shares, bool) {
        PackedUserSlot data = self.data; // single SLOAD
        return (unpackBalance(data), unpackBalanceForwarder(data));
    }

    function setBalanceForwarder(UserStorage storage self, bool newValue) internal {
        uint256 data = PackedUserSlot.unwrap(self.data);

        uint256 newFlag = newValue ? BALANCE_FORWARDER_MASK : 0;
        self.data = PackedUserSlot.wrap(newFlag | (data & ~BALANCE_FORWARDER_MASK));
    }

    function setOwed(UserStorage storage self, Owed owed) internal {
        uint256 data = PackedUserSlot.unwrap(self.data);

        self.data = PackedUserSlot.wrap((owed.toUint() << OWED_OFFSET) | (data & ~OWED_MASK));
    }

    function setBalance(UserStorage storage self, Shares balance) internal {
        uint256 data = PackedUserSlot.unwrap(self.data);

        self.data = PackedUserSlot.wrap(balance.toUint() | (data & ~SHARES_MASK));
    }

    function unpackBalance(PackedUserSlot data) private pure returns (Shares) {
        return Shares.wrap(uint112(PackedUserSlot.unwrap(data) & SHARES_MASK));
    }

    function unpackBalanceForwarder(PackedUserSlot data) private pure returns (bool) {
        return (PackedUserSlot.unwrap(data) & BALANCE_FORWARDER_MASK) > 0;
    }
}

using UserStorageLib for UserStorage global;

// File: lib/euler-vault-kit/src/EVault/shared/types/VaultStorage.sol

pragma solidity ^0.8.0;





/// @title VaultStorage
/// @notice This struct is used to hold all of the vault's permanent storage
/// @dev Note that snapshots are not a part of this struct, as they might be reimplemented as transient storage
struct VaultStorage {
    // Packed slot 6 + 14 + 2 + 2 + 4 + 1 + 1 = 30
    // A timestamp of the last interest accumulator update
    uint48 lastInterestAccumulatorUpdate;
    // The amount of assets held directly by the vault
    Assets cash;
    // Current supply cap in asset units
    AmountCap supplyCap;
    // Current borrow cap in asset units
    AmountCap borrowCap;
    // A bitfield of operations which trigger a hook call
    Flags hookedOps;
    // A vault global reentrancy protection flag
    bool reentrancyLocked;
    // A flag indicating if the vault snapshot has already been initialized for the currently executing batch
    bool snapshotInitialized;

    // Packed slot 14 + 18 = 32
    // Sum of all user shares
    Shares totalShares;
    // Sum of all user debts
    Owed totalBorrows;

    // Packed slot 14 + 2 + 2 + 4 = 22
    // Interest fees accrued since the last fee conversion
    Shares accumulatedFees;
    // Maximum liquidation discount
    ConfigAmount maxLiquidationDiscount;
    // Amount of time in seconds that must pass after a successful account status check before liquidation is possible
    uint16 liquidationCoolOffTime;
    // A bitfield of vault configuration options
    Flags configFlags;

    // Current interest accumulator
    uint256 interestAccumulator;

    // Packed slot 20 + 2 + 9 = 31
    // Address of the interest rate model contract. If not set, 0% interest is applied
    address interestRateModel;
    // Percentage of accrued interest that is directed to fees
    ConfigAmount interestFee;
    // Current interest rate applied to outstanding borrows
    uint72 interestRate;

    // Name of the shares token (eToken)
    string name;
    // Symbol of the shares token (eToken)
    string symbol;

    // Address of the vault's creator
    address creator;

    // Address of the vault's governor
    address governorAdmin;
    // Address which receives governor fees
    address feeReceiver;
    // Address which will be called for enabled hooks
    address hookTarget;

    // User accounts
    mapping(address account => UserStorage) users;

    // LTV configuration for collaterals
    mapping(address collateral => LTVConfig) ltvLookup;
    // List of addresses which were at any point configured as collateral
    address[] ltvList;
}

// File: lib/euler-vault-kit/src/EVault/shared/types/Snapshot.sol

pragma solidity ^0.8.0;



/// @title Snapshot
/// @notice This struct is used to store a snapshot of the vault's cash and total borrows at the beginning of an
/// operation (or a batch thereof)
struct Snapshot {
    // Packed slot: 14 + 14 + 4 = 32
    // vault's cash holdings
    Assets cash;
    // vault's total borrows in assets, in regular precision
    Assets borrows;
    // stamp occupies the rest of the storage slot and makes sure the slot is non-zero for gas savings
    uint32 stamp;
}

/// @title SnapshotLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Library for working with the `Snapshot` struct
library SnapshotLib {
    uint32 private constant STAMP = 1; // non zero initial value of the snapshot slot to save gas on SSTORE

    function set(Snapshot storage self, Assets cash, Assets borrows) internal {
        self.cash = cash;
        self.borrows = borrows;
        self.stamp = STAMP;
    }

    function reset(Snapshot storage self) internal {
        self.set(Assets.wrap(0), Assets.wrap(0));
    }
}

using SnapshotLib for Snapshot global;

// File: lib/euler-vault-kit/src/interfaces/IPriceOracle.sol

pragma solidity >=0.8.0;

/// @title IPriceOracle
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Common PriceOracle interface.
interface IPriceOracle {
    /// @notice Get the name of the oracle.
    /// @return The name of the oracle.
    function name() external view returns (string memory);

    /// @notice One-sided price: How much quote token you would get for inAmount of base token, assuming no price
    /// spread.
    /// @param inAmount The amount of `base` to convert.
    /// @param base The token that is being priced.
    /// @param quote The token that is the unit of account.
    /// @return outAmount The amount of `quote` that is equivalent to `inAmount` of `base`.
    function getQuote(uint256 inAmount, address base, address quote) external view returns (uint256 outAmount);

    /// @notice Two-sided price: How much quote token you would get/spend for selling/buying inAmount of base token.
    /// @param inAmount The amount of `base` to convert.
    /// @param base The token that is being priced.
    /// @param quote The token that is the unit of account.
    /// @return bidOutAmount The amount of `quote` you would get for selling `inAmount` of `base`.
    /// @return askOutAmount The amount of `quote` you would spend for buying `inAmount` of `base`.
    function getQuotes(uint256 inAmount, address base, address quote)
        external
        view
        returns (uint256 bidOutAmount, uint256 askOutAmount);
}

// File: lib/euler-vault-kit/src/EVault/shared/types/VaultCache.sol

pragma solidity ^0.8.0;






/// @title VaultCache
/// @notice This struct is used to hold all the most often used vault data in memory
struct VaultCache {
    // Proxy immutables

    // Vault's asset
    IERC20 asset;
    // Vault's pricing oracle
    IPriceOracle oracle;
    // Unit of account is the asset in which collateral and liability values are expressed
    address unitOfAccount;

    // Vault data

    // A timestamp of the last interest accumulator update
    uint48 lastInterestAccumulatorUpdate;
    // The amount of assets held directly by the vault
    Assets cash;
    // Sum of all user debts
    Owed totalBorrows;
    // Sum of all user shares
    Shares totalShares;
    // Interest fees accrued since the last fee conversion
    Shares accumulatedFees;
    // Current interest accumulator
    uint256 interestAccumulator;

    // Vault config

    // Current supply cap in asset units
    uint256 supplyCap;
    // Current borrow cap in asset units
    uint256 borrowCap;
    // A bitfield of operations which trigger a hook call
    Flags hookedOps;
    // A bitfield of vault configuration options
    Flags configFlags;

    // Runtime

    // A flag indicating if the vault snapshot has already been initialized for the currently executing batch
    bool snapshotInitialized;
}

// File: lib/euler-vault-kit/src/EVault/shared/lib/ConversionHelpers.sol

pragma solidity ^0.8.0;



/// @title ConversionHelpers Library
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice The library provides a helper function for conversions between shares and assets
library ConversionHelpers {
    // virtual deposit used in conversions between shares and assets, serving as exchange rate manipulation mitigation
    uint256 internal constant VIRTUAL_DEPOSIT_AMOUNT = 1e6;

    function conversionTotals(VaultCache memory vaultCache)
        internal
        pure
        returns (uint256 totalAssets, uint256 totalShares)
    {
        unchecked {
            totalAssets =
                vaultCache.cash.toUint() + vaultCache.totalBorrows.toAssetsUp().toUint() + VIRTUAL_DEPOSIT_AMOUNT;
            totalShares = vaultCache.totalShares.toUint() + VIRTUAL_DEPOSIT_AMOUNT;
        }
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/types/Shares.sol

pragma solidity ^0.8.0;





/// @title SharesLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Library for `Shares` custom type, which is used to store vault's shares balances
library SharesLib {
    function toUint(Shares self) internal pure returns (uint256) {
        return Shares.unwrap(self);
    }

    function isZero(Shares self) internal pure returns (bool) {
        return Shares.unwrap(self) == 0;
    }

    function toAssetsDown(Shares amount, VaultCache memory vaultCache) internal pure returns (Assets) {
        (uint256 totalAssets, uint256 totalShares) = ConversionHelpers.conversionTotals(vaultCache);
        unchecked {
            return TypesLib.toAssets(amount.toUint() * totalAssets / totalShares);
        }
    }

    function toAssetsUp(Shares amount, VaultCache memory vaultCache) internal pure returns (Assets) {
        (uint256 totalAssets, uint256 totalShares) = ConversionHelpers.conversionTotals(vaultCache);
        unchecked {
            // totalShares >= VIRTUAL_DEPOSIT_AMOUNT > 1
            return TypesLib.toAssets((amount.toUint() * totalAssets + (totalShares - 1)) / totalShares);
        }
    }

    function mulDiv(Shares self, uint256 multiplier, uint256 divisor) internal pure returns (Shares) {
        return TypesLib.toShares(uint256(Shares.unwrap(self)) * multiplier / divisor);
    }

    function subUnchecked(Shares self, Shares b) internal pure returns (Shares) {
        unchecked {
            return Shares.wrap(uint112(self.toUint() - b.toUint()));
        }
    }
}

function addShares(Shares a, Shares b) pure returns (Shares) {
    return TypesLib.toShares(uint256(Shares.unwrap(a)) + uint256(Shares.unwrap(b)));
}

function subShares(Shares a, Shares b) pure returns (Shares) {
    return Shares.wrap((Shares.unwrap(a) - Shares.unwrap(b)));
}

function eqShares(Shares a, Shares b) pure returns (bool) {
    return Shares.unwrap(a) == Shares.unwrap(b);
}

function neqShares(Shares a, Shares b) pure returns (bool) {
    return Shares.unwrap(a) != Shares.unwrap(b);
}

function gtShares(Shares a, Shares b) pure returns (bool) {
    return Shares.unwrap(a) > Shares.unwrap(b);
}

function ltShares(Shares a, Shares b) pure returns (bool) {
    return Shares.unwrap(a) < Shares.unwrap(b);
}

// File: lib/euler-vault-kit/src/EVault/shared/Constants.sol

pragma solidity ^0.8.0;

// Implementation internals

// asset amounts are shifted left by this number of bits for increased precision of debt tracking.
uint256 constant INTERNAL_DEBT_PRECISION_SHIFT = 31;
// max amount for Assets and Shares custom types based on a uint112.
uint256 constant MAX_SANE_AMOUNT = type(uint112).max;
// max debt amount fits in uint144 (112 + 31 bits).
// Last 31 bits are zeros to ensure max debt rounded up equals max sane amount.
uint256 constant MAX_SANE_DEBT_AMOUNT = uint256(MAX_SANE_AMOUNT) << INTERNAL_DEBT_PRECISION_SHIFT;
// proxy trailing calldata length in bytes.
// Three addresses, 20 bytes each: vault underlying asset, oracle and unit of account + 4 empty bytes.
uint256 constant PROXY_METADATA_LENGTH = 64;
// gregorian calendar
uint256 constant SECONDS_PER_YEAR = 365.2425 * 86400;
// max interest rate accepted from IRM. 1,000,000% APY: floor(((1000000 / 100 + 1)**(1/(86400*365.2425)) - 1) * 1e27)
uint256 constant MAX_ALLOWED_INTEREST_RATE = 291867278914945094175;
// max valid value of the ConfigAmount custom type, signifying 100%
uint16 constant CONFIG_SCALE = 1e4;

// Account status checks special values

// no account status checks should be scheduled
address constant CHECKACCOUNT_NONE = address(0);
// account status check should be scheduled for the authenticated account
address constant CHECKACCOUNT_CALLER = address(1);

// Operations

uint32 constant OP_DEPOSIT = 1 << 0;
uint32 constant OP_MINT = 1 << 1;
uint32 constant OP_WITHDRAW = 1 << 2;
uint32 constant OP_REDEEM = 1 << 3;
uint32 constant OP_TRANSFER = 1 << 4;
uint32 constant OP_SKIM = 1 << 5;
uint32 constant OP_BORROW = 1 << 6;
uint32 constant OP_REPAY = 1 << 7;
uint32 constant OP_REPAY_WITH_SHARES = 1 << 8;
uint32 constant OP_PULL_DEBT = 1 << 9;
uint32 constant OP_CONVERT_FEES = 1 << 10;
uint32 constant OP_LIQUIDATE = 1 << 11;
uint32 constant OP_FLASHLOAN = 1 << 12;
uint32 constant OP_TOUCH = 1 << 13;
uint32 constant OP_VAULT_STATUS_CHECK = 1 << 14;
// Delimiter of possible operations
uint32 constant OP_MAX_VALUE = 1 << 15;

// Config Flags

// When flag is set, debt socialization during liquidation is disabled
uint32 constant CFG_DONT_SOCIALIZE_DEBT = 1 << 0;
// When flag is set, asset is considered to be compatible with EVC sub-accounts and protections
// against sending assets to sub-accounts are disabled
uint32 constant CFG_EVC_COMPATIBLE_ASSET = 1 << 1;
// Delimiter of possible config flags
uint32 constant CFG_MAX_VALUE = 1 << 2;

// EVC authentication

// in order to perform these operations, the account doesn't need to have the vault installed as a controller
uint32 constant CONTROLLER_NEUTRAL_OPS = OP_DEPOSIT | OP_MINT | OP_WITHDRAW | OP_REDEEM | OP_TRANSFER | OP_SKIM
    | OP_REPAY | OP_REPAY_WITH_SHARES | OP_CONVERT_FEES | OP_FLASHLOAN | OP_TOUCH | OP_VAULT_STATUS_CHECK;

// File: lib/euler-vault-kit/src/EVault/shared/types/Assets.sol

pragma solidity ^0.8.0;






/// @title AssetsLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Custom type `Assets` represents amounts of the vault's underlying asset
library AssetsLib {
    function toUint(Assets self) internal pure returns (uint256) {
        return Assets.unwrap(self);
    }

    function isZero(Assets self) internal pure returns (bool) {
        return Assets.unwrap(self) == 0;
    }

    function toSharesDown(Assets amount, VaultCache memory vaultCache) internal pure returns (Shares) {
        return TypesLib.toShares(toSharesDownUint(amount, vaultCache));
    }

    function toSharesDownUint(Assets amount, VaultCache memory vaultCache) internal pure returns (uint256) {
        (uint256 totalAssets, uint256 totalShares) = ConversionHelpers.conversionTotals(vaultCache);
        unchecked {
            return amount.toUint() * totalShares / totalAssets;
        }
    }

    function toSharesUp(Assets amount, VaultCache memory vaultCache) internal pure returns (Shares) {
        (uint256 totalAssets, uint256 totalShares) = ConversionHelpers.conversionTotals(vaultCache);
        unchecked {
            // totalAssets >= VIRTUAL_DEPOSIT_AMOUNT > 1
            return TypesLib.toShares((amount.toUint() * totalShares + (totalAssets - 1)) / totalAssets);
        }
    }

    function toOwed(Assets self) internal pure returns (Owed) {
        unchecked {
            return TypesLib.toOwed(self.toUint() << INTERNAL_DEBT_PRECISION_SHIFT);
        }
    }

    function addUnchecked(Assets self, Assets b) internal pure returns (Assets) {
        unchecked {
            return Assets.wrap(uint112(self.toUint() + b.toUint()));
        }
    }

    function subUnchecked(Assets self, Assets b) internal pure returns (Assets) {
        unchecked {
            return Assets.wrap(uint112(self.toUint() - b.toUint()));
        }
    }
}

function addAssets(Assets a, Assets b) pure returns (Assets) {
    return TypesLib.toAssets(a.toUint() + b.toUint());
}

function subAssets(Assets a, Assets b) pure returns (Assets) {
    return Assets.wrap((Assets.unwrap(a) - Assets.unwrap(b)));
}

function eqAssets(Assets a, Assets b) pure returns (bool) {
    return Assets.unwrap(a) == Assets.unwrap(b);
}

function neqAssets(Assets a, Assets b) pure returns (bool) {
    return Assets.unwrap(a) != Assets.unwrap(b);
}

function gtAssets(Assets a, Assets b) pure returns (bool) {
    return Assets.unwrap(a) > Assets.unwrap(b);
}

function gteAssets(Assets a, Assets b) pure returns (bool) {
    return Assets.unwrap(a) >= Assets.unwrap(b);
}

function ltAssets(Assets a, Assets b) pure returns (bool) {
    return Assets.unwrap(a) < Assets.unwrap(b);
}

function lteAssets(Assets a, Assets b) pure returns (bool) {
    return Assets.unwrap(a) <= Assets.unwrap(b);
}

// File: lib/euler-vault-kit/src/EVault/shared/types/Owed.sol

pragma solidity ^0.8.0;




/// @title OwedLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Library for `Owed` custom type
/// @dev The owed type tracks borrowed funds in asset units scaled up by shifting left INTERNAL_DEBT_PRECISION_SHIFT
/// bits. Increased precision allows for accurate interest accounting.
library OwedLib {
    function toUint(Owed self) internal pure returns (uint256) {
        return Owed.unwrap(self);
    }

    function toAssetsUp(Owed amount) internal pure returns (Assets) {
        if (Owed.unwrap(amount) == 0) return Assets.wrap(0);

        return TypesLib.toAssets(toAssetsUpUint(Owed.unwrap(amount)));
    }

    function toAssetsDown(Owed amount) internal pure returns (Assets) {
        if (Owed.unwrap(amount) == 0) return Assets.wrap(0);

        return TypesLib.toAssets(Owed.unwrap(amount) >> INTERNAL_DEBT_PRECISION_SHIFT);
    }

    function isDust(Owed self) internal pure returns (bool) {
        // less than a minimum representable internal debt amount
        return Owed.unwrap(self) < (1 << INTERNAL_DEBT_PRECISION_SHIFT);
    }

    function isZero(Owed self) internal pure returns (bool) {
        return Owed.unwrap(self) == 0;
    }

    function mulDiv(Owed self, uint256 multiplier, uint256 divisor) internal pure returns (Owed) {
        return TypesLib.toOwed(uint256(Owed.unwrap(self)) * multiplier / divisor);
    }

    function addUnchecked(Owed self, Owed b) internal pure returns (Owed) {
        unchecked {
            return Owed.wrap(uint144(self.toUint() + b.toUint()));
        }
    }

    function subUnchecked(Owed self, Owed b) internal pure returns (Owed) {
        unchecked {
            return Owed.wrap(uint144(self.toUint() - b.toUint()));
        }
    }

    function toAssetsUpUint(uint256 owedExact) internal pure returns (uint256) {
        return (owedExact + (1 << INTERNAL_DEBT_PRECISION_SHIFT) - 1) >> INTERNAL_DEBT_PRECISION_SHIFT;
    }
}

function addOwed(Owed a, Owed b) pure returns (Owed) {
    return TypesLib.toOwed(uint256(Owed.unwrap(a)) + uint256(Owed.unwrap(b)));
}

function subOwed(Owed a, Owed b) pure returns (Owed) {
    return Owed.wrap((Owed.unwrap(a) - Owed.unwrap(b)));
}

function eqOwed(Owed a, Owed b) pure returns (bool) {
    return Owed.unwrap(a) == Owed.unwrap(b);
}

function neqOwed(Owed a, Owed b) pure returns (bool) {
    return Owed.unwrap(a) != Owed.unwrap(b);
}

function gtOwed(Owed a, Owed b) pure returns (bool) {
    return Owed.unwrap(a) > Owed.unwrap(b);
}

function ltOwed(Owed a, Owed b) pure returns (bool) {
    return Owed.unwrap(a) < Owed.unwrap(b);
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

// File: lib/euler-vault-kit/src/EVault/shared/types/ConfigAmount.sol

pragma solidity ^0.8.0;





/// @title ConfigAmountLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Library for `ConfigAmount` custom type
/// @dev ConfigAmounts are fixed point values encoded in 16 bits with a 1e4 precision.
/// @dev The type is used to store protocol configuration values.
library ConfigAmountLib {
    function isZero(ConfigAmount self) internal pure returns (bool) {
        return self.toUint16() == 0;
    }

    function toUint16(ConfigAmount self) internal pure returns (uint16) {
        return ConfigAmount.unwrap(self);
    }
}

function gtConfigAmount(ConfigAmount a, ConfigAmount b) pure returns (bool) {
    return a.toUint16() > b.toUint16();
}

function gteConfigAmount(ConfigAmount a, ConfigAmount b) pure returns (bool) {
    return a.toUint16() >= b.toUint16();
}

function ltConfigAmount(ConfigAmount a, ConfigAmount b) pure returns (bool) {
    return a.toUint16() < b.toUint16();
}

function lteConfigAmount(ConfigAmount a, ConfigAmount b) pure returns (bool) {
    return a.toUint16() <= b.toUint16();
}

// File: lib/euler-vault-kit/src/EVault/shared/types/Flags.sol

pragma solidity ^0.8.0;



/// @title FlagsLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Library for `Flags` custom type
library FlagsLib {
    /// @dev Are *all* of the flags in bitMask set?
    function isSet(Flags self, uint32 bitMask) internal pure returns (bool) {
        return (Flags.unwrap(self) & bitMask) == bitMask;
    }

    /// @dev Are *none* of the flags in bitMask set?
    function isNotSet(Flags self, uint32 bitMask) internal pure returns (bool) {
        return (Flags.unwrap(self) & bitMask) == 0;
    }

    function toUint32(Flags self) internal pure returns (uint32) {
        return Flags.unwrap(self);
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/types/AmountCap.sol

pragma solidity ^0.8.0;



/// @title AmountCapLib
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Library for `AmountCap` custom type
/// @dev AmountCaps are 16-bit decimal floating point values:
/// * The least significant 6 bits are the exponent
/// * The most significant 10 bits are the mantissa, scaled by 100
/// * The special value of 0 means limit is not set
///   * This is so that uninitialized storage implies no limit
///   * For an actual cap value of 0, use a zero mantissa and non-zero exponent
library AmountCapLib {
    function resolve(AmountCap self) internal pure returns (uint256) {
        uint256 amountCap = AmountCap.unwrap(self);

        if (amountCap == 0) return type(uint256).max;

        unchecked {
            // Cannot overflow because this is less than 2**256:
            //   10**(2**6 - 1) * (2**10 - 1) = 1.023e+66
            return 10 ** (amountCap & 63) * (amountCap >> 6) / 100;
        }
    }

    function toRawUint16(AmountCap self) internal pure returns (uint16) {
        return AmountCap.unwrap(self);
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/types/Types.sol

pragma solidity ^0.8.0;














/// @notice In this file, custom types are defined and linked globally with their libraries and operators

type Shares is uint112;

type Assets is uint112;

type Owed is uint144;

type AmountCap is uint16;

type ConfigAmount is uint16;

type Flags is uint32;

using SharesLib for Shares global;
using {
    addShares as +, subShares as -, eqShares as ==, neqShares as !=, gtShares as >, ltShares as <
} for Shares global;

using AssetsLib for Assets global;
using {
    addAssets as +,
    subAssets as -,
    eqAssets as ==,
    neqAssets as !=,
    gtAssets as >,
    gteAssets as >=,
    ltAssets as <,
    lteAssets as <=
} for Assets global;

using OwedLib for Owed global;
using {addOwed as +, subOwed as -, eqOwed as ==, neqOwed as !=, gtOwed as >, ltOwed as <} for Owed global;

using ConfigAmountLib for ConfigAmount global;
using {
    gtConfigAmount as >, gteConfigAmount as >=, ltConfigAmount as <, lteConfigAmount as <=
} for ConfigAmount global;

using AmountCapLib for AmountCap global;
using FlagsLib for Flags global;

/// @title TypesLib
/// @notice Library for casting basic types' amounts into custom types
library TypesLib {
    function toShares(uint256 amount) internal pure returns (Shares) {
        if (amount > MAX_SANE_AMOUNT) revert Errors.E_AmountTooLargeToEncode();
        return Shares.wrap(uint112(amount));
    }

    function toAssets(uint256 amount) internal pure returns (Assets) {
        if (amount > MAX_SANE_AMOUNT) revert Errors.E_AmountTooLargeToEncode();
        return Assets.wrap(uint112(amount));
    }

    function toOwed(uint256 amount) internal pure returns (Owed) {
        if (amount > MAX_SANE_DEBT_AMOUNT) revert Errors.E_DebtAmountTooLargeToEncode();
        return Owed.wrap(uint144(amount));
    }

    function toConfigAmount(uint16 amount) internal pure returns (ConfigAmount) {
        if (amount > CONFIG_SCALE) revert Errors.E_ConfigAmountTooLargeToEncode();
        return ConfigAmount.wrap(amount);
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/Storage.sol

pragma solidity ^0.8.0;



/// @title Storage
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Contract that defines the EVault's data storage
abstract contract Storage {
    /// @notice Flag indicating if the vault has been initialized
    bool internal initialized;

    /// @notice Snapshot of vault's cash and borrows created at the beginning of an operation or a batch of operations
    /// @dev The snapshot is separate from VaultStorage, because it could be implemented as transient storage
    Snapshot internal snapshot;

    /// @notice A singleton VaultStorage
    VaultStorage internal vaultStorage;
}

// File: lib/euler-vault-kit/src/EVault/shared/Events.sol

pragma solidity ^0.8.0;

/// @title Events
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Contract implementing EVault's events
abstract contract Events {
    // ERC20

    /// @notice Transfer an ERC20 token balance
    /// @param from Sender address
    /// @param to Receiver address
    /// @param value Tokens sent
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Set an ERC20 approval
    /// @param owner Address granting approval to spend tokens
    /// @param spender Address receiving approval to spend tokens
    /// @param value Amount of tokens approved to spend
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ERC4626

    /// @notice Deposit assets into an ERC4626 vault
    /// @param sender Address initiating the deposit
    /// @param owner Address holding the assets
    /// @param assets Amount of assets deposited
    /// @param shares Amount of shares minted as receipt for the deposit
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    /// @notice Withdraw from an ERC4626 vault
    /// @param sender Address initiating the withdrawal
    /// @param receiver Address receiving the assets
    /// @param owner Address holding the shares
    /// @param assets Amount of assets sent to the receiver
    /// @param shares Amount of shares burned
    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    // EVault

    /// @notice New EVault is initialized
    /// @param creator Address designated as the vault's creator
    /// @param asset The underlying asset of the vault
    /// @param dToken Address of the sidecar debt token
    event EVaultCreated(address indexed creator, address indexed asset, address dToken);

    /// @notice Log the current vault status
    /// @param totalShares Sum of all shares
    /// @param totalBorrows Sum of all borrows in assets
    /// @param accumulatedFees Interest fees accrued in the accumulator
    /// @param cash The amount of assets held by the vault directly
    /// @param interestAccumulator Current interest accumulator in ray
    /// @param interestRate Current interest rate, which will be applied during the next fee accrual
    /// @param timestamp Current block's timestamp
    event VaultStatus(
        uint256 totalShares,
        uint256 totalBorrows,
        uint256 accumulatedFees,
        uint256 cash,
        uint256 interestAccumulator,
        uint256 interestRate,
        uint256 timestamp
    );

    /// @notice Increase account's debt
    /// @param account Address adding liability
    /// @param assets Amount of debt added in assets
    event Borrow(address indexed account, uint256 assets);

    /// @notice Decrease account's debt
    /// @param account Address repaying the debt
    /// @param assets Amount of debt removed in assets
    event Repay(address indexed account, uint256 assets);

    /// @notice Account's debt was increased due to interest
    /// @param account Address being charged interest
    /// @param assets Amount of debt added in assets
    event InterestAccrued(address indexed account, uint256 assets);

    /// @notice Liquidate unhealthy account
    /// @param liquidator Address executing the liquidation
    /// @param violator Address holding an unhealthy borrow
    /// @param collateral Address of the asset seized
    /// @param repayAssets Amount of debt in assets transferred from violator to liquidator
    /// @param yieldBalance Amount of collateral asset's balance transferred from violator to liquidator
    event Liquidate(
        address indexed liquidator,
        address indexed violator,
        address collateral,
        uint256 repayAssets,
        uint256 yieldBalance
    );

    /// @notice Take on debt from another account
    /// @param from Account from which the debt is taken
    /// @param to Account taking on the debt
    /// @param assets Amount of debt transferred in assets
    event PullDebt(address indexed from, address indexed to, uint256 assets);

    /// @notice Socialize debt after liquidating all of the unhealthy account's collateral
    /// @param account Address holding an unhealthy borrow
    /// @param assets Amount of debt socialized among all of the share holders
    event DebtSocialized(address indexed account, uint256 assets);

    /// @notice Split the accumulated fees between the governor and the protocol
    /// @param sender Address initializing the conversion
    /// @param protocolReceiver Address receiving the protocol's share of the fees
    /// @param governorReceiver Address receiving the governor's share of the fees
    /// @param protocolShares Amount of shares transferred to the protocol receiver
    /// @param governorShares Amount of shares transferred to the governor receiver
    event ConvertFees(
        address indexed sender,
        address indexed protocolReceiver,
        address indexed governorReceiver,
        uint256 protocolShares,
        uint256 governorShares
    );

    /// @notice Enable or disable balance tracking for the account
    /// @param account Address which enabled or disabled balance tracking
    /// @param status True if balance tracking was enabled, false otherwise
    event BalanceForwarderStatus(address indexed account, bool status);
}

// File: lib/euler-vault-kit/src/EVault/shared/lib/ProxyUtils.sol

pragma solidity ^0.8.0;






/// @title ProxyUtils Library
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice The library provides helper functions for working with proxy meta data
library ProxyUtils {
    function metadata() internal pure returns (IERC20 asset, IPriceOracle oracle, address unitOfAccount) {
        assembly {
            asset := shr(96, calldataload(sub(calldatasize(), 60)))
            oracle := shr(96, calldataload(sub(calldatasize(), 40)))
            unitOfAccount := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }

    // When `useView` modifier is used, the original caller's address is attached to the call data along with the
    // metadata
    function useViewCaller() internal pure returns (address viewCaller) {
        assembly {
            viewCaller := shr(96, calldataload(sub(calldatasize(), add(PROXY_METADATA_LENGTH, 20))))
        }
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/lib/AddressUtils.sol

pragma solidity ^0.8.0;



/// @title AddressUtils Library
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice The library provides a helper function for checking if provided address is a contract (has code)
library AddressUtils {
    function checkContract(address addr) internal view returns (address) {
        if (addr.code.length == 0) revert Errors.E_BadAddress();

        return addr;
    }
}

// File: lib/ethereum-vault-connector/src/interfaces/IEthereumVaultConnector.sol

pragma solidity >=0.8.0;

/// @title IEVC
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This interface defines the methods for the Ethereum Vault Connector.
interface IEVC {
    /// @notice A struct representing a batch item.
    /// @dev Each batch item represents a single operation to be performed within a checks deferred context.
    struct BatchItem {
        /// @notice The target contract to be called.
        address targetContract;
        /// @notice The account on behalf of which the operation is to be performed. msg.sender must be authorized to
        /// act on behalf of this account. Must be address(0) if the target contract is the EVC itself.
        address onBehalfOfAccount;
        /// @notice The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
        /// balance of the EVC contract will be forwarded. Must be 0 if the target contract is the EVC itself.
        uint256 value;
        /// @notice The encoded data which is called on the target contract.
        bytes data;
    }

    /// @notice A struct representing the result of a batch item operation.
    /// @dev Used only for simulation purposes.
    struct BatchItemResult {
        /// @notice A boolean indicating whether the operation was successful.
        bool success;
        /// @notice The result of the operation.
        bytes result;
    }

    /// @notice A struct representing the result of the account or vault status check.
    /// @dev Used only for simulation purposes.
    struct StatusCheckResult {
        /// @notice The address of the account or vault for which the check was performed.
        address checkedAddress;
        /// @notice A boolean indicating whether the status of the account or vault is valid.
        bool isValid;
        /// @notice The result of the check.
        bytes result;
    }

    /// @notice Returns current raw execution context.
    /// @dev When checks in progress, on behalf of account is always address(0).
    /// @return context Current raw execution context.
    function getRawExecutionContext() external view returns (uint256 context);

    /// @notice Returns an account on behalf of which the operation is being executed at the moment and whether the
    /// controllerToCheck is an enabled controller for that account.
    /// @dev This function should only be used by external smart contracts if msg.sender is the EVC. Otherwise, the
    /// account address returned must not be trusted.
    /// @dev When checks in progress, on behalf of account is always address(0). When address is zero, the function
    /// reverts to protect the consumer from ever relying on the on behalf of account address which is in its default
    /// state.
    /// @param controllerToCheck The address of the controller for which it is checked whether it is an enabled
    /// controller for the account on behalf of which the operation is being executed at the moment.
    /// @return onBehalfOfAccount An account that has been authenticated and on behalf of which the operation is being
    /// executed at the moment.
    /// @return controllerEnabled A boolean value that indicates whether controllerToCheck is an enabled controller for
    /// the account on behalf of which the operation is being executed at the moment. Always false if controllerToCheck
    /// is address(0).
    function getCurrentOnBehalfOfAccount(address controllerToCheck)
        external
        view
        returns (address onBehalfOfAccount, bool controllerEnabled);

    /// @notice Checks if checks are deferred.
    /// @return A boolean indicating whether checks are deferred.
    function areChecksDeferred() external view returns (bool);

    /// @notice Checks if checks are in progress.
    /// @return A boolean indicating whether checks are in progress.
    function areChecksInProgress() external view returns (bool);

    /// @notice Checks if control collateral is in progress.
    /// @return A boolean indicating whether control collateral is in progress.
    function isControlCollateralInProgress() external view returns (bool);

    /// @notice Checks if an operator is authenticated.
    /// @return A boolean indicating whether an operator is authenticated.
    function isOperatorAuthenticated() external view returns (bool);

    /// @notice Checks if a simulation is in progress.
    /// @return A boolean indicating whether a simulation is in progress.
    function isSimulationInProgress() external view returns (bool);

    /// @notice Checks whether the specified account and the other account have the same owner.
    /// @dev The function is used to check whether one account is authorized to perform operations on behalf of the
    /// other. Accounts are considered to have a common owner if they share the first 19 bytes of their address.
    /// @param account The address of the account that is being checked.
    /// @param otherAccount The address of the other account that is being checked.
    /// @return A boolean flag that indicates whether the accounts have the same owner.
    function haveCommonOwner(address account, address otherAccount) external pure returns (bool);

    /// @notice Returns the address prefix of the specified account.
    /// @dev The address prefix is the first 19 bytes of the account address.
    /// @param account The address of the account whose address prefix is being retrieved.
    /// @return A bytes19 value that represents the address prefix of the account.
    function getAddressPrefix(address account) external pure returns (bytes19);

    /// @notice Returns the owner for the specified account.
    /// @dev The function returns address(0) if the owner is not registered. Registration of the owner happens on the
    /// initial
    /// interaction with the EVC that requires authentication of an owner.
    /// @param account The address of the account whose owner is being retrieved.
    /// @return owner The address of the account owner. An account owner is an EOA/smart contract which address matches
    /// the first 19 bytes of the account address.
    function getAccountOwner(address account) external view returns (address);

    /// @notice Checks if lockdown mode is enabled for a given address prefix.
    /// @param addressPrefix The address prefix to check for lockdown mode status.
    /// @return A boolean indicating whether lockdown mode is enabled.
    function isLockdownMode(bytes19 addressPrefix) external view returns (bool);

    /// @notice Checks if permit functionality is disabled for a given address prefix.
    /// @param addressPrefix The address prefix to check for permit functionality status.
    /// @return A boolean indicating whether permit functionality is disabled.
    function isPermitDisabledMode(bytes19 addressPrefix) external view returns (bool);

    /// @notice Returns the current nonce for a given address prefix and nonce namespace.
    /// @dev Each nonce namespace provides 256 bit nonce that has to be used sequentially. There's no requirement to use
    /// all the nonces for a given nonce namespace before moving to the next one which allows to use permit messages in
    /// a non-sequential manner.
    /// @param addressPrefix The address prefix for which the nonce is being retrieved.
    /// @param nonceNamespace The nonce namespace for which the nonce is being retrieved.
    /// @return nonce The current nonce for the given address prefix and nonce namespace.
    function getNonce(bytes19 addressPrefix, uint256 nonceNamespace) external view returns (uint256 nonce);

    /// @notice Returns the bit field for a given address prefix and operator.
    /// @dev The bit field is used to store information about authorized operators for a given address prefix. Each bit
    /// in the bit field corresponds to one account belonging to the same owner. If the bit is set, the operator is
    /// authorized for the account.
    /// @param addressPrefix The address prefix for which the bit field is being retrieved.
    /// @param operator The address of the operator for which the bit field is being retrieved.
    /// @return operatorBitField The bit field for the given address prefix and operator. The bit field defines which
    /// accounts the operator is authorized for. It is a 256-position binary array like 0...010...0, marking the account
    /// positionally in a uint256. The position in the bit field corresponds to the account ID (0-255), where 0 is the
    /// owner account's ID.
    function getOperator(bytes19 addressPrefix, address operator) external view returns (uint256 operatorBitField);

    /// @notice Returns whether a given operator has been authorized for a given account.
    /// @param account The address of the account whose operator is being checked.
    /// @param operator The address of the operator that is being checked.
    /// @return authorized A boolean value that indicates whether the operator is authorized for the account.
    function isAccountOperatorAuthorized(address account, address operator) external view returns (bool authorized);

    /// @notice Enables or disables lockdown mode for a given address prefix.
    /// @dev This function can only be called by the owner of the address prefix. To disable this mode, the EVC
    /// must be called directly. It is not possible to disable this mode by using checks-deferrable call or
    /// permit message.
    /// @param addressPrefix The address prefix for which the lockdown mode is being set.
    /// @param enabled A boolean indicating whether to enable or disable lockdown mode.
    function setLockdownMode(bytes19 addressPrefix, bool enabled) external payable;

    /// @notice Enables or disables permit functionality for a given address prefix.
    /// @dev This function can only be called by the owner of the address prefix. To disable this mode, the EVC
    /// must be called directly. It is not possible to disable this mode by using checks-deferrable call or (by
    /// definition) permit message. To support permit functionality by default, note that the logic was inverted here. To
    /// disable  the permit functionality, one must pass true as the second argument. To enable the permit
    /// functionality, one must pass false as the second argument.
    /// @param addressPrefix The address prefix for which the permit functionality is being set.
    /// @param enabled A boolean indicating whether to enable or disable the disable-permit mode.
    function setPermitDisabledMode(bytes19 addressPrefix, bool enabled) external payable;

    /// @notice Sets the nonce for a given address prefix and nonce namespace.
    /// @dev This function can only be called by the owner of the address prefix. Each nonce namespace provides a 256
    /// bit nonce that has to be used sequentially. There's no requirement to use all the nonces for a given nonce
    /// namespace before moving to the next one which allows the use of permit messages in a non-sequential manner. To
    /// invalidate signed permit messages, set the nonce for a given nonce namespace accordingly. To invalidate all the
    /// permit messages for a given nonce namespace, set the nonce to type(uint).max.
    /// @param addressPrefix The address prefix for which the nonce is being set.
    /// @param nonceNamespace The nonce namespace for which the nonce is being set.
    /// @param nonce The new nonce for the given address prefix and nonce namespace.
    function setNonce(bytes19 addressPrefix, uint256 nonceNamespace, uint256 nonce) external payable;

    /// @notice Sets the bit field for a given address prefix and operator.
    /// @dev This function can only be called by the owner of the address prefix. Each bit in the bit field corresponds
    /// to one account belonging to the same owner. If the bit is set, the operator is authorized for the account.
    /// @param addressPrefix The address prefix for which the bit field is being set.
    /// @param operator The address of the operator for which the bit field is being set. Can neither be the EVC address
    /// nor an address belonging to the same address prefix.
    /// @param operatorBitField The new bit field for the given address prefix and operator. Reverts if the provided
    /// value is equal to the currently stored value.
    function setOperator(bytes19 addressPrefix, address operator, uint256 operatorBitField) external payable;

    /// @notice Authorizes or deauthorizes an operator for the account.
    /// @dev Only the owner or authorized operator of the account can call this function. An operator is an address that
    /// can perform actions for an account on behalf of the owner. If it's an operator calling this function, it can
    /// only deauthorize itself.
    /// @param account The address of the account whose operator is being set or unset.
    /// @param operator The address of the operator that is being installed or uninstalled. Can neither be the EVC
    /// address nor an address belonging to the same owner as the account.
    /// @param authorized A boolean value that indicates whether the operator is being authorized or deauthorized.
    /// Reverts if the provided value is equal to the currently stored value.
    function setAccountOperator(address account, address operator, bool authorized) external payable;

    /// @notice Returns an array of collaterals enabled for an account.
    /// @dev A collateral is a vault for which an account's balances are under the control of the currently enabled
    /// controller vault.
    /// @param account The address of the account whose collaterals are being queried.
    /// @return An array of addresses that are enabled collaterals for the account.
    function getCollaterals(address account) external view returns (address[] memory);

    /// @notice Returns whether a collateral is enabled for an account.
    /// @dev A collateral is a vault for which account's balances are under the control of the currently enabled
    /// controller vault.
    /// @param account The address of the account that is being checked.
    /// @param vault The address of the collateral that is being checked.
    /// @return A boolean value that indicates whether the vault is an enabled collateral for the account or not.
    function isCollateralEnabled(address account, address vault) external view returns (bool);

    /// @notice Enables a collateral for an account.
    /// @dev A collaterals is a vault for which account's balances are under the control of the currently enabled
    /// controller vault. Only the owner or an operator of the account can call this function. Unless it's a duplicate,
    /// the collateral is added to the end of the array. There can be at most 10 unique collaterals enabled at a time.
    /// Account status checks are performed.
    /// @param account The account address for which the collateral is being enabled.
    /// @param vault The address being enabled as a collateral.
    function enableCollateral(address account, address vault) external payable;

    /// @notice Disables a collateral for an account.
    /// @dev This function does not preserve the order of collaterals in the array obtained using the getCollaterals
    /// function; the order may change. A collateral is a vault for which account’s balances are under the control of
    /// the currently enabled controller vault. Only the owner or an operator of the account can call this function.
    /// Disabling a collateral might change the order of collaterals in the array obtained using getCollaterals
    /// function. Account status checks are performed.
    /// @param account The account address for which the collateral is being disabled.
    /// @param vault The address of a collateral being disabled.
    function disableCollateral(address account, address vault) external payable;

    /// @notice Swaps the position of two collaterals so that they appear switched in the array of collaterals for a
    /// given account obtained by calling getCollaterals function.
    /// @dev A collateral is a vault for which account’s balances are under the control of the currently enabled
    /// controller vault. Only the owner or an operator of the account can call this function. The order of collaterals
    /// can be changed by specifying the indices of the two collaterals to be swapped. Indices are zero-based and must
    /// be in the range of 0 to the number of collaterals minus 1. index1 must be lower than index2. Account status
    /// checks are performed.
    /// @param account The address of the account for which the collaterals are being reordered.
    /// @param index1 The index of the first collateral to be swapped.
    /// @param index2 The index of the second collateral to be swapped.
    function reorderCollaterals(address account, uint8 index1, uint8 index2) external payable;

    /// @notice Returns an array of enabled controllers for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over the account's
    /// balances in enabled collaterals vaults. A user can have multiple controllers during a call execution, but at
    /// most one can be selected when the account status check is performed.
    /// @param account The address of the account whose controllers are being queried.
    /// @return An array of addresses that are the enabled controllers for the account.
    function getControllers(address account) external view returns (address[] memory);

    /// @notice Returns whether a controller is enabled for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults.
    /// @param account The address of the account that is being checked.
    /// @param vault The address of the controller that is being checked.
    /// @return A boolean value that indicates whether the vault is enabled controller for the account or not.
    function isControllerEnabled(address account, address vault) external view returns (bool);

    /// @notice Enables a controller for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults. Only the owner or an operator of the account can call this function.
    /// Unless it's a duplicate, the controller is added to the end of the array. Transiently, there can be at most 10
    /// unique controllers enabled at a time, but at most one can be enabled after the outermost checks-deferrable
    /// call concludes. Account status checks are performed.
    /// @param account The address for which the controller is being enabled.
    /// @param vault The address of the controller being enabled.
    function enableController(address account, address vault) external payable;

    /// @notice Disables a controller for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults. Only the vault itself can call this function. Disabling a controller
    /// might change the order of controllers in the array obtained using getControllers function. Account status checks
    /// are performed.
    /// @param account The address for which the calling controller is being disabled.
    function disableController(address account) external payable;

    /// @notice Executes signed arbitrary data by self-calling into the EVC.
    /// @dev Low-level call function is used to execute the arbitrary data signed by the owner or the operator on the
    /// EVC contract. During that call, EVC becomes msg.sender.
    /// @param signer The address signing the permit message (ECDSA) or verifying the permit message signature
    /// (ERC-1271). It's also the owner or the operator of all the accounts for which authentication will be needed
    /// during the execution of the arbitrary data call.
    /// @param sender The address of the msg.sender which is expected to execute the data signed by the signer. If
    /// address(0) is passed, the msg.sender is ignored.
    /// @param nonceNamespace The nonce namespace for which the nonce is being used.
    /// @param nonce The nonce for the given account and nonce namespace. A valid nonce value is considered to be the
    /// value currently stored and can take any value between 0 and type(uint256).max - 1.
    /// @param deadline The timestamp after which the permit is considered expired.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is self-called on the EVC contract.
    /// @param signature The signature of the data signed by the signer.
    function permit(
        address signer,
        address sender,
        uint256 nonceNamespace,
        uint256 nonce,
        uint256 deadline,
        uint256 value,
        bytes calldata data,
        bytes calldata signature
    ) external payable;

    /// @notice Calls into a target contract as per data encoded.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev This function can be used to interact with any contract while checks are deferred. If the target contract
    /// is msg.sender, msg.sender is called back with the calldata provided and the context set up according to the
    /// account provided. If the target contract is not msg.sender, only the owner or the operator of the account
    /// provided can call this function.
    /// @dev This function can be used to recover the remaining value from the EVC contract.
    /// @param targetContract The address of the contract to be called.
    /// @param onBehalfOfAccount  If the target contract is msg.sender, the address of the account which will be set
    /// in the context. It assumes msg.sender has authenticated the account themselves. If the target contract is
    /// not msg.sender, the address of the account for which it is checked whether msg.sender is authorized to act
    /// on behalf of.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is called on the target contract.
    /// @return result The result of the call.
    function call(
        address targetContract,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result);

    /// @notice For a given account, calls into one of the enabled collateral vaults from the currently enabled
    /// controller vault as per data encoded.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev This function can be used to interact with any contract while checks are deferred as long as the contract
    /// is enabled as a collateral of the account and the msg.sender is the only enabled controller of the account.
    /// @param targetCollateral The collateral address to be called.
    /// @param onBehalfOfAccount The address of the account for which it is checked whether msg.sender is authorized to
    /// act on behalf.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is called on the target collateral.
    /// @return result The result of the call.
    function controlCollateral(
        address targetCollateral,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result);

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev The authentication rules for each batch item are the same as for the call function.
    /// @param items An array of batch items to be executed.
    function batch(BatchItem[] calldata items) external payable;

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function always reverts as it's only used for simulation purposes. This function cannot be called
    /// within a checks-deferrable call.
    /// @param items An array of batch items to be executed.
    function batchRevert(BatchItem[] calldata items) external payable;

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function does not modify state and should only be used for simulation purposes. This function cannot
    /// be called within a checks-deferrable call.
    /// @param items An array of batch items to be executed.
    /// @return batchItemsResult An array of batch item results for each item.
    /// @return accountsStatusCheckResult An array of account status check results for each account.
    /// @return vaultsStatusCheckResult An array of vault status check results for each vault.
    function batchSimulation(BatchItem[] calldata items)
        external
        payable
        returns (
            BatchItemResult[] memory batchItemsResult,
            StatusCheckResult[] memory accountsStatusCheckResult,
            StatusCheckResult[] memory vaultsStatusCheckResult
        );

    /// @notice Retrieves the timestamp of the last successful account status check performed for a specific account.
    /// @dev This function reverts if the checks are in progress.
    /// @dev The account status check is considered to be successful if it calls into the selected controller vault and
    /// obtains expected magic value. This timestamp does not change if the account status is considered valid when no
    /// controller enabled. When consuming, one might need to ensure that the account status check is not deferred at
    /// the moment.
    /// @param account The address of the account for which the last status check timestamp is being queried.
    /// @return The timestamp of the last status check as a uint256.
    function getLastAccountStatusCheckTimestamp(address account) external view returns (uint256);

    /// @notice Checks whether the status check is deferred for a given account.
    /// @dev This function reverts if the checks are in progress.
    /// @param account The address of the account for which it is checked whether the status check is deferred.
    /// @return A boolean flag that indicates whether the status check is deferred or not.
    function isAccountStatusCheckDeferred(address account) external view returns (bool);

    /// @notice Checks the status of an account and reverts if it is not valid.
    /// @dev If checks deferred, the account is added to the set of accounts to be checked at the end of the outermost
    /// checks-deferrable call. There can be at most 10 unique accounts added to the set at a time. Account status
    /// check is performed by calling into the selected controller vault and passing the array of currently enabled
    /// collaterals. If controller is not selected, the account is always considered valid.
    /// @param account The address of the account to be checked.
    function requireAccountStatusCheck(address account) external payable;

    /// @notice Forgives previously deferred account status check.
    /// @dev Account address is removed from the set of addresses for which status checks are deferred. This function
    /// can only be called by the currently enabled controller of a given account. Depending on the vault
    /// implementation, may be needed in the liquidation flow.
    /// @param account The address of the account for which the status check is forgiven.
    function forgiveAccountStatusCheck(address account) external payable;

    /// @notice Checks whether the status check is deferred for a given vault.
    /// @dev This function reverts if the checks are in progress.
    /// @param vault The address of the vault for which it is checked whether the status check is deferred.
    /// @return A boolean flag that indicates whether the status check is deferred or not.
    function isVaultStatusCheckDeferred(address vault) external view returns (bool);

    /// @notice Checks the status of a vault and reverts if it is not valid.
    /// @dev If checks deferred, the vault is added to the set of vaults to be checked at the end of the outermost
    /// checks-deferrable call. There can be at most 10 unique vaults added to the set at a time. This function can
    /// only be called by the vault itself.
    function requireVaultStatusCheck() external payable;

    /// @notice Forgives previously deferred vault status check.
    /// @dev Vault address is removed from the set of addresses for which status checks are deferred. This function can
    /// only be called by the vault itself.
    function forgiveVaultStatusCheck() external payable;

    /// @notice Checks the status of an account and a vault and reverts if it is not valid.
    /// @dev If checks deferred, the account and the vault are added to the respective sets of accounts and vaults to be
    /// checked at the end of the outermost checks-deferrable call. Account status check is performed by calling into
    /// selected controller vault and passing the array of currently enabled collaterals. If controller is not selected,
    /// the account is always considered valid. This function can only be called by the vault itself.
    /// @param account The address of the account to be checked.
    function requireAccountAndVaultStatusCheck(address account) external payable;
}

// File: lib/euler-vault-kit/src/EVault/shared/EVCClient.sol

pragma solidity ^0.8.0;












/// @title EVCClient
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Utilities for interacting with the EVC (Ethereum Vault Connector)
abstract contract EVCClient is Storage, Events, Errors {
    IEVC internal immutable evc;

    modifier onlyEVCChecks() {
        if (msg.sender != address(evc) || !evc.areChecksInProgress()) {
            revert E_CheckUnauthorized();
        }

        _;
    }

    constructor(address _evc) {
        evc = IEVC(AddressUtils.checkContract(_evc));
    }

    function disableControllerInternal(address account) internal virtual {
        evc.disableController(account);
    }

    // Authenticate the account and the controller, making sure the call is made through EVC and the status checks are
    // deferred
    function EVCAuthenticateDeferred(bool checkController) internal view virtual returns (address) {
        assert(msg.sender == address(evc)); // this ensures that callThroughEVC modifier was utilized

        (address onBehalfOfAccount, bool controllerEnabled) =
            evc.getCurrentOnBehalfOfAccount(checkController ? address(this) : address(0));

        if (checkController && !controllerEnabled) revert E_ControllerDisabled();

        return onBehalfOfAccount;
    }

    // Authenticate the account
    function EVCAuthenticate() internal view virtual returns (address) {
        if (msg.sender == address(evc)) {
            (address onBehalfOfAccount,) = evc.getCurrentOnBehalfOfAccount(address(0));

            return onBehalfOfAccount;
        }
        return msg.sender;
    }

    // Authenticate the governor, making sure neither a sub-account nor operator is used. Prohibit the use of control
    // collateral
    function EVCAuthenticateGovernor() internal view virtual returns (address) {
        if (msg.sender == address(evc)) {
            (address onBehalfOfAccount,) = evc.getCurrentOnBehalfOfAccount(address(0));

            if (
                isKnownNonOwnerAccount(onBehalfOfAccount) || evc.isOperatorAuthenticated()
                    || evc.isControlCollateralInProgress()
            ) {
                revert E_Unauthorized();
            }

            return onBehalfOfAccount;
        }
        return msg.sender;
    }

    // Checks if the account is known to EVC to be a non-owner sub-account.
    // Assets that are not EVC integrated should not be sent to those accounts,
    // as there will be no way to transfer them out.
    function isKnownNonOwnerAccount(address account) internal view returns (bool) {
        address owner = evc.getAccountOwner(account);
        return owner != address(0) && owner != account;
    }

    function EVCRequireStatusChecks(address account) internal virtual {
        assert(account != CHECKACCOUNT_CALLER); // the special value should be resolved by now

        if (account == CHECKACCOUNT_NONE) {
            evc.requireVaultStatusCheck();
        } else {
            evc.requireAccountAndVaultStatusCheck(account);
        }
    }

    function enforceCollateralTransfer(address collateral, uint256 amount, address from, address receiver)
        internal
        virtual
    {
        evc.controlCollateral(collateral, from, 0, abi.encodeCall(IERC20.transfer, (receiver, amount)));
    }

    function forgiveAccountStatusCheck(address account) internal virtual {
        evc.forgiveAccountStatusCheck(account);
    }

    function hasAnyControllerEnabled(address account) internal view returns (bool) {
        return evc.getControllers(account).length > 0;
    }

    function getCollaterals(address account) internal view returns (address[] memory) {
        return evc.getCollaterals(account);
    }

    function isCollateralEnabled(address account, address collateral) internal view returns (bool) {
        return evc.isCollateralEnabled(account, collateral);
    }

    function isAccountStatusCheckDeferred(address account) internal view returns (bool) {
        return evc.isAccountStatusCheckDeferred(account);
    }

    function isVaultStatusCheckDeferred() internal view returns (bool) {
        return evc.isVaultStatusCheckDeferred(address(this));
    }

    function isControlCollateralInProgress() internal view returns (bool) {
        return evc.isControlCollateralInProgress();
    }

    function getLastAccountStatusCheckTimestamp(address account) internal view returns (uint256) {
        return evc.getLastAccountStatusCheckTimestamp(account);
    }

    function validateController(address account) internal view {
        address[] memory controllers = evc.getControllers(account);

        if (controllers.length > 1) revert E_TransientState();
        if (controllers.length == 0) revert E_NoLiability();
        if (controllers[0] != address(this)) revert E_NotController();
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/lib/RPow.sol

pragma solidity ^0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @custom:security-contact security@euler.xyz
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
/// @author Modified by Euler Labs (https://www.eulerlabs.com/) to return an `overflow` bool instead of reverting
library RPow {
    /// @dev If overflow is true, an overflow occurred and the value of z is undefined
    function rpow(uint256 x, uint256 n, uint256 scalar) internal pure returns (uint256 z, bool overflow) {
        /// @solidity memory-safe-assembly
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Bail if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        overflow := 1
                        break
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Bail if xx + half overflowed.
                    if lt(xxRound, xx) {
                        overflow := 1
                        break
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Bail if x is non-zero.
                            if iszero(iszero(x)) {
                                overflow := 1
                                break
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Bail if zx + half overflowed.
                        if lt(zxRound, zx) {
                            overflow := 1
                            break
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }
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

// File: lib/euler-vault-kit/src/EVault/shared/Cache.sol

pragma solidity ^0.8.0;









/// @title Cache
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Utilities for loading vault storage and updating it with interest accrued
contract Cache is Storage, Errors {
    using TypesLib for uint256;

    // Returns an updated VaultCache
    // If different from VaultStorage, updates VaultStorage
    function updateVault() internal virtual returns (VaultCache memory vaultCache) {
        if (initVaultCache(vaultCache)) {
            vaultStorage.lastInterestAccumulatorUpdate = vaultCache.lastInterestAccumulatorUpdate;
            vaultStorage.accumulatedFees = vaultCache.accumulatedFees;

            vaultStorage.totalShares = vaultCache.totalShares;
            vaultStorage.totalBorrows = vaultCache.totalBorrows;

            vaultStorage.interestAccumulator = vaultCache.interestAccumulator;
        }
    }

    // Returns an updated VaultCache
    function loadVault() internal view virtual returns (VaultCache memory vaultCache) {
        initVaultCache(vaultCache);
    }

    // Takes a VaultCache struct, overwrites it with VaultStorage data and, if time has passed since VaultStorage
    // was last updated, updates VaultStorage.
    // Returns a boolean if the cache is different from storage. VaultCache param is updated to this block.
    function initVaultCache(VaultCache memory vaultCache) internal view returns (bool dirty) {
        dirty = false;

        // Proxy metadata

        (vaultCache.asset, vaultCache.oracle, vaultCache.unitOfAccount) = ProxyUtils.metadata();

        // Storage loads

        vaultCache.lastInterestAccumulatorUpdate = vaultStorage.lastInterestAccumulatorUpdate;
        vaultCache.cash = vaultStorage.cash;
        vaultCache.supplyCap = vaultStorage.supplyCap.resolve();
        vaultCache.borrowCap = vaultStorage.borrowCap.resolve();
        vaultCache.hookedOps = vaultStorage.hookedOps;
        vaultCache.snapshotInitialized = vaultStorage.snapshotInitialized;

        vaultCache.totalShares = vaultStorage.totalShares;
        vaultCache.totalBorrows = vaultStorage.totalBorrows;

        vaultCache.accumulatedFees = vaultStorage.accumulatedFees;
        vaultCache.configFlags = vaultStorage.configFlags;

        vaultCache.interestAccumulator = vaultStorage.interestAccumulator;

        // Update interest accumulator and fees balance

        uint256 deltaT = block.timestamp - vaultCache.lastInterestAccumulatorUpdate;
        if (deltaT > 0) {
            dirty = true;

            // Compute new cache values. Use full precision for intermediate results.

            ConfigAmount interestFee = vaultStorage.interestFee;
            uint256 interestRate = vaultStorage.interestRate;

            uint256 newInterestAccumulator = vaultCache.interestAccumulator;
            uint256 newTotalBorrows = vaultCache.totalBorrows.toUint();

            unchecked {
                uint256 intermediate;
                (uint256 multiplier, bool overflow) = RPow.rpow(interestRate + 1e27, deltaT, 1e27);

                // if exponentiation or accumulator update overflows, keep the old accumulator
                if (!overflow) {
                    intermediate = newInterestAccumulator * multiplier;
                    if (newInterestAccumulator == intermediate / multiplier) {
                        newInterestAccumulator = intermediate / 1e27;
                    }
                }

                intermediate = newTotalBorrows * newInterestAccumulator;
                if (newTotalBorrows == intermediate / newInterestAccumulator) {
                    newTotalBorrows = intermediate / vaultCache.interestAccumulator;
                }
            }

            uint256 newAccumulatedFees = vaultCache.accumulatedFees.toUint();
            uint256 newTotalShares = vaultCache.totalShares.toUint();
            uint256 feeAssets = (newTotalBorrows - vaultCache.totalBorrows.toUint()) * interestFee.toUint16()
                / (uint256(CONFIG_SCALE) << INTERNAL_DEBT_PRECISION_SHIFT);

            if (feeAssets != 0) {
                // Fee shares are minted at a slightly worse price than user deposits (unless the exchange rate of
                // shares to assets is < 1, which is only possible in an extreme case of large debt socialization). The
                // discrepancy arises because, firstly, the virtual deposit is not accounted for, and secondly, all new
                // interest is included in the total assets during the minting process, whereas during a regular user
                // operation, the pre-money conversion is performed. This behavior is considered safe and reduces code
                // complexity and gas costs, while its effect is positive for regular users (unless the exchange rate is
                // abnormally < 1)
                uint256 newTotalAssets = vaultCache.cash.toUint() + OwedLib.toAssetsUpUint(newTotalBorrows);
                newTotalShares = newTotalAssets * newTotalShares / (newTotalAssets - feeAssets);
                newAccumulatedFees += newTotalShares - vaultCache.totalShares.toUint();
            }

            // Store new values in vaultCache, only if no overflows will occur. Fees are not larger than total shares,
            // since they are included in them.
            if (newTotalBorrows <= MAX_SANE_DEBT_AMOUNT) {
                vaultCache.totalBorrows = newTotalBorrows.toOwed();
                vaultCache.interestAccumulator = newInterestAccumulator;
                vaultCache.lastInterestAccumulatorUpdate = uint48(block.timestamp);

                if (newTotalShares != vaultCache.totalShares.toUint() && newTotalShares <= MAX_SANE_AMOUNT) {
                    vaultCache.accumulatedFees = newAccumulatedFees.toShares();
                    vaultCache.totalShares = newTotalShares.toShares();
                }
            }
        }
    }

    function totalAssetsInternal(VaultCache memory vaultCache) internal pure virtual returns (uint256) {
        // total assets can exceed Assets max amount (MAX_SANE_AMOUNT)
        return vaultCache.cash.toUint() + vaultCache.totalBorrows.toAssetsUp().toUint();
    }
}

// File: lib/euler-vault-kit/src/ProtocolConfig/IProtocolConfig.sol

pragma solidity >=0.8.0;

/// @title IProtocolConfig
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Interface of the contract centralizing the protocol's (DAO's) configuration for all the EVault deployments
interface IProtocolConfig {
    /// @notice check if a vault's interest fee is valid
    /// @param vault address of the vault
    /// @param interestFee an interest fee value to check
    /// @dev an interest fee is considered valid only when it is greater than or equal the min interest fee and less
    /// than or equal the max interest fee
    /// @dev if a vault has a specific interest fee ranges set by admin, it will be used, otherwise the generic ones
    /// will be checked against
    /// @return bool true for valid, else false
    function isValidInterestFee(address vault, uint16 interestFee) external view returns (bool);

    /// @notice get protocol fee config for a certain vault
    /// @param vault address of the vault
    /// @dev if vault == address(0), the generic config will be returned
    /// @return address protocol fee receiver
    /// @return uint16 protocol fee share
    function protocolFeeConfig(address vault) external view returns (address, uint16);

    /// @notice get interest fee ranges for a certain vault
    /// @param vault address of the vault
    /// @dev if vault == address(0), the generic ranges will be returned
    /// @return uint16 min interest fee
    /// @return uint16 max interest fee
    function interestFeeRange(address vault) external view returns (uint16, uint16);
}

// File: lib/euler-vault-kit/src/interfaces/IBalanceTracker.sol

pragma solidity >=0.8.0;

/// @title IBalanceTracker
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Provides an interface for tracking the balance of accounts.
interface IBalanceTracker {
    /// @notice Executes the balance tracking hook for an account.
    /// @dev This function is called by the Balance Forwarder contract which was enabled for the account. This function
    /// must be called with the current balance of the account when enabling the balance forwarding for it. This
    /// function must be called with 0 balance of the account when disabling the balance forwarding for it. This
    /// function allows to be called on zero balance transfers, when the newAccountBalance is the same as the previous
    /// one. To prevent DOS attacks, forfeitRecentReward should be used appropriately.
    /// @param account The account address to execute the hook for.
    /// @param newAccountBalance The new balance of the account.
    /// @param forfeitRecentReward Whether to forfeit the most recent reward and not update the accumulator.
    function balanceTrackerHook(address account, uint256 newAccountBalance, bool forfeitRecentReward) external;
}

// File: lib/euler-vault-kit/src/interfaces/ISequenceRegistry.sol

pragma solidity >=0.8.0;

/// @title ISequenceRegistry
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Provides an interface for reserving sequence IDs.
interface ISequenceRegistry {
    /// @notice Reserve an ID for a given designator
    /// @param designator An opaque string that corresponds to the sequence counter to be used
    /// @return Sequence ID
    function reserveSeqId(string calldata designator) external returns (uint256);
}

// File: lib/euler-vault-kit/src/EVault/shared/Base.sol

pragma solidity ^0.8.0;













/// @title Base
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Base contract for EVault modules with top level modifiers and utilities
abstract contract Base is EVCClient, Cache {
    IProtocolConfig internal immutable protocolConfig;
    ISequenceRegistry immutable sequenceRegistry;
    IBalanceTracker internal immutable balanceTracker;
    address internal immutable permit2;

    /// @title Integrations
    /// @notice Struct containing addresses of all of the contracts which EVault integrates with
    struct Integrations {
        // Ethereum Vault Connector's address
        address evc;
        // Address of the contract handling protocol level configurations
        address protocolConfig;
        // Address of the contract providing a unique ID used in setting the vault's name and symbol
        address sequenceRegistry;
        // Address of the contract which is called when user balances change
        address balanceTracker;
        // Address of Uniswap's Permit2 contract
        address permit2;
    }

    constructor(Integrations memory integrations) EVCClient(integrations.evc) {
        protocolConfig = IProtocolConfig(AddressUtils.checkContract(integrations.protocolConfig));
        sequenceRegistry = ISequenceRegistry(AddressUtils.checkContract(integrations.sequenceRegistry));
        balanceTracker = IBalanceTracker(integrations.balanceTracker);
        permit2 = integrations.permit2;
    }

    modifier reentrantOK() {
        _;
    } // documentation only

    modifier nonReentrant() {
        if (vaultStorage.reentrancyLocked) revert E_Reentrancy();

        vaultStorage.reentrancyLocked = true;
        _;
        vaultStorage.reentrancyLocked = false;
    }

    modifier nonReentrantView() {
        if (vaultStorage.reentrancyLocked) {
            address hookTarget = vaultStorage.hookTarget;

            // The hook target is allowed to bypass the RO-reentrancy lock. The hook target can either be a msg.sender
            // when the view function is inlined in the EVault.sol or the hook target should be taken from the trailing
            // data appended by the delegateToModuleView function used by useView modifier. In the latter case, it is
            // safe to consume the trailing data as we know we are inside useView because msg.sender == address(this)
            if (msg.sender != hookTarget && !(msg.sender == address(this) && ProxyUtils.useViewCaller() == hookTarget))
            {
                revert E_Reentrancy();
            }
        }
        _;
    }

    // Generate a vault snapshot and store it.
    // Queue vault and maybe account checks in the EVC (caller, current, onBehalfOf or none).
    // If needed, revert if this contract is not the controller of the authenticated account.
    // Returns the VaultCache and active account.
    function initOperation(uint32 operation, address accountToCheck)
        internal
        virtual
        returns (VaultCache memory vaultCache, address account)
    {
        vaultCache = updateVault();
        account = EVCAuthenticateDeferred(CONTROLLER_NEUTRAL_OPS & operation == 0);

        callHook(vaultCache.hookedOps, operation, account);
        EVCRequireStatusChecks(accountToCheck == CHECKACCOUNT_CALLER ? account : accountToCheck);

        // The snapshot is used only to verify that supply increased when checking the supply cap, and to verify that
        // the borrows increased when checking the borrowing cap. Caps are not checked when the capped variables
        // decrease (become safer). For this reason, the snapshot is disabled if both caps are disabled.
        // The snapshot is cleared during the vault status check hence the vault status check must not be forgiven.
        if (
            !vaultCache.snapshotInitialized
                && !(vaultCache.supplyCap == type(uint256).max && vaultCache.borrowCap == type(uint256).max)
        ) {
            vaultStorage.snapshotInitialized = vaultCache.snapshotInitialized = true;
            snapshot.set(vaultCache.cash, vaultCache.totalBorrows.toAssetsUp());
        }
    }

    // Checks whether the operation is disabled and returns the result of the check.
    // An operation is considered disabled if a hook has been installed for it and the
    // hook target is zero address.
    function isOperationDisabled(Flags hookedOps, uint32 operation) internal view returns (bool) {
        return hookedOps.isSet(operation) && vaultStorage.hookTarget == address(0);
    }

    // Checks whether a hook has been installed for the operation and if so, invokes the hook target.
    // If the hook target is zero address, this will revert.
    function callHook(Flags hookedOps, uint32 operation, address caller) internal virtual {
        if (hookedOps.isNotSet(operation)) return;

        invokeHookTarget(caller);
    }

    // Same as callHook, but acquires the reentrancy lock when calling the hook
    function callHookWithLock(Flags hookedOps, uint32 operation, address caller) internal virtual {
        if (hookedOps.isNotSet(operation)) return;

        invokeHookTargetWithLock(caller);
    }

    function invokeHookTarget(address caller) private {
        address hookTarget = vaultStorage.hookTarget;

        if (hookTarget == address(0)) revert E_OperationDisabled();

        (bool success, bytes memory data) = hookTarget.call(abi.encodePacked(msg.data, caller));

        if (!success) RevertBytes.revertBytes(data);
    }

    function invokeHookTargetWithLock(address caller) private nonReentrant {
        invokeHookTarget(caller);
    }

    function logVaultStatus(VaultCache memory a, uint256 interestRate) internal {
        emit VaultStatus(
            a.totalShares.toUint(),
            a.totalBorrows.toAssetsUp().toUint(),
            a.accumulatedFees.toUint(),
            a.cash.toUint(),
            a.interestAccumulator,
            interestRate,
            block.timestamp
        );
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/BalanceUtils.sol

pragma solidity ^0.8.0;





/// @title BalanceUtils
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Utilities for tracking share balances and allowances
abstract contract BalanceUtils is Base {
    // Balances

    function increaseBalance(
        VaultCache memory vaultCache,
        address account,
        address sender,
        Shares amount,
        Assets assets
    ) internal virtual {
        if (account == address(0)) revert E_BadSharesReceiver();
        UserStorage storage user = vaultStorage.users[account];

        (Shares origBalance, bool balanceForwarderEnabled) = user.getBalanceAndBalanceForwarder();
        Shares newBalance = origBalance + amount;

        user.setBalance(newBalance);
        vaultStorage.totalShares = vaultCache.totalShares = vaultCache.totalShares + amount;

        if (balanceForwarderEnabled) {
            balanceTracker.balanceTrackerHook(account, newBalance.toUint(), false);
        }

        emit Transfer(address(0), account, amount.toUint());
        emit Deposit(sender, account, assets.toUint(), amount.toUint());
    }

    function decreaseBalance(
        VaultCache memory vaultCache,
        address account,
        address sender,
        address receiver,
        Shares amount,
        Assets assets
    ) internal virtual {
        UserStorage storage user = vaultStorage.users[account];
        (Shares origBalance, bool balanceForwarderEnabled) = user.getBalanceAndBalanceForwarder();
        if (origBalance < amount) revert E_InsufficientBalance();

        Shares newBalance = origBalance.subUnchecked(amount);

        user.setBalance(newBalance);
        vaultStorage.totalShares = vaultCache.totalShares = vaultCache.totalShares - amount;

        if (balanceForwarderEnabled) {
            // if the balance is decreased as a part of the collateral transfer during liquidation,
            // which is indicated by the EVC with a collateral control in progress flag,
            // instruct the balance tracker to forfeit rewards due to the liquidated account, in order to
            // limit gas consumption, which could potentially be abused by violators to prevent liquidations.
            balanceTracker.balanceTrackerHook(account, newBalance.toUint(), isControlCollateralInProgress());
        }

        emit Transfer(account, address(0), amount.toUint());
        emit Withdraw(sender, receiver, account, assets.toUint(), amount.toUint());
    }

    function transferBalance(address from, address to, Shares amount) internal virtual {
        if (to == address(0)) revert E_BadSharesReceiver();

        if (!amount.isZero()) {
            // update from

            UserStorage storage user = vaultStorage.users[from];

            (Shares origFromBalance, bool fromBalanceForwarderEnabled) = user.getBalanceAndBalanceForwarder();
            if (origFromBalance < amount) revert E_InsufficientBalance();

            Shares newFromBalance = origFromBalance.subUnchecked(amount);
            user.setBalance(newFromBalance);

            if (fromBalanceForwarderEnabled) {
                balanceTracker.balanceTrackerHook(from, newFromBalance.toUint(), isControlCollateralInProgress());
            }

            // update to

            user = vaultStorage.users[to];

            (Shares origToBalance, bool toBalanceForwarderEnabled) = user.getBalanceAndBalanceForwarder();

            Shares newToBalance = origToBalance + amount;
            user.setBalance(newToBalance);

            if (toBalanceForwarderEnabled) {
                balanceTracker.balanceTrackerHook(to, newToBalance.toUint(), false);
            }
        }

        emit Transfer(from, to, amount.toUint());
    }

    // Allowance

    function setAllowance(address owner, address spender, uint256 amount) internal {
        if (spender == owner) return;

        vaultStorage.users[owner].eTokenAllowance[spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /// @dev As gas saving optimization, consuming allowance doesn't emit the Approval event.
    function decreaseAllowance(address owner, address spender, Shares amount) internal virtual {
        if (amount.isZero() || owner == spender) return;
        UserStorage storage user = vaultStorage.users[owner];

        uint256 allowance = user.eTokenAllowance[spender];
        if (allowance != type(uint256).max) {
            if (allowance < amount.toUint()) revert E_InsufficientAllowance();
            unchecked {
                allowance -= amount.toUint();
            }
            user.eTokenAllowance[spender] = allowance;
        }
    }
}

// File: lib/euler-vault-kit/src/EVault/DToken.sol

pragma solidity ^0.8.0;





/// @title DToken
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Contract implements read only ERC20 interface, and `Transfer` events, for EVault's debt
contract DToken is IERC20, Errors, Events {
    /// @notice The address of the EVault associated with this DToken
    address public immutable eVault;

    constructor() {
        eVault = msg.sender;
    }

    // ERC20 interface

    /// @notice The debt token (dToken) name
    /// @return The dToken name
    function name() external view returns (string memory) {
        return string.concat("Debt token of ", IEVault(eVault).name());
    }

    /// @notice The debt token (dToken) symbol
    /// @return The dToken symbol
    function symbol() external view returns (string memory) {
        return string.concat(IEVault(eVault).symbol(), "-DEBT");
    }

    /// @notice Decimals of the dToken, same as EVault's
    /// @return The dToken decimals
    function decimals() external view returns (uint8) {
        return IEVault(eVault).decimals();
    }

    /// @notice Return total supply of the DToken
    /// @return The dToken total supply
    function totalSupply() external view returns (uint256) {
        return IEVault(eVault).totalBorrows();
    }

    /// @notice Balance of a particular account, in dTokens
    /// @param owner The account to query
    /// @return The balance of the account
    function balanceOf(address owner) external view returns (uint256) {
        return IEVault(eVault).debtOf(owner);
    }

    /// @notice Retrieve the current allowance
    /// @return The allowance
    /// @dev Approvals are not supported by the dToken
    function allowance(address, address) external pure returns (uint256) {
        return 0;
    }

    /// @notice Function required by the ERC20 interface
    /// @dev Approvals are not supported by the DToken
    function approve(address, uint256) external pure returns (bool) {
        revert E_NotSupported();
    }

    /// @notice Function required by the ERC20 interface
    /// @dev Transfers are not supported by the DToken directly
    function transfer(address, uint256) external pure returns (bool) {
        revert E_NotSupported();
    }

    /// @notice Function required by the ERC20 interface
    /// @dev Transfers are not supported by the DToken directly
    function transferFrom(address, address, uint256) external pure returns (bool) {
        revert E_NotSupported();
    }

    // Events

    /// @notice Emit an ERC20 Transfer event
    /// @dev Only callable by the parent EVault
    function emitTransfer(address from, address to, uint256 value) external {
        if (msg.sender != eVault) revert E_Unauthorized();

        emit Transfer(from, to, value);
    }

    // Helpers

    /// @notice Return the address of the asset the debt is denominated in
    function asset() external view returns (address) {
        return IEVault(eVault).asset();
    }
}

// File: lib/euler-vault-kit/src/InterestRateModels/IIRM.sol

pragma solidity >=0.8.0;

/// @title IIRM
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Interface of the interest rate model contracts used by EVault
interface IIRM {
    error E_IRMUpdateUnauthorized();

    /// @notice Perform potentially state mutating computation of the new interest rate
    /// @param vault Address of the vault to compute the new interest rate for
    /// @param cash Amount of assets held directly by the vault
    /// @param borrows Amount of assets lent out to borrowers by the vault
    /// @return Then new interest rate in second percent yield (SPY), scaled by 1e27
    function computeInterestRate(address vault, uint256 cash, uint256 borrows) external returns (uint256);

    /// @notice Perform computation of the new interest rate without mutating state
    /// @param vault Address of the vault to compute the new interest rate for
    /// @param cash Amount of assets held directly by the vault
    /// @param borrows Amount of assets lent out to borrowers by the vault
    /// @return Then new interest rate in second percent yield (SPY), scaled by 1e27
    function computeInterestRateView(address vault, uint256 cash, uint256 borrows) external view returns (uint256);
}

// File: lib/euler-vault-kit/src/EVault/shared/BorrowUtils.sol

pragma solidity ^0.8.0;







/// @title BorrowUtils
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Utilities for tracking debt and interest rates
abstract contract BorrowUtils is Base {
    function getCurrentOwed(VaultCache memory vaultCache, address account, Owed owed) internal view returns (Owed) {
        // Don't bother loading the user's accumulator
        if (owed.isZero()) return Owed.wrap(0);

        // Can't divide by 0 here: If owed is non-zero, we must've initialized the user's interestAccumulator
        return owed.mulDiv(vaultCache.interestAccumulator, vaultStorage.users[account].interestAccumulator);
    }

    function getCurrentOwed(VaultCache memory vaultCache, address account) internal view returns (Owed) {
        return getCurrentOwed(vaultCache, account, vaultStorage.users[account].getOwed());
    }

    function loadUserBorrow(VaultCache memory vaultCache, address account)
        private
        view
        returns (Owed newOwed, Owed prevOwed)
    {
        prevOwed = vaultStorage.users[account].getOwed();
        newOwed = getCurrentOwed(vaultCache, account, prevOwed);
    }

    function setUserBorrow(VaultCache memory vaultCache, address account, Owed newOwed) private {
        UserStorage storage user = vaultStorage.users[account];

        user.setOwed(newOwed);
        user.interestAccumulator = vaultCache.interestAccumulator;
    }

    function increaseBorrow(VaultCache memory vaultCache, address account, Assets assets) internal virtual {
        (Owed owed, Owed prevOwed) = loadUserBorrow(vaultCache, account);

        Owed amount = assets.toOwed();
        owed = owed + amount;

        setUserBorrow(vaultCache, account, owed);
        vaultStorage.totalBorrows = vaultCache.totalBorrows = vaultCache.totalBorrows + amount;

        logBorrow(account, assets, prevOwed.toAssetsUp(), owed.toAssetsUp());
    }

    /// @dev Contrary to `increaseBorrow` and `transferBorrow` this function does the accounting in Assets
    /// by first rounding up the user's debt. The rounding is an additional cost to the user and is recorded
    /// both in user's account and in `totalBorrows`
    function decreaseBorrow(VaultCache memory vaultCache, address account, Assets assets) internal virtual {
        (Owed owedExact, Owed prevOwed) = loadUserBorrow(vaultCache, account);
        Assets owed = owedExact.toAssetsUp();

        if (assets > owed) revert E_RepayTooMuch();

        Owed owedRemaining = owed.subUnchecked(assets).toOwed();

        setUserBorrow(vaultCache, account, owedRemaining);
        vaultStorage.totalBorrows = vaultCache.totalBorrows = vaultCache.totalBorrows > owedExact
            ? vaultCache.totalBorrows.subUnchecked(owedExact).addUnchecked(owedRemaining)
            : owedRemaining;

        logRepay(account, assets, prevOwed.toAssetsUp(), owedRemaining.toAssetsUp());
    }

    function transferBorrow(VaultCache memory vaultCache, address from, address to, Assets assets) internal virtual {
        Owed amount = assets.toOwed();

        (Owed fromOwed, Owed fromOwedPrev) = loadUserBorrow(vaultCache, from);

        // If amount was rounded up, or dust is left over, transfer exact amount owed
        if (
            (amount > fromOwed && amount.subUnchecked(fromOwed).isDust())
                || (amount < fromOwed && fromOwed.subUnchecked(amount).isDust())
        ) {
            amount = fromOwed;
        }

        if (amount > fromOwed) revert E_InsufficientDebt();

        fromOwed = fromOwed.subUnchecked(amount);
        setUserBorrow(vaultCache, from, fromOwed);

        (Owed toOwed, Owed toOwedPrev) = loadUserBorrow(vaultCache, to);

        toOwed = toOwed + amount;
        setUserBorrow(vaultCache, to, toOwed);

        // with small fractional debt amounts the interest calculation could be negative in `logRepay`
        Assets fromPrevAssets = fromOwedPrev.toAssetsUp();
        Assets fromAssets = fromOwed.toAssetsUp();
        Assets repayAssets = fromPrevAssets > assets + fromAssets ? fromPrevAssets.subUnchecked(fromAssets) : assets;
        logRepay(from, repayAssets, fromPrevAssets, fromAssets);

        // with small fractional debt amounts the interest calculation could be negative in `logBorrow`
        Assets toPrevAssets = toOwedPrev.toAssetsUp();
        Assets toAssets = toOwed.toAssetsUp();
        Assets borrowAssets = assets + toPrevAssets > toAssets ? toAssets.subUnchecked(toPrevAssets) : assets;
        logBorrow(to, borrowAssets, toPrevAssets, toAssets);
    }

    function computeInterestRate(VaultCache memory vaultCache) internal virtual returns (uint256) {
        // single sload
        address irm = vaultStorage.interestRateModel;
        uint256 newInterestRate = vaultStorage.interestRate;

        if (irm != address(0)) {
            (bool success, bytes memory data) = irm.call(
                abi.encodeCall(
                    IIRM.computeInterestRate,
                    (address(this), vaultCache.cash.toUint(), vaultCache.totalBorrows.toAssetsUp().toUint())
                )
            );

            if (success && data.length >= 32) {
                newInterestRate = abi.decode(data, (uint256));
                if (newInterestRate > MAX_ALLOWED_INTEREST_RATE) newInterestRate = MAX_ALLOWED_INTEREST_RATE;
                vaultStorage.interestRate = uint72(newInterestRate);
            }
        }

        return newInterestRate;
    }

    function computeInterestRateView(VaultCache memory vaultCache) internal view virtual returns (uint256) {
        // single sload
        address irm = vaultStorage.interestRateModel;
        uint256 newInterestRate = vaultStorage.interestRate;

        if (irm != address(0) && isVaultStatusCheckDeferred()) {
            (bool success, bytes memory data) = irm.staticcall(
                abi.encodeCall(
                    IIRM.computeInterestRateView,
                    (address(this), vaultCache.cash.toUint(), vaultCache.totalBorrows.toAssetsUp().toUint())
                )
            );

            if (success && data.length >= 32) {
                newInterestRate = abi.decode(data, (uint256));
                if (newInterestRate > MAX_ALLOWED_INTEREST_RATE) newInterestRate = MAX_ALLOWED_INTEREST_RATE;
            }
        }

        return newInterestRate;
    }

    function calculateDTokenAddress() internal view virtual returns (address dToken) {
        // inspired by:
        // https://github.com/Vectorized/solady/blob/229c18cfcdcd474f95c30ad31b0f7d428ee8a31a/src/utils/CREATE3.sol#L82-L90
        assembly ("memory-safe") {
            mstore(0x14, address())
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ address(this) ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            // Nonce of the contract when DToken was deployed (1).
            mstore8(0x34, 0x01)

            dToken := keccak256(0x1e, 0x17)
        }
    }

    function logBorrow(address account, Assets amount, Assets prevOwed, Assets owed) private {
        Assets interest = owed.subUnchecked(prevOwed).subUnchecked(amount);
        if (!interest.isZero()) emit InterestAccrued(account, interest.toUint());
        if (!amount.isZero()) emit Borrow(account, amount.toUint());
        logDToken(account, prevOwed, owed);
    }

    function logRepay(address account, Assets amount, Assets prevOwed, Assets owed) private {
        Assets interest = owed.addUnchecked(amount).subUnchecked(prevOwed);
        if (!interest.isZero()) emit InterestAccrued(account, interest.toUint());
        if (!amount.isZero()) emit Repay(account, amount.toUint());
        logDToken(account, prevOwed, owed);
    }

    function logDToken(address account, Assets prevOwed, Assets owed) private {
        address dTokenAddress = calculateDTokenAddress();

        if (owed > prevOwed) {
            uint256 change = owed.subUnchecked(prevOwed).toUint();
            DToken(dTokenAddress).emitTransfer(address(0), account, change);
        } else if (prevOwed > owed) {
            uint256 change = prevOwed.subUnchecked(owed).toUint();
            DToken(dTokenAddress).emitTransfer(account, address(0), change);
        }
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/LTVUtils.sol

pragma solidity ^0.8.0;




/// @title LTVUtils
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Overridable getters for LTV configuration
abstract contract LTVUtils is Storage {
    function getLTV(address collateral, bool liquidation) internal view virtual returns (ConfigAmount) {
        return vaultStorage.ltvLookup[collateral].getLTV(liquidation);
    }

    function isRecognizedCollateral(address collateral) internal view virtual returns (bool) {
        return vaultStorage.ltvLookup[collateral].isRecognizedCollateral();
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/LiquidityUtils.sol

pragma solidity ^0.8.0;






/// @title LiquidityUtils
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Utilities for calculating account liquidity and health status
abstract contract LiquidityUtils is BorrowUtils, LTVUtils {
    using TypesLib for uint256;

    // Calculate the value of liabilities, and the liquidation or borrowing LTV adjusted collateral value.
    function calculateLiquidity(
        VaultCache memory vaultCache,
        address account,
        address[] memory collaterals,
        bool liquidation
    ) internal view virtual returns (uint256 collateralValue, uint256 liabilityValue) {
        validateOracle(vaultCache);

        for (uint256 i; i < collaterals.length; ++i) {
            collateralValue += getCollateralValue(vaultCache, account, collaterals[i], liquidation);
        }

        liabilityValue = getLiabilityValue(vaultCache, account, vaultStorage.users[account].getOwed(), liquidation);
    }

    // Check that there is no liability, or the value of the collateral, adjusted for borrowing LTV, is greater than the
    // liability value. Since this function uses bid/ask prices, it should only be used within the account status check,
    // and not for determining whether an account can be liquidated (which uses mid-point prices).
    function checkLiquidity(VaultCache memory vaultCache, address account, address[] memory collaterals)
        internal
        view
        virtual
    {
        validateOracle(vaultCache);

        Owed owed = vaultStorage.users[account].getOwed();
        if (owed.isZero()) return;

        uint256 liabilityValue = getLiabilityValue(vaultCache, account, owed, false);

        uint256 collateralValue;
        for (uint256 i; i < collaterals.length; ++i) {
            collateralValue += getCollateralValue(vaultCache, account, collaterals[i], false);
            if (collateralValue > liabilityValue) return;
        }

        revert E_AccountLiquidity();
    }

    // Check if the account has no collateral balance left, used for debt socialization
    // If LTV is zero, the collateral can still be liquidated.
    // If the price of collateral is zero, liquidations are not executed, so the check won't be performed.
    // If there is no collateral balance at all, then debt socialization can happen.
    function checkNoCollateral(address account, address[] memory collaterals) internal view virtual returns (bool) {
        for (uint256 i; i < collaterals.length; ++i) {
            address collateral = collaterals[i];

            if (!isRecognizedCollateral(collateral)) continue;

            if (IERC20(collateral).balanceOf(account) > 0) return false;
        }

        return true;
    }

    function getLiabilityValue(VaultCache memory vaultCache, address account, Owed owed, bool liquidation)
        internal
        view
        virtual
        returns (uint256 value)
    {
        // update owed with interest accrued
        uint256 owedAssets = getCurrentOwed(vaultCache, account, owed).toAssetsUp().toUint();

        if (owedAssets == 0) return 0;

        if (address(vaultCache.asset) == vaultCache.unitOfAccount) {
            value = owedAssets;
        } else {
            if (liquidation) {
                // mid-point price
                value = vaultCache.oracle.getQuote(owedAssets, address(vaultCache.asset), vaultCache.unitOfAccount);
            } else {
                // ask price for liability
                (, value) = vaultCache.oracle.getQuotes(owedAssets, address(vaultCache.asset), vaultCache.unitOfAccount);
            }
        }
    }

    function getCollateralValue(VaultCache memory vaultCache, address account, address collateral, bool liquidation)
        internal
        view
        virtual
        returns (uint256 value)
    {
        ConfigAmount ltv = getLTV(collateral, liquidation);
        if (ltv.isZero()) return 0;

        uint256 balance = IERC20(collateral).balanceOf(account);
        if (balance == 0) return 0;

        uint256 currentCollateralValue;

        if (liquidation) {
            // mid-point price
            currentCollateralValue = vaultCache.oracle.getQuote(balance, collateral, vaultCache.unitOfAccount);
        } else {
            // bid price for collateral
            (currentCollateralValue,) = vaultCache.oracle.getQuotes(balance, collateral, vaultCache.unitOfAccount);
        }

        return currentCollateralValue * ltv.toUint16() / CONFIG_SCALE;
    }

    function validateOracle(VaultCache memory vaultCache) internal pure {
        if (address(vaultCache.oracle) == address(0)) revert E_NoPriceOracle();
    }
}

// File: lib/euler-vault-kit/src/EVault/shared/AssetTransfers.sol

pragma solidity ^0.8.0;






/// @title AssetTransfers
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Transfer assets into and out of the vault
abstract contract AssetTransfers is Base {
    using TypesLib for uint256;
    using SafeERC20Lib for IERC20;

    function pullAssets(VaultCache memory vaultCache, address from, Assets amount) internal virtual {
        vaultCache.asset.safeTransferFrom(from, address(this), amount.toUint(), permit2);
        vaultStorage.cash = vaultCache.cash = vaultCache.cash + amount;
    }

    /// @dev If the `CFG_EVC_COMPATIBLE_ASSET` flag is not set (default), the function will protect users from
    /// mistakenly sending funds to the EVC sub-accounts. Functions that push tokens out (`withdraw`, `redeem`,
    /// `borrow`) accept a `receiver` argument. If the user sets one of their sub-accounts (not the owner) as the
    /// receiver, funds would be lost because a regular asset doesn't support the EVC's sub-accounts. The private key to
    /// a sub-account (not the owner) is not known, so the user would not be able to move the funds out. The function
    /// will make a best effort to prevent this by checking if the receiver of the token is recognized by EVC as a
    /// non-owner sub-account. In other words, if there is an account registered in EVC as the owner for the intended
    /// receiver, the transfer will be prevented. However, there is no guarantee that EVC will have the owner
    /// registered. If the asset itself is compatible with EVC, it is safe to set the flag and send the asset to a
    /// non-owner sub-account.
    function pushAssets(VaultCache memory vaultCache, address to, Assets amount) internal virtual {
        if (
            to == address(0)
                || (vaultCache.configFlags.isNotSet(CFG_EVC_COMPATIBLE_ASSET) && isKnownNonOwnerAccount(to))
        ) {
            revert E_BadAssetReceiver();
        }

        vaultStorage.cash = vaultCache.cash = vaultCache.cash - amount;
        vaultCache.asset.safeTransfer(to, amount.toUint());
    }
}

// File: lib/euler-vault-kit/src/interfaces/IFlashLoan.sol

pragma solidity >=0.8.0;

/// @title IFlashLoan
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Definition of callback method that flashLoan will invoke on your contract
interface IFlashLoan {
    /// @notice Function that will be called on the caller of `flashloan`
    /// @param data Data that was passed to the `flashloan` call
    function onFlashLoan(bytes memory data) external;
}

// File: lib/euler-vault-kit/src/EVault/modules/Borrowing.sol

pragma solidity ^0.8.0;












/// @title BorrowingModule
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice An EVault module handling borrowing and repaying of vault assets
abstract contract BorrowingModule is IBorrowing, AssetTransfers, BalanceUtils, LiquidityUtils {
    using TypesLib for uint256;
    using SafeERC20Lib for IERC20;

    /// @inheritdoc IBorrowing
    function totalBorrows() public view virtual nonReentrantView returns (uint256) {
        return loadVault().totalBorrows.toAssetsUp().toUint();
    }

    /// @inheritdoc IBorrowing
    function totalBorrowsExact() public view virtual nonReentrantView returns (uint256) {
        return loadVault().totalBorrows.toUint();
    }

    /// @inheritdoc IBorrowing
    function cash() public view virtual nonReentrantView returns (uint256) {
        return vaultStorage.cash.toUint();
    }

    /// @inheritdoc IBorrowing
    function debtOf(address account) public view virtual nonReentrantView returns (uint256) {
        return getCurrentOwed(loadVault(), account).toAssetsUp().toUint();
    }

    /// @inheritdoc IBorrowing
    function debtOfExact(address account) public view virtual nonReentrantView returns (uint256) {
        return getCurrentOwed(loadVault(), account).toUint();
    }

    /// @inheritdoc IBorrowing
    function interestRate() public view virtual nonReentrantView returns (uint256) {
        return computeInterestRateView(loadVault());
    }

    /// @inheritdoc IBorrowing
    function interestAccumulator() public view virtual nonReentrantView returns (uint256) {
        return loadVault().interestAccumulator;
    }

    /// @inheritdoc IBorrowing
    function dToken() public view virtual reentrantOK returns (address) {
        return calculateDTokenAddress();
    }

    /// @inheritdoc IBorrowing
    function borrow(uint256 amount, address receiver) public virtual nonReentrant returns (uint256) {
        (VaultCache memory vaultCache, address account) = initOperation(OP_BORROW, CHECKACCOUNT_CALLER);

        Assets assets = amount == type(uint256).max ? vaultCache.cash : amount.toAssets();
        if (assets.isZero()) return 0;

        if (assets > vaultCache.cash) revert E_InsufficientCash();

        increaseBorrow(vaultCache, account, assets);

        pushAssets(vaultCache, receiver, assets);

        return assets.toUint();
    }

    /// @inheritdoc IBorrowing
    function repay(uint256 amount, address receiver) public virtual nonReentrant returns (uint256) {
        (VaultCache memory vaultCache, address account) = initOperation(OP_REPAY, CHECKACCOUNT_NONE);

        uint256 owed = getCurrentOwed(vaultCache, receiver).toAssetsUp().toUint();

        Assets assets = (amount == type(uint256).max ? owed : amount).toAssets();
        if (assets.isZero()) return 0;

        pullAssets(vaultCache, account, assets);

        decreaseBorrow(vaultCache, receiver, assets);

        return assets.toUint();
    }

    /// @inheritdoc IBorrowing
    function repayWithShares(uint256 amount, address receiver) public virtual nonReentrant returns (uint256, uint256) {
        (VaultCache memory vaultCache, address account) = initOperation(OP_REPAY_WITH_SHARES, CHECKACCOUNT_CALLER);

        Assets owed = getCurrentOwed(vaultCache, receiver).toAssetsUp();
        if (owed.isZero()) return (0, 0);

        Assets assets;
        Shares shares;

        if (amount == type(uint256).max) {
            shares = vaultStorage.users[account].getBalance();
            assets = shares.toAssetsDown(vaultCache);
        } else {
            assets = amount.toAssets();
            shares = assets.toSharesUp(vaultCache);
        }

        if (assets.isZero()) return (0, 0);

        if (assets > owed) {
            assets = owed;
            shares = assets.toSharesUp(vaultCache);
        }

        // Burn ETokens
        decreaseBalance(vaultCache, account, account, account, shares, assets);

        // Burn DTokens
        decreaseBorrow(vaultCache, receiver, assets);

        return (shares.toUint(), assets.toUint());
    }

    /// @inheritdoc IBorrowing
    function pullDebt(uint256 amount, address from) public virtual nonReentrant {
        (VaultCache memory vaultCache, address account) = initOperation(OP_PULL_DEBT, CHECKACCOUNT_CALLER);

        if (from == account) revert E_SelfTransfer();

        Assets assets = amount == type(uint256).max ? getCurrentOwed(vaultCache, from).toAssetsUp() : amount.toAssets();

        if (assets.isZero()) return;
        transferBorrow(vaultCache, from, account, assets);

        emit PullDebt(from, account, assets.toUint());
    }

    /// @inheritdoc IBorrowing
    function flashLoan(uint256 amount, bytes calldata data) public virtual nonReentrant {
        address account = EVCAuthenticate();
        callHook(vaultStorage.hookedOps, OP_FLASHLOAN, account);

        (IERC20 asset,,) = ProxyUtils.metadata();

        uint256 origBalance = asset.balanceOf(address(this));

        asset.safeTransfer(account, amount);

        IFlashLoan(account).onFlashLoan(data);

        if (asset.balanceOf(address(this)) < origBalance) revert E_FlashLoanNotRepaid();
    }

    /// @inheritdoc IBorrowing
    function touch() public virtual nonReentrant {
        initOperation(OP_TOUCH, CHECKACCOUNT_NONE);
    }
}

/// @dev Deployable module contract
contract Borrowing is BorrowingModule {
    constructor(Integrations memory integrations) Base(integrations) {}
}
