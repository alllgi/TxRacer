// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IDaiLikePermit.sol";
import "../interface/IPermit2.sol";
import "../interface/IWETH.sol";
import "../libs/Order.sol";
import "../libs/Signature.sol";
import "../libs/Transfer.sol";
import "../libs/Commands.sol";
import "../libs/common/SafeCast160.sol";
import "./BebopSigning.sol";
import "./BebopPartner.sol";
import "./Errors.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract BebopTransfer is BebopPartner {

    using SafeERC20 for IERC20;

    address internal immutable WRAPPED_NATIVE_TOKEN;
    address internal immutable DAI_TOKEN;

    IPermit2 internal immutable PERMIT2;

    uint private immutable _chainId;

    function _getChainId() private view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    constructor(address _wrappedNativeToken, address _permit2, address _daiAddress) {
        WRAPPED_NATIVE_TOKEN = _wrappedNativeToken;
        DAI_TOKEN = _daiAddress;
        PERMIT2 = IPermit2(_permit2);
        _chainId = _getChainId();
    }

    /// @notice Validates that partial fill is allowed and extract necessary information from Aggregate order
    /// @return quoteTakerAmount - full taker_amount for One-to-One or One-to-Many trades, for Many-to-One orders it's 0
    /// @return lenInfo - lengths of `pendingTransfers` and `batchTransferDetails` arrays
    function _getAggregateOrderInfo(
        Order.Aggregate calldata order,
        uint256 filledTakerAmount
    ) internal pure returns (uint quoteTakerAmount, Transfer.LengthsInfo memory lenInfo){
        uint commandsInd;
        address tokenAddress = order.taker_tokens[0][0];
        for (uint i; i < order.taker_tokens.length; ++i){
            commandsInd += order.maker_tokens[i].length;
            for (uint j; j < order.taker_tokens[i].length; ++j) {
                bytes1 curCommand = order.commands[commandsInd + j];
                if (curCommand != Commands.TRANSFER_FROM_CONTRACT){
                    if (filledTakerAmount > 0){
                        /// @dev partial fills works only for One-to-One or One-to-Many trades,
                        /// filledTakerAmount is partially filled amount of taker's token,
                        /// so filledTakerAmount should be 0 for Many-to-One orders and orders without partial fills
                        quoteTakerAmount += order.taker_amounts[i][j];
                        if (tokenAddress != order.taker_tokens[i][j]){
                            revert PartialFillNotSupported();
                        }
                    }
                    if (curCommand == Commands.NATIVE_TRANSFER) {
                        ++lenInfo.pendingTransfersLen;
                    } else if (curCommand == Commands.PERMIT2_TRANSFER || curCommand == Commands.CALL_PERMIT2_THEN_TRANSFER) {
                        ++lenInfo.permit2Len;
                    }
                } else {
                    ++lenInfo.pendingTransfersLen;
                }
            }
            commandsInd += order.taker_tokens[i].length;
        }
    }

    /// @notice Universal function for transferring tokens
    /// @param from address from which tokens will be transferred
    /// @param to address to which tokens will be transferred
    /// @param token address of token
    /// @param amount amount of token
    /// @param command Commands to indicate how to transfer token
    /// @param action Wrap or Unwrap native token
    /// @param partnerId identifier of partner to pay referral fee
    function _transferToken(
        address from, address to, address token, uint256 amount, bytes1 command, Transfer.Action action, uint64 partnerId
    ) internal {
        if (action == Transfer.Action.Wrap){
            if (token != WRAPPED_NATIVE_TOKEN) revert WrongWrappedTokenAddress();
            IWETH(WRAPPED_NATIVE_TOKEN).deposit{value: amount}();
        }
        uint fee;
        PartnerInfo memory partnerInfo;
        if (partnerId != 0){
            partnerInfo = partners[partnerId];
            if (partnerInfo.registered && partnerInfo.fee > 0){
                fee = amount * partnerInfo.fee / HUNDRED_PERCENT;
            }
        }
        address receiver = action == Transfer.Action.Unwrap ? address(this) : to;
        if (command == Commands.SIMPLE_TRANSFER || command == Commands.CALL_PERMIT_THEN_TRANSFER){
            if (fee > 0){
                IERC20(token).safeTransferFrom(from, partnerInfo.beneficiary, fee);
                amount -= fee;
            }
            IERC20(token).safeTransferFrom(from, receiver, amount);
        } else if (command == Commands.PERMIT2_TRANSFER || command == Commands.CALL_PERMIT2_THEN_TRANSFER){
            if (fee > 0){
                amount -= fee;
                IPermit2.AllowanceTransferDetails[] memory batchTransferDetails = new IPermit2.AllowanceTransferDetails[](2);
                batchTransferDetails[0] = IPermit2.AllowanceTransferDetails(from, partnerInfo.beneficiary, SafeCast160.toUint160(fee), token);
                batchTransferDetails[1] = IPermit2.AllowanceTransferDetails(from, receiver, SafeCast160.toUint160(amount), token);
                PERMIT2.transferFrom(batchTransferDetails);
            } else {
                PERMIT2.transferFrom(from, receiver, SafeCast160.toUint160(amount), token);
            }
        } else if (command == Commands.TRANSFER_FROM_CONTRACT || command == Commands.NATIVE_TRANSFER){
            IERC20(token).safeTransfer(to, amount);
        } else {
            revert InvalidCommand();
        }
        if (action == Transfer.Action.Unwrap){
            if (token != WRAPPED_NATIVE_TOKEN) revert WrongWrappedTokenAddress();
            IWETH(WRAPPED_NATIVE_TOKEN).withdraw(amount);
            (bool sent,) = to.call{value: amount}("");
            if (!sent) revert FailedToSendNativeToken();
        }
    }

    /// @notice For MultiOrder transfer taker's tokens to maker
    /// @param order MultiOrder
    function _transferTakerTokens(Order.Multi calldata order) internal {
        IPermit2.AllowanceTransferDetails[] memory batchTransferDetails;
        uint permit2Ind;
        for (uint i; i < order.taker_tokens.length; ++i) {
            bytes1 command = order.commands[i + order.maker_tokens.length];
            if (command == Commands.SIMPLE_TRANSFER || command == Commands.CALL_PERMIT_THEN_TRANSFER){
                IERC20(order.taker_tokens[i]).safeTransferFrom(
                    order.taker_address, order.maker_address, order.taker_amounts[i]
                );
            } else if (command == Commands.PERMIT2_TRANSFER || command == Commands.CALL_PERMIT2_THEN_TRANSFER){
                if (batchTransferDetails.length == 0){
                    batchTransferDetails = new IPermit2.AllowanceTransferDetails[](order.taker_tokens.length - i);
                }
                batchTransferDetails[permit2Ind++] = IPermit2.AllowanceTransferDetails({
                    from: order.taker_address,
                    to: order.maker_address,
                    amount: SafeCast160.toUint160(order.taker_amounts[i]),
                    token: order.taker_tokens[i]
                });
                continue;
            } else if (command == Commands.NATIVE_TRANSFER) {
                if (order.taker_tokens[i] != WRAPPED_NATIVE_TOKEN) revert WrongWrappedTokenAddress();
                IWETH(WRAPPED_NATIVE_TOKEN).deposit{value: order.taker_amounts[i]}();
                IERC20(WRAPPED_NATIVE_TOKEN).safeTransfer(order.maker_address, order.taker_amounts[i]);
            } else {
                revert InvalidCommand();
            }
            if (batchTransferDetails.length > 0){
                assembly {mstore(batchTransferDetails, sub(mload(batchTransferDetails), 1))}
            }
        }
        if (batchTransferDetails.length > 0){
            PERMIT2.transferFrom(batchTransferDetails);
        }
    }

    /// @notice Transfer tokens from maker to taker
    /// @param from maker_address from which tokens will be transferred
    /// @param to taker_address to which tokens will be transferred
    /// @param maker_tokens addresses of tokens
    /// @param maker_amounts amounts of tokens
    /// @param usingPermit2 indicates whether maker is Permit2 for transfers or not
    /// @param makerCommands commands to indicate how to transfer tokens
    /// @param partnerId identifier of partner to pay referral fee
    /// @return nativeToTaker amount of native token to transfer to taker
    function _transferMakerTokens(
        address from,
        address to,
        address[] calldata maker_tokens,
        uint256[] memory maker_amounts,
        bool usingPermit2,
        bytes memory makerCommands,
        uint64 partnerId
    ) internal returns (uint256) {
        uint256 nativeToTaker;
        IPermit2.AllowanceTransferDetails[] memory batchTransferDetails;
        uint batchInd;

        bool hasPartnerFee = partnerId != 0;
        PartnerInfo memory partnerInfo;
        if (hasPartnerFee){
            partnerInfo = partners[partnerId];
            hasPartnerFee = partnerInfo.registered && partnerInfo.fee > 0;
        }

        for (uint j; j < maker_tokens.length; ++j) {
            uint256 amount = maker_amounts[j];
            address receiver = to;
            if (makerCommands[j] != Commands.SIMPLE_TRANSFER){
                if (makerCommands[j] == Commands.TRANSFER_TO_CONTRACT) {
                    receiver = address(this);
                } else if (makerCommands[j] == Commands.NATIVE_TRANSFER) {
                    if (maker_tokens[j] != WRAPPED_NATIVE_TOKEN) revert WrongWrappedTokenAddress();
                    nativeToTaker += amount;
                    receiver = address(this);
                } else {
                    revert InvalidCommand();
                }
            }
            if (usingPermit2) {
                if (batchTransferDetails.length == 0){
                    batchTransferDetails = new IPermit2.AllowanceTransferDetails[](hasPartnerFee ? 2 * maker_tokens.length : maker_tokens.length);
                }
                if (hasPartnerFee){
                    if (makerCommands[j] != Commands.TRANSFER_TO_CONTRACT){
                        uint256 fee = amount * partnerInfo.fee / HUNDRED_PERCENT;
                        if (fee > 0){
                            batchTransferDetails[batchInd++] = IPermit2.AllowanceTransferDetails({
                                from: from,
                                to: partnerInfo.beneficiary,
                                amount: SafeCast160.toUint160(fee),
                                token: maker_tokens[j]
                            });
                            amount -= fee;
                            if (makerCommands[j] == Commands.NATIVE_TRANSFER){
                                nativeToTaker -= fee;
                            }
                        } else {
                            assembly {mstore(batchTransferDetails, sub(mload(batchTransferDetails), 1))}
                        }
                    } else {
                        assembly {mstore(batchTransferDetails, sub(mload(batchTransferDetails), 1))}
                    }
                }
                batchTransferDetails[batchInd++] = IPermit2.AllowanceTransferDetails({
                    from: from,
                    to: receiver,
                    amount: SafeCast160.toUint160(amount),
                    token: maker_tokens[j]
                });
            } else {
                if (hasPartnerFee && makerCommands[j] != Commands.TRANSFER_TO_CONTRACT){
                    uint256 fee = amount * partnerInfo.fee / HUNDRED_PERCENT;
                    if (fee > 0){
                        IERC20(maker_tokens[j]).safeTransferFrom(from, partnerInfo.beneficiary, fee);
                        amount -= fee;
                        if (makerCommands[j] == Commands.NATIVE_TRANSFER){
                            nativeToTaker -= fee;
                        }
                    }
                }
                IERC20(maker_tokens[j]).safeTransferFrom(from, receiver, amount);
            }
        }
        if (usingPermit2){
            if (batchInd != batchTransferDetails.length) revert InvalidPermit2Commands();
            PERMIT2.transferFrom(batchTransferDetails);
        }

        return nativeToTaker;
    }

    /// @notice Transfer tokens from taker to maker with index=i in Aggregate order
    /// @param order AggregateOrder
    /// @param i index of current maker
    /// @param filledTakerAmount Token amount which taker wants to swap, should be less or equal to order.taker_amount
    ///  if filledTakerAmount == 0 then order.taker_amounts will be used, Many-to-One trades don't support partial fill
    /// @param quoteTakerAmount - full taker_amount for One-to-One or One-to-Many trades, for Many-to-One orders it's 0
    /// @param indices helper structure to track indices
    /// @param nativeTokens helper structure to track native token transfers
    /// @param pendingTransfers helper structure to track pending transfers
    /// @param batchTransferDetails helper structure to track permit2 transfer
    function _transferTakerTokensForAggregateOrder(
        Order.Aggregate calldata order,
        uint256 i,
        uint256 filledTakerAmount,
        uint256 quoteTakerAmount,
        Transfer.IndicesInfo memory indices,
        Transfer.NativeTokens memory nativeTokens,
        Transfer.Pending[] memory pendingTransfers,
        IPermit2.AllowanceTransferDetails[] memory batchTransferDetails
    ) internal {
        for (uint k; k < order.taker_tokens[i].length; ++k) {
            uint currentTakerAmount = filledTakerAmount > 0 && filledTakerAmount < quoteTakerAmount ?
                order.taker_amounts[i][k] * filledTakerAmount / quoteTakerAmount : order.taker_amounts[i][k];
            bytes1 curCommand = order.commands[indices.commandsInd + k];
            if (curCommand == Commands.SIMPLE_TRANSFER || curCommand == Commands.CALL_PERMIT_THEN_TRANSFER){
                IERC20(order.taker_tokens[i][k]).safeTransferFrom(
                    order.taker_address, order.maker_addresses[i], currentTakerAmount
                );
            } else if (curCommand == Commands.PERMIT2_TRANSFER || curCommand == Commands.CALL_PERMIT2_THEN_TRANSFER){
                batchTransferDetails[indices.permit2Ind++] = IPermit2.AllowanceTransferDetails({
                    from: order.taker_address,
                    to: order.maker_addresses[i],
                    amount: SafeCast160.toUint160(currentTakerAmount),
                    token: order.taker_tokens[i][k]
                });
            } else if (curCommand == Commands.NATIVE_TRANSFER) {
                if (order.taker_tokens[i][k] != WRAPPED_NATIVE_TOKEN) revert WrongWrappedTokenAddress();
                nativeTokens.toMakers += currentTakerAmount;
                pendingTransfers[indices.pendingTransfersInd++] = Transfer.Pending(
                    order.taker_tokens[i][k], order.maker_addresses[i], currentTakerAmount
                );
            } else if (curCommand == Commands.TRANSFER_FROM_CONTRACT){
                // If using contract as an intermediate recipient for tokens transferring
                pendingTransfers[indices.pendingTransfersInd++] = Transfer.Pending(
                    order.taker_tokens[i][k], order.maker_addresses[i], currentTakerAmount
                );
            } else {
                revert InvalidCommand();
            }
        }
    }

    /// @notice Call 'permit' function for taker's token
    function _tokenPermit(
        address takerAddress, address tokenAddress, Signature.PermitSignature calldata takerPermitSignature
    ) internal {
        (bytes32 r, bytes32 s, uint8 v) = Signature.getRsv(takerPermitSignature.signatureBytes);
        if (tokenAddress == DAI_TOKEN){
            if (_chainId == 137){
                IDaiLikePermit(tokenAddress).permit(
                    takerAddress, address(this), IDaiLikePermit(tokenAddress).getNonce(takerAddress), takerPermitSignature.deadline, true, v, r, s
                );
            } else {
                IDaiLikePermit(tokenAddress).permit(
                    takerAddress, address(this), IERC20Permit(tokenAddress).nonces(takerAddress), takerPermitSignature.deadline, true, v, r, s
                );
            }
        } else {
            IERC20Permit(tokenAddress).permit(takerAddress, address(this), type(uint).max, takerPermitSignature.deadline, v, r, s);
        }
    }

    /// @notice On Permit2 contract call 'permit' function for taker's token
    function _tokenPermit2(
        address takerAddress, address tokenAddress, Signature.Permit2Signature calldata takerPermit2Signature
    ) internal {
        IPermit2.PermitDetails[] memory permitBatch = new IPermit2.PermitDetails[](1);
        permitBatch[0] = IPermit2.PermitDetails(
            tokenAddress, type(uint160).max, takerPermit2Signature.deadline, takerPermit2Signature.nonce
        );
        PERMIT2.permit(
            takerAddress,
            IPermit2.PermitBatch(permitBatch, address(this), takerPermit2Signature.deadline),
            takerPermit2Signature.signatureBytes
        );
    }

    /// @notice Call 'permit' function for one taker token that has command 'CALL_PERMIT_THEN_TRANSFER'
    function _tokenPermitForMultiOrder(
        Order.Multi calldata order, Signature.PermitSignature calldata takerPermitSignature
    ) internal {
        uint commandsInd = order.maker_tokens.length;
        for (uint i; i < order.taker_tokens.length; ++i){
            if (order.commands[commandsInd++] == Commands.CALL_PERMIT_THEN_TRANSFER){
                _tokenPermit(order.taker_address, order.taker_tokens[i], takerPermitSignature);
                return;
            }
        }
    }

    /// @notice On Permit2 contract call 'permit' for batch of tokens with transfer-command 'CALL_PERMIT2_THEN_TRANSFER'
    function _tokensPermit2ForMultiOrder(
        Order.Multi calldata order, Signature.MultiTokensPermit2Signature calldata infoPermit2
    ) internal {
        uint commandsInd = order.maker_tokens.length;
        uint batchToApproveInd;
        IPermit2.PermitDetails[] memory batchToApprove = new IPermit2.PermitDetails[](infoPermit2.nonces.length);
        for (uint i; i < order.taker_tokens.length; ++i){
            if (order.commands[commandsInd++] == Commands.CALL_PERMIT2_THEN_TRANSFER){
                batchToApprove[batchToApproveInd] = IPermit2.PermitDetails(
                    order.taker_tokens[i], type(uint160).max, infoPermit2.deadline, infoPermit2.nonces[batchToApproveInd]
                );
                ++batchToApproveInd;
            }
        }
        if (batchToApproveInd != batchToApprove.length) revert InvalidPermit2Commands();
        PERMIT2.permit(
            order.taker_address,
            IPermit2.PermitBatch(batchToApprove, address(this), infoPermit2.deadline),
            infoPermit2.signatureBytes
        );
    }

    /// @notice Call 'permit' function for one taker token that has command 'CALL_PERMIT_THEN_TRANSFER'
    function _tokenPermitForAggregateOrder(
        Order.Aggregate calldata order, Signature.PermitSignature calldata takerPermitSignature
    ) internal {
        uint commandsInd;
        for (uint i; i < order.taker_tokens.length; ++i){
            commandsInd += order.maker_tokens[i].length;
            for (uint j; j < order.taker_tokens[i].length; ++j) {
                if (order.commands[commandsInd++] == Commands.CALL_PERMIT_THEN_TRANSFER){
                    _tokenPermit(order.taker_address, order.taker_tokens[i][j], takerPermitSignature);
                    return;
                }
            }
        }
    }

    /// @notice On Permit2 contract call 'permit' for batch of tokens with transfer-command 'CALL_PERMIT2_THEN_TRANSFER'
    function _tokensPermit2ForAggregateOrder(
        Order.Aggregate calldata order, Signature.MultiTokensPermit2Signature calldata infoPermit2
    ) internal {
        uint commandsInd;
        uint batchToApproveInd;
        IPermit2.PermitDetails[] memory batchToApprove = new IPermit2.PermitDetails[](infoPermit2.nonces.length);
        for (uint i; i < order.taker_tokens.length; ++i){
            commandsInd += order.maker_tokens[i].length;
            for (uint j; j < order.taker_tokens[i].length; ++j) {
                if (order.commands[commandsInd++] == Commands.CALL_PERMIT2_THEN_TRANSFER){
                    batchToApprove[batchToApproveInd] = IPermit2.PermitDetails(
                        order.taker_tokens[i][j], type(uint160).max, infoPermit2.deadline, infoPermit2.nonces[batchToApproveInd]
                    );
                    ++batchToApproveInd;
                }
            }
        }
        if (batchToApproveInd != batchToApprove.length) revert InvalidPermit2Commands();
        PERMIT2.permit(
            order.taker_address,
            IPermit2.PermitBatch(batchToApprove, address(this), infoPermit2.deadline),
            infoPermit2.signatureBytes
        );
    }



}
