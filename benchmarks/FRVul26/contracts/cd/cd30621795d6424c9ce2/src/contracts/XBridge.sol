// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

import "./adaptor/BridgeAdaptorBase.sol";
import "./helpers/Constants.sol";
import "./helpers/Errors.sol";

import "./interfaces/IDaiLikePermit.sol";
import "./interfaces/IApproveProxy.sol";
import "./interfaces/IWNativeRelayer.sol";
import "./interfaces/IWETH.sol";

import "./libraries/Bytes.sol";
import "./libraries/RevertReasonParser.sol";
import "./libraries/CommissionLib.sol";

/**
 * @title XBridge
 * @notice Entrance for Bridge
 * - Users can:
 *   # Bridge: Initiate cross-chain asset transfers.
 *   # Swap and bridge: Perform token swaps and initiate cross-chain transfers.
 * @dev XBridge is a smart contract that serves as the entrance for cross-chain operations,
 * allowing users to interact with various functionalities such as bridging assets,
 * swapping and bridging tokens, and claiming assets on the destination chain.
 */
contract XBridge is PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, CommissionLib {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Struct representing the information needed for a bridge transaction
    struct BridgeRequestV2 {
        uint256 adaptorId;
        address to;
        address token;
        uint256 toChainId; // orderId[64bit] | gasFeeAmount[160] | target chainId[32bit]
        uint256 amount;
        bytes   data;      // router data
        bytes   extData;
    }

    // Struct representing the information needed for a swap and bridge transaction
    struct SwapBridgeRequestV2 {
        address fromToken;                // the source token
        address toToken;                  // the token to be bridged
        address to;                       // the address to be bridged to
        uint256 adaptorId;
        uint256 toChainId;                // orderId[64bit] | gasFeeAmount[160] | target chainId[32bit]
        uint256 fromTokenAmount;          // the source token amount
        uint256 toTokenMinAmount;
        uint256 toChainToTokenMinAmount;
        bytes   data;                     // router data
        bytes   dexData;                  // the call data for dexRouter
        bytes   extData;
    }

    // Struct representing the information needed for a swap transaction
    struct SwapRequest {
        address fromToken;
        address toToken;
        address to;
        uint256 amount; // amount of swapped fromToken
        uint256 gasFeeAmount; // tx gas fee slash from fromToken
        uint256 srcChainId;
        bytes32 srcTxHash;
        bytes   dexData;
        bytes   extData;
    }

    // Struct representing the information needed for receiving gas tokens on another chain
    struct ReceiveGasRequest {
        address to;
        uint256 amount;
        uint256 srcChainId;
        bytes32 srcTxHash;
        bytes   extData;
    }

    // Struct representing a threshold configuration for a specific address
    struct Threshold {
        bool    opened;
        uint256 amount;
    }

    // Struct representing information related to an oracle, used for verifying certain transactions
    struct OracleInfo {
        uint256 srcChainId;
        bytes32 txHash;
        bytes32 to;
        bytes32 token;
        uint256 amount;
        uint256 actualAmount;
    }

    //-------------------------------
    //------- storage ---------------
    //-------------------------------
    mapping(uint256 => address) public adaptorInfo;

    /**
     * @dev This state variable is deprecated and should not be used anymore.
     */
    address public approveProxy;

    address public dexRouter;

    address public payer;

    address public receiver;

    address public feeTo;

    address public admin;

    mapping(address => bool) public mpc;

    mapping(uint256 => mapping(bytes32 => bool)) public paidTx;

    mapping(uint256 => mapping(bytes32 => bool)) public receiveGasTx;

    /**
     * @dev Set by admin
     */
    mapping(uint256 => uint256) public sysRatio;

    /**
     * @dev This state variable is deprecated and should not be used anymore.
     */
    mapping(uint256 => address) public sysAddressConfig;

    mapping(address => Threshold) public thresholdConfig;

    mapping(address => bool) public proxies; // oracle proxy

    mapping(bytes4 => bool) public accessSelectorId; // for swap

    /**
     * @notice Initializes the XBridge contract.
     * @dev This function is part of the Upgradable pattern and is called once to initialize contract state.
     * It sets up the initial state by invoking the initializers of the inherited contracts.
     * The `admin` variable is set to the address of the account that deploys the contract.
     * Note: This function is meant to be called only once during the contract deployment.
     */
    function initialize() public initializer {
        __Pausable_init();
        __ReentrancyGuard_init();
        __Ownable_init();
        admin = msg.sender;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    //-------------------------------
    //------- Events ----------------
    //-------------------------------
    event DexRouterChanged(address _dexRouter);

    /**
     * @notice Event emitted when a bridge transaction occurs
     */
    event LogBridgeTo(
        uint256 indexed _adaptorId,
        address _from,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _receiveFee,
        bytes32[] ext
    );

    /**
     * @notice Event emitted when a swap and bridge transaction occurs
     */
    event LogSwapAndBridgeTo(
        uint256 indexed _adaptorId,
        address _from,
        address _to,
        address _fromToken,
        uint256 _fromAmount,
        address _toToken,
        uint256 _toAmount,
        uint256 _receiveFee,
        bytes32[] ext
    );
    event FeeToChanged(address _feeTo);

    event AdminChanged(address _newAdmin);

    event GasTokenReceived(
        address to,
        uint256 amount,
        uint256 srcChainId,
        bytes32[] ext
    );

    /**
     * @notice Event emitted when a claim transaction occurs
     */
    event Claimed(
        address to,
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 toTokenAmount,
        uint256 gasFeeAmount,
        uint256 srcChainId,
        string  errInfo,
        bytes32[] ext
    );

    event AdaptorsChanged(uint256 indexed _adaptorId, address _adaptor);

    event MpcChanged(address _mpc, bool _enable);

    event SysRatioChanged(uint256 _index, uint256 _ratio);

    event ProxiesChanged(address _proxy, bool _enable);

    event AccessSelectorIdChanged(bytes4 _selectorId, bool _enable);
    //-------------------------------
    //------- Modifier --------------
    //-------------------------------

    modifier onlyMPC() {
        require(mpc[msg.sender], XBridgeErrors.ONLY_MPC);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, XBridgeErrors.ONLY_ADMIN);
        _;
    }

    //-------------------------------
    //------- Internal Functions ----
    //-------------------------------

    /**
     * @notice Internal pure function to extract information from a packed uint256 value representing gas receive details
     * @param toChainId Packed uint256 value containing order ID, gas fee amount, and chain ID
     */
    function _getGasReceiveAmount(uint256 toChainId)
        internal
        pure
        returns (
            uint256 orderId,
            uint256 gasFeeAmount,
            uint256 chainId
        )
    {
        orderId      = (toChainId & 0xffffffffffffffff000000000000000000000000000000000000000000000000) >> 192;
        gasFeeAmount = (toChainId & 0x0000000000000000ffffffffffffffffffffffffffffffffffffffff00000000) >> 32;
        chainId      =  toChainId & 0x00000000000000000000000000000000000000000000000000000000ffffffff;
    }

    /**
     * @notice Internal function to perform a token deposit operation.
     * @dev Ensures that the caller has sufficient allowance to deposit the specified amount of tokens.
     * @param from The address from which tokens are transferred.
     * @param to The recipient address to receive the deposited tokens.
     * @param token The address of the ERC20 token being deposited.
     * @param amount The amount of tokens to be deposited.
    */
    function _deposit(
        address from,
        address to,
        address token,
        uint256 amount
    ) internal {
        IApproveProxy(XBridgeConstants.APPROVE_PROXY).claimTokens(token, from, to, amount);
    }

    function _getBalanceOf(address token) internal view returns (uint256) {
        return _getBalanceOf(token, address(this));
    }

    function _getBalanceOf(address token, address who) internal view returns(uint256) {
        return token == XBridgeConstants.NATIVE_TOKEN ? who.balance : IERC20Upgradeable(token).balanceOf(who);
    }


    /**
     * @notice Internal function to transfer ERC20 tokens or native tokens (ETH) to a specified address.
     * @param to The address to which tokens are transferred.
     * @param token The address of the ERC20 token to be transferred.
     * @param amount The amount of tokens to be transferred.
     */
    function _transferToken(address to, address token, uint256 amount) internal {
        if (amount > 0) {
            if (token == XBridgeConstants.NATIVE_TOKEN) {
                (bool success, ) = payable(to).call{value: amount}("");
                require(success, XBridgeErrors.TRANSFER_ETH_FAILD);
            } else {
                IERC20Upgradeable(token).safeTransfer(to, amount);
            }
        }
    }

    /**
     * @notice Internal pure function to construct extension data for cross-chain transaction.
     * @param orderId The unique identifier for the cross-chain transaction.
     * @param toChainId The identifier of the target chain.
     * @param adaptorId The identifier of the cross-chain adaptor used.
     * @param to The destination address on the target chain.
     * @param data Additional data specific to the cross-chain adaptor.
     * @param extData Additional extension data containing user-specific information.
     * @return ext An array of bytes32 values representing the constructed extension data.
     */
    function _constructExt(uint256 orderId, uint256 toChainId, uint256 adaptorId, address to, bytes memory data, bytes memory extData)
        internal
        pure
        returns(bytes32[] memory ext)
    {
        ext = new bytes32[](6);
        ext[0] = bytes32(orderId);
        ext[1] = bytes32(toChainId);

        if (adaptorId == XBridgeConstants.ADAPTER_ID_ANYSWAP
                || adaptorId == XBridgeConstants.ADAPTER_ID_CBRIDGE) {
            ext[2] = bytes32(abi.encodePacked(to));
            ext[3] = bytes32(abi.encodePacked(""));
        } else if (adaptorId == XBridgeConstants.ADAPTER_ID_SWFT) {
            (,,string memory destination,) = abi.decode(data, (address, string, string, uint256));
            bytes32[] memory destBytes32Arr = Bytes.bytesToBytes32Array(bytes(destination));
            ext[2] = destBytes32Arr[0];
            if (destBytes32Arr.length > 1) {
                ext[3] = destBytes32Arr[1];
            }
        }
        if (extData.length > 0) {
            (string memory userAddress) = abi.decode(extData, (string));
            bytes32[] memory userAddressBytes32Arr = Bytes.bytesToBytes32Array(bytes(userAddress));
            ext[4] = userAddressBytes32Arr[0];
            if (userAddressBytes32Arr.length > 1) {
                ext[5] = userAddressBytes32Arr[1];
            }
        } else {
            ext[4] = ext[2];
            ext[5] = ext[3];
        }
        return ext;
    }

    /**
     * @notice Struct to represent the result of a commission operation.
     */
    struct CommissionReturn {
        uint256 commissionAmount;  // commission amount
        bytes extDataWithoutLast32;  // extData without last 32 bytes
    }

    /**
     * @notice Internal function to initiate a cross-chain transaction using the specified BridgeRequestV2 parameters.
     * @param _request The BridgeRequestV2 struct containing transaction details.
     * @dev Performs necessary validations, token transfers, and calls the outboundBridgeTo function on the selected adaptor.
     */
    function _bridgeToV2Internal(BridgeRequestV2 memory _request) internal {
        require(_request.adaptorId != 0, XBridgeErrors.INVALID_ADAPTOR_ID);
        address adaptor = adaptorInfo[_request.adaptorId];
        require(adaptor != address(0), XBridgeErrors.INVALID_ADAPTOR_ADDRESS);
        require(_request.to != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.token != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.amount != 0, XBridgeErrors.AMOUNT_ZERO);

        // doCommission
        CommissionReturn memory vars;
        (vars.commissionAmount, vars.extDataWithoutLast32) = _doCommission(_request.amount, _request.token, _request.extData);
        _request.extData = vars.extDataWithoutLast32;
        uint256 ethValue = msg.value;

        // Extract gas fee details from toChainId
        (uint256 orderId, uint256 gasFeeAmount, uint256 toChainId) = _getGasReceiveAmount(_request.toChainId);
        if (_request.token == XBridgeConstants.NATIVE_TOKEN) {
            require(msg.value >= _request.amount + gasFeeAmount + vars.commissionAmount, XBridgeErrors.INVALID_MSG_VALUE);
            ethValue -= vars.commissionAmount;   // after docommission
            if (gasFeeAmount > 0) {
                (bool success, ) = payable(feeTo).call{value: gasFeeAmount}("");
                require(success, XBridgeErrors.TRANSFER_ETH_FAILD);
                ethValue -= gasFeeAmount;
            }
        } else {
            if (gasFeeAmount > 0) {
                _deposit(msg.sender, feeTo, _request.token, gasFeeAmount);
            }
            _deposit(msg.sender, adaptor, _request.token, _request.amount);
        }

        // Call the outboundBridgeTo function on the selected adaptor
        BridgeAdaptorBase(payable(adaptor)).outboundBridgeTo{value : ethValue}(
            msg.sender,
            _request.to,
            msg.sender, // refund to msg.sender
            _request.token,
            _request.amount,
            toChainId,
            _request.data
        );

        // Construct extension data and emit the LogBridgeTo event
        bytes32[] memory ext = _constructExt(
                                    orderId,
                                    toChainId,
                                    _request.adaptorId,
                                    _request.to,
                                    _request.data,
                                    _request.extData
                                );
        emit LogBridgeTo(
            _request.adaptorId,
            msg.sender,
            _request.to,
            _request.token,
            _request.amount,
            gasFeeAmount,
            ext
        );
    }

    /**
     * @notice Struct to represent the result of a cross-chain bridge operation.
     * @dev Holds information about the adaptor, token balances, gas fee, chain ID, order ID, success status, function selector, and result data.
     */
    struct BridgeVariants {
        address adaptor;
        uint256 toTokenBalance;
        uint256 toTokenBalanceOrigin;
        uint256 gasFeeAmount;
        uint256 toChainId;
        uint256 orderId;
        bool success;
        bytes4 selectorId;
        bytes result;
    }

    /**
     * @notice Internal function to perform a token swap and bridge operation using the specified SwapBridgeRequestV2 parameters.
     * @param _request The SwapBridgeRequestV2 struct containing swap and bridge details.
     * @dev Performs necessary validations, token swaps, bridge calls, and balance checks.
     */
    function _swapBridgeToInternal(SwapBridgeRequestV2 memory _request) internal {
        BridgeVariants memory vars;
        require(_request.adaptorId != 0, XBridgeErrors.INVALID_ADAPTOR_ID);
        vars.adaptor = adaptorInfo[_request.adaptorId];
        require(vars.adaptor != address(0), XBridgeErrors.INVALID_ADAPTOR_ADDRESS);
        require(_request.fromToken != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.toToken != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.fromToken != _request.toToken, XBridgeErrors.ADDRESS_EQUAL);
        require(_request.to != address(0), XBridgeErrors.ADDRESS_0);
        require(dexRouter != address(0), XBridgeErrors.ADDRESS_0);
        require(_request.fromTokenAmount != 0, XBridgeErrors.AMOUNT_ZERO);
        require(_request.toTokenMinAmount != 0, XBridgeErrors.MIN_AMOUNT_ZERO);

        // Extract gas fee details from toChainId
        (vars.orderId, vars.gasFeeAmount,  vars.toChainId) = _getGasReceiveAmount(_request.toChainId);
        vars.toTokenBalanceOrigin = _getBalanceOf(_request.toToken);

        // Validate the dexData function selector
        require(accessSelectorId[bytes4(_request.dexData)], XBridgeErrors.ERROR_SELECTOR_ID);

        // Set payer and receiver addresses for potential refund
        payer = msg.sender;
        receiver = address(this);

        // doCommission
        (uint256 commissionAmount, bytes memory extDataWithoutLast32) = _doCommission(_request.fromTokenAmount, _request.fromToken, _request.extData);
        _request.extData = extDataWithoutLast32;

        // 1. prepare and swap
        if (_request.fromToken == XBridgeConstants.NATIVE_TOKEN) { //FROM NATIVE
            require(msg.value - commissionAmount >= _request.fromTokenAmount, XBridgeErrors.INVALID_MSG_VALUE);
            if (_request.toToken == XBridgeConstants.WETH) { //ETH => WETH
                vars.success = _swapWrap(address(this), address(this), _request.fromTokenAmount, false);
            } else { // ETH => ERC20, use dexRouter       
                (vars.success, vars.result) = dexRouter.call{value : _request.fromTokenAmount}(_request.dexData);
            }
        } else { // FROM ERC20
            if (_request.fromToken == XBridgeConstants.WETH && _request.toToken == XBridgeConstants.NATIVE_TOKEN) {
                // WETH => ETH
                vars.success = _swapWrap(msg.sender, address(this), _request.fromTokenAmount, true);
            } else { // ERC20 => ERC20, use dexRouter
                (vars.success, vars.result) = dexRouter.call(_request.dexData);
            }
        }
        delete payer;
        delete receiver;
        // 2. check result and balance

        require(vars.success,vars.result.length == 0 ? XBridgeErrors.INTERNAL_WRAP_FAIL : RevertReasonParser.parse(vars.result, XBridgeErrors.DEX_ROUTER_ERR));
        vars.toTokenBalance = _getBalanceOf(_request.toToken) - vars.toTokenBalanceOrigin; // toToken added
        require(vars.toTokenBalance >= vars.gasFeeAmount + _request.toTokenMinAmount, XBridgeErrors.MIN_AMOUNT_ERR);

        // 3. Receive to token for relay gas token on target chain to user
        _transferToken(feeTo, _request.toToken, vars.gasFeeAmount);

        // 4. Bridge the toToken to the target chain
        vars.toTokenBalance = vars.toTokenBalance - vars.gasFeeAmount;
        if (_request.toToken == XBridgeConstants.NATIVE_TOKEN) {
            // Internal with BridgeAdaptorBase, so it is safe to use payable
            BridgeAdaptorBase(payable(vars.adaptor)).outboundBridgeTo{
                value: vars.toTokenBalance + msg.value
            }(
                msg.sender,
                _request.to,
                msg.sender, // refund to msg.sender
                _request.toToken,
                vars.toTokenBalance,
                vars.toChainId,
                _request.data
            );
        } else {
            _transferToken(vars.adaptor, _request.toToken, vars.toTokenBalance);
            if (_request.fromToken == XBridgeConstants.NATIVE_TOKEN){
                BridgeAdaptorBase(payable(vars.adaptor)).outboundBridgeTo{value : msg.value - commissionAmount - _request.fromTokenAmount }(
                    msg.sender,
                    _request.to,
                    msg.sender, // refund to msg.sender
                    _request.toToken,
                    vars.toTokenBalance,
                    vars.toChainId,
                    _request.data
                );
            } else {
                BridgeAdaptorBase(payable(vars.adaptor)).outboundBridgeTo{value : msg.value }(
                    msg.sender,
                    _request.to,
                    msg.sender, // refund to msg.sender
                    _request.toToken,
                    vars.toTokenBalance,
                    vars.toChainId,
                    _request.data
                );
            }
        }

        // Construct extension data and emit the LogBridgeTo event
        bytes32[] memory ext = _constructExt(
                                    vars.orderId,
                                    vars.toChainId,
                                    _request.adaptorId,
                                    _request.to,
                                    _request.data,
                                    _request.extData
                                );
        emit LogSwapAndBridgeTo(
            _request.adaptorId,
            msg.sender,
            _request.to,
            _request.fromToken,
            _request.fromTokenAmount,
            _request.toToken,
            vars.toTokenBalance,
            vars.gasFeeAmount,
            ext
        );

        // 5. Check balance
        if (_request.toToken == XBridgeConstants.NATIVE_TOKEN){
            // if toToken equal nativeToken, should add msg.value
            require(_getBalanceOf(_request.toToken) + msg.value >= vars.toTokenBalanceOrigin, XBridgeErrors.SLASH_MUCH_TOO_MONEY);
        } else {
            require(_getBalanceOf(_request.toToken) >= vars.toTokenBalanceOrigin, XBridgeErrors.SLASH_MUCH_TOO_MONEY);
        }
    }

    /**
     * @notice Internal function to execute a permit on an ERC20 token if a permit data is provided.
     * @param token Address of the ERC20 token.
     * @param permit Permit data containing the necessary parameters for the permit function.
     */
    function _permit(address token, bytes calldata permit) internal {
        if (permit.length > 0) {
            bool success;
            bytes memory result;
            if (permit.length == 32 * 7) {
                // solhint-disable-next-line avoid-low-level-calls
                (success, result) = token.call(abi.encodePacked(IERC20Permit.permit.selector, permit));
            } else if (permit.length == 32 * 8) {
                // solhint-disable-next-line avoid-low-level-calls
                (success, result) = token.call(abi.encodePacked(IDaiLikePermit.permit.selector, permit));
            } else {
                revert("Wrong permit length");
            }
            if (!success) {
                revert(RevertReasonParser.parse(result, "Permit failed: "));
            }
        }
    }

    /**
     * @notice Internal function to receive gas tokens from the source chain and transfer them to the specified recipient.
     * @param _request The ReceiveGasRequest struct containing details about the gas token receipt.
     * @dev Performs necessary validations, updates state, and emits the GasTokenReceived event.
     */
    function _receiveGasTokenInternal(ReceiveGasRequest memory _request) internal {
        require(_request.amount <= sysRatio[XBridgeConstants.GAS_TOKEN_RECEIVE_MAX_INDEX], XBridgeErrors.EXCEED_ALLOWED_GAS);
        require(!receiveGasTx[_request.srcChainId][_request.srcTxHash], XBridgeErrors.HAS_RECEIVE_GAS);
        receiveGasTx[_request.srcChainId][_request.srcTxHash] = true;
        _transferToken(_request.to, XBridgeConstants.NATIVE_TOKEN, _request.amount);
        bytes32[] memory ext = new bytes32[](1);
        ext[0] = _request.srcTxHash;
        emit GasTokenReceived(_request.to, _request.amount, _request.srcChainId, ext);
    }

    /**
     * @notice Internal function to decode a message and its signature to extract relevant information.
     * @param _message The encoded message containing information about the oracle request.
     * @param _signature The signature of the message for authentication.
     * @return source The address of the message sender recovered from the signature.
     * @return thisChainId The chain ID of this contract.
     * @return thisContractAddress The address of this contract.
     * @return oracleInfo An OracleInfo struct containing details of the oracle request.
     * @dev Decodes the message and signature to extract source address, chain ID, contract address, and oracle request details.
     */
    function _decode(bytes memory _message, bytes memory _signature)
        internal
        pure
        returns (
            address source,
            uint256 thisChainId,
            address thisContractAddress,
            OracleInfo memory oracleInfo
        )
    {
        { // fix Stack too deep
            (bytes32 r, bytes32 s, uint8 v) = abi.decode(_signature, (bytes32, bytes32, uint8));
            bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(_message)));
            source = ecrecover(hash, v, r, s);
        }
        (
            thisChainId,
            thisContractAddress,
            oracleInfo.srcChainId,
            oracleInfo.txHash,
            oracleInfo.to,
            oracleInfo.token,
            oracleInfo.amount,
            oracleInfo.actualAmount
        ) = abi.decode(_message, (uint256, address, uint256, bytes32, bytes32, bytes32, uint256, uint256));
        return (source, thisChainId, thisContractAddress, oracleInfo);
    }

    /**
     * @notice Internal function to verify the oracle signature and details for a swap request.
     * @param _request The SwapRequest struct containing swap details.
     * @param _amount The amount to be verified against the oracle threshold.
     * @dev Verifies the oracle signature, source address, and additional details for the swap request.
     */
    function _verifyOracle(
        SwapRequest memory _request,
        uint256 _amount
    )
        view
        internal
    {
        (bytes memory message, bytes memory signature) = abi.decode(_request.extData, (bytes, bytes));
        (
            address source,
            uint256 thisChainId,
            address thisContractAddress,
            OracleInfo memory oracleInfo
        ) = _decode(message, signature);

        // Validate the source address, oracle proxy status, chain ID, contract address, and request details
        require(source != address(0), XBridgeErrors.ZERO_SIGNER);
        require(proxies[source], XBridgeErrors.NOT_ORACLE_PROXY);
        require(thisChainId == sysRatio[XBridgeConstants.CHAIN_ID_INDEX], XBridgeErrors.ERR_CHAIN_ID);
        require(thisContractAddress == address(this), XBridgeErrors.CONTRACT_ADDRESS_ERROR);
        require(_request.srcTxHash == oracleInfo.txHash, XBridgeErrors.ORACLE_NO_INFO);
        require(_request.to == address(uint160(uint256(oracleInfo.to))), XBridgeErrors.ORACLE_TO_ADDRESS_ERR);
        require(_request.fromToken == address(uint160(uint256(oracleInfo.token))), XBridgeErrors.ORACLE_TOKEN_ADDRESS_ERR);

        // Calculate the high threshold based on the actualAmount and configured ratio
        uint256 ratio = sysRatio[XBridgeConstants.CLAIM_TOKEN_RATIO_MAX_INDEX];
        uint256 high = oracleInfo.actualAmount * (ratio + XBridgeConstants.DEFAULT_RATIO_BASE) / XBridgeConstants.DEFAULT_RATIO_BASE;

        // Check if the requested amount is within the allowed high threshold
        require(_amount <= high, XBridgeErrors.ORACLE_TOKEN_AMOUNT_ERR);
    }

    /**
     * @notice Internal function to process the claim for a swap request, including gas fee handling and token transfer.
     * @param _request The SwapRequest struct containing swap details.
     * @dev Verifies the oracle, handles gas fees, performs token swap or transfer and emits the Claimed event.
     */
    function _claimInternal(SwapRequest memory _request) internal {
        uint256 fromTokenOriginBalance = _getBalanceOf(_request.fromToken);

        // Calculate the total amount needed, including swap amount and gas fees
        uint256 fromTokenNeed = _request.amount + _request.gasFeeAmount;

        // Verify the oracle signature and threshold for the source token
        _verifyOracle(_request, fromTokenNeed);
        require(fromTokenOriginBalance >= fromTokenNeed, XBridgeErrors.NO_ENOUGH_MONEY);
        require(dexRouter != address(0), XBridgeErrors.ADDRESS_0);
        require(!paidTx[_request.srcChainId][_request.srcTxHash], XBridgeErrors.HAS_PAID);
        paidTx[_request.srcChainId][_request.srcTxHash] = true;

        // Initialize extension data for the Claimed event
        bytes32[] memory ext = new bytes32[](1);
        ext[0] = _request.srcTxHash;
        bool success;
        bytes memory result;
        string memory errInfo;

        // 1. Handle gas fee
        _transferToken(feeTo, _request.fromToken, _request.gasFeeAmount);

        // 2. Perform token swap or transfer to the user
        if (_request.dexData.length > 0) {
            // swap
            uint256 toTokenReceiverBalance = _getBalanceOf(_request.toToken, _request.to);

            // Exchange anypair using the dexRouter except WETH<=>ETH
            payer = address(this);
            receiver = _request.to;
            if (_request.fromToken == XBridgeConstants.NATIVE_TOKEN) { // FROM NATIVE
                if (_request.toToken == XBridgeConstants.WETH) { // ETH => WETH
                    success = _swapWrap(address(this), _request.to, _request.amount, false);
                    if (!success) {
                        errInfo = XBridgeErrors.INTERNAL_WRAP_FAIL;
                    }  
                } else { // ETH => ERC20, use dexRouter
                    (success, result) = dexRouter.call{value : _request.amount}(_request.dexData); 
                }
            } else { // FROM ERC20
                if (_request.fromToken == XBridgeConstants.WETH && _request.toToken == XBridgeConstants.NATIVE_TOKEN) {
                    // WETH => ETH
                    success =_swapWrap(address(this), _request.to, _request.amount, true);
                    if (!success) {
                        errInfo = XBridgeErrors.INTERNAL_WRAP_FAIL;
                    } 
                } else { // ERC20 => ERC20, use dexRouter
                    address tokenApprove = IApproveProxy(XBridgeConstants.APPROVE_PROXY).tokenApprove();
                    IERC20Upgradeable(_request.fromToken).safeApprove(tokenApprove, _request.amount);
                    (success, result) = dexRouter.call(_request.dexData);
                    if (IERC20Upgradeable(_request.fromToken).allowance(address(this), tokenApprove) != 0){
                        IERC20Upgradeable(_request.fromToken).safeApprove(tokenApprove, 0);  
                    }
                }
            }
            if (!success && result.length > 0) {
                errInfo = RevertReasonParser.parse(result, XBridgeErrors.DEX_ROUTER_ERR);
            }
            delete payer; // payer = 0;
            delete receiver;
            if (!success) { // transfer fromToken if swap failed
                _transferToken(_request.to, _request.fromToken, _request.amount);
                emit Claimed(_request.to, _request.fromToken, _request.toToken, _request.amount, 0, _request.gasFeeAmount, _request.srcChainId, errInfo, ext);
            } else {
                toTokenReceiverBalance = _getBalanceOf(_request.toToken, _request.to) - toTokenReceiverBalance;
                emit Claimed(_request.to, _request.fromToken, _request.toToken, 0, toTokenReceiverBalance, _request.gasFeeAmount, _request.srcChainId, errInfo, ext);
            }
        } else { // transfer token
            errInfo = XBridgeConstants.__REFUND__;
            _transferToken(_request.to, _request.fromToken, _request.amount);
            emit Claimed(_request.to, _request.fromToken, _request.toToken, _request.amount, 0, _request.gasFeeAmount, _request.srcChainId, errInfo, ext);
        }

        // 3. Check the final balance of the source token
        require(fromTokenOriginBalance - _getBalanceOf(_request.fromToken) <= fromTokenNeed, XBridgeErrors.SLASH_MUCH_TOO_MONEY);
    }

    /**
     * @dev Internal function to swap and wrap tokens.
     * @param from The address to transfer the tokens from.
     * @param to The address to transfer the wrapped tokens to.
     * @param amount The amount of tokens to swap and wrap.
     * @param reversed Boolean indicating whether the swap is reversed (WETH => ETH).
     * @return A boolean indicating the success of the swap and wrap operation.
     */
    function _swapWrap(
        address from,
        address to,
        uint256 amount,
        bool reversed
    ) internal returns (bool) {
        require(amount > 0,  XBridgeErrors.WRAP_AMOUNT_ZERO);
        if (reversed) {
            // reversed == true: WETH => ETH
            if (from == address(this)){
                IWETH(address(uint160(XBridgeConstants.WETH))).transfer(XBridgeConstants.WNATIVE_RELAY, amount);
            } else {
                _deposit(from, XBridgeConstants.WNATIVE_RELAY, XBridgeConstants.WETH, amount);
            }
            IWNativeRelayer(XBridgeConstants.WNATIVE_RELAY).withdraw(amount);
            if (to != address(this)){
                (bool success, ) = payable(to).call{value: amount}("");
                require(success, XBridgeErrors.TRANSFER_ETH_FAILD);
            }
        } else {
            // reversed == false: ETH => WETH
            IWETH(XBridgeConstants.WETH).deposit{value: amount}();
            if (to != address(this)){
                IERC20Upgradeable(XBridgeConstants.WETH).safeTransfer(to, amount);
            }
        }
        return true;
    }

    /**
     * @notice Internal function to handle commission logic
     * @param inputAmount The amount of tokens to be transferred.
     * @param commissionToken The address of the ERC20 token to be transferred.
     * @param extData Additional extension data containing user-specific information.
     * @return commissionAmount The amount of commission tokens to be transferred.
     * @return extDataWithoutLast32 Additional extension data containing user-specific information without last 32 bytes.
     */
    function _doCommission( uint256 inputAmount, address commissionToken, bytes memory extData) internal returns (uint256 commissionAmount, bytes memory extDataWithoutLast32) {
        
        // Retrieve commission info from the last 32 bytes of extData
        uint256 commissionInfo;
        assembly {
            commissionInfo := calldataload(sub(calldatasize(),0x20))
        }

        if ((commissionInfo & _COMMISSION_FLAG_MASK) == OKX_COMMISSION) {
            // 0. decode the commissionInfo
            address referrerAddress = address(uint160(commissionInfo & _REFERRER_MASK));
            uint256 commissionRate = uint256((commissionInfo & _COMMISSION_FEE_MASK) >> 160);

            // 1. Check the commission ratio. CommissionFeeAmount = fromTokenAmount * Rate / (10000 - Rate)
            require(commissionRate <= commissionRateLimit, XBridgeErrors.COMMISSION_ERROR_RATE);
            commissionAmount = (inputAmount * commissionRate) / (10000 - commissionRate);

            // 2. Perform commission
            if (commissionToken == XBridgeConstants.NATIVE_TOKEN) {
                (bool success,) = payable(referrerAddress).call{value: commissionAmount}("");
                require(success, XBridgeErrors.COMMISSION_ERROR_ETHER); 
            } else {
                _deposit(msg.sender, referrerAddress, commissionToken, commissionAmount);
            }

            // 3. Restore extData
            uint256 extDataSize = extData.length;
            extDataWithoutLast32 = new bytes(extDataSize - 32);
            for (uint256 i = 0; i < extDataSize - 32; i++) {
                extDataWithoutLast32[i] = extData[i];
            }

            emit CommissionRecord(commissionAmount, referrerAddress);
        } else {
            extDataWithoutLast32 = extData;
        }
    }

    //-------------------------------
    //------- Admin functions -------
    //-------------------------------

    function setAdmin(address _newAdmin) external onlyOwner {
        require(_newAdmin != address(0), XBridgeErrors.ADDRESS_0);
        admin = _newAdmin;
        emit AdminChanged(_newAdmin);
    }

    function setDexRouter(address _newDexRouter) external onlyAdmin {
        require(_newDexRouter != address(0), XBridgeErrors.ADDRESS_0);
        dexRouter = _newDexRouter;
        emit DexRouterChanged(_newDexRouter);
    }

    function pause() external onlyAdmin {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }

    function setAdaptors(uint256[] calldata _ids, address[] calldata _adaptors) external onlyAdmin {
        require(_ids.length == _adaptors.length, XBridgeErrors.LENGTH_NOT_EQUAL);
        for (uint256 i = 0; i < _ids.length; i++) {
            adaptorInfo[_ids[i]] = _adaptors[i];
            emit AdaptorsChanged(_ids[i], _adaptors[i]);
        }
    }

    function setFeeTo(address _newFeeTo) external onlyAdmin {
        require(_newFeeTo != address(0), XBridgeErrors.ADDRESS_0);
        feeTo = _newFeeTo;
        emit FeeToChanged(_newFeeTo);
    }

    function setMpc(address[] memory _mpcList, bool[] memory _v) external onlyAdmin {
        require(_mpcList.length == _v.length, XBridgeErrors.LENGTH_NOT_EQUAL);
        for (uint256 i = 0; i < _mpcList.length; i++) {
            mpc[_mpcList[i]] = _v[i];
            emit MpcChanged(_mpcList[i], _v[i]);
        }
    }

    function setSysRatio(uint256 _index, uint256 _v) external onlyAdmin {
        sysRatio[_index] = _v;
        emit SysRatioChanged(_index, _v);
    }

    function setProxies(address[] memory proxiesList, bool[] memory values)
        external
        onlyAdmin
    {
        require(proxiesList.length == values.length, XBridgeErrors.LENGTH_NOT_EQUAL);
        for (uint256 i = 0; i < proxiesList.length; i++) {
            proxies[proxiesList[i]] = values[i];
            emit ProxiesChanged(proxiesList[i], values[i]);
        }
    }

    function setAccessSelectorId(bytes4[] memory selectorIds, bool[] memory values) external onlyAdmin{
        require(selectorIds.length == values.length, XBridgeErrors.LENGTH_NOT_EQUAL);
        for (uint256 i = 0; i < selectorIds.length; i++) {
            accessSelectorId[selectorIds[i]] = values[i];
            emit AccessSelectorIdChanged(selectorIds[i], values[i]);
        }
    }

    //-------------------------------
    //------- Users Functions -------
    //-------------------------------

    /**
     * @notice Initiates the bridge operation to transfer assets to another chain using the bridge.
     * @param _request The BridgeRequestV2 struct containing the details of the bridge operation.
     */
    function bridgeToV2(BridgeRequestV2 memory _request)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        _bridgeToV2Internal(_request);
    }

    /**
     * @notice Initiates a swap and bridge operation using the bridge.
     * @param _request The SwapBridgeRequestV2 struct containing the details of the swap and bridge operation.
     */
    function swapBridgeToV2(SwapBridgeRequestV2 memory _request)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        _swapBridgeToInternal(_request);
    }

    /**
     * @notice Initiates a swap and bridge operation with permit using V2 of the bridge.
     * @param _request The SwapBridgeRequestV2 struct containing the details of the swap and bridge operation.
     * @param _signature The permit signature for the fromToken.
     */
    function swapBridgeToWithPermit(
        SwapBridgeRequestV2 calldata _request,
        bytes calldata _signature
    ) external nonReentrant whenNotPaused {
        _permit(_request.fromToken, _signature);
        _swapBridgeToInternal(_request);
    }

    /**
     * @notice Completed receiving gas tokens from the source chain.
     * @param _request The ReceiveGasRequest struct containing the details of this operation.
     */
    function receiveGasToken(ReceiveGasRequest memory _request)
        public
        payable
        nonReentrant
        whenNotPaused
        onlyMPC
    {
        require(msg.value == _request.amount, XBridgeErrors.INVALID_MSG_VALUE);
        _receiveGasTokenInternal(_request);
    }

    /**
     * @notice Claims the assets on the current chain as part of the cross-chain swap.
     * @param _request The SwapRequest struct containing details of the asset claiming operation.
     */
    function claim(SwapRequest memory _request)
        public
        nonReentrant
        whenNotPaused
        onlyMPC
    {
        _claimInternal(_request);
    }

    /**
     * @notice Performs batch operations including Gas Token receiving and asset claiming.
     * @param _gasRequest Array of ReceiveGasRequest structs containing details of Gas Token receiving operations.
     * @param _claimRequest Array of SwapRequest structs containing details of asset claiming operations.
     */
    function doBatch(ReceiveGasRequest[] memory _gasRequest, SwapRequest[] memory _claimRequest)
        public
        payable
        nonReentrant
        whenNotPaused
        onlyMPC
    {
        uint256 leftValue = msg.value;
        for (uint256 i = 0; i < _gasRequest.length; i++) {
            _receiveGasTokenInternal(_gasRequest[i]);
            // DOES NOT need check, because it will overflow if less than amount
            leftValue -= _gasRequest[i].amount;
        }
        for (uint256 i = 0; i < _claimRequest.length; i++) {
            _claimInternal(_claimRequest[i]);
        }
        require(leftValue == 0, XBridgeErrors.LEFT_VALUE_NOT_ZERO);
    }

    function payerReceiver() external view returns(address, address) {
        return (payer, receiver);
    }

    receive() external payable {}
}