// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Signature.sol";
import "../base/Errors.sol";

library Order {

    /// @notice Struct for one-to-one trade with one maker
    struct Single {
        uint256 expiry;
        address taker_address;
        address maker_address;
        uint256 maker_nonce;
        address taker_token;
        address maker_token;
        uint256 taker_amount;
        uint256 maker_amount;
        address receiver;
        uint256 packed_commands;
        uint256 flags; // `hashSingleOrder` doesn't use this field for SingleOrder hash
    }

    /// @notice Struct for many-to-one or one-to-many trade with one maker
    /// Also this struct is used as maker order which is part of AggregateOrder
    struct Multi {
        uint256 expiry;
        address taker_address;
        address maker_address;
        uint256 maker_nonce;
        address[] taker_tokens;
        address[] maker_tokens;
        uint256[] taker_amounts;
        uint256[] maker_amounts;
        address receiver;
        bytes commands;
        uint256 flags; // `hashMultiOrder` doesn't use this field for MultiOrder hash
    }

    /// @notice Struct for any trade with multiple makers
    struct Aggregate {
        uint256 expiry;
        address taker_address;
        address[] maker_addresses;
        uint256[] maker_nonces;
        address[][] taker_tokens;
        address[][] maker_tokens;
        uint256[][] taker_amounts;
        uint256[][] maker_amounts;
        address receiver;
        bytes commands;
        uint256 flags; // `hashAggregateOrder` doesn't use this field for AggregateOrder hash
    }


    /// @dev Decode Single order packed_commands
    ///
    ///       ...     | 2 | 1 | 0 |
    /// -+------------+---+---+---+
    ///  |  reserved  | * | * | * |
    ///                 |   |   |
    ///                 |   |   +------- takerHasNative bit, 0 for erc20 token
    ///                 |   |                                1 for native token
    ///                 |   +----------- makerHasNative bit, 0 for erc20 token
    ///                 |                                    1 for native token
    ///                 +-------------takerUsingPermit2 bit, 0 for standard transfer
    ///                                                      1 for permit2 transfer
    function extractSingleOrderCommands(
        uint256 commands
    ) internal pure returns (bool takerHasNative, bool makerHasNative, bool takerUsingPermit2){
        takerHasNative = (commands & 0x01) != 0;
        makerHasNative = (commands & 0x02) != 0;
        takerUsingPermit2 = (commands & 0x04) != 0;
        if (takerHasNative && takerUsingPermit2){
            revert InvalidFlags();
        }
    }

    /// @dev Order flags
    ///
    ///  |    255..128    |      127..64     |   ...    | 1 | 0 |
    /// -+----------------+------------------+----------+---+---+
    ///   uint128 eventID | uint64 partnerId | reserved | *   * |
    ///                                                   |   |
    ///                                                   +---+----- signature type
    ///                                                               00: EIP-712
    ///                                                               01: EIP-1271
    ///                                                               10: ETH_SIGN
    function extractSignatureType(uint256 flags) internal pure returns (Signature.Type signatureType){
        signatureType = Signature.Type(flags & 0x03);
    }

    function extractFlags(uint256 flags) internal pure returns (uint128 eventId, uint64 partnerId){
        eventId = uint128(flags >> 128);
        partnerId = uint64(flags >> 64);
    }

    function extractPartnerId(uint256 flags) internal pure returns (uint64 partnerId){
        partnerId = uint64(flags >> 64);
    }

    function extractEventId(uint256 flags) internal pure returns (uint128 eventId){
        eventId = uint128(flags >> 128);
    }

}
