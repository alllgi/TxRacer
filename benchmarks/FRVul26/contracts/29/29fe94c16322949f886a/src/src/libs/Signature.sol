// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../base/Errors.sol";

library Signature {

    enum Type {
        EIP712,  //0
        EIP1271, //1
        ETHSIGN  //2
    }

    struct PermitSignature {
        bytes signatureBytes;
        uint256 deadline;
    }

    struct Permit2Signature {
        bytes signatureBytes;
        uint48 deadline;
        uint48 nonce;
    }

    struct MultiTokensPermit2Signature {
        bytes signatureBytes;
        uint48 deadline;
        uint48[] nonces;
    }

    struct MakerSignature {
        bytes signatureBytes;
        uint256 flags;
    }

    /// @dev Decode maker flags
    ///
    ///  |   ...    | 2 | 1 | 0 |
    /// -+----------+---+-------+
    ///  | reserved | * | *   * |
    ///               |   |   |
    ///               |   +---+--- signature type bits
    ///               |               00: EIP-712
    ///               |               01: EIP-1271
    ///               |               10: ETH_SIGN
    ///               |
    ///               +-------------makerUsingPermit2 bit, 0 for standard transfer
    ///                                                    1 for permit2 transfer
    function extractMakerFlags(uint256 flags) internal pure returns (bool usingPermit2, Type signatureType){
        signatureType = Type(flags & 0x03);
        usingPermit2 = (flags & 0x04) != 0;
    }

    /// @notice Split signature into `r`, `s`, `v` variables
    function getRsv(bytes calldata sig) internal pure returns (bytes32, bytes32, uint8){
        if(sig.length != 65) revert InvalidSignatureLength();
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 32))
            v := calldataload(add(sig.offset, 33))
        }
        if (v < 27) v += 27;
        if(uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) revert InvalidSignatureValueS();
        if(v != 27 && v != 28) revert InvalidSignatureValueV();
        return (r, s, v);
    }

}
