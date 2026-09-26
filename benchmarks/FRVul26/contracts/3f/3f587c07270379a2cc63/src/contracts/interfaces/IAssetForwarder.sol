// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Interface for handler contracts that support deposits and deposit executions.
/// @author Router Protocol.
interface IAssetForwarder {
    event FundsDeposited(
        uint256 partnerId,
        uint256 amount,
        bytes32 destChainIdBytes,
        uint256 destAmount,
        uint256 depositId,
        address srcToken,
        address depositor,
        bytes recipient,
        bytes destToken
    );

    event FundsDepositedWithMessage(
        uint256 partnerId,
        uint256 amount,
        bytes32 destChainIdBytes,
        uint256 destAmount,
        uint256 depositId,
        address srcToken,
        bytes recipient,
        address depositor,
        bytes destToken,
        bytes message
    );
    event FundsPaid(bytes32 messageHash, address forwarder, uint256 nonce);

    event DepositInfoUpdate(
        address srcToken,
        uint256 feeAmount,
        uint256 depositId,
        uint256 eventNonce,
        bool initiatewithdrawal,
        address depositor
    );

    event FundsPaidWithMessage(
        bytes32 messageHash,
        address forwarder,
        uint256 nonce,
        bool execFlag,
        bytes execData
    );

    struct RelayData {
        uint256 amount;
        bytes32 srcChainId;
        uint256 depositId;
        address destToken;
        address recipient;
    }

    struct RelayDataMessage {
        uint256 amount;
        bytes32 srcChainId;
        uint256 depositId;
        address destToken;
        address recipient;
        bytes message;
    }

    struct DepositData {
        uint256 partnerId;
        uint256 amount;
        uint256 destAmount;
        address srcToken;
        address refundRecipient;
        bytes32 destChainIdBytes;
    }

    function iDeposit(
        DepositData memory depositData,
        bytes memory destToken,
        bytes memory recipient
    ) external payable;

    function iDepositInfoUpdate(
        address srcToken,
        uint256 feeAmount,
        uint256 depositId,
        bool initiatewithdrawal
    ) external payable;

    function iDepositMessage(
        DepositData memory depositData,
        bytes memory destToken,
        bytes memory recipient,
        bytes memory message
    ) external payable;

    function iRelay(RelayData memory relayData) external payable;

    function iRelayMessage(RelayDataMessage memory relayData) external payable;
}
