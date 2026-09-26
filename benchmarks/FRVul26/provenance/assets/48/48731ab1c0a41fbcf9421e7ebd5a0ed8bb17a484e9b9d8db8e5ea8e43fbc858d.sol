// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/solady/src/utils/ECDSA.sol

pragma solidity ^0.8.4;

/// @notice Gas optimized ECDSA wrapper.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ECDSA.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ECDSA.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol)
///
/// @dev Note:
/// - The recovery functions use the ecrecover precompile (0x1).
/// - As of Solady version 0.0.68, the `recover` variants will revert upon recovery failure.
///   This is for more safety by default.
///   Use the `tryRecover` variants if you need to get the zero address back
///   upon recovery failure instead.
/// - As of Solady version 0.0.134, all `bytes signature` variants accept both
///   regular 65-byte `(r, s, v)` and EIP-2098 `(r, vs)` short form signatures.
///   See: https://eips.ethereum.org/EIPS/eip-2098
///   This is for calldata efficiency on smart accounts prevalent on L2s.
///
/// WARNING! Do NOT use signatures as unique identifiers:
/// - Use a nonce in the digest to prevent replay attacks on the same contract.
/// - Use EIP-712 for the digest to prevent replay attacks across different chains and contracts.
///   EIP-712 also enables readable signing of typed data for better user safety.
/// This implementation does NOT check if a signature is non-malleable.
library ECDSA {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The signature is invalid.
    error InvalidSignature();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    RECOVERY OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function recover(bytes32 hash, bytes memory signature) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            for {} 1 {} {
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    break
                }
                result := 0
                break
            }
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        result, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function recoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            for {} 1 {} {
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
                    break
                }
                result := 0
                break
            }
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        result, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   TRY-RECOVER OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // WARNING!
    // These functions will NOT revert upon recovery failure.
    // Instead, they will return the zero address upon recovery failure.
    // It is critical that the returned address is NEVER compared against
    // a zero address (e.g. an uninitialized address variable).

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            for {} 1 {} {
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    break
                }
                result := 0
                break
            }
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    result, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function tryRecoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            for {} 1 {} {
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
                    break
                }
                result := 0
                break
            }
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    result, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an Ethereum Signed Message, created from a `hash`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, hash) // Store into scratch space for keccak256.
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32") // 28 bytes.
            result := keccak256(0x04, 0x3c) // `32 * 2 - (32 - 28) = 60 = 0x3c`.
        }
    }

    /// @dev Returns an Ethereum Signed Message, created from `s`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    /// Note: Supports lengths of `s` up to 999999 bytes.
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let sLength := mload(s)
            let o := 0x20
            mstore(o, "\x19Ethereum Signed Message:\n") // 26 bytes, zero-right-padded.
            mstore(0x00, 0x00)
            // Convert the `s.length` to ASCII decimal representation: `base10(s.length)`.
            for { let temp := sLength } 1 {} {
                o := sub(o, 1)
                mstore8(o, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) { break }
            }
            let n := sub(0x3a, o) // Header length: `26 + 32 - o`.
            // Throw an out-of-offset error (consumes all gas) if the header exceeds 32 bytes.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0x20))
            mstore(s, or(mload(0x00), mload(n))) // Temporarily store the header.
            result := keccak256(add(s, sub(0x20, n)), add(n, sLength))
            mstore(s, sLength) // Restore the length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes.
    function emptySignature() internal pure returns (bytes calldata signature) {
        /// @solidity memory-safe-assembly
        assembly {
            signature.length := 0
        }
    }
}

// File: src/Interfaces/ILiFi.sol

pragma solidity ^0.8.17;

/// @title ILiFi
/// @author LI.FI (https://li.fi)
/// @custom:version 1.0.1
interface ILiFi {
    /// Structs ///

    struct BridgeData {
        bytes32 transactionId;
        string bridge;
        string integrator;
        address referrer;
        address sendingAssetId;
        address receiver;
        uint256 minAmount;
        uint256 destinationChainId;
        bool hasSourceSwaps;
        bool hasDestinationCall;
    }

    /// Events ///

    event LiFiTransferStarted(ILiFi.BridgeData bridgeData);

    event LiFiTransferCompleted(
        bytes32 indexed transactionId,
        address receivingAssetId,
        address receiver,
        uint256 amount,
        uint256 timestamp
    );

    event LiFiTransferRecovered(
        bytes32 indexed transactionId,
        address receivingAssetId,
        address receiver,
        uint256 amount,
        uint256 timestamp
    );

    event LiFiGenericSwapCompleted(
        bytes32 indexed transactionId,
        string integrator,
        string referrer,
        address receiver,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount
    );

    // this event is emitted when a bridge transction is initiated to a non-EVM chain
    event BridgeToNonEVMChain(
        bytes32 indexed transactionId,
        uint256 indexed destinationChainId,
        bytes receiver
    );
    event BridgeToNonEVMChainBytes32(
        bytes32 indexed transactionId,
        uint256 indexed destinationChainId,
        bytes32 receiver
    );

    // Deprecated but kept here to include in ABI to parse historic events
    event LiFiSwappedGeneric(
        bytes32 indexed transactionId,
        string integrator,
        string referrer,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount
    );
}

// File: lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: src/Libraries/LibBytes.sol

/// @custom:version 1.0.0
pragma solidity ^0.8.17;

library LibBytes {
    // solhint-disable no-inline-assembly

    // LibBytes specific errors
    error SliceOverflow();
    error SliceOutOfBounds();
    error AddressOutOfBounds();

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    // -------------------------

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        if (_length + 31 < _length) revert SliceOverflow();
        if (_bytes.length < _start + _length) revert SliceOutOfBounds();

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(
                    add(tempBytes, lengthmod),
                    mul(0x20, iszero(lengthmod))
                )
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(
                        add(
                            add(_bytes, lengthmod),
                            mul(0x20, iszero(lengthmod))
                        ),
                        _start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (address) {
        if (_bytes.length < _start + 20) {
            revert AddressOutOfBounds();
        }
        address tempAddress;

        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }

    /// Copied from OpenZeppelin's `Strings.sol` utility library.
    /// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8335676b0e99944eef6a742e16dcd9ff6e68e609
    /// /contracts/utils/Strings.sol
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        // solhint-disable-next-line gas-custom-errors
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: src/Libraries/LibUtil.sol

/// @custom:version 1.0.0
pragma solidity ^0.8.17;

// solhint-disable-next-line no-global-import


library LibUtil {
    using LibBytes for bytes;

    function getRevertMsg(
        bytes memory _res
    ) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_res.length < 68) return "Transaction reverted silently";
        bytes memory revertData = _res.slice(4, _res.length - 4); // Remove the selector which is the first 4 bytes
        return abi.decode(revertData, (string)); // All that remains is the revert string
    }

    /// @notice Determines whether the given address is the zero address
    /// @param addr The address to verify
    /// @return Boolean indicating if the address is the zero address
    function isZeroAddress(address addr) internal pure returns (bool) {
        return addr == address(0);
    }

    function revertWith(bytes memory data) internal pure {
        assembly {
            let dataSize := mload(data) // Load the size of the data
            let dataPtr := add(data, 0x20) // Advance data pointer to the next word
            revert(dataPtr, dataSize) // Revert with the given data
        }
    }
}

// File: src/Errors/GenericErrors.sol

/// @custom:version 1.0.2
pragma solidity ^0.8.17;

