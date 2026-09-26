// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./interface/IBebopSettlement.sol";
import "./base/BebopSigning.sol";
import "./base/BebopTransfer.sol";
import "./libs/Order.sol";
import "./libs/Signature.sol";
import "./libs/Transfer.sol";

contract BebopSettlement is IBebopSettlement, BebopSigning, BebopTransfer {

    using SafeERC20 for IERC20;

    constructor(address _wrappedNativeToken, address _permit2, address _daiAddress)
        BebopTransfer(_wrappedNativeToken, _permit2, _daiAddress) {
    }

    receive() external payable {}


    //-----------------------------------------
    //
    //      One-to-One trade with one maker
    //           taker execution (RFQ-T)
    //
    // -----------------------------------------

    /// @inheritdoc IBebopSettlement
    function swapSingle(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount
    ) external override payable {
        if (msg.sender != order.taker_address) revert InvalidSender();
        _executeSingleOrder(order, makerSignature, filledTakerAmount, Commands.SIMPLE_TRANSFER, order.maker_amount);
    }

    /// @inheritdoc IBebopSettlement
    function swapSingleFromContract(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature
    ) external override payable {
        if (msg.sender != order.taker_address) revert InvalidSender();
        _executeSingleOrder(
            order, makerSignature, IERC20(order.taker_token).balanceOf(address(this)), Commands.TRANSFER_FROM_CONTRACT, order.maker_amount
        );
    }


    //-----------------------------------------
    //
    //      One-to-One trade with one maker
    //           maker execution (RFQ-M)
    //
    // -----------------------------------------

    /// @inheritdoc IBebopSettlement
    function settleSingle(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldSingleQuote calldata takerQuoteInfo,
        bytes calldata takerSignature
    ) external override payable {
        _validateTakerSignatureForSingleOrder(order, takerSignature, takerQuoteInfo);
        _executeSingleOrder(
            order, makerSignature, filledTakerAmount, Commands.SIMPLE_TRANSFER,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmount : order.maker_amount
        );
    }

    /// @inheritdoc IBebopSettlement
    function settleSingleAndSignPermit(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldSingleQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.PermitSignature calldata takerPermitSignature
    ) external override payable {
        _validateTakerSignatureForSingleOrder(order, takerSignature, takerQuoteInfo);
        _tokenPermit(order.taker_address, order.taker_token, takerPermitSignature);
        _executeSingleOrder(
            order, makerSignature, filledTakerAmount, Commands.SIMPLE_TRANSFER,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmount : order.maker_amount
        );
    }

    /// @inheritdoc IBebopSettlement
    function settleSingleAndSignPermit2(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldSingleQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.Permit2Signature calldata takerPermit2Signature
    ) external override payable {
        _validateTakerSignatureForSingleOrder(order, takerSignature, takerQuoteInfo);
        _tokenPermit2(order.taker_address, order.taker_token, takerPermit2Signature);
        _executeSingleOrder(
            order, makerSignature, filledTakerAmount, Commands.PERMIT2_TRANSFER,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmount : order.maker_amount
        );
    }


    //------------------------------------------------------
    //
    //      Many-to-One or One-to-Many trade with one maker
    //                taker execution (RFQ-T)
    //
    // ------------------------------------------------------

    /// @inheritdoc IBebopSettlement
    function swapMulti(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount
    ) external override payable {
        if (msg.sender != order.taker_address) revert InvalidSender();
        _executeMultiOrder(order, makerSignature, filledTakerAmount, order.maker_amounts);
    }


    //------------------------------------------------------
    //
    //      Many-to-One or One-to-Many trade with one maker
    //                maker execution (RFQ-M)
    //
    // ------------------------------------------------------

    /// @inheritdoc IBebopSettlement
    function settleMulti(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldMultiQuote calldata takerQuoteInfo,
        bytes calldata takerSignature
    ) external override payable {
        _validateTakerSignatureForMultiOrder(order, takerSignature, takerQuoteInfo);
        _executeMultiOrder(
            order, makerSignature, filledTakerAmount,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmounts : order.maker_amounts
        );
    }

    /// @inheritdoc IBebopSettlement
    function settleMultiAndSignPermit(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldMultiQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.PermitSignature calldata takerPermitSignature
    ) external override payable {
        _validateTakerSignatureForMultiOrder(order, takerSignature, takerQuoteInfo);
        _tokenPermitForMultiOrder(order, takerPermitSignature);
        _executeMultiOrder(
            order, makerSignature, filledTakerAmount,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmounts : order.maker_amounts
        );
    }

    /// @inheritdoc IBebopSettlement
    function settleMultiAndSignPermit2(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldMultiQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.MultiTokensPermit2Signature calldata infoPermit2
    ) external override payable {
        _validateTakerSignatureForMultiOrder(order, takerSignature, takerQuoteInfo);
        _tokensPermit2ForMultiOrder(order, infoPermit2);
        _executeMultiOrder(
            order, makerSignature, filledTakerAmount,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmounts : order.maker_amounts
        );
    }


    //-----------------------------------------
    //
    //      Any trade with multiple makers
    //          taker execution (RFQ-T)
    //
    // ----------------------------------------

    /// @inheritdoc IBebopSettlement
    function swapAggregate(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount
    ) external override payable {
        if (msg.sender != order.taker_address) revert InvalidSender();
        _executeAggregateOrder(order, makersSignatures, filledTakerAmount, order.maker_amounts);
    }


    //-----------------------------------------
    //
    //      Any trade with multiple makers
    //          maker execution (RFQ-M)
    //
    // ----------------------------------------

    /// @inheritdoc IBebopSettlement
    function settleAggregate(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount,
        Transfer.OldAggregateQuote calldata takerQuoteInfo,
        bytes calldata takerSignature
    ) external override payable {
        _validateTakerSignatureForAggregateOrder(order, takerSignature, takerQuoteInfo);
        _executeAggregateOrder(
            order, makersSignatures, filledTakerAmount,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmounts : order.maker_amounts
        );
    }

    /// @inheritdoc IBebopSettlement
    function settleAggregateAndSignPermit(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount,
        Transfer.OldAggregateQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.PermitSignature calldata takerPermitSignature
    ) external override payable {
        _validateTakerSignatureForAggregateOrder(order, takerSignature, takerQuoteInfo);
        _tokenPermitForAggregateOrder(order, takerPermitSignature);
        _executeAggregateOrder(
            order, makersSignatures, filledTakerAmount,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmounts : order.maker_amounts
        );
    }

    /// @inheritdoc IBebopSettlement
    function settleAggregateAndSignPermit2(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount,
        Transfer.OldAggregateQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.MultiTokensPermit2Signature calldata infoPermit2
    ) external override payable {
        _validateTakerSignatureForAggregateOrder(order, takerSignature, takerQuoteInfo);
        _tokensPermit2ForAggregateOrder(order, infoPermit2);
        _executeAggregateOrder(
            order, makersSignatures, filledTakerAmount,
            takerQuoteInfo.useOldAmount ? takerQuoteInfo.makerAmounts : order.maker_amounts
        );
    }


    /// @notice Execute One-to-One trade with one maker
    /// @param order All information about order
    /// @param makerSignature Maker signature for SingleOrder
    /// @param filledTakerAmount Token amount which taker wants to swap, should be less or equal to order.taker_amount
    ///                          if filledTakerAmount == 0 then order.taker_amount will be used
    /// @param takerTransferCommand Command to indicate how to transfer taker's token
    /// @param updatedMakerAmount for RFQ-M case maker amount can be improved
    function _executeSingleOrder(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        bytes1 takerTransferCommand,
        uint256 updatedMakerAmount
    ) internal {
        _validateSingleOrder(order, makerSignature);
        (uint128 eventId, uint64 partnerId) = Order.extractFlags(order.flags);
        (bool takerHasNative, bool makerHasNative, bool takerUsingPermit2) = Order.extractSingleOrderCommands(order.packed_commands);
        if (takerTransferCommand == Commands.TRANSFER_FROM_CONTRACT && takerHasNative){
            filledTakerAmount = address(this).balance;
        }
        _transferToken(
            order.taker_address, order.maker_address, order.taker_token,
            filledTakerAmount == 0 || filledTakerAmount > order.taker_amount ? order.taker_amount : filledTakerAmount,
            takerHasNative ? Commands.NATIVE_TRANSFER : (takerUsingPermit2 ? Commands.PERMIT2_TRANSFER : takerTransferCommand),
            takerHasNative ? Transfer.Action.Wrap : Transfer.Action.None, 0
        );
        uint256 newMakerAmount = updatedMakerAmount;
        if (filledTakerAmount != 0 && filledTakerAmount < order.taker_amount){
            newMakerAmount = (updatedMakerAmount * filledTakerAmount) / order.taker_amount;
        }
        (bool makerUsingPermit2, ) = Signature.extractMakerFlags(makerSignature.flags);
        _transferToken(
            order.maker_address, order.receiver, order.maker_token, newMakerAmount,
            makerUsingPermit2 ? Commands.PERMIT2_TRANSFER : Commands.SIMPLE_TRANSFER,
            makerHasNative ? Transfer.Action.Unwrap : Transfer.Action.None, partnerId
        );
        emit BebopOrder(eventId);
    }

    /// @notice Execute Many-to-One or One-to-Many trade with one maker
    /// @param order All information about order
    /// @param makerSignature Maker signature for SingleOrder
    /// @param filledTakerAmount Token amount which taker wants to swap, should be less or equal to order.taker_amount
    ///  if filledTakerAmount == 0 then order.taker_amounts will be used, Many-to-One trades don't support partial fill
    /// @param updatedMakerAmounts for RFQ-M case maker amounts can be improved
    function _executeMultiOrder(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        uint256[] calldata updatedMakerAmounts
    ) internal {
        _validateMultiOrder(order, makerSignature, filledTakerAmount);
        (uint128 eventId, uint64 partnerId) = Order.extractFlags(order.flags);
        (bool makerUsingPermit2, ) = Signature.extractMakerFlags(makerSignature.flags);
        if (order.taker_tokens.length > 1){ // Many-to-One
            // transfer taker's tokens
            _transferTakerTokens(order);

            // transfer maker's token
            _transferToken(
                order.maker_address, order.receiver, order.maker_tokens[0], updatedMakerAmounts[0],
                makerUsingPermit2 ? Commands.PERMIT2_TRANSFER : Commands.SIMPLE_TRANSFER,
                order.commands[0] == Commands.NATIVE_TRANSFER ? Transfer.Action.Unwrap : Transfer.Action.None, partnerId
            );
        } else { // One-to-Many
            // transfer taker's token
            bytes1 takerCommand = order.commands[order.maker_tokens.length];
            _transferToken(
                order.taker_address, order.maker_address, order.taker_tokens[0],
                filledTakerAmount == 0 || filledTakerAmount > order.taker_amounts[0] ?
                    order.taker_amounts[0] : filledTakerAmount,
                takerCommand, takerCommand == Commands.NATIVE_TRANSFER ? Transfer.Action.Wrap : Transfer.Action.None, 0
            );

            // transfer maker's tokens
            uint[] memory makerAmounts = updatedMakerAmounts;
            if (filledTakerAmount > 0 && filledTakerAmount < order.taker_amounts[0]){
                for (uint j; j < updatedMakerAmounts.length; ++j){
                    makerAmounts[j] = updatedMakerAmounts[j] * filledTakerAmount / order.taker_amounts[0];
                }
            }
            uint nativeToTaker = _transferMakerTokens(
                order.maker_address, order.receiver, order.maker_tokens, makerAmounts, makerUsingPermit2,
                order.commands, partnerId
            );
            if (nativeToTaker > 0){
                IWETH(WRAPPED_NATIVE_TOKEN).withdraw(nativeToTaker);
                (bool sent,) = order.receiver.call{value: nativeToTaker}("");
                if (!sent) revert FailedToSendNativeToken();
            }
        }
        emit BebopOrder(eventId);
    }

    /// @notice Execute trade with multiple makers
    /// @param order All information about order
    /// @param makersSignatures Maker signatures for part of AggregateOrder(which is MultiOrder)
    /// @param filledTakerAmount Token amount which taker wants to swap, should be less or equal to order.taker_amount
    ///  if filledTakerAmount == 0 then order.taker_amounts will be used, Many-to-One trades don't support partial fill
    /// @param updatedMakerAmounts for RFQ-M case maker amounts can be improved
    function _executeAggregateOrder(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount,
        uint256[][] calldata updatedMakerAmounts
    ) internal {
        _validateAggregateOrder(order, makersSignatures);
        (uint quoteTakerAmount, Transfer.LengthsInfo memory lenInfo) = _getAggregateOrderInfo(order, filledTakerAmount);
        Transfer.IndicesInfo memory indices = Transfer.IndicesInfo(0, 0, 0);
        Transfer.NativeTokens memory nativeTokens = Transfer.NativeTokens(0, 0);
        Transfer.Pending[] memory pendingTransfers = new Transfer.Pending[](lenInfo.pendingTransfersLen);
        IPermit2.AllowanceTransferDetails[] memory batchTransferDetails = new IPermit2.AllowanceTransferDetails[](lenInfo.permit2Len);
        for (uint i; i < order.maker_tokens.length; ++i){
            (bool makerUsingPermit2, ) = Signature.extractMakerFlags(makersSignatures[i].flags);
            uint[] memory makerAmounts = updatedMakerAmounts[i];
            if (filledTakerAmount > 0 && filledTakerAmount < quoteTakerAmount){ // partial fill
                for (uint j; j < updatedMakerAmounts[i].length; ++j){
                    makerAmounts[j] = updatedMakerAmounts[i][j] * filledTakerAmount / quoteTakerAmount;
                }
            }
            nativeTokens.toTaker += _transferMakerTokens(
                order.maker_addresses[i], order.receiver, order.maker_tokens[i], makerAmounts,
                makerUsingPermit2, BytesLib.slice(order.commands, indices.commandsInd, order.maker_tokens[i].length),
                Order.extractPartnerId(order.flags)
            );
            indices.commandsInd += order.maker_tokens[i].length;
            _transferTakerTokensForAggregateOrder(
                order, i, filledTakerAmount, quoteTakerAmount, indices, nativeTokens, pendingTransfers, batchTransferDetails
            );
            indices.commandsInd += order.taker_tokens[i].length;
        }
        if (indices.pendingTransfersInd != lenInfo.pendingTransfersLen) revert InvalidPendingTransfersLength();
        if (indices.permit2Ind != lenInfo.permit2Len) revert InvalidPermit2TransfersLength();
        if (lenInfo.permit2Len > 0) {
            // Transfer taker's tokens with Permit2 batch
            PERMIT2.transferFrom(batchTransferDetails);
        }

        // Transfer tokens from contract to makers
        if (lenInfo.pendingTransfersLen > 0) {
            // Wrap taker's native token
            if (nativeTokens.toMakers > 0){
                if (msg.value < nativeTokens.toMakers) revert NotEnoughNativeToken();
                IWETH(WRAPPED_NATIVE_TOKEN).deposit{value: nativeTokens.toMakers}();
            }
            for (uint i; i < pendingTransfers.length; ++i) {
                if (pendingTransfers[i].amount > 0) {
                    IERC20(pendingTransfers[i].token).safeTransfer(
                        pendingTransfers[i].to, pendingTransfers[i].amount
                    );
                }
            }
        }

        // Unwrap and transfer native token to receiver
        if (nativeTokens.toTaker > 0) {
            IWETH(WRAPPED_NATIVE_TOKEN).withdraw(nativeTokens.toTaker);
            (bool sent,) = order.receiver.call{value: nativeTokens.toTaker}("");
            if (!sent) revert FailedToSendNativeToken();
        }

        emit BebopOrder(Order.extractEventId(order.flags));
    }

}
