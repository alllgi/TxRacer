// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/openzeppelin-solc-0.6/contracts/math/SafeMath.sol

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: lib/openzeppelin-solc-0.6/contracts/utils/Address.sol

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: contracts/external-interfaces/IGsnForwarder.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IGsnForwarder interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGsnForwarder {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }
}

// File: contracts/external-interfaces/IGsnTypes.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;



/// @title IGsnTypes Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGsnTypes {
    struct RelayData {
        uint256 gasPrice;
        uint256 pctRelayFee;
        uint256 baseRelayFee;
        address relayWorker;
        address paymaster;
        address forwarder;
        bytes paymasterData;
        uint256 clientId;
    }

    struct RelayRequest {
        IGsnForwarder.ForwardRequest request;
        RelayData relayData;
    }
}

// File: contracts/external-interfaces/IGsnPaymaster.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;



/// @title IGsnPaymaster interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGsnPaymaster {
    struct GasAndDataLimits {
        uint256 acceptanceBudget;
        uint256 preRelayedCallGasLimit;
        uint256 postRelayedCallGasLimit;
        uint256 calldataSizeLimit;
    }

    function getGasAndDataLimits() external view returns (GasAndDataLimits memory limits);

    function getHubAddr() external view returns (address);

    function getRelayHubDeposit() external view returns (uint256);

    function preRelayedCall(
        IGsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    ) external returns (bytes memory context, bool rejectOnRecipientRevert);

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        IGsnTypes.RelayData calldata relayData
    ) external;

    function trustedForwarder() external view returns (address);

    function versionPaymaster() external view returns (string memory);
}

// File: contracts/external-interfaces/IGsnRelayHub.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;



/// @title IGsnRelayHub Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGsnRelayHub {
    function balanceOf(address target) external view returns (uint256);

    function calculateCharge(uint256 gasUsed, IGsnTypes.RelayData calldata relayData) external view returns (uint256);

    function depositFor(address target) external payable;

    function relayCall(
        uint256 maxAcceptanceBudget,
        IGsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 externalGasLimit
    ) external returns (bool paymasterAccepted, bytes memory returnValue);

    function withdraw(uint256 amount, address payable dest) external;
}

// File: contracts/external-interfaces/IWETH.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IWETH Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// File: contracts/persistent/vault/interfaces/IExternalPositionVault.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IExternalPositionVault interface
/// @author Enzyme Council <security@enzyme.finance>
/// Provides an interface to get the externalPositionLib for a given type from the Vault
interface IExternalPositionVault {
    function getExternalPositionLibForType(uint256) external view returns (address);
}

// File: contracts/persistent/vault/interfaces/IFreelyTransferableSharesVault.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IFreelyTransferableSharesVault Interface
/// @author Enzyme Council <security@enzyme.finance>
/// @notice Provides the interface for determining whether a vault's shares
/// are guaranteed to be freely transferable.
/// @dev DO NOT EDIT CONTRACT
interface IFreelyTransferableSharesVault {
    function sharesAreFreelyTransferable() external view returns (bool sharesAreFreelyTransferable_);
}

// File: contracts/persistent/vault/interfaces/IMigratableVault.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IMigratableVault Interface
/// @author Enzyme Council <security@enzyme.finance>
/// @dev DO NOT EDIT CONTRACT
interface IMigratableVault {
    function canMigrate(address _who) external view returns (bool canMigrate_);

    function init(address _owner, address _accessor, string calldata _fundName) external;

    function setAccessor(address _nextAccessor) external;

    function setVaultLib(address _nextVaultLib) external;
}

// File: contracts/persistent/vault/interfaces/IVaultCore.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IVaultCore interface
/// @author Enzyme Council <security@enzyme.finance>
/// @notice Interface for getters of core vault storage
/// @dev DO NOT EDIT CONTRACT
interface IVaultCore {
    function getAccessor() external view returns (address accessor_);

    function getCreator() external view returns (address creator_);

    function getMigrator() external view returns (address migrator_);

    function getOwner() external view returns (address owner_);
}

// File: contracts/release/core/fund/vault/IVault.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;






/// @title IVault Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IVault is IVaultCore, IMigratableVault, IFreelyTransferableSharesVault, IExternalPositionVault {
    enum VaultAction {
        None,
        // Shares management
        BurnShares,
        MintShares,
        TransferShares,
        // Asset management
        AddTrackedAsset,
        ApproveAssetSpender,
        RemoveTrackedAsset,
        WithdrawAssetTo,
        // External position management
        AddExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition
    }

    function addAssetManagers(address[] calldata _managers) external;

    function addTrackedAsset(address _asset) external;

    function burnShares(address _target, uint256 _amount) external;

    function buyBackProtocolFeeShares(uint256 _sharesAmount, uint256 _mlnValue, uint256 _gav) external;

    function callOnContract(address _contract, bytes calldata _callData) external returns (bytes memory returnData_);

    function canManageAssets(address _who) external view returns (bool canManageAssets_);

    function canRelayCalls(address _who) external view returns (bool canRelayCalls_);

    function claimOwnership() external;

    function getActiveExternalPositions() external view returns (address[] memory activeExternalPositions_);

    function getExternalPositionManager() external view returns (address externalPositionManager_);

    function getFundDeployer() external view returns (address fundDeployer_);

    function getMlnBurner() external view returns (address mlnBurner_);

    function getMlnToken() external view returns (address mlnToken_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getPositionsLimit() external view returns (uint256 positionsLimit_);

    function getProtocolFeeReserve() external view returns (address protocolFeeReserve_);

    function getProtocolFeeTracker() external view returns (address protocolFeeTracker_);

    function getTrackedAssets() external view returns (address[] memory trackedAssets_);

    function isActiveExternalPosition(address _externalPosition)
        external
        view
        returns (bool isActiveExternalPosition_);

    function isAssetManager(address _who) external view returns (bool isAssetManager_);

    function isTrackedAsset(address _asset) external view returns (bool isTrackedAsset_);

    function mintShares(address _target, uint256 _amount) external;

    function payProtocolFee() external;

    function receiveValidatedVaultAction(VaultAction _action, bytes calldata _actionData) external;

    function removeAssetManagers(address[] calldata _managers) external;

    function removeNominatedOwner() external;

    function setAccessorForFundReconfiguration(address _nextAccessor) external;

    function setFreelyTransferableShares() external;

    function setMigrator(address _nextMigrator) external;

    function setName(string calldata _nextName) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSymbol(string calldata _nextSymbol) external;

    function transferShares(address _from, address _to, uint256 _amount) external;

    function withdrawAssetTo(address _asset, address _target, uint256 _amount) external;
}

// File: contracts/release/core/fund/comptroller/IComptroller.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;