error AlreadyInitialized();
error CannotAuthoriseSelf();
error CannotBridgeToSameNetwork();
error ContractCallNotAllowed();
error CumulativeSlippageTooHigh(uint256 minAmount, uint256 receivedAmount);
error DiamondIsPaused();
error ETHTransferFailed();
error ExternalCallFailed();
error FunctionDoesNotExist();
error InformationMismatch();
error InsufficientBalance(uint256 required, uint256 balance);
error InvalidAmount();
error InvalidCallData();
error InvalidConfig();
error InvalidContract();
error InvalidDestinationChain();
error InvalidFallbackAddress();
error InvalidNonEVMReceiver();
error InvalidReceiver();
error InvalidSendingToken();
error NativeAssetNotSupported();
error NativeAssetTransferFailed();
error NoSwapDataProvided();
error NoSwapFromZeroBalance();
error NotAContract();
error NotInitialized();
error NoTransferToNullAddress();
error NullAddrIsNotAnERC20Token();
error NullAddrIsNotAValidSpender();
error OnlyContractOwner();
error RecoveryAddressCannotBeZero();
error ReentrancyError();
error TokenNotSupported();
error TransferFromFailed();
error UnAuthorized();
error UnsupportedChainId(uint256 chainId);
error WithdrawFailed();
error ZeroAmount();

// File: src/Libraries/LibSwap.sol

pragma solidity ^0.8.17;






/// @title LibSwap
/// @custom:version 1.1.0
/// @notice This library contains functionality to execute mostly swaps but also
///         other calls such as fee collection, token wrapping/unwrapping or
///         sending gas to destination chain
library LibSwap {
    /// @notice Struct containing all necessary data to execute a swap or generic call
    /// @param callTo The address of the contract to call for executing the swap
    /// @param approveTo The address that will receive token approval (can be different than callTo for some DEXs)
    /// @param sendingAssetId The address of the token being sent
    /// @param receivingAssetId The address of the token expected to be received
    /// @param fromAmount The exact amount of the sending asset to be used in the call
    /// @param callData Encoded function call data to be sent to the `callTo` contract
    /// @param requiresDeposit A flag indicating whether the tokens must be deposited (pulled) before the call
    struct SwapData {
        address callTo;
        address approveTo;
        address sendingAssetId;
        address receivingAssetId;
        uint256 fromAmount;
        bytes callData;
        bool requiresDeposit;
    }

    /// @notice Emitted after a successful asset swap or related operation
    /// @param transactionId    The unique identifier associated with the swap operation
    /// @param dex              The address of the DEX or contract that handled the swap
    /// @param fromAssetId      The address of the token that was sent
    /// @param toAssetId        The address of the token that was received
    /// @param fromAmount       The amount of `fromAssetId` sent
    /// @param toAmount         The amount of `toAssetId` received
    /// @param timestamp        The timestamp when the swap was executed
    event AssetSwapped(
        bytes32 transactionId,
        address dex,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 timestamp
    );

    function swap(bytes32 transactionId, SwapData calldata _swap) internal {
        // make sure callTo is a contract
        if (!LibAsset.isContract(_swap.callTo)) revert InvalidContract();

        // make sure that fromAmount is not 0
        uint256 fromAmount = _swap.fromAmount;
        if (fromAmount == 0) revert NoSwapFromZeroBalance();

        // determine how much native value to send with the swap call
        uint256 nativeValue = LibAsset.isNativeAsset(_swap.sendingAssetId)
            ? _swap.fromAmount
            : 0;

        // store initial balance (required for event emission)
        uint256 initialReceivingAssetBalance = LibAsset.getOwnBalance(
            _swap.receivingAssetId
        );

        // max approve (if ERC20)
        if (nativeValue == 0) {
            LibAsset.maxApproveERC20(
                IERC20(_swap.sendingAssetId),
                _swap.approveTo,
                _swap.fromAmount
            );
        }

        // we used to have a sending asset balance check here (initialSendingAssetBalance >= _swap.fromAmount)
        // this check was removed to allow for more flexibility with rebasing/fee-taking tokens
        // the general assumption is that if not enough tokens are available to execute the calldata,
        // the transaction will fail anyway
        // the error message might not be as explicit though

        // execute the swap
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory res) = _swap.callTo.call{
            value: nativeValue
        }(_swap.callData);
        if (!success) {
            LibUtil.revertWith(res);
        }

        // get post-swap balance
        uint256 newBalance = LibAsset.getOwnBalance(_swap.receivingAssetId);

        // emit event
        emit AssetSwapped(
            transactionId,
            _swap.callTo,
            _swap.sendingAssetId,
            _swap.receivingAssetId,
            _swap.fromAmount,
            newBalance > initialReceivingAssetBalance
                ? newBalance - initialReceivingAssetBalance
                : newBalance,
            block.timestamp
        );
    }
}

// File: lib/solady/src/utils/SafeTransferLib.sol

pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Permit2 operations from (https://github.com/Uniswap/permit2/blob/main/src/libraries/Permit2Lib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
/// - For ERC20s, this implementation won't check that a token has code,
///   responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /// @dev The Permit2 operation has failed.
    error Permit2Failed();

    /// @dev The Permit2 amount must be less than `2**160 - 1`.
    error Permit2AmountOverflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /// @dev The unique EIP-712 domain domain separator for the DAI token contract.
    bytes32 internal constant DAI_DOMAIN_SEPARATOR =
        0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @dev The address for the WETH9 contract on Ethereum mainnet.
    address internal constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @dev The canonical Permit2 address.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function trySafeTransferFrom(address token, address from, address to, uint256 amount)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            success :=
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) // Store 0 for the `amount`.
                mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                mstore(0x34, amount) // Store back the original `amount`.
                // Retry the approval, reverting upon failure.
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul( // The arguments of `mul` are evaluated from right to left.
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// If the initial attempt fails, try to use Permit2 to transfer the token.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function safeTransferFrom2(address token, address from, address to, uint256 amount) internal {
        if (!trySafeTransferFrom(token, from, to, amount)) {
            permit2TransferFrom(token, from, to, amount);
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to` via Permit2.
    /// Reverts upon failure.
    function permit2TransferFrom(address token, address from, address to, uint256 amount)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(add(m, 0x74), shr(96, shl(96, token)))
            mstore(add(m, 0x54), amount)
            mstore(add(m, 0x34), to)
            mstore(add(m, 0x20), shl(96, from))
            // `transferFrom(address,address,uint160,address)`.
            mstore(m, 0x36c78516000000000000000000000000)
            let p := PERMIT2
            let exists := eq(chainid(), 1)
            if iszero(exists) { exists := iszero(iszero(extcodesize(p))) }
            if iszero(and(call(gas(), p, 0, add(m, 0x10), 0x84, codesize(), 0x00), exists)) {
                mstore(0x00, 0x7939f4248757f0fd) // `TransferFromFailed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(iszero(shr(160, amount))))), 0x04)
            }
        }
    }

    /// @dev Permit a user to spend a given amount of
    /// another user's tokens via native EIP-2612 permit if possible, falling
    /// back to Permit2 if native permit fails or is not implemented on the token.
    function permit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bool success;
        /// @solidity memory-safe-assembly
        assembly {
            for {} shl(96, xor(token, WETH9)) {} {
                mstore(0x00, 0x3644e515) // `DOMAIN_SEPARATOR()`.
                if iszero(
                    and( // The arguments of `and` are evaluated from right to left.
                        lt(iszero(mload(0x00)), eq(returndatasize(), 0x20)), // Returns 1 non-zero word.
                        // Gas stipend to limit gas burn for tokens that don't refund gas when
                        // an non-existing function is called. 5K should be enough for a SLOAD.
                        staticcall(5000, token, 0x1c, 0x04, 0x00, 0x20)
                    )
                ) { break }
                // After here, we can be sure that token is a contract.
                let m := mload(0x40)
                mstore(add(m, 0x34), spender)
                mstore(add(m, 0x20), shl(96, owner))
                mstore(add(m, 0x74), deadline)
                if eq(mload(0x00), DAI_DOMAIN_SEPARATOR) {
                    mstore(0x14, owner)
                    mstore(0x00, 0x7ecebe00000000000000000000000000) // `nonces(address)`.
                    mstore(add(m, 0x94), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `1` is already stored at `add(m, 0x94)`.
                    mstore(add(m, 0xb4), and(0xff, v))
                    mstore(add(m, 0xd4), r)
                    mstore(add(m, 0xf4), s)
                    success := call(gas(), token, 0, add(m, 0x10), 0x104, codesize(), 0x00)
                    break
                }
                mstore(m, 0xd505accf000000000000000000000000) // `IERC20Permit.permit`.
                mstore(add(m, 0x54), amount)
                mstore(add(m, 0x94), and(0xff, v))
                mstore(add(m, 0xb4), r)
                mstore(add(m, 0xd4), s)
                success := call(gas(), token, 0, add(m, 0x10), 0xe4, codesize(), 0x00)
                break
            }
        }
        if (!success) simplePermit2(token, owner, spender, amount, deadline, v, r, s);
    }

    /// @dev Simple permit on the Permit2 contract.
    function simplePermit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0x927da105) // `allowance(address,address,address)`.
            {
                let addressMask := shr(96, not(0))
                mstore(add(m, 0x20), and(addressMask, owner))
                mstore(add(m, 0x40), and(addressMask, token))
                mstore(add(m, 0x60), and(addressMask, spender))
                mstore(add(m, 0xc0), and(addressMask, spender))
            }
            let p := mul(PERMIT2, iszero(shr(160, amount)))
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x5f), // Returns 3 words: `amount`, `expiration`, `nonce`.
                    staticcall(gas(), p, add(m, 0x1c), 0x64, add(m, 0x60), 0x60)
                )
            ) {
                mstore(0x00, 0x6b836e6b8757f0fd) // `Permit2Failed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(p))), 0x04)
            }
            mstore(m, 0x2b67b570) // `Permit2.permit` (PermitSingle variant).
            // `owner` is already `add(m, 0x20)`.
            // `token` is already at `add(m, 0x40)`.
            mstore(add(m, 0x60), amount)
            mstore(add(m, 0x80), 0xffffffffffff) // `expiration = type(uint48).max`.
            // `nonce` is already at `add(m, 0xa0)`.
            // `spender` is already at `add(m, 0xc0)`.
            mstore(add(m, 0xe0), deadline)
            mstore(add(m, 0x100), 0x100) // `signature` offset.
            mstore(add(m, 0x120), 0x41) // `signature` length.
            mstore(add(m, 0x140), r)
            mstore(add(m, 0x160), s)
            mstore(add(m, 0x180), shl(248, v))
            if iszero(call(gas(), p, 0, add(m, 0x1c), 0x184, codesize(), 0x00)) {
                mstore(0x00, 0x6b836e6b) // `Permit2Failed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}

// File: src/Libraries/LibAsset.sol

pragma solidity ^0.8.17;





// solhint-disable-next-line max-line-length


/// @title LibAsset
/// @author LI.FI (https://li.fi)
/// @custom:version 2.1.3
/// @notice This library contains helpers for dealing with onchain transfers
///         of assets, including accounting for the native asset `assetId`
///         conventions and any noncompliant ERC20 transfers
library LibAsset {
    using SafeTransferLib for address;
    using SafeTransferLib for address payable;

    /// @dev All native assets use the empty address for their asset id
    ///      by convention
    address internal constant NULL_ADDRESS = address(0);

    /// @dev EIP-7702 delegation designator prefix for Account Abstraction
    bytes3 internal constant DELEGATION_DESIGNATOR = 0xef0100;

    /// @notice Gets the balance of the inheriting contract for the given asset
    /// @param assetId The asset identifier to get the balance of
    /// @return Balance held by contracts using this library (returns 0 if assetId does not exist)
    function getOwnBalance(address assetId) internal view returns (uint256) {
        return
            isNativeAsset(assetId)
                ? address(this).balance
                : assetId.balanceOf(address(this));
    }

    /// @notice Wrapper function to transfer a given asset (native or erc20) to
    ///         some recipient. Should handle all non-compliant return value
    ///         tokens as well by using the SafeERC20 contract by open zeppelin.
    /// @param assetId Asset id for transfer (address(0) for native asset,
    ///                token address for erc20s)
    /// @param recipient Address to send asset to
    /// @param amount Amount to send to given recipient
    function transferAsset(
        address assetId,
        address payable recipient,
        uint256 amount
    ) internal {
        if (isNativeAsset(assetId)) {
            transferNativeAsset(recipient, amount);
        } else {
            transferERC20(assetId, recipient, amount);
        }
    }

    /// @notice Transfers ether from the inheriting contract to a given
    ///         recipient
    /// @param recipient Address to send ether to
    /// @param amount Amount to send to given recipient
    function transferNativeAsset(
        address payable recipient,
        uint256 amount
    ) internal {
        // make sure a meaningful receiver address was provided
        if (recipient == NULL_ADDRESS) revert InvalidReceiver();

        // transfer native asset (will revert if target reverts or contract has insufficient balance)
        recipient.safeTransferETH(amount);
    }

    /// @notice Transfers tokens from the inheriting contract to a given recipient
    /// @param assetId Token address to transfer
    /// @param recipient Address to send tokens to
    /// @param amount Amount to send to given recipient
    function transferERC20(
        address assetId,
        address recipient,
        uint256 amount
    ) internal {
        // make sure a meaningful receiver address was provided
        if (recipient == NULL_ADDRESS) {
            revert InvalidReceiver();
        }

        // transfer ERC20 assets (will revert if target reverts or contract has insufficient balance)
        assetId.safeTransfer(recipient, amount);
    }

    /// @notice Transfers tokens from a sender to a given recipient
    /// @param assetId Token address to transfer
    /// @param from Address of sender/owner
    /// @param recipient Address of recipient/spender
    /// @param amount Amount to transfer from owner to spender
    function transferFromERC20(
        address assetId,
        address from,
        address recipient,
        uint256 amount
    ) internal {
        // check if native asset
        if (isNativeAsset(assetId)) {
            revert NullAddrIsNotAnERC20Token();
        }

        // make sure a meaningful receiver address was provided
        if (recipient == NULL_ADDRESS) {
            revert InvalidReceiver();
        }

        // transfer ERC20 assets (will revert if target reverts or contract has insufficient balance)
        assetId.safeTransferFrom(from, recipient, amount);
    }

    /// @notice Pulls tokens from msg.sender
    /// @param assetId Token address to transfer
    /// @param amount Amount to transfer from owner
    function depositAsset(address assetId, uint256 amount) internal {
        // make sure a meaningful amount was provided
        if (amount == 0) revert InvalidAmount();

        // check if native asset
        if (isNativeAsset(assetId)) {
            // ensure msg.value is equal or greater than amount
            if (msg.value < amount) revert InvalidAmount();
        } else {
            // transfer ERC20 assets (will revert if target reverts or contract has insufficient balance)
            assetId.safeTransferFrom(msg.sender, address(this), amount);
        }
    }

    function depositAssets(LibSwap.SwapData[] calldata swaps) internal {
        for (uint256 i = 0; i < swaps.length; ) {
            LibSwap.SwapData calldata swap = swaps[i];
            if (swap.requiresDeposit) {
                depositAsset(swap.sendingAssetId, swap.fromAmount);
            }
            unchecked {
                i++;
            }
        }
    }

    /// @notice If the current allowance is insufficient, the allowance for a given spender
    ///         is set to MAX_UINT.
    /// @param assetId Token address to transfer
    /// @param spender Address to give spend approval to
    /// @param amount allowance amount required for current transaction
    function maxApproveERC20(
        IERC20 assetId,
        address spender,
        uint256 amount
    ) internal {
        approveERC20(assetId, spender, amount, type(uint256).max);
    }

    /// @notice If the current allowance is insufficient, the allowance for a given spender
    ///         is set to the amount provided
    /// @param assetId Token address to transfer
    /// @param spender Address to give spend approval to
    /// @param requiredAllowance Allowance required for current transaction
    /// @param setAllowanceTo The amount the allowance should be set to if current allowance is insufficient
    function approveERC20(
        IERC20 assetId,
        address spender,
        uint256 requiredAllowance,
        uint256 setAllowanceTo
    ) internal {
        if (isNativeAsset(address(assetId))) {
            return;
        }

        // make sure a meaningful spender address was provided
        if (spender == NULL_ADDRESS) {
            revert NullAddrIsNotAValidSpender();
        }

        // check if allowance is sufficient, otherwise set allowance to provided amount
        // If the initial attempt to approve fails, attempts to reset the approved amount to zero,
        // then retries the approval again (some tokens, e.g. USDT, requires this).
        // Reverts upon failure
        if (assetId.allowance(address(this), spender) < requiredAllowance) {
            address(assetId).safeApproveWithRetry(spender, setAllowanceTo);
        }
    }

    /// @notice Determines whether the given assetId is the native asset
    /// @param assetId The asset identifier to evaluate
    /// @return Boolean indicating if the asset is the native asset
    function isNativeAsset(address assetId) internal pure returns (bool) {
        return assetId == NULL_ADDRESS;
    }

    /// @notice Checks if the given address is a contract
    ///         Returns true for any account with runtime code (excluding EIP-7702 accounts).
    ///         For EIP-7702 accounts, checks if code size is exactly 23 bytes (delegation format).
    ///         Limitations:
    ///         - Cannot distinguish between EOA and self-destructed contract
    /// @param account The address to be checked
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }

        // Return true only for regular contracts (size > 23)
        // EIP-7702 delegated accounts (size == 23) are still EOAs, not contracts
        return size > 23;
    }
}

