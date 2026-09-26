// Sources retrieved from Blockscout Ethereum API v2.

// ===== codeslaw-ethereum-0xb830a5afcbebb936c30c607a18bbba9f5b0a592f/contracts/RelayerV2.sol =====
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "hardhat-deploy/solc_0.7/proxy/Proxied.sol";

import "./interfaces/ILayerZeroRelayerV2.sol";
import "./interfaces/ILayerZeroUltraLightNodeV2.sol";
import "./interfaces/ILayerZeroPriceFeedV2.sol";

interface IStargateComposer {
    function isSending() external view returns (bool);
}

contract RelayerV2 is ReentrancyGuard, OwnableUpgradeable, Proxied, ILayerZeroRelayerV2 {
    using SafeERC20 for IERC20;
    using SafeMath for uint;
    using SafeMath for uint128;
    using SafeMath for uint64;

    ILayerZeroUltraLightNodeV2 public uln;
    address public stargateBridgeAddress;
    uint public constant AIRDROP_GAS_LIMIT = 10000;

    struct DstPrice {
        uint128 dstPriceRatio; // 10^10
        uint128 dstGasPriceInWei;
    }

    struct DstConfig {
        uint128 dstNativeAmtCap;
        uint64 baseGas;
        uint64 gasPerByte;
    }

    struct DstMultiplier {
        uint16 chainId;
        uint128 multiplier;
    }

    struct DstFloorMargin {
        uint16 chainId;
        uint128 floorMargin;
    }

    // [_chainId] => DstPriceData. change often
    mapping(uint16 => DstPrice) public dstPriceLookupOld;
    // [_chainId][_outboundProofType] => DstConfig. change much less often
    mapping(uint16 => mapping(uint16 => DstConfig)) public dstConfigLookup;
    mapping(address => bool) public approvedAddresses;

    event Withdraw(address to, uint amount);
    event ApproveAddress(address addr, bool approved);
    event SetPriceConfigUpdater(address priceConfigUpdater, bool allow);
    event AssignJob(uint totalFee);
    event ValueTransferFailed(address indexed to, uint indexed quantity);
    event SetDstPrice(uint16 chainId, uint128 dstPriceRatio, uint128 dstGasPriceInWei);
    event SetDstConfig(
        uint16 chainId,
        uint16 outboundProofType,
        uint128 dstNativeAmtCap,
        uint64 baseGas,
        uint64 gasPerByte
    );

    // new pauseable relayer
    bool public paused;

    // Update for Price Feed
    ILayerZeroPriceFeedV2 public priceFeed;
    // multipler for airdrop
    uint128 public multiplierBps;

    // PriceFeedContract Upgrade
    // all encoded param bytes except for proof for validateTransactionProofV1
    uint16 public validateProofBytes;
    uint16 public fpBytes;
    uint16 public mptOverhead;

    // [chainId] => [multiplier]
    mapping(uint16 => uint128) public dstMultipliers;
    // [chainId] => [floor margin in USD]
    mapping(uint16 => uint128) public dstFloorMarginsUSD;
    mapping(address => bool) public priceConfigUpdaters;

    // stargate guard
    IStargateComposer public stargateComposer;
    address public stargateBridgeAddr;

    // owner is always approved
    modifier onlyApproved() {
        if (owner() != msg.sender) {
            require(isApproved(msg.sender), "Relayer: not approved");
        }
        _;
    }

    modifier onlyPriceConfigUpdater() {
        if (owner() != msg.sender && !approvedAddresses[msg.sender]) {
            require(priceConfigUpdaters[msg.sender], "Relayer: not updater");
        }
        _;
    }

    function initialize(
        address _uln,
        address _priceFeed,
        address _stargateBridgeAddr,
        address _stargateComposer
    ) public proxied initializer {
        __Ownable_init();
        uln = ILayerZeroUltraLightNodeV2(_uln);
        setApprovedAddress(address(this), true);
        multiplierBps = 12000;
        priceFeed = ILayerZeroPriceFeedV2(_priceFeed);
        validateProofBytes = 164;
        fpBytes = 160;
        mptOverhead = 500;
        stargateBridgeAddr = _stargateBridgeAddr;
        stargateComposer = IStargateComposer(_stargateComposer);
    }

    function onUpgrade(address _stargateBridgeAddr, address _stargateComposer) public proxied {
        stargateBridgeAddr = _stargateBridgeAddr;
        stargateComposer = IStargateComposer(_stargateComposer);
    }

    //----------------------------------------------------------------------------------
    // onlyApproved

    function setDstPrice(uint16 _chainId, uint128 _dstPriceRatio, uint128 _dstGasPriceInWei) external onlyApproved {
        // No longer used: Write prices in PriceFeed.
    }

    function setPriceFeed(address _priceFeed) external onlyApproved {
        priceFeed = ILayerZeroPriceFeedV2(_priceFeed);
    }

    function setPriceMultiplierBps(uint128 _multiplierBps) external onlyApproved {
        multiplierBps = _multiplierBps;
    }

    function setDstPriceMultipliers(DstMultiplier[] calldata _multipliers) external onlyPriceConfigUpdater {
        for (uint i = 0; i < _multipliers.length; i++) {
            DstMultiplier calldata _data = _multipliers[i];
            dstMultipliers[_data.chainId] = _data.multiplier;
        }
    }

    function setDstFloorMarginsUSD(DstFloorMargin[] calldata _margins) external onlyPriceConfigUpdater {
        for (uint i = 0; i < _margins.length; i++) {
            DstFloorMargin calldata _data = _margins[i];
            dstFloorMarginsUSD[_data.chainId] = _data.floorMargin;
        }
    }

    function setDstConfig(
        uint16 _chainId,
        uint16 _outboundProofType,
        uint128 _dstNativeAmtCap,
        uint64 _baseGas,
        uint64 _gasPerByte
    ) external onlyApproved {
        dstConfigLookup[_chainId][_outboundProofType] = DstConfig(_dstNativeAmtCap, _baseGas, _gasPerByte);
        emit SetDstConfig(_chainId, _outboundProofType, _dstNativeAmtCap, _baseGas, _gasPerByte);
    }

    function setStargateAddress(address _stargateAddress) external onlyApproved {
        stargateBridgeAddress = _stargateAddress;
    }

    //----------------------------------------------------------------------------------
    // onlyOwner

    function setApprovedAddress(address _relayerAddress, bool _approve) public onlyOwner {
        approvedAddresses[_relayerAddress] = _approve;
        emit ApproveAddress(_relayerAddress, _approve);
    }

    function setPriceConfigUpdater(address _priceConfigUpdater, bool _allow) public onlyOwner {
        priceConfigUpdaters[_priceConfigUpdater] = _allow;
        emit SetPriceConfigUpdater(_priceConfigUpdater, _allow);
    }

    function setPause(bool _paused) public onlyOwner {
        paused = _paused;
    }

    // txType 1
    // bytes  [2       32      ]
    // fields [txType  extraGas]
    // txType 2
    // bytes  [2       32        32            bytes[]         ]
    // fields [txType  extraGas  dstNativeAmt  dstNativeAddress]
    // User App Address is not used in this version
    function _getPrices(
        uint16 _dstChainId,
        uint16 _outboundProofType,
        address,
        uint _payloadSize,
        bytes memory _adapterParameters
    ) internal view returns (uint) {
        require(!paused, "Admin: paused");
        // decoding the _adapterParameters - reverts if type 2 and there is no dstNativeAddress
        require(
            _adapterParameters.length == 34 || _adapterParameters.length > 66,
            "Relayer: wrong _adapterParameters size"
        );
        uint16 txType;
        uint extraGas;
        assembly {
            txType := mload(add(_adapterParameters, 2))
            extraGas := mload(add(_adapterParameters, 34))
        }
        require(extraGas > 0, "Relayer: gas too low");
        require(txType == 1 || txType == 2, "Relayer: unsupported txType");

        DstConfig storage dstConfig = dstConfigLookup[_dstChainId][_outboundProofType];

        // validateTransactionProof bytes = fixedBytes + proofBytes
        // V2 has an extra 32 bytes for payable address
        uint totalFixedBytes = txType == 2 ? uint(validateProofBytes).add(32) : validateProofBytes;
        uint proofBytes = _outboundProofType == 2 ? _payloadSize.add(fpBytes) : _payloadSize.add(mptOverhead);

        uint16 dstChainId = _dstChainId; // stack too deep
        (uint fee, uint128 priceRatio, uint128 priceRatioDenominator, uint128 nativePriceUSD) = priceFeed
            .estimateFeeByEid(dstChainId, totalFixedBytes.add(proofBytes), dstConfig.baseGas.add(extraGas));

        uint dstNativeAmt = 0;
        if (txType == 2) {
            assembly {
                dstNativeAmt := mload(add(_adapterParameters, 66))
            }
            require(dstConfig.dstNativeAmtCap >= dstNativeAmt, "Relayer: dstNativeAmt too large");
        }
        uint airdropAmount = 0;
        if (dstNativeAmt > 0) {
            // gas saver if no airdrop
            airdropAmount = dstNativeAmt.mul(priceRatio).div(priceRatioDenominator).mul(multiplierBps).div(10000); // cheaper than priceFeed.getPriceRatioDenominator()
        }
        return _getDstTxCost(dstChainId, fee, nativePriceUSD).add(airdropAmount);
    }

    function _getDstTxCost(uint16 _dstChainId, uint _fee, uint128 nativeTokenPriceUSD) private view returns (uint) {
        uint128 _dstMultiplier = dstMultipliers[_dstChainId];
        if (_dstMultiplier == 0) {
            _dstMultiplier = multiplierBps;
        }
        uint dstTxCostWithMultiplier = _fee.mul(_dstMultiplier).div(10000);

        if (nativeTokenPriceUSD == 0) {
            return dstTxCostWithMultiplier;
        }

        uint priceDenominator = 1e18;
        uint dstTxCostWithMargin = _fee.add(
            dstFloorMarginsUSD[_dstChainId].mul(priceDenominator).div(nativeTokenPriceUSD)
        );

        return dstTxCostWithMargin > dstTxCostWithMultiplier ? dstTxCostWithMargin : dstTxCostWithMultiplier;
    }

    function getFee(
        uint16 _dstChainId,
        uint16 _outboundProofType,
        address _userApplication,
        uint _payloadSize,
        bytes calldata _adapterParams
    ) external view override returns (uint) {
        require(_payloadSize <= 10000, "Relayer: _payloadSize tooooo big");
        return _getPrices(_dstChainId, _outboundProofType, _userApplication, _payloadSize, _adapterParams);
    }

    // view function to convert pricefeed price to current price (for backwards compatibility)
    function dstPriceLookup(uint16 _dstChainId) public view returns (DstPrice memory) {
        ILayerZeroPriceFeedV2.Price memory price = priceFeed.getPrice(_dstChainId);
        return DstPrice(price.priceRatio, price.gasPriceInUnit);
    }

    function isApproved(address _relayerAddress) public view returns (bool) {
        return approvedAddresses[_relayerAddress];
    }

    function assignJob(
        uint16 _dstChainId,
        uint16 _outboundProofType,
        address _userApplication,
        uint _payloadSize,
        bytes calldata _adapterParams
    ) external override returns (uint fee) {
        require(msg.sender == address(uln), "Relayer: invalid uln");
        require(_payloadSize <= 10000, "Relayer: _payloadSize > 10000");

        if (_userApplication == stargateBridgeAddr) {
            // following way also prevents user from inputting to address greater than 32 bytes
            bool validPayload = (_payloadSize == 544 || // swap with no payload
                _payloadSize == 320 || // redeem local callback
                _payloadSize == 288 || // redeem local
                _payloadSize == 160); // send credits

            if (!validPayload) {
                require(stargateComposer.isSending(), "Relayer: stargate composer is not sending");
            }
        }

        fee = _getPrices(_dstChainId, _outboundProofType, _userApplication, _payloadSize, _adapterParams);
        emit AssignJob(fee);
    }

    function withdrawFee(address payable _to, uint _amount) external override onlyApproved {
        uint totalFee = uln.accruedNativeFee(address(this));
        require(_amount <= totalFee, "Relayer: not enough fee for withdrawal");
        uln.withdrawNative(_to, _amount);
    }

    function withdrawToken(address _token, address _to, uint _amount) external onlyApproved {
        uint total = IERC20(_token).balanceOf(address(this));
        require(_amount <= total, "Relayer: not enough fee for withdrawal");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function validateTransactionProofV2(
        uint16 _srcChainId,
        address _dstAddress,
        uint _gasLimit,
        bytes32 _blockHash,
        bytes32 _data,
        bytes calldata _transactionProof,
        address payable _to
    ) external payable onlyApproved nonReentrant {
        (bool sent, ) = _to.call{gas: AIRDROP_GAS_LIMIT, value: msg.value}("");
        //require(sent, "Relayer: failed to send ether");
        if (!sent) {
            emit ValueTransferFailed(_to, msg.value);
        }
        uln.validateTransactionProof(_srcChainId, _dstAddress, _gasLimit, _blockHash, _data, _transactionProof);
    }

    function validateTransactionProofV1(
        uint16 _srcChainId,
        address _dstAddress,
        uint _gasLimit,
        bytes32 _blockHash,
        bytes32 _data,
        bytes calldata _transactionProof
    ) external onlyApproved nonReentrant {
        uln.validateTransactionProof(_srcChainId, _dstAddress, _gasLimit, _blockHash, _data, _transactionProof);
    }
}


// ===== @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol =====
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}