/// @title IComptroller Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IComptroller {
    function activate(bool _isMigration) external;

    function buyBackProtocolFeeShares(uint256 _sharesAmount) external;

    function buyShares(uint256 _investmentAmount, uint256 _minSharesQuantity)
        external
        returns (uint256 sharesReceived_);

    function buySharesOnBehalf(address _buyer, uint256 _investmentAmount, uint256 _minSharesQuantity)
        external
        returns (uint256 sharesReceived_);

    function calcGav() external returns (uint256 gav_);

    function calcGrossShareValue() external returns (uint256 grossShareValue_);

    function callOnExtension(address _extension, uint256 _actionId, bytes calldata _callArgs) external;

    function deployGasRelayPaymaster() external;

    function depositToGasRelayPaymaster() external;

    function destructActivated(uint256 _deactivateFeeManagerGasLimit, uint256 _payProtocolFeeGasLimit) external;

    function destructUnactivated() external;

    function doesAutoProtocolFeeSharesBuyback() external view returns (bool doesAutoBuyback_);

    function getDenominationAsset() external view returns (address denominationAsset_);

    function getDispatcher() external view returns (address dispatcher_);

    function getExternalPositionManager() external view returns (address externalPositionManager_);

    function getFeeManager() external view returns (address feeManager_);

    function getFundDeployer() external view returns (address fundDeployer_);

    function getGasRelayPaymaster() external view returns (address gasRelayPaymaster_);

    function getIntegrationManager() external view returns (address integrationManager_);

    function getLastSharesBoughtTimestampForAccount(address _who)
        external
        view
        returns (uint256 lastSharesBoughtTimestamp_);

    function getMlnToken() external view returns (address mlnToken_);

    function getPolicyManager() external view returns (address policyManager_);

    function getProtocolFeeReserve() external view returns (address protocolFeeReserve_);

    function getSharesActionTimelock() external view returns (uint256 sharesActionTimelock_);

    function getValueInterpreter() external view returns (address valueInterpreter_);

    function getVaultProxy() external view returns (address vaultProxy_);

    function getWethToken() external view returns (address wethToken_);

    function init(address _denominationAsset, uint256 _sharesActionTimelock) external;

    function permissionedVaultAction(IVault.VaultAction _action, bytes calldata _actionData) external;

    function preTransferSharesHook(address _sender, address _recipient, uint256 _amount) external;

    function preTransferSharesHookFreelyTransferable(address _sender) external view;

    function redeemSharesForSpecificAssets(
        address _recipient,
        uint256 _sharesQuantity,
        address[] calldata _payoutAssets,
        uint256[] calldata _payoutAssetPercentages
    ) external returns (uint256[] memory payoutAmounts_);

    function redeemSharesInKind(
        address _recipient,
        uint256 _sharesQuantity,
        address[] calldata _additionalAssets,
        address[] calldata _assetsToSkip
    ) external returns (address[] memory payoutAssets_, uint256[] memory payoutAmounts_);

    function setAutoProtocolFeeSharesBuyback(bool _nextAutoProtocolFeeSharesBuyback) external;

    function setGasRelayPaymaster(address _nextGasRelayPaymaster) external;

    function setVaultProxy(address _vaultProxy) external;

    function shutdownGasRelayPaymaster() external;

    function vaultCallOnContract(address _contract, bytes4 _selector, bytes calldata _encodedArgs)
        external
        returns (bytes memory returnData_);
}

// File: contracts/release/core/fund-deployer/IFundDeployer.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title IFundDeployer Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IFundDeployer {
    struct ReconfigurationRequest {
        address nextComptrollerProxy;
        uint256 executableTimestamp;
    }

    function cancelMigration(address _vaultProxy, bool _bypassPrevReleaseFailure) external;

    function cancelReconfiguration(address _vaultProxy) external;

    function createMigrationRequest(
        address _vaultProxy,
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData,
        bool _bypassPrevReleaseFailure
    ) external returns (address comptrollerProxy_);

    function createNewFund(
        address _fundOwner,
        string calldata _fundName,
        string calldata _fundSymbol,
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData
    ) external returns (address comptrollerProxy_, address vaultProxy_);

    function createReconfigurationRequest(
        address _vaultProxy,
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData
    ) external returns (address comptrollerProxy_);

    function deregisterBuySharesOnBehalfCallers(address[] calldata _callers) external;

    function deregisterVaultCalls(
        address[] calldata _contracts,
        bytes4[] calldata _selectors,
        bytes32[] memory _dataHashes
    ) external;

    function executeMigration(address _vaultProxy, bool _bypassPrevReleaseFailure) external;

    function executeReconfiguration(address _vaultProxy) external;

    function getComptrollerLib() external view returns (address comptrollerLib_);

    function getCreator() external view returns (address creator_);

    function getDispatcher() external view returns (address dispatcher_);

    function getGasLimitsForDestructCall()
        external
        view
        returns (uint256 deactivateFeeManagerGasLimit_, uint256 payProtocolFeeGasLimit_);

    function getOwner() external view returns (address owner_);

    function getProtocolFeeTracker() external view returns (address protocolFeeTracker_);

    function getReconfigurationRequestForVaultProxy(address _vaultProxy)
        external
        view
        returns (ReconfigurationRequest memory reconfigurationRequest_);

    function getReconfigurationTimelock() external view returns (uint256 reconfigurationTimelock_);

    function getVaultLib() external view returns (address vaultLib_);

    function hasReconfigurationRequest(address _vaultProxy) external view returns (bool hasReconfigurationRequest_);

    function isAllowedBuySharesOnBehalfCaller(address _who) external view returns (bool isAllowed_);

    function isAllowedVaultCall(address _contract, bytes4 _selector, bytes32 _dataHash)
        external
        view
        returns (bool isAllowed_);

    function isRegisteredVaultCall(address _contract, bytes4 _selector, bytes32 _dataHash)
        external
        view
        returns (bool isRegistered_);

    function registerBuySharesOnBehalfCallers(address[] calldata _callers) external;

    function registerVaultCalls(
        address[] calldata _contracts,
        bytes4[] calldata _selectors,
        bytes32[] memory _dataHashes
    ) external;

    function releaseIsLive() external view returns (bool isLive_);

    function setComptrollerLib(address _comptrollerLib) external;

    function setGasLimitsForDestructCall(uint32 _nextDeactivateFeeManagerGasLimit, uint32 _nextPayProtocolFeeGasLimit)
        external;

    function setProtocolFeeTracker(address _protocolFeeTracker) external;

    function setReconfigurationTimelock(uint256 _nextTimelock) external;

    function setReleaseLive() external;

    function setVaultLib(address _vaultLib) external;
}

// File: contracts/release/extensions/policy-manager/IPolicyManager.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title PolicyManager Interface
/// @author Enzyme Council <security@enzyme.finance>
/// @notice Interface for the PolicyManager
interface IPolicyManager {
    // When updating PolicyHook, also update these functions in PolicyManager:
    // 1. __getAllPolicyHooks()
    // 2. __policyHookRestrictsCurrentInvestorActions()
    enum PolicyHook {
        PostBuyShares,
        PostCallOnIntegration,
        PreTransferShares,
        RedeemSharesForSpecificAssets,
        AddTrackedAssets,
        RemoveTrackedAssets,
        CreateExternalPosition,
        PostCallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function disablePolicyForFund(address _comptrollerProxy, address _policy) external;

    function enablePolicyForFund(address _comptrollerProxy, address _policy, bytes calldata _settingsData) external;

    function getEnabledPoliciesForFund(address _comptrollerProxy)
        external
        view
        returns (address[] memory enabledPolicies_);

    function getEnabledPoliciesOnHookForFund(address _comptrollerProxy, PolicyHook _hook)
        external
        view
        returns (address[] memory enabledPolicies_);

    function policyIsEnabledOnHookForFund(address _comptrollerProxy, PolicyHook _hook, address _policy)
        external
        view
        returns (bool isEnabled_);

    function updatePolicySettingsForFund(address _comptrollerProxy, address _policy, bytes calldata _settingsData)
        external;