// File: src/Helpers/ReentrancyGuard.sol

/// @custom:version 1.0.0
pragma solidity ^0.8.17;

/// @title Reentrancy Guard
/// @author LI.FI (https://li.fi)
/// @notice Abstract contract to provide protection against reentrancy
abstract contract ReentrancyGuard {
    /// Storage ///

    bytes32 private constant NAMESPACE = keccak256("com.lifi.reentrancyguard");

    /// Types ///

    struct ReentrancyStorage {
        uint256 status;
    }

    /// Errors ///

    error ReentrancyError();

    /// Constants ///

    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    /// Modifiers ///

    modifier nonReentrant() {
        ReentrancyStorage storage s = reentrancyStorage();
        if (s.status == _ENTERED) revert ReentrancyError();
        s.status = _ENTERED;
        _;
        s.status = _NOT_ENTERED;
    }

    /// Private Methods ///

    /// @dev fetch local storage
    function reentrancyStorage()
        private
        pure
        returns (ReentrancyStorage storage data)
    {
        bytes32 position = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data.slot := position
        }
    }
}

// File: src/Libraries/LibAllowList.sol

pragma solidity ^0.8.17;




/// @title LibAllowList
/// @author LI.FI (https://li.fi)
/// @notice Manages a dual-model allow list to support a secure, granular permissions system
/// while maintaining backward compatibility with a non-granular, global system.
/// @dev This library is the single source of truth for all whitelist state changes.
/// It ensures that both the new granular mapping and the global arrays used by older
/// contracts are kept perfectly synchronized. The long-term goal is to migrate all usage
/// to the new granular system. New development should exclusively use the "Primary Interface" functions.
///
/// Special ApproveTo-Only Selector:
/// - Use 0xffffffff to whitelist contracts that are used only as approveTo in
///   LibSwap.SwapData, without allowing function calls to them.
/// - Some DEXs have specific contracts that need to be approved to while another
///   (router) contract must be called to initiate the swap.
/// - This selector makes contractIsAllowed(_contract) return true for backward
///   compatibility, but does not authorize any granular calls. In the granular
///   system, real function selectors must be explicitly whitelisted to be callable.
/// @custom:version 2.0.0
library LibAllowList {
    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.library.allow.list");

    struct AllowListStorage {
        // --- STORAGE FOR OLDER VERSIONS ---
        /// @dev [BACKWARD COMPATIBILITY] [V1 DATA] Boolean mapping actively maintained
        /// by functions to support older, deployed contracts that read from it.
        /// Also kept for storage layout compatibility.
        mapping(address => bool) contractAllowList;
        /// @dev [BACKWARD COMPATIBILITY] [V1 DATA] Boolean mapping actively maintained
        /// by functions to support older, deployed contracts that read from it.
        /// Also kept for storage layout compatibility.
        mapping(bytes4 => bool) selectorAllowList;
        /// @dev [BACKWARD COMPATIBILITY] The global list of all unique whitelisted contracts for older facets.
        address[] contracts;
        // --- NEW GRANULAR STORAGE & SYNCHRONIZATION ---
        // These variables form the new, secure, and preferred whitelist system.

        /// @dev [BACKWARD COMPATIBILITY] 1-based index for `contracts` array for efficient removal.
        mapping(address => uint256) contractToIndex;
        /// @dev [BACKWARD COMPATIBILITY] 1-based index for `selectors` array for efficient removal.
        mapping(bytes4 => uint256) selectorToIndex;
        /// @dev [BACKWARD COMPATIBILITY] The global list of all unique whitelisted selectors for older facets.
        bytes4[] selectors;
        /// @dev The SOURCE OF TRUTH for the new granular system.
        mapping(address => mapping(bytes4 => bool)) contractSelectorAllowList;
        /// @dev A global reference count for each selector to manage the `selectors` array for backward compatibility.
        mapping(bytes4 => uint256) selectorReferenceCount;
        /// @dev Iterable list of selectors for each contract, used by the backend getter.
        /// The length of this array also serves as the IMPLICIT contract reference count.
        mapping(address => bytes4[]) whitelistedSelectorsByContract;
        /// @dev 1-based index for `whitelistedSelectorsByContract` array for efficient removal.
        mapping(address => mapping(bytes4 => uint256)) selectorIndices;
        /// @dev Flag to indicate completion of a one-time data migration.
        bool migrated;
    }

    /// @notice Adds a specific contract-selector pair to the allow list.
    /// @dev This is the primary entry point for whitelisting. It updates the granular
    /// mapping and synchronizes the global arrays (for backward compatibility) via reference counting.
    /// @param _contract The contract address.
    /// @param _selector The function selector.
    function addAllowedContractSelector(
        address _contract,
        bytes4 _selector
    ) internal {
        if (_contract == address(0) || _selector == bytes4(0))
            revert InvalidCallData();
        AllowListStorage storage als = _getStorage();

        // Skip if the pair is already allowed.
        if (als.contractSelectorAllowList[_contract][_selector]) return;

        // 1. Update the source of truth for the new system.
        als.contractSelectorAllowList[_contract][_selector] = true;

        // 2. Update the `contracts` variables if this is the first selector for this contract.
        // We use the length of the iterable array as an implicit reference count.
        if (als.whitelistedSelectorsByContract[_contract].length == 0) {
            _addAllowedContract(_contract);
        }

        // 3. Update the `selectors` variables if this is the first time this selector is used globally.
        if (++als.selectorReferenceCount[_selector] == 1) {
            _addAllowedSelector(_selector);
        }

        // 4. Update the iterable list used by the on-chain getter.
        als.whitelistedSelectorsByContract[_contract].push(_selector);
        // Store 1-based index for efficient removal later.
        als.selectorIndices[_contract][_selector] = als
            .whitelistedSelectorsByContract[_contract]
            .length;
    }

    /// @notice Removes a specific contract-selector pair from the allow list.
    /// @dev This is the primary entry point for removal. It updates the granular
    /// mapping and synchronizes the global arrays (for backward compatibility) via reference counting.
    /// @param _contract The contract address.
    /// @param _selector The function selector.
    function removeAllowedContractSelector(
        address _contract,
        bytes4 _selector
    ) internal {
        AllowListStorage storage als = _getStorage();
        // Skip if the pair is not currently allowed.
        if (!als.contractSelectorAllowList[_contract][_selector]) return;

        // 1. Update the source of truth.
        delete als.contractSelectorAllowList[_contract][_selector];

        // 2. Update the iterable list FIRST to get the new length.
        _removeSelectorFromIterableList(_contract, _selector);

        // 3. If the iterable list's new length is 0, it was the last selector,
        // so remove the contract from the global list.
        if (als.whitelistedSelectorsByContract[_contract].length == 0) {
            _removeAllowedContract(_contract);
        }

        // 4. If the global reference count is now 0, it was the last usage of this
        // selector, so remove it from the global list.
        if (--als.selectorReferenceCount[_selector] == 0) {
            _removeAllowedSelector(_selector);
        }
    }

    /// @notice Checks if a specific contract-selector pair is allowed.
    /// @dev Preferred runtime check for all new contracts/facets.
    /// @param _contract The contract address.
    /// @param _selector The function selector.
    /// @return isAllowed True if the contract-selector pair is allowed, false otherwise.
    function contractSelectorIsAllowed(
        address _contract,
        bytes4 _selector
    ) internal view returns (bool) {
        return _getStorage().contractSelectorAllowList[_contract][_selector];
    }

    /// @notice Gets all approved selectors for a specific contract.
    /// @dev Used by the on-chain getter in the facet for backend synchronization.
    /// @param _contract The contract address.
    /// @return selectors The whitelisted selectors for the contract.
    function getWhitelistedSelectorsForContract(
        address _contract
    ) internal view returns (bytes4[] memory) {
        return _getStorage().whitelistedSelectorsByContract[_contract];
    }

    /// Backward Compatibility Interface (V1) ///

    // These functions read from the global arrays. They are required for existing,
    // deployed facets to continue functioning. They should be considered part of a
    // transitional phase and MUST NOT be used in new development.

    /// @notice [Backward Compatibility] Checks if a contract is on the global allow list.
    /// @dev This function reads from the global list and is NOT granular. It is required for
    /// older, deployed facets to function correctly. Avoid use in new code.
    /// @param _contract The contract address.
    /// @return isAllowed True if the contract is allowed, false otherwise.
    function contractIsAllowed(
        address _contract
    ) internal view returns (bool) {
        return _getStorage().contractAllowList[_contract];
    }

    /// @notice [Backward Compatibility] Checks if a selector is on the global allow list.
    /// @dev This function reads from the global list and is NOT granular. It is required for
    /// older, deployed facets to function correctly. Avoid use in new code.
    /// @param _selector The function selector.
    /// @return isAllowed True if the selector is allowed, false otherwise.
    function selectorIsAllowed(bytes4 _selector) internal view returns (bool) {
        return _getStorage().selectorAllowList[_selector];
    }

    /// @notice [Backward Compatibility] Gets the entire global list of whitelisted contracts.
    /// @dev Returns the `contracts` array, which is synchronized with the new granular system.
    /// @return contracts The global list of whitelisted contracts.
    function getAllowedContracts() internal view returns (address[] memory) {
        return _getStorage().contracts;
    }

    /// @notice [Backward Compatibility] Gets the entire global list of whitelisted selectors.
    /// @dev Returns the `selectors` array, which is synchronized with the new granular system.
    function getAllowedSelectors() internal view returns (bytes4[] memory) {
        return _getStorage().selectors;
    }

    /// Private Helpers (Internal Use Only) ///

    /// @dev Internal helper to add a contract to the `contracts` array.
    /// @param _contract The contract address.
    function _addAllowedContract(address _contract) private {
        // Ensure address is actually a contract.
        if (!LibAsset.isContract(_contract)) revert InvalidContract();
        AllowListStorage storage als = _getStorage();

        // Add contract to the old allow list for backward compatibility
        als.contractAllowList[_contract] = true;

        // Skip if contract is already in allow list (1-based index).
        if (als.contractToIndex[_contract] > 0) return;

        // Add contract to allow list array.
        als.contracts.push(_contract);
        // Store 1-based index for efficient removal later.
        als.contractToIndex[_contract] = als.contracts.length;
    }

    /// @dev Internal helper to remove a contract from the `contracts` array.
    /// @param _contract The contract address.
    function _removeAllowedContract(address _contract) private {
        AllowListStorage storage als = _getStorage();

        // The V1 boolean mapping must be cleared before any checks.
        // This delete operation is placed at the top to ensure V1/V2 sync
        // and primarily solves two issues of stale item where
        // V1 data - als.selectorAllowList[_selector]=true,
        // V2 data - als.selectorToIndex[_selector]=0.
        // This scenario is different from selectors; it's an unlikely
        // edge case for contracts because the migration iterates the
        // full on-chain `contracts` array for a "perfect" cleanup.
        // However, this defensive delete ensures the function is robust
        //against any state corruption.
        delete als.contractAllowList[_contract];

        // Get the 1-based index; return if not found.
        uint256 oneBasedIndex = als.contractToIndex[_contract];
        if (oneBasedIndex == 0) {
            return;
        }
        // Convert to 0-based index for array operations.
        uint256 index = oneBasedIndex - 1;
        uint256 lastIndex = als.contracts.length - 1;

        // If the contract to remove isn't the last one,
        // move the last contract to the removed contract's position.
        if (index != lastIndex) {
            address lastContract = als.contracts[lastIndex];
            als.contracts[index] = lastContract;
            als.contractToIndex[lastContract] = oneBasedIndex;
        }

        // Remove the last element and clean up mappings.
        als.contracts.pop();
        delete als.contractToIndex[_contract];
    }

    /// @dev Internal helper to add a selector to the `selectors` array.
    /// @param _selector The function selector.
    function _addAllowedSelector(bytes4 _selector) private {
        AllowListStorage storage als = _getStorage();

        // Add selector to the old allow list for backward compatibility
        als.selectorAllowList[_selector] = true;

        // Skip if selector is already in allow list (1-based index).
        if (als.selectorToIndex[_selector] > 0) return;

        // Add selector to the array.
        als.selectors.push(_selector);

        // Store 1-based index for efficient removal later.
        als.selectorToIndex[_selector] = als.selectors.length;
    }

    /// @dev Internal helper to remove a selector from the `selectors` array.
    /// @param _selector The function selector.
    function _removeAllowedSelector(bytes4 _selector) private {
        AllowListStorage storage als = _getStorage();

        // The V1 boolean mapping must be cleared before any checks.
        // The migration's selector cleanup is "imperfect" as it relies on an
        // off-chain list. A "stale selector" ( V1 data - als.selectorAllowList[_selector]=true, V2 data - als.selectorToIndex[_selector]=0) is possible.
        // Placing `delete` here allows an admin to fix this by
        // add-then-remove, as this line will clean the V1 bool even if
        // the V2 `oneBasedIndex` is 0.
        delete als.selectorAllowList[_selector];

        // Get the 1-based index; return if not found.
        uint256 oneBasedIndex = als.selectorToIndex[_selector];
        if (oneBasedIndex == 0) {
            return;
        }

        // Convert to 0-based index for array operations.
        uint256 index = oneBasedIndex - 1;
        uint256 lastIndex = als.selectors.length - 1;

        // If the selector to remove isn't the last one,
        // move the last selector to the removed selector's position.
        if (index != lastIndex) {
            bytes4 lastSelector = als.selectors[lastIndex];
            als.selectors[index] = lastSelector;
            als.selectorToIndex[lastSelector] = oneBasedIndex;
        }

        // Remove the last element and clean up mappings.
        als.selectors.pop();
        delete als.selectorToIndex[_selector];
    }

    /// @dev Internal helper to manage the iterable array for the getter function.
    /// @param _contract The contract address.
    /// @param _selector The function selector.
    function _removeSelectorFromIterableList(
        address _contract,
        bytes4 _selector
    ) private {
        AllowListStorage storage als = _getStorage();

        // Get the 1-based index; return if not found.
        uint256 oneBasedIndex = als.selectorIndices[_contract][_selector];
        if (oneBasedIndex == 0) return;

        // Convert to 0-based index for array operations.
        uint256 index = oneBasedIndex - 1;
        bytes4[] storage selectorsArray = als.whitelistedSelectorsByContract[
            _contract
        ];
        uint256 lastIndex = selectorsArray.length - 1;

        // If the selector to remove isn't the last one,
        // move the last selector to the removed selector's position.
        if (index != lastIndex) {
            bytes4 lastSelector = selectorsArray[lastIndex];
            selectorsArray[index] = lastSelector;
            als.selectorIndices[_contract][lastSelector] = oneBasedIndex;
        }

        // Remove the last element and clean up mappings.
        selectorsArray.pop();
        delete als.selectorIndices[_contract][_selector];
    }

    /// @dev Fetches the storage pointer for this library.
    /// @return als The storage pointer.
    function _getStorage()
        internal
        pure
        returns (AllowListStorage storage als)
    {
        bytes32 position = NAMESPACE;
        assembly {
            als.slot := position
        }
    }
}

