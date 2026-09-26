// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: /Users/sav/Repos/protocol/node_modules/@0x/contracts-erc20/src/IERC20Token.sol

/*

  Copyright 2023 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.6.5 <0.9;

interface IERC20Token {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @dev send `value` token to `to` from `msg.sender`
    /// @param to The address of the recipient
    /// @param value The amount of token to be transferred
    /// @return True if transfer was successful
    function transfer(address to, uint256 value) external returns (bool);

    /// @dev send `value` token to `to` from `from` on the condition it is approved by `from`
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param value The amount of token to be transferred
    /// @return True if transfer was successful
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    /// @dev `msg.sender` approves `spender` to spend `value` tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @param value The amount of wei to be approved for transfer
    /// @return Always true if the call has enough gas to complete execution
    function approve(address spender, uint256 value) external returns (bool);

    /// @dev Query total supply of token
    /// @return Total supply of token
    function totalSupply() external view returns (uint256);

    /// @dev Get the balance of `owner`.
    /// @param owner The address from which the balance will be retrieved
    /// @return Balance of owner
    function balanceOf(address owner) external view returns (uint256);

    /// @dev Get the allowance for `spender` to spend from `owner`.
    /// @param owner The address of the account owning tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address owner, address spender) external view returns (uint256);

    /// @dev Get the number of decimals this token has.
    function decimals() external view returns (uint8);
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/IBridgeAdapter.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;



interface IBridgeAdapter {
    struct BridgeOrder {
        // Upper 16 bytes: uint128 protocol ID (right-aligned)
        // Lower 16 bytes: ASCII source name (left-aligned)
        bytes32 source;
        uint256 takerTokenAmount;
        uint256 makerTokenAmount;
        bytes bridgeData;
    }

    /// @dev Emitted when tokens are swapped with an external source.
    /// @param source A unique ID for the source, where the upper 16 bytes
    ///        encodes the (right-aligned) uint128 protocol ID and the
    ///        lower 16 bytes encodes an ASCII source name.
    /// @param inputToken The token the bridge is converting from.
    /// @param outputToken The token the bridge is converting to.
    /// @param inputTokenAmount Amount of input token sold.
    /// @param outputTokenAmount Amount of output token bought.
    event BridgeFill(
        bytes32 source,
        IERC20Token inputToken,
        IERC20Token outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount
    );

    function isSupportedSource(bytes32 source) external returns (bool isSupported);

    function trade(
        BridgeOrder calldata order,
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount
    ) external returns (uint256 boughtAmount);
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/AbstractBridgeAdapter.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6;
pragma experimental ABIEncoderV2;



abstract contract AbstractBridgeAdapter is IBridgeAdapter {
    constructor(uint256 expectedChainId, string memory expectedChainName) public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        // Skip chain id validation on Ganache (1337), Anvil (31337), Goerli (5), Mumbai (80001), Base Goerli (84531)
        bool skipValidation = (chainId == 1337 ||
            chainId == 31337 ||
            chainId == 5 ||
            chainId == 80001 ||
            chainId == 84531);

        if (chainId != expectedChainId && !skipValidation) {
            revert(string(abi.encodePacked(expectedChainName, "BridgeAdapter.constructor: wrong chain ID")));
        }
    }

    function isSupportedSource(bytes32 source) external override returns (bool isSupported) {
        BridgeOrder memory placeholderOrder;
        placeholderOrder.source = source;
        IERC20Token placeholderToken = IERC20Token(address(0));

        (, isSupported) = _trade(placeholderOrder, placeholderToken, placeholderToken, 0, true);
    }

    function trade(
        BridgeOrder memory order,
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount
    ) public override returns (uint256 boughtAmount) {
        (boughtAmount, ) = _trade(order, sellToken, buyToken, sellAmount, false);
    }

    function _trade(
        BridgeOrder memory order,
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bool dryRun
    ) internal virtual returns (uint256 boughtAmount, bool supportedSource);
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/BridgeProtocols.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;



library BridgeProtocols {
    // A incrementally increasing, append-only list of protocol IDs.
    // We don't use an enum so solidity doesn't throw when we pass in a
    // new protocol ID that hasn't been rolled up yet.
    uint128 internal constant UNKNOWN = 0;
    uint128 internal constant CURVE = 1;
    uint128 internal constant UNISWAPV2 = 2;
    uint128 internal constant UNISWAP = 3;
    uint128 internal constant BALANCER = 4;
    uint128 internal constant KYBER = 5; // Not used: deprecated.
    uint128 internal constant MOONISWAP = 6;
    uint128 internal constant MSTABLE = 7;
    uint128 internal constant OASIS = 8; // Not used: deprecated.
    uint128 internal constant SHELL = 9;
    uint128 internal constant DODO = 10;
    uint128 internal constant DODOV2 = 11;
    uint128 internal constant CRYPTOCOM = 12;
    uint128 internal constant BANCOR = 13;
    uint128 internal constant COFIX = 14; // Not used: deprecated.
    uint128 internal constant NERVE = 15;
    uint128 internal constant MAKERPSM = 16;
    uint128 internal constant BALANCERV2 = 17;
    uint128 internal constant UNISWAPV3 = 18;
    uint128 internal constant KYBERDMM = 19;
    uint128 internal constant CURVEV2 = 20;
    uint128 internal constant LIDO = 21;
    uint128 internal constant CLIPPER = 22; // Not used: Clipper is now using PLP interface
    uint128 internal constant AAVEV2 = 23;
    uint128 internal constant COMPOUND = 24;
    uint128 internal constant BALANCERV2BATCH = 25;
    uint128 internal constant GMX = 26;
    uint128 internal constant PLATYPUS = 27;
    uint128 internal constant BANCORV3 = 28;
    uint128 internal constant SOLIDLY = 29;
    uint128 internal constant SYNTHETIX = 30;
    uint128 internal constant WOOFI = 31;
    uint128 internal constant AAVEV3 = 32;
    uint128 internal constant KYBERELASTIC = 33;
    uint128 internal constant BARTER = 34;
    uint128 internal constant TRADERJOEV2 = 35;
    uint128 internal constant VELODROMEV2 = 36;
    uint128 internal constant MAVERICK = 37;
}

// File: /Users/sav/Repos/protocol/node_modules/@0x/contracts-utils/contracts/src/v06/errors/LibRichErrorsV06.sol

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibRichErrorsV06 {
    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    /// @dev ABI encode a standard, string revert error payload.
    ///      This is the same payload that would be included by a `revert(string)`
    ///      solidity statement. It has the function signature `Error(string)`.
    /// @param message The error string.
    /// @return The ABI encoded error.
    function StandardError(string memory message) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(STANDARD_ERROR_SELECTOR, bytes(message));
    }

    /// @dev Reverts an encoded rich revert reason `errorData`.
    /// @param errorData ABI encoded error data.
    function rrevert(bytes memory errorData) internal pure {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}

// File: /Users/sav/Repos/protocol/node_modules/@0x/contracts-utils/contracts/src/v06/errors/LibBytesRichErrorsV06.sol

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibBytesRichErrorsV06 {
    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    // bytes4(keccak256("InvalidByteOperationError(uint8,uint256,uint256)"))
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR = 0x28006595;

    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    ) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(INVALID_BYTE_OPERATION_ERROR_SELECTOR, errorCode, offset, required);
    }
}

// File: /Users/sav/Repos/protocol/node_modules/@0x/contracts-utils/contracts/src/v06/LibBytesV06.sol

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




library LibBytesV06 {
    using LibBytesV06 for bytes;

    /// @dev Gets the memory address for a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of byte array. This
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input) internal pure returns (uint256 memoryAddress) {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    /// @dev Gets the memory address for the contents of a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input) internal pure returns (uint256 memoryAddress) {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    /// @dev Copies `length` bytes from memory location `source` to `dest`.
    /// @param dest memory address to copy bytes to.
    /// @param source memory address to copy bytes from.
    /// @param length number of bytes to copy.
    function memCopy(uint256 dest, uint256 source, uint256 length) internal pure {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    for {

                    } lt(source, sEnd) {

                    } {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    for {

                    } slt(dest, dEnd) {

                    } {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    /// @dev Returns a slices from a byte array.
    /// @param b The byte array to take a slice from.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function slice(bytes memory b, uint256 from, uint256 to) internal pure returns (bytes memory result) {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                    from,
                    to
                )
            );
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                    to,
                    b.length
                )
            );
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(result.contentAddress(), b.contentAddress() + from, result.length);
        return result;
    }

    /// @dev Returns a slice from a byte array without preserving the input.
    ///      When `from == 0`, the original array will match the slice.
    ///      In other cases its state will be corrupted.
    /// @param b The byte array to take a slice from. Will be destroyed in the process.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function sliceDestructive(bytes memory b, uint256 from, uint256 to) internal pure returns (bytes memory result) {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                    from,
                    to
                )
            );
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                    to,
                    b.length
                )
            );
        }

        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    /// @dev Pops the last byte off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return result The byte that was popped off.
    function popLastByte(bytes memory b) internal pure returns (bytes1 result) {
        if (b.length == 0) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                    b.length,
                    0
                )
            );
        }

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Tests equality of two byte arrays.
    /// @param lhs First byte array to compare.
    /// @param rhs Second byte array to compare.
    /// @return equal True if arrays are the same. False otherwise.
    function equals(bytes memory lhs, bytes memory rhs) internal pure returns (bool equal) {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    /// @dev Reads an address from a position in a byte array.
    /// @param b Byte array containing an address.
    /// @param index Index in byte array of address.
    /// @return result address from byte array.
    function readAddress(bytes memory b, uint256 index) internal pure returns (address result) {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                    b.length,
                    index + 20 // 20 is length of address
                )
            );
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    /// @dev Writes an address into a specific position in a byte array.
    /// @param b Byte array to insert address into.
    /// @param index Index in byte array of address.
    /// @param input Address to put into byte array.
    function writeAddress(bytes memory b, uint256 index, address input) internal pure {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                    b.length,
                    index + 20 // 20 is length of address
                )
            );
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return result bytes32 value from byte array.
    function readBytes32(bytes memory b, uint256 index) internal pure returns (bytes32 result) {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                    b.length,
                    index + 32
                )
            );
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Writes a bytes32 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes32 to put into byte array.
    function writeBytes32(bytes memory b, uint256 index, bytes32 input) internal pure {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                    b.length,
                    index + 32
                )
            );
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    /// @dev Reads a uint256 value from a position in a byte array.
    /// @param b Byte array containing a uint256 value.
    /// @param index Index in byte array of uint256 value.
    /// @return result uint256 value from byte array.
    function readUint256(bytes memory b, uint256 index) internal pure returns (uint256 result) {
        result = uint256(readBytes32(b, index));
        return result;
    }

    /// @dev Writes a uint256 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input uint256 to put into byte array.
    function writeUint256(bytes memory b, uint256 index, uint256 input) internal pure {
        writeBytes32(b, index, bytes32(input));
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return result bytes4 value from byte array.
    function readBytes4(bytes memory b, uint256 index) internal pure returns (bytes4 result) {
        if (b.length < index + 4) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                    b.length,
                    index + 4
                )
            );
        }

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    /// @dev Writes a new length to a byte array.
    ///      Decreasing length will lead to removing the corresponding lower order bytes from the byte array.
    ///      Increasing length may lead to appending adjacent in-memory bytes to the end of the byte array.
    /// @param b Bytes array to write new length to.
    /// @param length New length of byte array.
    function writeLength(bytes memory b, uint256 length) internal pure {
        assembly {
            mstore(b, length)
        }
    }
}

// File: /Users/sav/Repos/protocol/node_modules/@0x/contracts-erc20/src/v06/LibERC20TokenV06.sol

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





library LibERC20TokenV06 {
    bytes private constant DECIMALS_CALL_DATA = hex"313ce567";

    /// @dev Calls `IERC20Token(token).approve()`.
    ///      Reverts if the return data is invalid or the call reverts.
    /// @param token The address of the token contract.
    /// @param spender The address that receives an allowance.
    /// @param allowance The allowance to set.
    function compatApprove(IERC20Token token, address spender, uint256 allowance) internal {
        bytes memory callData = abi.encodeWithSelector(token.approve.selector, spender, allowance);
        _callWithOptionalBooleanResult(address(token), callData);
    }

    /// @dev Calls `IERC20Token(token).approve()` and sets the allowance to the
    ///      maximum if the current approval is not already >= an amount.
    ///      Reverts if the return data is invalid or the call reverts.
    /// @param token The address of the token contract.
    /// @param spender The address that receives an allowance.
    /// @param amount The minimum allowance needed.
    function approveIfBelow(IERC20Token token, address spender, uint256 amount) internal {
        if (token.allowance(address(this), spender) < amount) {
            compatApprove(token, spender, uint256(-1));
        }
    }

    /// @dev Calls `IERC20Token(token).transfer()`.
    ///      Reverts if the return data is invalid or the call reverts.
    /// @param token The address of the token contract.
    /// @param to The address that receives the tokens
    /// @param amount Number of tokens to transfer.
    function compatTransfer(IERC20Token token, address to, uint256 amount) internal {
        bytes memory callData = abi.encodeWithSelector(token.transfer.selector, to, amount);
        _callWithOptionalBooleanResult(address(token), callData);
    }

    /// @dev Calls `IERC20Token(token).transferFrom()`.
    ///      Reverts if the return data is invalid or the call reverts.
    /// @param token The address of the token contract.
    /// @param from The owner of the tokens.
    /// @param to The address that receives the tokens
    /// @param amount Number of tokens to transfer.
    function compatTransferFrom(IERC20Token token, address from, address to, uint256 amount) internal {
        bytes memory callData = abi.encodeWithSelector(token.transferFrom.selector, from, to, amount);
        _callWithOptionalBooleanResult(address(token), callData);
    }

    /// @dev Retrieves the number of decimals for a token.
    ///      Returns `18` if the call reverts.
    /// @param token The address of the token contract.
    /// @return tokenDecimals The number of decimals places for the token.
    function compatDecimals(IERC20Token token) internal view returns (uint8 tokenDecimals) {
        tokenDecimals = 18;
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(DECIMALS_CALL_DATA);
        if (didSucceed && resultData.length >= 32) {
            tokenDecimals = uint8(LibBytesV06.readUint256(resultData, 0));
        }
    }

    /// @dev Retrieves the allowance for a token, owner, and spender.
    ///      Returns `0` if the call reverts.
    /// @param token The address of the token contract.
    /// @param owner The owner of the tokens.
    /// @param spender The address the spender.
    /// @return allowance_ The allowance for a token, owner, and spender.
    function compatAllowance(
        IERC20Token token,
        address owner,
        address spender
    ) internal view returns (uint256 allowance_) {
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(
            abi.encodeWithSelector(token.allowance.selector, owner, spender)
        );
        if (didSucceed && resultData.length >= 32) {
            allowance_ = LibBytesV06.readUint256(resultData, 0);
        }
    }

    /// @dev Retrieves the balance for a token owner.
    ///      Returns `0` if the call reverts.
    /// @param token The address of the token contract.
    /// @param owner The owner of the tokens.
    /// @return balance The token balance of an owner.
    function compatBalanceOf(IERC20Token token, address owner) internal view returns (uint256 balance) {
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(
            abi.encodeWithSelector(token.balanceOf.selector, owner)
        );
        if (didSucceed && resultData.length >= 32) {
            balance = LibBytesV06.readUint256(resultData, 0);
        }
    }

    /// @dev Executes a call on address `target` with calldata `callData`
    ///      and asserts that either nothing was returned or a single boolean
    ///      was returned equal to `true`.
    /// @param target The call target.
    /// @param callData The abi-encoded call data.
    function _callWithOptionalBooleanResult(address target, bytes memory callData) private {
        (bool didSucceed, bytes memory resultData) = target.call(callData);
        // Revert if the call reverted.
        if (!didSucceed) {
            LibRichErrorsV06.rrevert(resultData);
        }
        // If we get back 0 returndata, this may be a non-standard ERC-20 that
        // does not return a boolean. Check that it at least contains code.
        if (resultData.length == 0) {
            uint256 size;
            assembly {
                size := extcodesize(target)
            }
            require(size > 0, "invalid token address, contains no code");
            return;
        }
        // If we get back at least 32 bytes, we know the target address
        // contains code, and we assume it is a token that returned a boolean
        // success value, which must be true.
        if (resultData.length >= 32) {
            uint256 result = LibBytesV06.readUint256(resultData, 0);
            if (result == 1) {
                return;
            } else {
                LibRichErrorsV06.rrevert(resultData);
            }
        }
        // If 0 < returndatasize < 32, the target is a contract, but not a
        // valid token.
        LibRichErrorsV06.rrevert(resultData);
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinAaveV2.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;




// Minimal Aave V2 LendingPool interface
interface ILendingPool {
    /**
     * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
     * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
     * @param asset The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
     *   is a different wallet
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without any middle-man
     **/
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;

    /**
     * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
     * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
     * @param to Address that will receive the underlying, same as msg.sender if the user
     *   wants to receive it on his own wallet, or a different address if the beneficiary is a
     *   different wallet
     * @return The final amount withdrawn
     **/
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