// ===== @openzeppelin/contracts-upgradeable/proxy/Initializable.sol =====
// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}


// ===== @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol =====
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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


// ===== @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol =====
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


// ===== @openzeppelin/contracts/math/SafeMath.sol =====
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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


// ===== @openzeppelin/contracts/token/ERC20/IERC20.sol =====
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}


// ===== @openzeppelin/contracts/token/ERC20/SafeERC20.sol =====
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

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
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// ===== @openzeppelin/contracts/utils/Address.sol =====
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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


// ===== @openzeppelin/contracts/utils/ReentrancyGuard.sol =====
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
abstract contract ReentrancyGuard {
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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// ===== codeslaw-ethereum-0xb830a5afcbebb936c30c607a18bbba9f5b0a592f/contracts/interfaces/ILayerZeroPriceFeedV2.sol =====
// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;
pragma abicoder v2;

// copy of "@layerzerolabs/lz-evm-messagelib-v2/contracts/interfaces/ILayerZeroPriceFeed.sol"
interface ILayerZeroPriceFeedV2 {
    /**
     * @dev
     * priceRatio: (USD price of 1 unit of remote native token in unit of local native token) * PRICE_RATIO_DENOMINATOR
     */

    struct Price {
        uint128 priceRatio; // float value * 10 ^ 20, decimal awared. for aptos to evm, the basis would be (10^18 / 10^8) * 10 ^20 = 10 ^ 30.
        uint64 gasPriceInUnit; // for evm, it is in wei, for aptos, it is in octas.
        uint32 gasPerByte;
    }

    struct UpdatePrice {
        uint32 eid;
        Price price;
    }

    /**
     * @dev
     *    ArbGasInfo.go:GetPricesInArbGas
     *
     */
    struct ArbitrumPriceExt {
        uint64 gasPerL2Tx; // L2 overhead
        uint32 gasPerL1CallDataByte;
    }

    struct UpdatePriceExt {
        uint32 eid;
        Price price;
        ArbitrumPriceExt extend;
    }

    function getPrice(uint32 _dstEid) external view returns (Price memory);

    function getPriceRatioDenominator() external view returns (uint128);

    function estimateFeeByEid(
        uint32 _dstEid,
        uint _callDataSize,
        uint _gas
    ) external view returns (uint fee, uint128 priceRatio, uint128 priceRatioDenominator, uint128 nativePriceUSD);
}


// ===== codeslaw-ethereum-0xb830a5afcbebb936c30c607a18bbba9f5b0a592f/contracts/interfaces/ILayerZeroRelayerV2.sol =====
// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;

interface ILayerZeroRelayerV2 {
    // @notice query price and assign jobs at the same time
    // @param _dstChainId - the destination endpoint identifier
    // @param _outboundProofType - the proof type identifier to specify proof to be relayed
    // @param _userApplication - the source sending contract address. relayers may apply price discrimination to user apps
    // @param _payloadSize - the length of the payload. it is an indicator of gas usage for relaying cross-chain messages
    // @param _adapterParams - optional parameters for extra service plugins, e.g. sending dust tokens at the destination chain
    function assignJob(
        uint16 _dstChainId,
        uint16 _outboundProofType,
        address _userApplication,
        uint _payloadSize,
        bytes calldata _adapterParams
    ) external returns (uint price);

    // @notice query the relayer price for relaying the payload and its proof to the destination chain
    // @param _dstChainId - the destination endpoint identifier
    // @param _outboundProofType - the proof type identifier to specify proof to be relayed
    // @param _userApplication - the source sending contract address. relayers may apply price discrimination to user apps
    // @param _payloadSize - the length of the payload. it is an indicator of gas usage for relaying cross-chain messages
    // @param _adapterParams - optional parameters for extra service plugins, e.g. sending dust tokens at the destination chain
    function getFee(
        uint16 _dstChainId,
        uint16 _outboundProofType,
        address _userApplication,
        uint _payloadSize,
        bytes calldata _adapterParams
    ) external view returns (uint price);

    // @notice withdraw the accrued fee in ultra light node
    // @param _to - the fee receiver
    // @param _amount - the withdrawal amount
    function withdrawFee(address payable _to, uint _amount) external;
}


// ===== codeslaw-ethereum-0xb830a5afcbebb936c30c607a18bbba9f5b0a592f/contracts/interfaces/ILayerZeroUltraLightNodeV2.sol =====
// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;
pragma abicoder v2;

interface ILayerZeroUltraLightNodeV2 {
    // Relayer functions
    function validateTransactionProof(
        uint16 _srcChainId,
        address _dstAddress,
        uint _gasLimit,
        bytes32 _lookupHash,
        bytes32 _blockData,
        bytes calldata _transactionProof
    ) external;

    // an Oracle delivers the block data using updateHash()
    function updateHash(uint16 _srcChainId, bytes32 _lookupHash, uint _confirmations, bytes32 _blockData) external;

    // can only withdraw the receivable of the msg.sender
    function withdrawNative(address payable _to, uint _amount) external;

    function withdrawZRO(address _to, uint _amount) external;

    // view functions
    function getAppConfig(
        uint16 _remoteChainId,
        address _userApplicationAddress
    ) external view returns (ApplicationConfiguration memory);

    function accruedNativeFee(address _address) external view returns (uint);

    struct ApplicationConfiguration {
        uint16 inboundProofLibraryVersion;
        uint64 inboundBlockConfirmations;
        address relayer;
        uint16 outboundProofType;
        uint64 outboundBlockConfirmations;
        address oracle;
    }

    event HashReceived(
        uint16 indexed srcChainId,
        address indexed oracle,
        bytes32 lookupHash,
        bytes32 blockData,
        uint confirmations
    );
    event RelayerParams(bytes adapterParams, uint16 outboundProofType);
    event Packet(bytes payload);
    event InvalidDst(
        uint16 indexed srcChainId,
        bytes srcAddress,
        address indexed dstAddress,
        uint64 nonce,
        bytes32 payloadHash
    );
    event PacketReceived(
        uint16 indexed srcChainId,
        bytes srcAddress,
        address indexed dstAddress,
        uint64 nonce,
        bytes32 payloadHash
    );
    event AppConfigUpdated(address indexed userApplication, uint indexed configType, bytes newConfig);
    event AddInboundProofLibraryForChain(uint16 indexed chainId, address lib);
    event EnableSupportedOutboundProof(uint16 indexed chainId, uint16 proofType);
    event SetChainAddressSize(uint16 indexed chainId, uint size);
    event SetDefaultConfigForChainId(
        uint16 indexed chainId,
        uint16 inboundProofLib,
        uint64 inboundBlockConfirm,
        address relayer,
        uint16 outboundProofType,
        uint64 outboundBlockConfirm,
        address oracle
    );
    event SetDefaultAdapterParamsForChainId(uint16 indexed chainId, uint16 indexed proofType, bytes adapterParams);
    event SetLayerZeroToken(address indexed tokenAddress);
    event SetRemoteUln(uint16 indexed chainId, bytes32 uln);
    event SetTreasury(address indexed treasuryAddress);
    event WithdrawZRO(address indexed msgSender, address indexed to, uint amount);
    event WithdrawNative(address indexed msgSender, address indexed to, uint amount);
}


// ===== hardhat-deploy/solc_0.7/proxy/Proxied.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

abstract contract Proxied {
    /// @notice to be used by initialisation / postUpgrade function so that only the proxy's admin can execute them
    /// It also allows these functions to be called inside a contructor
    /// even if the contract is meant to be used without proxy
    modifier proxied() {
        address proxyAdminAddress = _proxyAdmin();
        // With hardhat-deploy proxies
        // the proxyAdminAddress is zero only for the implementation contract
        // if the implementation contract want to be used as a standalone/immutable contract
        // it simply has to execute the `proxied` function
        // This ensure the proxyAdminAddress is never zero post deployment
        // And allow you to keep the same code for both proxied contract and immutable contract
        if (proxyAdminAddress == address(0)) {
            // ensure can not be called twice when used outside of proxy : no admin
            // solhint-disable-next-line security/no-inline-assembly
            assembly {
                sstore(
                    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                )
            }
        } else {
            require(msg.sender == proxyAdminAddress);
        }
        _;
    }

    modifier onlyProxyAdmin() {
        require(msg.sender == _proxyAdmin(), "NOT_AUTHORIZED");
        _;
    }

    function _proxyAdmin() internal view returns (address ownerAddress) {
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            ownerAddress := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
        }
    }
}