    function validatePolicies(address _comptrollerProxy, PolicyHook _hook, bytes calldata _validationData) external;
}

// File: contracts/release/infrastructure/gas-relayer/bases/GasRelayPaymasterLibBase1.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title GasRelayPaymasterLibBase1 Contract
/// @author Enzyme Council <security@enzyme.finance>
/// @notice A persistent contract containing all required storage variables and events
/// for a GasRelayPaymasterLib
/// @dev DO NOT EDIT CONTRACT ONCE DEPLOYED. If new events or storage are necessary,
/// they should be added to a numbered GasRelayPaymasterLibBaseXXX that inherits the previous base.
/// e.g., `GasRelayPaymasterLibBase2 is GasRelayPaymasterLibBase1`
abstract contract GasRelayPaymasterLibBase1 {
    event Deposited(uint256 amount);

    event TransactionRelayed(address indexed authorizer, bytes4 invokedSelector, bool successful);

    event Withdrawn(uint256 amount);

    // Pseudo-constants
    address internal parentVault;
}

// File: contracts/release/infrastructure/gas-relayer/bases/GasRelayPaymasterLibBase2.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



/// @title GasRelayPaymasterLibBase2 Contract
/// @author Enzyme Council <security@enzyme.finance>
/// @notice A persistent contract containing all required storage variables and events
/// for a GasRelayPaymasterLib
/// @dev DO NOT EDIT CONTRACT ONCE DEPLOYED. If new events or storage are necessary,
/// they should be added to a numbered GasRelayPaymasterLibBaseXXX that inherits the previous base.
/// e.g., `GasRelayPaymasterLibBase2 is GasRelayPaymasterLibBase1`
abstract contract GasRelayPaymasterLibBase2 is GasRelayPaymasterLibBase1 {
    uint256 internal lastDepositTimestamp;
}

// File: contracts/release/infrastructure/gas-relayer/IGasRelayPaymaster.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;



/// @title IGasRelayPaymaster Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGasRelayPaymaster is IGsnPaymaster {
    function addAdditionalRelayUsers(address[] calldata _usersToAdd) external;

    function deposit() external;

    function getLastDepositTimestamp() external view returns (uint256 lastDepositTimestamp_);

    function getParentComptroller() external view returns (address parentComptroller_);

    function getParentVault() external view returns (address parentVault_);

    function getWethToken() external view returns (address wethToken_);

    function init(address _vault) external;

    function isAdditionalRelayUser(address _who) external view returns (bool isAdditionalRelayUser_);

    function removeAdditionalRelayUsers(address[] calldata _usersToRemove) external;

    function withdrawBalance() external;
}

// File: contracts/release/infrastructure/gas-relayer/IGasRelayPaymasterDepositor.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IGasRelayPaymasterDepositor Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGasRelayPaymasterDepositor {
    function pullWethForGasRelayer(uint256) external;
}

// File: contracts/release/infrastructure/gas-relayer/GasRelayPaymasterLib.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;















