// Sources retrieved from Blockscout Ethereum API v2.

// ===== contracts/DeBridgeRouter.sol =====
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


// ===== @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// ===== contracts/DeBridgeRouterBase.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract DeBridgeRouterBase is Initializable, AccessControlUpgradeable {
    /* ========== ERRORS ========== */

    error EthTransferFailed();
    error AdminBadRole();

    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    /* ========== INITIALIZERS ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _initializeBase() internal initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /*
     * @dev transfer ETH to an address, revert if it fails.
     * @param to recipient of the transfer
     * @param value the amount to send
     */
    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) revert EthTransferFailed();
    }

    receive() external payable {}
}


// ===== contracts/libraries/SignatureUtil.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library SignatureUtil {
    /* ========== ERRORS ========== */

    error WrongArgumentLength();
    error SignatureInvalidLength();
    error SignatureInvalidV();

    /// @dev Prepares raw msg that was signed by the oracle.
    /// @param _submissionId Submission identifier.
    function getUnsignedMsg(
        bytes32 _submissionId
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _submissionId
                )
            );
    }

    /// @dev Splits signature bytes to r,s,v components.
    /// @param _signature Signature bytes in format r+s+v.
    function splitSignature(
        bytes memory _signature
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        if (_signature.length != 65) revert SignatureInvalidLength();
        return parseSignature(_signature, 0);
    }

    function parseSignature(
        bytes memory _signatures,
        uint256 offset
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        assembly {
            r := mload(add(_signatures, add(32, offset)))
            s := mload(add(_signatures, add(64, offset)))
            v := and(mload(add(_signatures, add(65, offset))), 0xff)
        }

        if (v < 27) v += 27;
        if (v != 27 && v != 28) revert SignatureInvalidV();
    }

    function toUint256(
        bytes memory _bytes,
        uint256 _offset
    ) internal pure returns (uint256 result) {
        if (_bytes.length < _offset + 32) revert WrongArgumentLength();

        assembly {
            result := mload(add(add(_bytes, 0x20), _offset))
        }
    }
}


// ===== @openzeppelin/contracts/utils/cryptography/EIP712.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

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
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}


// ===== @openzeppelin/contracts/utils/Address.sol =====
// SPDX-License-Identifier: MIT
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


// ===== @openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.0;

import "../ERC1967/ERC1967Proxy.sol";

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}


// ===== @openzeppelin/contracts/utils/cryptography/ECDSA.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

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


// ===== @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// ===== @openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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


// ===== contracts/mock/DummyDlnDestinationCalldataLib.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {ISanityCheckErrors} from "../interfaces/ISanityCheckErrors.sol";
import {DlnDestinationCalldataLib} from "../libraries/DlnDestinationCalldataLib.sol";

contract DummyDlnDestinationCalldataLib is ISanityCheckErrors {
    bytes4 public constant FULFILL_ORDER_FUNCTION_SELECTOR_1 =
        DlnDestinationCalldataLib.FULFILL_ORDER_FUNCTION_SELECTOR_1;

    bytes4 public constant FULFILL_ORDER_FUNCTION_SELECTOR_2 =
        DlnDestinationCalldataLib.FULFILL_ORDER_FUNCTION_SELECTOR_2;

    uint256 public constant ORDER_ARG_CALLDATA_OFFSET =
        DlnDestinationCalldataLib.ORDER_ARG_CALLDATA_OFFSET;

    uint256 public constant FULFILL_AMOUNT_CALLDATA_OFFSET =
        DlnDestinationCalldataLib.FULFILL_AMOUNT_CALLDATA_OFFSET;

    uint256 public constant FULFILL_AMOUNT_CALLDATA_MIN_SIZE =
        DlnDestinationCalldataLib.FULFILL_AMOUNT_CALLDATA_MIN_SIZE;

    uint256 public constant ORDER_ID_CALLDATA_OFFSET =
        DlnDestinationCalldataLib.ORDER_ID_CALLDATA_OFFSET;

    uint256 public constant ORDER_ID_CALLDATA_MIN_SIZE =
        DlnDestinationCalldataLib.ORDER_ID_CALLDATA_MIN_SIZE;

    uint256 public constant ORDER_OFFSET_OVERLOAD_1 =
        DlnDestinationCalldataLib.ORDER_OFFSET_OVERLOAD_1;

    uint256 public constant ORDER_OFFSET_OVERLOAD_2 =
        DlnDestinationCalldataLib.ORDER_OFFSET_OVERLOAD_2;

    uint256 public constant ORDER_TAKE_AMOUNT_TUPLE_OFFSET =
        DlnDestinationCalldataLib.ORDER_TAKE_AMOUNT_TUPLE_OFFSET;

    function validateFunctionSelector(bytes calldata _calldata) external pure {
        DlnDestinationCalldataLib.validateFunctionSelector(_calldata);
    }

    function getOrderId(
        bytes calldata _calldata
    ) external pure returns (bytes32 orderId) {
        return DlnDestinationCalldataLib.getOrderId(_calldata);
    }

    function getFulfillAmount(
        bytes calldata _calldata
    ) external pure returns (uint256 fulfillAmount) {
        return DlnDestinationCalldataLib.getFulfillAmount(_calldata);
    }

    function getOrderTakeAmount(
        bytes calldata _calldata
    ) external pure returns (uint256 orderTakeAmount) {
        return DlnDestinationCalldataLib.getOrderTakeAmount(_calldata);
    }

    function patchCalldataFulfillAmount(
        bytes calldata _calldata,
        uint256 _newFulfillAmount
    ) external pure returns (bytes memory patchedCalldata) {
        return DlnDestinationCalldataLib.patchCalldataFulfillAmount(
            _calldata, _newFulfillAmount
        );
    }
}


// ===== @openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// ===== contracts/mock/DummyToken.sol =====
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract DummyToken is ERC20, ERC20Permit {
    uint8 _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}


// ===== contracts/downscaled-token/DownscaledToken.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {ERC20Utils} from "./../libraries/ERC20Utils.sol";

contract DownscaledToken is ERC20 {
    using SafeERC20 for IERC20;
    using ERC20Utils for IERC20;
    using SafeCast for uint;

    error WrongArgument();

    uint8 public decimalsDifference; // Difference between original and new decimals
    uint8 public downscaledDecimals;
    IERC20 public token;

    /* ========== INITIALIZERS ========== */

    constructor(
        address token_,
        uint8 downscaledDecimals_
    ) ERC20(ERC20(token_).name(), ERC20(token_).symbol()) {
        token = IERC20(token_);
        uint8 tokenDecimals = ERC20(token_).decimals();
        if (!(downscaledDecimals_ < tokenDecimals)) {
            revert WrongArgument();
        }
        // require(downscaledDecimals_ < tokenDecimals, WrongArgument());

        downscaledDecimals = downscaledDecimals_;
        decimalsDifference = tokenDecimals - downscaledDecimals_;
    }

    // Override decimals to return the wrapped token's decimals
    function decimals() public view virtual override returns (uint8) {
        return downscaledDecimals;
    }

    function wrap(uint256 amount_) external returns (uint64) {
        return _wrap(amount_, msg.sender);
    }

    function adjustAmount(uint256 amount_) public view returns (uint256) {
        // Adjust _amount to be divisible by 10 ** decimalsDifference
        return amount_ - (amount_ % (10 ** decimalsDifference));
    }

    function downscaleAmount(uint256 amount_) public view returns (uint64) {
        return (amount_ / (10 ** decimalsDifference)).toUint64();
    }

    // Deposit original tokens and receive wrapped tokens
    function _wrap(
        uint256 amount_,
        address to_
    ) internal returns (uint64 wrappedAmount) {
        // Adjust _amount so we pull only what is going to be wrapped (avoiding dust)
        uint256 adjustedAmount = adjustAmount(amount_);

        token.safePull(adjustedAmount);

        // Calculate equivalent wrapped amount with reduced decimals
        wrappedAmount = downscaleAmount(adjustedAmount);

        // Mint wrapped tokens to the sender
        _mint(to_, wrappedAmount);
    }

    function unwrapBalanceTo(address to_) external returns (uint256) {
        return _unwrap(balanceOf(msg.sender).toUint64(), to_);
    }

    function unwrap(uint64 wrappedAmount_) external returns (uint256) {
        return _unwrap(wrappedAmount_, msg.sender);
    }

    function unwrap(
        uint64 wrappedAmount_,
        address to_
    ) external returns (uint256) {
        return _unwrap(wrappedAmount_, to_);
    }

    // Redeem wrapped tokens and get back original tokens
    function _unwrap(
        uint64 wrappedAmount_,
        address to_
    ) internal returns (uint256 originalAmount) {
        // Calculate equivalent original amount to redeem
        originalAmount = wrappedAmount_ * (10 ** decimalsDifference);

        // Burn wrapped tokens from sender
        _burn(msg.sender, wrappedAmount_);

        // Transfer original tokens back to the sender
        token.safeTransfer(to_, originalAmount);
    }

    function version() external pure returns (string memory) {
        return "1.0.0";
    }
}


// ===== contracts/mock/DummyPremintedToken.sol =====
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DummyPremintedToken is ERC20 {
    uint8 _decimals;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, type(uint256).max);
    }
}


// ===== contracts/mock/DummyAllowanceHolder.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