contract MixinAaveV2 {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeAaveV2(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256) {
        (ILendingPool lendingPool, address aToken) = abi.decode(bridgeData, (ILendingPool, address));

        sellToken.approveIfBelow(address(lendingPool), sellAmount);

        if (address(buyToken) == aToken) {
            lendingPool.deposit(address(sellToken), sellAmount, address(this), 0);
            // 1:1 mapping token -> aToken and have the same number of decimals as the underlying token
            return sellAmount;
        } else if (address(sellToken) == aToken) {
            return lendingPool.withdraw(address(buyToken), sellAmount, address(this));
        }

        revert("MixinAaveV2/UNSUPPORTED_TOKEN_PAIR");
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinBalancer.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;




interface IBalancerPool {
    /// @dev Sell `tokenAmountIn` of `tokenIn` and receive `tokenOut`.
    /// @param tokenIn The token being sold
    /// @param tokenAmountIn The amount of `tokenIn` to sell.
    /// @param tokenOut The token being bought.
    /// @param minAmountOut The minimum amount of `tokenOut` to buy.
    /// @param maxPrice The maximum value for `spotPriceAfter`.
    /// @return tokenAmountOut The amount of `tokenOut` bought.
    /// @return spotPriceAfter The new marginal spot price of the given
    ///         token pair for this pool.
    function swapExactAmountIn(
        IERC20Token tokenIn,
        uint256 tokenAmountIn,
        IERC20Token tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);
}

contract MixinBalancer {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeBalancer(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        // Decode the bridge data.
        IBalancerPool pool = abi.decode(bridgeData, (IBalancerPool));
        sellToken.approveIfBelow(address(pool), sellAmount);
        // Sell all of this contract's `sellToken` token balance.
        (boughtAmount, ) = pool.swapExactAmountIn(
            sellToken, // tokenIn
            sellAmount, // tokenAmountIn
            buyToken, // tokenOut
            1, // minAmountOut
            uint256(-1) // maxPrice
        );
        return boughtAmount;
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinBalancerV2Batch.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;




interface IBalancerV2BatchSwapVault {
    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function batchSwap(
        SwapKind kind,
        BatchSwapStep[] calldata swaps,
        IERC20Token[] calldata assets,
        FundManagement calldata funds,
        int256[] calldata limits,
        uint256 deadline
    ) external returns (int256[] memory amounts);
}

contract MixinBalancerV2Batch {
    using LibERC20TokenV06 for IERC20Token;

    struct BalancerV2BatchBridgeData {
        IBalancerV2BatchSwapVault vault;
        IBalancerV2BatchSwapVault.BatchSwapStep[] swapSteps;
        IERC20Token[] assets;
    }

    function _tradeBalancerV2Batch(
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        // Decode the bridge data.
        (
            IBalancerV2BatchSwapVault vault,
            IBalancerV2BatchSwapVault.BatchSwapStep[] memory swapSteps,
            address[] memory assets_
        ) = abi.decode(bridgeData, (IBalancerV2BatchSwapVault, IBalancerV2BatchSwapVault.BatchSwapStep[], address[]));
        IERC20Token[] memory assets;
        assembly {
            assets := assets_
        }

        // Grant an allowance to the exchange to spend `fromTokenAddress` token.
        assets[0].approveIfBelow(address(vault), sellAmount);

        swapSteps[0].amount = sellAmount;
        int256[] memory limits = new int256[](assets.length);
        for (uint256 i = 0; i < limits.length; ++i) {
            limits[i] = type(int256).max;
        }

        int256[] memory amounts = vault.batchSwap(
            IBalancerV2BatchSwapVault.SwapKind.GIVEN_IN,
            swapSteps,
            assets,
            IBalancerV2BatchSwapVault.FundManagement({
                sender: address(this),
                fromInternalBalance: false,
                recipient: payable(address(this)),
                toInternalBalance: false
            }),
            limits,
            block.timestamp + 1
        );
        require(amounts[amounts.length - 1] <= 0, "Unexpected BalancerV2Batch output");
        return uint256(amounts[amounts.length - 1] * -1);
    }
}

// File: /Users/sav/Repos/protocol/node_modules/@0x/contracts-erc20/src/IEtherToken.sol

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface IEtherToken is IERC20Token {
    /// @dev Wrap ether.
    function deposit() external payable;

    /// @dev Unwrap ether.
    function withdraw(uint256 amount) external;
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinBancorV3.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





/*
    BancorV3
*/
interface IBancorV3 {
    /**
     * @dev performs a trade by providing the source amount and returns the target amount and the associated fee
     *
     * requirements:
     *
     * - the caller must be the network contract
     */
    function tradeBySourceAmount(
        address sourceToken,
        address targetToken,
        uint256 sourceAmount,
        uint256 minReturnAmount,
        uint256 deadline,
        address beneficiary
    ) external payable returns (uint256 amount);
}

contract MixinBancorV3 {
    using LibERC20TokenV06 for IERC20Token;

    IERC20Token public constant BANCORV3_ETH_ADDRESS = IERC20Token(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IEtherToken private immutable WETH;

    constructor(IEtherToken weth) public {
        WETH = weth;
    }

    function _tradeBancorV3(
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 amountOut) {
        IBancorV3 router;
        IERC20Token[] memory path;
        address[] memory _path;
        uint256 payableAmount = 0;

        {
            (router, _path) = abi.decode(bridgeData, (IBancorV3, address[]));
            // To get around `abi.decode()` not supporting interface array types.
            assembly {
                path := _path
            }
        }

        require(path.length >= 2, "MixinBancorV3/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(path[path.length - 1] == buyToken, "MixinBancorV3/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN");

        //swap WETH->ETH as Bancor only deals in ETH
        if (_path[0] == address(WETH)) {
            //withdraw the sell amount of WETH for ETH
            WETH.withdraw(sellAmount);
            payableAmount = sellAmount;
            // set _path[0] to the ETH address if WETH is our buy token
            _path[0] = address(BANCORV3_ETH_ADDRESS);
        } else {
            // Grant the BancorV3 router an allowance to sell the first token.
            path[0].approveIfBelow(address(router), sellAmount);
        }

        // if we are buying WETH we need to swap to ETH and deposit into WETH after the swap
        if (_path[1] == address(WETH)) {
            _path[1] = address(BANCORV3_ETH_ADDRESS);
        }

        uint256 amountOut = router.tradeBySourceAmount{value: payableAmount}(
            _path[0],
            _path[1],
            // Sell all tokens we hold.
            sellAmount,
            // Minimum buy amount.
            1,
            //deadline
            block.timestamp + 1,
            // address of the mixin
            address(this)
        );

        // if we want to return WETH deposit the ETH amount we sold
        if (buyToken == WETH) {
            WETH.deposit{value: amountOut}();
        }

        return amountOut;
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinBarter.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





contract MixinBarter {
    using LibERC20TokenV06 for IERC20Token;
    using LibRichErrorsV06 for bytes;

    function _tradeBarter(
        IERC20Token sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        (address barterRouter, bytes memory data) = abi.decode(bridgeData, (address, bytes));
        sellToken.approveIfBelow(barterRouter, sellAmount);

        (bool success, bytes memory resultData) = barterRouter.call(data);
        if (!success) {
            resultData.rrevert();
        }

        return abi.decode(resultData, (uint256));
    }
}

// File: /Users/sav/Repos/protocol/node_modules/@0x/contracts-utils/contracts/src/v06/errors/LibSafeMathRichErrorsV06.sol

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibSafeMathRichErrorsV06 {
    // bytes4(keccak256("Uint256BinOpError(uint8,uint256,uint256)"))
    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR = 0xe946c1bb;

    // bytes4(keccak256("Uint256DowncastError(uint8,uint256)"))
    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR = 0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT128
    }

    function Uint256BinOpError(BinOpErrorCodes errorCode, uint256 a, uint256 b) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(UINT256_BINOP_ERROR_SELECTOR, errorCode, a, b);
    }

    function Uint256DowncastError(DowncastErrorCodes errorCode, uint256 a) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(UINT256_DOWNCAST_ERROR_SELECTOR, errorCode, a);
    }
}

// File: /Users/sav/Repos/protocol/node_modules/@0x/contracts-utils/contracts/src/v06/LibSafeMathV06.sol

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




library LibSafeMathV06 {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                    a,
                    b
                )
            );
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                    a,
                    b
                )
            );
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                    a,
                    b
                )
            );
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                    a,
                    b
                )
            );
        }
        return c;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function safeMul128(uint128 a, uint128 b) internal pure returns (uint128) {
        if (a == 0) {
            return 0;
        }
        uint128 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                    a,
                    b
                )
            );
        }
        return c;
    }

    function safeDiv128(uint128 a, uint128 b) internal pure returns (uint128) {
        if (b == 0) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                    a,
                    b
                )
            );
        }
        uint128 c = a / b;
        return c;
    }

    function safeSub128(uint128 a, uint128 b) internal pure returns (uint128) {
        if (b > a) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                    a,
                    b
                )
            );
        }
        return a - b;
    }

    function safeAdd128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                    a,
                    b
                )
            );
        }
        return c;
    }

    function max128(uint128 a, uint128 b) internal pure returns (uint128) {
        return a >= b ? a : b;
    }

    function min128(uint128 a, uint128 b) internal pure returns (uint128) {
        return a < b ? a : b;
    }

    function safeDowncastToUint128(uint256 a) internal pure returns (uint128) {
        if (a > type(uint128).max) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256DowncastError(
                    LibSafeMathRichErrorsV06.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT128,
                    a
                )
            );
        }
        return uint128(a);
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinCompound.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;