// File: src/Helpers/SwapperV2.sol

pragma solidity ^0.8.17;







/// @title SwapperV2
/// @author LI.FI (https://li.fi)
/// @notice Abstract contract to provide swap functionality with leftover token handling
/// @custom:version 1.1.0
contract SwapperV2 is ILiFi {
    /// Types ///

    /// @dev only used to get around "Stack Too Deep" errors
    struct ReserveData {
        bytes32 transactionId;
        address payable leftoverReceiver;
        uint256 nativeReserve;
    }

    /// Modifiers ///

    /// @dev Sends any leftover balances back to the user
    /// @notice Sends any leftover balances to the user
    /// @param _swaps Swap data array
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial token balances
    modifier noLeftovers(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances
    ) {
        _;
        _refundLeftovers(_swaps, _leftoverReceiver, _initialBalances, 0);
    }

    /// @dev Sends any leftover balances back to the user reserving native tokens
    /// @notice Sends any leftover balances to the user
    /// @param _swaps Swap data array
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial token balances
    /// @param _nativeReserve Amount of native token to prevent from being swept
    modifier noLeftoversReserve(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances,
        uint256 _nativeReserve
    ) {
        _;
        _refundLeftovers(
            _swaps,
            _leftoverReceiver,
            _initialBalances,
            _nativeReserve
        );
    }

    /// @dev Refunds any excess native asset sent to the contract after the main function
    /// @notice Refunds any excess native asset sent to the contract after the main function
    /// @param _refundReceiver Address to send refunds to
    modifier refundExcessNative(address payable _refundReceiver) {
        uint256 initialBalance = address(this).balance - msg.value;
        _;
        uint256 finalBalance = address(this).balance;

        if (finalBalance > initialBalance) {
            LibAsset.transferAsset(
                LibAsset.NULL_ADDRESS,
                _refundReceiver,
                finalBalance - initialBalance
            );
        }
    }

    /// Internal Methods ///

    /// @dev Deposits value, executes swaps, and performs minimum amount check
    /// @param _transactionId the transaction id associated with the operation
    /// @param _minAmount the minimum amount of the final asset to receive
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver The address to send leftover funds to
    /// @return uint256 result of the swap
    function _depositAndSwap(
        bytes32 _transactionId,
        uint256 _minAmount,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver
    ) internal returns (uint256) {
        uint256 numSwaps = _swaps.length;

        if (numSwaps == 0) {
            revert NoSwapDataProvided();
        }

        address finalTokenId = _swaps[numSwaps - 1].receivingAssetId;
        uint256 initialBalance = LibAsset.getOwnBalance(finalTokenId);

        if (LibAsset.isNativeAsset(finalTokenId)) {
            initialBalance -= msg.value;
        }

        uint256[] memory initialBalances = _fetchBalances(_swaps);

        LibAsset.depositAssets(_swaps);

        _executeSwaps(
            _transactionId,
            _swaps,
            _leftoverReceiver,
            initialBalances
        );

        uint256 newBalance = LibAsset.getOwnBalance(finalTokenId) -
            initialBalance;

        if (newBalance < _minAmount) {
            revert CumulativeSlippageTooHigh(_minAmount, newBalance);
        }

        return newBalance;
    }

    /// @dev Deposits value, executes swaps, and performs minimum amount check and reserves native token for fees
    /// @param _transactionId the transaction id associated with the operation
    /// @param _minAmount the minimum amount of the final asset to receive
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver The address to send leftover funds to
    /// @param _nativeReserve Amount of native token to prevent from being swept back to the caller
    function _depositAndSwap(
        bytes32 _transactionId,
        uint256 _minAmount,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256 _nativeReserve
    ) internal returns (uint256) {
        uint256 numSwaps = _swaps.length;

        if (numSwaps == 0) {
            revert NoSwapDataProvided();
        }

        address finalTokenId = _swaps[numSwaps - 1].receivingAssetId;
        uint256 initialBalance = LibAsset.getOwnBalance(finalTokenId);

        if (LibAsset.isNativeAsset(finalTokenId)) {
            initialBalance -= msg.value;
        }

        uint256[] memory initialBalances = _fetchBalances(_swaps);

        LibAsset.depositAssets(_swaps);

        ReserveData memory reserveData = ReserveData({
            transactionId: _transactionId,
            leftoverReceiver: _leftoverReceiver,
            nativeReserve: _nativeReserve
        });

        _executeSwaps(reserveData, _swaps, initialBalances);

        uint256 newBalance = LibAsset.getOwnBalance(finalTokenId) -
            initialBalance;

        if (LibAsset.isNativeAsset(finalTokenId)) {
            newBalance -= _nativeReserve;
        }

        if (newBalance < _minAmount) {
            revert CumulativeSlippageTooHigh(_minAmount, newBalance);
        }

        return newBalance;
    }

    /// Private Methods ///

    /// @dev Executes swaps and checks that DEXs used are in the allowList
    /// @param _transactionId the transaction id associated with the operation
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial balances
    function _executeSwaps(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances
    ) internal noLeftovers(_swaps, _leftoverReceiver, _initialBalances) {
        uint256 numSwaps = _swaps.length;
        for (uint256 i; i < numSwaps; ++i) {
            LibSwap.SwapData calldata currentSwap = _swaps[i];

            if (
                !((LibAsset.isNativeAsset(currentSwap.sendingAssetId) ||
                    LibAllowList.contractIsAllowed(currentSwap.approveTo)) &&
                    LibAllowList.contractIsAllowed(currentSwap.callTo) &&
                    LibAllowList.selectorIsAllowed(
                        bytes4(currentSwap.callData[:4])
                    ))
            ) revert ContractCallNotAllowed();

            LibSwap.swap(_transactionId, currentSwap);
        }
    }

    /// @dev Executes swaps and checks that DEXs used are in the allowList
    /// @param _reserveData Data passed used to reserve native tokens
    /// @param _swaps Array of data used to execute swaps
    /// @param _initialBalances Array of initial balances
    function _executeSwaps(
        ReserveData memory _reserveData,
        LibSwap.SwapData[] calldata _swaps,
        uint256[] memory _initialBalances
    )
        internal
        noLeftoversReserve(
            _swaps,
            _reserveData.leftoverReceiver,
            _initialBalances,
            _reserveData.nativeReserve
        )
    {
        uint256 numSwaps = _swaps.length;
        for (uint256 i; i < numSwaps; ++i) {
            LibSwap.SwapData calldata currentSwap = _swaps[i];

            if (
                !((LibAsset.isNativeAsset(currentSwap.sendingAssetId) ||
                    LibAllowList.contractIsAllowed(currentSwap.approveTo)) &&
                    LibAllowList.contractIsAllowed(currentSwap.callTo) &&
                    LibAllowList.selectorIsAllowed(
                        bytes4(currentSwap.callData[:4])
                    ))
            ) revert ContractCallNotAllowed();

            LibSwap.swap(_reserveData.transactionId, currentSwap);
        }
    }

    /// @dev Fetches balances of tokens to be swapped before swapping.
    /// @param _swaps Array of data used to execute swaps
    /// @return uint256[] Array of token balances.
    function _fetchBalances(
        LibSwap.SwapData[] calldata _swaps
    ) internal view returns (uint256[] memory) {
        uint256 numSwaps = _swaps.length;
        uint256[] memory balances = new uint256[](numSwaps);
        address asset;
        for (uint256 i; i < numSwaps; ++i) {
            asset = _swaps[i].receivingAssetId;
            balances[i] = LibAsset.getOwnBalance(asset);

            if (LibAsset.isNativeAsset(asset)) {
                balances[i] -= msg.value;
            }
        }

        return balances;
    }

    /// @dev Refunds leftover tokens to a specified receiver after swaps complete
    /// @param _swaps Swap data array
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial token balances
    /// @param _nativeReserve Amount of native token to prevent from being swept (0 for no reserve)
    function _refundLeftovers(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances,
        uint256 _nativeReserve
    ) private {
        uint256 numSwaps = _swaps.length;
        address finalAsset = _swaps[numSwaps - 1].receivingAssetId;

        // Handle both intermediate receiving assets and leftover input tokens in a single loop
        uint256 leftoverAmount;
        address curAsset;
        address inputAsset;
        uint256 curAssetReserve;
        uint256 currentInputBalance;
        uint256 inputAssetReserve;

        for (uint256 i; i < numSwaps; ++i) {
            // Handle intermediate receiving assets (only for non-final swaps when numSwaps > 1)
            if (i < numSwaps - 1 && numSwaps != 1) {
                curAsset = _swaps[i].receivingAssetId;
                // Handle multiple swap steps
                if (curAsset != finalAsset) {
                    leftoverAmount =
                        LibAsset.getOwnBalance(curAsset) -
                        _initialBalances[i];
                    curAssetReserve = LibAsset.isNativeAsset(curAsset)
                        ? _nativeReserve
                        : 0;
                    if (leftoverAmount > curAssetReserve) {
                        LibAsset.transferAsset(
                            curAsset,
                            _leftoverReceiver,
                            leftoverAmount - curAssetReserve
                        );
                    }
                }
            }

            // Handle leftover input tokens (but never sweep the final receiving asset)
            inputAsset = _swaps[i].sendingAssetId;
            currentInputBalance = LibAsset.getOwnBalance(inputAsset);
            inputAssetReserve = LibAsset.isNativeAsset(inputAsset)
                ? _nativeReserve
                : 0;

            // Only transfer leftovers if there's actually a balance remaining after reserve
            // and if it's not the final receiving asset (which should be kept for bridging)
            if (
                currentInputBalance > inputAssetReserve &&
                inputAsset != finalAsset
            ) {
                LibAsset.transferAsset(
                    inputAsset,
                    _leftoverReceiver,
                    currentInputBalance - inputAssetReserve
                );
            }
        }
    }
}

