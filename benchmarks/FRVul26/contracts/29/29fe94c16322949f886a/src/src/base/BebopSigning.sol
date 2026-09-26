// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/Order.sol";
import "../libs/Signature.sol";
import "../libs/common/BytesLib.sol";
import "./Errors.sol";
import "lib/openzeppelin-contracts/contracts/interfaces/IERC1271.sol";
import "../libs/Transfer.sol";

abstract contract BebopSigning {

    event OrderSignerRegistered(address maker, address signer, bool allowed);

    bytes32 private constant DOMAIN_NAME = keccak256("BebopSettlement");
    bytes32 private constant DOMAIN_VERSION = keccak256("2");

    // bytes4(keccak256("isValidSignature(bytes32,bytes)"))
    bytes4 private constant EIP1271_MAGICVALUE = 0x1626ba7e;

    uint256 private constant ETH_SIGN_HASH_PREFIX = 0x19457468657265756d205369676e6564204d6573736167653a0a333200000000;

    /// @dev This value is pre-computed from the following expression
    /// keccak256(abi.encodePacked(
    ///   "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    /// ));
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev This value is pre-computed from the following expression
    /// keccak256(abi.encodePacked(
    ///   "AggregateOrder(uint64 partner_id,uint256 expiry,address taker_address,address[] maker_addresses,uint256[] maker_nonces,address[][] taker_tokens,address[][] maker_tokens,uint256[][] taker_amounts,uint256[][] maker_amounts,address receiver,bytes commands)"
    /// ));
    bytes32 private constant AGGREGATED_ORDER_TYPE_HASH = 0xe850f4ac05cb765eff6f120037e6d3286f8f71aaedad7f9f242af69d53091265;

    /// @dev This value is pre-computed from the following expression
    /// keccak256(abi.encodePacked(
    ///   "MultiOrder(uint64 partner_id,uint256 expiry,address taker_address,address maker_address,uint256 maker_nonce,address[] taker_tokens,address[] maker_tokens,uint256[] taker_amounts,uint256[] maker_amounts,address receiver,bytes commands)"
    /// ));
    bytes32 private constant MULTI_ORDER_TYPE_HASH = 0x34728ce057ec73e3b4f0871dced9cc875f5b1aece9fd07891e156fe852a858d9;

    /// @dev This value is pre-computed from the following expression
    /// keccak256(abi.encodePacked(
    ///   "SingleOrder(uint64 partner_id,uint256 expiry,address taker_address,address maker_address,uint256 maker_nonce,address taker_token,address maker_token,uint256 taker_amount,uint256 maker_amount,address receiver,uint256 packed_commands)"
    /// ));
    bytes32 private constant SINGLE_ORDER_TYPE_HASH = 0xe34225bc7cd92038d42c258ee3ff66d30f9387dd932213ba32a52011df0603fc;

    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    mapping(address => mapping(uint256 => uint256)) private makerNonceValidator;
    mapping(address => mapping(address => bool)) private orderSignerRegistry;

    constructor(){
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = keccak256(
            abi.encode(EIP712_DOMAIN_TYPEHASH, DOMAIN_NAME, DOMAIN_VERSION, block.chainid, address(this))
        );
    }

    /// @notice The domain separator used in the order validation signature
    /// @return The domain separator hash
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return block.chainid == _CACHED_CHAIN_ID
            ? _CACHED_DOMAIN_SEPARATOR
            : keccak256(
                abi.encode(EIP712_DOMAIN_TYPEHASH, DOMAIN_NAME, DOMAIN_VERSION, block.chainid, address(this))
            );
    }

    /// @notice Register another order signer for a maker
    /// @param signer The address of the additional signer
    /// @param allowed Whether the signer is allowed to sign orders for the maker
    function registerAllowedOrderSigner(address signer, bool allowed) external {
        orderSignerRegistry[msg.sender][signer] = allowed;
        emit OrderSignerRegistered(msg.sender, signer, allowed);
    }

    /// @notice Hash partnerId + Order.Single struct without `flags` field
    /// @param order Order.Single struct
    /// @param partnerId Unique partner identifier, 0 for no partner
    /// @param updatedMakerAmount Updated maker amount, 0 for no update
    /// @param updatedMakerNonce Updated maker nonce, 0 for no update
    /// @return The hash of the order
    function hashSingleOrder(
        Order.Single calldata order, uint64 partnerId, uint256 updatedMakerAmount, uint256 updatedMakerNonce
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), keccak256(
            abi.encode(
                SINGLE_ORDER_TYPE_HASH, partnerId, order.expiry, order.taker_address, order.maker_address,
                updatedMakerNonce != 0 ? updatedMakerNonce : order.maker_nonce, order.taker_token, order.maker_token,
                order.taker_amount, updatedMakerAmount != 0 ? updatedMakerAmount : order.maker_amount, order.receiver,
                order.packed_commands
            )
        )));
    }

    /// @notice Hash partnerId + Order.Multi struct without `flags` field
    /// @param order Order.Multi struct
    /// @param partnerId Unique partner identifier, 0 for no partner
    /// @param updatedMakerAmounts Updated maker amounts, it replaces order.maker_amounts
    /// @param updatedMakerNonce Updated maker nonce, it replaces order.maker_nonce
    /// @return The hash of the order
    function hashMultiOrder(
        Order.Multi memory order, uint64 partnerId, uint256[] calldata updatedMakerAmounts, uint256 updatedMakerNonce
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), keccak256(
            abi.encode(
                MULTI_ORDER_TYPE_HASH, partnerId, order.expiry, order.taker_address, order.maker_address, updatedMakerNonce,
                keccak256(abi.encodePacked(order.taker_tokens)), keccak256(abi.encodePacked(order.maker_tokens)),
                keccak256(abi.encodePacked(order.taker_amounts)), keccak256(abi.encodePacked(updatedMakerAmounts)),
                order.receiver, keccak256(order.commands)
            )
        )));
    }

    /// @notice Hash partnerId + Order.Aggregate struct without `flags` field
    /// @param order Order.Aggregate struct
    /// @param partnerId Unique partner identifier, 0 for no partner
    /// @param updatedMakerAmounts Updated maker amounts, it replaces order.maker_amounts
    /// @param updatedMakerNonces Updated maker nonces, it replaces order.maker_nonces
    /// @return The hash of the order
    function hashAggregateOrder(
        Order.Aggregate calldata order, uint64 partnerId, uint256[][] calldata updatedMakerAmounts, uint256[] calldata updatedMakerNonces
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), keccak256(
            abi.encode(
                AGGREGATED_ORDER_TYPE_HASH, partnerId, order.expiry, order.taker_address,
                keccak256(abi.encodePacked(order.maker_addresses)), keccak256(abi.encodePacked(updatedMakerNonces)),
                keccak256(_encodeTightlyPackedNested(order.taker_tokens)), keccak256(_encodeTightlyPackedNested(order.maker_tokens)),
                keccak256(_encodeTightlyPackedNestedInt(order.taker_amounts)), keccak256(_encodeTightlyPackedNestedInt(updatedMakerAmounts)),
                order.receiver, keccak256(order.commands)
            )
        )));
    }

    /// @notice Validate the order signature
    /// @param validationAddress The address to validate the signature against
    /// @param hash The hash of the order
    /// @param signature The signature to validate
    /// @param signatureType The type of the signature
    /// @param isMaker Whether external signer from orderSignerRegistry is allowed or not
    function _validateSignature(
        address validationAddress, bytes32 hash, bytes calldata signature, Signature.Type signatureType, bool isMaker
    ) internal view {
        if (signatureType == Signature.Type.EIP712) {
            (bytes32 r, bytes32 s, uint8 v) = Signature.getRsv(signature);
            address signer = ecrecover(hash, v, r, s);
            if (signer == address(0)) revert OrderInvalidSigner();
            if (signer != validationAddress && (!isMaker || !orderSignerRegistry[validationAddress][signer])) {
                revert InvalidEIP721Signature();
            }
        } else if (signatureType == Signature.Type.EIP1271) {
            if (IERC1271(validationAddress).isValidSignature(hash, signature) != EIP1271_MAGICVALUE){
                revert InvalidEIP1271Signature();
            }
        } else if (signatureType == Signature.Type.ETHSIGN) {
            bytes32 ethSignHash;
            assembly {
                mstore(0, ETH_SIGN_HASH_PREFIX)
                mstore(28, hash)
                ethSignHash := keccak256(0, 60)
            }
            (bytes32 r, bytes32 s, uint8 v) = Signature.getRsv(signature);
            address signer = ecrecover(ethSignHash, v, r, s);
            if (signer == address(0)) revert OrderInvalidSigner();
            if (signer != validationAddress && (!isMaker || !orderSignerRegistry[validationAddress][signer])) {
                revert InvalidETHSIGNSignature();
            }
        } else {
            revert InvalidSignatureType();
        }
    }

    /// @notice Pack 2D array of integers into tightly packed bytes for hashing
    function _encodeTightlyPackedNestedInt(uint256[][] calldata _nested_array) private pure returns (bytes memory encoded) {
        uint nested_array_length = _nested_array.length;
        for (uint i; i < nested_array_length; ++i) {
            encoded = abi.encodePacked(encoded, keccak256(abi.encodePacked(_nested_array[i])));
        }
        return encoded;
    }

    /// @notice Pack 2D array of addresses into tightly packed bytes for hashing
    function _encodeTightlyPackedNested(address[][] calldata _nested_array) private pure returns (bytes memory encoded) {
        uint nested_array_length = _nested_array.length;
        for (uint i; i < nested_array_length; ++i) {
            encoded = abi.encodePacked(encoded, keccak256(abi.encodePacked(_nested_array[i])));
        }
        return encoded;
    }

    /// @notice Check maker nonce and invalidate it
    function _invalidateOrder(address maker, uint256 nonce) private {
        if (nonce == 0) revert ZeroNonce();
        uint256 invalidatorSlot = nonce >> 8;
        uint256 invalidatorBit = 1 << (nonce & 0xff);
        mapping(uint256 => uint256) storage invalidatorStorage = makerNonceValidator[maker];
        uint256 invalidator = invalidatorStorage[invalidatorSlot];
        if (invalidator & invalidatorBit == invalidatorBit) revert InvalidNonce();
        invalidatorStorage[invalidatorSlot] = invalidator | invalidatorBit;
    }

    /// @notice Validate maker signature and SingleOrder fields
    function _validateSingleOrder(
        Order.Single calldata order,
        Signature.MakerSignature calldata makerSignature
    ) internal {
        (, Signature.Type signatureType) = Signature.extractMakerFlags(makerSignature.flags);
        _validateSignature(
            order.maker_address, hashSingleOrder(order, Order.extractPartnerId(order.flags), 0, 0),
            makerSignature.signatureBytes, signatureType, true
        );
        _invalidateOrder(order.maker_address, order.maker_nonce);
        if (order.expiry <= block.timestamp) revert OrderExpired();
    }

    /// @notice Validate maker signature and MultiOrder fields
    function _validateMultiOrder(
        Order.Multi calldata order,
        Signature.MakerSignature calldata makerSignature,
        uint256 filledTakerAmount
    ) internal {
        (, Signature.Type signatureType) = Signature.extractMakerFlags(makerSignature.flags);
        _validateSignature(
            order.maker_address,
            hashMultiOrder(order, Order.extractPartnerId(order.flags), order.maker_amounts, order.maker_nonce),
            makerSignature.signatureBytes, signatureType, true
        );
        _invalidateOrder(order.maker_address, order.maker_nonce);
        if (
            order.taker_tokens.length != order.taker_amounts.length || order.maker_tokens.length != order.maker_amounts.length
        ) revert TokensLengthsMismatch();
        if (order.commands.length != order.taker_tokens.length + order.maker_tokens.length) revert InvalidCommandsLength();
        if (order.taker_tokens.length != 1 && order.maker_tokens.length != 1) revert ManyToManyNotSupported();
        if (order.taker_tokens.length > 1 && filledTakerAmount != 0){
            /// @dev Partial fill is not supported for many-to-one orders, so filledTakerAmount should be 0
            revert PartialFillNotSupported();
        }
        if (order.expiry <= block.timestamp) revert OrderExpired();
    }

    /// @notice Validate makers signatures and AggregateOrder fields
    function _validateAggregateOrder(
        Order.Aggregate calldata order,
        Signature.MakerSignature[] calldata makersSignatures
    ) internal {
        uint makersNum = makersSignatures.length;
        if (
            order.maker_addresses.length != makersNum || order.maker_nonces.length != makersNum
            || order.taker_tokens.length != makersNum || order.maker_tokens.length != makersNum
            || order.taker_amounts.length != makersNum || order.maker_amounts.length != makersNum
        ) revert OrdersLengthsMismatch();
        uint tokenTransfers;
        for (uint i; i < makersNum; ++i) {
            if (order.maker_tokens[i].length != order.maker_amounts[i].length
                || order.taker_tokens[i].length != order.taker_amounts[i].length)
                revert TokensLengthsMismatch();
            Order.Multi memory partialAggregateOrder = Order.Multi(
                order.expiry, order.taker_address, order.maker_addresses[i], order.maker_nonces[i],
                order.taker_tokens[i], order.maker_tokens[i], order.taker_amounts[i], order.maker_amounts[i],
                order.receiver, BytesLib.slice(
                    order.commands, tokenTransfers, order.maker_tokens[i].length + order.taker_tokens[i].length
                ), 0
            );
            bytes32 multiOrderHash = hashMultiOrder(
                partialAggregateOrder, Order.extractPartnerId(order.flags), order.maker_amounts[i], order.maker_nonces[i]
            );

            (, Signature.Type signatureType) = Signature.extractMakerFlags(makersSignatures[i].flags);
            _validateSignature(
                order.maker_addresses[i], multiOrderHash, makersSignatures[i].signatureBytes, signatureType, true
            );
            _invalidateOrder(order.maker_addresses[i], order.maker_nonces[i]);
            tokenTransfers += order.maker_tokens[i].length + order.taker_tokens[i].length;
        }
        if (tokenTransfers != order.commands.length) revert CommandsLengthsMismatch();
        if (order.expiry <= block.timestamp) revert OrderExpired();
    }

    /// @notice Validate taker signature for SingleOrder
    function _validateTakerSignatureForSingleOrder(
        Order.Single calldata order, bytes calldata takerSignature, Transfer.OldSingleQuote calldata takerQuoteInfo
    ) internal {
        if (order.maker_amount < takerQuoteInfo.makerAmount) revert UpdatedMakerAmountsTooLow();
        if (takerQuoteInfo.makerAmount == 0) revert ZeroMakerAmount();
        if (takerQuoteInfo.makerNonce != order.maker_nonce){
            _invalidateOrder(order.maker_address, takerQuoteInfo.makerNonce);
        }
        if (msg.sender != order.taker_address){
            Signature.Type signatureType = Order.extractSignatureType(order.flags);
            _validateSignature(
                order.taker_address,
                hashSingleOrder(order, Order.extractPartnerId(order.flags), takerQuoteInfo.makerAmount, takerQuoteInfo.makerNonce),
                takerSignature, signatureType, false
            );
        }
    }

    /// @notice Validate taker signature for MultiOrder
    function _validateTakerSignatureForMultiOrder(
        Order.Multi calldata order, bytes calldata takerSignature, Transfer.OldMultiQuote calldata takerQuoteInfo
    ) internal {
        if (takerQuoteInfo.makerAmounts.length != order.maker_amounts.length) revert MakerAmountsLengthsMismatch();
        for (uint i; i < takerQuoteInfo.makerAmounts.length; ++i){
            if (takerQuoteInfo.makerAmounts[i] == 0) revert ZeroMakerAmount();
            if (order.maker_amounts[i] < takerQuoteInfo.makerAmounts[i]) revert UpdatedMakerAmountsTooLow();
        }
        if (takerQuoteInfo.makerNonce != order.maker_nonce){
            _invalidateOrder(order.maker_address, takerQuoteInfo.makerNonce);
        }
        if (msg.sender != order.taker_address){
            Signature.Type signatureType = Order.extractSignatureType(order.flags);
            _validateSignature(
                order.taker_address,
                hashMultiOrder(order, Order.extractPartnerId(order.flags), takerQuoteInfo.makerAmounts, takerQuoteInfo.makerNonce),
                takerSignature, signatureType, false
            );
        }
    }

    /// @notice Validate taker signature for AggregateOrder
    function _validateTakerSignatureForAggregateOrder(
        Order.Aggregate calldata order, bytes calldata takerSignature, Transfer.OldAggregateQuote calldata takerQuoteInfo
    ) internal {
        if (takerQuoteInfo.makerAmounts.length != order.maker_amounts.length) revert MakerAmountsLengthsMismatch();
        for (uint i; i < order.maker_amounts.length; ++i){
            if (takerQuoteInfo.makerAmounts[i].length != order.maker_amounts[i].length) revert MakerAmountsLengthsMismatch();
            for (uint j; j < order.maker_amounts[i].length; ++j){
                if (order.maker_amounts[i][j] < takerQuoteInfo.makerAmounts[i][j]) revert UpdatedMakerAmountsTooLow();
            }
            if (takerQuoteInfo.makerNonces[i] != order.maker_nonces[i]){
                _invalidateOrder(order.maker_addresses[i], takerQuoteInfo.makerNonces[i]);
            }
        }
        if (msg.sender != order.taker_address){
            Signature.Type signatureType = Order.extractSignatureType(order.flags);
            _validateSignature(
                order.taker_address,
                hashAggregateOrder(order, Order.extractPartnerId(order.flags), takerQuoteInfo.makerAmounts, takerQuoteInfo.makerNonces),
                takerSignature, signatureType, false
            );
        }
    }

}
