// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../libs/Order.sol";
import "../libs/Signature.sol";
import "../libs/Transfer.sol";

interface IBebopSettlement {

    event BebopOrder(uint128 indexed eventId);

    /// @notice Taker execution of one-to-one trade with one maker
    /// @param order Single order struct
    /// @param makerSignature Maker's signature for SingleOrder
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill
    function swapSingle(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount
    ) external payable;

    /// @notice Taker execution of one-to-one trade with one maker.
    /// Using current contract's balance of taker_token as partial fill amount
    /// @param order Single order struct
    /// @param makerSignature Maker's signature for SingleOrder
    function swapSingleFromContract(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature
    ) external payable;

    /// @notice Maker execution of one-to-one trade with one maker
    /// @param order Single order struct
    /// @param makerSignature Maker's signature for SingleOrder
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill
    /// @param takerQuoteInfo If maker_amount has improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///        if taker executes order himself then signature can be '0x' (recommended to use swapSingle for this case)
    function settleSingle(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldSingleQuote calldata takerQuoteInfo,
        bytes calldata takerSignature
    ) external payable;

    /// @notice Maker execution of one-to-one trade with one maker.
    /// Sign permit for taker_token before execution of the order
    /// @param order Single order struct
    /// @param makerSignature Maker's signature for SingleOrder
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill
    /// @param takerQuoteInfo If maker_amount has improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///                       if taker executes order himself then signature can be '0x'
    /// @param takerPermitSignature Taker's signature to approve spending of taker_token by calling token.permit(..)
    function settleSingleAndSignPermit(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldSingleQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.PermitSignature calldata takerPermitSignature
    ) external payable;

    /// @notice Maker execution of one-to-one trade with one maker.
    /// Sign permit2 for taker_token before execution of the order
    /// @param order Single order struct
    /// @param makerSignature Maker's signature for SingleOrder
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill
    /// @param takerQuoteInfo If maker_amount has improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///                       if taker executes order himself then signature can be '0x'
    /// @param takerPermit2Signature Taker's signature to approve spending of taker_token by calling Permit2.permit(..)
    function settleSingleAndSignPermit2(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldSingleQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.Permit2Signature calldata takerPermit2Signature
    ) external payable;


    /// @notice Taker execution of one-to-many or many-to-one trade with one maker
    /// @param order Multi order struct
    /// @param makerSignature Maker's signature for MultiOrder
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill. Many-to-one doesnt support partial fill
    function swapMulti(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount
    ) external payable;

    /// @notice Maker execution of one-to-many or many-to-one trade with one maker
    /// @param order Multi order struct
    /// @param makerSignature Maker's signature for MultiOrder
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill. Many-to-one doesnt support partial fill
    /// @param takerQuoteInfo If maker_amounts have improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///        if taker executes order himself then signature can be '0x' (recommended to use swapMulti for this case)
    function settleMulti(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldMultiQuote calldata takerQuoteInfo,
        bytes calldata takerSignature
    ) external payable;

    /// @notice Maker execution of one-to-many or many-to-one trade with one maker.
    /// Before execution of the order, signs permit for one of taker_tokens
    /// @param order Multi order struct
    /// @param makerSignature Maker's signature for MultiOrder
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill. Many-to-one doesnt support partial fill
    /// @param takerQuoteInfo If maker_amounts have improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///                       if taker executes order himself then signature can be '0x'
    /// @param takerPermitSignature Taker's signature to approve spending of taker_token by calling token.permit(..)
    function settleMultiAndSignPermit(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldMultiQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.PermitSignature calldata takerPermitSignature
    ) external payable;

    /// @notice Maker execution of one-to-many or many-to-one trade with one maker.
    /// Sign permit2 for taker_tokens before execution of the order
    /// @param order Multi order struct
    /// @param makerSignature Maker's signature for MultiOrder
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill. Many-to-one doesnt support partial fill
    /// @param takerQuoteInfo If maker_amounts have improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///                       if taker executes order himself then signature can be '0x'
    /// @param infoPermit2 Taker's signature to approve spending of taker_tokens by calling Permit2.permit(..)
    function settleMultiAndSignPermit2(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount,
        Transfer.OldMultiQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.MultiTokensPermit2Signature calldata infoPermit2
    ) external payable;


    /// @notice Taker execution of any trade with multiple makers
    /// @param order Aggregate order struct
    /// @param makersSignatures Makers signatures for MultiOrder (can be contructed as part of current AggregateOrder)
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill. Many-to-one doesnt support partial fill
    function swapAggregate(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount
    ) external payable;

    /// @notice Maker execution of any trade with multiple makers
    /// @param order Aggregate order struct
    /// @param makersSignatures Makers signatures for MultiOrder (can be contructed as part of current AggregateOrder)
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill. Many-to-one doesnt support partial fill
    /// @param takerQuoteInfo If maker_amounts have improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///      if taker executes order himself then signature can be '0x' (recommended to use swapAggregate for this case)
    function settleAggregate(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount,
        Transfer.OldAggregateQuote calldata takerQuoteInfo,
        bytes calldata takerSignature
    ) external payable;

    /// @notice Maker execution of any trade with multiple makers.
    /// Before execution of the order, signs permit for one of taker_tokens
    /// @param order Aggregate order struct
    /// @param makersSignatures Makers signatures for MultiOrder (can be contructed as part of current AggregateOrder)
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill. Many-to-one doesnt support partial fill
    /// @param takerQuoteInfo If maker_amounts have improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///                       if taker executes order himself then signature can be '0x'
    /// @param takerPermitSignature Taker's signature to approve spending of taker_token by calling token.permit(..)
    function settleAggregateAndSignPermit(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount,
        Transfer.OldAggregateQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.PermitSignature calldata takerPermitSignature
    ) external payable;

    /// @notice Maker execution of any trade with multiple makers.
    /// Sign permit2 for taker_tokens before execution of the order
    /// @param order Aggregate order struct
    /// @param makersSignatures Makers signatures for MultiOrder (can be contructed as part of current AggregateOrder)
    /// @param filledTakerAmount Partially filled taker amount, 0 for full fill. Many-to-one doesnt support partial fill
    /// @param takerQuoteInfo If maker_amounts have improved then it contains old quote values that taker signed,
    ///                       otherwise it contains same values as in order
    /// @param takerSignature Taker's signature to approve executing order by maker,
    ///                       if taker executes order himself then signature can be '0x'
    /// @param infoPermit2 Taker's signature to approve spending of taker_tokens by calling Permit2.permit(..)
    function settleAggregateAndSignPermit2(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures,
        uint256 filledTakerAmount,
        Transfer.OldAggregateQuote calldata takerQuoteInfo,
        bytes calldata takerSignature,
        Signature.MultiTokensPermit2Signature calldata infoPermit2
    ) external payable;


}