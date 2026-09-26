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
