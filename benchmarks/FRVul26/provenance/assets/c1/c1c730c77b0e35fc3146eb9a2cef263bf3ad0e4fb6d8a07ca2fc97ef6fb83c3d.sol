// Sources retrieved from Blockscout Ethereum API v2.

// ===== contracts/spoke-pools/Ethereum_SpokePool.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./SpokePool.sol";
import "@openzeppelin/contracts-upgradeable-v4/access/OwnableUpgradeable.sol";

/**
 * @notice Ethereum L1 specific SpokePool. Used on Ethereum L1 to facilitate L2->L1 transfers.
 * @custom:security-contact bugs@across.to
 */
contract Ethereum_SpokePool is SpokePool, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address _wrappedNativeTokenAddress,
        uint32 _depositQuoteTimeBuffer,
        uint32 _fillDeadlineBuffer,
        address _gateway
    )
        SpokePool(
            _wrappedNativeTokenAddress,
            _depositQuoteTimeBuffer,
            _fillDeadlineBuffer,
            // Ethereum_SpokePool does not use OFT messaging; setting destination eid and fee cap to 0
            0,
            0,
            _gateway
        )
    {} // solhint-disable-line no-empty-blocks

    /**
     * @notice Construct the Ethereum SpokePool.
     * @dev crossDomainAdmin is unused on this contract.
     * @param _initialDepositId Starting deposit ID. Set to 0 unless this is a re-deployment in order to mitigate
     * relay hash collisions.
     * @param _withdrawalRecipient Address which receives token withdrawals. Can be changed by admin. For Spoke Pools on L2, this will
     * likely be the hub pool.
     */
    function initialize(uint32 _initialDepositId, address _withdrawalRecipient) public initializer {
        __Ownable_init();
        __SpokePool_init(_initialDepositId, _withdrawalRecipient, _withdrawalRecipient);
    }

    /**************************************
     *          INTERNAL FUNCTIONS           *
     **************************************/

    function _bridgeTokensToHubPool(uint256 amountToReturn, address l2TokenAddress) internal override {
        IERC20Upgradeable(l2TokenAddress).safeTransfer(withdrawalRecipient, amountToReturn);
    }

    // The SpokePool deployed to the same network as the HubPool must be owned by the HubPool.
    // A core assumption of this contract system is that the HubPool is deployed on Ethereum.
    function _requireAdminSender() internal override onlyOwner {}
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/interfaces/draft-IERC1822Upgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}


// ===== contracts/interfaces/V3SpokePoolInterface.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contains structs and functions used by SpokePool contracts to facilitate universal settlement.
interface V3SpokePoolInterface {
    /**************************************
     *              ENUMS                 *
     **************************************/

    // Fill status tracks on-chain state of deposit, uniquely identified by relayHash.
    enum FillStatus {
        Unfilled,
        RequestedSlowFill,
        Filled
    }
    // Fill type is emitted in the FilledRelay event to assist Dataworker with determining which types of
    // fills to refund (e.g. only fast fills) and whether a fast fill created a sow fill excess.
    enum FillType {
        FastFill,
        // Fast fills are normal fills that do not replace a slow fill request.
        ReplacedSlowFill,
        // Replaced slow fills are fast fills that replace a slow fill request. This type is used by the Dataworker
        // to know when to send excess funds from the SpokePool to the HubPool because they can no longer be used
        // for a slow fill execution.
        SlowFill
    }
    // Slow fills are requested via requestSlowFill and executed by executeSlowRelayLeaf after a bundle containing
    // the slow fill is validated.

    /**************************************
     *              STRUCTS               *
     **************************************/

    // This struct represents the data to fully specify a **unique** relay submitted on this chain.
    // This data is hashed with the chainId() and saved by the SpokePool to prevent collisions and protect against
    // replay attacks on other chains. If any portion of this data differs, the relay is considered to be
    // completely distinct.
    struct V3RelayData {
        // The bytes32 that made the deposit on the origin chain.
        bytes32 depositor;
        // The recipient bytes32 on the destination chain.
        bytes32 recipient;
        // This is the exclusive relayer who can fill the deposit before the exclusivity deadline.
        bytes32 exclusiveRelayer;
        // Token that is deposited on origin chain by depositor.
        bytes32 inputToken;
        // Token that is received on destination chain by recipient.
        bytes32 outputToken;
        // The amount of input token deposited by depositor.
        uint256 inputAmount;
        // The amount of output token to be received by recipient.
        uint256 outputAmount;
        // Origin chain id.
        uint256 originChainId;
        // The id uniquely identifying this deposit on the origin chain.
        uint256 depositId;
        // The timestamp on the destination chain after which this deposit can no longer be filled.
        uint32 fillDeadline;
        // The timestamp on the destination chain after which any relayer can fill the deposit.
        uint32 exclusivityDeadline;
        // Data that is forwarded to the recipient.
        bytes message;
    }

    // Same as V3RelayData but using addresses instead of bytes32 & depositId is uint32.
    // Will be deprecated in favor of V3RelayData in the future.
    struct V3RelayDataLegacy {
        address depositor;
        address recipient;
        address exclusiveRelayer;
        address inputToken;
        address outputToken;
        uint256 inputAmount;
        uint256 outputAmount;
        uint256 originChainId;
        uint32 depositId;
        uint32 fillDeadline;
        uint32 exclusivityDeadline;
        bytes message;
    }

    // Contains parameters passed in by someone who wants to execute a slow relay leaf.
    struct V3SlowFill {
        V3RelayData relayData;
        uint256 chainId;
        uint256 updatedOutputAmount;
    }

    // Contains information about a relay to be sent along with additional information that is not unique to the
    // relay itself but is required to know how to process the relay. For example, "updatedX" fields can be used
    // by the relayer to modify fields of the relay with the depositor's permission, and "repaymentChainId" is specified
    // by the relayer to determine where to take a relayer refund, but doesn't affect the uniqueness of the relay.
    struct V3RelayExecutionParams {
        V3RelayData relay;
        bytes32 relayHash;
        uint256 updatedOutputAmount;
        bytes32 updatedRecipient;
        bytes updatedMessage;
        uint256 repaymentChainId;
    }

    // Packs together parameters emitted in FilledRelay because there are too many emitted otherwise.
    // Similar to V3RelayExecutionParams, these parameters are not used to uniquely identify the deposit being
    // filled so they don't have to be unpacked by all clients.
    struct V3RelayExecutionEventInfo {
        bytes32 updatedRecipient;
        bytes32 updatedMessageHash;
        uint256 updatedOutputAmount;
        FillType fillType;
    }

    // Represents the parameters required for a V3 deposit operation in the SpokePool.
    struct DepositV3Params {
        bytes32 depositor;
        bytes32 recipient;
        bytes32 inputToken;
        bytes32 outputToken;
        uint256 inputAmount;
        uint256 outputAmount;
        uint256 destinationChainId;
        bytes32 exclusiveRelayer;
        uint256 depositId;
        uint32 quoteTimestamp;
        uint32 fillDeadline;
        uint32 exclusivityParameter;
        bytes message;
    }

    /**************************************
     *              EVENTS                *
     **************************************/

    event FundsDeposited(
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 indexed destinationChainId,
        uint256 indexed depositId,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes32 indexed depositor,
        bytes32 recipient,
        bytes32 exclusiveRelayer,
        bytes message
    );

    event RequestedSpeedUpDeposit(
        uint256 updatedOutputAmount,
        uint256 indexed depositId,
        bytes32 indexed depositor,
        bytes32 updatedRecipient,
        bytes updatedMessage,
        bytes depositorSignature
    );

    event FilledRelay(
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 repaymentChainId,
        uint256 indexed originChainId,
        uint256 indexed depositId,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes32 exclusiveRelayer,
        bytes32 indexed relayer,
        bytes32 depositor,
        bytes32 recipient,
        bytes32 messageHash,
        V3RelayExecutionEventInfo relayExecutionInfo
    );

    event RequestedSlowFill(
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 indexed originChainId,
        uint256 indexed depositId,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes32 exclusiveRelayer,
        bytes32 depositor,
        bytes32 recipient,
        bytes32 messageHash
    );

    event ClaimedRelayerRefund(
        bytes32 indexed l2TokenAddress,
        bytes32 indexed refundAddress,
        uint256 amount,
        address indexed caller
    );

    /**************************************
     *              FUNCTIONS             *
     **************************************/

