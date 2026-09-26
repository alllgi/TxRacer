// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/forge-std/src/interfaces/IERC20.sol

pragma solidity >=0.6.2;

/// @dev Interface of the ERC20 standard as defined in the EIP.
/// @dev This includes the optional name, symbol, and decimals metadata.
interface IERC20 {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set, where `value`
    /// is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    /// @notice Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Moves `amount` tokens from the caller's account to `to`.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` is allowed
    /// to spend on behalf of `owner`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev Be aware of front-running risks: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Moves `amount` tokens from `from` to `to` using the allowance mechanism.
    /// `amount` is then deducted from the caller's allowance.
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /// @notice Returns the decimals places of the token.
    function decimals() external view returns (uint8);
}

// File: lib/forge-std/src/interfaces/IERC4626.sol

pragma solidity >=0.6.2;



/// @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
/// https://eips.ethereum.org/EIPS/eip-4626
interface IERC4626 is IERC20 {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    /// @notice Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
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

    /// @notice Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
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

    /// @notice Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
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

    /// @notice Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
    /// through a deposit call.
    /// @dev
    /// - MUST return a limited value if receiver is subject to some deposit limit.
    /// - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
    /// - MUST NOT revert.
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
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
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

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
    function maxMint(address receiver) external view returns (uint256 maxShares);

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
    function previewMint(uint256 shares) external view returns (uint256 assets);

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
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

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
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

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
    function maxRedeem(address owner) external view returns (uint256 maxShares);

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
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

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

// File: lib/euler-price-oracle/src/interfaces/IPriceOracle.sol

pragma solidity >=0.8.0;

/// @title IPriceOracle
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Common PriceOracle interface.
interface IPriceOracle {
    /// @notice Get the name of the oracle.
    /// @return The name of the oracle.
    function name() external view returns (string memory);

    /// @notice One-sided price: How much quote token you would get for inAmount of base token, assuming no price spread.
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

// File: lib/euler-price-oracle/src/lib/Errors.sol

pragma solidity ^0.8.0;

/// @title Errors
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Collects common errors in PriceOracles.
library Errors {
    /// @notice The external feed returned an invalid answer.
    error PriceOracle_InvalidAnswer();
    /// @notice The configuration parameters for the PriceOracle are invalid.
    error PriceOracle_InvalidConfiguration();
    /// @notice The base/quote path is not supported.
    /// @param base The address of the base asset.
    /// @param quote The address of the quote asset.
    error PriceOracle_NotSupported(address base, address quote);
    /// @notice The quote cannot be completed due to overflow.
    error PriceOracle_Overflow();
    /// @notice The price is too stale.
    /// @param staleness The time elapsed since the price was updated.
    /// @param maxStaleness The maximum time elapsed since the last price update.
    error PriceOracle_TooStale(uint256 staleness, uint256 maxStaleness);
    /// @notice The method can only be called by the governor.
    error Governance_CallerNotGovernor();
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

// File: lib/ethereum-vault-connector/src/ExecutionContext.sol

pragma solidity ^0.8.0;

type EC is uint256;

/// @title ExecutionContext
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This library provides functions for managing the execution context in the Ethereum Vault Connector.
/// @dev The execution context is a bit field that stores the following information:
/// @dev - on behalf of account - an account on behalf of which the currently executed operation is being performed
/// @dev - checks deferred flag - used to indicate whether checks are deferred
/// @dev - checks in progress flag - used to indicate that the account/vault status checks are in progress. This flag is
/// used to prevent re-entrancy.
/// @dev - control collateral in progress flag - used to indicate that the control collateral is in progress. This flag
/// is used to prevent re-entrancy.
/// @dev - operator authenticated flag - used to indicate that the currently executed operation is being performed by
/// the account operator
/// @dev - simulation flag - used to indicate that the currently executed batch call is a simulation
/// @dev - stamp - dummy value for optimization purposes
library ExecutionContext {
    uint256 internal constant ON_BEHALF_OF_ACCOUNT_MASK =
        0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 internal constant CHECKS_DEFERRED_MASK = 0x0000000000000000000000FF0000000000000000000000000000000000000000;
    uint256 internal constant CHECKS_IN_PROGRESS_MASK =
        0x00000000000000000000FF000000000000000000000000000000000000000000;
    uint256 internal constant CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK =
        0x000000000000000000FF00000000000000000000000000000000000000000000;
    uint256 internal constant OPERATOR_AUTHENTICATED_MASK =
        0x0000000000000000FF0000000000000000000000000000000000000000000000;
    uint256 internal constant SIMULATION_MASK = 0x00000000000000FF000000000000000000000000000000000000000000000000;
    uint256 internal constant STAMP_OFFSET = 200;

    // None of the functions below modifies the state. All the functions operate on the copy
    // of the execution context and return its modified value as a result. In order to update
    // one should use the result of the function call as a new execution context value.

    function getOnBehalfOfAccount(EC self) internal pure returns (address result) {
        result = address(uint160(EC.unwrap(self) & ON_BEHALF_OF_ACCOUNT_MASK));
    }

    function setOnBehalfOfAccount(EC self, address account) internal pure returns (EC result) {
        result = EC.wrap((EC.unwrap(self) & ~ON_BEHALF_OF_ACCOUNT_MASK) | uint160(account));
    }

    function areChecksDeferred(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CHECKS_DEFERRED_MASK != 0;
    }

    function setChecksDeferred(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CHECKS_DEFERRED_MASK);
    }

    function areChecksInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CHECKS_IN_PROGRESS_MASK != 0;
    }