contract DummyAllowanceHolder {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Event emitted when tokens are pulled from a spender
    event TokensPulled(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    // Pull tokens from a spender to a recipient
    function pullTokens(
        address token,
        address from,
        address to,
        uint256 amount
    ) external {
        // Pull tokens from the spender
        IERC20Upgradeable(token).safeTransferFrom(from, to, amount);
        
        emit TokensPulled(token, from, to, amount);
    }

    // Helper function to check allowance
    function checkAllowance(
        address token,
        address owner
    ) external view returns (uint256) {
        return IERC20Upgradeable(token).allowance(owner, address(this));
    }
} 

// ===== @openzeppelin/contracts/utils/math/SafeCast.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


// ===== contracts/mock/libraries/DlnOrderLib.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library DlnOrderLib {
    /* ========== CONSTANTS ========== */

    uint256 public constant MAX_ADDRESS_LENGTH = 255;
    uint256 public constant EVM_ADDRESS_LENGTH = 20;
    uint256 public constant SOLANA_ADDRESS_LENGTH = 32;

    /* ========== ERRORS ========== */

    error WrongExternalCallHash();
    error WrongAddressLength();

    /* ========== ENUMS ========== */

    /**
     * @dev Enum defining the supported blockchain engines.
     * - `UNDEFINED`: Represents an undefined or unknown blockchain engine (0).
     * - `EVM`: Represents the Ethereum Virtual Machine (EVM) blockchain engine (1).
     * - `SOLANA`: Represents the Solana blockchain engine (2).
     */
    enum ChainEngine {
        UNDEFINED, // 0
        EVM, // 1
        SOLANA // 2
    }

    /* ========== STRUCTS ========== */

    /// @dev Struct representing the creation parameters for creating an order on the (EVM) chain.
    struct OrderCreation {
        /// Address of the ERC-20 token that the maker is offering as part of this order.
        /// Use the zero address to indicate that the maker is offering a native blockchain token (such as Ether, Matic, etc.).
        address giveTokenAddress;
        /// Amount of tokens the maker is offering.
        uint256 giveAmount;
        /// Address of the ERC-20 token that the maker is willing to accept on the destination chain.
        bytes takeTokenAddress;
        /// Amount of tokens the maker is willing to accept on the destination chain.
        uint256 takeAmount;
        // the ID of the chain where an order should be fulfilled.
        uint256 takeChainId;
        /// Address on the destination chain where funds should be sent upon order fulfillment.
        bytes receiverDst;
        /// Address on the source (current) chain authorized to patch the order by adding more input tokens, making it more attractive to takers.
        address givePatchAuthoritySrc;
        /// Address on the destination chain authorized to patch the order by reducing the take amount, making it more attractive to takers,
        /// and can also cancel the order in the take chain.
        bytes orderAuthorityAddressDst;
        // An optional address restricting anyone in the open market from fulfilling
        // this order but the given address. This can be useful if you are creating a order
        // for a specific taker. By default, set to empty bytes array (0x)
        bytes allowedTakerDst;
        /// An optional external call data payload.
        bytes externalCall;
        // An optional address on the source (current) chain where the given input tokens
        // would be transferred to in case order cancellation is initiated by the orderAuthorityAddressDst
        // on the destination chain. This property can be safely set to an empty bytes array (0x):
        // in this case, tokens would be transferred to the arbitrary address specified
        // by the orderAuthorityAddressDst upon order cancellation
        bytes allowedCancelBeneficiarySrc;
    }

    /// @dev  Struct representing an order.
    struct Order {
        /// Nonce for each maker.
        uint64 makerOrderNonce;
        /// Order maker address (EOA signer for EVM) in the source chain.
        bytes makerSrc;
        /// Chain ID where the order's was created.
        uint256 giveChainId;
        /// Address of the ERC-20 token that the maker is offering as part of this order.
        /// Use the zero address to indicate that the maker is offering a native blockchain token (such as Ether, Matic, etc.).
        bytes giveTokenAddress;
        /// Amount of tokens the maker is offering.
        uint256 giveAmount;
        // the ID of the chain where an order should be fulfilled.
        uint256 takeChainId;
        /// Address of the ERC-20 token that the maker is willing to accept on the destination chain.
        bytes takeTokenAddress;
        /// Amount of tokens the maker is willing to accept on the destination chain.
        uint256 takeAmount;
        /// Address on the destination chain where funds should be sent upon order fulfillment.
        bytes receiverDst;
        /// Address on the source (current) chain authorized to patch the order by adding more input tokens, making it more attractive to takers.
        bytes givePatchAuthoritySrc;
        /// Address on the destination chain authorized to patch the order by reducing the take amount, making it more attractive to takers,
        /// and can also cancel the order in the take chain.
        bytes orderAuthorityAddressDst;
        // An optional address restricting anyone in the open market from fulfilling
        // this order but the given address. This can be useful if you are creating a order
        // for a specific taker. By default, set to empty bytes array (0x)
        bytes allowedTakerDst;
        // An optional address on the source (current) chain where the given input tokens
        // would be transferred to in case order cancellation is initiated by the orderAuthorityAddressDst
        // on the destination chain. This property can be safely set to an empty bytes array (0x):
        // in this case, tokens would be transferred to the arbitrary address specified
        // by the orderAuthorityAddressDst upon order cancellation
        bytes allowedCancelBeneficiarySrc;
        /// An optional external call data payload.
        bytes externalCall;
    }

    /* ========== Methods ========== */

    function getOrderId(Order memory _order) internal pure returns (bytes32) {
        return keccak256(encodeOrder(_order, false));
    }

    function getOrderIdWithExternalCallHash(
        Order memory _order
    ) internal pure returns (bytes32) {
        return keccak256(encodeOrder(_order, true));
    }

    function encodeOrder(
        Order memory _order,
        bool externalCallIsHash
    ) internal pure returns (bytes memory encoded) {
        {
            if (
                _order.makerSrc.length > MAX_ADDRESS_LENGTH ||
                _order.giveTokenAddress.length > MAX_ADDRESS_LENGTH ||
                _order.takeTokenAddress.length > MAX_ADDRESS_LENGTH ||
                _order.receiverDst.length > MAX_ADDRESS_LENGTH ||
                _order.givePatchAuthoritySrc.length > MAX_ADDRESS_LENGTH ||
                _order.allowedTakerDst.length > MAX_ADDRESS_LENGTH ||
                _order.allowedCancelBeneficiarySrc.length > MAX_ADDRESS_LENGTH
            ) revert WrongAddressLength();
        }
        // | Bytes | Bits | Field                                                |
        // | ----- | ---- | ---------------------------------------------------- |
        // | 8     | 64   | Nonce
        // | 1     | 8    | Maker Src Address Size (!=0)                         |
        // | N     | 8*N  | Maker Src Address                                              |
        // | 32    | 256  | Give Chain Id                                        |
        // | 1     | 8    | Give Token Address Size (!=0)                        |
        // | N     | 8*N  | Give Token Address                                   |
        // | 32    | 256  | Give Amount                                          |
        // | 32    | 256  | Take Chain Id                                        |
        // | 1     | 8    | Take Token Address Size (!=0)                        |
        // | N     | 8*N  | Take Token Address                                   |
        // | 32    | 256  | Take Amount                                          |                         |
        // | 1     | 8    | Receiver Dst Address Size (!=0)                      |
        // | N     | 8*N  | Receiver Dst Address                                 |
        // | 1     | 8    | Give Patch Authority Address Size (!=0)              |
        // | N     | 8*N  | Give Patch Authority Address                         |
        // | 1     | 8    | Order Authority Address Dst Size (!=0)               |
        // | N     | 8*N  | Order Authority Address Dst                     |
        // | 1     | 8    | Allowed Taker Dst Address Size                       |
        // | N     | 8*N  | * Allowed Taker Address Dst                          |
        // | 1     | 8    | Allowed Cancel Beneficiary Src Address Size          |
        // | N     | 8*N  | * Allowed Cancel Beneficiary Address Src             |
        // | 1     | 8    | Is External Call Presented 0x0 - Not, != 0x0 - Yes   |
        // | 32    | 256  | * External Call Envelope Hash

        encoded = abi.encodePacked(
            _order.makerOrderNonce,
            (uint8)(_order.makerSrc.length),
            _order.makerSrc
        );
        {
            encoded = abi.encodePacked(
                encoded,
                _order.giveChainId,
                (uint8)(_order.giveTokenAddress.length),
                _order.giveTokenAddress,
                _order.giveAmount,
                _order.takeChainId
            );
        }
        //Avoid stack to deep
        {
            encoded = abi.encodePacked(
                encoded,
                (uint8)(_order.takeTokenAddress.length),
                _order.takeTokenAddress,
                _order.takeAmount,
                (uint8)(_order.receiverDst.length),
                _order.receiverDst
            );
        }
        {
            encoded = abi.encodePacked(
                encoded,
                (uint8)(_order.givePatchAuthoritySrc.length),
                _order.givePatchAuthoritySrc,
                (uint8)(_order.orderAuthorityAddressDst.length),
                _order.orderAuthorityAddressDst
            );
        }
        {
            encoded = abi.encodePacked(
                encoded,
                (uint8)(_order.allowedTakerDst.length),
                _order.allowedTakerDst,
                (uint8)(_order.allowedCancelBeneficiarySrc.length),
                _order.allowedCancelBeneficiarySrc,
                _order.externalCall.length > 0
            );
        }
        if (_order.externalCall.length > 0) {
            if (externalCallIsHash) {
                if (_order.externalCall.length != 32) revert WrongExternalCallHash();
                encoded = abi.encodePacked(encoded, _order.externalCall);
            } else {
                encoded = abi.encodePacked(
                    encoded,
                    keccak256(_order.externalCall)
                );
            }
        }
        return encoded;
    }
}


// ===== @openzeppelin/contracts/token/ERC20/ERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// ===== @openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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


// ===== @openzeppelin/contracts/proxy/beacon/IBeacon.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}


// ===== @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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


// ===== contracts/libraries/DlnDestinationCalldataLib.sol =====
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import {ISanityCheckErrors} from "../interfaces/ISanityCheckErrors.sol";