/// @title GasRelayPaymasterLib Contract
/// @author Enzyme Council <security@enzyme.finance>
/// @notice The core logic library for the "paymaster" contract which refunds GSN relayers
/// @dev Allows any permissioned user of the fund to relay any call,
/// without validation of the target of the call itself.
/// Funds with untrusted permissioned users should monitor for abuse (i.e., relaying personal calls).
/// The extent of abuse is throttled by `DEPOSIT_COOLDOWN` and `DEPOSIT_MAX_TOTAL`.
contract GasRelayPaymasterLib is IGasRelayPaymaster, GasRelayPaymasterLibBase2 {
    using SafeMath for uint256;

    event AdditionalRelayUserAdded(address indexed account);

    event AdditionalRelayUserRemoved(address indexed account);

    // Immutable and constants
    // Sane defaults, subject to change after gas profiling
    uint256 private constant CALLDATA_SIZE_LIMIT = 10500;
    // Sane defaults, subject to change after gas profiling
    uint256 private constant PRE_RELAYED_CALL_GAS_LIMIT = 100000;
    uint256 private constant POST_RELAYED_CALL_GAS_LIMIT = 110000;
    // FORWARDER_HUB_OVERHEAD = 50000;
    // PAYMASTER_ACCEPTANCE_BUDGET = FORWARDER_HUB_OVERHEAD + PRE_RELAYED_CALL_GAS_LIMIT
    uint256 private constant PAYMASTER_ACCEPTANCE_BUDGET = 150000;

    uint256 private immutable DEPOSIT_COOLDOWN; // in seconds
    uint256 private immutable DEPOSIT_MAX_TOTAL; // in wei
    uint256 private immutable RELAY_FEE_MAX_BASE;
    uint256 private immutable RELAY_FEE_MAX_PERCENT; // e.g., `10` is 10%
    address private immutable RELAY_HUB;
    address private immutable TRUSTED_FORWARDER;
    address private immutable WETH_TOKEN;

    mapping(address => bool) private accountToIsAdditionalRelayUser;

    modifier onlyComptroller() {
        require(msg.sender == getParentComptroller(), "Can only be called by the parent comptroller");
        _;
    }

    modifier onlyFundOwner() {
        require(__msgSender() == IVault(getParentVault()).getOwner(), "Only the fund owner can call this function");
        _;
    }

    modifier relayHubOnly() {
        require(msg.sender == getHubAddr(), "Can only be called by RelayHub");
        _;
    }

    constructor(
        address _wethToken,
        address _relayHub,
        address _trustedForwarder,
        uint256 _depositCooldown,
        uint256 _depositMaxTotal,
        uint256 _relayFeeMaxBase,
        uint256 _relayFeeMaxPercent
    ) public {
        DEPOSIT_COOLDOWN = _depositCooldown;
        DEPOSIT_MAX_TOTAL = _depositMaxTotal;
        RELAY_FEE_MAX_BASE = _relayFeeMaxBase;
        RELAY_FEE_MAX_PERCENT = _relayFeeMaxPercent;
        RELAY_HUB = _relayHub;
        TRUSTED_FORWARDER = _trustedForwarder;
        WETH_TOKEN = _wethToken;
    }

    // INIT

    /// @notice Initializes a paymaster proxy
    /// @param _vault The VaultProxy associated with the paymaster proxy
    /// @dev Used to set the owning vault
    function init(address _vault) external override {
        require(getParentVault() == address(0), "init: Paymaster already initialized");

        parentVault = _vault;
    }

    // EXTERNAL FUNCTIONS

    /// @notice Pull deposit from the vault and reactivate relaying
    function deposit() external override onlyComptroller {
        __depositMax();
    }

    /// @notice Checks whether the paymaster will pay for a given relayed tx
    /// @param _relayRequest The full relay request structure
    /// @return context_ The tx signer and the fn sig, encoded so that it can be passed to `postRelayCall`
    /// @return rejectOnRecipientRevert_ Always false
    function preRelayedCall(IGsnTypes.RelayRequest calldata _relayRequest, bytes calldata, bytes calldata, uint256)
        external
        override
        relayHubOnly
        returns (bytes memory context_, bool rejectOnRecipientRevert_)
    {
        require(_relayRequest.relayData.forwarder == TRUSTED_FORWARDER, "preRelayedCall: Unauthorized forwarder");
        require(_relayRequest.relayData.baseRelayFee <= RELAY_FEE_MAX_BASE, "preRelayedCall: High baseRelayFee");
        require(_relayRequest.relayData.pctRelayFee <= RELAY_FEE_MAX_PERCENT, "preRelayedCall: High pctRelayFee");

        // No Enzyme txs require msg.value
        require(_relayRequest.request.value == 0, "preRelayedCall: Non-zero value");

        // Allow any transaction, as long as it's from a permissioned account for the fund
        address vaultProxy = getParentVault();
        require(
            IVault(vaultProxy).canRelayCalls(_relayRequest.request.from)
                || isAdditionalRelayUser(_relayRequest.request.from),
            "preRelayedCall: Unauthorized caller"
        );

        bytes4 selector = __parseTxDataFunctionSelector(_relayRequest.request.data);

        return (abi.encode(_relayRequest.request.from, selector), false);
    }

    /// @notice Called by the relay hub after the relayed tx is executed, tops up deposit if flag passed through paymasterdata is true
    /// @param _context The context constructed by preRelayedCall (used to pass data from pre to post relayed call)
    /// @param _success Whether or not the relayed tx succeed
    /// @param _relayData The relay params of the request. can be used by relayHub.calculateCharge()
    function postRelayedCall(bytes calldata _context, bool _success, uint256, IGsnTypes.RelayData calldata _relayData)
        external
        override
        relayHubOnly
    {
        bool shouldTopUpDeposit = abi.decode(_relayData.paymasterData, (bool));
        if (shouldTopUpDeposit) {
            __depositMax();
        }

        (address spender, bytes4 selector) = abi.decode(_context, (address, bytes4));
        emit TransactionRelayed(spender, selector, _success);
    }

    /// @notice Send any deposited ETH back to the vault
    function withdrawBalance() external override {
        address vaultProxy = getParentVault();
        address canonicalSender = __msgSender();
        require(
            canonicalSender == IVault(vaultProxy).getOwner() || canonicalSender == __getComptrollerForVault(vaultProxy),
            "withdrawBalance: Only owner or comptroller is authorized"
        );

        IGsnRelayHub(getHubAddr()).withdraw(getRelayHubDeposit(), payable(address(this)));

        uint256 amount = address(this).balance;

        Address.sendValue(payable(vaultProxy), amount);

        emit Withdrawn(amount);
    }

    // PUBLIC FUNCTIONS

    /// @notice Gets the current ComptrollerProxy of the VaultProxy associated with this contract
    /// @return parentComptroller_ The ComptrollerProxy
    function getParentComptroller() public view override returns (address parentComptroller_) {
        return __getComptrollerForVault(parentVault);
    }

    // PRIVATE FUNCTIONS

    /// @dev Helper to pull WETH from the associated vault to top up to the max ETH deposit in the relay hub
    function __depositMax() private {
        // Only allow one deposit every DEPOSIT_COOLDOWN seconds
        if (block.timestamp - getLastDepositTimestamp() < DEPOSIT_COOLDOWN) {
            return;
        }

        // Cap the total deposit to DEPOSIT_MAX_TOTAL wei
        uint256 prevDeposit = getRelayHubDeposit();
        if (prevDeposit >= DEPOSIT_MAX_TOTAL) {
            return;
        }
        uint256 amount = DEPOSIT_MAX_TOTAL.sub(prevDeposit);

        IGasRelayPaymasterDepositor(getParentComptroller()).pullWethForGasRelayer(amount);

        IWETH(getWethToken()).withdraw(amount);

        IGsnRelayHub(getHubAddr()).depositFor{value: amount}(address(this));

        lastDepositTimestamp = block.timestamp;

        emit Deposited(amount);
    }

    /// @dev Helper to get the ComptrollerProxy for a given VaultProxy
    function __getComptrollerForVault(address _vaultProxy) private view returns (address comptrollerProxy_) {
        return IVault(_vaultProxy).getAccessor();
    }

    /// @dev Helper to parse the canonical msg sender from trusted forwarder relayed calls
    /// See https://github.com/opengsn/gsn/blob/da4222b76e3ae1968608dc5c5d80074dcac7c4be/packages/contracts/src/ERC2771Recipient.sol#L41-L53
    function __msgSender() internal view returns (address canonicalSender_) {
        if (msg.data.length >= 20 && msg.sender == TRUSTED_FORWARDER) {
            assembly {
                canonicalSender_ := shr(96, calldataload(sub(calldatasize(), 20)))
            }

            return canonicalSender_;
        }

        return msg.sender;
    }

    /// @notice Parses the function selector from tx data
    /// @param _txData The tx data
    /// @return functionSelector_ The extracted function selector
    function __parseTxDataFunctionSelector(bytes calldata _txData) private pure returns (bytes4 functionSelector_) {
        /// convert bytes[:4] to bytes4
        require(_txData.length >= 4, "__parseTxDataFunctionSelector: _txData is not a valid length");

        functionSelector_ =
            _txData[0] | (bytes4(_txData[1]) >> 8) | (bytes4(_txData[2]) >> 16) | (bytes4(_txData[3]) >> 24);

        return functionSelector_;
    }

    //////////////////////////////////////
    // REGISTRY: ADDITIONAL RELAY USERS //
    //////////////////////////////////////

    /// @notice Adds additional relay users
    /// @param _usersToAdd The users to add
    function addAdditionalRelayUsers(address[] calldata _usersToAdd) external override onlyFundOwner {
        for (uint256 i; i < _usersToAdd.length; i++) {
            address user = _usersToAdd[i];
            require(!isAdditionalRelayUser(user), "addAdditionalRelayUsers: User registered");

            accountToIsAdditionalRelayUser[user] = true;

            emit AdditionalRelayUserAdded(user);
        }
    }

    /// @notice Removes additional relay users
    /// @param _usersToRemove The users to remove
    function removeAdditionalRelayUsers(address[] calldata _usersToRemove) external override onlyFundOwner {
        for (uint256 i; i < _usersToRemove.length; i++) {
            address user = _usersToRemove[i];
            require(isAdditionalRelayUser(user), "removeAdditionalRelayUsers: User not registered");

            accountToIsAdditionalRelayUser[user] = false;

            emit AdditionalRelayUserRemoved(user);
        }
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    /// @notice Gets gas limits used by the relay hub for the pre and post relay calls
    /// @return limits_ `GasAndDataLimits(PAYMASTER_ACCEPTANCE_BUDGET, PRE_RELAYED_CALL_GAS_LIMIT, POST_RELAYED_CALL_GAS_LIMIT, CALLDATA_SIZE_LIMIT)`
    function getGasAndDataLimits() external view override returns (IGsnPaymaster.GasAndDataLimits memory limits_) {
        return IGsnPaymaster.GasAndDataLimits(
            PAYMASTER_ACCEPTANCE_BUDGET, PRE_RELAYED_CALL_GAS_LIMIT, POST_RELAYED_CALL_GAS_LIMIT, CALLDATA_SIZE_LIMIT
        );
    }

    /// @notice Gets the `RELAY_HUB` variable value
    /// @return relayHub_ The `RELAY_HUB` value
    function getHubAddr() public view override returns (address relayHub_) {
        return RELAY_HUB;
    }

    /// @notice Gets the timestamp at last deposit into the relayer
    /// @return lastDepositTimestamp_ The timestamp
    function getLastDepositTimestamp() public view override returns (uint256 lastDepositTimestamp_) {
        return lastDepositTimestamp;
    }

    /// @notice Gets the `parentVault` variable value
    /// @return parentVault_ The `parentVault` value
    function getParentVault() public view override returns (address parentVault_) {
        return parentVault;
    }

    /// @notice Look up amount of ETH deposited on the relay hub
    /// @return depositBalance_ amount of ETH deposited on the relay hub
    function getRelayHubDeposit() public view override returns (uint256 depositBalance_) {
        return IGsnRelayHub(getHubAddr()).balanceOf(address(this));
    }

    /// @notice Gets the `WETH_TOKEN` variable value
    /// @return wethToken_ The `WETH_TOKEN` value
    function getWethToken() public view override returns (address wethToken_) {
        return WETH_TOKEN;
    }

    /// @notice Checks whether an account is an approved additional relayer user
    /// @return isAdditionalRelayUser_ True if the account is an additional relayer user
    function isAdditionalRelayUser(address _who) public view override returns (bool isAdditionalRelayUser_) {
        return accountToIsAdditionalRelayUser[_who];
    }

    /// @notice Gets the `TRUSTED_FORWARDER` variable value
    /// @return trustedForwarder_ The forwarder contract which is trusted to validated the relayed tx signature
    function trustedForwarder() external view override returns (address trustedForwarder_) {
        return TRUSTED_FORWARDER;
    }

    /// @notice Gets the string representation of the contract version (fulfills interface)
    /// @return versionString_ The version string
    function versionPaymaster() external view override returns (string memory versionString_) {
        return "2.2.3+opengsn.enzymefund.ipaymaster";
    }
}

// File: AssetManager/contracts/external-interfaces/IGsnForwarder.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IGsnForwarder interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGsnForwarder {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }
}