// File: src/Helpers/Validatable.sol

/// @custom:version 1.0.0
pragma solidity ^0.8.17;



// solhint-disable-next-line max-line-length


// solhint-disable-next-line no-unused-

contract Validatable {
    modifier validateBridgeData(ILiFi.BridgeData memory _bridgeData) {
        if (LibUtil.isZeroAddress(_bridgeData.receiver)) {
            revert InvalidReceiver();
        }
        if (_bridgeData.minAmount == 0) {
            revert InvalidAmount();
        }
        if (_bridgeData.destinationChainId == block.chainid) {
            revert CannotBridgeToSameNetwork();
        }
        _;
    }

    modifier noNativeAsset(ILiFi.BridgeData memory _bridgeData) {
        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            revert NativeAssetNotSupported();
        }
        _;
    }

    modifier onlyAllowSourceToken(
        ILiFi.BridgeData memory _bridgeData,
        address _token
    ) {
        if (_bridgeData.sendingAssetId != _token) {
            revert InvalidSendingToken();
        }
        _;
    }

    modifier onlyAllowDestinationChain(
        ILiFi.BridgeData memory _bridgeData,
        uint256 _chainId
    ) {
        if (_bridgeData.destinationChainId != _chainId) {
            revert InvalidDestinationChain();
        }
        _;
    }

    modifier containsSourceSwaps(ILiFi.BridgeData memory _bridgeData) {
        if (!_bridgeData.hasSourceSwaps) {
            revert InformationMismatch();
        }
        _;
    }

    modifier doesNotContainSourceSwaps(ILiFi.BridgeData memory _bridgeData) {
        if (_bridgeData.hasSourceSwaps) {
            revert InformationMismatch();
        }
        _;
    }

    modifier doesNotContainDestinationCalls(
        ILiFi.BridgeData memory _bridgeData
    ) {
        if (_bridgeData.hasDestinationCall) {
            revert InformationMismatch();
        }
        _;
    }
}