library DlnDestinationCalldataLib {
    /* ========== CONSTANTS ========== */

    /// @dev Function selector of DlnDestination.fulfillOrder function (first
    /// overload).
    bytes4 internal constant FULFILL_ORDER_FUNCTION_SELECTOR_1 = 0xc358547e;

    /// @dev Function selector of DlnDestination.fulfillOrder function (second
    /// overload).
    bytes4 internal constant FULFILL_ORDER_FUNCTION_SELECTOR_2 = 0x0ebcd2f6;

    /// @dev Offset of order parameter offset slot in the calldata for
    /// DlnDestination.fulfillOrder function calls.
    uint256 internal constant ORDER_ARG_CALLDATA_OFFSET = 4;

    /// @dev Offset of fulfillAmount parameter in the calldata for
    /// DlnDestination.fulfillOrder function calls.
    uint256 internal constant FULFILL_AMOUNT_CALLDATA_OFFSET = 36;

    /// @dev Minimum size of calldata to read fulfillAmount at the fixed offset.
    /// FULFILL_AMOUNT_CALLDATA_OFFSET (36) + 32 bytes for the fulfillAmount =
    /// 68 bytes minimum.
    uint256 internal constant FULFILL_AMOUNT_CALLDATA_MIN_SIZE = 68;

    /// @dev Offset of orderId parameter in the calldata for
    /// DlnDestination.fulfillOrder function calls.
    uint256 internal constant ORDER_ID_CALLDATA_OFFSET = 68;

    /// @dev Top-level ABI offset of the dynamic order tuple in the first
    /// supported fulfillOrder overload.
    uint256 internal constant ORDER_OFFSET_OVERLOAD_1 = 160;

    /// @dev Top-level ABI offset of the dynamic order tuple in the second
    /// supported fulfillOrder overload.
    uint256 internal constant ORDER_OFFSET_OVERLOAD_2 = 192;

    /// @dev Offset of takeAmount field inside DLN order tuple.
    uint256 internal constant ORDER_TAKE_AMOUNT_TUPLE_OFFSET = 7 * 32;

    /// @dev Minimum size of calldata to read orderId at the fixed offset.
    /// ORDER_ID_CALLDATA_OFFSET (68) + 32 bytes for the orderId = 100 bytes
    /// minimum.
    uint256 internal constant ORDER_ID_CALLDATA_MIN_SIZE = 100;

    /* ========== INTERNAL ========== */

    function validateFunctionSelector(bytes calldata _calldata) internal pure {
        bytes4 functionSelector = _getFunctionSelector(_calldata);

        if (
            functionSelector != FULFILL_ORDER_FUNCTION_SELECTOR_1 &&
            functionSelector != FULFILL_ORDER_FUNCTION_SELECTOR_2
        ) {
            revert ISanityCheckErrors.WrongArgument();
        }
    }

    function getOrderId(
        bytes calldata _calldata
    ) internal pure returns (bytes32 orderId) {
        if (_calldata.length < ORDER_ID_CALLDATA_MIN_SIZE) {
            revert ISanityCheckErrors.WrongArgument();
        }

        assembly {
            orderId := calldataload(
                add(_calldata.offset, ORDER_ID_CALLDATA_OFFSET)
            )
        }
    }

    function getFulfillAmount(
        bytes calldata _calldata
    ) internal pure returns (uint256 fulfillAmount) {
        if (_calldata.length < FULFILL_AMOUNT_CALLDATA_MIN_SIZE) {
            revert ISanityCheckErrors.WrongArgument();
        }

        assembly {
            fulfillAmount := calldataload(
                add(_calldata.offset, FULFILL_AMOUNT_CALLDATA_OFFSET)
            )
        }
    }

    function getOrderTakeAmount(
        bytes calldata _calldata
    ) internal pure returns (uint256 orderTakeAmount) {
        bytes4 functionSelector = _getFunctionSelector(_calldata);

        uint256 expectedOrderOffset;
        if (functionSelector == FULFILL_ORDER_FUNCTION_SELECTOR_1) {
            expectedOrderOffset = ORDER_OFFSET_OVERLOAD_1;
        } else if (functionSelector == FULFILL_ORDER_FUNCTION_SELECTOR_2) {
            expectedOrderOffset = ORDER_OFFSET_OVERLOAD_2;
        } else {
            revert ISanityCheckErrors.WrongArgument();
        }

        uint256 orderOffset = _readUint256(
            _calldata,
            ORDER_ARG_CALLDATA_OFFSET
        );
        if (orderOffset != expectedOrderOffset) {
            revert ISanityCheckErrors.WrongArgument();
        }

        return _readUint256(
            _calldata,
            ORDER_ARG_CALLDATA_OFFSET + orderOffset + ORDER_TAKE_AMOUNT_TUPLE_OFFSET
        );
    }

    function patchCalldataFulfillAmount(
        bytes calldata _calldata,
        uint256 _newFulfillAmount
    ) internal pure returns (bytes memory patchedCalldata) {
        if (_calldata.length < FULFILL_AMOUNT_CALLDATA_MIN_SIZE) {
            revert ISanityCheckErrors.WrongArgument();
        }

        patchedCalldata = _calldata;

        assembly {
            // skip patchedCalldata length
            let dataPtr := add(patchedCalldata, 32)

            // overwrite fulfillAmount at the fixed offset
            mstore(
                add(dataPtr, FULFILL_AMOUNT_CALLDATA_OFFSET),
                _newFulfillAmount
            )
        }
    }

    /* ========== PRIVATE ========== */

    function _getFunctionSelector(
        bytes calldata _calldata
    ) private pure returns (bytes4 functionSelector) {
        if (_calldata.length < 4) revert ISanityCheckErrors.WrongArgument();

        functionSelector = bytes4(_calldata[:4]);
    }

    function _readUint256(
        bytes calldata _calldata,
        uint256 _offset
    ) private pure returns (uint256 value) {
        if (_calldata.length < _offset + 32) {
            revert ISanityCheckErrors.WrongArgument();
        }

        assembly {
            value := calldataload(add(_calldata.offset, _offset))
        }
    }
}


// ===== @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol =====
// SPDX-License-Identifier: MIT
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


// ===== contracts/mock/DummyDlnDestination.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { DlnOrderLib } from './libraries/DlnOrderLib.sol';

contract DummyDlnDestination {
    using SafeERC20 for IERC20;

    uint256 private constant MAX_UINT32 = type(uint32).max;

    enum OrderTakeStatus {
        NotSet, // 0
        Fulfilled, // 1
        SentUnlock, // 2
        SentCancel // 3
    }

    struct OrderTakeState {
        OrderTakeStatus status;
        address takerAddress;
        // use giveChainId if chainId less than uint32 max
        uint32 giveChainId;
        // use bigGiveChainId if chainId more than uint32 max
        uint256 bigGiveChainId;
    }

    mapping(bytes32 => OrderTakeState) public takeOrders;

    error IncorrectOrderStatus();
    error InsufficientTakerAmount();
    error InsufficientActualFulfillAmount(uint256 actualAmount, uint256 requiredAmount);
    error MismatchNativeFulfillAmount();
    error MismatchedOrderId();
    error EthTransferFailed();

    event FulfilledOrder(
        DlnOrderLib.Order order,
        bytes32 orderId,
        uint256 actualFulfillAmount,
        address sender,
        address unlockAuthority
    );

    function setOrderTakeState(
        bytes32 _orderId,
        OrderTakeStatus _status,
        address _takerAddress,
        uint32 _giveChainId,
        uint256 _bigGiveChainId
    ) external {
        takeOrders[_orderId] = OrderTakeState({
            status: _status,
            takerAddress: _takerAddress,
            giveChainId: _giveChainId,
            bigGiveChainId: _bigGiveChainId
        });
    }

    function getOrderId(
        DlnOrderLib.Order memory _order
    ) public pure returns (bytes32) {
        return DlnOrderLib.getOrderId(_order);
    }

    function fulfillOrder(
        DlnOrderLib.Order memory _order,
        uint256 _fulFillAmount,
        bytes32 _orderId,
        bytes calldata _permitEnvelope,
        address _unlockAuthority
    ) external payable {
        _fulfillOrder(
            _permitEnvelope,
            _order,
            _fulFillAmount,
            _orderId,
            _unlockAuthority
        );
    }

    function fulfillOrder(
        DlnOrderLib.Order memory _order,
        uint256 _fulFillAmount,
        bytes32 _orderId,
        bytes calldata _permitEnvelope,
        address _unlockAuthority,
        address _externalCallRewardBeneficiary
    ) external payable {
        // Silence compiler warning. External-call adapter flow is outside this mock's scope.
        _externalCallRewardBeneficiary;

        _fulfillOrder(
            _permitEnvelope,
            _order,
            _fulFillAmount,
            _orderId,
            _unlockAuthority
        );
    }

    function _fulfillOrder(
        bytes memory _permitEnvelope,
        DlnOrderLib.Order memory _order,
        uint256 _fulFillAmount,
        bytes32 _orderId,
        address _unlockAuthority
    ) private {
        // Silence compiler warning. Permit handling is outside this mock's scope.
        _permitEnvelope;

        bytes32 orderId = DlnOrderLib.getOrderId(_order);
        if (orderId != _orderId) revert MismatchedOrderId();

        OrderTakeState storage orderState = takeOrders[orderId];
        if (orderState.status != OrderTakeStatus.NotSet) {
            revert IncorrectOrderStatus();
        }

        if (_fulFillAmount < _order.takeAmount) revert InsufficientTakerAmount();

        address takeTokenAddress = _toAddress(_order.takeTokenAddress);
        address tokenReceiver = _toAddress(_order.receiverDst);
        uint256 actualFulfillAmount = _fulFillAmount;

        if (takeTokenAddress == address(0)) {
            if (msg.value != _fulFillAmount) revert MismatchNativeFulfillAmount();
            _safeTransferETH(tokenReceiver, _fulFillAmount);
        } else {
            uint256 balanceBefore = IERC20(takeTokenAddress).balanceOf(tokenReceiver);
            IERC20(takeTokenAddress).safeTransferFrom(
                msg.sender, tokenReceiver, _fulFillAmount
            );
            actualFulfillAmount = IERC20(takeTokenAddress).balanceOf(tokenReceiver) - balanceBefore;
        }

        if (actualFulfillAmount < _order.takeAmount) {
            revert InsufficientActualFulfillAmount(actualFulfillAmount, _order.takeAmount);
        }

        orderState.status = OrderTakeStatus.Fulfilled;
        orderState.takerAddress = _unlockAuthority;
        if (_order.giveChainId <= MAX_UINT32) {
            orderState.giveChainId = uint32(_order.giveChainId);
        } else {
            orderState.bigGiveChainId = _order.giveChainId;
        }

        emit FulfilledOrder(_order, orderId, actualFulfillAmount, msg.sender, _unlockAuthority);
    }

    function _safeTransferETH(address _to, uint256 _amount) private {
        (bool success, ) = _to.call{value: _amount}("");
        if (!success) revert EthTransferFailed();
    }

    function _toAddress(bytes memory _data) private pure returns (address addr) {
        require(_data.length == 20, "INVALID_ADDRESS_LENGTH");
        assembly {
            addr := div(mload(add(_data, 32)), 0x1000000000000000000000000)
        }
    }
}