// File: AssetManager/contracts/external-interfaces/IGsnTypes.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;



/// @title IGsnTypes Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGsnTypes {
    struct RelayData {
        uint256 gasPrice;
        uint256 pctRelayFee;
        uint256 baseRelayFee;
        address relayWorker;
        address paymaster;
        address forwarder;
        bytes paymasterData;
        uint256 clientId;
    }

    struct RelayRequest {
        IGsnForwarder.ForwardRequest request;
        RelayData relayData;
    }
}

// File: AssetManager/contracts/external-interfaces/IGsnPaymaster.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;



/// @title IGsnPaymaster interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGsnPaymaster {
    struct GasAndDataLimits {
        uint256 acceptanceBudget;
        uint256 preRelayedCallGasLimit;
        uint256 postRelayedCallGasLimit;
        uint256 calldataSizeLimit;
    }

    function getGasAndDataLimits() external view returns (GasAndDataLimits memory limits);

    function getHubAddr() external view returns (address);

    function getRelayHubDeposit() external view returns (uint256);

    function preRelayedCall(
        IGsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    ) external returns (bytes memory context, bool rejectOnRecipientRevert);

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        IGsnTypes.RelayData calldata relayData
    ) external;

    function trustedForwarder() external view returns (address);

    function versionPaymaster() external view returns (string memory);
}

// File: AssetManager/contracts/external-interfaces/IGsnRelayHub.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;



/// @title IGsnRelayHub Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGsnRelayHub {
    function balanceOf(address target) external view returns (uint256);

    function calculateCharge(uint256 gasUsed, IGsnTypes.RelayData calldata relayData) external view returns (uint256);

    function depositFor(address target) external payable;

    function relayCall(
        uint256 maxAcceptanceBudget,
        IGsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 externalGasLimit
    ) external returns (bool paymasterAccepted, bytes memory returnValue);

    function withdraw(uint256 amount, address payable dest) external;
}

// File: AssetManager/contracts/external-interfaces/IWETH.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IWETH Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// File: AssetManager/contracts/persistent/vault/interfaces/IExternalPositionVault.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IExternalPositionVault interface
/// @author Enzyme Council <security@enzyme.finance>
/// Provides an interface to get the externalPositionLib for a given type from the Vault
interface IExternalPositionVault {
    function getExternalPositionLibForType(uint256) external view returns (address);
}

// File: AssetManager/contracts/persistent/vault/interfaces/IFreelyTransferableSharesVault.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IFreelyTransferableSharesVault Interface
/// @author Enzyme Council <security@enzyme.finance>
/// @notice Provides the interface for determining whether a vault's shares
/// are guaranteed to be freely transferable.
/// @dev DO NOT EDIT CONTRACT
interface IFreelyTransferableSharesVault {
    function sharesAreFreelyTransferable() external view returns (bool sharesAreFreelyTransferable_);
}

// File: AssetManager/contracts/persistent/vault/interfaces/IMigratableVault.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IMigratableVault Interface
/// @author Enzyme Council <security@enzyme.finance>
/// @dev DO NOT EDIT CONTRACT
interface IMigratableVault {
    function canMigrate(address _who) external view returns (bool canMigrate_);

    function init(address _owner, address _accessor, string calldata _fundName) external;

    function setAccessor(address _nextAccessor) external;

    function setVaultLib(address _nextVaultLib) external;
}

// File: AssetManager/contracts/persistent/vault/interfaces/IVaultCore.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IVaultCore interface
/// @author Enzyme Council <security@enzyme.finance>
/// @notice Interface for getters of core vault storage
/// @dev DO NOT EDIT CONTRACT
interface IVaultCore {
    function getAccessor() external view returns (address accessor_);

    function getCreator() external view returns (address creator_);

    function getMigrator() external view returns (address migrator_);

    function getOwner() external view returns (address owner_);
}

// File: AssetManager/contracts/release/core/fund-deployer/IFundDeployer.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title IFundDeployer Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IFundDeployer {
    struct ReconfigurationRequest {
        address nextComptrollerProxy;
        uint256 executableTimestamp;
    }

    function cancelMigration(address _vaultProxy, bool _bypassPrevReleaseFailure) external;

    function cancelReconfiguration(address _vaultProxy) external;

    function createMigrationRequest(
        address _vaultProxy,
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData,
        bool _bypassPrevReleaseFailure
    ) external returns (address comptrollerProxy_);

    function createNewFund(
        address _fundOwner,
        string calldata _fundName,
        string calldata _fundSymbol,
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData
    ) external returns (address comptrollerProxy_, address vaultProxy_);

    function createReconfigurationRequest(
        address _vaultProxy,
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData
    ) external returns (address comptrollerProxy_);

    function deregisterBuySharesOnBehalfCallers(address[] calldata _callers) external;

    function deregisterVaultCalls(
        address[] calldata _contracts,
        bytes4[] calldata _selectors,
        bytes32[] memory _dataHashes
    ) external;

    function executeMigration(address _vaultProxy, bool _bypassPrevReleaseFailure) external;

    function executeReconfiguration(address _vaultProxy) external;

    function getComptrollerLib() external view returns (address comptrollerLib_);

    function getCreator() external view returns (address creator_);

    function getDispatcher() external view returns (address dispatcher_);

    function getGasLimitsForDestructCall()
        external
        view
        returns (uint256 deactivateFeeManagerGasLimit_, uint256 payProtocolFeeGasLimit_);

    function getOwner() external view returns (address owner_);

    function getProtocolFeeTracker() external view returns (address protocolFeeTracker_);

    function getReconfigurationRequestForVaultProxy(address _vaultProxy)
        external
        view
        returns (ReconfigurationRequest memory reconfigurationRequest_);

    function getReconfigurationTimelock() external view returns (uint256 reconfigurationTimelock_);

    function getVaultLib() external view returns (address vaultLib_);

    function getBridgeManager() external view returns (address bridgeManager_);

    function hasReconfigurationRequest(address _vaultProxy) external view returns (bool hasReconfigurationRequest_);

    function isAllowedBuySharesOnBehalfCaller(address _who) external view returns (bool isAllowed_);

    function isAllowedVaultCall(address _contract, bytes4 _selector, bytes32 _dataHash)
        external
        view
        returns (bool isAllowed_);

    function isRegisteredVaultCall(address _contract, bytes4 _selector, bytes32 _dataHash)
        external
        view
        returns (bool isRegistered_);

    function registerBuySharesOnBehalfCallers(address[] calldata _callers) external;

    function registerVaultCalls(
        address[] calldata _contracts,
        bytes4[] calldata _selectors,
        bytes32[] memory _dataHashes
    ) external;

    function releaseIsLive() external view returns (bool isLive_);

    function setComptrollerLib(address _comptrollerLib) external;

    function setGasLimitsForDestructCall(uint32 _nextDeactivateFeeManagerGasLimit, uint32 _nextPayProtocolFeeGasLimit)
        external;

    function setProtocolFeeTracker(address _protocolFeeTracker) external;

    function setReconfigurationTimelock(uint256 _nextTimelock) external;

    function setReleaseLive() external;

    function setVaultLib(address _vaultLib) external;

    function setBridgeManager(address _bridgeManager) external;
}

// File: AssetManager/contracts/release/core/fund/vault/IVault.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;






