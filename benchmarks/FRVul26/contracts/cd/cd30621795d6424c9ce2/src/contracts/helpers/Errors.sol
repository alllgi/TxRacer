// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library XBridgeErrors {
    string internal constant ONLY_X_BRIDGE = "only XBridge";
    string internal constant ONLY_MPC = "only mpc";
    string internal constant ONLY_ADMIN = "only admin";
    string internal constant ADDRESS_0 = "address 0";
    string internal constant LENGTH_NOT_EQUAL = "length not equal";
    string internal constant DEX_ROUTER_ERR = "dex router err : ";
    string internal constant ADDRESS_EQUAL = "address equal";
    string internal constant ADDRESS_NOT_EQUAL = "address not equal";
    string internal constant MIN_AMOUNT_ERR = "min amount err";
    string internal constant REFUND_ETH_ERROR = "refund eth err";
    string internal constant REFUND_EXIST = "refund exist";
    string internal constant CBRIDGE_HAS_WITHDRAW = "has withdraw";
    string internal constant HAS_PAID = "has paid";
    string internal constant HAS_RECEIVE_GAS = "has receive gas";
    string internal constant NO_ENOUGH_MONEY = "no enough money";
    string internal constant SLASH_MUCH_TOO_MONEY = "slash much too money";
    string internal constant ERROR_SELECTOR_ID = "err selector id";
    string internal constant EXCEED_ALLOWED_GAS = "exceed allowed gas";
    string internal constant ALLOWANCE_NOT_ENOUGH = "allowance not enough";
    string internal constant ORACLE_NO_INFO = "claim no oracle info";
    string internal constant ORACLE_TO_ADDRESS_ERR = "claim to address err";
    string internal constant ORACLE_TOKEN_ADDRESS_ERR = "claim token address err";
    string internal constant ORACLE_TOKEN_AMOUNT_ERR = "claim token amount err";
    string internal constant NOT_ORACLE_PROXY = "not oracle proxy";
    string internal constant ERR_CHAIN_ID = "err chain id";
    string internal constant ZERO_SIGNER = "zero signer";
    string internal constant CONTRACT_ADDRESS_ERROR = "contract address error";
    string internal constant INTERNAL_WRAP_FAIL = "internal wrap fail";
    string internal constant WRAP_AMOUNT_ZERO = "wrap amount must be > 0";
    string internal constant TRANSFER_ETH_FAILD = "ETH transfer failed";
    string internal constant AMOUNT_ZERO = "amount must be > 0";
    string internal constant MIN_AMOUNT_ZERO = "min amount must be > 0";
    string internal constant LEFT_VALUE_NOT_ZERO = "left value must be 0";

    string internal constant NOT_SUPPORT_CHAIN = "not support chain";
    string internal constant NOT_SUPPORT_TOKEN = "not support token";
    string internal constant AMOUNT_NOT_EQ_VALUE = "amount must == msg.value";
    string internal constant VALUE_NOT_ENOUGH = "amount must <= msg.value";
    string internal constant VALUE_MUST_ZERO = "msg.value == 0";
    string internal constant INVALID_ADAPTOR_ID = "invalid adaptorID";
    string internal constant INVALID_ADAPTOR_ADDRESS = "invalid adaptor address";
    string internal constant INVALID_ROUTER = "invalid router";
    string internal constant INVALID_MSG_VALUE = "invalid msg value";

    string internal constant COMMISSION_ERROR_RATE = "error commission rate limit";
    string internal constant COMMISSION_ERROR_ETHER = "commission with ether error";
}