// ===== contracts/mock/PmmSourceMock.sol =====
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PmmSourceMock {
    using SafeERC20 for IERC20;

    struct OrderTakeState {
        uint8 status;
        address takerAddress;
        uint256 giveChainId;
    }

    mapping(bytes32 => OrderTakeState) public takeOrders;

    uint256 public globalFixedNativeFee;

    error PmmSourceCustomError();

    constructor(uint256 _globalFixedNativeFee) {
        globalFixedNativeFee = _globalFixedNativeFee;
    }

    event OrderCreated(address giveTokenAddress, uint256 giveAmount);

    function setTakeOrders(bytes32 _orderId, uint8 _status) external {
        OrderTakeState storage order = takeOrders[_orderId];
        order.status = _status;
        order.takerAddress = msg.sender;
        order.giveChainId = getChainId();
    }

    function getChainId() public view virtual returns (uint256 cid) {
        assembly {
            cid := chainid()
        }
    }

    ///@dev This method emulates createOrder() which accepts arbitrary amount of arbitrary token (incl. native)
    ///     and the fixed fee in native token
    function paidAction(address tokenIn, uint256 amountIn) external payable {
        if (tokenIn == address(0)) {
            require(
                msg.value == amountIn + globalFixedNativeFee,
                "native fee not covered"
            );
        } else {
            require(
                msg.value == globalFixedNativeFee,
                "msg.value does not cover fee"
            );
            IERC20(tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
        }

        emit OrderCreated(tokenIn, amountIn);
    }

    ///@dev This method emulates fulfill() which accepts arbitrary amount of arbitrary token (incl. native)
    function freeAction(address tokenIn, uint256 amountIn) external payable {
        if (tokenIn == address(0)) {
            require(msg.value == amountIn, "amount in is not exactly the same");
        } else {
            require(msg.value == 0, "msg.value should be zero");
            IERC20(tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
        }

        emit OrderCreated(tokenIn, amountIn);
    }

    ///@dev This method takes the given arbitrary amount of arbitrary token (incl. native) and sends the given amount
    ///     to another address. This is useful to emulate refunds
    function bypass(
        address token,
        uint256 amountIn,
        address refundTo,
        uint256 amountOut
    ) external payable {
        if (token != address(0)) {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amountIn);
        }

        if (token == address(0)) {
            (bool success, ) = refundTo.call{value: amountOut}("");
            require(success);
        } else IERC20(token).safeTransfer(refundTo, amountOut);
    }

    function raiseCustomError() external payable {
        revert PmmSourceCustomError();
    }

    function raiseError() external payable {
        require(false, "error");
    }
}


// ===== @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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


// ===== contracts/mock/DummyRebasingToken.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev Synthetic rebasing token that mimics stETH transfer behavior.
/// Internally tracks balances as shares. A nominal token transfer can credit
/// the receiver with less due to share rounding, as with stETH.
contract DummyRebasingToken is ERC20 {
    uint8 private _decimals;

    uint256 public totalShares;
    uint256 public totalPooledEther;
    mapping(address => uint256) public sharesOf;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /// @dev Sets the total pooled ether. Changing it after minting simulates a rebase.
    function setTotalPooledEther(uint256 _totalPooledEther) external {
        totalPooledEther = _totalPooledEther;
    }

    /// @dev Mint shares so that token-denominated balance equals `amount`
    /// at the current exchange rate.
    function mint(address recipient, uint256 amount) external {
        uint256 sharesToMint;
        if (totalShares == 0 || totalPooledEther == 0) {
            sharesToMint = amount;
            totalPooledEther += amount;
        } else {
            sharesToMint = (amount * totalShares) / totalPooledEther;
            totalPooledEther += amount;
        }
        totalShares += sharesToMint;
        sharesOf[recipient] += sharesToMint;
        _mint(recipient, amount);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        if (totalShares == 0) return 0;
        return (sharesOf[account] * totalPooledEther) / totalShares;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return totalPooledEther;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transferShares(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transferShares(from, to, amount);
        return true;
    }

    function _transferShares(address from, address to, uint256 amount) private {
        uint256 sharesToTransfer = (amount * totalShares) / totalPooledEther;
        require(sharesToTransfer > 0, "Transfer amount too small");
        require(sharesOf[from] >= sharesToTransfer, "Insufficient shares");

        sharesOf[from] -= sharesToTransfer;
        sharesOf[to] += sharesToTransfer;

        uint256 tokensTransferred = (sharesToTransfer * totalPooledEther) / totalShares;
        emit Transfer(from, to, tokensTransferred);
    }
}


// ===== contracts/interfaces/IDeBridgeGate.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IDeBridgeGate {
    function getDebridgeId(
        uint256 _chainId,
        address _tokenAddress
    ) external pure returns (bytes32);

    function getChainId() external view returns (uint256 cid);

    /* ========== STRUCTS ========== */

    struct TokenInfo {
        uint256 nativeChainId;
        bytes nativeAddress;
    }

    struct DebridgeInfo {
        uint256 chainId; // native chain id
        uint256 maxAmount; // maximum amount to transfer
        uint256 balance; // total locked assets
        uint256 lockedInStrategies; // total locked assets in strategy (AAVE, Compound, etc)
        address tokenAddress; // asset address on the current chain
        uint16 minReservesBps; // minimal hot reserves in basis points (1/10000)
        bool exist;
    }

    struct DebridgeFeeInfo {
        uint256 collectedFees; // total collected fees
        uint256 withdrawnFees; // fees that already withdrawn
        mapping(uint256 => uint256) getChainFee; // whether the chain for the asset is supported
    }

    struct ChainSupportInfo {
        uint256 fixedNativeFee; // transfer fixed fee
        bool isSupported; // whether the chain for the asset is supported
        uint16 transferFeeBps; // transfer fee rate nominated in basis points (1/10000) of transferred amount
    }

    struct DiscountInfo {
        uint16 discountFixBps; // fix discount in BPS
        uint16 discountTransferBps; // transfer % discount in BPS
    }

    /// @param executionFee Fee paid to the transaction executor.
    /// @param fallbackAddress Receiver of the tokens if the call fails.
    struct SubmissionAutoParamsTo {
        uint256 executionFee;
        uint256 flags;
        bytes fallbackAddress;
        bytes data;
    }

    /// @param executionFee Fee paid to the transaction executor.
    /// @param fallbackAddress Receiver of the tokens if the call fails.
    struct SubmissionAutoParamsFrom {
        uint256 executionFee;
        uint256 flags;
        address fallbackAddress;
        bytes data;
        bytes nativeSender;
    }

    struct FeeParams {
        uint256 receivedAmount;
        uint256 fixFee;
        uint256 transferFee;
        bool useAssetFee;
        bool isNativeToken;
    }

    /* ========== PUBLIC VARS GETTERS ========== */

    /// @dev Returns whether the transfer with the submissionId was claimed.
    /// submissionId is generated in getSubmissionIdFrom
    function isSubmissionUsed(
        bytes32 submissionId
    ) external view returns (bool);

    /// @dev Returns native token info by wrapped token address
    function getNativeInfo(
        address token
    ) external view returns (uint256 nativeChainId, bytes memory nativeAddress);

    /// @dev Returns address of the proxy to execute user's calls.
    function callProxy() external view returns (address);

    /// @dev Fallback fixed fee in native asset, used if a chain fixed fee is set to 0
    function globalFixedNativeFee() external view returns (uint256);

    /// @dev Fallback transfer fee in BPS, used if a chain transfer fee is set to 0
    function globalTransferFeeBps() external view returns (uint16);

    /* ========== FUNCTIONS ========== */

    /// @dev Submits the message to the deBridge infrastructure to be broadcasted to another supported blockchain (identified by _dstChainId)
    ///      with the instructions to call the _targetContractAddress contract using the given _targetContractCalldata
    /// @notice NO ASSETS ARE BROADCASTED ALONG WITH THIS MESSAGE
    /// @notice DeBridgeGate only accepts submissions with msg.value (native ether) covering a small protocol fee
    ///         (defined in the globalFixedNativeFee property). Any excess amount of ether passed to this function is
    ///         included in the message as the execution fee - the amount deBridgeGate would give as an incentive to
    ///         a third party in return for successful claim transaction execution on the destination chain.
    /// @notice DeBridgeGate accepts a set of flags that control the behaviour of the execution. This simple method
    ///         sets the default set of flags: REVERT_IF_EXTERNAL_FAIL, PROXY_WITH_SENDER
    /// @param _dstChainId ID of the destination chain.
    /// @param _targetContractAddress A contract address to be called on the destination chain
    /// @param _targetContractCalldata Calldata to execute against the target contract on the destination chain
    function sendMessage(
        uint256 _dstChainId,
        bytes memory _targetContractAddress,
        bytes memory _targetContractCalldata
    ) external payable returns (bytes32 submissionId);

    /// @dev Submits the message to the deBridge infrastructure to be broadcasted to another supported blockchain (identified by _dstChainId)
    ///      with the instructions to call the _targetContractAddress contract using the given _targetContractCalldata
    /// @notice NO ASSETS ARE BROADCASTED ALONG WITH THIS MESSAGE
    /// @notice DeBridgeGate only accepts submissions with msg.value (native ether) covering a small protocol fee
    ///         (defined in the globalFixedNativeFee property). Any excess amount of ether passed to this function is
    ///         included in the message as the execution fee - the amount deBridgeGate would give as an incentive to
    ///         a third party in return for successful claim transaction execution on the destination chain.
    /// @notice DeBridgeGate accepts a set of flags that control the behaviour of the execution. This simple method
    ///         sets the default set of flags: REVERT_IF_EXTERNAL_FAIL, PROXY_WITH_SENDER
    /// @param _dstChainId ID of the destination chain.
    /// @param _targetContractAddress A contract address to be called on the destination chain
    /// @param _targetContractCalldata Calldata to execute against the target contract on the destination chain
    /// @param _flags A bitmask of toggles listed in the Flags library
    /// @param _referralCode Referral code to identify this submission
    function sendMessage(
        uint256 _dstChainId,
        bytes memory _targetContractAddress,
        bytes memory _targetContractCalldata,
        uint256 _flags,
        uint32 _referralCode
    ) external payable returns (bytes32 submissionId);

    /// @dev This method is used for the transfer of assets [from the native chain](https://docs.debridge.finance/the-core-protocol/transfers#transfer-from-native-chain).
    /// It locks an asset in the smart contract in the native chain and enables minting of deAsset on the secondary chain.
    /// @param _tokenAddress Asset identifier.
    /// @param _amount Amount to be transferred (note: the fee can be applied).
    /// @param _chainIdTo Chain id of the target chain.
    /// @param _receiver Receiver address.
    /// @param _permitEnvelope Permit for approving the spender by signature. bytes (amount + deadline + signature)
    /// @param _useAssetFee use assets fee for pay protocol fix (work only for specials token)
    /// @param _referralCode Referral code
    /// @param _autoParams Auto params for external call in target network
    function send(
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bytes memory _receiver,
        bytes memory _permitEnvelope,
        bool _useAssetFee,
        uint32 _referralCode,
        bytes calldata _autoParams
    ) external payable returns (bytes32 submissionId);

    /// @dev Is used for transfers [into the native chain](https://docs.debridge.finance/the-core-protocol/transfers#transfer-from-secondary-chain-to-native-chain)
    /// to unlock the designated amount of asset from collateral and transfer it to the receiver.
    /// @param _debridgeId Asset identifier.
    /// @param _amount Amount of the transferred asset (note: the fee can be applied).
    /// @param _chainIdFrom Chain where submission was sent
    /// @param _receiver Receiver address.
    /// @param _nonce Submission id.
    /// @param _signatures Validators signatures to confirm
    /// @param _autoParams Auto params for external call
    function claim(
        bytes32 _debridgeId,
        uint256 _amount,
        uint256 _chainIdFrom,
        address _receiver,
        uint256 _nonce,
        bytes calldata _signatures,
        bytes calldata _autoParams
    ) external;

    /// @dev Withdraw collected fees to feeProxy
    /// @param _debridgeId Asset identifier.
    function withdrawFee(bytes32 _debridgeId) external;

    /// @dev Returns asset fixed fee value for specified debridge and chainId.
    /// @param _debridgeId Asset identifier.
    /// @param _chainId Chain id.
    function getDebridgeChainAssetFixedFee(
        bytes32 _debridgeId,
        uint256 _chainId
    ) external view returns (uint256);

    /* ========== EVENTS ========== */

    /// @dev Emitted once the tokens are sent from the original(native) chain to the other chain; the transfer tokens
    /// are expected to be claimed by the users.
    event Sent(
        bytes32 submissionId,
        bytes32 indexed debridgeId,
        uint256 amount,
        bytes receiver,
        uint256 nonce,
        uint256 indexed chainIdTo,
        uint32 referralCode,
        FeeParams feeParams,
        bytes autoParams,
        address nativeSender
        // bool isNativeToken //added to feeParams
    );

    /// @dev Emitted once the tokens are transferred and withdrawn on a target chain
    event Claimed(
        bytes32 submissionId,
        bytes32 indexed debridgeId,
        uint256 amount,
        address indexed receiver,
        uint256 nonce,
        uint256 indexed chainIdFrom,
        bytes autoParams,
        bool isNativeToken
    );

    /// @dev Emitted when new asset support is added.
    event PairAdded(
        bytes32 debridgeId,
        address tokenAddress,
        bytes nativeAddress,
        uint256 indexed nativeChainId,
        uint256 maxAmount,
        uint16 minReservesBps
    );

    event MonitoringSendEvent(
        bytes32 submissionId,
        uint256 nonce,
        uint256 lockedOrMintedAmount,
        uint256 totalSupply
    );

    event MonitoringClaimEvent(
        bytes32 submissionId,
        uint256 lockedOrMintedAmount,
        uint256 totalSupply
    );

    /// @dev Emitted when the asset is allowed/disallowed to be transferred to the chain.
    event ChainSupportUpdated(
        uint256 chainId,
        bool isSupported,
        bool isChainFrom
    );
    /// @dev Emitted when the supported chains are updated.
    event ChainsSupportUpdated(
        uint256 chainIds,
        ChainSupportInfo chainSupportInfo,
        bool isChainFrom
    );

    /// @dev Emitted when the new call proxy is set.
    event CallProxyUpdated(address callProxy);
    /// @dev Emitted when the transfer request is executed.
    event AutoRequestExecuted(
        bytes32 submissionId,
        bool indexed success,
        address callProxy
    );

    /// @dev Emitted when a submission is blocked.
    event Blocked(bytes32 submissionId);
    /// @dev Emitted when a submission is unblocked.
    event Unblocked(bytes32 submissionId);

    /// @dev Emitted when fee is withdrawn.
    event WithdrawnFee(bytes32 debridgeId, uint256 fee);

    /// @dev Emitted when globalFixedNativeFee and globalTransferFeeBps are updated.
    event FixedNativeFeeUpdated(
        uint256 globalFixedNativeFee,
        uint256 globalTransferFeeBps
    );

    /// @dev Emitted when globalFixedNativeFee is updated by feeContractUpdater
    event FixedNativeFeeAutoUpdated(uint256 globalFixedNativeFee);
}


// ===== contracts/interfaces/ISanityCheckErrors.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ISanityCheckErrors {
    error WrongArgument(); // Various sanity checks on function arguments
}