    function setChecksInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CHECKS_IN_PROGRESS_MASK);
    }

    function isControlCollateralInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK != 0;
    }

    function setControlCollateralInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK);
    }

    function isOperatorAuthenticated(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & OPERATOR_AUTHENTICATED_MASK != 0;
    }

    function setOperatorAuthenticated(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | OPERATOR_AUTHENTICATED_MASK);
    }

    function clearOperatorAuthenticated(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) & ~OPERATOR_AUTHENTICATED_MASK);
    }

    function isSimulationInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & SIMULATION_MASK != 0;
    }

    function setSimulationInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | SIMULATION_MASK);
    }
}

// File: lib/ethereum-vault-connector/src/utils/EVCUtil.sol

pragma solidity ^0.8.0;




/// @title EVCUtil
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This contract is an abstract base contract for interacting with the Ethereum Vault Connector (EVC).
/// It provides utility functions for authenticating the callers in the context of the EVC, a pattern for enforcing the
/// contracts to be called through the EVC.
abstract contract EVCUtil {
    using ExecutionContext for EC;

    uint160 internal constant ACCOUNT_ID_OFFSET = 8;
    IEVC internal immutable evc;

    error EVC_InvalidAddress();
    error NotAuthorized();
    error ControllerDisabled();

    constructor(address _evc) {
        if (_evc == address(0)) revert EVC_InvalidAddress();

        evc = IEVC(_evc);
    }

    /// @notice Returns the address of the Ethereum Vault Connector (EVC) used by this contract.
    /// @return The address of the EVC contract.
    function EVC() external view returns (address) {
        return address(evc);
    }

    /// @notice Ensures that the msg.sender is the EVC by using the EVC callback functionality if necessary.
    /// @dev Optional to use for functions requiring account and vault status checks to enforce predictable behavior.
    /// @dev If this modifier used in conjuction with any other modifier, it must appear as the first (outermost)
    /// modifier of the function.
    modifier callThroughEVC() virtual {
        _callThroughEVC();
        _;
    }

    /// @notice Ensures that the caller is the EVC in the appropriate context.
    /// @dev Should be used for checkAccountStatus and checkVaultStatus functions.
    modifier onlyEVCWithChecksInProgress() virtual {
        _onlyEVCWithChecksInProgress();
        _;
    }

    /// @notice Ensures a standard authentication path on the EVC.
    /// @dev This modifier checks if the caller is the EVC and if so, verifies the execution context.
    /// It reverts if the operator is authenticated, control collateral is in progress, or checks are in progress.
    /// It reverts if the authenticated account owner is known and it is not the account owner.
    /// @dev It assumes that if the caller is not the EVC, the caller is the account owner.
    /// @dev This modifier must not be used on functions utilized by liquidation flows, i.e. transfer or withdraw.
    /// @dev This modifier must not be used on checkAccountStatus and checkVaultStatus functions.
    /// @dev This modifier can be used on access controlled functions to prevent non-standard authentication paths on
    /// the EVC.
    modifier onlyEVCAccountOwner() virtual {
        _onlyEVCAccountOwner();
        _;
    }

    /// @notice Checks whether the specified account and the other account have the same owner.
    /// @dev The function is used to check whether one account is authorized to perform operations on behalf of the
    /// other. Accounts are considered to have a common owner if they share the first 19 bytes of their address.
    /// @param account The address of the account that is being checked.
    /// @param otherAccount The address of the other account that is being checked.
    /// @return A boolean flag that indicates whether the accounts have the same owner.
    function _haveCommonOwner(address account, address otherAccount) internal pure returns (bool) {
        bool result;
        assembly {
            result := lt(xor(account, otherAccount), 0x100)
        }
        return result;
    }

    /// @notice Returns the address prefix of the specified account.
    /// @dev The address prefix is the first 19 bytes of the account address.
    /// @param account The address of the account whose address prefix is being retrieved.
    /// @return A bytes19 value that represents the address prefix of the account.
    function _getAddressPrefix(address account) internal pure returns (bytes19) {
        return bytes19(uint152(uint160(account) >> ACCOUNT_ID_OFFSET));
    }

    /// @notice Retrieves the message sender in the context of the EVC.
    /// @dev This function returns the account on behalf of which the current operation is being performed, which is
    /// either msg.sender or the account authenticated by the EVC.
    /// @return The address of the message sender.
    function _msgSender() internal view virtual returns (address) {
        address sender = msg.sender;

        if (sender == address(evc)) {
            (sender,) = evc.getCurrentOnBehalfOfAccount(address(0));
        }

        return sender;
    }

    /// @notice Retrieves the message sender in the context of the EVC for a borrow operation.
    /// @dev This function returns the account on behalf of which the current operation is being performed, which is
    /// either msg.sender or the account authenticated by the EVC. This function reverts if this contract is not enabled
    /// as a controller for the account on behalf of which the operation is being executed.
    /// @return The address of the message sender.
    function _msgSenderForBorrow() internal view virtual returns (address) {
        address sender = msg.sender;
        bool controllerEnabled;

        if (sender == address(evc)) {
            (sender, controllerEnabled) = evc.getCurrentOnBehalfOfAccount(address(this));
        } else {
            controllerEnabled = evc.isControllerEnabled(sender, address(this));
        }

        if (!controllerEnabled) {
            revert ControllerDisabled();
        }

        return sender;
    }

    /// @notice Calls the current external function through the EVC.
    /// @dev This function is used to route the current call through the EVC if it's not already coming from the EVC. It
    /// makes the EVC set the execution context and call back this contract with unchanged calldata. msg.sender is used
    /// as the onBehalfOfAccount.
    /// @dev This function shall only be used by the callThroughEVC modifier.
    function _callThroughEVC() internal {
        address _evc = address(evc);
        if (msg.sender == _evc) return;

        assembly {
            mstore(0, 0x1f8b521500000000000000000000000000000000000000000000000000000000) // EVC.call selector
            mstore(4, address()) // EVC.call 1st argument - address(this)
            mstore(36, caller()) // EVC.call 2nd argument - msg.sender
            mstore(68, callvalue()) // EVC.call 3rd argument - msg.value
            mstore(100, 128) // EVC.call 4th argument - msg.data, offset to the start of encoding - 128 bytes
            mstore(132, calldatasize()) // msg.data length
            calldatacopy(164, 0, calldatasize()) // original calldata

            // abi encoded bytes array should be zero padded so its length is a multiple of 32
            // store zero word after msg.data bytes and round up calldatasize to nearest multiple of 32
            mstore(add(164, calldatasize()), 0)
            let result := call(gas(), _evc, callvalue(), 0, add(164, and(add(calldatasize(), 31), not(31))), 0, 0)

            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(64, sub(returndatasize(), 64)) } // strip bytes encoding from call return
        }
    }

    /// @notice Ensures that the function is called only by the EVC during the checks phase
    /// @dev Reverts if the caller is not the EVC or if checks are not in progress.
    function _onlyEVCWithChecksInProgress() internal view {
        if (msg.sender != address(evc) || !evc.areChecksInProgress()) {
            revert NotAuthorized();
        }
    }

    /// @notice Ensures that the function is called only by the EVC account owner
    /// @dev This function checks if the caller is the EVC and if so, verifies that the execution context is not in a
    /// special state (operator authenticated, collateral control in progress, or checks in progress). If the owner was
    /// already registered on the EVC, it verifies that the onBehalfOfAccount is the owner.
    /// @dev Reverts if the caller is not the EVC or if the execution context is in a special state.
    function _onlyEVCAccountOwner() internal view {
        if (msg.sender == address(evc)) {
            EC ec = EC.wrap(evc.getRawExecutionContext());

            if (ec.isOperatorAuthenticated() || ec.isControlCollateralInProgress() || ec.areChecksInProgress()) {
                revert NotAuthorized();
            }

            address onBehalfOfAccount = ec.getOnBehalfOfAccount();
            address owner = evc.getAccountOwner(onBehalfOfAccount);

            if (owner != address(0) && owner != onBehalfOfAccount) {
                revert NotAuthorized();
            }
        }
    }
}