/// @title IVault Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IVault is IVaultCore, IMigratableVault, IFreelyTransferableSharesVault, IExternalPositionVault {
    enum VaultAction {
        None,
        // Shares management
        BurnShares,
        MintShares,
        TransferShares,
        // Asset management
        AddTrackedAsset,
        ApproveAssetSpender,
        RemoveTrackedAsset,
        WithdrawAssetTo,
        // External position management
        AddExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition
    }

    function addAssetManagers(address[] calldata _managers) external;

    function addTrackedAsset(address _asset) external;

    function burnShares(address _target, uint256 _amount) external;

    function buyBackProtocolFeeShares(uint256 _sharesAmount, uint256 _mlnValue, uint256 _gav) external;

    function callOnContract(address _contract, bytes calldata _callData) external returns (bytes memory returnData_);

    function canManageAssets(address _who) external view returns (bool canManageAssets_);

    function canRelayCalls(address _who) external view returns (bool canRelayCalls_);

    function claimOwnership() external;

    function getActiveExternalPositions() external view returns (address[] memory activeExternalPositions_);

    function getExternalPositionManager() external view returns (address externalPositionManager_);

    function getFundDeployer() external view returns (address fundDeployer_);

    function getMlnBurner() external view returns (address mlnBurner_);

    function getMlnToken() external view returns (address mlnToken_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getPositionsLimit() external view returns (uint256 positionsLimit_);

    function getProtocolFeeReserve() external view returns (address protocolFeeReserve_);

    function getProtocolFeeTracker() external view returns (address protocolFeeTracker_);

    function getTrackedAssets() external view returns (address[] memory trackedAssets_);

    function isActiveExternalPosition(address _externalPosition) external view returns (bool isActiveExternalPosition_);

    function isAssetManager(address _who) external view returns (bool isAssetManager_);

    function isTrackedAsset(address _asset) external view returns (bool isTrackedAsset_);

    function mintShares(address _target, uint256 _amount) external;

    function payProtocolFee() external;

    function receiveValidatedVaultAction(VaultAction _action, bytes calldata _actionData) external;

    function removeAssetManagers(address[] calldata _managers) external;

    function removeNominatedOwner() external;

    function setAccessorForFundReconfiguration(address _nextAccessor) external;

    function setFreelyTransferableShares() external;

    function setMigrator(address _nextMigrator) external;

    function setName(string calldata _nextName) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSymbol(string calldata _nextSymbol) external;

    function transferShares(address _from, address _to, uint256 _amount) external;

    function withdrawAssetTo(address _asset, address _target, uint256 _amount) external;
}

// File: AssetManager/contracts/release/core/fund/comptroller/IComptroller.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;



/// @title IComptroller Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IComptroller {
    function activate(bool _isMigration) external;

    function buyBackProtocolFeeShares(uint256 _sharesAmount) external;

    function buyShares(uint256 _investmentAmount, uint256 _minSharesQuantity) external returns (uint256 sharesReceived_);

    function buySharesOnBehalf(address _buyer, uint256 _investmentAmount, uint256 _minSharesQuantity)
        external
        returns (uint256 sharesReceived_);

    function calcGav() external returns (uint256 gav_);

    function calcGrossShareValue() external returns (uint256 grossShareValue_);

    function callOnExtension(address _extension, uint256 _actionId, bytes calldata _callArgs) external;

    function deployGasRelayPaymaster() external;

    function depositToGasRelayPaymaster() external;

    function destructActivated(uint256 _deactivateFeeManagerGasLimit, uint256 _payProtocolFeeGasLimit) external;

    function destructUnactivated() external;

    function doesAutoProtocolFeeSharesBuyback() external view returns (bool doesAutoBuyback_);

    function getDenominationAsset() external view returns (address denominationAsset_);

    function getDispatcher() external view returns (address dispatcher_);

    function getExternalPositionManager() external view returns (address externalPositionManager_);

    function getFeeManager() external view returns (address feeManager_);

    function getFundDeployer() external view returns (address fundDeployer_);

    function getGasRelayPaymaster() external view returns (address gasRelayPaymaster_);

    function getIntegrationManager() external view returns (address integrationManager_);

    function getLastSharesBoughtTimestampForAccount(address _who)
        external
        view
        returns (uint256 lastSharesBoughtTimestamp_);

    function getMlnToken() external view returns (address mlnToken_);

    function getPolicyManager() external view returns (address policyManager_);

    function getProtocolFeeReserve() external view returns (address protocolFeeReserve_);

    function getSharesActionTimelock() external view returns (uint256 sharesActionTimelock_);

    function getValueInterpreter() external view returns (address valueInterpreter_);

    function getVaultProxy() external view returns (address vaultProxy_);

    function getWethToken() external view returns (address wethToken_);

    function init(address _denominationAsset, uint256 _sharesActionTimelock) external;

    function permissionedVaultAction(IVault.VaultAction _action, bytes calldata _actionData) external;

    function preTransferSharesHook(address _sender, address _recipient, uint256 _amount) external;

    function preTransferSharesHookFreelyTransferable(address _sender) external view;

    function redeemSharesForSpecificAssets(
        address _recipient,
        uint256 _sharesQuantity,
        address[] calldata _payoutAssets,
        uint256[] calldata _payoutAssetPercentages
    ) external returns (uint256[] memory payoutAmounts_);

    function redeemSharesInKind(
        address _recipient,
        uint256 _sharesQuantity,
        address[] calldata _additionalAssets,
        address[] calldata _assetsToSkip
    ) external returns (address[] memory payoutAssets_, uint256[] memory payoutAmounts_);

    function setAutoProtocolFeeSharesBuyback(bool _nextAutoProtocolFeeSharesBuyback) external;

    function setGasRelayPaymaster(address _nextGasRelayPaymaster) external;

    function setVaultProxy(address _vaultProxy) external;

    function shutdownGasRelayPaymaster() external;

    function vaultCallOnContract(address _contract, bytes4 _selector, bytes calldata _encodedArgs)
        external
        returns (bytes memory returnData_);
}

// File: AssetManager/contracts/release/extensions/policy-manager/IPolicyManager.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title PolicyManager Interface
/// @author Enzyme Council <security@enzyme.finance>
/// @notice Interface for the PolicyManager
interface IPolicyManager {
    // When updating PolicyHook, also update these functions in PolicyManager:
    // 1. __getAllPolicyHooks()
    // 2. __policyHookRestrictsCurrentInvestorActions()
    enum PolicyHook {
        PostBuyShares,
        PostCallOnIntegration,
        PreTransferShares,
        RedeemSharesForSpecificAssets,
        AddTrackedAssets,
        RemoveTrackedAssets,
        CreateExternalPosition,
        PostCallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function disablePolicyForFund(address _comptrollerProxy, address _policy) external;

    function enablePolicyForFund(address _comptrollerProxy, address _policy, bytes calldata _settingsData) external;

    function getEnabledPoliciesForFund(address _comptrollerProxy)
        external
        view
        returns (address[] memory enabledPolicies_);

    function getEnabledPoliciesOnHookForFund(address _comptrollerProxy, PolicyHook _hook)
        external
        view
        returns (address[] memory enabledPolicies_);

    function policyIsEnabledOnHookForFund(address _comptrollerProxy, PolicyHook _hook, address _policy)
        external
        view
        returns (bool isEnabled_);

    function updatePolicySettingsForFund(address _comptrollerProxy, address _policy, bytes calldata _settingsData)
        external;

