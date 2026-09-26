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
