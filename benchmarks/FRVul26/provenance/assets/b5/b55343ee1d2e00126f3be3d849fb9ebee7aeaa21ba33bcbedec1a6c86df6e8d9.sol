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