    function deposit(
        bytes32 depositor,
        bytes32 recipient,
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        bytes32 exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;

    function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;

    function depositNow(
        bytes32 depositor,
        bytes32 recipient,
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        bytes32 exclusiveRelayer,
        uint32 fillDeadlineOffset,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;

    function depositV3Now(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 fillDeadlineOffset,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;

    function unsafeDeposit(
        bytes32 depositor,
        bytes32 recipient,
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        bytes32 exclusiveRelayer,
        uint256 depositNonce,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityParameter,
        bytes calldata message
    ) external payable;

    function speedUpDeposit(
        bytes32 depositor,
        uint256 depositId,
        uint256 updatedOutputAmount,
        bytes32 updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) external;

    function speedUpV3Deposit(
        address depositor,
        uint256 depositId,
        uint256 updatedOutputAmount,
        address updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) external;

    function fillRelay(V3RelayData calldata relayData, uint256 repaymentChainId, bytes32 repaymentAddress) external;

    function fillV3Relay(V3RelayDataLegacy calldata relayData, uint256 repaymentChainId) external;

    function fillRelayWithUpdatedDeposit(
        V3RelayData calldata relayData,
        uint256 repaymentChainId,
        bytes32 repaymentAddress,
        uint256 updatedOutputAmount,
        bytes32 updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) external;

    function requestSlowFill(V3RelayData calldata relayData) external;

    function executeSlowRelayLeaf(
        V3SlowFill calldata slowFillLeaf,
        uint32 rootBundleId,
        bytes32[] calldata proof
    ) external;

    function claimRelayerRefund(bytes32 l2TokenAddress, bytes32 refundAddress) external;

    function getUnsafeDepositId(
        address msgSender,
        bytes32 depositor,
        uint256 depositNonce
    ) external pure returns (uint256);

    function numberOfDeposits() external view returns (uint32);

    /**************************************
     *              ERRORS                *
     **************************************/

    error DisabledRoute();
    error InvalidQuoteTimestamp();
    error InvalidFillDeadline();
    error InvalidExclusiveRelayer();
    error InvalidOutputToken();
    error RemovedFunction();
    error MsgValueDoesNotMatchInputAmount();
    error NotExclusiveRelayer();
    error NoSlowFillsInExclusivityWindow();
    error RelayFilled();
    error InvalidSlowFillRequest();
    error ExpiredFillDeadline();
    error InvalidMerkleProof();
    error InvalidChainId();
    error InvalidMerkleLeaf();
    error ClaimedMerkleLeaf();
    error InvalidPayoutAdjustmentPct();
    error WrongERC7683OrderId();
    error LowLevelCallFailed(bytes data);
    error InsufficientSpokePoolBalanceToExecuteLeaf();
    error NoRelayerRefundToClaim();

    /**************************************
     *             LEGACY EVENTS          *
     **************************************/

    // Note: these events are unused, but included in the ABI for ease of migration.
    event V3FundsDeposited(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 indexed destinationChainId,
        uint32 indexed depositId,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address indexed depositor,
        address recipient,
        address exclusiveRelayer,
        bytes message
    );

    event RequestedSpeedUpV3Deposit(
        uint256 updatedOutputAmount,
        uint32 indexed depositId,
        address indexed depositor,
        address updatedRecipient,
        bytes updatedMessage,
        bytes depositorSignature
    );

    // Legacy struct only used to preserve the FilledV3Relay event definition.
    struct LegacyV3RelayExecutionEventInfo {
        address updatedRecipient;
        bytes updatedMessage;
        uint256 updatedOutputAmount;
        FillType fillType;
    }

    event FilledV3Relay(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 repaymentChainId,
        uint256 indexed originChainId,
        uint32 indexed depositId,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address exclusiveRelayer,
        address indexed relayer,
        address depositor,
        address recipient,
        bytes message,
        LegacyV3RelayExecutionEventInfo relayExecutionInfo
    );

    event RequestedV3SlowFill(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 indexed originChainId,
        uint32 indexed depositId,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address exclusiveRelayer,
        address depositor,
        address recipient,
        bytes message
    );
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/proxy/utils/UUPSUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import {Initializable} from "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeTo(address newImplementation) public virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// ===== node_modules/@openzeppelin/contracts-v4/utils/Address.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/proxy/utils/Initializable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
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
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
        if (_initialized != type(uint8).max) {
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


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/proxy/beacon/IBeaconUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}


// ===== contracts/interfaces/IOFT.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @notice This file contains minimal copies of relevant structs / interfaces for OFT bridging. Source code link:
 * https://github.com/LayerZero-Labs/LayerZero-v2/blob/9a4049ae3a374e1c0ef01ac9fb53dd83f4257a68/packages/layerzero-v2/evm/oapp/contracts/oft/interfaces/IOFT.sol
 * It's also published as a part of an npm package: @layerzerolabs/oft-evm. The published code is incompatible with
 * our compiler version requirements, so we copy it here instead
 */

struct MessagingReceipt {
    bytes32 guid;
    uint64 nonce;
    MessagingFee fee;
}

struct MessagingFee {
    uint256 nativeFee;
    uint256 lzTokenFee;
}

/**
 * @dev Struct representing token parameters for the OFT send() operation.
 */
struct SendParam {
    uint32 dstEid; // Destination endpoint ID.
    bytes32 to; // Recipient address.
    uint256 amountLD; // Amount to send in local decimals.
    uint256 minAmountLD; // Minimum amount to send in local decimals.
    bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
    bytes composeMsg; // The composed message for the send() operation.
    bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
}

/**
 * @dev Struct representing OFT receipt information.
 */
struct OFTReceipt {
    uint256 amountSentLD; // Amount of tokens ACTUALLY debited from the sender in local decimals.
    // @dev In non-default implementations, the amountReceivedLD COULD differ from this value.
    uint256 amountReceivedLD; // Amount of tokens to be received on the remote side.
}

/**
 * @title IOFT
 * @dev Interface for the OftChain (OFT) token.
 * @dev Does not inherit ERC20 to accommodate usage by OFTAdapter as well.
 * @dev This specific interface ID is '0x02e49c2c'.
 */
interface IOFT {
    /**
     * @notice Retrieves the address of the token associated with the OFT.
     * @return token The address of the ERC20 token implementation.
     */
    function token() external view returns (address);

    /**
     * @notice Retrieves the shared decimals of the OFT.
     * @return sharedDecimals The shared decimals of the OFT.
     */
    function sharedDecimals() external view returns (uint8);

    /**
     * @notice Provides a quote for the send() operation.
     * @param _sendParam The parameters for the send() operation.
     * @param _payInLzToken Flag indicating whether the caller is paying in the LZ token.
     * @return fee The calculated LayerZero messaging fee from the send() operation.
     *
     * @dev MessagingFee: LayerZero msg fee
     *  - nativeFee: The native fee.
     *  - lzTokenFee: The lzToken fee.
     */
    function quoteSend(SendParam calldata _sendParam, bool _payInLzToken) external view returns (MessagingFee memory);

    /**
     * @notice Executes the send() operation.
     * @param _sendParam The parameters for the send operation.
     * @param _fee The fee information supplied by the caller.
     *      - nativeFee: The native fee.
     *      - lzTokenFee: The lzToken fee.
     * @param _refundAddress The address to receive any excess funds from fees etc. on the src.
     * @return receipt The LayerZero messaging receipt from the send() operation.
     * @return oftReceipt The OFT receipt information.
     *
     * @dev MessagingReceipt: LayerZero msg receipt
     *  - guid: The unique identifier for the sent message.
     *  - nonce: The nonce of the sent message.
     *  - fee: The LayerZero fee incurred for the message.
     */
    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory, OFTReceipt memory);
}

interface IEndpoint {
    function eid() external view returns (uint32);
}

interface IOAppCore {
    /**
     * @notice Retrieves the LayerZero endpoint associated with the OApp.
     * @return iEndpoint The LayerZero endpoint as an interface.
     */
    function endpoint() external view returns (IEndpoint iEndpoint);
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/utils/AddressUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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


// ===== contracts/external/interfaces/IGateway.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @notice Read-only subset of the Across V5 Gateway interface: the live execution-context getters the SpokePool
 * needs to authenticate and parameterize V5 fills. The canonical, full interface lives in the Across V5
 * periphery repository. All getters are backed by transient storage on the Gateway and return zero values when
 * no execution is in flight.
 */
interface IGateway {
    /// @notice Active step id (the Merkle root) for the currently executing step, or bytes32(0) when idle.
    function currentStepId() external view returns (bytes32);

    /// @notice Active path id (the path's Merkle leaf hash) for the currently executing step, or bytes32(0) when idle.
    function currentPathId() external view returns (bytes32);

    /// @notice Active submitter (the `execute()` caller) for the currently executing step, or address(0) when idle.
    function currentSubmitter() external view returns (address);

    /// @notice The committed executor of the currently executing step, or address(0) when no executor call is in
    /// flight. The Gateway sets this immediately before calling the committed executor and clears it right after
    /// the call returns — so it reads zero while idle AND while the uncommitted funding loop runs. That is what
    /// makes `msg.sender == currentExecutor()` the complete funding-adapter boundary check.
    function currentExecutor() external view returns (address);
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/utils/StorageSlotUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}


// ===== node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// ===== node_modules/@openzeppelin/contracts/interfaces/IERC1363.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

pragma solidity >=0.6.2;

import {IERC20} from "./IERC20.sol";
import {IERC165} from "./IERC165.sol";

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/utils/math/SignedMathUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMathUpgradeable {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/interfaces/IERC1967Upgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC1967.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 *
 * _Available since v4.8.3._
 */
interface IERC1967Upgradeable {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
}


// ===== contracts/external/interfaces/WETH9Interface.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @notice Interface for the WETH9 contract.
 */
interface WETH9Interface {
    /**
     * @notice Burn Wrapped Ether and receive native Ether.
     * @param wad Amount of WETH to unwrap and send to caller.
     */
    function withdraw(uint256 wad) external;

    /**
     * @notice Lock native Ether and mint Wrapped Ether ERC20
     * @dev msg.value is amount of Wrapped Ether to mint/Ether to lock.
     */
    function deposit() external payable;

    /**
     * @notice Get balance of WETH held by `guy`.
     * @param guy Address to get balance of.
     * @return wad Amount of WETH held by `guy`.
     */
    function balanceOf(address guy) external view returns (uint256 wad);

    /**
     * @notice Transfer `wad` of WETH from caller to `guy`.
     * @param guy Address to send WETH to.
     * @param wad Amount of WETH to send.
     * @return ok True if transfer succeeded.
     */
    function transfer(address guy, uint256 wad) external returns (bool);
}


// ===== contracts/interfaces/HubPoolInterface.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";

/**
 * @notice Concise list of functions in HubPool implementation.
 */
interface HubPoolInterface {
    // This leaf is meant to be decoded in the HubPool to rebalance tokens between HubPool and SpokePool.
    struct PoolRebalanceLeaf {
        // This is used to know which chain to send cross-chain transactions to (and which SpokePool to send to).
        uint256 chainId;
        // Total LP fee amount per token in this bundle, encompassing all associated bundled relays.
        uint256[] bundleLpFees;
        // Represents the amount to push to or pull from the SpokePool. If +, the pool pays the SpokePool. If negative
        // the SpokePool pays the HubPool. There can be arbitrarily complex rebalancing rules defined offchain. This
        // number is only nonzero when the rules indicate that a rebalancing action should occur. When a rebalance does
        // occur, runningBalances must be set to zero for this token and netSendAmounts should be set to the previous
        // runningBalances + relays - deposits in this bundle. If non-zero then it must be set on the SpokePool's
        // RelayerRefundLeaf amountToReturn as -1 * this value to show if funds are being sent from or to the SpokePool.
        int256[] netSendAmounts;
        // This is only here to be emitted in an event to track a running unpaid balance between the L2 pool and the L1
        // pool. A positive number indicates that the HubPool owes the SpokePool funds. A negative number indicates that
        // the SpokePool owes the HubPool funds. See the comment above for the dynamics of this and netSendAmounts.
        int256[] runningBalances;
        // Used by data worker to mark which leaves should relay roots to SpokePools, and to otherwise organize leaves.
        // For example, each leaf should contain all the rebalance information for a single chain, but in the case where
        // the list of l1Tokens is very large such that they all can't fit into a single leaf that can be executed under
        // the block gas limit, then the data worker can use this groupIndex to organize them. Any leaves with
        // a groupIndex equal to 0 will relay roots to the SpokePool, so the data worker should ensure that only one
        // leaf for a specific chainId should have a groupIndex equal to 0.
        uint256 groupIndex;
        // Used as the index in the bitmap to track whether this leaf has been executed or not.
        uint8 leafId;
        // The bundleLpFees, netSendAmounts, and runningBalances are required to be the same length. They are parallel
        // arrays for the given chainId and should be ordered by the l1Tokens field. All whitelisted tokens with nonzero
        // relays on this chain in this bundle in the order of whitelisting.
        address[] l1Tokens;
    }

    // A data worker can optimistically store several merkle roots on this contract by staking a bond and calling
    // proposeRootBundle. By staking a bond, the data worker is alleging that the merkle roots all contain valid leaves
    // that can be executed later to:
    // - Send funds from this contract to a SpokePool or vice versa
    // - Send funds from a SpokePool to Relayer as a refund for a relayed deposit
    // - Send funds from a SpokePool to a deposit recipient to fulfill a "slow" relay
    // Anyone can dispute this struct if the merkle roots contain invalid leaves before the
    // challengePeriodEndTimestamp. Once the expiration timestamp is passed, executeRootBundle to execute a leaf
    // from the poolRebalanceRoot on this contract and it will simultaneously publish the relayerRefundRoot and
    // slowRelayRoot to a SpokePool. The latter two roots, once published to the SpokePool, contain
    // leaves that can be executed on the SpokePool to pay relayers or recipients.
    struct RootBundle {
        // Contains leaves instructing this contract to send funds to SpokePools.
        bytes32 poolRebalanceRoot;
        // Relayer refund merkle root to be published to a SpokePool.
        bytes32 relayerRefundRoot;
        // Slow relay merkle root to be published to a SpokePool.
        bytes32 slowRelayRoot;
        // This is a 1D bitmap, with max size of 256 elements, limiting us to 256 chainsIds.
        uint256 claimedBitMap;
        // Proposer of this root bundle.
        address proposer;
        // Number of pool rebalance leaves to execute in the poolRebalanceRoot. After this number
        // of leaves are executed, a new root bundle can be proposed
        uint8 unclaimedPoolRebalanceLeafCount;
        // When root bundle challenge period passes and this root bundle becomes executable.
        uint32 challengePeriodEndTimestamp;
    }

    // Each whitelisted L1 token has an associated pooledToken struct that contains all information used to track the
    // cumulative LP positions and if this token is enabled for deposits.
    struct PooledToken {
        // LP token given to LPs of a specific L1 token.
        address lpToken;
        // True if accepting new LP's.
        bool isEnabled;
        // Timestamp of last LP fee update.
        uint32 lastLpFeeUpdate;
        // Number of LP funds sent via pool rebalances to SpokePools and are expected to be sent
        // back later.
        int256 utilizedReserves;
        // Number of LP funds held in contract less utilized reserves.
        uint256 liquidReserves;
        // Number of LP funds reserved to pay out to LPs as fees.
        uint256 undistributedLpFees;
    }

    // Helper contracts to facilitate cross chain actions between HubPool and SpokePool for a specific network.
    struct CrossChainContract {
        address adapter;
        address spokePool;
    }

    function setPaused(bool pause) external;

    function emergencyDeleteProposal() external;

    function relaySpokePoolAdminFunction(uint256 chainId, bytes memory functionData) external;

    function setProtocolFeeCapture(address newProtocolFeeCaptureAddress, uint256 newProtocolFeeCapturePct) external;

    function setBond(IERC20 newBondToken, uint256 newBondAmount) external;

    function setLiveness(uint32 newLiveness) external;

    function setIdentifier(bytes32 newIdentifier) external;

    function setCrossChainContracts(uint256 l2ChainId, address adapter, address spokePool) external;

    function enableL1TokenForLiquidityProvision(address l1Token) external;

    function disableL1TokenForLiquidityProvision(address l1Token) external;

    function addLiquidity(address l1Token, uint256 l1TokenAmount) external payable;

    function removeLiquidity(address l1Token, uint256 lpTokenAmount, bool sendEth) external;

    function exchangeRateCurrent(address l1Token) external returns (uint256);

    function liquidityUtilizationCurrent(address l1Token) external returns (uint256);

    function liquidityUtilizationPostRelay(address l1Token, uint256 relayedAmount) external returns (uint256);

    function sync(address l1Token) external;

    function proposeRootBundle(
        uint256[] memory bundleEvaluationBlockNumbers,
        uint8 poolRebalanceLeafCount,
        bytes32 poolRebalanceRoot,
        bytes32 relayerRefundRoot,
        bytes32 slowRelayRoot
    ) external;

    function executeRootBundle(
        uint256 chainId,
        uint256 groupIndex,
        uint256[] memory bundleLpFees,
        int256[] memory netSendAmounts,
        int256[] memory runningBalances,
        uint8 leafId,
        address[] memory l1Tokens,
        bytes32[] memory proof
    ) external;

    function disputeRootBundle() external;

    function claimProtocolFeesCaptured(address l1Token) external;

    function setPoolRebalanceRoute(uint256 destinationChainId, address l1Token, address destinationToken) external;

    function setDepositRoute(
        uint256 originChainId,
        uint256 destinationChainId,
        address originToken,
        bool depositsEnabled
    ) external;

    function poolRebalanceRoute(
        uint256 destinationChainId,
        address l1Token
    ) external view returns (address destinationToken);

    function loadEthForL2Calls() external payable;
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/utils/cryptography/ECDSAUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
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
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
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
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
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
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
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
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
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
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
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
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/token/ERC20/extensions/IERC20PermitUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20PermitUpgradeable {
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
     *
     * CAUTION: See Security Considerations above.
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


// ===== contracts/upgradeable/AddressLibUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @title AddressUpgradeable
 * @dev Collection of functions related to the address type
 * @notice Logic is 100% copied from "@openzeppelin/contracts-upgradeable-v4/contracts/utils/AddressUpgradeable.sol" but one
 * comment is added to clarify why we allow delegatecall() in this contract, which is typically unsafe for use in
 * upgradeable implementation contracts.
 * @dev See https://docs.openzeppelin.com/upgrades-plugins/1.x/faq#delegatecall-selfdestruct for more details.
 * @custom:security-contact bugs@across.to
 */
library AddressLibUpgradeable {
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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
        /// @custom:oz-upgrades-unsafe-allow delegatecall
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


// ===== contracts/interfaces/SpokePoolMessageHandler.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This interface is expected to be implemented by any contract that expects to receive messages from the SpokePool.
interface AcrossMessageHandler {
    function handleV3AcrossMessage(address tokenSent, uint256 amount, address relayer, bytes memory message) external;
}


// ===== contracts/libraries/MerkleLib.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../interfaces/SpokePoolInterface.sol";
import "../interfaces/V3SpokePoolInterface.sol";
import "../interfaces/HubPoolInterface.sol";

import "@openzeppelin/contracts-v4/utils/cryptography/MerkleProof.sol";

/**
 * @notice Library to help with merkle roots, proofs, and claims.
 * @custom:security-contact bugs@across.to
 */
library MerkleLib {
    /**
     * @notice Verifies that a repayment is contained within a merkle root.
     * @param root the merkle root.
     * @param rebalance the rebalance struct.
     * @param proof the merkle proof.
     * @return bool to signal if the pool rebalance proof correctly shows inclusion of the rebalance within the tree.
     */
    function verifyPoolRebalance(
        bytes32 root,
        HubPoolInterface.PoolRebalanceLeaf memory rebalance,
        bytes32[] memory proof
    ) internal pure returns (bool) {
        return MerkleProof.verify(proof, root, keccak256(abi.encode(rebalance)));
    }

    /**
     * @notice Verifies that a relayer refund is contained within a merkle root.
     * @param root the merkle root.
     * @param refund the refund struct.
     * @param proof the merkle proof.
     * @return bool to signal if the relayer refund proof correctly shows inclusion of the refund within the tree.
     */
    function verifyRelayerRefund(
        bytes32 root,
        SpokePoolInterface.RelayerRefundLeaf memory refund,
        bytes32[] memory proof
    ) internal pure returns (bool) {
        return MerkleProof.verify(proof, root, keccak256(abi.encode(refund)));
    }

    function verifyV3SlowRelayFulfillment(
        bytes32 root,
        V3SpokePoolInterface.V3SlowFill memory slowRelayFulfillment,
        bytes32[] memory proof
    ) internal pure returns (bool) {
        return MerkleProof.verify(proof, root, keccak256(abi.encode(slowRelayFulfillment)));
    }

    // The following functions are primarily copied from
    // https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol with minor changes.

    /**
     * @notice Tests whether a claim is contained within a claimedBitMap mapping.
     * @param claimedBitMap a simple uint256 mapping in storage used as a bitmap.
     * @param index the index to check in the bitmap.
     * @return bool indicating if the index within the claimedBitMap has been marked as claimed.
     */
    function isClaimed(mapping(uint256 => uint256) storage claimedBitMap, uint256 index) internal view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /**
     * @notice Marks an index in a claimedBitMap as claimed.
     * @param claimedBitMap a simple uint256 mapping in storage used as a bitmap.
     * @param index the index to mark in the bitmap.
     */
    function setClaimed(mapping(uint256 => uint256) storage claimedBitMap, uint256 index) internal {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    /**
     * @notice Tests whether a claim is contained within a 1D claimedBitMap mapping.
     * @param claimedBitMap a simple uint256 value, encoding a 1D bitmap.
     * @param index the index to check in the bitmap. Uint8 type enforces that index can't be > 255.
     * @return bool indicating if the index within the claimedBitMap has been marked as claimed.
     */
    function isClaimed1D(uint256 claimedBitMap, uint8 index) internal pure returns (bool) {
        uint256 mask = (1 << index);
        return claimedBitMap & mask == mask;
    }

    /**
     * @notice Marks an index in a claimedBitMap as claimed.
     * @param claimedBitMap a simple uint256 mapping in storage used as a bitmap. Uint8 type enforces that index
     * can't be > 255.
     * @param index the index to mark in the bitmap.
     * @return uint256 representing the modified input claimedBitMap with the index set to true.
     */
    function setClaimed1D(uint256 claimedBitMap, uint8 index) internal pure returns (uint256) {
        return claimedBitMap | (1 << index);
    }
}


// ===== contracts/spoke-pools/SpokePool.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "../libraries/MerkleLib.sol";
import "../interfaces/ERC7683.sol"; // Deprecated: ERC-7683 v1. A new version of ERC-7683 is being developed.
import "../external/interfaces/WETH9Interface.sol";
import "../interfaces/SpokePoolMessageHandler.sol";
import "../interfaces/SpokePoolInterface.sol";
import "../interfaces/V3SpokePoolInterface.sol";
import "../upgradeable/MultiCallerUpgradeable.sol";
import "../upgradeable/EIP712CrossChainUpgradeable.sol";
import "../upgradeable/AddressLibUpgradeable.sol";
import "../libraries/AddressConverters.sol";
import { SafeTransferERC20 } from "../libraries/SafeTransferERC20.sol";
import { IOFT, SendParam, MessagingFee } from "../interfaces/IOFT.sol";
import { OFTTransportAdapter } from "../libraries/OFTTransportAdapter.sol";
import { V5SpokePoolInterface } from "../interfaces/V5SpokePoolInterface.sol";
import { IGateway } from "../external/interfaces/IGateway.sol";
import { IAcrossV5Executor } from "../external/interfaces/IAcrossV5Executor.sol";
import { IAcrossV5ExecutorAdapter } from "../external/interfaces/IAcrossV5ExecutorAdapter.sol";

import "@openzeppelin/contracts-upgradeable-v4/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable-v4/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-v4/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts-upgradeable-v4/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable-v4/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-v4/utils/math/SignedMath.sol";

/**
 * @title SpokePool
 * @notice Base contract deployed on source and destination chains enabling depositors to transfer assets from source to
 * destination. Deposit orders are fulfilled by off-chain relayers who also interact with this contract. Deposited
 * tokens are locked on the source chain and relayers send the recipient the desired token currency and amount
 * on the destination chain. Locked source chain tokens are later sent over the canonical token bridge to L1 HubPool.
 * Relayers are refunded with destination tokens out of this contract after another off-chain actor, a "data worker",
 * submits a proof that the relayer correctly submitted a relay on this SpokePool.
 * @custom:security-contact bugs@across.to
 */
abstract contract SpokePool is
    V3SpokePoolInterface,
    V5SpokePoolInterface,
    SpokePoolInterface,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    MultiCallerUpgradeable,
    EIP712CrossChainUpgradeable,
    IDestinationSettler,
    OFTTransportAdapter,
    IAcrossV5Executor,
    IAcrossV5ExecutorAdapter,
    SafeTransferERC20
{
    // Restrict the `using` attachment to `safeTransferFrom` only. All `safeTransfer` calls must go
    // through the `_safeTransfer` hook (inherited from `SafeTransferERC20`) so chain-specific
    // variants can override transfer semantics in one place.
    using { SafeERC20Upgradeable.safeTransferFrom } for IERC20Upgradeable;
    using AddressLibUpgradeable for address;
    using Bytes32ToAddress for bytes32;
    using AddressToBytes32 for address;

    // Address of the L1 contract that acts as the owner of this SpokePool. This should normally be set to the HubPool
    // address. The crossDomainAdmin address is unused when the SpokePool is deployed to the same chain as the HubPool.
    address public crossDomainAdmin;

    // Address of the L1 contract that will send tokens to and receive tokens from this contract to fund relayer
    // refunds and slow relays.
    address public withdrawalRecipient;

    // Note: The following two storage variables prefixed with DEPRECATED used to be variables that could be set by
    // the cross-domain admin. Admins ended up not changing these in production, so to reduce
    // gas in deposit/fill functions, we are converting them to private variables to maintain the contract
    // storage layout and replacing them with immutable or constant variables, because retrieving a constant
    // value is cheaper than retrieving a storage variable. Please see out the immutable/constant variable section.
    WETH9Interface private DEPRECATED_wrappedNativeToken;
    uint32 private DEPRECATED_depositQuoteTimeBuffer;

    // `numberOfDeposits` acts as a counter to generate unique deposit identifiers for this spoke pool.
    // It is a uint32 that increments with each `depositV3` call. In the `FundsDeposited` event, it is
    // implicitly cast to uint256 by setting its most significant bits to 0, reducing the risk of ID collisions
    // with unsafe deposits. However, this variable's name could be improved (e.g., `depositNonceCounter`)
    // since it does not accurately reflect the total number of deposits, as `unsafeDeposit` can bypass this increment.
    uint32 public numberOfDeposits;

    // Whether deposits and fills are disabled.
    bool public pausedFills;
    bool public pausedDeposits;

    // This contract can store as many root bundles as the HubPool chooses to publish here.
    RootBundle[] public rootBundles;

    // Origin token to destination token routings can be turned on or off, which can enable or disable deposits.
    mapping(address => mapping(uint256 => bool)) private DEPRECATED_enabledDepositRoutes;

    // Each relay is associated with the hash of parameters that uniquely identify the original deposit and a relay
    // attempt for that deposit. The relay itself is just represented as the amount filled so far. The total amount to
    // relay, the fees, and the agents are all parameters included in the hash key.
    mapping(bytes32 => uint256) private DEPRECATED_relayFills;

    // Note: We will likely un-deprecate the fill and deposit counters to implement a better
    // dynamic LP fee mechanism but for now we'll deprecate it to reduce bytecode
    // in deposit/fill functions. These counters are designed to implement a fee mechanism that is based on a
    // canonical history of deposit and fill events and how they update a virtual running balance of liabilities and
    // assets, which then determines the LP fee charged to relays.

    // This keeps track of the worst-case liabilities due to fills.
    // It is never reset. Users should only rely on it to determine the worst-case increase in liabilities between
    // two points. This is used to provide frontrunning protection to ensure the relayer's assumptions about the state
    // upon which their expected repayments are based will not change before their transaction is mined.
    mapping(address => uint256) private DEPRECATED_fillCounter;

    // This keeps track of the total running deposits for each token. This allows depositors to protect themselves from
    // frontrunning that might change their worst-case quote.
    mapping(address => uint256) private DEPRECATED_depositCounter;

    // This tracks the number of identical refunds that have been requested.
    // The intention is to allow an off-chain system to know when this could be a duplicate and ensure that the other
    // requests are known and accounted for.
    mapping(bytes32 => uint256) private DEPRECATED_refundsRequested;

    // Mapping of V3 relay hashes to fill statuses. Distinguished from relayFills
    // to eliminate any chance of collision between pre and post V3 relay hashes.
    mapping(bytes32 => uint256) public fillStatuses;

    // Mapping of L2TokenAddress to relayer to outstanding refund amount. Used when a relayer repayment fails for some
    // reason (eg blacklist) to track their outstanding liability, thereby letting them claim it later.
    mapping(address => mapping(address => uint256)) public relayerRefund;

    // Mapping of L2 token address to L2 IOFT messenger address. Required to support bridging via OFT standard
    mapping(address l2TokenAddress => address l2OftMessenger) public oftMessengers;

    /**************************************************************
     *                CONSTANT/IMMUTABLE VARIABLES                *
     **************************************************************/
    // Constant and immutable variables do not take up storage slots and are instead added to the contract bytecode
    // at compile time. The difference between them is that constant variables must be declared inline, meaning
    // that they cannot be changed in production without changing the contract code, while immutable variables
    // can be set in the constructor. Therefore we use the immutable keyword for variables that we might want to be
    // different for each child contract (one obvious example of this is the wrappedNativeToken) or that we might
    // want to update in the future like depositQuoteTimeBuffer. Constants are unlikely to ever be changed.

    // Address of wrappedNativeToken contract for this network. If an origin token matches this, then the caller can
    // optionally instruct this contract to wrap native tokens when depositing (ie ETH->WETH or MATIC->WMATIC).
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    WETH9Interface public immutable wrappedNativeToken;

    // Any deposit quote times greater than or less than this value to the current contract time is blocked. Forces
    // caller to use an approximately "current" realized fee.
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    uint32 public immutable depositQuoteTimeBuffer;

    // The fill deadline can only be set this far into the future from the timestamp of the deposit on this contract.
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    uint32 public immutable fillDeadlineBuffer;

    // Across V5 Gateway whose live execution context authenticates and parameterizes V5 fills.
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    IGateway public immutable gateway;

    uint256 public constant MAX_TRANSFER_SIZE = 1e36;

    bytes32 public constant UPDATE_BYTES32_DEPOSIT_DETAILS_HASH =
        keccak256(
            "UpdateDepositDetails(uint256 depositId,uint256 originChainId,uint256 updatedOutputAmount,bytes32 updatedRecipient,bytes updatedMessage)"
        );
    // Default chain Id used to signify that no repayment is requested, for example when executing a slow fill.
    uint256 public constant EMPTY_REPAYMENT_CHAIN_ID = 0;
    // Default address used to signify that no relayer should be credited with a refund, for example
    // when executing a slow fill.
    bytes32 public constant EMPTY_RELAYER = bytes32(0);
    // This is the magic value that signals to the off-chain validator
    // that this deposit can never expire. A deposit with this fill deadline should always be eligible for a
    // slow fill, meaning that its output token and input token must be "equivalent". Therefore, this value is only
    // used as a fillDeadline in deposit(), a soon to be deprecated function that also hardcodes outputToken to
    // the zero address, which forces the off-chain validator to replace the output token with the equivalent
    // token for the input token. By using this magic value, off-chain validators do not have to keep
    // this event in their lookback window when querying for expired deposits.
    uint32 public constant INFINITE_FILL_DEADLINE = type(uint32).max;

    // One year in seconds. If `exclusivityParameter` is set to a value less than this, then the emitted
    // exclusivityDeadline in a deposit event will be set to the current time plus this value.
    uint32 public constant MAX_EXCLUSIVITY_PERIOD_SECONDS = 31_536_000;

    // EIP-7702 prefix for delegated wallets.
    bytes3 internal constant EIP7702_PREFIX = 0xef0100;

    // Magic prefix tagging a deposit message as an Across V5 witness: `message = V5_MAGIC_PREFIX || stepId`,
    // where stepId is the Merkle root of the Gateway execution allowed to consume the deposit. V5-tagged
    // deposits are only consumable through the Gateway-context-checked V5 fill entrypoints.
    bytes32 public constant V5_MAGIC_PREFIX = keccak256("AcrossV5MessagePrefix.V1");

    /****************************************
     *                EVENTS                *
     ****************************************/
    event SetXDomainAdmin(address indexed newAdmin);
    event SetWithdrawalRecipient(address indexed newWithdrawalRecipient);
    event EnabledDepositRoute(address indexed originToken, uint256 indexed destinationChainId, bool enabled);
    event RelayedRootBundle(
        uint32 indexed rootBundleId,
        bytes32 indexed relayerRefundRoot,
        bytes32 indexed slowRelayRoot
    );
    event ExecutedRelayerRefundRoot(
        uint256 amountToReturn,
        uint256 indexed chainId,
        uint256[] refundAmounts,
        uint32 indexed rootBundleId,
        uint32 indexed leafId,
        address l2TokenAddress,
        address[] refundAddresses,
        bool deferredRefunds,
        address caller
    );
    event TokensBridged(
        uint256 amountToReturn,
        uint256 indexed chainId,
        uint32 indexed leafId,
        bytes32 indexed l2TokenAddress,
        address caller
    );
    event EmergencyDeletedRootBundle(uint256 indexed rootBundleId);
    event PausedDeposits(bool isPaused);
    event PausedFills(bool isPaused);
    event SetOFTMessenger(address indexed token, address indexed messenger);

    /// @notice Emitted when the call to external contract is executed, triggered by an admin action
    event AdminExternalCallExecuted(address indexed target, bytes data);

    error OFTTokenMismatch();
    /// @notice Thrown when the native fee sent by the caller is insufficient to cover the OFT transfer.
    error OFTFeeUnderpaid();

    /**
     * @notice Construct the SpokePool. Normally, logic contracts used in upgradeable proxies shouldn't
     * have constructors since the following code will be executed within the logic contract's state, not the
     * proxy contract's state. However, if we restrict the constructor to setting only immutable variables, then
     * we are safe because immutable variables are included in the logic contract's bytecode rather than its storage.
     * @dev Do not leave an implementation contract uninitialized. An uninitialized implementation contract can be
     * taken over by an attacker, which may impact the proxy. To prevent the implementation contract from being
     * used, you should invoke the _disableInitializers function in the constructor to automatically lock it when
     * it is deployed:
     * @param _wrappedNativeTokenAddress wrappedNativeToken address for this network to set.
     * @param _depositQuoteTimeBuffer depositQuoteTimeBuffer to set. Quote timestamps can't be set more than this amount
     * into the past from the block time of the deposit.
     * @param _fillDeadlineBuffer fillDeadlineBuffer to set. Fill deadlines can't be set more than this amount
     * into the future from the block time of the deposit.
     * @param _oftDstEid destination endpoint id for OFT messaging
     * @param _oftFeeCap fee cap in native token when paying for cross-chain OFT transfers
     * @param _gateway Across V5 Gateway address. Set to address(0) to deploy with V5 fills disabled.
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address _wrappedNativeTokenAddress,
        uint32 _depositQuoteTimeBuffer,
        uint32 _fillDeadlineBuffer,
        uint32 _oftDstEid,
        uint256 _oftFeeCap,
        address _gateway
    ) OFTTransportAdapter(_oftDstEid, _oftFeeCap) {
        wrappedNativeToken = WETH9Interface(_wrappedNativeTokenAddress);
        depositQuoteTimeBuffer = _depositQuoteTimeBuffer;
        fillDeadlineBuffer = _fillDeadlineBuffer;
        gateway = IGateway(_gateway);
        _disableInitializers();
    }

    /**
     * @notice Construct the base SpokePool.
     * @param _initialDepositId Starting deposit ID. Set to 0 unless this is a re-deployment in order to mitigate
     * relay hash collisions.
     * @param _crossDomainAdmin Cross domain admin to set. Can be changed by admin.
     * @param _withdrawalRecipient Address which receives token withdrawals. Can be changed by admin. For Spoke Pools on L2, this will
     * likely be the hub pool.
     */
    function __SpokePool_init(
        uint32 _initialDepositId,
        address _crossDomainAdmin,
        address _withdrawalRecipient
    ) public onlyInitializing {
        numberOfDeposits = _initialDepositId;
        __EIP712_init("ACROSS-V2", "1.0.0");
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        _setCrossDomainAdmin(_crossDomainAdmin);
        _setWithdrawalRecipient(_withdrawalRecipient);
    }

    /****************************************
     *               MODIFIERS              *
     ****************************************/

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     * @dev This should be set to cross domain admin for specific SpokePool.
     */
    modifier onlyAdmin() {
        _requireAdminSender();
        _;
    }

    modifier unpausedDeposits() {
        if (pausedDeposits) revert DepositsArePaused();
        _;
    }

    modifier unpausedFills() {
        if (pausedFills) revert FillsArePaused();
        _;
    }

    // Quarantines V5-tagged deposits from non-V5 settlement paths (regular fills, updated fills, slow-fill
    // requests and executions). V5 deposits commit to a Gateway execution witness in `message` and are only
    // consumable through the V5 entrypoints that check it; without this guard the witness binding would be
    // bypassable.
    modifier nonV5Fill(bytes memory message) {
        if (_isV5Message(message)) revert V5FillOnly();
        _;
    }

    /**************************************
     *          ADMIN FUNCTIONS           *
     **************************************/

    // Allows cross domain admin to upgrade UUPS proxy implementation.
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {}

    /**
     * @notice Pauses deposit-related functions. This is intended to be used if this contract is deprecated or when
     * something goes awry.
     * @dev Affects `deposit()` but not `speedUpDeposit()`, so that existing deposits can be sped up and still
     * relayed.
     * @param pause true if the call is meant to pause the system, false if the call is meant to unpause it.
     */
    function pauseDeposits(bool pause) public override onlyAdmin nonReentrant {
        pausedDeposits = pause;
        emit PausedDeposits(pause);
    }

    /**
     * @notice Pauses fill-related functions. This is intended to be used if this contract is deprecated or when
     * something goes awry.
     * @dev Affects fillRelayWithUpdatedDeposit() and fillRelay().
     * @param pause true if the call is meant to pause the system, false if the call is meant to unpause it.
     */
    function pauseFills(bool pause) public override onlyAdmin nonReentrant {
        pausedFills = pause;
        emit PausedFills(pause);
    }

    /**
     * @notice Change cross domain admin address. Callable by admin only.
     * @param newCrossDomainAdmin New cross domain admin.
     */
    function setCrossDomainAdmin(address newCrossDomainAdmin) public override onlyAdmin nonReentrant {
        _setCrossDomainAdmin(newCrossDomainAdmin);
    }

    /**
     * @notice Change L1 withdrawal recipient address. Callable by admin only.
     * @param newWithdrawalRecipient New withdrawal recipient address.
     */
    function setWithdrawalRecipient(address newWithdrawalRecipient) public override onlyAdmin nonReentrant {
        _setWithdrawalRecipient(newWithdrawalRecipient);
    }

    /**
     * @notice This method stores a new root bundle in this contract that can be executed to refund relayers, fulfill
     * slow relays, and send funds back to the HubPool on L1. This method can only be called by the admin and is
     * designed to be called as part of a cross-chain message from the HubPool's executeRootBundle method.
     * @param relayerRefundRoot Merkle root containing relayer refund leaves that can be individually executed via
     * executeRelayerRefundLeaf().
     * @param slowRelayRoot Merkle root containing slow relay fulfillment leaves that can be individually executed via
     * executeSlowRelayLeaf().
     */
    function relayRootBundle(bytes32 relayerRefundRoot, bytes32 slowRelayRoot) public override onlyAdmin nonReentrant {
        uint32 rootBundleId = uint32(rootBundles.length);
        RootBundle storage rootBundle = rootBundles.push();
        rootBundle.relayerRefundRoot = relayerRefundRoot;
        rootBundle.slowRelayRoot = slowRelayRoot;
        emit RelayedRootBundle(rootBundleId, relayerRefundRoot, slowRelayRoot);
    }

    /**
     * @notice This method is intended to only be used in emergencies where a bad root bundle has reached the
     * SpokePool.
     * @param rootBundleId Index of the root bundle that needs to be deleted. Note: this is intentionally a uint256
     * to ensure that a small input range doesn't limit which indices this method is able to reach.
     */
    function emergencyDeleteRootBundle(uint256 rootBundleId) public override onlyAdmin nonReentrant {
        // Deleting a struct containing a mapping does not delete the mapping in Solidity, therefore the bitmap's
        // data will still remain potentially leading to vulnerabilities down the line. The way around this would
        // be to iterate through every key in the mapping and resetting the value to 0, but this seems expensive and
        // would require a new list in storage to keep track of keys.
        //slither-disable-next-line mapping-deletion
        delete rootBundles[rootBundleId];
        emit EmergencyDeletedRootBundle(rootBundleId);
    }

    /**
     * @notice Add token -> OFTMessenger relationship. Callable only by admin.
     * @param token token address on the current chain
     * @param messenger IOFT contract address on the current chain for the specified token. Acts as a 'mailbox'
     */
    function setOftMessenger(address token, address messenger) external onlyAdmin nonReentrant {
        _setOftMessenger(token, messenger);
    }

    /**
     * @notice Execute an external call to a target contract.
     * @param message The message containing the target address and calldata to execute.
     * @return returnData The return data from the executed call.
     */
    function executeExternalCall(
        bytes calldata message
    ) external onlyAdmin nonReentrant returns (bytes memory returnData) {
        (address target, bytes memory data) = abi.decode(message, (address, bytes));

        if (target == address(0)) revert ZeroAddressTarget();
        if (data.length < 4) revert MessageTooShort(); // need at least a selector

        // external call to target
        bool success;
        (success, returnData) = target.call(data);

        if (!success) revert ExternalCallExecutionFailed();
        emit AdminExternalCallExecuted(target, data);
    }

    /**************************************
     *      REMOVED DEPOSITOR FUNCTIONS   *
     **************************************/

    /**
     * @dev REMOVED: This function has been removed and is now disallowed to prevent selector reuse.
     * @notice This function was removed from the protocol. Calling it will revert.
     * Function selector is preserved to prevent accidental reuse in future versions.
     * @notice This function shares the same selector as the original "deposit" function that was removed.
     * The collision was intentionally created to allow reusing the "deposit" name for a different function signature.
     */
    function depositDeprecated_5947912356(
        address,
        address,
        uint256,
        uint256,
        int64,
        uint32,
        bytes memory,
        uint256
    ) public payable {
        revert RemovedFunction();
    }

    /**
     * @dev REMOVED: This function has been removed and is now disallowed to prevent selector reuse.
     * @notice This function was removed from the protocol. Calling it will revert.
     * Function selector is preserved to prevent accidental reuse in future versions.
     */
    function depositFor(
        address,
        address,
        address,
        uint256,
        uint256,
        int64,
        uint32,
        bytes memory,
        uint256
    ) public payable {
        revert RemovedFunction();
    }

    /********************************************
     *            DEPOSITOR FUNCTIONS           *
     ********************************************/

    /**
     * @notice Previously, this function allowed the caller to specify the exclusivityDeadline, otherwise known as the
     * as exact timestamp on the destination chain before which only the exclusiveRelayer could fill the deposit. Now,
     * the caller is expected to pass in a number that will be interpreted either as an offset or a fixed
     * timestamp depending on its value.
     * @notice Request to bridge input token cross chain to a destination chain and receive a specified amount
     * of output tokens. The fee paid to relayers and the system should be captured in the spread between output
     * amount and input amount when adjusted to be denominated in the input token. A relayer on the destination
     * chain will send outputAmount of outputTokens to the recipient and receive inputTokens on a repayment
     * chain of their choice. Therefore, the fee should account for destination fee transaction costs,
     * the relayer's opportunity cost of capital while they wait to be refunded following an optimistic challenge
     * window in the HubPool, and the system fee that they'll be charged.
     * @dev On the destination chain, the hash of the deposit data will be used to uniquely identify this deposit, so
     * modifying any params in it will result in a different hash and a different deposit. The hash will comprise
     * all parameters to this function along with this chain's chainId(). Relayers are only refunded for filling
     * deposits with deposit hashes that map exactly to the one emitted by this contract.
     * @param depositor The account credited with the deposit who can request to "speed up" this deposit by modifying
     * the output amount, recipient, and message.
     * @param recipient The account receiving funds on the destination chain. Can be an EOA or a contract. If
     * the output token is the wrapped native token for the chain, then the recipient will receive native token if
     * an EOA or wrapped native token if a contract.
     * @param inputToken The token pulled from the caller's account and locked into this contract to
     * initiate the deposit. The equivalent of this token on the relayer's repayment chain of choice will be sent
     * as a refund. If this is equal to the wrapped native token then the caller can optionally pass in native token as
     * msg.value, as long as msg.value = inputTokenAmount.
     * @param outputToken The token that the relayer will send to the recipient on the destination chain. Must be an
     * ERC20.
     * @param inputAmount The amount of input tokens to pull from the caller's account and lock into this contract.
     * This amount will be sent to the relayer on their repayment chain of choice as a refund following an optimistic
     * challenge window in the HubPool, less a system fee.
     * @param outputAmount The amount of output tokens that the relayer will send to the recipient on the destination.
     * @param destinationChainId The destination chain identifier. Must be enabled along with the input token
     * as a valid deposit route from this spoke pool or this transaction will revert.
     * @param exclusiveRelayer The relayer that will be exclusively allowed to fill this deposit before the
     * exclusivity deadline timestamp. This must be a valid, non-zero address if the exclusivity deadline is
     * greater than the current block.timestamp. If the exclusivity deadline is < currentTime, then this must be
     * address(0), and vice versa if this is address(0).
     * @param quoteTimestamp The HubPool timestamp that is used to determine the system fee paid by the depositor.
     *  This must be set to some time between [currentTime - depositQuoteTimeBuffer, currentTime]
     * where currentTime is block.timestamp on this chain or this transaction will revert.
     * @param fillDeadline The deadline for the relayer to fill the deposit. After this destination chain timestamp,
     * the fill will revert on the destination chain. Must be set before currentTime + fillDeadlineBuffer, where
     * currentTime is block.timestamp on this chain or this transaction will revert.
     * @param exclusivityParameter This value is used to set the exclusivity deadline timestamp in the emitted deposit
     * event. Before this destination chain timestamp, only the exclusiveRelayer (if set to a non-zero address),
     * can fill this deposit. There are three ways to use this parameter:
     *     1. NO EXCLUSIVITY: If this value is set to 0, then a timestamp of 0 will be emitted,
     *        meaning that there is no exclusivity period.
     *     2. OFFSET: If this value is less than MAX_EXCLUSIVITY_PERIOD_SECONDS, then add this value to
     *        the block.timestamp to derive the exclusive relayer deadline. Note that using the parameter in this way
     *        will expose the filler of the deposit to the risk that the block.timestamp of this event gets changed
     *        due to a chain-reorg, which would also change the exclusivity timestamp.
     *     3. TIMESTAMP: Otherwise, set this value as the exclusivity deadline timestamp.
     * which is the deadline for the exclusiveRelayer to fill the deposit.
     * @param message The message to send to the recipient on the destination chain if the recipient is a contract.
     * If the message is not empty, the recipient contract must implement handleV3AcrossMessage() or the fill will revert.
     */
    function deposit(
        bytes32 depositor,
        bytes32 recipient,
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        bytes32 exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityParameter,
        bytes calldata message
    ) public payable override nonReentrant unpausedDeposits {
        // Increment the `numberOfDeposits` counter to ensure a unique deposit ID for this spoke pool.
        DepositV3Params memory params = DepositV3Params({
            depositor: depositor,
            recipient: recipient,
            inputToken: inputToken,
            outputToken: outputToken,
            inputAmount: inputAmount,
            outputAmount: outputAmount,
            destinationChainId: destinationChainId,
            exclusiveRelayer: exclusiveRelayer,
            depositId: numberOfDeposits++,
            quoteTimestamp: quoteTimestamp,
            fillDeadline: fillDeadline,
            exclusivityParameter: exclusivityParameter,
            message: message
        });
        _depositV3(params);
    }

    /**
     * @notice A version of `deposit` that accepts `address` types for backward compatibility.
     * This function allows bridging of input tokens cross-chain to a destination chain, receiving a specified amount of output tokens.
     * The relayer is refunded in input tokens on a repayment chain of their choice, minus system fees, after an optimistic challenge
     * window. The exclusivity period is specified as an offset from the current block timestamp.
     *
     * @dev This version mirrors the original `depositV3` function, but uses `address` types for `depositor`, `recipient`,
     * `inputToken`, `outputToken`, and `exclusiveRelayer` for compatibility with contracts using the `address` type.
     *
     * The key functionality and logic remain identical, ensuring interoperability across both versions.
     *
     * @param depositor The account credited with the deposit who can request to "speed up" this deposit by modifying
     * the output amount, recipient, and message.
     * @param recipient The account receiving funds on the destination chain. Can be an EOA or a contract. If
     * the output token is the wrapped native token for the chain, then the recipient will receive native token if
     * an EOA or wrapped native token if a contract.
     * @param inputToken The token pulled from the caller's account and locked into this contract to initiate the deposit.
     * The equivalent of this token on the relayer's repayment chain of choice will be sent as a refund. If this is equal
     * to the wrapped native token, the caller can optionally pass in native token as msg.value, provided msg.value = inputTokenAmount.
     * @param outputToken The token that the relayer will send to the recipient on the destination chain. Must be an ERC20.
     * @param inputAmount The amount of input tokens pulled from the caller's account and locked into this contract. This
     * amount will be sent to the relayer as a refund following an optimistic challenge window in the HubPool, less a system fee.
     * @param outputAmount The amount of output tokens that the relayer will send to the recipient on the destination.
     * @param destinationChainId The destination chain identifier. Must be enabled along with the input token as a valid
     * deposit route from this spoke pool or this transaction will revert.
     * @param exclusiveRelayer The relayer exclusively allowed to fill this deposit before the exclusivity deadline.
     * @param quoteTimestamp The HubPool timestamp that determines the system fee paid by the depositor. This must be set
     * between [currentTime - depositQuoteTimeBuffer, currentTime] where currentTime is block.timestamp on this chain.
     * @param fillDeadline The deadline for the relayer to fill the deposit. After this destination chain timestamp, the fill will
     * revert on the destination chain. Must be set before currentTime + fillDeadlineBuffer, where currentTime is block.timestamp
     * on this chain.
     * @param exclusivityParameter This value is used to set the exclusivity deadline timestamp in the emitted deposit
     * event. Before this destination chain timestamp, only the exclusiveRelayer (if set to a non-zero address),
     * can fill this deposit. There are three ways to use this parameter:
     *     1. NO EXCLUSIVITY: If this value is set to 0, then a timestamp of 0 will be emitted,
     *        meaning that there is no exclusivity period.
     *     2. OFFSET: If this value is less than MAX_EXCLUSIVITY_PERIOD_SECONDS, then add this value to
     *        the block.timestamp to derive the exclusive relayer deadline. Note that using the parameter in this way
     *        will expose the filler of the deposit to the risk that the block.timestamp of this event gets changed
     *        due to a chain-reorg, which would also change the exclusivity timestamp.
     *     3. TIMESTAMP: Otherwise, set this value as the exclusivity deadline timestamp.
     * which is the deadline for the exclusiveRelayer to fill the deposit.
     * @param message The message to send to the recipient on the destination chain if the recipient is a contract. If the
     * message is not empty, the recipient contract must implement `handleV3AcrossMessage()` or the fill will revert.
     */
    function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityParameter,
        bytes calldata message
    ) public payable override {
        deposit(
            depositor.toBytes32(),
            recipient.toBytes32(),
            inputToken.toBytes32(),
            outputToken.toBytes32(),
            inputAmount,
            outputAmount,
            destinationChainId,
            exclusiveRelayer.toBytes32(),
            quoteTimestamp,
            fillDeadline,
            exclusivityParameter,
            message
        );
    }

    /**
     * @notice See deposit for details. This function is identical to deposit except that it does not use the
     * global deposit ID counter as a deposit nonce, instead allowing the caller to pass in a deposit nonce. This
     * function is designed to be used by anyone who wants to pre-compute their resultant relay data hash, which
     * could be useful for filling a deposit faster and avoiding any risk of a relay hash unexpectedly changing
     * due to another deposit front-running this one and incrementing the global deposit ID counter.
     * @dev This is labeled "unsafe" because there is no guarantee that the depositId emitted in the resultant
     * FundsDeposited event is unique which means that the
     * corresponding fill might collide with an existing relay hash on the destination chain SpokePool,
     * which would make this deposit unfillable. In this case, the depositor would subsequently receive a refund
     * of `inputAmount` of `inputToken` on the origin chain after the fill deadline. Re-using a depositNonce is very
     * dangerous when combined with `speedUpDeposit`, as a speed up signature can be re-used for any deposits
     * with the same deposit ID.
     * @dev On the destination chain, the hash of the deposit data will be used to uniquely identify this deposit, so
     * modifying any params in it will result in a different hash and a different deposit. The hash will comprise
     * all parameters to this function along with this chain's chainId(). Relayers are only refunded for filling
     * deposits with deposit hashes that map exactly to the one emitted by this contract.
     * @param depositNonce The nonce that uniquely identifies this deposit. This function will combine this parameter
     * with the msg.sender address to create a unique uint256 depositNonce and ensure that the msg.sender cannot
     * use this function to front-run another depositor's unsafe deposit. This function guarantees that the resultant
     * deposit nonce will not collide with a safe uint256 deposit nonce whose 24 most significant bytes are always 0.
     * @param depositor See identically named parameter in depositV3() comments.
     * @param recipient See identically named parameter in depositV3() comments.
     * @param inputToken See identically named parameter in depositV3() comments.
     * @param outputToken See identically named parameter in depositV3() comments.
     * @param inputAmount See identically named parameter in depositV3() comments.
     * @param outputAmount See identically named parameter in depositV3() comments.
     * @param destinationChainId See identically named parameter in depositV3() comments.
     * @param exclusiveRelayer See identically named parameter in depositV3() comments.
     * @param quoteTimestamp See identically named parameter in depositV3() comments.
     * @param fillDeadline See identically named parameter in depositV3() comments.
     * @param exclusivityParameter See identically named parameter in depositV3() comments.
     * @param message See identically named parameter in depositV3() comments.
     */
    function unsafeDeposit(
        bytes32 depositor,
        bytes32 recipient,
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        bytes32 exclusiveRelayer,
        uint256 depositNonce,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityParameter,
        bytes calldata message
    ) public payable nonReentrant unpausedDeposits {
        // @dev Create the uint256 deposit ID by concatenating the msg.sender and depositor address with the inputted
        // depositNonce parameter. The resultant 32 byte string will be hashed and then casted to an "unsafe"
        // uint256 deposit ID. The probability that the resultant ID collides with a "safe" deposit ID is
        // equal to the chance that the first 28 bytes of the hash are 0, which is too small for us to consider.

        uint256 depositId = getUnsafeDepositId(msg.sender, depositor, depositNonce);
        DepositV3Params memory params = DepositV3Params({
            depositor: depositor,
            recipient: recipient,
            inputToken: inputToken,
            outputToken: outputToken,
            inputAmount: inputAmount,
            outputAmount: outputAmount,
            destinationChainId: destinationChainId,
            exclusiveRelayer: exclusiveRelayer,
            depositId: depositId,
            quoteTimestamp: quoteTimestamp,
            fillDeadline: fillDeadline,
            exclusivityParameter: exclusivityParameter,
            message: message
        });
        _depositV3(params);
    }

    /**
     * @notice Submits deposit and sets quoteTimestamp to current Time. Sets fill and exclusivity
     * deadlines as offsets added to the current time. This function is designed to be called by users
     * such as Multisig contracts who do not have certainty when their transaction will mine.
     * @param depositor The account credited with the deposit who can request to "speed up" this deposit by modifying
     * the output amount, recipient, and message.
     * @param recipient The account receiving funds on the destination chain. Can be an EOA or a contract. If
     * the output token is the wrapped native token for the chain, then the recipient will receive native token if
     * an EOA or wrapped native token if a contract.
     * @param inputToken The token pulled from the caller's account and locked into this contract to
     * initiate the deposit. The equivalent of this token on the relayer's repayment chain of choice will be sent
     * as a refund. If this is equal to the wrapped native token then the caller can optionally pass in native token as
     * msg.value, as long as msg.value = inputTokenAmount.
     * @param outputToken The token that the relayer will send to the recipient on the destination chain. Must be an
     * ERC20.
     * @param inputAmount The amount of input tokens to pull from the caller's account and lock into this contract.
     * This amount will be sent to the relayer on their repayment chain of choice as a refund following an optimistic
     * challenge window in the HubPool, plus a system fee.
     * @param outputAmount The amount of output tokens that the relayer will send to the recipient on the destination.
     * @param destinationChainId The destination chain identifier. Must be enabled along with the input token
     * as a valid deposit route from this spoke pool or this transaction will revert.
     * @param exclusiveRelayer The relayer that will be exclusively allowed to fill this deposit before the
     * exclusivity deadline timestamp.
     * @param fillDeadlineOffset Added to the current time to set the fill deadline, which is the deadline for the
     * relayer to fill the deposit. After this destination chain timestamp, the fill will revert on the
     * destination chain.
     * @param exclusivityParameter See identically named parameter in deposit() comments.
     * @param message The message to send to the recipient on the destination chain if the recipient is a contract.
     * If the message is not empty, the recipient contract must implement handleV3AcrossMessage() or the fill will revert.
     */
    function depositNow(
        bytes32 depositor,
        bytes32 recipient,
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        bytes32 exclusiveRelayer,
        uint32 fillDeadlineOffset,
        uint32 exclusivityParameter,
        bytes calldata message
    ) external payable override {
        deposit(
            depositor,
            recipient,
            inputToken,
            outputToken,
            inputAmount,
            outputAmount,
            destinationChainId,
            exclusiveRelayer,
            uint32(getCurrentTime()),
            uint32(getCurrentTime()) + fillDeadlineOffset,
            exclusivityParameter,
            message
        );
    }

    /**
     * @notice A version of `depositNow` that supports addresses as input types for backward compatibility.
     * This function submits a deposit and sets `quoteTimestamp` to the current time. The `fill` and `exclusivity` deadlines
     * are set as offsets added to the current time. It is designed to be called by users, including Multisig contracts, who may
     * not have certainty when their transaction will be mined.
     *
     * @dev This version is identical to the original `depositV3Now` but uses `address` types for `depositor`, `recipient`,
     * `inputToken`, `outputToken`, and `exclusiveRelayer` to support compatibility with older systems.
     * It maintains the same logic and purpose, ensuring interoperability with both versions.
     *
     * @param depositor The account credited with the deposit, who can request to "speed up" this deposit by modifying
     * the output amount, recipient, and message.
     * @param recipient The account receiving funds on the destination chain. Can be an EOA or a contract. If
     * the output token is the wrapped native token for the chain, then the recipient will receive the native token if
     * an EOA or wrapped native token if a contract.
     * @param inputToken The token pulled from the caller's account and locked into this contract to initiate the deposit.
     * Equivalent tokens on the relayer's repayment chain will be sent as a refund. If this is the wrapped native token,
     * msg.value must equal inputTokenAmount when passed.
     * @param outputToken The token the relayer will send to the recipient on the destination chain. Must be an ERC20.
     * @param inputAmount The amount of input tokens pulled from the caller's account and locked into this contract.
     * This amount will be sent to the relayer as a refund following an optimistic challenge window in the HubPool, plus a system fee.
     * @param outputAmount The amount of output tokens the relayer will send to the recipient on the destination.
     * @param destinationChainId The destination chain identifier. Must be enabled with the input token as a valid deposit route
     * from this spoke pool, or the transaction will revert.
     * @param exclusiveRelayer The relayer exclusively allowed to fill the deposit before the exclusivity deadline.
     * @param fillDeadlineOffset Added to the current time to set the fill deadline. After this timestamp, fills on the
     * destination chain will revert.
     * @param exclusivityParameter See identically named parameter in deposit() comments.
     * @param message The message to send to the recipient on the destination chain. If the recipient is a contract, it must
     * implement `handleV3AcrossMessage()` if the message is not empty, or the fill will revert.
     */
    function depositV3Now(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 fillDeadlineOffset,
        uint32 exclusivityParameter,
        bytes calldata message
    ) external payable override {
        depositV3(
            depositor,
            recipient,
            inputToken,
            outputToken,
            inputAmount,
            outputAmount,
            destinationChainId,
            exclusiveRelayer,
            uint32(getCurrentTime()),
            uint32(getCurrentTime()) + fillDeadlineOffset,
            exclusivityParameter,
            message
        );
    }

    /**
     * @notice Depositor can use this function to signal to relayer to use updated output amount, recipient,
     * and/or message. The speed up signature uniquely identifies the speed up based only on
     * depositor, deposit ID and origin chain, so using this function in conjunction with unsafeDeposit is risky
     * due to the chance of repeating a deposit ID.
     * @dev the depositor and depositId must match the params in a FundsDeposited event that the depositor
     * wants to speed up. The relayer has the option but not the obligation to use this updated information
     * when filling the deposit via fillRelayWithUpdatedDeposit().
     * @param depositor Depositor that must sign the depositorSignature and was the original depositor.
     * @param depositId Deposit ID to speed up.
     * @param updatedOutputAmount New output amount to use for this deposit. Should be lower than previous value
     * otherwise relayer has no incentive to use this updated value.
     * @param updatedRecipient New recipient to use for this deposit. Can be modified if the recipient is a contract
     * that expects to receive a message from the relay and for some reason needs to be modified.
     * @param updatedMessage New message to use for this deposit. Can be modified if the recipient is a contract
     * that expects to receive a message from the relay and for some reason needs to be modified.
     * @param depositorSignature Signed EIP712 hashstruct containing the deposit ID. Should be signed by the depositor
     * account. If depositor is a contract, then should implement EIP1271 to sign as a contract. See
     * _verifyUpdateV3DepositMessage() for more details about how this signature should be constructed.
     */
    function speedUpDeposit(
        bytes32 depositor,
        uint256 depositId,
        uint256 updatedOutputAmount,
        bytes32 updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) public override nonReentrant {
        _verifyUpdateV3DepositMessage(
            depositor.toAddress(),
            depositId,
            chainId(),
            updatedOutputAmount,
            updatedRecipient,
            updatedMessage,
            depositorSignature,
            UPDATE_BYTES32_DEPOSIT_DETAILS_HASH
        );

        // Assuming the above checks passed, a relayer can take the signature and the updated deposit information
        // from the following event to submit a fill with updated relay data.
        emit RequestedSpeedUpDeposit(
            updatedOutputAmount,
            depositId,
            depositor,
            updatedRecipient,
            updatedMessage,
            depositorSignature
        );
    }

    /**
     * @notice A version of `speedUpDeposit` using `address` types for backward compatibility.
     * This function allows the depositor to signal to the relayer to use updated output amount, recipient, and/or message
     * when filling a deposit. This can be useful when the deposit needs to be modified after the original transaction has
     * been mined.
     *
     * @dev The `depositor` and `depositId` must match the parameters in a `FundsDeposited` event that the depositor wants to speed up.
     * The relayer is not obligated but has the option to use this updated information when filling the deposit using
     * `fillRelayWithUpdatedDeposit()`. This version uses `address` types for compatibility with systems relying on
     * `address`-based implementations.
     *
     * @param depositor The depositor that must sign the `depositorSignature` and was the original depositor.
     * @param depositId The deposit ID to speed up.
     * @param updatedOutputAmount The new output amount to use for this deposit. It should be lower than the previous value,
     * otherwise the relayer has no incentive to use this updated value.
     * @param updatedRecipient The new recipient for this deposit. Can be modified if the original recipient is a contract that
     * expects to receive a message from the relay and needs to be changed.
     * @param updatedMessage The new message for this deposit. Can be modified if the recipient is a contract that expects
     * to receive a message from the relay and needs to be updated.
     * @param depositorSignature The signed EIP712 hashstruct containing the deposit ID. Should be signed by the depositor account.
     * If the depositor is a contract, it should implement EIP1271 to sign as a contract. See `_verifyUpdateV3DepositMessage()`
     * for more details on how the signature should be constructed.
     */
    function speedUpV3Deposit(
        address depositor,
        uint256 depositId,
        uint256 updatedOutputAmount,
        address updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) public {
        _verifyUpdateV3DepositMessage(
            depositor,
            depositId,
            chainId(),
            updatedOutputAmount,
            updatedRecipient.toBytes32(),
            updatedMessage,
            depositorSignature,
            UPDATE_BYTES32_DEPOSIT_DETAILS_HASH
        );

        // Assuming the above checks passed, a relayer can take the signature and the updated deposit information
        // from the following event to submit a fill with updated relay data.
        emit RequestedSpeedUpDeposit(
            updatedOutputAmount,
            depositId,
            depositor.toBytes32(),
            updatedRecipient.toBytes32(),
            updatedMessage,
            depositorSignature
        );
    }

    /**************************************
     *         RELAYER FUNCTIONS          *
     **************************************/

    /**
     * @notice Fulfill request to bridge cross chain by sending specified output tokens to the recipient.
     * @dev The fee paid to relayers and the system should be captured in the spread between output
     * amount and input amount when adjusted to be denominated in the input token. A relayer on the destination
     * chain will send outputAmount of outputTokens to the recipient and receive inputTokens on a repayment
     * chain of their choice. Therefore, the fee should account for destination fee transaction costs, the
     * relayer's opportunity cost of capital while they wait to be refunded following an optimistic challenge
     * window in the HubPool, and a system fee charged to relayers.
     * @dev The hash of the relayData will be used to uniquely identify the deposit to fill, so
     * modifying any params in it will result in a different hash and a different deposit. The hash will comprise
     * all parameters passed to deposit() on the origin chain along with that chain's chainId(). This chain's
     * chainId() must therefore match the destinationChainId passed into deposit.
     * Relayers are only refunded for filling deposits with deposit hashes that map exactly to the one emitted by the
     * origin SpokePool therefore the relayer should not modify any params in relayData.
     * @dev Cannot fill more than once. Partial fills are not supported.
     * @param relayData struct containing all the data needed to identify the deposit to be filled. Should match
     * all the same-named parameters emitted in the origin chain FundsDeposited event.
     * - depositor: The account credited with the deposit who can request to "speed up" this deposit by modifying
     * the output amount, recipient, and message.
     * - recipient The account receiving funds on this chain. Can be an EOA or a contract. If
     * the output token is the wrapped native token for the chain, then the recipient will receive native token if
     * an EOA or wrapped native token if a contract.
     * - inputToken: The token pulled from the caller's account to initiate the deposit. The equivalent of this
     * token on the repayment chain will be sent as a refund to the caller.
     * - outputToken The token that the caller will send to the recipient on the destination chain. Must be an
     * ERC20.
     * - inputAmount: This amount, less a system fee, will be sent to the caller on their repayment chain of choice as a refund
     * following an optimistic challenge window in the HubPool.
     * - outputAmount: The amount of output tokens that the caller will send to the recipient.
     * - originChainId: The origin chain identifier.
     * - exclusiveRelayer The relayer that will be exclusively allowed to fill this deposit before the
     * exclusivity deadline timestamp.
     * - fillDeadline The deadline for the caller to fill the deposit. After this timestamp,
     * the fill will revert on the destination chain.
     * - exclusivityDeadline: The deadline for the exclusive relayer to fill the deposit. After this
     * timestamp, anyone can fill this deposit. Note that if this value was set in deposit by adding an offset
     * to the deposit's block.timestamp, there is re-org risk for the caller of this method because the event's
     * block.timestamp can change. Read the comments in `deposit` about the `exclusivityParameter` for more details.
     * - message The message to send to the recipient if the recipient is a contract that implements a
     * handleV3AcrossMessage() public function
     * @param repaymentChainId Chain of SpokePool where relayer wants to be refunded after the challenge window has
     * passed. Will receive inputAmount of the equivalent token to inputToken on the repayment chain.
     * @param repaymentAddress Address the relayer wants to be receive their refund at.
     */
    function fillRelay(
        V3RelayData memory relayData,
        uint256 repaymentChainId,
        bytes32 repaymentAddress
    ) public override nonReentrant unpausedFills nonV5Fill(relayData.message) {
        _requireExclusiveFiller(relayData.exclusivityDeadline, relayData.exclusiveRelayer, msg.sender);

        V3RelayExecutionParams memory relayExecution = V3RelayExecutionParams({
            relay: relayData,
            relayHash: getV3RelayHash(relayData),
            updatedOutputAmount: relayData.outputAmount,
            updatedRecipient: relayData.recipient,
            updatedMessage: relayData.message,
            repaymentChainId: repaymentChainId
        });

        _fillRelayV3(relayExecution, repaymentAddress, false);
    }

    // Exposes the same function as fillRelay but with a legacy V3RelayData struct that takes in address types. Inner
    // function fillV3Relay() applies reentrancy & non-paused checks.
    function fillV3Relay(V3RelayDataLegacy calldata relayData, uint256 repaymentChainId) public override {
        // Convert V3RelayDataLegacy to V3RelayData using the .toBytes32() method.
        V3RelayData memory convertedRelayData = V3RelayData({
            depositor: relayData.depositor.toBytes32(),
            recipient: relayData.recipient.toBytes32(),
            exclusiveRelayer: relayData.exclusiveRelayer.toBytes32(),
            inputToken: relayData.inputToken.toBytes32(),
            outputToken: relayData.outputToken.toBytes32(),
            inputAmount: relayData.inputAmount,
            outputAmount: relayData.outputAmount,
            originChainId: relayData.originChainId,
            depositId: relayData.depositId,
            fillDeadline: relayData.fillDeadline,
            exclusivityDeadline: relayData.exclusivityDeadline,
            message: relayData.message
        });

        fillRelay(convertedRelayData, repaymentChainId, msg.sender.toBytes32());
    }

    /**
     * @notice Fills a V5 deposit as the entire Across V5 Gateway execution (spoke-as-executor mode: the user's
     * path commits the SpokePool itself as the executor, so the Gateway calls this entrypoint directly).
     * @dev Because the committed input is a fixed struct — a submitter can parse the complete execution
     * semantics before calling `Gateway.execute()` — this mode (and only this mode) pulls the output tokens
     * from the Gateway's current submitter, using the same standing approval relayers already hold for
     * `fillRelay`. The fill is terminal: after delivering to the committed recipient, a committed callback
     * message (if any) triggers the contract recipient's `handleV3AcrossMessage` hook with the submitter
     * reported as relayer, and nothing else runs.
     * @param message Path-committed `abi.encode(V5FillInput)`: the user's acceptance bounds (recipient, output
     * token, minimum output amount, callback message).
     * @param executorMessage Submitter-supplied `abi.encode(V5FillJit)`: the deposit's relay data, passed
     * verbatim, and repayment fields.
     */
    function executeAcrossV5(
        bytes calldata message,
        bytes calldata executorMessage
    ) external payable override nonReentrant {
        if (msg.sender != address(gateway)) revert V5NotGateway();
        // Fills never accept native value — the V3 fill entrypoints are not even payable. This entrypoint is
        // payable only because the V5 executor interface requires it, so reject any value rather than strand it.
        if (msg.value > 0) revert V5UnusedMsgValue();

        _fillV5(
            abi.decode(message, (V5FillInput)),
            abi.decode(executorMessage, (V5FillJit)),
            gateway.currentSubmitter()
        );
    }

    /**
     * @notice Fills a V5 deposit as one step inside an Across V5 Gateway execution (spoke-as-adapter mode: the
     * SpokePool is a funding-adapter target invoked mid-sequence by the executor running the user's committed
     * commands).
     * @dev Callable only by the committed executor of the live Gateway execution. Output tokens are always
     * pulled from `msg.sender` — the executing contract's own balance, funded by the Gateway or by earlier
     * steps — never from a standing submitter allowance, so a submitter executing a command sequence they
     * don't fully understand risks only what that execution was explicitly funded with. The fill has no
     * trailing call after delivery: anything that should happen next is expressed as later steps of the
     * committed sequence.
     * @param input Tape-committed `abi.encode(V5FillInput)`: the user's acceptance bounds (recipient, output
     * token, minimum output amount; no callback message may be committed).
     * @param jitData Submitter-supplied `abi.encode(V5FillJit)`: the deposit's relay data, passed verbatim,
     * and repayment fields.
     */
    function adapterExecuteAcrossV5(
        bytes calldata input,
        bytes calldata jitData
    ) external payable override nonReentrant {
        // Check that a Gateway execution is active and that the caller is its committed executor, directly.
        // For closed executors (only callable through the Gateway), this means `input` is committed in the
        // user's path rather than chosen by whoever gained control mid-execution.
        if (msg.sender != gateway.currentExecutor()) revert V5NotCurrentExecutor();
        // Fills never accept native value — the V3 fill entrypoints are not even payable. This entrypoint is
        // payable only because the V5 adapter interface requires it, so reject any value rather than strand it.
        if (msg.value > 0) revert V5UnusedMsgValue();

        V5FillInput memory fillInput = abi.decode(input, (V5FillInput));
        if (fillInput.message.length != 0) revert V5CallbackNotAllowed();

        _fillV5(fillInput, abi.decode(jitData, (V5FillJit)), msg.sender);
    }

    /**
     * @notice Identical to fillV3Relay except that the relayer wants to use a depositor's updated output amount,
     * recipient, and/or message. The relayer should only use this function if they can supply a message signed
     * by the depositor that contains the fill's matching deposit ID along with updated relay parameters.
     * If the signature can be verified, then this function will emit a FilledV3Event that will be used by
     * the system for refund verification purposes. In other words, this function is an alternative way to fill a
     * a deposit than fillV3Relay.
     * @dev Subject to same exclusivity deadline rules as fillV3Relay().
     * @param relayData struct containing all the data needed to identify the deposit to be filled. See fillV3Relay().
     * @param repaymentChainId Chain of SpokePool where relayer wants to be refunded after the challenge window has
     * passed. See fillV3Relay().
     * @param repaymentAddress Address the relayer wants to be receive their refund at.
     * @param updatedOutputAmount New output amount to use for this deposit.
     * @param updatedRecipient New recipient to use for this deposit.
     * @param updatedMessage New message to use for this deposit.
     * @param depositorSignature Signed EIP712 hashstruct containing the deposit ID. Should be signed by the depositor
     * account.
     */
    function fillRelayWithUpdatedDeposit(
        V3RelayData calldata relayData,
        uint256 repaymentChainId,
        bytes32 repaymentAddress,
        uint256 updatedOutputAmount,
        bytes32 updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) public override nonReentrant unpausedFills nonV5Fill(relayData.message) {
        _requireExclusiveFiller(relayData.exclusivityDeadline, relayData.exclusiveRelayer, msg.sender);

        V3RelayExecutionParams memory relayExecution = V3RelayExecutionParams({
            relay: relayData,
            relayHash: getV3RelayHash(relayData),
            updatedOutputAmount: updatedOutputAmount,
            updatedRecipient: updatedRecipient,
            updatedMessage: updatedMessage,
            repaymentChainId: repaymentChainId
        });

        _verifyUpdateV3DepositMessage(
            relayData.depositor.toAddress(),
            relayData.depositId,
            relayData.originChainId,
            updatedOutputAmount,
            updatedRecipient,
            updatedMessage,
            depositorSignature,
            UPDATE_BYTES32_DEPOSIT_DETAILS_HASH
        );

        _fillRelayV3(relayExecution, repaymentAddress, false);
    }

    /**
     * @notice Request Across to send LP funds to this contract to fulfill a slow fill relay
     * for a deposit in the next bundle.
     * @dev Slow fills are not possible unless the input and output tokens are "equivalent", i.e.
     * they route to the same L1 token via PoolRebalanceRoutes.
     * @dev Slow fills are created by inserting slow fill objects into a merkle tree that is included
     * in the next HubPool "root bundle". Once the optimistic challenge window has passed, the HubPool
     * will relay the slow root to this chain via relayRootBundle(). Once the slow root is relayed,
     * the slow fill can be executed by anyone who calls executeSlowRelayLeaf().
     * @dev Cannot request a slow fill if the fill deadline has passed.
     * @dev Cannot request a slow fill if the relay has already been filled or a slow fill has already been requested.
     * @param relayData struct containing all the data needed to identify the deposit that should be
     * slow filled. If any of the params are missing or different from the origin chain deposit,
     * then Across will not include a slow fill for the intended deposit.
     */
    function requestSlowFill(
        V3RelayData calldata relayData
    ) public override nonReentrant unpausedFills nonV5Fill(relayData.message) {
        uint32 currentTime = uint32(getCurrentTime());
        // If a depositor has set an exclusivity deadline, then only the exclusive relayer should be able to
        // fast fill within this deadline. Moreover, the depositor should expect to get *fast* filled within
        // this deadline, not slow filled. As a simplifying assumption, we will not allow slow fills to be requested
        // during this exclusivity period.
        if (_fillIsExclusive(relayData.exclusivityDeadline, currentTime)) {
            revert NoSlowFillsInExclusivityWindow();
        }
        if (relayData.fillDeadline < currentTime) revert ExpiredFillDeadline();

        bytes32 relayHash = getV3RelayHash(relayData);
        if (fillStatuses[relayHash] != uint256(FillStatus.Unfilled)) revert InvalidSlowFillRequest();
        fillStatuses[relayHash] = uint256(FillStatus.RequestedSlowFill);

        emit RequestedSlowFill(
            relayData.inputToken,
            relayData.outputToken,
            relayData.inputAmount,
            relayData.outputAmount,
            relayData.originChainId,
            relayData.depositId,
            relayData.fillDeadline,
            relayData.exclusivityDeadline,
            relayData.exclusiveRelayer,
            relayData.depositor,
            relayData.recipient,
            _hashNonEmptyMessage(relayData.message)
        );
    }

    /**
     * @notice Fills a single leg of a particular order on the destination chain
     * @dev Deprecated: ERC-7683 v1 fill function. A new version of ERC-7683 is being developed.
     * @param orderId Unique order identifier for this order
     * @param originData Data emitted on the origin to parameterize the fill
     * @param fillerData Data provided by the filler to inform the fill or express their preferences
     */
    function fill(bytes32 orderId, bytes calldata originData, bytes calldata fillerData) external {
        if (keccak256(abi.encode(originData, chainId())) != orderId) {
            revert WrongERC7683OrderId();
        }

        // Ensure that the call is not malformed. If the call is malformed, abi.decode will fail.
        V3SpokePoolInterface.V3RelayData memory relayData = abi.decode(originData, (V3SpokePoolInterface.V3RelayData));
        AcrossDestinationFillerData memory destinationFillerData = abi.decode(
            fillerData,
            (AcrossDestinationFillerData)
        );

        // Must do a delegatecall because the function requires the inputs to be calldata.
        (bool success, bytes memory data) = address(this).delegatecall(
            abi.encodeCall(
                V3SpokePoolInterface.fillRelay,
                (relayData, destinationFillerData.repaymentChainId, msg.sender.toBytes32())
            )
        );
        if (!success) {
            revert LowLevelCallFailed(data);
        }
    }

    /**************************************
     *         DATA WORKER FUNCTIONS      *
     **************************************/

    /**
     * @notice Executes a slow relay leaf stored as part of a root bundle relayed by the HubPool.
     * @dev Executing a slow fill leaf is equivalent to filling the relayData so this function cannot be used to
     * double fill a recipient. The relayData that is filled is included in the slowFillLeaf and is hashed
     * like any other fill sent through a fill method.
     * @dev There is no relayer credited with filling this relay since funds are sent directly out of this contract.
     * @param slowFillLeaf Contains all data necessary to uniquely identify a relay for this chain. This struct is
     * hashed and included in a merkle root that is relayed to all spoke pools.
     * - relayData: struct containing all the data needed to identify the original deposit to be slow filled.
     * - chainId: chain identifier where slow fill leaf should be executed. If this doesn't match this chain's
     * chainId, then this function will revert.
     * - updatedOutputAmount: Amount to be sent to recipient out of this contract's balance. Can be set differently
     * from relayData.outputAmount to charge a different fee because this deposit was "slow" filled. Usually,
     * this will be set higher to reimburse the recipient for waiting for the slow fill.
     * @param rootBundleId Unique ID of root bundle containing slow relay root that this leaf is contained in.
     * @param proof Inclusion proof for this leaf in slow relay root in root bundle.
     */
    function executeSlowRelayLeaf(
        V3SlowFill calldata slowFillLeaf,
        uint32 rootBundleId,
        bytes32[] calldata proof
    ) public override nonReentrant nonV5Fill(slowFillLeaf.relayData.message) {
        V3RelayData memory relayData = slowFillLeaf.relayData;

        _preExecuteLeafHook(relayData.outputToken.toAddress());

        // @TODO In the future consider allowing way for slow fill leaf to be created with updated
        // deposit params like outputAmount, message and recipient.
        V3RelayExecutionParams memory relayExecution = V3RelayExecutionParams({
            relay: relayData,
            relayHash: getV3RelayHash(relayData),
            updatedOutputAmount: slowFillLeaf.updatedOutputAmount,
            updatedRecipient: relayData.recipient,
            updatedMessage: relayData.message,
            repaymentChainId: EMPTY_REPAYMENT_CHAIN_ID // Repayment not relevant for slow fills.
        });

        _verifyV3SlowFill(relayExecution, rootBundleId, proof);

        // - No relayer to refund for slow fill executions.
        _fillRelayV3(relayExecution, EMPTY_RELAYER, true);
    }

    /**
     * @notice Executes a relayer refund leaf stored as part of a root bundle. Will send the relayer the amount they
     * sent to the recipient plus a relayer fee.
     * @param rootBundleId Unique ID of root bundle containing relayer refund root that this leaf is contained in.
     * @param relayerRefundLeaf Contains all data necessary to reconstruct leaf contained in root bundle and to
     * refund relayer. This data structure is explained in detail in the SpokePoolInterface.
     * @param proof Inclusion proof for this leaf in relayer refund root in root bundle.
     */
    function executeRelayerRefundLeaf(
        uint32 rootBundleId,
        SpokePoolInterface.RelayerRefundLeaf memory relayerRefundLeaf,
        bytes32[] memory proof
    ) public payable virtual override nonReentrant {
        _preExecuteLeafHook(relayerRefundLeaf.l2TokenAddress);

        if (relayerRefundLeaf.chainId != chainId()) revert InvalidChainId();

        RootBundle storage rootBundle = rootBundles[rootBundleId];

        // Check that proof proves that relayerRefundLeaf is contained within the relayer refund root.
        // Note: This should revert if the relayerRefundRoot is uninitialized.
        if (!MerkleLib.verifyRelayerRefund(rootBundle.relayerRefundRoot, relayerRefundLeaf, proof)) {
            revert InvalidMerkleProof();
        }

        _setClaimedLeaf(rootBundleId, relayerRefundLeaf.leafId);

        bool deferredRefunds = _distributeRelayerRefunds(
            relayerRefundLeaf.chainId,
            relayerRefundLeaf.amountToReturn,
            relayerRefundLeaf.refundAmounts,
            relayerRefundLeaf.leafId,
            relayerRefundLeaf.l2TokenAddress,
            relayerRefundLeaf.refundAddresses
        );

        emit ExecutedRelayerRefundRoot(
            relayerRefundLeaf.amountToReturn,
            relayerRefundLeaf.chainId,
            relayerRefundLeaf.refundAmounts,
            rootBundleId,
            relayerRefundLeaf.leafId,
            relayerRefundLeaf.l2TokenAddress,
            relayerRefundLeaf.refundAddresses,
            deferredRefunds,
            msg.sender
        );
    }

    /**
     * @notice Enables a relayer to claim outstanding repayments. Should virtually never be used, unless for some reason
     * relayer repayment transfer fails for reasons such as token transfer reverts due to blacklisting. In this case,
     * the relayer can still call this method and claim the tokens to a new address.
     * @param l2TokenAddress Address of the L2 token to claim refunds for.
     * @param refundAddress Address to send the refund to.
     */
    function claimRelayerRefund(bytes32 l2TokenAddress, bytes32 refundAddress) external {
        uint256 refund = relayerRefund[l2TokenAddress.toAddress()][msg.sender];
        if (refund == 0) revert NoRelayerRefundToClaim();
        relayerRefund[l2TokenAddress.toAddress()][msg.sender] = 0;
        _safeTransfer(l2TokenAddress.toAddress(), refundAddress.toAddress(), refund);

        emit ClaimedRelayerRefund(l2TokenAddress, refundAddress, refund, msg.sender);
    }

    /**************************************
     *           VIEW FUNCTIONS           *
     **************************************/

    /**
     * @notice Returns chain ID for this network.
     * @dev Some L2s like ZKSync don't support the CHAIN_ID opcode so we allow the implementer to override this.
     */
    function chainId() public view virtual override returns (uint256) {
        return block.chainid;
    }

    /**
     * @notice Gets the current time.
     * @return uint for the current timestamp.
     */
    function getCurrentTime() public view virtual returns (uint256) {
        return block.timestamp; // solhint-disable-line not-rely-on-time
    }

    /**
     * @notice Returns the deposit ID for an unsafe deposit. This function is used to compute the deposit ID
     * in unsafeDeposit and is provided as a convenience.
     * @dev msgSender and depositor are both used as inputs to allow passthrough depositors to create unique
     * deposit hash spaces for unique depositors.
     * @param msgSender The caller of the transaction used as input to produce the deposit ID.
     * @param depositor The depositor address used as input to produce the deposit ID.
     * @param depositNonce The nonce used as input to produce the deposit ID.
     * @return The deposit ID for the unsafe deposit.
     */
    function getUnsafeDepositId(
        address msgSender,
        bytes32 depositor,
        uint256 depositNonce
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(msgSender, depositor, depositNonce)));
    }

    function getRelayerRefund(address l2TokenAddress, address refundAddress) public view returns (uint256) {
        return relayerRefund[l2TokenAddress][refundAddress];
    }

    function getV3RelayHash(V3RelayData memory relayData) public view returns (bytes32) {
        return keccak256(abi.encode(relayData, chainId()));
    }

    /**************************************
     *         INTERNAL FUNCTIONS         *
     **************************************/

    function _depositV3(DepositV3Params memory params) internal {
        // Verify depositor is a valid EVM address.
        params.depositor.checkAddress();

        // Verify output token is not zero address.
        if (params.outputToken == bytes32(0)) revert InvalidOutputToken();

        // Require that quoteTimestamp has a maximum age so that depositors pay an LP fee based on recent HubPool usage.
        // It is assumed that cross-chain timestamps are normally loosely in-sync, but clock drift can occur. If the
        // SpokePool time stalls or lags significantly, it is still possible to make deposits by setting quoteTimestamp
        // within the configured buffer. The owner should pause deposits/fills if this is undesirable.
        // This will underflow if quoteTimestamp is more than depositQuoteTimeBuffer;
        // this is safe but will throw an unintuitive error.

        // slither-disable-next-line timestamp
        uint256 currentTime = getCurrentTime();
        if (currentTime < params.quoteTimestamp || currentTime - params.quoteTimestamp > depositQuoteTimeBuffer)
            revert InvalidQuoteTimestamp();

        // fillDeadline is relative to the destination chain.
        // Don’t allow fillDeadline to be more than several bundles into the future.
        // This limits the maximum required lookback for dataworker and relayer instances.
        if (params.fillDeadline > currentTime + fillDeadlineBuffer) revert InvalidFillDeadline();

        // There are three cases for setting the exclusivity deadline using the exclusivity parameter:
        // 1. If this parameter is 0, then there is no exclusivity period and emit 0 for the deadline. This
        //    means that fillers of this deposit do not have to worry about the block.timestamp of this event changing
        //    due to re-orgs when filling this deposit.
        // 2. If the exclusivity parameter is less than or equal to MAX_EXCLUSIVITY_PERIOD_SECONDS, then the exclusivity
        //    deadline is set to the block.timestamp of this event plus the exclusivity parameter. This means that the
        //    filler of this deposit assumes re-org risk when filling this deposit because the block.timestamp of this
        //    event affects the exclusivity deadline.
        // 3. Otherwise, interpret this parameter as a timestamp and emit it as the exclusivity deadline. This means
        //    that the filler of this deposit will not assume re-org risk related to the block.timestamp of this
        //    event changing.
        uint32 exclusivityDeadline = params.exclusivityParameter;
        if (exclusivityDeadline > 0) {
            if (exclusivityDeadline <= MAX_EXCLUSIVITY_PERIOD_SECONDS) {
                exclusivityDeadline += uint32(currentTime);
            }

            // As a safety measure, prevent caller from inadvertently locking funds during exclusivity period
            //  by forcing them to specify an exclusive relayer.
            if (params.exclusiveRelayer == bytes32(0)) revert InvalidExclusiveRelayer();
        }

        // If the address of the origin token is a wrappedNativeToken contract and there is a msg.value with the
        // transaction then the user is sending the native token. In this case, the native token should be
        // wrapped.
        if (params.inputToken == address(wrappedNativeToken).toBytes32() && msg.value > 0) {
            if (msg.value != params.inputAmount) revert MsgValueDoesNotMatchInputAmount();
            wrappedNativeToken.deposit{ value: msg.value }();
            // Else, it is a normal ERC20. In this case pull the token from the caller as per normal.
            // Note: this includes the case where the L2 caller has WETH (already wrapped ETH) and wants to bridge them.
            // In this case the msg.value will be set to 0, indicating a "normal" ERC20 bridging action.
        } else {
            // msg.value should be 0 if input token isn't the wrapped native token.
            if (msg.value != 0) revert MsgValueDoesNotMatchInputAmount();
            IERC20Upgradeable(params.inputToken.toAddress()).safeTransferFrom(
                msg.sender,
                address(this),
                params.inputAmount
            );
        }

        emit FundsDeposited(
            params.inputToken,
            params.outputToken,
            params.inputAmount,
            params.outputAmount,
            params.destinationChainId,
            params.depositId,
            params.quoteTimestamp,
            params.fillDeadline,
            exclusivityDeadline,
            params.depositor,
            params.recipient,
            params.exclusiveRelayer,
            params.message
        );
    }

    function _distributeRelayerRefunds(
        uint256 _chainId,
        uint256 amountToReturn,
        uint256[] memory refundAmounts,
        uint32 leafId,
        address l2TokenAddress,
        address[] memory refundAddresses
    ) internal returns (bool deferredRefunds) {
        uint256 numRefunds = refundAmounts.length;
        if (refundAddresses.length != numRefunds) revert InvalidMerkleLeaf();

        if (numRefunds > 0) {
            uint256 spokeStartBalance = IERC20Upgradeable(l2TokenAddress).balanceOf(address(this));
            uint256 totalRefundedAmount = 0; // Track the total amount refunded.

            // Send each relayer refund address the associated refundAmount for the L2 token address.
            // Note: Even if the L2 token is not enabled on this spoke pool, we should still refund relayers.
            for (uint256 i = 0; i < numRefunds; ++i) {
                if (refundAmounts[i] > 0) {
                    totalRefundedAmount += refundAmounts[i];

                    // Only if the total refunded amount exceeds the spoke starting balance, should we revert. This
                    // ensures that bundles are atomic, if we have sufficient balance to refund all relayers and
                    // prevents can only re-pay some of the relayers.
                    if (totalRefundedAmount > spokeStartBalance) revert InsufficientSpokePoolBalanceToExecuteLeaf();

                    bool success = _noRevertTransfer(l2TokenAddress, refundAddresses[i], refundAmounts[i]);

                    // If the transfer failed then track a deferred transfer for the relayer. Given this function would
                    // have reverted if there was insufficient balance, this will only happen if the transfer call
                    // reverts. This will only occur if the underlying transfer method on the l2Token reverts due to
                    // recipient blacklisting or other related modifications to the l2Token.transfer method.
                    if (!success) {
                        relayerRefund[l2TokenAddress][refundAddresses[i]] += refundAmounts[i];
                        deferredRefunds = true;
                    }
                }
            }
        }
        // If leaf's amountToReturn is positive, then send L2 --> L1 message to bridge tokens back via
        // chain-specific bridging method.
        if (amountToReturn > 0) {
            _bridgeTokensToHubPool(amountToReturn, l2TokenAddress);

            emit TokensBridged(amountToReturn, _chainId, leafId, l2TokenAddress.toBytes32(), msg.sender);
        }
    }

    // Re-implementation of OZ _callOptionalReturnBool to use private logic. Function executes a transfer and returns a
    // bool indicating if the external call was successful, rather than reverting. Original method:
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/28aed34dc5e025e61ea0390c18cac875bfde1a78/contracts/token/ERC20/utils/SafeERC20.sol#L188
    function _noRevertTransfer(address token, address to, uint256 amount) internal virtual returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        bytes memory data = abi.encodeCall(IERC20Upgradeable.transfer, (to, amount));
        assembly {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }

    function _setCrossDomainAdmin(address newCrossDomainAdmin) internal {
        if (newCrossDomainAdmin == address(0)) revert InvalidCrossDomainAdmin();
        crossDomainAdmin = newCrossDomainAdmin;
        emit SetXDomainAdmin(newCrossDomainAdmin);
    }

    function _setWithdrawalRecipient(address newWithdrawalRecipient) internal {
        if (newWithdrawalRecipient == address(0)) revert InvalidWithdrawalRecipient();
        withdrawalRecipient = newWithdrawalRecipient;
        emit SetWithdrawalRecipient(newWithdrawalRecipient);
    }

    function _preExecuteLeafHook(address) internal virtual {
        // This method by default is a no-op. Different child spoke pools might want to execute functionality here
        // such as wrapping any native tokens owned by the contract into wrapped tokens before proceeding with
        // executing the leaf.
    }

    // Should be overridden by implementing contract depending on how L2 handles sending tokens to L1.
    function _bridgeTokensToHubPool(uint256 amountToReturn, address l2TokenAddress) internal virtual;

    function _setClaimedLeaf(uint32 rootBundleId, uint32 leafId) internal {
        RootBundle storage rootBundle = rootBundles[rootBundleId];

        // Verify the leafId in the leaf has not yet been claimed.
        if (MerkleLib.isClaimed(rootBundle.claimedBitmap, leafId)) revert ClaimedMerkleLeaf();

        // Set leaf as claimed in bitmap. This is passed by reference to the storage rootBundle.
        MerkleLib.setClaimed(rootBundle.claimedBitmap, leafId);
    }

    function _verifyUpdateV3DepositMessage(
        address depositor,
        uint256 depositId,
        uint256 originChainId,
        uint256 updatedOutputAmount,
        bytes32 updatedRecipient,
        bytes memory updatedMessage,
        bytes memory depositorSignature,
        bytes32 hashType
    ) internal view {
        // A depositor can request to modify an un-relayed deposit by signing a hash containing the updated
        // details and information uniquely identifying the deposit to relay. This information ensures
        // that this signature cannot be re-used for other deposits.
        bytes32 expectedTypedDataV4Hash = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    hashType,
                    depositId,
                    originChainId,
                    updatedOutputAmount,
                    updatedRecipient,
                    keccak256(updatedMessage)
                )
            ),
            originChainId
        );
        _verifyDepositorSignature(depositor, expectedTypedDataV4Hash, depositorSignature);
    }

    // This function is isolated and made virtual to allow different L2's to implement chain specific recovery of
    // signers from signatures because some L2s might not support ecrecover. To be safe, consider always reverting
    // this function for L2s where ecrecover is different from how it works on Ethereum, otherwise there is the
    // potential to forge a signature from the depositor using a different private key than the original depositor's.
    function _verifyDepositorSignature(
        address depositor,
        bytes32 ethSignedMessageHash,
        bytes memory depositorSignature
    ) internal view virtual {
        // Note:
        // - We don't need to worry about re-entrancy from a contract deployed at the depositor address since the method
        //   `SignatureChecker.isValidSignatureNow` is a view method. Re-entrancy can happen, but it cannot affect state.
        // - EIP-1271 signatures are supported. This means that a signature valid now, may not be valid later and vice-versa.
        // - For an EIP-1271 signature to work, the depositor contract address must map to a deployed contract on the destination
        //   chain that can validate the signature.
        // - Regular signatures from an EOA are also supported.
        bool isValid = SignatureChecker.isValidSignatureNow(depositor, ethSignedMessageHash, depositorSignature);
        if (!isValid) revert InvalidDepositorSignature();
    }

    function _verifyV3SlowFill(
        V3RelayExecutionParams memory relayExecution,
        uint32 rootBundleId,
        bytes32[] memory proof
    ) internal view {
        V3SlowFill memory slowFill = V3SlowFill({
            relayData: relayExecution.relay,
            chainId: chainId(),
            updatedOutputAmount: relayExecution.updatedOutputAmount
        });

        if (!MerkleLib.verifyV3SlowRelayFulfillment(rootBundles[rootBundleId].slowRelayRoot, slowFill, proof)) {
            revert InvalidMerkleProof();
        }
    }

    function _computeAmountPostFees(uint256 amount, int256 feesPct) private pure returns (uint256) {
        return (amount * uint256(int256(1e18) - feesPct)) / 1e18;
    }

    // Unwraps ETH and does a transfer to a recipient address. If the recipient is a smart contract then sends wrappedNativeToken.
    function _unwrapwrappedNativeTokenTo(address payable to, uint256 amount) internal {
        if (!AddressLibUpgradeable.isContract(address(to)) || _is7702DelegatedWallet(to)) {
            wrappedNativeToken.withdraw(amount);
            AddressLibUpgradeable.sendValue(to, amount);
        } else {
            _safeTransfer(address(wrappedNativeToken), to, amount);
        }
    }

    /**
     * @notice Checks if an address is a 7702 delegated wallet (EOA with delegated code).
     * @param account The address to check.
     * @return True if the address is a 7702 delegated wallet, false otherwise.
     */
    function _is7702DelegatedWallet(address account) internal view virtual returns (bool) {
        return bytes3(account.code) == EIP7702_PREFIX;
    }

    // Exclusivity deadline is inclusive and is the latest timestamp that the exclusive relayer has sole right
    // to fill the relay. `filler` is msg.sender for V3 fills and the Gateway's current submitter for V5 fills.
    function _requireExclusiveFiller(
        uint32 exclusivityDeadline,
        bytes32 exclusiveRelayer,
        address filler
    ) internal view {
        if (_fillIsExclusive(exclusivityDeadline, uint32(getCurrentTime())) && exclusiveRelayer.toAddress() != filler) {
            revert NotExclusiveRelayer();
        }
    }

    /**
     * @notice Shared core of both V5 fill modes: validates the committed acceptance bounds against the
     * submitter-supplied relay data, binds the fill to the live Gateway execution, and settles it through the
     * standard fill pipeline (fill-status ledger, FilledRelay event, token transfer, optional callback).
     * @dev The supplied relay data is hashed verbatim, so every `V5FillInput` commitment must be explicitly
     * checked against it here — recipient, output token, the output-amount floor, and the witness
     * `message == V5_MAGIC_PREFIX || gateway.currentStepId()`. The witness check makes the relay hash only
     * match a real deposit if that deposit committed to the root being executed; marking that hash filled is
     * the replay protection. The unchecked relay-data fields are competition parameters the submitter proves
     * by paying: a wrong value yields a hash matching no real deposit, forfeiting the refund. Exclusivity is
     * judged against the Gateway's current submitter in both modes: identity for relayer competition is
     * decoupled from where funds are pulled.
     * @param fillInput Deposit-committed acceptance bounds.
     * @param fillJit Submitter-supplied relay data and repayment fields.
     * @param payer Address the output tokens are pulled from: the Gateway's current submitter (executor mode)
     * or msg.sender, the executing tape's own balance (adapter mode).
     */
    function _fillV5(V5FillInput memory fillInput, V5FillJit memory fillJit, address payer) internal unpausedFills {
        V3RelayData memory relayData = fillJit.relayData;
        if (
            relayData.recipient != fillInput.recipient ||
            relayData.outputToken != fillInput.outputToken ||
            keccak256(relayData.message) != keccak256(abi.encodePacked(V5_MAGIC_PREFIX, gateway.currentStepId()))
        ) revert V5CommitmentMismatch();
        if (relayData.outputAmount < fillInput.minOutputAmount) revert V5OutputAmountTooLow();
        _requireExclusiveFiller(relayData.exclusivityDeadline, relayData.exclusiveRelayer, gateway.currentSubmitter());

        V3RelayExecutionParams memory relayExecution = V3RelayExecutionParams({
            relay: relayData,
            relayHash: getV3RelayHash(relayData),
            updatedOutputAmount: relayData.outputAmount,
            updatedRecipient: relayData.recipient,
            updatedMessage: fillInput.message,
            repaymentChainId: fillJit.repaymentChainId
        });

        _fillRelay(relayExecution, fillJit.repaymentAddress, false, payer);
    }

    // @param relayer: relayer who is actually credited as filling this deposit. Can be different from
    // exclusiveRelayer if passed exclusivityDeadline or if slow fill.
    function _fillRelayV3(V3RelayExecutionParams memory relayExecution, bytes32 relayer, bool isSlowFill) internal {
        _fillRelay(relayExecution, relayer, isSlowFill, msg.sender);
    }

    // @param payer: address that fast-fill output tokens are pulled from. Always msg.sender for V3 fills; V5
    // fills pull from the Gateway's current submitter (executor mode) or the executing tape (adapter mode).
    function _fillRelay(
        V3RelayExecutionParams memory relayExecution,
        bytes32 relayer,
        bool isSlowFill,
        address payer
    ) internal {
        V3RelayData memory relayData = relayExecution.relay;

        if (relayData.fillDeadline < getCurrentTime()) revert ExpiredFillDeadline();

        bytes32 relayHash = relayExecution.relayHash;

        // If a slow fill for this fill was requested then the relayFills value for this hash will be
        // FillStatus.RequestedSlowFill. Therefore, if this is the status, then this fast fill
        // will be replacing the slow fill. If this is a slow fill execution, then the following variable
        // is trivially true. We'll emit this value in the FilledRelay
        // event to assist the Dataworker in knowing when to return funds back to the HubPool that can no longer
        // be used for a slow fill execution.
        FillType fillType = isSlowFill
            ? FillType.SlowFill // The following is true if this is a fast fill that was sent after a slow fill request.
            : (
                fillStatuses[relayExecution.relayHash] == uint256(FillStatus.RequestedSlowFill)
                    ? FillType.ReplacedSlowFill
                    : FillType.FastFill
            );

        // @dev This function doesn't support partial fills. Therefore, we associate the relay hash with
        // an enum tracking its fill status. All filled relays, whether slow or fast fills, are set to the Filled
        // status. However, we also use this slot to track whether this fill had a slow fill requested. Therefore
        // we can include a bool in the FilledRelay event making it easy for the dataworker to compute if this
        // fill was a fast fill that replaced a slow fill and therefore this SpokePool has excess funds that it
        // needs to send back to the HubPool.
        if (fillStatuses[relayHash] == uint256(FillStatus.Filled)) revert RelayFilled();
        fillStatuses[relayHash] = uint256(FillStatus.Filled);

        _emitFilledRelayEvent(relayExecution, relayData, relayer, fillType);
        _transferTokensToRecipient(relayExecution, relayData, payer, isSlowFill);
    }

    /**
     * @notice Emits the FilledRelay event for a completed relay fill.
     * @param relayExecution The relay execution parameters.
     * @param relayData The relay data.
     * @param relayer The relayer address.
     * @param fillType The type of fill being executed.
     */
    function _emitFilledRelayEvent(
        V3RelayExecutionParams memory relayExecution,
        V3RelayData memory relayData,
        bytes32 relayer,
        FillType fillType
    ) internal {
        emit FilledRelay(
            relayData.inputToken,
            relayData.outputToken,
            relayData.inputAmount,
            relayData.outputAmount,
            relayExecution.repaymentChainId,
            relayData.originChainId,
            relayData.depositId,
            relayData.fillDeadline,
            relayData.exclusivityDeadline,
            relayData.exclusiveRelayer,
            relayer,
            relayData.depositor,
            relayData.recipient,
            _hashNonEmptyMessage(relayData.message),
            V3RelayExecutionEventInfo({
                updatedRecipient: relayExecution.updatedRecipient,
                updatedMessageHash: _hashNonEmptyMessage(relayExecution.updatedMessage),
                updatedOutputAmount: relayExecution.updatedOutputAmount,
                fillType: fillType
            })
        );
    }

    /**
     * @notice Transfers tokens to the recipient based on the relay execution parameters.
     * @param relayExecution The relay execution parameters.
     * @param relayData The relay data.
     * @param payer Address fast-fill output tokens are pulled from; also reported as the relayer to the
     * recipient's handleV3AcrossMessage hook. Unused for the slow-fill transfer, which pays out of reserves.
     * @param isSlowFill Whether this is a slow fill execution.
     */
    function _transferTokensToRecipient(
        V3RelayExecutionParams memory relayExecution,
        V3RelayData memory relayData,
        address payer,
        bool isSlowFill
    ) internal {
        address outputToken = relayData.outputToken.toAddress();
        uint256 amountToSend = relayExecution.updatedOutputAmount;
        address recipientToSend = relayExecution.updatedRecipient.toAddress();

        // If relay token is wrappedNativeToken then unwrap and send native token.
        if (outputToken == address(wrappedNativeToken)) {
            // Note: useContractFunds is True if we want to send funds to the recipient directly out of this contract,
            // otherwise we expect the caller to send funds to the recipient. If useContractFunds is True and the
            // recipient wants wrappedNativeToken, then we can assume that wrappedNativeToken is already in the
            // contract, otherwise we'll need the user to send wrappedNativeToken to this contract. Regardless, we'll
            // need to unwrap it to native token before sending to the user.
            if (!isSlowFill) IERC20Upgradeable(outputToken).safeTransferFrom(payer, address(this), amountToSend);
            _unwrapwrappedNativeTokenTo(payable(recipientToSend), amountToSend);
            // Else, this is a normal ERC20 token. Send to recipient.
        } else {
            // Note: Similar to note above, send token directly from the contract to the user in the slow relay case.
            if (!isSlowFill) IERC20Upgradeable(outputToken).safeTransferFrom(payer, recipientToSend, amountToSend);
            else _safeTransfer(outputToken, recipientToSend, amountToSend);
        }

        bytes memory updatedMessage = relayExecution.updatedMessage;
        if (updatedMessage.length > 0 && AddressLibUpgradeable.isContract(recipientToSend)) {
            AcrossMessageHandler(recipientToSend).handleV3AcrossMessage(
                outputToken,
                amountToSend,
                payer,
                updatedMessage
            );
        }
    }

    // Determine whether the exclusivityDeadline implies active exclusivity.
    function _fillIsExclusive(uint32 exclusivityDeadline, uint32 currentTime) internal pure returns (bool) {
        return exclusivityDeadline >= currentTime;
    }

    // Returns true if `message` is V5-tagged (starts with V5_MAGIC_PREFIX), meaning the deposit is consumable
    // only through the V5 fill entrypoints.
    function _isV5Message(bytes memory message) internal pure returns (bool) {
        if (message.length < 32) return false;
        bytes32 header;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            header := mload(add(message, 32))
        }
        return header == V5_MAGIC_PREFIX;
    }

    // Helper for emitting message hash. For easier easier human readability we return bytes32(0) for empty message.
    function _hashNonEmptyMessage(bytes memory message) internal pure returns (bytes32) {
        if (message.length == 0) return bytes32(0);
        else return keccak256(message);
    }

    function _setOftMessenger(address _token, address _messenger) private {
        if (_messenger != address(0) && IOFT(_messenger).token() != _token) {
            revert OFTTokenMismatch();
        }
        oftMessengers[_token] = _messenger;
        emit SetOFTMessenger(_token, _messenger);
    }

    function _getOftMessenger(address _token) internal view returns (address) {
        return oftMessengers[_token];
    }

    /**
     * @notice Perform an OFT transfer where the caller supplies the native fee via msg.value.
     * @dev Supports overpayment: any excess native token is refunded to msg.sender before executing the transfer.
     *      This function does not re-quote and uses the provided `fee` with `_sendOftTransfer`.
     *      Must be invoked from a payable context.
     * @param _token ERC-20 token to transfer.
     * @param _messenger OFT messenger contract on the current chain for `_token`.
     * @param _to Destination address on the remote chain.
     * @param _amount Amount of tokens to transfer.
     */
    function _fundedTransferViaOft(IERC20 _token, IOFT _messenger, address _to, uint256 _amount) internal {
        (SendParam memory sendParam, MessagingFee memory fee) = _buildOftTransfer(_messenger, _to, _amount);

        if (fee.nativeFee > msg.value) {
            revert OFTFeeUnderpaid();
        }
        // Refund any overpayment to the caller using a safe native transfer.
        uint256 refund = msg.value - fee.nativeFee;
        if (refund > 0) {
            AddressLibUpgradeable.sendValue(payable(msg.sender), refund);
        }
        _sendOftTransfer(_token, _messenger, sendParam, fee);
    }

    // Implementing contract needs to override this to ensure that only the appropriate cross chain admin can execute
    // certain admin functions. For L2 contracts, the cross chain admin refers to some L1 address or contract, and for
    // L1, this would just be the same admin of the HubPool.
    function _requireAdminSender() internal virtual;

    // Added to enable the this contract to receive native token (ETH). Used when unwrapping wrappedNativeToken.
    receive() external payable {}

    // Reserve storage slots for future versions of this base contract to add state variables without
    // affecting the storage layout of child contracts. Decrement the size of __gap whenever state variables
    // are added, so that the total number of slots taken by this contract remains constant. Per-contract
    // storage layout information  can be found in storage-layouts/
    // This is at bottom of contract to make sure it's always at the end of storage.
    uint256[997] private __gap;
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/IERC1967Upgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import {Initializable} from "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable, IERC1967Upgradeable {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// ===== contracts/upgradeable/EIP712CrossChainUpgradeable.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable-v4/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable-v4/proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * This contract is based on OpenZeppelin's implementation:
 * https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/utils/cryptography/EIP712Upgradeable.sol
 *
 * NOTE: Modified version that allows to build a domain separator that relies on a different chain id than the chain this
 * contract is deployed to. An example use case we want to support is:
 * - User A signs a message on chain with id = 1
 * - User B executes a method by verifying user A's EIP-712 compliant signature on a chain with id != 1
 * @custom:security-contact bugs@across.to
 */
abstract contract EIP712CrossChainUpgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator depending on the `originChainId`.
     * @param originChainId Chain id of network where message originates from.
     * @return bytes32 EIP-712-compliant domain separator.
     */
    function _domainSeparatorV4(uint256 originChainId) internal view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION, originChainId));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 structHash = keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * ));
     * bytes32 digest = _hashTypedDataV4(structHash, originChainId);
     * address signer = ECDSA.recover(digest, signature);
     * ```
     * @param structHash Hashed struct as defined in https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct.
     * @param originChainId Chain id of network where message originates from.
     * @return bytes32 Hash digest that is recoverable via `EDCSA.recover`.
     */
    function _hashTypedDataV4(bytes32 structHash, uint256 originChainId) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(originChainId), structHash);
    }

    // Reserve storage slots for future versions of this base contract to add state variables without
    // affecting the storage layout of child contracts. Decrement the size of __gap whenever state variables
    // are added, so that the total number of slots taken by this contract remains constant. Per-contract
    // storage layout information  can be found in storage-layouts/
    // This is at bottom of contract to make sure it's always at the end of storage.
    uint256[1000] private __gap;
}


// ===== node_modules/@openzeppelin/contracts-v4/utils/math/Math.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
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
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
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
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/utils/StringsUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";
import "./math/SignedMathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
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
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMathUpgradeable.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


// ===== node_modules/@openzeppelin/contracts-v4/utils/math/SignedMath.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}


// ===== node_modules/@openzeppelin/contracts-v4/token/ERC20/IERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// ===== contracts/upgradeable/MultiCallerUpgradeable.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title MultiCallerUpgradeable
 * @notice Logic is 100% copied from "contracts/external/uma/core/contracts/common/implementation/MultiCaller.sol" but one
 * comment is added to clarify why we allow delegatecall() in this contract, which is typically unsafe for use in
 * upgradeable implementation contracts.
 * @dev See https://docs.openzeppelin.com/upgrades-plugins/1.x/faq#delegatecall-selfdestruct for more details.
 * @custom:security-contact bugs@across.to
 */
contract MultiCallerUpgradeable {
    struct Result {
        bool success;
        bytes returnData;
    }

    function _validateMulticallData(bytes[] calldata data) internal virtual {
        // no-op
    }

    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {
        _validateMulticallData(data);

        uint256 dataLength = data.length;
        results = new bytes[](dataLength);

        //slither-disable-start calls-loop
        for (uint256 i = 0; i < dataLength; ++i) {
            // Typically, implementation contracts used in the upgradeable proxy pattern shouldn't call `delegatecall`
            // because it could allow a malicious actor to call this implementation contract directly (rather than
            // through a proxy contract) and then selfdestruct() the contract, thereby freezing the upgradeable
            // proxy. However, since we're only delegatecall-ing into this contract, then we can consider this
            // use of delegatecall() safe.

            //slither-disable-start low-level-calls
            /// @custom:oz-upgrades-unsafe-allow delegatecall
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            //slither-disable-end low-level-calls

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                //slither-disable-next-line assembly
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
        //slither-disable-end calls-loop
    }

    function tryMulticall(bytes[] calldata data) external returns (Result[] memory results) {
        _validateMulticallData(data);

        uint256 dataLength = data.length;
        results = new Result[](dataLength);

        //slither-disable-start calls-loop
        for (uint256 i = 0; i < dataLength; ++i) {
            // The delegatecall here is safe for the same reasons outlined in the first multicall function.
            Result memory result = results[i];
            //slither-disable-start low-level-calls
            /// @custom:oz-upgrades-unsafe-allow delegatecall
            (result.success, result.returnData) = address(this).delegatecall(data[i]);
            //slither-disable-end low-level-calls
        }
        //slither-disable-end calls-loop
    }

    // Reserve storage slots for future versions of this base contract to add state variables without
    // affecting the storage layout of child contracts. Decrement the size of __gap whenever state variables
    // are added, so that the total number of slots taken by this contract remains constant. Per-contract
    // storage layout information  can be found in storage-layouts/
    // This is at bottom of contract to make sure it's always at the end of storage.
    uint256[1000] private __gap;
}


// ===== contracts/interfaces/ERC7683.sol =====
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

// @dev Deprecated: This ERC-7683 interface is from a previous version of the standard.
// A new version of ERC-7683 is being developed and will replace this interface.

/// @title IDestinationSettler
/// @notice Standard interface for settlement contracts on the destination chain
interface IDestinationSettler {
    /// @notice Fills a single leg of a particular order on the destination chain
    /// @param orderId Unique order identifier for this order
    /// @param originData Data emitted on the origin to parameterize the fill
    /// @param fillerData Data provided by the filler to inform the fill or express their preferences
    function fill(bytes32 orderId, bytes calldata originData, bytes calldata fillerData) external;
}

/// @dev Deprecated: See note above.
struct AcrossDestinationFillerData {
    uint256 repaymentChainId;
}


// ===== node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// ===== node_modules/@openzeppelin/contracts/interfaces/IERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

pragma solidity >=0.4.16;

import {IERC20} from "../token/ERC20/IERC20.sol";


// ===== contracts/libraries/OFTTransportAdapter.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts-v4/token/ERC20/utils/SafeERC20.sol";
import { IOFT, SendParam, MessagingFee, OFTReceipt } from "../interfaces/IOFT.sol";
import { AddressToBytes32 } from "../libraries/AddressConverters.sol";

/**
 * @notice Facilitate bridging tokens via LayerZero's OFT.
 * @dev This contract is intended to be inherited by other chain-specific adapters and spoke pools.
 * @custom:security-contact bugs@across.to
 */
contract OFTTransportAdapter {
    using SafeERC20 for IERC20;
    using AddressToBytes32 for address;

    /** @notice Empty bytes array used for OFT messaging parameters */
    bytes public constant EMPTY_MSG_BYTES = new bytes(0);

    /**
     * @notice Fee cap checked before sending messages to OFTMessenger
     * @dev Conservative (high) cap to not interfere with operations under normal conditions
     */
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    uint256 public immutable OFT_FEE_CAP;

    /**
     * @notice The destination endpoint id in the OFT messaging protocol.
     * @dev Source https://docs.layerzero.network/v2/developers/evm/technical-reference/deployed-contracts.
     */
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    uint32 public immutable OFT_DST_EID;

    /** @notice Thrown when OFT fee exceeds the configured cap */
    error OftFeeCapExceeded();

    /** @notice Thrown when contract has insufficient balance to pay OFT fees */
    error OftInsufficientBalanceForFee();

    /** @notice Thrown when LayerZero token fee is not zero (only native fees supported) */
    error OftLzFeeNotZero();

    /** @notice Thrown when amount received differs from expected amount */
    error OftIncorrectAmountReceivedLD();

    /** @notice Thrown when amount sent differs from expected amount */
    error OftIncorrectAmountSentLD();

    /**
     * @notice intiailizes the OFTTransportAdapter contract.
     * @param _oftDstEid the endpoint ID that OFT protocol will transfer funds to.
     * @param _feeCap a fee cap we check against before sending a message with value to OFTMessenger as fees.
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(uint32 _oftDstEid, uint256 _feeCap) {
        OFT_DST_EID = _oftDstEid;
        OFT_FEE_CAP = _feeCap;
    }

    /**
     * @notice transfer token to the other dstEid (e.g. chain) via OFT messaging protocol
     * @dev the caller has to provide both _token and _messenger. The caller is responsible for knowing the correct _messenger
     * @param _token token we're sending on current chain.
     * @param _messenger corresponding OFT messenger on current chain.
     * @param _to address to receive a transfer on the destination chain.
     * @param _amount amount to send.
     */
    function _transferViaOFT(IERC20 _token, IOFT _messenger, address _to, uint256 _amount) internal {
        (SendParam memory sendParam, MessagingFee memory fee) = _buildOftTransfer(_messenger, _to, _amount);
        _sendOftTransfer(_token, _messenger, sendParam, fee);
    }

    /**
     * @notice Build OFT send params and quote the native fee.
     * @dev Sets `minAmountLD == amountLD` to disallow silent deductions (e.g. dust removal) by OFT.
     *      The fee is quoted for payment in native token.
     * @param _messenger OFT messenger contract on the current chain for the token being sent.
     * @param _to Destination address on the remote chain.
     * @param _amount Amount of tokens to transfer.
     * @return sendParam The encoded OFT send parameters.
     * @return fee The quoted MessagingFee required for the transfer.
     */
    function _buildOftTransfer(
        IOFT _messenger,
        address _to,
        uint256 _amount
    ) internal view returns (SendParam memory, MessagingFee memory) {
        bytes32 to = _to.toBytes32();

        SendParam memory sendParam = SendParam(
            OFT_DST_EID,
            to,
            /**
             * _amount, _amount here specify `amountLD` and `minAmountLD`. Setting `minAmountLD` equal to `amountLD` protects us
             * from any changes to the sent amount due to internal OFT contract logic, e.g. `_removeDust`. Meaning that if any
             * dust is subtracted, the `.send()` should revert
             */
            _amount,
            _amount,
            /**
             * EMPTY_MSG_BYTES, EMPTY_MSG_BYTES, EMPTY_MSG_BYTES here specify `extraOptions`, `composeMsg` and `oftCmd`.
             * These can be set to empty bytes arrays for the purposes of sending a simple cross-chain transfer.
             */
            EMPTY_MSG_BYTES,
            EMPTY_MSG_BYTES,
            EMPTY_MSG_BYTES
        );

        // `false` in the 2nd param here refers to `bool _payInLzToken`. We will pay in native token, so set to `false`
        MessagingFee memory fee = _messenger.quoteSend(sendParam, false);

        return (sendParam, fee);
    }

    /**
     * @notice Execute an OFT transfer using pre-built params and fee.
     * @dev Verifies fee bounds and equality of sent/received amounts. Pays native fee from this contract.
     * @param _token ERC-20 token to transfer.
     * @param _messenger OFT messenger contract on the current chain for `_token`.
     * @param sendParam Pre-built OFT send parameters.
     * @param fee Quoted MessagingFee to pay for this transfer.
     */
    function _sendOftTransfer(
        IERC20 _token,
        IOFT _messenger,
        SendParam memory sendParam,
        MessagingFee memory fee
    ) internal {
        // Create a stack variable to optimize gas usage on subsequent reads
        uint256 nativeFee = fee.nativeFee;
        if (nativeFee > OFT_FEE_CAP) revert OftFeeCapExceeded();
        if (nativeFee > address(this).balance) revert OftInsufficientBalanceForFee();
        if (fee.lzTokenFee != 0) revert OftLzFeeNotZero();

        // Approve the exact _amount for `_messenger` to spend. Fee will be paid in native token
        uint256 _amount = sendParam.amountLD;
        _token.forceApprove(address(_messenger), _amount);

        (, OFTReceipt memory oftReceipt) = _messenger.send{ value: nativeFee }(sendParam, fee, address(this));

        // The HubPool expects that the amount received by the SpokePool is exactly the sent amount
        if (_amount != oftReceipt.amountReceivedLD) revert OftIncorrectAmountReceivedLD();
        // Also check the amount sent on origin chain to harden security
        if (_amount != oftReceipt.amountSentLD) revert OftIncorrectAmountSentLD();
    }
}


// ===== contracts/external/interfaces/IAcrossV5ExecutorAdapter.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @notice Across V5 adapter interface for stateful Executor handoffs (ADAPTER_CALL command targets). Canonical
 * definition lives in the Across V5 periphery repository.
 * @dev No return value: the Executor invokes adapters with a raw low-level call and discards success returndata,
 * so adapter results must be observed via state or balance requirements.
 */
interface IAcrossV5ExecutorAdapter {
    /// @param input   Tape-committed adapter input.
    /// @param jitData Submitter-provided dynamic data.
    function adapterExecuteAcrossV5(bytes calldata input, bytes calldata jitData) external payable;
}


// ===== node_modules/@openzeppelin/contracts-v4/utils/cryptography/SignatureChecker.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";
import "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Gnosis Safe.
 *
 * _Available since v4.1._
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success &&
            result.length >= 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
    }
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/security/ReentrancyGuardUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import {Initializable} from "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// ===== contracts/external/interfaces/IAcrossV5Executor.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @notice Across V5 executor interface. The Gateway calls the path-committed executor through this entrypoint
 * after verifying the path and running the funding loop. Canonical definition lives in the Across V5 periphery
 * repository.
 */
interface IAcrossV5Executor {
    /// @notice Execute a path's committed message.
    /// @param message         The path-committed message.
    /// @param executorMessage Submitter-provided dynamic data.
    function executeAcrossV5(bytes calldata message, bytes calldata executorMessage) external payable;
}


// ===== node_modules/@openzeppelin/contracts-v4/utils/Strings.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

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
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


// ===== node_modules/@openzeppelin/contracts/interfaces/IERC165.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

pragma solidity >=0.4.16;

import {IERC165} from "../utils/introspection/IERC165.sol";


// ===== contracts/libraries/SafeTransferERC20.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @notice Mixin exposing a virtual `_safeTransfer` hook. Default implementation uses
 *         OZ `SafeERC20.safeTransfer`. Inheritors may override to swap in alternative
 *         ERC20 transfer semantics.
 */
abstract contract SafeTransferERC20 {
    // This mixin is the only place in the codebase permitted to call `IERC20.safeTransfer`
    // directly. Inheriting contracts restrict their own `using` directives to exclude
    // `safeTransfer` so all transfer call sites are forced through this overridable hook.
    using { SafeERC20.safeTransfer } for IERC20;

    function _safeTransfer(address token, address to, uint256 amount) internal virtual {
        IERC20(token).safeTransfer(to, amount);
    }
}


// ===== node_modules/@openzeppelin/contracts-v4/interfaces/IERC1271.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/utils/math/MathUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
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
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
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
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
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
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}


// ===== node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.5.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        if (!_safeTransfer(token, to, value, true)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        if (!_safeTransferFrom(token, from, to, value, true)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _safeTransfer(token, to, value, false);
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _safeTransferFrom(token, from, to, value, false);
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        if (!_safeApprove(token, spender, value, false)) {
            if (!_safeApprove(token, spender, 0, true)) revert SafeERC20FailedOperation(address(token));
            if (!_safeApprove(token, spender, value, true)) revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that relies on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that relies on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Oppositely, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity `token.transfer(to, value)` call, relaxing the requirement on the return value: the
     * return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param to The recipient of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeTransfer(IERC20 token, address to, uint256 value, bool bubble) private returns (bool success) {
        bytes4 selector = IERC20.transfer.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(to, shr(96, not(0))))
            mstore(0x24, value)
            success := call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
        }
    }

    /**
     * @dev Imitates a Solidity `token.transferFrom(from, to, value)` call, relaxing the requirement on the return
     * value: the return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param from The sender of the tokens
     * @param to The recipient of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value,
        bool bubble
    ) private returns (bool success) {
        bytes4 selector = IERC20.transferFrom.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(from, shr(96, not(0))))
            mstore(0x24, and(to, shr(96, not(0))))
            mstore(0x44, value)
            success := call(gas(), token, 0, 0x00, 0x64, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
            mstore(0x60, 0)
        }
    }

    /**
     * @dev Imitates a Solidity `token.approve(spender, value)` call, relaxing the requirement on the return value:
     * the return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param spender The spender of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeApprove(IERC20 token, address spender, uint256 value, bool bubble) private returns (bool success) {
        bytes4 selector = IERC20.approve.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(spender, shr(96, not(0))))
            mstore(0x24, value)
            success := call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
        }
    }
}


// ===== node_modules/@openzeppelin/contracts-v4/utils/cryptography/ECDSA.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

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
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
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
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
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
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
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
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
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
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/access/OwnableUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import {Initializable} from "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// ===== node_modules/@openzeppelin/contracts-v4/utils/cryptography/MerkleProof.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}


// ===== contracts/libraries/AddressConverters.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Bytes32ToAddress {
    /**************************************
     *              ERRORS                *
     **************************************/
    error InvalidBytes32();

    function toAddress(bytes32 _bytes32) internal pure returns (address) {
        checkAddress(_bytes32);
        return address(uint160(uint256(_bytes32)));
    }

    function toAddressUnchecked(bytes32 _bytes32) internal pure returns (address) {
        return address(uint160(uint256(_bytes32)));
    }

    function checkAddress(bytes32 _bytes32) internal pure {
        if (!isValidAddress(_bytes32)) {
            revert InvalidBytes32();
        }
    }

    function isValidAddress(bytes32 _bytes32) internal pure returns (bool) {
        return uint256(_bytes32) >> 160 == 0;
    }
}

library AddressToBytes32 {
    function toBytes32(address _address) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_address)));
    }
}


// ===== node_modules/@openzeppelin/contracts-v4/token/ERC20/utils/SafeERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

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

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
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
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/utils/ContextUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;
import {Initializable} from "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// ===== contracts/interfaces/SpokePoolInterface.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice Contains common data structures and functions used by all SpokePool implementations.
 * @dev Active depositor functions (`deposit`, `depositV3`, `depositNow`, `depositV3Now`, `unsafeDeposit`) are
 * defined in `V3SpokePoolInterface.sol`. This interface primarily contains shared admin/root functions and removed
 * legacy selectors that are intentionally preserved to avoid accidental selector reuse.
 */
interface SpokePoolInterface {
    // This leaf is meant to be decoded in the SpokePool to pay out successful relayers.
    struct RelayerRefundLeaf {
        // This is the amount to return to the HubPool. This occurs when there is a PoolRebalanceLeaf netSendAmount that
        // is negative. This is just the negative of this value.
        uint256 amountToReturn;
        // Used to verify that this is being executed on the correct destination chainId.
        uint256 chainId;
        // This array designates how much each of those addresses should be refunded.
        uint256[] refundAmounts;
        // Used as the index in the bitmap to track whether this leaf has been executed or not.
        uint32 leafId;
        // The associated L2TokenAddress that these claims apply to.
        address l2TokenAddress;
        // Must be same length as refundAmounts and designates each address that must be refunded.
        address[] refundAddresses;
    }

    // Stores collection of merkle roots that can be published to this contract from the HubPool, which are referenced
    // by "data workers" via inclusion proofs to execute leaves in the roots.
    struct RootBundle {
        // Merkle root of slow relays that were not fully filled and whose recipient is still owed funds from the LP pool.
        bytes32 slowRelayRoot;
        // Merkle root of relayer refunds for successful relays.
        bytes32 relayerRefundRoot;
        // This is a 2D bitmap tracking which leaves in the relayer refund root have been claimed, with max size of
        // 256x(2^248) leaves per root.
        mapping(uint256 => uint256) claimedBitmap;
    }

    function setCrossDomainAdmin(address newCrossDomainAdmin) external;

    function setWithdrawalRecipient(address newWithdrawalRecipient) external;

    function pauseDeposits(bool pause) external;

    function pauseFills(bool pause) external;

    function relayRootBundle(bytes32 relayerRefundRoot, bytes32 slowRelayRoot) external;

    function emergencyDeleteRootBundle(uint256 rootBundleId) external;

    // REMOVED FUNCTIONS: These functions have been removed and are now disallowed.
    // See V3SpokePoolInterface for active deposit functions.
    // Function selectors are preserved to prevent accidental reuse in future versions.
    // All calls to these functions will revert.

    /**
     * @dev REMOVED: This function has been removed and is now disallowed.
     * @notice Calling this function will revert. Use deposit() or depositV3() instead.
     * @notice This function shares the same selector as the original "deposit" function that was removed.
     * The collision was intentionally created to allow reusing the "deposit" name for a different function signature.
     */
    function depositDeprecated_5947912356(
        address recipient,
        address originToken,
        uint256 amount,
        uint256 destinationChainId,
        int64 relayerFeePct,
        uint32 quoteTimestamp,
        bytes memory message,
        uint256 maxCount
    ) external payable;

    /**
     * @dev REMOVED: This function has been removed and is now disallowed.
     * @notice Calling this function will revert. Use deposit() or depositV3() instead.
     */
    function depositFor(
        address depositor,
        address recipient,
        address originToken,
        uint256 amount,
        uint256 destinationChainId,
        int64 relayerFeePct,
        uint32 quoteTimestamp,
        bytes memory message,
        uint256 maxCount
    ) external payable;

    function executeRelayerRefundLeaf(
        uint32 rootBundleId,
        SpokePoolInterface.RelayerRefundLeaf memory relayerRefundLeaf,
        bytes32[] memory proof
    ) external payable;

    function chainId() external view returns (uint256);

    error NotEOA();
    error InvalidDepositorSignature();
    error InvalidCrossDomainAdmin();
    error InvalidWithdrawalRecipient();
    error DepositsArePaused();
    error FillsArePaused();
    error ExternalCallExecutionFailed();
    error MessageTooShort();
    error ZeroAddressTarget();
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/token/ERC20/IERC20Upgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// ===== node_modules/@openzeppelin/contracts-v4/token/ERC20/extensions/IERC20Permit.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
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
     *
     * CAUTION: See Security Considerations above.
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


// ===== contracts/interfaces/V5SpokePoolInterface.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { V3SpokePoolInterface } from "./V3SpokePoolInterface.sol";

/**
 * @notice Types and errors for Across V5 SpokePool deposits and fills.
 *
 * A V5 deposit carries only a witness across the bridge: `message = V5_MAGIC_PREFIX || stepId`, where `stepId`
 * is the Merkle root of the Gateway execution allowed to consume it. Everything else the destination must honor
 * is committed in the destination path leaf as `V5FillInput`; the submitter supplies the deposit's `V3RelayData`
 * verbatim just-in-time as `V5FillJit`. The SpokePool validates the committed bounds — and the witness, against
 * the live stepId read from the Gateway — before hashing the supplied relay data, so the relay hash only matches
 * a real deposit when the committed root is the one being executed.
 *
 * V5 deposits are consumable in two modes:
 * - executor mode (`executeAcrossV5`): the SpokePool is the path executor, called directly by the Gateway.
 * - adapter mode (`adapterExecuteAcrossV5`): the SpokePool is an ADAPTER_CALL target inside a command tape,
 *   called by the live step's committed executor.
 *
 * V5 deposits themselves are created outside the SpokePool (e.g. by a V5 planner or adapter on the source
 * chain) as ordinary Across deposits whose message is the stamped witness.
 */
interface V5SpokePoolInterface {
    /// @notice Deposit-committed acceptance bounds for a V5 fill, committed in the path leaf under the
    /// deposit's witness root rather than crossing the bridge.
    struct V5FillInput {
        // Account receiving the fill on this chain.
        bytes32 recipient;
        // Token delivered to the recipient. Must be an ERC20.
        bytes32 outputToken;
        // Floor for the submitter-resolved output amount.
        uint256 minOutputAmount;
        // handleV3AcrossMessage payload delivered to a contract recipient after the transfer. Committed under
        // the witness, giving it V3's trust semantics. Executor mode only — adapter-mode fills have no trailing
        // call, so it must be empty there.
        bytes message;
    }

    /// @notice Submitter-supplied relay data for a V5 fill, plus their repayment preferences.
    struct V5FillJit {
        // The deposit's relay data, passed verbatim. `recipient`, `outputToken` and `message` must match the
        // committed `V5FillInput` / live Gateway stepId, and `outputAmount` must meet the committed floor; the
        // remaining fields are competition parameters and facts the submitter proves by paying for the fill.
        V3SpokePoolInterface.V3RelayData relayData;
        // Chain and address where the filler wants their refund.
        uint256 repaymentChainId;
        bytes32 repaymentAddress;
    }

    /// @notice Thrown when `executeAcrossV5` is called by anyone other than the Gateway.
    error V5NotGateway();
    /// @notice Thrown when `adapterExecuteAcrossV5` is called by anyone other than the live step's committed
    /// executor (also rejects calls while the Gateway is idle or still in its funding loop).
    error V5NotCurrentExecutor();
    /// @notice Thrown when a V5-tagged deposit reaches a non-V5 settlement path (regular fills, updated fills,
    /// slow-fill requests and executions). V5 deposits are consumable only through the witness-checked V5
    /// entrypoints.
    error V5FillOnly();
    /// @notice Thrown when the submitter-supplied relay data contradicts the committed `V5FillInput` or the
    /// live Gateway stepId (recipient, output token, or witness message mismatch).
    error V5CommitmentMismatch();
    /// @notice Thrown when the submitter-resolved output amount is below the committed floor.
    error V5OutputAmountTooLow();
    /// @notice Thrown when native value is sent to a V5 fill. Fills never accept native value; the V5
    /// entrypoints are payable only because the external V5 interfaces require it.
    error V5UnusedMsgValue();
    /// @notice Thrown when an adapter-mode fill commits a callback message (adapter fills have no trailing call;
    /// delivery-then-action belongs in the tape).
    error V5CallbackNotAllowed();
}


// ===== node_modules/@openzeppelin/contracts-upgradeable-v4/token/ERC20/utils/SafeERC20Upgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20PermitUpgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20Upgradeable token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && AddressUpgradeable.isContract(address(token));
    }
}