// File: src/Helpers/LiFiData.sol

pragma solidity ^0.8.17;

/// @title LiFiData
/// @author LI.FI (https://li.fi)
/// @notice A storage for LI.FI-internal config data (addresses, chainIDs, etc.)
/// @custom:version 1.0.1
contract LiFiData {
    address internal constant NON_EVM_ADDRESS =
        0x11f111f111f111F111f111f111F111f111f111F1;

    // LI.FI non-EVM Custom Chain IDs (IDs are made up by the LI.FI team)
    uint256 internal constant LIFI_CHAIN_ID_APTOS = 9271000000000010;
    uint256 internal constant LIFI_CHAIN_ID_BCH = 20000000000002;
    uint256 internal constant LIFI_CHAIN_ID_BTC = 20000000000001;
    uint256 internal constant LIFI_CHAIN_ID_DGE = 20000000000004;
    uint256 internal constant LIFI_CHAIN_ID_LTC = 20000000000003;
    uint256 internal constant LIFI_CHAIN_ID_SOLANA = 1151111081099710;
    uint256 internal constant LIFI_CHAIN_ID_SUI = 9270000000000000;
    uint256 internal constant LIFI_CHAIN_ID_TRON = 1885080386571452;
    uint256 internal constant LIFI_CHAIN_ID_HYPERCORE = 1337;
}