// File: lib/euler-price-oracle/src/lib/Governable.sol

pragma solidity ^0.8.0;




/// @title Governable
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Contract mixin for governance, compatible with EVC.
abstract contract Governable is EVCUtil {
    /// @notice The active governor address. If `address(0)` then the role is renounced.
    address public governor;

    /// @notice Set the governor of the contract.
    /// @param oldGovernor The address of the previous governor.
    /// @param newGovernor The address of the newly appointed governor.
    event GovernorSet(address indexed oldGovernor, address indexed newGovernor);

    constructor(address _evc, address _governor) EVCUtil(_evc) {
        _setGovernor(_governor);
    }

    /// @notice Transfer the governor role to another address.
    /// @param newGovernor The address of the next governor.
    /// @dev Can only be called by the current governor.
    function transferGovernance(address newGovernor) external onlyEVCAccountOwner onlyGovernor {
        _setGovernor(newGovernor);
    }

    /// @notice Restrict access to the governor.
    /// @dev Consider also adding `onlyEVCAccountOwner` for stricter caller checks.
    modifier onlyGovernor() {
        if (_msgSender() != governor) {
            revert Errors.Governance_CallerNotGovernor();
        }
        _;
    }

    /// @notice Set the governor address.
    /// @param newGovernor The address of the new governor.
    function _setGovernor(address newGovernor) internal {
        emit GovernorSet(governor, newGovernor);
        governor = newGovernor;
    }
}