    function validatePolicies(address _comptrollerProxy, PolicyHook _hook, bytes calldata _validationData) external;
}

// File: AssetManager/contracts/release/infrastructure/gas-relayer/bases/GasRelayPaymasterLibBase1.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title GasRelayPaymasterLibBase1 Contract
/// @author Enzyme Council <security@enzyme.finance>
/// @notice A persistent contract containing all required storage variables and events
/// for a GasRelayPaymasterLib
/// @dev DO NOT EDIT CONTRACT ONCE DEPLOYED. If new events or storage are necessary,
/// they should be added to a numbered GasRelayPaymasterLibBaseXXX that inherits the previous base.
/// e.g., `GasRelayPaymasterLibBase2 is GasRelayPaymasterLibBase1`
abstract contract GasRelayPaymasterLibBase1 {
    event Deposited(uint256 amount);

    event TransactionRelayed(address indexed authorizer, bytes4 invokedSelector, bool successful);

    event Withdrawn(uint256 amount);

    // Pseudo-constants
    address internal parentVault;
}

// File: AssetManager/contracts/release/infrastructure/gas-relayer/bases/GasRelayPaymasterLibBase2.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



/// @title GasRelayPaymasterLibBase2 Contract
/// @author Enzyme Council <security@enzyme.finance>
/// @notice A persistent contract containing all required storage variables and events
/// for a GasRelayPaymasterLib
/// @dev DO NOT EDIT CONTRACT ONCE DEPLOYED. If new events or storage are necessary,
/// they should be added to a numbered GasRelayPaymasterLibBaseXXX that inherits the previous base.
/// e.g., `GasRelayPaymasterLibBase2 is GasRelayPaymasterLibBase1`
abstract contract GasRelayPaymasterLibBase2 is GasRelayPaymasterLibBase1 {
    uint256 internal lastDepositTimestamp;
}

// File: AssetManager/contracts/release/infrastructure/gas-relayer/IGasRelayPaymaster.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;



/// @title IGasRelayPaymaster Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGasRelayPaymaster is IGsnPaymaster {
    function addAdditionalRelayUsers(address[] calldata _usersToAdd) external;

    function deposit() external;

    function getLastDepositTimestamp() external view returns (uint256 lastDepositTimestamp_);

    function getParentComptroller() external view returns (address parentComptroller_);

    function getParentVault() external view returns (address parentVault_);

    function getWethToken() external view returns (address wethToken_);

    function init(address _vault) external;

    function isAdditionalRelayUser(address _who) external view returns (bool isAdditionalRelayUser_);

    function removeAdditionalRelayUsers(address[] calldata _usersToRemove) external;

    function withdrawBalance() external;
}

// File: AssetManager/contracts/release/infrastructure/gas-relayer/IGasRelayPaymasterDepositor.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IGasRelayPaymasterDepositor Interface
/// @author Enzyme Council <security@enzyme.finance>
interface IGasRelayPaymasterDepositor {
    function pullWethForGasRelayer(uint256) external;
}

// File: AssetManager/contracts/release/infrastructure/gas-relayer/GasRelayPaymasterLib.sol

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;