// ===== @openzeppelin/contracts/utils/StorageSlot.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
 * ```
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
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
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
}


// ===== contracts/mock/DummyPool.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./DummyAllowanceHolder.sol";

contract DummyPool {
    using SafeERC20 for IERC20;

    address public tokenA;
    address public tokenB;
    uint256 public feeBps;

    constructor(address _tokenA, address _tokenB, uint256 _feeBps) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        feeBps = _feeBps;
    }

    function setFeeBps(uint256 _feeBps) external {
        feeBps = _feeBps;
    }

    function swap(address tokenIn, uint256 amountIn) external payable {
        _swap(tokenIn, amountIn, msg.sender, true);
    }

    function swap(
        address tokenIn,
        uint256 amountIn,
        address recipient
    ) external payable {
        _swap(tokenIn, amountIn, recipient, true);
    }

    // Special swap function that works with allowance holder
    function swapWithAllowanceHolder(
        address tokenIn,
        uint256 amountIn,
        address allowanceHolder
    ) external payable {
        require(allowanceHolder != address(0), "Invalid allowance holder");
        
        if (tokenIn == address(0)) {
            require(msg.value == amountIn, "Incorrect native token amount");
            _swap(tokenIn, amountIn, msg.sender, true);
        } else {
            require(msg.value == 0, "Native token not expected");
            // Pull tokens through allowance holder
            DummyAllowanceHolder(allowanceHolder).pullTokens(
                tokenIn,
                msg.sender,
                address(this),
                amountIn
            );
            // Skip transferFrom since tokens are already transferred
            _swap(tokenIn, amountIn, msg.sender, false);
        }
    }

    function _swap(
        address tokenIn,
        uint256 amountIn,
        address recipient,
        bool shouldTransfer
    ) internal {
        uint256 amount0In;
        uint256 amount1In;
        address tokenOut;
        if (tokenIn == tokenA) {
            amount0In = amountIn;
            tokenOut = tokenB;
        } else if (tokenIn == tokenB) {
            amount1In = amountIn;
            tokenOut = tokenA;
        } else {
            require(false);
        }

        if (tokenIn == address(0)) {
            require(msg.value == amountIn);
        } else if (shouldTransfer) {
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        }

        (uint256 reserve0, uint256 reserve1, uint256 k) = getReserves();

        reserve0 -= amount0In;
        reserve1 -= amount1In;
        k = reserve0 * reserve1;

        (uint256 amount0Out, uint256 amount1Out) = _calcSwap(
            amount0In,
            amount1In,
            reserve0,
            reserve1,
            k
        );
        uint256 amountOut = amount0Out == 0 ? amount1Out : amount0Out;

        if (tokenOut == address(0)) {
            (bool success, ) = recipient.call{value: amountOut}("");
            require(success);
        } else {
            IERC20(tokenOut).safeTransfer(recipient, amountOut);
        }
    }

    function getReserves()
        public
        view
        returns (uint256 reserve0, uint256 reserve1, uint256 k)
    {
        reserve0 = tokenA == address(0)
            ? address(this).balance
            : IERC20(tokenA).balanceOf(address(this));
        reserve1 = tokenB == address(0)
            ? address(this).balance
            : IERC20(tokenB).balanceOf(address(this));
        k = reserve0 * reserve1;
    }

    function calcSwap(
        uint256 amount0In,
        uint256 amount1In
    ) external view returns (uint256 amount0Out, uint256 amount1Out) {
        (uint256 reserve0, uint256 reserve1, uint256 k) = getReserves();
        return _calcSwap(amount0In, amount1In, reserve0, reserve1, k);
    }

    function _calcSwap(
        uint256 amount0In,
        uint256 amount1In,
        uint256 reserve0,
        uint256 reserve1,
        uint256 k
    ) internal view returns (uint256 amount0Out, uint256 amount1Out) {
        if (amount0In != 0) {
            amount0In = (amount0In * (10000 - feeBps)) / 10000;
            uint256 newReserve0 = reserve0 + amount0In;
            uint256 newReserve1 = k / newReserve0;
            amount1Out = reserve1 - newReserve1;
        } else if (amount1In != 0) {
            amount1In = (amount1In * (10000 - feeBps)) / 10000;
            uint256 newReserve1 = reserve1 + amount1In;
            uint256 newReserve0 = k / newReserve1;
            amount0Out = reserve0 - newReserve0;
        } else {
            require(false, "SHOULD_NOT_HAPPEN");
        }
    }

    receive() external payable {}
}


// ===== @openzeppelin/contracts/utils/Strings.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

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


// ===== @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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


// ===== @openzeppelin/contracts/proxy/Proxy.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}


// ===== @openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}


// ===== contracts/mock/DummyFixedSwapRouter.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DummyFixedSwapRouter {
    using SafeERC20 for IERC20;

    address public tokenOut;
    uint256 public amountOut;

    constructor(address _tokenOut, uint256 _amountOut) {
        tokenOut = _tokenOut;
        amountOut = _amountOut;
    }

    function setAmountOut(uint256 _amountOut) external {
        amountOut = _amountOut;
    }

    function swap(address _tokenIn, uint256 _amountIn) external payable {
        if (_tokenIn == address(0)) {
            require(msg.value == _amountIn, "wrong msg.value");
        } else {
            IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);
        }

        if (tokenOut == address(0)) {
            (bool success, ) = msg.sender.call{value: amountOut}("");
            require(success, "eth transfer failed");
        } else {
            IERC20(tokenOut).safeTransfer(msg.sender, amountOut);
        }
    }

    receive() external payable {}
}


// ===== @openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
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
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}


// ===== contracts/mock/TargetTokenHolder.sol =====
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract TargetTokenHolder {
    using SafeERC20 for IERC20;

    address _targetToken;

    constructor(address targetToken_) {
        _targetToken = targetToken_;
    }

    function obtain(address _wrappedToken) external {
        IERC20 wrappedToken = IERC20(_wrappedToken);
        wrappedToken.transferFrom(
            msg.sender,
            address(this),
            wrappedToken.balanceOf(msg.sender)
        );
    }
}


// ===== @openzeppelin/contracts/utils/Context.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// ===== @openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol =====
// SPDX-License-Identifier: MIT
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


// ===== @openzeppelin/contracts/interfaces/draft-IERC1822.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
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


// ===== contracts/imports.sol =====
pragma solidity ^0.8.7;

// import this contract for typechain
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";


// ===== @openzeppelin/contracts/token/ERC20/IERC20.sol =====
// SPDX-License-Identifier: MIT
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


// ===== @openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/cryptography/EIP712.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    /**
     * @dev In previous versions `_PERMIT_TYPEHASH` was declared as `immutable`.
     * However, to ensure consistency with the upgradeable transpiler, we will continue
     * to reserve a slot.
     * @custom:oz-renamed-from _PERMIT_TYPEHASH
     */
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}


// ===== contracts/mock/DummySwapCaller.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../DeBridgeRouter.sol";

contract DummySwapCaller {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event ActualAmountOut(uint256 actualAmountOut);

    function callSwap(
        DeBridgeRouter _deBridgeRouter,
        address _tokenIn,
        uint256 _amountIn,
        bytes memory _tokenInPermitEnvelope,
        DeBridgeRouter.SameChainSwapDetails calldata _swapDetails,
        uint32 _referralCode
    ) external payable {
        if (_tokenIn == address(0)) {
            require(msg.value == _amountIn, "Incorrect native token amount sent");
        } else {
            require(msg.value == 0, "Native token sent with ERC20 swap");
            // Ensure the contract has enough allowance to transfer tokens
            _lazyApprove(_tokenIn, address(_deBridgeRouter), _amountIn);
            // Transfer the tokens from the caller to this contract
            IERC20Upgradeable(_tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                _amountIn
            );
        }

        uint256 actualAmountOut = _deBridgeRouter.swap{value: msg.value}(
            _tokenIn,
            _amountIn,
            _tokenInPermitEnvelope,
            _swapDetails,
            _referralCode
        );

        emit ActualAmountOut(actualAmountOut);
    }

    function _lazyApprove(
        address _tokenAddress,
        address _spender,
        uint256 _amount
    ) private {
        IERC20Upgradeable token = IERC20Upgradeable(_tokenAddress);
        uint256 currentAllowance = token.allowance(address(this), _spender);

        if (currentAllowance < _amount) {
            // if an approval was issued before
            token.safeApprove(_spender, 0);
            // create permanent approve
            token.safeApprove(_spender, type(uint256).max);
        }
    }
}

// ===== @openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";

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
}


// ===== @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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


// ===== @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
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

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// ===== @openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// ===== @openzeppelin/contracts/utils/math/Math.sol =====
// SPDX-License-Identifier: MIT
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


// ===== contracts/DeBridgeRouterProxy.sol =====
pragma solidity ^0.8.7;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeBridgeRouterProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable TransparentUpgradeableProxy(_logic, admin_, _data) {}

    receive() external payable override {}
}


// ===== contracts/libraries/Permit.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./SignatureUtil.sol";

library Permit {
    using SignatureUtil for bytes;

    function executePermit(
        address _tokenAddress,
        bytes memory _permitEnvelope
    ) internal {
        if (_permitEnvelope.length > 0) {
            uint256 permitAmount = _permitEnvelope.toUint256(0);
            uint256 deadline = _permitEnvelope.toUint256(32);
            (bytes32 r, bytes32 s, uint8 v) = _permitEnvelope.parseSignature(
                64
            );
            try
                IERC20Permit(_tokenAddress).permit(
                    msg.sender,
                    address(this),
                    permitAmount,
                    deadline,
                    v,
                    r,
                    s
                )
            {
                return;
            } catch {
                if (
                    IERC20(_tokenAddress).allowance(
                        msg.sender,
                        address(this)
                    ) >= permitAmount
                ) {
                    return;
                }
            }
            revert("Permit failure");
        }
    }
}


// ===== contracts/libraries/ERC20Utils.sol =====
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library ERC20Utils {
    using SafeERC20 for IERC20;
    error NotEnoughSrcFundsIn(uint256 amount);

    function safePull(IERC20 token_, uint256 amount_) internal {
        uint256 balanceBefore = token_.balanceOf(address(this));

        token_.safeTransferFrom(msg.sender, address(this), amount_);

        uint256 transferred = (token_.balanceOf(address(this)) - balanceBefore);

        if (transferred < amount_) revert NotEnoughSrcFundsIn(amount_);
    }

    function lazyApprove(
        IERC20 token_,
        address spender_,
        uint256 amount_
    ) internal {
        uint256 currentAllowance = token_.allowance(address(this), spender_);

        if (currentAllowance < amount_) {
            // if an approval was issued before
            token_.safeApprove(spender_, 0);
            // create permanent approve
            token_.safeApprove(spender_, type(uint256).max);
        }
    }
}


// ===== @openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(account),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// ===== contracts/mock/DummyETHReceiver.sol =====
pragma solidity ^0.8.7;

contract DummyETHReceiver {
    receive() external payable {}
}


// ===== contracts/downscaled-token/DownscaledTokenFactory.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDeBridgeGate} from "./../interfaces/IDeBridgeGate.sol";
import {ERC20Utils} from "./../libraries/ERC20Utils.sol";
import {DownscaledToken} from "./DownscaledToken.sol";

contract DownscaledTokenFactory is Initializable, AccessControlUpgradeable {
    using ERC20Utils for IERC20;
    using ERC20Utils for DownscaledToken;

    IDeBridgeGate _deBridgeGate;

    // Mapping from original token address to deployed wrapped token address
    mapping(address => DownscaledToken) public wrappedTokens;
    mapping(DownscaledToken => address) public originalTokens;

    // Event to emit when a new WrappedToken is created
    event DownscaledTokenCreated(address token, address downscaledToken);

    error WrongArgument();
    error SupplyTooLarge();

    /* ========== INITIALIZERS ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(IDeBridgeGate deBridgeGate_) external initializer {
        _deBridgeGate = deBridgeGate_;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function deployDownscaledToken(
        address token_
    ) public returns (DownscaledToken) {
        // state checks
        if (!(token_ != address(0))) {
            revert WrongArgument();
        }
        // require(token_ != address(0), WrongArgument());
        if (!(wrappedTokens[token_] == DownscaledToken(address(0)))) {
            revert WrongArgument();
        }
        // require(wrappedTokens[token_] == DownscaledToken(address(0)), WrongArgument());

        // reasonable constraints check
        uint256 totalSupply = IERC20(token_).totalSupply();

        // scale check
        uint8 decimals = ERC20(token_).decimals();
        uint8 scaledDecimals = getMaxDecimals(totalSupply, decimals);
        if (!(scaledDecimals < decimals)) {
            revert WrongArgument();
        }
        // require(scaledDecimals < decimals, WrongArgument());

        // debridgeId is a salt
        bytes32 debridgeId = _deBridgeGate.getDebridgeId(
            _deBridgeGate.getChainId(),
            token_
        );

        // deployment code
        bytes memory bytecode = abi.encodePacked(
            type(DownscaledToken).creationCode,
            abi.encode(token_, scaledDecimals)
        );

        DownscaledToken wrappedToken;
        assembly {
            wrappedToken := create2(
                0,
                add(bytecode, 0x20),
                mload(bytecode),
                debridgeId
            )

            if iszero(extcodesize(wrappedToken)) {
                revert(0, 0)
            }
        }

        wrappedTokens[token_] = wrappedToken;
        originalTokens[wrappedToken] = token_;
        emit DownscaledTokenCreated(token_, address(wrappedToken));

        return wrappedToken;
    }

    function deployAndWrapAndSend(
        IERC20 token_,
        uint256 amount_,
        uint256 chainId_,
        bytes memory recipient_,
        uint256 executionFee_
    ) external payable returns (bytes32) {
        deployDownscaledToken(address(token_));
        return
            wrapAndSend(token_, amount_, chainId_, recipient_, executionFee_);
    }

    function wrapAndSend(
        IERC20 token_,
        uint256 amount_,
        uint256 chainId_,
        bytes memory recipient_,
        uint256 executionFee_
    ) public payable returns (bytes32) {
        DownscaledToken wToken = wrappedTokens[address(token_)];
        if (!(address(wToken) != address(0))) {
            revert WrongArgument();
        }
        // require(address(wToken) != address(0), WrongArgument());

        // Adjust _amount so we pull only what is going to be wrapped (avoiding dust)
        uint256 adjustedAmount = wToken.adjustAmount(amount_);

        token_.safePull(adjustedAmount);

        token_.lazyApprove(address(wToken), adjustedAmount);
        uint64 wrappedAmount = wToken.wrap(adjustedAmount);

        wToken.lazyApprove(address(_deBridgeGate), wrappedAmount);
        return
            _sendToBridge(
                wToken,
                wrappedAmount,
                chainId_,
                recipient_,
                wToken.downscaleAmount(executionFee_)
            );
    }

    function getMaxDecimals(
        uint256 totalSupply_,
        uint8 originalDecimals_
    ) public pure returns (uint8) {
        for (
            uint8 wrappedDecimals = originalDecimals_;
            wrappedDecimals > 0;
            wrappedDecimals--
        ) {
            uint256 scaledSupply = totalSupply_ /
                (10 ** (originalDecimals_ - wrappedDecimals));

            // Check if the scaled supply fits within uint64
            if (scaledSupply <= type(uint64).max) {
                return wrappedDecimals; // Return the max valid decimals difference
            }
        }

        // If we reach here, it means we cannot reduce decimals enough to fit in uint64
        revert SupplyTooLarge();
    }

    function _sendToBridge(
        DownscaledToken token_,
        uint64 amount_,
        uint256 chainId_,
        bytes memory recipient_,
        uint64 executionFee_
    ) internal returns (bytes32) {
        IDeBridgeGate.SubmissionAutoParamsTo memory autoParams;
        autoParams.fallbackAddress = recipient_;
        autoParams.executionFee = executionFee_;

        // send to deBridge gate
        return
            _deBridgeGate.send{value: msg.value}(
                address(token_), // _tokenAddress
                amount_, // _amount
                chainId_, // _chainIdTo
                recipient_, // _receiver
                "", // _permit
                false, // _useAssetFee
                0, // _referralCode
                executionFee_ == 0 ? bytes("") : abi.encode(autoParams) // _autoParams
            );
    }

    function version() external pure returns (string memory) {
        return "1.0.0";
    }
}


// ===== @openzeppelin/contracts/utils/Counters.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// ===== contracts/interfaces/IDlnDestination.sol =====
// SPDX-License-Identifier: UNLICENSED
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v0.6.6. SEE SOURCE BELOW. !!
pragma solidity ^0.8.4;

interface IDlnDestination {
    function takeOrders(
        bytes32
    )
        external
        view
        returns (uint8 status, address takerAddress, uint256 giveChainId);
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"inputs":[],"name":"AdminBadRole","type":"error"},{"inputs":[{"internalType":"bytes","name":"expectedBeneficiary","type":"bytes"}],"name":"AllowOnlyForBeneficiary","type":"error"},{"inputs":[],"name":"CallProxyBadRole","type":"error"},{"inputs":[],"name":"EthTransferFailed","type":"error"},{"inputs":[],"name":"ExternalCallIsBlocked","type":"error"},{"inputs":[],"name":"GovMonitoringBadRole","type":"error"},{"inputs":[],"name":"IncorrectOrderStatus","type":"error"},{"inputs":[],"name":"MismatchGiveChainId","type":"error"},{"inputs":[],"name":"MismatchNativeTakerAmount","type":"error"},{"inputs":[],"name":"MismatchTakerAmount","type":"error"},{"inputs":[],"name":"MismatchedOrderId","type":"error"},{"inputs":[],"name":"MismatchedTransferAmount","type":"error"},{"inputs":[{"internalType":"bytes","name":"nativeSender","type":"bytes"},{"internalType":"uint256","name":"chainIdFrom","type":"uint256"}],"name":"NativeSenderBadRole","type":"error"},{"inputs":[],"name":"NotSupportedDstChain","type":"error"},{"inputs":[],"name":"ProposedFeeTooHigh","type":"error"},{"inputs":[],"name":"SignatureInvalidV","type":"error"},{"inputs":[],"name":"TheSameFromTo","type":"error"},{"inputs":[],"name":"TransferAmountNotCoverFees","type":"error"},{"inputs":[],"name":"Unauthorized","type":"error"},{"inputs":[],"name":"UnexpectedBatchSize","type":"error"},{"inputs":[],"name":"UnknownEngine","type":"error"},{"inputs":[],"name":"WrongAddressLength","type":"error"},{"inputs":[],"name":"WrongArgument","type":"error"},{"inputs":[],"name":"WrongAutoArgument","type":"error"},{"inputs":[],"name":"WrongChain","type":"error"},{"inputs":[],"name":"WrongToken","type":"error"},{"inputs":[],"name":"ZeroAddress","type":"error"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bytes32","name":"orderId","type":"bytes32"},{"indexed":false,"internalType":"uint256","name":"orderTakeFinalAmount","type":"uint256"}],"name":"DecreasedTakeAmount","type":"event"},{"anonymous":false,"inputs":[{"components":[{"internalType":"uint64","name":"makerOrderNonce","type":"uint64"},{"internalType":"bytes","name":"makerSrc","type":"bytes"},{"internalType":"uint256","name":"giveChainId","type":"uint256"},{"internalType":"bytes","name":"giveTokenAddress","type":"bytes"},{"internalType":"uint256","name":"giveAmount","type":"uint256"},{"internalType":"uint256","name":"takeChainId","type":"uint256"},{"internalType":"bytes","name":"takeTokenAddress","type":"bytes"},{"internalType":"uint256","name":"takeAmount","type":"uint256"},{"internalType":"bytes","name":"receiverDst","type":"bytes"},{"internalType":"bytes","name":"givePatchAuthoritySrc","type":"bytes"},{"internalType":"bytes","name":"orderAuthorityAddressDst","type":"bytes"},{"internalType":"bytes","name":"allowedTakerDst","type":"bytes"},{"internalType":"bytes","name":"allowedCancelBeneficiarySrc","type":"bytes"},{"internalType":"bytes","name":"externalCall","type":"bytes"}],"indexed":false,"internalType":"struct DlnBase.Order","name":"order","type":"tuple"},{"indexed":false,"internalType":"bytes32","name":"orderId","type":"bytes32"},{"indexed":false,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"address","name":"unlockAuthority","type":"address"}],"name":"FulfilledOrder","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint8","name":"version","type":"uint8"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"account","type":"address"}],"name":"Paused","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"previousAdminRole","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"newAdminRole","type":"bytes32"}],"name":"RoleAdminChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":true,"internalType":"address","name":"sender","type":"address"}],"name":"RoleGranted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":true,"internalType":"address","name":"sender","type":"address"}],"name":"RoleRevoked","type":"event"},{"anonymous":false,"inputs":[{"components":[{"internalType":"uint64","name":"makerOrderNonce","type":"uint64"},{"internalType":"bytes","name":"makerSrc","type":"bytes"},{"internalType":"uint256","name":"giveChainId","type":"uint256"},{"internalType":"bytes","name":"giveTokenAddress","type":"bytes"},{"internalType":"uint256","name":"giveAmount","type":"uint256"},{"internalType":"uint256","name":"takeChainId","type":"uint256"},{"internalType":"bytes","name":"takeTokenAddress","type":"bytes"},{"internalType":"uint256","name":"takeAmount","type":"uint256"},{"internalType":"bytes","name":"receiverDst","type":"bytes"},{"internalType":"bytes","name":"givePatchAuthoritySrc","type":"bytes"},{"internalType":"bytes","name":"orderAuthorityAddressDst","type":"bytes"},{"internalType":"bytes","name":"allowedTakerDst","type":"bytes"},{"internalType":"bytes","name":"allowedCancelBeneficiarySrc","type":"bytes"},{"internalType":"bytes","name":"externalCall","type":"bytes"}],"indexed":false,"internalType":"struct DlnBase.Order","name":"order","type":"tuple"},{"indexed":false,"internalType":"bytes32","name":"orderId","type":"bytes32"},{"indexed":false,"internalType":"bytes","name":"cancelBeneficiary","type":"bytes"},{"indexed":false,"internalType":"bytes32","name":"submissionId","type":"bytes32"}],"name":"SentOrderCancel","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bytes32","name":"orderId","type":"bytes32"},{"indexed":false,"internalType":"bytes","name":"beneficiary","type":"bytes"},{"indexed":false,"internalType":"bytes32","name":"submissionId","type":"bytes32"}],"name":"SentOrderUnlock","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"chainIdFrom","type":"uint256"},{"indexed":false,"internalType":"bytes","name":"dlnSourceAddress","type":"bytes"},{"indexed":false,"internalType":"enum DlnBase.ChainEngine","name":"chainEngine","type":"uint8"}],"name":"SetDlnSourceAddress","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"account","type":"address"}],"name":"Unpaused","type":"event"},{"inputs":[],"name":"BPS_DENOMINATOR","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"DEFAULT_ADMIN_ROLE","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"EVM_ADDRESS_LENGTH","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"GOVMONITORING_ROLE","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAX_ADDRESS_LENGTH","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAX_ORDER_COUNT_PER_BATCH_EVM_UNLOCK","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"NATIVE_AMOUNT_DIVIDER_FOR_TRANSFER_TO_SOLANA","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"SOLANA_ADDRESS_LENGTH","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"SOLANA_CHAIN_ID","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"chainEngines","outputs":[{"internalType":"enum DlnBase.ChainEngine","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"deBridgeGate","outputs":[{"internalType":"contract IDeBridgeGate","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"dlnSourceAddresses","outputs":[{"internalType":"bytes","name":"","type":"bytes"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"uint64","name":"makerOrderNonce","type":"uint64"},{"internalType":"bytes","name":"makerSrc","type":"bytes"},{"internalType":"uint256","name":"giveChainId","type":"uint256"},{"internalType":"bytes","name":"giveTokenAddress","type":"bytes"},{"internalType":"uint256","name":"giveAmount","type":"uint256"},{"internalType":"uint256","name":"takeChainId","type":"uint256"},{"internalType":"bytes","name":"takeTokenAddress","type":"bytes"},{"internalType":"uint256","name":"takeAmount","type":"uint256"},{"internalType":"bytes","name":"receiverDst","type":"bytes"},{"internalType":"bytes","name":"givePatchAuthoritySrc","type":"bytes"},{"internalType":"bytes","name":"orderAuthorityAddressDst","type":"bytes"},{"internalType":"bytes","name":"allowedTakerDst","type":"bytes"},{"internalType":"bytes","name":"allowedCancelBeneficiarySrc","type":"bytes"},{"internalType":"bytes","name":"externalCall","type":"bytes"}],"internalType":"struct DlnBase.Order","name":"_order","type":"tuple"},{"internalType":"uint256","name":"_fulFillAmount","type":"uint256"},{"internalType":"bytes32","name":"_orderId","type":"bytes32"},{"internalType":"bytes","name":"_permitEnvelope","type":"bytes"},{"internalType":"address","name":"_unlockAuthority","type":"address"}],"name":"fulfillOrder","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"getChainId","outputs":[{"internalType":"uint256","name":"cid","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"uint64","name":"makerOrderNonce","type":"uint64"},{"internalType":"bytes","name":"makerSrc","type":"bytes"},{"internalType":"uint256","name":"giveChainId","type":"uint256"},{"internalType":"bytes","name":"giveTokenAddress","type":"bytes"},{"internalType":"uint256","name":"giveAmount","type":"uint256"},{"internalType":"uint256","name":"takeChainId","type":"uint256"},{"internalType":"bytes","name":"takeTokenAddress","type":"bytes"},{"internalType":"uint256","name":"takeAmount","type":"uint256"},{"internalType":"bytes","name":"receiverDst","type":"bytes"},{"internalType":"bytes","name":"givePatchAuthoritySrc","type":"bytes"},{"internalType":"bytes","name":"orderAuthorityAddressDst","type":"bytes"},{"internalType":"bytes","name":"allowedTakerDst","type":"bytes"},{"internalType":"bytes","name":"allowedCancelBeneficiarySrc","type":"bytes"},{"internalType":"bytes","name":"externalCall","type":"bytes"}],"internalType":"struct DlnBase.Order","name":"_order","type":"tuple"}],"name":"getOrderId","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"}],"name":"getRoleAdmin","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"grantRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"hasRole","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"contract IDeBridgeGate","name":"_deBridgeGate","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"uint64","name":"makerOrderNonce","type":"uint64"},{"internalType":"bytes","name":"makerSrc","type":"bytes"},{"internalType":"uint256","name":"giveChainId","type":"uint256"},{"internalType":"bytes","name":"giveTokenAddress","type":"bytes"},{"internalType":"uint256","name":"giveAmount","type":"uint256"},{"internalType":"uint256","name":"takeChainId","type":"uint256"},{"internalType":"bytes","name":"takeTokenAddress","type":"bytes"},{"internalType":"uint256","name":"takeAmount","type":"uint256"},{"internalType":"bytes","name":"receiverDst","type":"bytes"},{"internalType":"bytes","name":"givePatchAuthoritySrc","type":"bytes"},{"internalType":"bytes","name":"orderAuthorityAddressDst","type":"bytes"},{"internalType":"bytes","name":"allowedTakerDst","type":"bytes"},{"internalType":"bytes","name":"allowedCancelBeneficiarySrc","type":"bytes"},{"internalType":"bytes","name":"externalCall","type":"bytes"}],"internalType":"struct DlnBase.Order","name":"_order","type":"tuple"},{"internalType":"uint256","name":"_newSubtrahend","type":"uint256"}],"name":"patchOrderTake","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"pause","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"paused","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"renounceRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"revokeRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32[]","name":"_orderIds","type":"bytes32[]"},{"internalType":"address","name":"_beneficiary","type":"address"},{"internalType":"uint256","name":"_executionFee","type":"uint256"}],"name":"sendBatchEvmUnlock","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"uint64","name":"makerOrderNonce","type":"uint64"},{"internalType":"bytes","name":"makerSrc","type":"bytes"},{"internalType":"uint256","name":"giveChainId","type":"uint256"},{"internalType":"bytes","name":"giveTokenAddress","type":"bytes"},{"internalType":"uint256","name":"giveAmount","type":"uint256"},{"internalType":"uint256","name":"takeChainId","type":"uint256"},{"internalType":"bytes","name":"takeTokenAddress","type":"bytes"},{"internalType":"uint256","name":"takeAmount","type":"uint256"},{"internalType":"bytes","name":"receiverDst","type":"bytes"},{"internalType":"bytes","name":"givePatchAuthoritySrc","type":"bytes"},{"internalType":"bytes","name":"orderAuthorityAddressDst","type":"bytes"},{"internalType":"bytes","name":"allowedTakerDst","type":"bytes"},{"internalType":"bytes","name":"allowedCancelBeneficiarySrc","type":"bytes"},{"internalType":"bytes","name":"externalCall","type":"bytes"}],"internalType":"struct DlnBase.Order","name":"_order","type":"tuple"},{"internalType":"address","name":"_cancelBeneficiary","type":"address"},{"internalType":"uint256","name":"_executionFee","type":"uint256"}],"name":"sendEvmOrderCancel","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"_orderId","type":"bytes32"},{"internalType":"address","name":"_beneficiary","type":"address"},{"internalType":"uint256","name":"_executionFee","type":"uint256"}],"name":"sendEvmUnlock","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"uint64","name":"makerOrderNonce","type":"uint64"},{"internalType":"bytes","name":"makerSrc","type":"bytes"},{"internalType":"uint256","name":"giveChainId","type":"uint256"},{"internalType":"bytes","name":"giveTokenAddress","type":"bytes"},{"internalType":"uint256","name":"giveAmount","type":"uint256"},{"internalType":"uint256","name":"takeChainId","type":"uint256"},{"internalType":"bytes","name":"takeTokenAddress","type":"bytes"},{"internalType":"uint256","name":"takeAmount","type":"uint256"},{"internalType":"bytes","name":"receiverDst","type":"bytes"},{"internalType":"bytes","name":"givePatchAuthoritySrc","type":"bytes"},{"internalType":"bytes","name":"orderAuthorityAddressDst","type":"bytes"},{"internalType":"bytes","name":"allowedTakerDst","type":"bytes"},{"internalType":"bytes","name":"allowedCancelBeneficiarySrc","type":"bytes"},{"internalType":"bytes","name":"externalCall","type":"bytes"}],"internalType":"struct DlnBase.Order","name":"_order","type":"tuple"},{"internalType":"bytes32","name":"_cancelBeneficiary","type":"bytes32"},{"internalType":"uint256","name":"_executionFee","type":"uint256"},{"internalType":"uint64","name":"_reward1","type":"uint64"},{"internalType":"uint64","name":"_reward2","type":"uint64"}],"name":"sendSolanaOrderCancel","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"uint64","name":"makerOrderNonce","type":"uint64"},{"internalType":"bytes","name":"makerSrc","type":"bytes"},{"internalType":"uint256","name":"giveChainId","type":"uint256"},{"internalType":"bytes","name":"giveTokenAddress","type":"bytes"},{"internalType":"uint256","name":"giveAmount","type":"uint256"},{"internalType":"uint256","name":"takeChainId","type":"uint256"},{"internalType":"bytes","name":"takeTokenAddress","type":"bytes"},{"internalType":"uint256","name":"takeAmount","type":"uint256"},{"internalType":"bytes","name":"receiverDst","type":"bytes"},{"internalType":"bytes","name":"givePatchAuthoritySrc","type":"bytes"},{"internalType":"bytes","name":"orderAuthorityAddressDst","type":"bytes"},{"internalType":"bytes","name":"allowedTakerDst","type":"bytes"},{"internalType":"bytes","name":"allowedCancelBeneficiarySrc","type":"bytes"},{"internalType":"bytes","name":"externalCall","type":"bytes"}],"internalType":"struct DlnBase.Order","name":"_order","type":"tuple"},{"internalType":"bytes32","name":"_beneficiary","type":"bytes32"},{"internalType":"uint256","name":"_executionFee","type":"uint256"},{"internalType":"uint64","name":"_solanaExternalCallReward1","type":"uint64"},{"internalType":"uint64","name":"_solanaExternalCallReward2","type":"uint64"}],"name":"sendSolanaUnlock","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_chainIdFrom","type":"uint256"},{"internalType":"bytes","name":"_dlnSourceAddress","type":"bytes"},{"internalType":"enum DlnBase.ChainEngine","name":"_chainEngine","type":"uint8"}],"name":"setDlnSourceAddress","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"takeOrders","outputs":[{"internalType":"enum DlnDestination.OrderTakeStatus","name":"status","type":"uint8"},{"internalType":"address","name":"takerAddress","type":"address"},{"internalType":"uint256","name":"giveChainId","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"takePatches","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"unpause","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"version","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"}]
*/