// File: lib/euler-price-oracle/src/EulerRouter.sol

pragma solidity ^0.8.0;






/// @title EulerRouter
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Default Oracle resolver for Euler lending products.
/// @dev Integration Note: The router supports pricing via `convertToAssets` for trusted `resolvedVaults`.
/// By ERC4626 spec `convert*` ignores liquidity restrictions, fees, slippage and per-user restrictions.
/// Therefore the reported price may not be realizable through `redeem` or `withdraw`.
contract EulerRouter is Governable, IPriceOracle {
    /// @inheritdoc IPriceOracle
    string public constant name = "EulerRouter";
    /// @notice The PriceOracle to call if this router is not configured for base/quote.
    /// @dev If `address(0)` then there is no fallback.
    address public fallbackOracle;
    /// @notice ERC4626 vaults resolved using internal pricing (`convertToAssets`).
    mapping(address vault => address asset) public resolvedVaults;
    /// @notice PriceOracle configured per asset pair.
    /// @dev The keys are lexicographically sorted (asset0 < asset1).
    mapping(address asset0 => mapping(address asset1 => address oracle)) internal oracles;

    /// @notice Configure a PriceOracle to resolve an asset pair.
    /// @param asset0 The address first in lexicographic order.
    /// @param asset1 The address second in lexicographic order.
    /// @param oracle The address of the PriceOracle that resolves the pair.
    /// @dev If `oracle` is `address(0)` then the configuration was removed.
    /// The keys are lexicographically sorted (asset0 < asset1).
    event ConfigSet(address indexed asset0, address indexed asset1, address indexed oracle);
    /// @notice Set a PriceOracle as a fallback resolver.
    /// @param fallbackOracle The address of the PriceOracle that is called when base/quote is not configured.
    /// @dev If `fallbackOracle` is `address(0)` then there is no fallback resolver.
    event FallbackOracleSet(address indexed fallbackOracle);
    /// @notice Mark an ERC4626 vault to be resolved to its `asset` via its `convert*` methods.
    /// @param vault The address of the ERC4626 vault.
    /// @param asset The address of the vault's asset.
    /// @dev If `asset` is `address(0)` then the configuration was removed.
    event ResolvedVaultSet(address indexed vault, address indexed asset);

    /// @notice Deploy EulerRouter.
    /// @param _governor The address of the governor.
    constructor(address _evc, address _governor) Governable(_evc, _governor) {
        if (_governor == address(0)) revert Errors.PriceOracle_InvalidConfiguration();
    }

    /// @notice Configure a PriceOracle to resolve base/quote and quote/base.
    /// @param base The address of the base token.
    /// @param quote The address of the quote token.
    /// @param oracle The address of the PriceOracle to resolve the pair.
    /// @dev Callable only by the governor.
    function govSetConfig(address base, address quote, address oracle) external onlyEVCAccountOwner onlyGovernor {
        // This case is handled by `resolveOracle`.
        if (base == quote) revert Errors.PriceOracle_InvalidConfiguration();
        (address asset0, address asset1) = _sort(base, quote);
        oracles[asset0][asset1] = oracle;
        emit ConfigSet(asset0, asset1, oracle);
    }

    /// @notice Configure an ERC4626 vault to use internal pricing via `convert*` methods.
    /// @param vault The address of the ERC4626 vault.
    /// @param set True to configure the vault, false to clear the record.
    /// @dev Callable only by the governor. Vault must implement ERC4626.
    /// Note: Before configuring a vault verify that its `convertToAssets` is secure.
    function govSetResolvedVault(address vault, bool set) external onlyEVCAccountOwner onlyGovernor {
        address asset = set ? IERC4626(vault).asset() : address(0);
        resolvedVaults[vault] = asset;
        emit ResolvedVaultSet(vault, asset);
    }

    /// @notice Set a PriceOracle as a fallback resolver.
    /// @param _fallbackOracle The address of the PriceOracle that is called when base/quote is not configured.
    /// @dev Callable only by the governor. `address(0)` removes the fallback.
    function govSetFallbackOracle(address _fallbackOracle) external onlyEVCAccountOwner onlyGovernor {
        fallbackOracle = _fallbackOracle;
        emit FallbackOracleSet(_fallbackOracle);
    }

    /// @inheritdoc IPriceOracle
    function getQuote(uint256 inAmount, address base, address quote) external view returns (uint256) {
        address oracle;
        (inAmount, base, quote, oracle) = resolveOracle(inAmount, base, quote);
        if (base == quote) return inAmount;
        return IPriceOracle(oracle).getQuote(inAmount, base, quote);
    }

    /// @inheritdoc IPriceOracle
    function getQuotes(uint256 inAmount, address base, address quote) external view returns (uint256, uint256) {
        address oracle;
        (inAmount, base, quote, oracle) = resolveOracle(inAmount, base, quote);
        if (base == quote) return (inAmount, inAmount);
        return IPriceOracle(oracle).getQuotes(inAmount, base, quote);
    }

    /// @notice Get the PriceOracle configured for base/quote.
    /// @param base The address of the base token.
    /// @param quote The address of the quote token.
    /// @return The configured `PriceOracle` for the pair or `address(0)` if no oracle is configured.
    function getConfiguredOracle(address base, address quote) public view returns (address) {
        (address asset0, address asset1) = _sort(base, quote);
        return oracles[asset0][asset1];
    }

    /// @notice Resolve the PriceOracle to call for a given base/quote pair.
    /// @param inAmount The amount of `base` to convert.
    /// @param base The token that is being priced.
    /// @param quote The token that is the unit of account.
    /// @dev Implements the following resolution logic:
    /// 1. Check the base case: `base == quote` and terminate if true.
    /// 2. If a PriceOracle is configured for base/quote in the `oracles` mapping, return it.
    /// 3. If `base` is configured as a resolved ERC4626 vault, call `convertToAssets(inAmount)`
    /// and continue the recursion, substituting the ERC4626 `asset` for `base`.
    /// 4. As a last resort, return the fallback oracle or revert if it is not set.
    /// @return The resolved amount. This value may be different from the original `inAmount`
    /// if the resolution path included an ERC4626 vault present in `resolvedVaults`.
    /// @return The resolved base.
    /// @return The resolved quote.
    /// @return The resolved PriceOracle to call.
    function resolveOracle(uint256 inAmount, address base, address quote)
        public
        view
        returns (uint256, /* resolvedAmount */ address, /* base */ address, /* quote */ address /* oracle */ )
    {
        // 1. Check the base case.
        if (base == quote) return (inAmount, base, quote, address(0));
        // 2. Check if there is a PriceOracle configured for base/quote.
        address oracle = getConfiguredOracle(base, quote);
        if (oracle != address(0)) return (inAmount, base, quote, oracle);
        // 3. Recursively resolve `base`.
        address baseAsset = resolvedVaults[base];
        if (baseAsset != address(0)) {
            inAmount = IERC4626(base).convertToAssets(inAmount);
            return resolveOracle(inAmount, baseAsset, quote);
        }
        // 4. Return the fallback or revert if not configured.
        oracle = fallbackOracle;
        if (oracle == address(0)) revert Errors.PriceOracle_NotSupported(base, quote);
        return (inAmount, base, quote, oracle);
    }

    /// @notice Lexicographically sort two addresses.
    /// @param assetA One of the assets in the pair.
    /// @param assetB The other asset in the pair.
    /// @return The address first in lexicographic order.
    /// @return The address second in lexicographic order.
    function _sort(address assetA, address assetB) internal pure returns (address, address) {
        return assetA < assetB ? (assetA, assetB) : (assetB, assetA);
    }
}