/// @dev Minimal CToken interface
interface ICToken {
    /// @dev deposits specified amount underlying tokens and mints cToken for the sender
    /// @param mintAmountInUnderlying amount of underlying tokens to deposit to mint cTokens
    /// @return status code of whether the mint was successful or not
    function mint(uint256 mintAmountInUnderlying) external returns (uint256);

    /// @dev redeems specified amount of cTokens and returns the underlying token to the sender
    /// @param redeemTokensInCtokens amount of cTokens to redeem for underlying collateral
    /// @return status code of whether the redemption was successful or not
    function redeem(uint256 redeemTokensInCtokens) external returns (uint256);
}

/// @dev Minimal CEther interface
interface ICEther {
    /// @dev deposits the amount of Ether sent as value and return mints cEther for the sender
    function mint() external payable;

    /// @dev redeems specified amount of cETH and returns the underlying ether to the sender
    /// @dev redeemTokensInCEther amount of cETH to redeem for underlying ether
    /// @return status code of whether the redemption was successful or not
    function redeem(uint256 redeemTokensInCEther) external returns (uint256);
}

contract MixinCompound {
    using LibERC20TokenV06 for IERC20Token;
    using LibSafeMathV06 for uint256;

    IEtherToken private immutable WETH;

    constructor(IEtherToken weth) public {
        WETH = weth;
    }

    uint256 private constant COMPOUND_SUCCESS_CODE = 0;

    function _tradeCompound(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256) {
        address cTokenAddress = abi.decode(bridgeData, (address));
        uint256 beforeBalance = buyToken.balanceOf(address(this));

        if (address(buyToken) == cTokenAddress) {
            if (address(sellToken) == address(WETH)) {
                // ETH/WETH -> cETH
                ICEther cETH = ICEther(cTokenAddress);
                // Compound expects ETH to be sent with mint call
                WETH.withdraw(sellAmount);
                // NOTE: cETH mint will revert on failure instead of returning a status code
                cETH.mint{value: sellAmount}();
            } else {
                sellToken.approveIfBelow(cTokenAddress, sellAmount);
                // Token -> cToken
                ICToken cToken = ICToken(cTokenAddress);
                require(cToken.mint(sellAmount) == COMPOUND_SUCCESS_CODE, "MixinCompound/FAILED_TO_MINT_CTOKEN");
            }
        } else if (address(sellToken) == cTokenAddress) {
            if (address(buyToken) == address(WETH)) {
                // cETH -> ETH/WETH
                uint256 etherBalanceBefore = address(this).balance;
                ICEther cETH = ICEther(cTokenAddress);
                require(cETH.redeem(sellAmount) == COMPOUND_SUCCESS_CODE, "MixinCompound/FAILED_TO_REDEEM_CETHER");
                uint256 etherBalanceAfter = address(this).balance;
                uint256 receivedEtherBalance = etherBalanceAfter.safeSub(etherBalanceBefore);
                WETH.deposit{value: receivedEtherBalance}();
            } else {
                ICToken cToken = ICToken(cTokenAddress);
                require(cToken.redeem(sellAmount) == COMPOUND_SUCCESS_CODE, "MixinCompound/FAILED_TO_REDEEM_CTOKEN");
            }
        }

        return buyToken.balanceOf(address(this)).safeSub(beforeBalance);
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinCurve.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;







contract MixinCurve {
    using LibERC20TokenV06 for IERC20Token;
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    /// @dev Mainnet address of the WETH contract.
    IEtherToken private immutable WETH;

    constructor(IEtherToken weth) public {
        WETH = weth;
    }

    struct CurveBridgeData {
        address curveAddress;
        bytes4 exchangeFunctionSelector;
        int128 fromCoinIdx;
        int128 toCoinIdx;
    }

    function _tradeCurve(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        // Decode the bridge data to get the Curve metadata.
        CurveBridgeData memory data = abi.decode(bridgeData, (CurveBridgeData));
        uint256 payableAmount;
        if (sellToken == WETH) {
            payableAmount = sellAmount;
            WETH.withdraw(sellAmount);
        } else {
            sellToken.approveIfBelow(data.curveAddress, sellAmount);
        }

        uint256 beforeBalance = buyToken.balanceOf(address(this));
        (bool success, bytes memory resultData) = data.curveAddress.call{value: payableAmount}(
            abi.encodeWithSelector(
                data.exchangeFunctionSelector,
                data.fromCoinIdx,
                data.toCoinIdx,
                // dx
                sellAmount,
                // min dy
                1
            )
        );
        if (!success) {
            resultData.rrevert();
        }

        if (buyToken == WETH) {
            boughtAmount = address(this).balance;
            WETH.deposit{value: boughtAmount}();
        }

        return buyToken.balanceOf(address(this)).safeSub(beforeBalance);
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinCurveV2.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;






contract MixinCurveV2 {
    using LibERC20TokenV06 for IERC20Token;
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    struct CurveBridgeDataV2 {
        address curveAddress;
        bytes4 exchangeFunctionSelector;
        int128 fromCoinIdx;
        int128 toCoinIdx;
    }

    function _tradeCurveV2(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        // Decode the bridge data to get the Curve metadata.
        CurveBridgeDataV2 memory data = abi.decode(bridgeData, (CurveBridgeDataV2));
        sellToken.approveIfBelow(data.curveAddress, sellAmount);

        uint256 beforeBalance = buyToken.balanceOf(address(this));
        (bool success, bytes memory resultData) = data.curveAddress.call(
            abi.encodeWithSelector(
                data.exchangeFunctionSelector,
                data.fromCoinIdx,
                data.toCoinIdx,
                // dx
                sellAmount,
                // min dy
                1
            )
        );
        if (!success) {
            resultData.rrevert();
        }

        return buyToken.balanceOf(address(this)).safeSub(beforeBalance);
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinUniswapV2.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





/*
    UniswapV2
*/
interface IUniswapV2Router02 {
    /// @dev Swaps an exact amount of input tokens for as many output tokens as possible, along the route determined by
    /// the path. The first element of path is the input token, the last is the output token, and any intermediate
    /// elements represent intermediate pairs to trade through (if, for example, a direct pair does not exist).
    /// @param amountIn The amount of input tokens to send.
    /// @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert.
    /// @param path An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses
    /// must exist and have liquidity.
    /// @param to Recipient of the output tokens.
    /// @param deadline Unix timestamp after which the transaction will revert.
    /// @return amounts The input token amount and all subsequent output token amounts.
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        IERC20Token[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract MixinUniswapV2 {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeUniswapV2(
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        IUniswapV2Router02 router;
        IERC20Token[] memory path;
        {
            address[] memory _path;
            (router, _path) = abi.decode(bridgeData, (IUniswapV2Router02, address[]));
            // To get around `abi.decode()` not supporting interface array types.
            assembly {
                path := _path
            }
        }

        require(path.length >= 2, "MixinUniswapV2/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(path[path.length - 1] == buyToken, "MixinUniswapV2/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN");
        // Grant the Uniswap router an allowance to sell the first token.
        path[0].approveIfBelow(address(router), sellAmount);

        uint256[] memory amounts = router.swapExactTokensForTokens(
            // Sell all tokens we hold.
            sellAmount,
            // Minimum buy amount.
            1,
            // Convert to `buyToken` along this path.
            path,
            // Recipient is `this`.
            address(this),
            // Expires after this block.
            block.timestamp
        );
        return amounts[amounts.length - 1];
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinCryptoCom.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





contract MixinCryptoCom {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeCryptoCom(
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        IUniswapV2Router02 router;
        IERC20Token[] memory path;
        {
            address[] memory _path;
            (router, _path) = abi.decode(bridgeData, (IUniswapV2Router02, address[]));
            // To get around `abi.decode()` not supporting interface array types.
            assembly {
                path := _path
            }
        }

        require(path.length >= 2, "MixinCryptoCom/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(path[path.length - 1] == buyToken, "MixinCryptoCom/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN");
        // Grant the CryptoCom router an allowance to sell the first token.
        path[0].approveIfBelow(address(router), sellAmount);

        uint256[] memory amounts = router.swapExactTokensForTokens(
            // Sell all tokens we hold.
            sellAmount,
            // Minimum buy amount.
            1,
            // Convert to `buyToken` along this path.
            path,
            // Recipient is `this`.
            address(this),
            // Expires after this block.
            block.timestamp
        );
        return amounts[amounts.length - 1];
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinDodo.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





interface IDODO {
    function sellBaseToken(uint256 amount, uint256 minReceiveQuote, bytes calldata data) external returns (uint256);

    function buyBaseToken(uint256 amount, uint256 maxPayQuote, bytes calldata data) external returns (uint256);
}

interface IDODOHelper {
    function querySellQuoteToken(IDODO dodo, uint256 amount) external view returns (uint256);
}

contract MixinDodo {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeDodo(
        IERC20Token sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        (IDODOHelper helper, IDODO pool, bool isSellBase) = abi.decode(bridgeData, (IDODOHelper, IDODO, bool));

        // Grant the Dodo pool contract an allowance to sell the first token.
        sellToken.approveIfBelow(address(pool), sellAmount);

        if (isSellBase) {
            // Sell the Base token directly against the contract
            boughtAmount = pool.sellBaseToken(
                // amount to sell
                sellAmount,
                // min receive amount
                1,
                new bytes(0)
            );
        } else {
            // Need to re-calculate the sell quote amount into buyBase
            boughtAmount = helper.querySellQuoteToken(pool, sellAmount);
            pool.buyBaseToken(
                // amount to buy
                boughtAmount,
                // max pay amount
                sellAmount,
                new bytes(0)
            );
        }

        return boughtAmount;
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinDodoV2.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





interface IDODOV2 {
    function sellBase(address recipient) external returns (uint256);

    function sellQuote(address recipient) external returns (uint256);
}

contract MixinDodoV2 {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeDodoV2(
        IERC20Token sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        (IDODOV2 pool, bool isSellBase) = abi.decode(bridgeData, (IDODOV2, bool));

        // Transfer the tokens into the pool
        sellToken.compatTransfer(address(pool), sellAmount);

        boughtAmount = isSellBase ? pool.sellBase(address(this)) : pool.sellQuote(address(this));
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinKyberDmm.sol

/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





/*
    KyberDmm Router
*/
interface IKyberDmmRouter {
    /// @dev Swaps an exact amount of input tokens for as many output tokens as possible, along the route determined by
    /// the path. The first element of path is the input token, the last is the output token, and any intermediate
    /// elements represent intermediate pairs to trade through (if, for example, a direct pair does not exist).
    /// @param amountIn The amount of input tokens to send.
    /// @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert.
    /// @param pools An array of pool addresses. pools.length must be >= 1.
    /// @param path An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses
    /// must exist and have liquidity.
    /// @param to Recipient of the output tokens.
    /// @param deadline Unix timestamp after which the transaction will revert.
    /// @return amounts The input token amount and all subsequent output token amounts.
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata pools,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract MixinKyberDmm {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeKyberDmm(
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        address router;
        address[] memory pools;
        address[] memory path;
        (router, pools, path) = abi.decode(bridgeData, (address, address[], address[]));

        require(pools.length >= 1, "MixinKyberDmm/POOLS_LENGTH_MUST_BE_AT_LEAST_ONE");
        require(path.length == pools.length + 1, "MixinKyberDmm/ARRAY_LENGTH_MISMATCH");
        require(
            path[path.length - 1] == address(buyToken),
            "MixinKyberDmm/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
        );
        // Grant the KyberDmm router an allowance to sell the first token.
        IERC20Token(path[0]).approveIfBelow(address(router), sellAmount);

        uint256[] memory amounts = IKyberDmmRouter(router).swapExactTokensForTokens(
            // Sell all tokens we hold.
            sellAmount,
            // Minimum buy amount.
            1,
            pools,
            // Convert to `buyToken` along this path.
            path,
            // Recipient is `this`.
            address(this),
            // Expires after this block.
            block.timestamp
        );
        return amounts[amounts.length - 1];
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinKyberElastic.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;




interface IKyberElasticRouter {
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 minAmountOut;
    }

    function swapExactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
}

contract MixinKyberElastic {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeKyberElastic(
        IERC20Token sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        (IKyberElasticRouter router, bytes memory path) = abi.decode(bridgeData, (IKyberElasticRouter, bytes));

        // Grant the Kyber router an allowance to sell the sell token.
        sellToken.approveIfBelow(address(router), sellAmount);

        boughtAmount = router.swapExactInput(
            IKyberElasticRouter.ExactInputParams({
                path: path,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: sellAmount,
                minAmountOut: 1
            })
        );
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinLido.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





/// @dev Minimal interface for minting StETH
interface IStETH {
    /// @dev Adds eth to the pool
    /// @param _referral optional address for referrals
    /// @return StETH Amount of shares generated
    function submit(address _referral) external payable returns (uint256 StETH);

    /// @dev Retrieve the current pooled ETH representation of the shares amount
    /// @param _sharesAmount amount of shares
    /// @return amount of pooled ETH represented by the shares amount
    function getPooledEthByShares(uint256 _sharesAmount) external view returns (uint256);
}

/// @dev Minimal interface for wrapping/unwrapping stETH.
interface IWstETH {
    /**
     * @notice Exchanges stETH to wstETH
     * @param _stETHAmount amount of stETH to wrap in exchange for wstETH
     * @dev Requirements:
     *  - `_stETHAmount` must be non-zero
     *  - msg.sender must approve at least `_stETHAmount` stETH to this
     *    contract.
     *  - msg.sender must have at least `_stETHAmount` of stETH.
     * User should first approve _stETHAmount to the WstETH contract
     * @return Amount of wstETH user receives after wrap
     */
    function wrap(uint256 _stETHAmount) external returns (uint256);

    /**
     * @notice Exchanges wstETH to stETH
     * @param _wstETHAmount amount of wstETH to uwrap in exchange for stETH
     * @dev Requirements:
     *  - `_wstETHAmount` must be non-zero
     *  - msg.sender must have at least `_wstETHAmount` wstETH.
     * @return Amount of stETH user receives after unwrap
     */
    function unwrap(uint256 _wstETHAmount) external returns (uint256);
}

contract MixinLido {
    using LibERC20TokenV06 for IERC20Token;
    using LibERC20TokenV06 for IEtherToken;

    IEtherToken private immutable WETH;

    constructor(IEtherToken weth) public {
        WETH = weth;
    }

    function _tradeLido(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        if (address(sellToken) == address(WETH)) {
            return _tradeStETH(buyToken, sellAmount, bridgeData);
        }

        return _tradeWstETH(sellToken, buyToken, sellAmount, bridgeData);
    }

    function _tradeStETH(
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) private returns (uint256 boughtAmount) {
        IStETH stETH = abi.decode(bridgeData, (IStETH));
        if (address(buyToken) == address(stETH)) {
            WETH.withdraw(sellAmount);
            return stETH.getPooledEthByShares(stETH.submit{value: sellAmount}(address(0)));
        }

        revert("MixinLido/UNSUPPORTED_TOKEN_PAIR");
    }

    function _tradeWstETH(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) private returns (uint256 boughtAmount) {
        (IEtherToken stETH, IWstETH wstETH) = abi.decode(bridgeData, (IEtherToken, IWstETH));
        if (address(sellToken) == address(stETH) && address(buyToken) == address(wstETH)) {
            sellToken.approveIfBelow(address(wstETH), sellAmount);
            return wstETH.wrap(sellAmount);
        }
        if (address(sellToken) == address(wstETH) && address(buyToken) == address(stETH)) {
            return wstETH.unwrap(sellAmount);
        }

        revert("MixinLido/UNSUPPORTED_TOKEN_PAIR");
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinMakerPSM.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





interface IPSM {
    // @dev Get the fee for selling USDC to DAI in PSM
    // @return tin toll in [wad]
    function tin() external view returns (uint256);

    // @dev Get the fee for selling DAI to USDC in PSM
    // @return tout toll out [wad]
    function tout() external view returns (uint256);

    // @dev Get the address of the PSM state Vat
    // @return address of the Vat
    function vat() external view returns (address);

    // @dev Get the address of the underlying vault powering PSM
    // @return address of gemJoin contract
    function gemJoin() external view returns (address);

    // @dev Sell USDC for DAI
    // @param usr The address of the account trading USDC for DAI.
    // @param gemAmt The amount of USDC to sell in USDC base units
    function sellGem(address usr, uint256 gemAmt) external;

    // @dev Buy USDC for DAI
    // @param usr The address of the account trading DAI for USDC
    // @param gemAmt The amount of USDC to buy in USDC base units
    function buyGem(address usr, uint256 gemAmt) external;
}

contract MixinMakerPSM {
    using LibERC20TokenV06 for IERC20Token;
    using LibSafeMathV06 for uint256;

    struct MakerPsmBridgeData {
        address psmAddress;
        address gemTokenAddres;
    }

    // Maker units
    // wad: fixed point decimal with 18 decimals (for basic quantities, e.g. balances)
    uint256 private constant WAD = 10 ** 18;
    // ray: fixed point decimal with 27 decimals (for precise quantites, e.g. ratios)
    uint256 private constant RAY = 10 ** 27;
    // rad: fixed point decimal with 45 decimals (result of integer multiplication with a wad and a ray)
    uint256 private constant RAD = 10 ** 45;

    // See https://github.com/makerdao/dss/blob/master/DEVELOPING.md

    function _tradeMakerPsm(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        // Decode the bridge data.
        MakerPsmBridgeData memory data = abi.decode(bridgeData, (MakerPsmBridgeData));
        uint256 beforeBalance = buyToken.balanceOf(address(this));

        IPSM psm = IPSM(data.psmAddress);

        if (address(sellToken) == data.gemTokenAddres) {
            sellToken.approveIfBelow(psm.gemJoin(), sellAmount);

            psm.sellGem(address(this), sellAmount);
        } else if (address(buyToken) == data.gemTokenAddres) {
            uint256 feeDivisor = WAD.safeAdd(psm.tout()); // eg. 1.001 * 10 ** 18 with 0.1% fee [tout is in wad];
            uint256 buyTokenBaseUnit = uint256(10) ** uint256(buyToken.decimals());
            uint256 gemAmount = sellAmount.safeMul(buyTokenBaseUnit).safeDiv(feeDivisor);

            sellToken.approveIfBelow(data.psmAddress, sellAmount);
            psm.buyGem(address(this), gemAmount);
        }

        return buyToken.balanceOf(address(this)).safeSub(beforeBalance);
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinMaverickV1.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;




interface IMaverickV1Router {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        address pool;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint256 sqrtPriceLimitD18;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

contract MixinMaverickV1 {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeMaverickV1(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        (IMaverickV1Router router, address pool) = abi.decode(bridgeData, (IMaverickV1Router, address));

        // Grant the MaverickV1 router an allowance to sell the sellToken
        sellToken.approveIfBelow(address(router), sellAmount);

        boughtAmount = router.exactInputSingle(
            IMaverickV1Router.ExactInputSingleParams({
                tokenIn: address(sellToken),
                tokenOut: address(buyToken),
                pool: pool,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: sellAmount,
                amountOutMinimum: 1,
                sqrtPriceLimitD18: 0
            })
        );
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinNerve.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;






contract MixinNerve {
    using LibERC20TokenV06 for IERC20Token;
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    struct NerveBridgeData {
        address pool;
        bytes4 exchangeFunctionSelector;
        int128 fromCoinIdx;
        int128 toCoinIdx;
    }

    function _tradeNerve(
        IERC20Token sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        // Basically a Curve fork but the swap option has a deadline

        // Decode the bridge data to get the Curve metadata.
        NerveBridgeData memory data = abi.decode(bridgeData, (NerveBridgeData));
        sellToken.approveIfBelow(data.pool, sellAmount);
        (bool success, bytes memory resultData) = data.pool.call(
            abi.encodeWithSelector(
                data.exchangeFunctionSelector,
                data.fromCoinIdx,
                data.toCoinIdx,
                // dx
                sellAmount,
                // min dy
                1,
                // deadline
                block.timestamp
            )
        );
        if (!success) {
            resultData.rrevert();
        }
        return abi.decode(resultData, (uint256));
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinSynthetix.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;

interface ISynthetix {
    // Ethereum Mainnet
    function exchangeAtomically(
        bytes32 sourceCurrencyKey,
        uint256 sourceAmount,
        bytes32 destinationCurrencyKey,
        bytes32 trackingCode,
        uint256 minAmount
    ) external returns (uint256 amountReceived);

    // Optimism
    function exchangeWithTracking(
        bytes32 sourceCurrencyKey,
        uint256 sourceAmount,
        bytes32 destinationCurrencyKey,
        address rewardAddress,
        bytes32 trackingCode
    ) external returns (uint256 amountReceived);
}

contract MixinSynthetix {
    // solhint-disable-next-line const-name-snakecase
    address private constant rewardAddress = 0x5C80239D97E1eB216b5c3D8fBa5DE5Be5d38e4C9;
    // solhint-disable-next-line const-name-snakecase
    bytes32 constant trackingCode = 0x3058000000000000000000000000000000000000000000000000000000000000;

    function _tradeSynthetix(uint256 sellAmount, bytes memory bridgeData) public returns (uint256 boughtAmount) {
        (ISynthetix synthetix, bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) = abi.decode(
            bridgeData,
            (ISynthetix, bytes32, bytes32)
        );

        boughtAmount = exchange(synthetix, sourceCurrencyKey, destinationCurrencyKey, sellAmount);
    }

    function exchange(
        ISynthetix synthetix,
        bytes32 sourceCurrencyKey,
        bytes32 destinationCurrencyKey,
        uint256 sellAmount
    ) internal returns (uint256 boughtAmount) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        if (chainId == 1) {
            boughtAmount = synthetix.exchangeAtomically(
                sourceCurrencyKey,
                sellAmount,
                destinationCurrencyKey,
                trackingCode,
                0
            );
        } else {
            boughtAmount = synthetix.exchangeWithTracking(
                sourceCurrencyKey,
                sellAmount,
                destinationCurrencyKey,
                rewardAddress,
                trackingCode
            );
        }
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinUniswap.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;






interface IUniswapExchangeFactory {
    /// @dev Get the exchange for a token.
    /// @param token The token contract.
    function getExchange(IERC20Token token) external view returns (IUniswapExchange exchange);
}

interface IUniswapExchange {
    /// @dev Buys at least `minTokensBought` tokens with ETH and transfer them
    ///      to `recipient`.
    /// @param minTokensBought The minimum number of tokens to buy.
    /// @param deadline Time when this order expires.
    /// @param recipient Who to transfer the tokens to.
    /// @return tokensBought Amount of tokens bought.
    function ethToTokenTransferInput(
        uint256 minTokensBought,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256 tokensBought);

    /// @dev Buys at least `minEthBought` ETH with tokens.
    /// @param tokensSold Amount of tokens to sell.
    /// @param minEthBought The minimum amount of ETH to buy.
    /// @param deadline Time when this order expires.
    /// @return ethBought Amount of tokens bought.
    function tokenToEthSwapInput(
        uint256 tokensSold,
        uint256 minEthBought,
        uint256 deadline
    ) external returns (uint256 ethBought);

    /// @dev Buys at least `minTokensBought` tokens with the exchange token
    ///      and transfer them to `recipient`.
    /// @param tokensSold Amount of tokens to sell.
    /// @param minTokensBought The minimum number of tokens to buy.
    /// @param minEthBought The minimum amount of intermediate ETH to buy.
    /// @param deadline Time when this order expires.
    /// @param recipient Who to transfer the tokens to.
    /// @param buyToken The token being bought.
    /// @return tokensBought Amount of tokens bought.
    function tokenToTokenTransferInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint256 deadline,
        address recipient,
        IERC20Token buyToken
    ) external returns (uint256 tokensBought);

    /// @dev Buys at least `minTokensBought` tokens with the exchange token.
    /// @param tokensSold Amount of tokens to sell.
    /// @param minTokensBought The minimum number of tokens to buy.
    /// @param minEthBought The minimum amount of intermediate ETH to buy.
    /// @param deadline Time when this order expires.
    /// @param buyToken The token being bought.
    /// @return tokensBought Amount of tokens bought.
    function tokenToTokenSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint256 deadline,
        IERC20Token buyToken
    ) external returns (uint256 tokensBought);
}

contract MixinUniswap {
    using LibERC20TokenV06 for IERC20Token;

    /// @dev Mainnet address of the WETH contract.
    IEtherToken private immutable WETH;

    constructor(IEtherToken weth) public {
        WETH = weth;
    }

    //B7solhint-disable-next-lineB7function-max-lines
    function _tradeUniswap(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        IUniswapExchangeFactory exchangeFactory = abi.decode(bridgeData, (IUniswapExchangeFactory));

        // Get the exchange for the token pair.
        IUniswapExchange exchange = _getUniswapExchangeForTokenPair(exchangeFactory, sellToken, buyToken);

        // Convert from WETH to a token.
        if (sellToken == WETH) {
            // Unwrap the WETH.
            WETH.withdraw(sellAmount);
            // Buy as much of `buyToken` token with ETH as possible
            boughtAmount = exchange.ethToTokenTransferInput{value: sellAmount}(
                // Minimum buy amount.
                1,
                // Expires after this block.
                block.timestamp,
                // Recipient is `this`.
                address(this)
            );

            // Convert from a token to WETH.
        } else if (buyToken == WETH) {
            // Grant the exchange an allowance.
            sellToken.approveIfBelow(address(exchange), sellAmount);
            // Buy as much ETH with `sellToken` token as possible.
            boughtAmount = exchange.tokenToEthSwapInput(
                // Sell all tokens we hold.
                sellAmount,
                // Minimum buy amount.
                1,
                // Expires after this block.
                block.timestamp
            );
            // Wrap the ETH.
            WETH.deposit{value: boughtAmount}();
            // Convert from one token to another.
        } else {
            // Grant the exchange an allowance.
            sellToken.approveIfBelow(address(exchange), sellAmount);
            // Buy as much `buyToken` token with `sellToken` token
            boughtAmount = exchange.tokenToTokenSwapInput(
                // Sell all tokens we hold.
                sellAmount,
                // Minimum buy amount.
                1,
                // Must buy at least 1 intermediate wei of ETH.
                1,
                // Expires after this block.
                block.timestamp,
                // Convert to `buyToken`.
                buyToken
            );
        }

        return boughtAmount;
    }

    /// @dev Retrieves the uniswap exchange for a given token pair.
    ///      In the case of a WETH-token exchange, this will be the non-WETH token.
    ///      In th ecase of a token-token exchange, this will be the first token.
    /// @param exchangeFactory The exchange factory.
    /// @param sellToken The address of the token we are converting from.
    /// @param buyToken The address of the token we are converting to.
    /// @return exchange The uniswap exchange.
    function _getUniswapExchangeForTokenPair(
        IUniswapExchangeFactory exchangeFactory,
        IERC20Token sellToken,
        IERC20Token buyToken
    ) private view returns (IUniswapExchange exchange) {
        // Whichever isn't WETH is the exchange token.
        exchange = sellToken == WETH ? exchangeFactory.getExchange(buyToken) : exchangeFactory.getExchange(sellToken);
        require(address(exchange) != address(0), "MixinUniswap/NO_EXCHANGE");
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinUniswapV3.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;





interface IUniswapV3Router {
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams memory params) external payable returns (uint256 amountOut);
}

// https://github.com/Uniswap/swap-router-contracts/blob/main/contracts/interfaces/IV3SwapRouter.sol
interface IUniswapV3Router2 {
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams memory params) external payable returns (uint256 amountOut);
}

contract MixinUniswapV3 {
    using LibERC20TokenV06 for IERC20Token;

    function _tradeUniswapV3(
        IERC20Token sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        (address router, bytes memory path, uint256 routerVersion) = abi.decode(bridgeData, (address, bytes, uint256));

        // Grant the Uniswap router an allowance to sell the sell token.
        sellToken.approveIfBelow(router, sellAmount);

        if (routerVersion != 2) {
            boughtAmount = IUniswapV3Router(router).exactInput(
                IUniswapV3Router.ExactInputParams({
                    path: path,
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: sellAmount,
                    amountOutMinimum: 1
                })
            );
        } else {
            boughtAmount = IUniswapV3Router2(router).exactInput(
                IUniswapV3Router2.ExactInputParams({
                    path: path,
                    recipient: address(this),
                    amountIn: sellAmount,
                    amountOutMinimum: 1
                })
            );
        }
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/vendor/ILiquidityProvider.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;



interface ILiquidityProvider {
    /// @dev An optional event an LP can emit for each fill against a source.
    /// @param inputToken The input token.
    /// @param outputToken The output token.
    /// @param inputTokenAmount How much input token was sold.
    /// @param outputTokenAmount How much output token was bought.
    /// @param sourceId A bytes32 encoded ascii source ID. E.g., `bytes32('Curve')`/
    /// @param sourceAddress An optional address associated with the source (e.g, a curve pool).
    /// @param sourceId A bytes32 encoded ascii source ID. E.g., `bytes32('Curve')`/
    /// @param sourceAddress An optional address associated with the source (e.g, a curve pool).
    /// @param sender The caller of the LP.
    /// @param recipient The recipient of the output tokens.
    event LiquidityProviderFill(
        IERC20Token inputToken,
        IERC20Token outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount,
        bytes32 sourceId,
        address sourceAddress,
        address sender,
        address recipient
    );

    /// @dev Trades `inputToken` for `outputToken`. The amount of `inputToken`
    ///      to sell must be transferred to the contract prior to calling this
    ///      function to trigger the trade.
    /// @param inputToken The token being sold.
    /// @param outputToken The token being bought.
    /// @param recipient The recipient of the bought tokens.
    /// @param minBuyAmount The minimum acceptable amount of `outputToken` to buy.
    /// @param auxiliaryData Arbitrary auxiliary data supplied to the contract.
    /// @return boughtAmount The amount of `outputToken` bought.
    function sellTokenForToken(
        IERC20Token inputToken,
        IERC20Token outputToken,
        address recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    ) external returns (uint256 boughtAmount);

    /// @dev Trades ETH for token. ETH must either be attached to this function
    ///      call or sent to the contract prior to calling this function to
    ///      trigger the trade.
    /// @param outputToken The token being bought.
    /// @param recipient The recipient of the bought tokens.
    /// @param minBuyAmount The minimum acceptable amount of `outputToken` to buy.
    /// @param auxiliaryData Arbitrary auxiliary data supplied to the contract.
    /// @return boughtAmount The amount of `outputToken` bought.
    function sellEthForToken(
        IERC20Token outputToken,
        address recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    ) external payable returns (uint256 boughtAmount);

    /// @dev Trades token for ETH. The token must be sent to the contract prior
    ///      to calling this function to trigger the trade.
    /// @param inputToken The token being sold.
    /// @param recipient The recipient of the bought tokens.
    /// @param minBuyAmount The minimum acceptable amount of ETH to buy.
    /// @param auxiliaryData Arbitrary auxiliary data supplied to the contract.
    /// @return boughtAmount The amount of ETH bought.
    function sellTokenForEth(
        IERC20Token inputToken,
        address payable recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    ) external returns (uint256 boughtAmount);

    /// @dev Quotes the amount of `outputToken` that would be obtained by
    ///      selling `sellAmount` of `inputToken`.
    /// @param inputToken Address of the taker token (what to sell). Use
    ///        the wETH address if selling ETH.
    /// @param outputToken Address of the maker token (what to buy). Use
    ///        the wETH address if buying ETH.
    /// @param sellAmount Amount of `inputToken` to sell.
    /// @return outputTokenAmount Amount of `outputToken` that would be obtained.
    function getSellQuote(
        IERC20Token inputToken,
        IERC20Token outputToken,
        uint256 sellAmount
    ) external view returns (uint256 outputTokenAmount);
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/mixins/MixinZeroExBridge.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;






contract MixinZeroExBridge {
    using LibERC20TokenV06 for IERC20Token;
    using LibSafeMathV06 for uint256;

    function _tradeZeroExBridge(
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    ) internal returns (uint256 boughtAmount) {
        (ILiquidityProvider provider, bytes memory lpData) = abi.decode(bridgeData, (ILiquidityProvider, bytes));
        // Trade the good old fashioned way
        sellToken.compatTransfer(address(provider), sellAmount);
        boughtAmount = provider.sellTokenForToken(
            sellToken,
            buyToken,
            address(this), // recipient
            1, // minBuyAmount
            lpData
        );
    }
}

// File: /Users/sav/Repos/protocol/contracts/zero-ex/contracts/src/transformers/bridges/EthereumBridgeAdapter.sol

/*
  Copyright 2023 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;


























contract EthereumBridgeAdapter is
    AbstractBridgeAdapter(1, "Ethereum"),
    MixinAaveV2,
    MixinBalancer,
    MixinBalancerV2Batch,
    MixinBancorV3,
    MixinBarter,
    MixinCompound,
    MixinCurve,
    MixinCurveV2,
    MixinCryptoCom,
    MixinDodo,
    MixinDodoV2,
    MixinKyberDmm,
    MixinKyberElastic,
    MixinLido,
    MixinMakerPSM,
    MixinMaverickV1,
    MixinNerve,
    MixinSynthetix,
    MixinUniswap,
    MixinUniswapV2,
    MixinUniswapV3,
    MixinZeroExBridge
{
    constructor(
        IEtherToken weth
    ) public MixinBancorV3(weth) MixinCompound(weth) MixinCurve(weth) MixinLido(weth) MixinUniswap(weth) {}

    function _trade(
        BridgeOrder memory order,
        IERC20Token sellToken,
        IERC20Token buyToken,
        uint256 sellAmount,
        bool dryRun
    ) internal override returns (uint256 boughtAmount, bool supportedSource) {
        uint128 protocolId = uint128(uint256(order.source) >> 128);
        if (protocolId == BridgeProtocols.CURVE) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeCurve(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.CURVEV2) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeCurveV2(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.UNISWAPV3) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeUniswapV3(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.UNISWAPV2) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeUniswapV2(buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.UNISWAP) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeUniswap(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.BALANCER) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeBalancer(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.BALANCERV2BATCH) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeBalancerV2Batch(sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.MAKERPSM) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeMakerPsm(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.DODO) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeDodo(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.DODOV2) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeDodoV2(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.CRYPTOCOM) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeCryptoCom(buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.NERVE) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeNerve(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.KYBERDMM) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeKyberDmm(buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.KYBERELASTIC) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeKyberElastic(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.LIDO) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeLido(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.AAVEV2) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeAaveV2(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.COMPOUND) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeCompound(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.BANCORV3) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeBancorV3(buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.SYNTHETIX) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeSynthetix(sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.BARTER) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeBarter(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.MAVERICK) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeMaverickV1(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.UNKNOWN) {
            if (dryRun) {
                return (0, true);
            }
            boughtAmount = _tradeZeroExBridge(sellToken, buyToken, sellAmount, order.bridgeData);
        }

        emit BridgeFill(order.source, sellToken, buyToken, sellAmount, boughtAmount);
    }
}
