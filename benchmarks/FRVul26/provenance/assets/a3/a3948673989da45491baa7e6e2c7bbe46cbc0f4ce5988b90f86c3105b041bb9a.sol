// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./DeBridgeRouterBase.sol";
import {IDlnDestination} from "./interfaces/IDlnDestination.sol";
import { ISanityCheckErrors } from "./interfaces/ISanityCheckErrors.sol";
import "./libraries/Permit.sol";
import "./libraries/SignatureUtil.sol";
import "./libraries/DlnDestinationCalldataLib.sol";

contract DeBridgeRouter is DeBridgeRouterBase, ISanityCheckErrors {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SignatureUtil for bytes;
    using DlnDestinationCalldataLib for bytes;
    
    /* ========== CONSTANTS ========== */

    uint256 public constant BPS_DENOMINATOR = 10_000;

    address public constant NATIVE_TOKEN = address(0);

    address private constant USDT_ON_TRON = address(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C);

    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address public immutable dlnDestination;

    address private _deBridgeGate; // deprecated since v3.1.0

    mapping(address => RouterConfig) public supportedRouters;

    address public feeTreasury;

    uint16 public swapVariableFeeBps;

    /* ========== Events ========== */

    event AffiliateFeePaid(
        address token,
        uint256 amount,
        address recipient,
        uint32 referralCode
    );
    event CollectedFee(address token, uint256 amount);
    event SameChainSwapExecuted(
        address sender, // the msg.sender of the swap
        address recipient, // the recipient of the swap outcome
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut,
        uint256 fee,
        uint256 affiliateFee,
        uint32 referralCode
    );
    event FeeTreasuryUpdated(address feeTreasury);
    event SwapVariableFeeBpsUpdated(uint16 swapVariableFeeBps);
    event SupportedRouter(address srcSwapRouter, bool isSupported);
    event SwapExecuted(
        address router,
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut
    );

    event Refund(address token, uint256 amount, address recipient);
    event AllowanceAggregatorUpdated(address router, address allowanceAggregator);

    /* ========== ERRORS ========== */

    error ExcessiveMsgValue(uint256 requiredAmount, uint256 providedAmount);
    error SwapToSameToken();

    error ZeroFeeTreasuryAddress();

    error SwapOutcomeTooLow(
        address tokenOut,
        uint256 amountOut,
        uint256 actualAmountOut,
        uint256 expectedAmountOut
    );

    // swap router didn't put target tokens on this (forwarder's) address
    error SwapEmptyResult(address srcTokenOut);

    error SwapFailed(address srcRouter);

    error NotEnoughSrcFundsIn(uint256 amount);
    error NotSupportedRouter();
    error CallFailed(address target, bytes data);
    error CallCausedBalanceDiscrepancy(
        address target,
        address token,
        uint256 expectedBalance,
        uint256 actualBalance
    );

    error InvalidAffiliateFeeDataLength(uint256 length);
    error InvalidAffiliateFeeData(uint16 bps, address recipient);

    error InvalidSwapVariableFeeBps();

    error ZeroDlnDestinationAddress();

    /* ========== STRUCTS ========== */

    struct RouterConfig {
        bool isSupported;
        address allowanceAggregator;
    }

    struct SameChainSwapDetails {
        /// @dev address of an aggregator to give approval (increase allowance) to for the swap
        ///      (if not zero, it will be used instead of the settings stored in this contract)
        address allowanceAggregator;
        /// @dev address of a router to call to swap token
        address swapRouter;
        /// @dev calldata for the router
        bytes swapCalldata;
        /// @dev address of an outcome token of a swap described in swapCalladata
        address tokenOut;
        /// @dev expected outcome of a swap
        uint256 tokenOutMinAmount;
        /// @dev surplus share in bps the the recipient will receive
        uint16 surplusShareBps;
        /// @dev optional affiliate fee envelope. bytes (uint16 bps + address recipient)
        bytes affiliateFeeEnvelope;
        /// @dev address of a recipient of the swap outcome
        ///      (if zero, the swap outcome will be sent to the caller)
        address recipient;
    }

    struct SwapDetails {
        /// @dev address of a router to call to swap token
        address swapRouter;
        /// @dev calldata for the router
        bytes swapCalldata;
        /// @dev address of an outcome token of a swap described in swapCalladata
        address tokenOut;
        /// @dev expected outcome of a swap
        uint256 tokenOutMinAmount;
        /// @dev remainder of swap outcome (which lefts after subtracting tokenOutMinAmount and tokenOutMaxExcessiveAmount
        ///         from the swap outcome)
        address tokenOutRefundRecipient;
    }

    /* ========== INITIALIZERS ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address _dlnDestination) {
        if (_dlnDestination == address(0)) revert ZeroDlnDestinationAddress();
        dlnDestination = _dlnDestination;
    }

    function initialize(
      address _feeTreasury,
      uint16 _swapVariableFeeBps
    ) external initializer {
        DeBridgeRouterBase._initializeBase();

        // order is important here:
        _setFeeTreasury(_feeTreasury);
        _setSwapVariableFeeBps(_swapVariableFeeBps);
    }


    /* ========== PUBLIC METHODS ========== */

    /// @dev Performs swap against arbitrary input token, extracts fees, and sends the outcome to the specified recipient
    /// @param _tokenIn arbitrary input token to swap from
    /// @param _amountIn amount of input token to swap
    /// @param _tokenInPermitEnvelope optional permit envelope to grab the token from the caller. bytes (amount + deadline + signature)
    /// @param _swapDetails details on how to deal with swap outcome
    /// @param _referralCode referral code to be passed to events
    /// @return actualAmountOut amount of tokens sent to the recipient
    function swap(
        address _tokenIn,
        uint256 _amountIn,
        bytes memory _tokenInPermitEnvelope,
        SameChainSwapDetails calldata _swapDetails,
        uint32 _referralCode
    ) external payable returns (
        uint256 actualAmountOut
    ) {
        if (msg.value != 0 && _tokenIn != NATIVE_TOKEN)
            revert ExcessiveMsgValue(0, msg.value);

        if (_tokenIn == _swapDetails.tokenOut)
            revert SwapToSameToken();

        _obtainSrcTokenIn(_tokenIn, _amountIn, _tokenInPermitEnvelope, true);

        (uint256 amountOut, ) = _performSwap(
            _tokenIn,
            _amountIn,
            msg.value,
            _swapDetails.swapRouter,
            _swapDetails.swapCalldata,
            _swapDetails.tokenOut,
            _swapDetails.allowanceAggregator
        );

        uint256 fee = (amountOut * swapVariableFeeBps) / BPS_DENOMINATOR;

        actualAmountOut = amountOut - fee;

        uint256 affiliateFee = _processAffiliateFee(
            _swapDetails.tokenOut,
            actualAmountOut,
            _swapDetails.affiliateFeeEnvelope,
            _referralCode
        );
        actualAmountOut -= affiliateFee;

        if (actualAmountOut < _swapDetails.tokenOutMinAmount) {
            revert SwapOutcomeTooLow(
                _swapDetails.tokenOut,
                amountOut,
                actualAmountOut,
                _swapDetails.tokenOutMinAmount
            );
        }

        {
            uint256 surplus = actualAmountOut - _swapDetails.tokenOutMinAmount;
            uint256 userSurplus = (surplus * _swapDetails.surplusShareBps) / BPS_DENOMINATOR;
            fee += surplus - userSurplus;
            actualAmountOut = _swapDetails.tokenOutMinAmount + userSurplus;
        }

        if (fee > 0) {
            address feeRecipient = feeTreasury;
            if (feeRecipient == address(0)) revert ZeroFeeTreasuryAddress();
            _safeTransferEthOrToken(_swapDetails.tokenOut, feeRecipient, fee);
            emit CollectedFee(_swapDetails.tokenOut, fee);
        }

        _finishSwap(
            _tokenIn,
            _amountIn,
            _swapDetails.tokenOut,
            amountOut,
            actualAmountOut,
            _swapDetails.recipient == address(0) ? msg.sender : _swapDetails.recipient,
            fee,
            affiliateFee,
            _referralCode
        );
    }

    /// @dev Performs a DLN fulfillment pre-swap, carrying excessive swap outcome into the fulfill amount
    ///      up to `_maxDlnFulfillAmount`. Any outcome above the cap is refunded.
    /// @param _tokenIn arbitrary input token to swap from
    /// @param _amountIn amount of input token to swap
    /// @param _swapDetails details on how to deal with swap outcome
    /// @param _dlnDestinationCalldata calldata to call against dlnDestination
    /// @param _maxDlnFulfillAmount maximum amount of swap outcome to pass as DLN fulfill amount
    function fillCrossChain(
        address _tokenIn,
        uint256 _amountIn,
        SwapDetails calldata _swapDetails,
        bytes calldata _dlnDestinationCalldata,
        uint256 _maxDlnFulfillAmount
    ) external payable {
        _dlnDestinationCalldata.validateFunctionSelector();
        
        uint256 originalDlnFulfillAmount = _dlnDestinationCalldata.getFulfillAmount();
        uint256 orderTakeAmount = _dlnDestinationCalldata.getOrderTakeAmount();

        if (_maxDlnFulfillAmount < orderTakeAmount) {
            revert ISanityCheckErrors.WrongArgument();
        }

        _ensureOrderNotFulfilledOrCanceled(
            dlnDestination,
            _dlnDestinationCalldata.getOrderId()
        );

        // Pull the _tokenIn from msg.sender
        _obtainSrcTokenIn(_tokenIn, _amountIn, bytes(""), false);

        // Swap tokenIn to tokenOut
        (
            uint256 amountOut,
            uint256 msgValueAfterSwap
        ) = _performSwap(
            _tokenIn,
            _amountIn,
            msg.value,
            _swapDetails.swapRouter,
            _swapDetails.swapCalldata,
            _swapDetails.tokenOut,
            address(0) // No allowance aggregator for DLN fill
        );

        if (amountOut < _swapDetails.tokenOutMinAmount) {
            // swap returned less than expected - revert the whole txn
            revert NotEnoughSrcFundsIn(_swapDetails.tokenOutMinAmount);
        }

        if (amountOut < orderTakeAmount) {
            revert NotEnoughSrcFundsIn(orderTakeAmount);
        }

        uint256 dlnFulfillAmount = amountOut;
        if (amountOut > _maxDlnFulfillAmount) {
            msgValueAfterSwap = _refund(
                _swapDetails.tokenOut,
                amountOut - _maxDlnFulfillAmount,
                _swapDetails.tokenOutRefundRecipient,
                msgValueAfterSwap
            );
            dlnFulfillAmount = _maxDlnFulfillAmount;
        }

        if (dlnFulfillAmount != originalDlnFulfillAmount) {
            _performTargetCallWithMemoryData(
                dlnDestination,
                _dlnDestinationCalldata.patchCalldataFulfillAmount(
                    dlnFulfillAmount
                ),
                _dlnDestinationCalldata, // Not used
                msgValueAfterSwap,
                _swapDetails.tokenOut,
                dlnFulfillAmount,
                orderTakeAmount // Allow rebasing rounding, but require at least order.takeAmount spent.
            );
        } else {
            _performTargetCall(
                dlnDestination,
                _dlnDestinationCalldata,
                msgValueAfterSwap,
                _swapDetails.tokenOut,
                originalDlnFulfillAmount,
                orderTakeAmount // Allow rebasing rounding, but require at least order.takeAmount spent.
            );
        }
    }

    /// @dev Performs swap against arbitrary input token, refunds excessive outcome of such swap (if any),
    ///      and calls the specified receiver supplying the outcome of the swap
    /// @param _srcTokenIn arbitrary input token to swap from
    /// @param _srcAmountIn amount of input token to swap
    /// @param _srcTokenInPermitEnvelope optional permit envelope to grab the token from the caller. bytes (amount + deadline + signature)
    /// @param _swapDetails details on how to deal with swap outcome
    /// @param _target DLN contract to call after successful swap
    /// @param _targetData calldata to call against _target
    /// @param _orderId Id of an order to be fulfilled
    function strictlySwapAndCallDln(
        address _srcTokenIn,
        uint256 _srcAmountIn,
        bytes memory _srcTokenInPermitEnvelope,
        SwapDetails calldata _swapDetails,
        address _target,
        bytes calldata _targetData,
        bytes32 _orderId
    ) external payable {
        _ensureOrderNotFulfilledOrCanceled(_target, _orderId);

        _strictlySwapAndCall(
            _srcTokenIn,
            _srcAmountIn,
            _srcTokenInPermitEnvelope,
            _swapDetails.swapRouter,
            _swapDetails.swapCalldata,
            _swapDetails.tokenOut,
            _swapDetails.tokenOutMinAmount,
            _swapDetails.tokenOutRefundRecipient,
            _target,
            _targetData
        );
    }

    /// @dev Performs swap against arbitrary input token, refunds excessive outcome of such swap (if any),
    ///      and calls the specified receiver supplying the outcome of the swap
    /// @param _srcTokenIn arbitrary input token to swap from
    /// @param _srcAmountIn amount of input token to swap
    /// @param _srcTokenInPermitEnvelope optional permit envelope to grab the token from the caller. bytes (amount + deadline + signature)
    /// @param _srcSwapRouter contract to call that performs swap from the input token to the output token
    /// @param _srcSwapCalldata calldata to call against _srcSwapRouter
    /// @param _srcTokenOut arbitrary output token to swap to
    /// @param _srcTokenExpectedAmountOut minimum acceptable outcome of the swap to provide to _target
    /// @param _srcTokenRefundRecipient address to send excessive outcome of the swap
    /// @param _target contract to call after successful swap
    /// @param _targetData calldata to call against _target
    function strictlySwapAndCall(
        address _srcTokenIn,
        uint256 _srcAmountIn,
        bytes memory _srcTokenInPermitEnvelope,
        address _srcSwapRouter,
        bytes calldata _srcSwapCalldata,
        address _srcTokenOut,
        uint256 _srcTokenExpectedAmountOut,
        address _srcTokenRefundRecipient,
        address _target,
        bytes calldata _targetData
    ) external payable {
        _strictlySwapAndCall(
            _srcTokenIn,
            _srcAmountIn,
            _srcTokenInPermitEnvelope,
            _srcSwapRouter,
            _srcSwapCalldata,
            _srcTokenOut,
            _srcTokenExpectedAmountOut,
            _srcTokenRefundRecipient,
            _target,
            _targetData
        );
    }

    function simulateSwap(
        address _srcTokenIn,
        uint256 _srcAmountIn,
        address _srcSwapRouter,
        bytes calldata _srcSwapCalldata,
        address _srcTokenOut
    ) external payable returns (
        uint256 srcAmountOut
    ) {
        _obtainSrcTokenIn(_srcTokenIn, _srcAmountIn, "", false);

        (srcAmountOut, ) = _performSwap(
            _srcTokenIn,
            _srcAmountIn,
            msg.value,
            _srcSwapRouter,
            _srcSwapCalldata,
            _srcTokenOut,
            address(0) // No allowance aggregator for simulation
        );
    }

    /* ========== INTERNAL METHODS ========== */

    function _finishSwap(
      address _tokenIn,
      uint256 _amountIn,
      address _tokenOut,
      uint256 amountOut,
      uint256 _actualAmountOut,
      address _actualRecipient,
      uint256 fee,
      uint256 affiliateFee,
      uint32 _referralCode
    ) internal {
        _safeTransferEthOrToken(_tokenOut, _actualRecipient, _actualAmountOut);

        emit SameChainSwapExecuted(
            msg.sender,
            _actualRecipient,
            _tokenIn,
            _amountIn,
            _tokenOut,
            amountOut,
            fee,
            affiliateFee,
            _referralCode
        );
    }

    function _ensureOrderNotFulfilledOrCanceled(
        address _dlnDestination,
        bytes32 _orderId
    ) internal view {
        // check order status as early as possible to safe gas: DLN market is highly concurrent, and txns attempting
        // to fulfill the same order may occur in the same block
        // _dlnDestination is checked later when invoking _callCustom()
        (
            uint8 status /*address takerAddress*/ /*uint256 giveChainId*/,
            ,

        ) = IDlnDestination(_dlnDestination).takeOrders(_orderId);
        // use require() instead of custom error because string error gives more clarity:
        // it is shown on Etherscan as well as on Tenderly
        require(status == 0, "ORDER_FULFILLED_OR_CANCELLED");
    }

    function _strictlySwapAndCall(
        address _srcTokenIn,
        uint256 _srcAmountIn,
        bytes memory _srcTokenInPermitEnvelope,
        address _srcSwapRouter,
        bytes calldata _srcSwapCalldata,
        address _srcTokenOut,
        uint256 _srcTokenExpectedAmountOut,
        address _srcTokenRefundRecipient,
        address _target,
        bytes calldata _targetData
    ) internal {
        //
        // pull the srcInToken from msg.sender
        //

        _obtainSrcTokenIn(
          _srcTokenIn, _srcAmountIn, _srcTokenInPermitEnvelope, false
        );

        //
        // swap srcInToken to srcOutToken
        //
        (uint256 srcAmountOut, uint256 msgValueAfterSwap) = _performSwap(
            _srcTokenIn,
            _srcAmountIn,
            msg.value,
            _srcSwapRouter,
            _srcSwapCalldata,
            _srcTokenOut,
            address(0) // No allowance aggregator for strictly swap and call
        );

        //
        // refund excessive srcTokenOut
        //
        if (_srcTokenExpectedAmountOut > srcAmountOut) {
            // swap returned less than expected - revert the whole txn
            revert NotEnoughSrcFundsIn(_srcTokenExpectedAmountOut);
        } else if (_srcTokenExpectedAmountOut < srcAmountOut) {
            // swap returned more than expected - refund
            msgValueAfterSwap = _refund(
                _srcTokenOut,
                srcAmountOut - _srcTokenExpectedAmountOut,
                _srcTokenRefundRecipient,
                msgValueAfterSwap
            );
        }

        //
        // do the target call
        //
        _performTargetCall(
            _target,
            _targetData,
            msgValueAfterSwap,
            _srcTokenOut,
            _srcTokenExpectedAmountOut,
            _srcTokenExpectedAmountOut
        );
    }

    function _refund(
        address _tokenOut,
        uint256 _refundAmount,
        address _tokenRefundRecipient,
        uint256 _msgValueAfterSwap
    ) internal returns (uint256 updatedMsgValueAfterSwap) {
        if (_tokenOut == NATIVE_TOKEN) {
            _safeTransferETH(_tokenRefundRecipient, _refundAmount);
            _msgValueAfterSwap -= _refundAmount;
        } else {
            _safeTransferEthOrToken(
                _tokenOut,
                _tokenRefundRecipient,
                _refundAmount
            );
        }

        emit Refund(_tokenOut, _refundAmount, _tokenRefundRecipient);

        return _msgValueAfterSwap;
    }

    function _performTargetCall(
        address _target,
        bytes calldata _targetData,
        uint256 _targetValue,
        address _srcTokenOut,
        uint256 _srcAmountOut,
        uint256 _minSrcAmountOut
    ) internal {
        _performTargetCall(
            _target,
            false,
            bytes(""),
            _targetData,
            _targetValue,
            _srcTokenOut,
            _srcAmountOut,
            _minSrcAmountOut
        );
    }

    function _performTargetCallWithMemoryData(
        address _target,
        bytes memory _targetData,
        bytes calldata _targetDataFallback,
        uint256 _targetValue,
        address _srcTokenOut,
        uint256 _srcAmountOut,
        uint256 _minSrcAmountOut
    ) internal {
        _performTargetCall(
            _target,
            true,
            _targetData,
            _targetDataFallback,
            _targetValue,
            _srcTokenOut,
            _srcAmountOut,
            _minSrcAmountOut
        );
    }

    function _performTargetCall(
        address _target,
        bool _useMemoryTargetData,
        bytes memory _targetDataMemory,
        bytes calldata _targetData,
        uint256 _targetValue,
        address _srcTokenOut,
        uint256 _srcAmountOut,
        uint256 _minSrcAmountOut
    ) internal {
        // we check both native and erc-20 balance before the call
        // For sure, we can use only one call of _getBalance, but we still must be
        // sure that native currency has the correct accounting after the call
        // where erc-20 was used
        uint256 tokenBalanceBeforeCall = _getBalance(_srcTokenOut);
        uint256 balanceBeforeCall = _getBalance(address(0));

        // do the call
        if (_srcTokenOut != NATIVE_TOKEN) {
            _lazyApprove(_srcTokenOut, _target, address(0), _srcAmountOut);
        }

        _callCustom(
            _target,
            _useMemoryTargetData,
            _targetDataMemory,
            _targetData,
            _targetValue
        );

        // check balances
        uint256 tokenBalanceAfterCall = _getBalance(_srcTokenOut);
        uint256 balanceAfterCall = _getBalance(address(0));

        // ensure _target has pulled enough tokens from this contract
        if ((tokenBalanceBeforeCall - tokenBalanceAfterCall) < _minSrcAmountOut) {
            revert CallCausedBalanceDiscrepancy(
                _target,
                _srcTokenOut,
                tokenBalanceBeforeCall - _minSrcAmountOut,
                tokenBalanceBeforeCall - tokenBalanceAfterCall
            );
        }

        if ((balanceBeforeCall - balanceAfterCall) < _targetValue) {
            revert CallCausedBalanceDiscrepancy(
                _target,
                address(0),
                tokenBalanceBeforeCall - _targetValue,
                balanceBeforeCall - balanceAfterCall
            );
        }
    }

    function _getBalance(address _token) internal view returns (uint256) {
        if (_token == NATIVE_TOKEN) {
            return payable(this).balance;
        } else {
            return IERC20Upgradeable(_token).balanceOf(address(this));
        }
    }

    function _obtainSrcTokenIn(
        address _srcTokenIn,
        uint256 _srcAmountIn,
        bytes memory _srcTokenInPermitEnvelope,
        bool _strictMsgValueCheck
    ) internal {
        if (_srcTokenIn == NATIVE_TOKEN) {

            if (msg.value < _srcAmountIn) {
                revert NotEnoughSrcFundsIn(_srcAmountIn);
            }

            if (_strictMsgValueCheck && msg.value > _srcAmountIn) {
                revert ExcessiveMsgValue(_srcAmountIn, msg.value);
            }
        } else {
            uint256 srcAmountCleared = _collectSrcERC20In(
                IERC20Upgradeable(_srcTokenIn),
                _srcAmountIn,
                _srcTokenInPermitEnvelope
            );

            if (srcAmountCleared < _srcAmountIn)
                revert NotEnoughSrcFundsIn(_srcAmountIn);
        }
    }

    function _performSwap(
        address _srcTokenIn,
        uint256 _srcAmountIn,
        uint256 _msgValue,
        address _srcSwapRouter,
        bytes calldata _srcSwapCalldata,
        address _srcTokenOut,
        address _allowanceAggregator
    ) internal returns (uint256 srcAmountOut, uint256 msgValueAfterSwap) {
        uint256 ethBalanceBefore = address(this).balance - _msgValue;

        if (_srcTokenIn == NATIVE_TOKEN) {
            srcAmountOut = _swapToERC20Via(
                _srcSwapRouter,
                _srcSwapCalldata,
                _srcAmountIn,
                IERC20Upgradeable(_srcTokenOut)
            );
        } else {
            _lazyApprove(_srcTokenIn, _srcSwapRouter, _allowanceAggregator, _srcAmountIn);
            if (_srcTokenOut == NATIVE_TOKEN) {
                srcAmountOut = _swapToETHVia(_srcSwapRouter, _srcSwapCalldata);
            } else {
                srcAmountOut = _swapToERC20Via(
                    _srcSwapRouter,
                    _srcSwapCalldata,
                    0 /*value*/,
                    IERC20Upgradeable(_srcTokenOut)
                );
            }
        }

        emit SwapExecuted(
            _srcSwapRouter,
            _srcTokenIn,
            _srcAmountIn,
            _srcTokenOut,
            srcAmountOut
        );

        msgValueAfterSwap = address(this).balance - ethBalanceBefore;
    }

    function _collectSrcERC20In(
        IERC20Upgradeable _token,
        uint256 _amount,
        bytes memory _permitEnvelope
    ) internal returns (uint256) {
        uint256 balanceBefore = _token.balanceOf(address(this));

        Permit.executePermit(address(_token), _permitEnvelope);
        _token.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 balanceAfter = _token.balanceOf(address(this));

        if (!(balanceAfter > balanceBefore))
            revert NotEnoughSrcFundsIn(_amount);

        return (balanceAfter - balanceBefore);
    }

    function _swapToETHVia(
        address _router,
        bytes calldata _calldata
    ) internal returns (uint256) {
        uint256 balanceBefore = address(this).balance;

        _callCustom(_router, _calldata, 0);

        uint256 balanceAfter = address(this).balance;

        if (balanceBefore >= balanceAfter) revert SwapEmptyResult(address(0));

        uint256 swapDstTokenBalance = balanceAfter - balanceBefore;
        return swapDstTokenBalance;
    }

    function _swapToERC20Via(
        address _router,
        bytes calldata _calldata,
        uint256 _msgValue,
        IERC20Upgradeable _targetToken
    ) internal returns (uint256) {
        uint256 balanceBefore = _targetToken.balanceOf(address(this));

        _callCustom(_router, _calldata, _msgValue);

        uint256 balanceAfter = _targetToken.balanceOf(address(this));

        if (balanceBefore >= balanceAfter)
            revert SwapEmptyResult(address(_targetToken));

        uint256 swapDstTokenBalance = balanceAfter - balanceBefore;
        return swapDstTokenBalance;
    }

    function _lazyApprove(
        address _tokenAddress,
        address _swapRouter,
        address _allowanceAggregator,
        uint256 _amount
    ) internal {
        IERC20Upgradeable token = IERC20Upgradeable(_tokenAddress);
        address approvalTarget = _swapRouter;
        if (_allowanceAggregator != address(0)) {
            if (!supportedRouters[_allowanceAggregator].isSupported) revert NotSupportedRouter();
            approvalTarget = _allowanceAggregator;
        } else {
            // check if there's a stored allowanceAggregator for this router
            address storedAggregator = supportedRouters[_swapRouter].allowanceAggregator;
            if (storedAggregator != address(0)) {
                approvalTarget = storedAggregator;
            }
        }
        uint256 currentAllowance = token.allowance(address(this), approvalTarget);

        if (currentAllowance < _amount) {
            // if an approval was issued before
            token.safeApprove(approvalTarget, 0);
            // create permanent approve
            token.safeApprove(approvalTarget, type(uint256).max);
        }
    }

    function _callCustom(
        address _to,
        bytes calldata _data,
        uint256 _msgValue
    ) internal {
        _callCustom(
            _to,
            false,
            bytes(""),
            _data,
            _msgValue
        );
    }

    function _callCustom(
        address _to,
        bool _useMemoryCalldata,
        bytes memory _calldataMemory,
        bytes calldata _calldata,
        uint256 _msgValue
    ) internal {
        if (
            _to != dlnDestination &&
            !supportedRouters[_to].isSupported
        ) {
            revert NotSupportedRouter();
        }

        (bool success, bytes memory returnData) = _to.call{value: _msgValue}(
            _useMemoryCalldata ? _calldataMemory : _calldata
        );

        if (!success) {
            revert CallFailed(_to, returnData);
        }
    }

    function _processAffiliateFee(
        address _token,
        uint256 _totalAmount,
        bytes calldata _affiliateFeeEnvelope,
        uint32 _referralCode
    ) internal returns (uint256 affiliateFee) {
        (uint16 affiliateFeeBps, address affiliateFeeRecipient)
            = _unpackAndValidateAffiliateFee(_affiliateFeeEnvelope);

        if (affiliateFeeBps == 0) return 0;

        affiliateFee = (_totalAmount * affiliateFeeBps) / BPS_DENOMINATOR;

        _safeTransferEthOrToken(
            _token,
            affiliateFeeRecipient,
            affiliateFee
        );

        emit AffiliateFeePaid(
            _token,
            affiliateFee,
            affiliateFeeRecipient,
            _referralCode
        );
    }

    function _unpackAndValidateAffiliateFee(
        bytes calldata _data
    ) internal pure returns (uint16 bps, address recipient) {
        if (_data.length == 0)
            return (0, address(0));

        if (_data.length != 22)
            revert InvalidAffiliateFeeDataLength(_data.length);

        bps = uint16(bytes2(_data[:2]));
        recipient = address(bytes20(_data[2:22]));

        if (bps > BPS_DENOMINATOR || (bps != 0 && recipient == address(0)))
            revert InvalidAffiliateFeeData(bps, recipient);
    }

    // ============ ADM ============

    function updateFeeTreasury(address _feeTreasury) external onlyAdmin {
        _setFeeTreasury(_feeTreasury);
    }

    function _setFeeTreasury(address _feeTreasury) internal {
        if (_feeTreasury == address(0)) revert ZeroFeeTreasuryAddress();
        feeTreasury = _feeTreasury;
        emit FeeTreasuryUpdated(_feeTreasury);
    }

    function updateSwapVariableFeeBps(
      uint16 _swapVariableFeeBps
    ) external onlyAdmin {
        _setSwapVariableFeeBps(_swapVariableFeeBps);
    }

    function _setSwapVariableFeeBps(uint16 _swapVariableFeeBps) internal {
        if (_swapVariableFeeBps > BPS_DENOMINATOR)
            revert InvalidSwapVariableFeeBps();

        if (_swapVariableFeeBps > 0 && feeTreasury == address(0))
            revert ZeroFeeTreasuryAddress();

        swapVariableFeeBps = _swapVariableFeeBps;
        emit SwapVariableFeeBpsUpdated(_swapVariableFeeBps);
    }

    function updateSupportedRouter(
        address _srcSwapRouter,
        bool _isSupported
    ) external onlyAdmin {
        supportedRouters[_srcSwapRouter].isSupported = _isSupported;
        emit SupportedRouter(_srcSwapRouter, _isSupported);
    }

    function updateAllowanceAggregator(
        address _router,
        address _allowanceAggregator
    ) external onlyAdmin {
        // If setting allowanceAggregator, ensure it's a supported router
        if (!supportedRouters[_allowanceAggregator].isSupported) {
            revert NotSupportedRouter();
        }
        supportedRouters[_router].allowanceAggregator = _allowanceAggregator;
        emit AllowanceAggregatorUpdated(_router, _allowanceAggregator);
    }

    function rescueFunds(
        address token,
        address recipient,
        uint256 amount
    ) external onlyAdmin {
        _safeTransferEthOrToken(token, recipient, amount);
    }

    function _safeTransferEthOrToken(
        address tokenAddress,
        address to,
        uint256 value
    ) private {
        if (value > 0) {
            if (tokenAddress == NATIVE_TOKEN) {
                _safeTransferETH(to, value);
            } else {
                // The return value of transfer is intentionally ignored here because USDT's implementation
                // is known to deviate from the standard ERC20 pattern. This is a temporary workaround.
                // TODO: Replace this hack with a proper SafeERC20 alternative once integrated.
                if (tokenAddress == USDT_ON_TRON)
                    IERC20Upgradeable(tokenAddress).transfer(to, value); // special case for USDT
                else
                    IERC20Upgradeable(tokenAddress).safeTransfer(to, value);
            }
        }
    }
    
    function _max(uint256 a, uint256 b) private pure returns (uint256) {
        return a > b ? a : b;
    }

    // ============ Version Control ============

    /// @dev Get this contract's version
    function version() external pure returns (uint256) {
        return 320; // 3.2.0
    }
}