/// @title GasRelayPaymasterLib Contract
/// @author Enzyme Council <security@enzyme.finance>
/// @notice The core logic library for the "paymaster" contract which refunds GSN relayers
/// @dev Allows any permissioned user of the fund to relay any call,
/// without validation of the target of the call itself.
/// Funds with untrusted permissioned users should monitor for abuse (i.e., relaying personal calls).
/// The extent of abuse is throttled by `DEPOSIT_COOLDOWN` and `DEPOSIT_MAX_TOTAL`.
contract GasRelayPaymasterLib is IGasRelayPaymaster, GasRelayPaymasterLibBase2 {
    using SafeMath for uint256;

    event AdditionalRelayUserAdded(address indexed account);

    event AdditionalRelayUserRemoved(address indexed account);

    // Immutable and constants
    // Sane defaults, subject to change after gas profiling
    uint256 private constant CALLDATA_SIZE_LIMIT = 10500;
    // Sane defaults, subject to change after gas profiling
    uint256 private constant PRE_RELAYED_CALL_GAS_LIMIT = 100000;
    uint256 private constant POST_RELAYED_CALL_GAS_LIMIT = 110000;
    // FORWARDER_HUB_OVERHEAD = 50000;
    // PAYMASTER_ACCEPTANCE_BUDGET = FORWARDER_HUB_OVERHEAD + PRE_RELAYED_CALL_GAS_LIMIT
    uint256 private constant PAYMASTER_ACCEPTANCE_BUDGET = 150000;

    uint256 private immutable DEPOSIT_COOLDOWN; // in seconds
    uint256 private immutable DEPOSIT_MAX_TOTAL; // in wei
    uint256 private immutable RELAY_FEE_MAX_BASE;
    uint256 private immutable RELAY_FEE_MAX_PERCENT; // e.g., `10` is 10%
    address private immutable RELAY_HUB;
    address private immutable TRUSTED_FORWARDER;
    address private immutable WETH_TOKEN;

    mapping(address => bool) private accountToIsAdditionalRelayUser;

    modifier onlyComptroller() {
        require(msg.sender == getParentComptroller(), "Can only be called by the parent comptroller");
        _;
    }

    modifier onlyFundOwner() {
        require(__msgSender() == IVault(getParentVault()).getOwner(), "Only the fund owner can call this function");
        _;
    }

    modifier relayHubOnly() {
        require(msg.sender == getHubAddr(), "Can only be called by RelayHub");
        _;
    }

    constructor(
        address _wethToken,
        address _relayHub,
        address _trustedForwarder,
        uint256 _depositCooldown,
        uint256 _depositMaxTotal,
        uint256 _relayFeeMaxBase,
        uint256 _relayFeeMaxPercent
    ) public {
        DEPOSIT_COOLDOWN = _depositCooldown;
        DEPOSIT_MAX_TOTAL = _depositMaxTotal;
        RELAY_FEE_MAX_BASE = _relayFeeMaxBase;
        RELAY_FEE_MAX_PERCENT = _relayFeeMaxPercent;
        RELAY_HUB = _relayHub;
        TRUSTED_FORWARDER = _trustedForwarder;
        WETH_TOKEN = _wethToken;
    }

    // INIT

    /// @notice Initializes a paymaster proxy
    /// @param _vault The VaultProxy associated with the paymaster proxy
    /// @dev Used to set the owning vault
    function init(address _vault) external override {
        require(getParentVault() == address(0), "init: Paymaster already initialized");

        parentVault = _vault;
    }

    // EXTERNAL FUNCTIONS

    /// @notice Pull deposit from the vault and reactivate relaying
    function deposit() external override onlyComptroller {
        __depositMax();
    }

    /// @notice Checks whether the paymaster will pay for a given relayed tx
    /// @param _relayRequest The full relay request structure
    /// @return context_ The tx signer and the fn sig, encoded so that it can be passed to `postRelayCall`
    /// @return rejectOnRecipientRevert_ Always false
    function preRelayedCall(IGsnTypes.RelayRequest calldata _relayRequest, bytes calldata, bytes calldata, uint256)
        external
        override
        relayHubOnly
        returns (bytes memory context_, bool rejectOnRecipientRevert_)
    {
        require(_relayRequest.relayData.forwarder == TRUSTED_FORWARDER, "preRelayedCall: Unauthorized forwarder");
        require(_relayRequest.relayData.baseRelayFee <= RELAY_FEE_MAX_BASE, "preRelayedCall: High baseRelayFee");
        require(_relayRequest.relayData.pctRelayFee <= RELAY_FEE_MAX_PERCENT, "preRelayedCall: High pctRelayFee");

        // No Enzyme txs require msg.value
        require(_relayRequest.request.value == 0, "preRelayedCall: Non-zero value");

        // Allow any transaction, as long as it's from a permissioned account for the fund
        address vaultProxy = getParentVault();
        require(
            IVault(vaultProxy).canRelayCalls(_relayRequest.request.from)
                || isAdditionalRelayUser(_relayRequest.request.from),
            "preRelayedCall: Unauthorized caller"
        );

        bytes4 selector = __parseTxDataFunctionSelector(_relayRequest.request.data);

        return (abi.encode(_relayRequest.request.from, selector), false);
    }

    /// @notice Called by the relay hub after the relayed tx is executed, tops up deposit if flag passed through paymasterdata is true
    /// @param _context The context constructed by preRelayedCall (used to pass data from pre to post relayed call)
    /// @param _success Whether or not the relayed tx succeed
    /// @param _relayData The relay params of the request. can be used by relayHub.calculateCharge()
    function postRelayedCall(bytes calldata _context, bool _success, uint256, IGsnTypes.RelayData calldata _relayData)
        external
        override
        relayHubOnly
    {
        bool shouldTopUpDeposit = abi.decode(_relayData.paymasterData, (bool));
        if (shouldTopUpDeposit) {
            __depositMax();
        }

        (address spender, bytes4 selector) = abi.decode(_context, (address, bytes4));
        emit TransactionRelayed(spender, selector, _success);
    }

    /// @notice Send any deposited ETH back to the vault
    function withdrawBalance() external override {
        address vaultProxy = getParentVault();
        address canonicalSender = __msgSender();
        require(
            canonicalSender == IVault(vaultProxy).getOwner() || canonicalSender == __getComptrollerForVault(vaultProxy),
            "withdrawBalance: Only owner or comptroller is authorized"
        );

        IGsnRelayHub(getHubAddr()).withdraw(getRelayHubDeposit(), payable(address(this)));

        uint256 amount = address(this).balance;

        Address.sendValue(payable(vaultProxy), amount);

        emit Withdrawn(amount);
    }

    // PUBLIC FUNCTIONS

    /// @notice Gets the current ComptrollerProxy of the VaultProxy associated with this contract
    /// @return parentComptroller_ The ComptrollerProxy
    function getParentComptroller() public view override returns (address parentComptroller_) {
        return __getComptrollerForVault(parentVault);
    }

    // PRIVATE FUNCTIONS

    /// @dev Helper to pull WETH from the associated vault to top up to the max ETH deposit in the relay hub
    function __depositMax() private {
        // Only allow one deposit every DEPOSIT_COOLDOWN seconds
        if (block.timestamp - getLastDepositTimestamp() < DEPOSIT_COOLDOWN) {
            return;
        }

        // Cap the total deposit to DEPOSIT_MAX_TOTAL wei
        uint256 prevDeposit = getRelayHubDeposit();
        if (prevDeposit >= DEPOSIT_MAX_TOTAL) {
            return;
        }
        uint256 amount = DEPOSIT_MAX_TOTAL.sub(prevDeposit);

        IGasRelayPaymasterDepositor(getParentComptroller()).pullWethForGasRelayer(amount);

        IWETH(getWethToken()).withdraw(amount);

        IGsnRelayHub(getHubAddr()).depositFor{value: amount}(address(this));

        lastDepositTimestamp = block.timestamp;

        emit Deposited(amount);
    }

    /// @dev Helper to get the ComptrollerProxy for a given VaultProxy
    function __getComptrollerForVault(address _vaultProxy) private view returns (address comptrollerProxy_) {
        return IVault(_vaultProxy).getAccessor();
    }

    /// @dev Helper to parse the canonical msg sender from trusted forwarder relayed calls
    /// See https://github.com/opengsn/gsn/blob/da4222b76e3ae1968608dc5c5d80074dcac7c4be/packages/contracts/src/ERC2771Recipient.sol#L41-L53
    function __msgSender() internal view returns (address canonicalSender_) {
        if (msg.data.length >= 20 && msg.sender == TRUSTED_FORWARDER) {
            assembly {
                canonicalSender_ := shr(96, calldataload(sub(calldatasize(), 20)))
            }

            return canonicalSender_;
        }

        return msg.sender;
    }

    /// @notice Parses the function selector from tx data
    /// @param _txData The tx data
    /// @return functionSelector_ The extracted function selector
    function __parseTxDataFunctionSelector(bytes calldata _txData) private pure returns (bytes4 functionSelector_) {
        /// convert bytes[:4] to bytes4
        require(_txData.length >= 4, "__parseTxDataFunctionSelector: _txData is not a valid length");

        functionSelector_ =
            _txData[0] | (bytes4(_txData[1]) >> 8) | (bytes4(_txData[2]) >> 16) | (bytes4(_txData[3]) >> 24);

        return functionSelector_;
    }

    //////////////////////////////////////
    // REGISTRY: ADDITIONAL RELAY USERS //
    //////////////////////////////////////

    /// @notice Adds additional relay users
    /// @param _usersToAdd The users to add
    function addAdditionalRelayUsers(address[] calldata _usersToAdd) external override onlyFundOwner {
        for (uint256 i; i < _usersToAdd.length; i++) {
            address user = _usersToAdd[i];
            require(!isAdditionalRelayUser(user), "addAdditionalRelayUsers: User registered");

            accountToIsAdditionalRelayUser[user] = true;

            emit AdditionalRelayUserAdded(user);
        }
    }

    /// @notice Removes additional relay users
    /// @param _usersToRemove The users to remove
    function removeAdditionalRelayUsers(address[] calldata _usersToRemove) external override onlyFundOwner {
        for (uint256 i; i < _usersToRemove.length; i++) {
            address user = _usersToRemove[i];
            require(isAdditionalRelayUser(user), "removeAdditionalRelayUsers: User not registered");

            accountToIsAdditionalRelayUser[user] = false;

            emit AdditionalRelayUserRemoved(user);
        }
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    /// @notice Gets gas limits used by the relay hub for the pre and post relay calls
    /// @return limits_ `GasAndDataLimits(PAYMASTER_ACCEPTANCE_BUDGET, PRE_RELAYED_CALL_GAS_LIMIT, POST_RELAYED_CALL_GAS_LIMIT, CALLDATA_SIZE_LIMIT)`
    function getGasAndDataLimits() external view override returns (IGsnPaymaster.GasAndDataLimits memory limits_) {
        return IGsnPaymaster.GasAndDataLimits(
            PAYMASTER_ACCEPTANCE_BUDGET, PRE_RELAYED_CALL_GAS_LIMIT, POST_RELAYED_CALL_GAS_LIMIT, CALLDATA_SIZE_LIMIT
        );
    }

    /// @notice Gets the `RELAY_HUB` variable value
    /// @return relayHub_ The `RELAY_HUB` value
    function getHubAddr() public view override returns (address relayHub_) {
        return RELAY_HUB;
    }

    /// @notice Gets the timestamp at last deposit into the relayer
    /// @return lastDepositTimestamp_ The timestamp
    function getLastDepositTimestamp() public view override returns (uint256 lastDepositTimestamp_) {
        return lastDepositTimestamp;
    }

    /// @notice Gets the `parentVault` variable value
    /// @return parentVault_ The `parentVault` value
    function getParentVault() public view override returns (address parentVault_) {
        return parentVault;
    }

    /// @notice Look up amount of ETH deposited on the relay hub
    /// @return depositBalance_ amount of ETH deposited on the relay hub
    function getRelayHubDeposit() public view override returns (uint256 depositBalance_) {
        return IGsnRelayHub(getHubAddr()).balanceOf(address(this));
    }

    /// @notice Gets the `WETH_TOKEN` variable value
    /// @return wethToken_ The `WETH_TOKEN` value
    function getWethToken() public view override returns (address wethToken_) {
        return WETH_TOKEN;
    }

    /// @notice Checks whether an account is an approved additional relayer user
    /// @return isAdditionalRelayUser_ True if the account is an additional relayer user
    function isAdditionalRelayUser(address _who) public view override returns (bool isAdditionalRelayUser_) {
        return accountToIsAdditionalRelayUser[_who];
    }

    /// @notice Gets the `TRUSTED_FORWARDER` variable value
    /// @return trustedForwarder_ The forwarder contract which is trusted to validated the relayed tx signature
    function trustedForwarder() external view override returns (address trustedForwarder_) {
        return TRUSTED_FORWARDER;
    }

    /// @notice Gets the string representation of the contract version (fulfills interface)
    /// @return versionString_ The version string
    function versionPaymaster() external view override returns (string memory versionString_) {
        return "2.2.3+opengsn.enzymefund.ipaymaster";
    }
}