// File: src/Facets/UnitFacet.sol

pragma solidity ^0.8.17;











/// @title UnitFacet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Unit
/// @custom:version 1.0.1
contract UnitFacet is
    ILiFi,
    ReentrancyGuard,
    SwapperV2,
    Validatable,
    LiFiData
{
    /// Constants ///

    bytes32 internal constant NAMESPACE = keccak256("com.lifi.facets.unit");

    // EIP-712 typehash for UnitPayload: keccak256("UnitPayload(bytes32 transactionId,uint256 minAmount,address receiver,address depositAddress,uint256 destinationChainId,address sendingAssetId,uint256 deadline)");
    bytes32 private constant UNIT_PAYLOAD_TYPEHASH =
        0xe40c93b75fa097357b7b866c9d28e3dba6e987fba2808befeaafebac93b94cba;

    /// @notice The address of the backend signer that is authorized to sign the UnitPayload
    address internal immutable BACKEND_SIGNER;

    /// Types ///

    struct Storage {
        /// @notice Tracks used transaction IDs to prevent replay attacks
        mapping(bytes32 => bool) usedTransactionIds;
    }

    /// @notice The data that is signed by the backend
    /// @param depositAddress The address to deposit the assets to
    /// @param signature The signature of the UnitPayload signed by the backend signer using EIP-712 standard
    /// @param deadline The deadline for the signature
    struct UnitData {
        address depositAddress;
        bytes signature;
        uint256 deadline;
    }

    /// Errors ///
    /// @notice Thrown when the signature is invalid
    error InvalidSignature();
    /// @notice Thrown when the signature is expired
    error SignatureExpired();
    /// @notice Thrown when the chain is unsupported
    error UnsupportedChain();
    /// @notice Thrown when a transaction with the same ID has already been processed
    error TransactionAlreadyProcessed();

    /// Constructor ///
    /// @notice Initializes the UnitFacet contract
    /// @param _backendSigner The address of the backend signer
    constructor(address _backendSigner) {
        if (_backendSigner == address(0)) {
            revert InvalidConfig();
        }
        BACKEND_SIGNER = _backendSigner;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Unit
    /// @dev IMPORTANT: Unit protocol enforces minimum deposit amounts to ensure deposits are sufficiently
    /// above network fees. Amounts below the minimum threshold may result in irrecoverable fund loss.
    /// These minimums are validated by the backend in the signed payload, but integrators should
    /// ensure amounts meet these requirements before calling this function.
    /// For the most up-to-date minimum amounts, refer to:
    /// https://docs.hyperunit.xyz/developers/api/generate-address and https://app.hyperunit.xyz/
    /// @param _bridgeData The core information needed for bridging
    /// @param _unitData Data specific to Unit
    function startBridgeTokensViaUnit(
        ILiFi.BridgeData memory _bridgeData,
        UnitData calldata _unitData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        validateBridgeData(_bridgeData)
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        onlyAllowSourceToken(_bridgeData, LibAsset.NULL_ADDRESS) // only allow native asset
        onlyAllowDestinationChain(_bridgeData, LIFI_CHAIN_ID_HYPERCORE)
    {
        _verifySignature(_bridgeData, _unitData);
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _unitData);
    }

    /// @notice Performs a swap before bridging via Unit
    /// @dev IMPORTANT: Unit protocol enforces minimum deposit amounts to ensure deposits are sufficiently
    /// above network fees. Amounts below the minimum threshold may result in irrecoverable fund loss.
    /// These minimums are validated by the backend in the signed payload, but integrators should
    /// ensure amounts meet these requirements before calling this function.
    /// For the most up-to-date minimum amounts, refer to:
    /// https://docs.hyperunit.xyz/developers/api/generate-address and https://app.hyperunit.xyz/
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _unitData Data specific to Unit
    function swapAndStartBridgeTokensViaUnit(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        UnitData calldata _unitData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowSourceToken(_bridgeData, LibAsset.NULL_ADDRESS) // only allow native asset
        onlyAllowDestinationChain(_bridgeData, LIFI_CHAIN_ID_HYPERCORE)
    {
        // The signature is intentionally verified with the pre-swap `minAmount`
        _verifySignature(_bridgeData, _unitData);
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData, _unitData);
    }

    /// Internal Methods ///

    /// @dev Contains the business logic for the bridge via Unit
    /// @param _bridgeData The core information needed for bridging
    /// @param _unitData Data specific to Unit
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        UnitData calldata _unitData
    ) internal {
        Storage storage s = getStorage();
        if (s.usedTransactionIds[_bridgeData.transactionId]) {
            revert TransactionAlreadyProcessed();
        }
        s.usedTransactionIds[_bridgeData.transactionId] = true;

        // Note: We intentionally do not add an explicit zero address validation for
        // `_unitData.depositAddress` here. The subsequent call to
        // `LibAsset.transferNativeAsset(payable(_unitData.depositAddress), _bridgeData.minAmount)`
        // will revert if `depositAddress` is address(0), ensuring user funds are never lost.
        // Adding a redundant check would only increase gas usage without improving safety.

        LibAsset.transferNativeAsset(
            payable(_unitData.depositAddress),
            _bridgeData.minAmount
        );

        emit LiFiTransferStarted(_bridgeData);
    }

    /// @dev Verifies the signature of the UnitPayload
    /// @param _bridgeData The core information needed for bridging
    /// @param _unitData Data specific to Unit
    function _verifySignature(
        ILiFi.BridgeData memory _bridgeData,
        UnitData calldata _unitData
    ) internal view {
        // check for signature expiration
        if (block.timestamp > _unitData.deadline) {
            revert SignatureExpired();
        }

        // compute the struct hash according to the EIP-712 standard: https://eips.ethereum.org/EIPS/eip-712
        bytes32 structHash = keccak256(
            abi.encode(
                UNIT_PAYLOAD_TYPEHASH,
                _bridgeData.transactionId, // transactionId from payload
                _bridgeData.minAmount, // minAmount from payload
                _bridgeData.receiver, // receiver from payload
                _unitData.depositAddress, // depositAddress from payload
                _bridgeData.destinationChainId, // destinationChainId from payload
                _bridgeData.sendingAssetId, // sendingAssetId from payload
                _unitData.deadline // deadline from payload
            )
        );

        // compute the final digest to be signed according to EIP-712
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", _domainSeparator(), structHash)
        );

        // recover the signer's address from the signature
        address recoveredSigner = ECDSA.recover(digest, _unitData.signature);

        // verify that the signer is the authorized backend
        if (recoveredSigner != BACKEND_SIGNER) {
            revert InvalidSignature();
        }
    }

    /// @notice Returns the EIP-712 domain separator.
    /// @dev The domain separator is calculated on the fly to ensure that `address(this)`
    /// always refers to the diamond's address when called via delegatecall.
    /// @return The EIP-712 domain separator.
    function _domainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("LI.FI Unit Facet")),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(this) // This will be the diamond's address at runtime
                )
            );
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        assembly {
            s.slot := namespace
        }
    }
}
