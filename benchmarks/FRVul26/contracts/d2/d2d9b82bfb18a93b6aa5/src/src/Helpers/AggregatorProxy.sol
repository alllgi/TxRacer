// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ReentrancyGuard} from "src/Helpers/ReentrancyGuard.sol";
import {RouterErrors} from "src/Errors/RouterErrors.sol";
import {LibFeeCollector} from "src/Libraries/LibFeeCollector.sol";

contract AggregatorProxy is ReentrancyGuard {
    using SafeERC20 for IERC20;

    event FeeCollected(address token, address recipient, uint256 amount);

    uint256 private constant FEE_PERCENTAGE_BASE = 10000;
    address private immutable aggregator;

    constructor(address _aggregator) {
        require(_aggregator != address(0) && _aggregator.code.length > 100, "AggregatorProxy: invalid aggregator");
        aggregator = _aggregator;
    }

    function _parseAddressAndFee(uint256 tokenWithFee) internal pure returns (address token, uint16 fee) {
        token = address(uint160(tokenWithFee));
        fee = uint16(tokenWithFee >> 160);
        require(fee < FEE_PERCENTAGE_BASE, "AggregatorProxy: invalid fee");
    }

    function _callAggregator(
        uint256 fromTokenWithFee,
        uint256 fromAmount,
        uint256 toTokenWithFee,
        bytes calldata callData
    ) internal nonReentrant {
        uint256 ethBalanceBefore = address(this).balance - msg.value;
        (address fromToken, uint16 fromFee) = _parseAddressAndFee(fromTokenWithFee);
        uint256 fromTokenBalanceBefore;
        uint256 msgValue = msg.value;
        address feeRecipient = LibFeeCollector.getRecipient();
        if (fromToken == address(0)) {
            if (fromFee > 0) {
                // Use feeAmount because cross-chain transactions charge an additional native token as bridge fee.
                uint256 feeAmt = (fromAmount * fromFee) / FEE_PERCENTAGE_BASE;
                msgValue -= feeAmt;
                _callAndBubblingRevert(feeRecipient, "", feeAmt);
                emit FeeCollected(fromToken, feeRecipient, feeAmt);
            }
        } else {
            fromTokenBalanceBefore = IERC20(fromToken).balanceOf(address(this));
            if (fromFee > 0) {
                uint256 feeAmt = (fromAmount * fromFee) / FEE_PERCENTAGE_BASE;
                fromAmount -= feeAmt;
                IERC20(fromToken).safeTransferFrom(msg.sender, feeRecipient, feeAmt);
                emit FeeCollected(fromToken, feeRecipient, feeAmt);
            }
            IERC20(fromToken).safeTransferFrom(msg.sender, address(this), fromAmount);
            if (!_makeCall(IERC20(fromToken), IERC20.approve.selector, aggregator, fromAmount)) {
                revert RouterErrors.ApproveFailed();
            }
        }

        (address toToken, uint16 toFee) = _parseAddressAndFee(toTokenWithFee);
        uint256 toTokenBalanceBefore;
        if (toFee > 0 && toToken != address(0)) {
            toTokenBalanceBefore = IERC20(toToken).balanceOf(address(this));
        }

        _callAndBubblingRevert(aggregator, callData, msgValue);

        if (fromToken != address(0)) {
            uint256 balanceDiff = IERC20(fromToken).balanceOf(address(this)) - fromTokenBalanceBefore;
            if (balanceDiff > 0) {
                IERC20(fromToken).safeTransfer(msg.sender, balanceDiff);
            }
            if (!_makeCall(IERC20(fromToken), IERC20.approve.selector, aggregator, 0)) {
                revert RouterErrors.ApproveFailed();
            }
        }

        if (toToken == address(0)) {
            uint256 balanceDiff = address(this).balance - ethBalanceBefore;
            if (balanceDiff > 0) {
                uint256 feeAmt = (balanceDiff * toFee) / FEE_PERCENTAGE_BASE;
                _callAndBubblingRevert(msg.sender, "", balanceDiff - feeAmt);
                if (feeAmt > 0) {
                    _callAndBubblingRevert(feeRecipient, "", feeAmt);
                }
                emit FeeCollected(toToken, feeRecipient, feeAmt);
            }
        } else {
            uint256 balanceDiff = IERC20(toToken).balanceOf(address(this)) - toTokenBalanceBefore;
            if (balanceDiff > 0) {
                uint256 feeAmt = (balanceDiff * toFee) / FEE_PERCENTAGE_BASE;
                IERC20(toToken).safeTransfer(msg.sender, balanceDiff - feeAmt);
                if (feeAmt > 0) {
                    IERC20(toToken).safeTransfer(feeRecipient, feeAmt);
                }
                emit FeeCollected(toToken, feeRecipient, feeAmt);
            }
        }
    }

    function _callAndBubblingRevert(address to, bytes memory callData, uint256 value) private {
        (bool success, bytes memory result) = to.call{value: value}(callData);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function _makeCall(IERC20 token, bytes4 selector, address to, uint256 amount) private returns (bool success) {
        assembly ("memory-safe") {
            // solhint-disable-line no-inline-assembly
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), to)
            mstore(add(data, 0x24), amount)
            success := call(gas(), token, 0, data, 0x44, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 { success := gt(extcodesize(token), 0) }
                default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
            }
        }
    }
}
