// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/allowanceholder/IAllowanceHolder.sol

pragma solidity ^0.8.25;

interface IAllowanceHolder {
    /// @notice Executes against `target` with the `data` payload. Prior to execution, token permits
    ///         are temporarily stored for the duration of the transaction. These permits can be
    ///         consumed by the `operator` during the execution
    /// @notice `operator` consumes the funds during its operations by calling back into
    ///         `AllowanceHolder` with `transferFrom`, consuming a token permit.
    /// @dev Neither `exec` nor `transferFrom` check that `token` contains code.
    /// @dev msg.sender is forwarded to target appended to the msg data (similar to ERC-2771)
    /// @param operator An address which is allowed to consume the token permits
    /// @param token The ERC20 token the caller has authorised to be consumed
    /// @param amount The quantity of `token` the caller has authorised to be consumed
    /// @param target A contract to execute operations with `data`
    /// @param data The data to forward to `target`
    /// @return result The returndata from calling `target` with `data`
    /// @notice If calling `target` with `data` reverts, the revert is propagated
    function exec(address operator, address token, uint256 amount, address payable target, bytes calldata data)
        external
        payable
        returns (bytes memory result);

    /// @notice The counterpart to `exec` which allows for the consumption of token permits later
    ///         during execution
    /// @dev *DOES NOT* check that `token` contains code. This function vacuously succeeds if
    ///      `token` is empty.
    /// @dev can only be called by the `operator` previously registered in `exec`
    /// @param token The ERC20 token to transfer
    /// @param owner The owner of tokens to transfer
    /// @param recipient The destination/beneficiary of the ERC20 `transferFrom`
    /// @param amount The quantity of `token` to transfer`
    /// @return true
    function transferFrom(address token, address owner, address recipient, uint256 amount) external returns (bool);
}

// File: src/IERC20.sol

pragma solidity ^0.8.25;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed, address indexed, uint256);
    event Approval(address indexed, address indexed, uint256);
}

interface IERC20Meta is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// File: src/vendor/SafeTransferLib.sol

pragma solidity >=0.8.25;



/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    uint32 private constant _TRANSFER_FROM_FAILED_SELECTOR = 0x7939f424; // bytes4(keccak256("TransferFromFailed()"))
    uint32 private constant _TRANSFER_FAILED_SELECTOR = 0x90b8ec18; // bytes4(keccak256("TransferFailed()"))
    uint32 private constant _APPROVE_FAILED_SELECTOR = 0x3e3f8f73; // bytes4(keccak256("ApproveFailed()"))

    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address payable to, uint256 amount) internal {
        assembly ("memory-safe") {
            // Transfer the ETH and store if it succeeded or not.
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                let freeMemoryPointer := mload(0x40)
                returndatacopy(freeMemoryPointer, 0, returndatasize())
                revert(freeMemoryPointer, returndatasize())
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        assembly ("memory-safe") {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            if iszero(call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)) {
                returndatacopy(freeMemoryPointer, 0, returndatasize())
                revert(freeMemoryPointer, returndatasize())
            }
            // We check that the call either returned exactly 1 (can't just be non-zero data), or had no
            // return data.
            if iszero(or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize()))) {
                mstore(0, _TRANSFER_FROM_FAILED_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        assembly ("memory-safe") {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)) {
                returndatacopy(freeMemoryPointer, 0, returndatasize())
                revert(freeMemoryPointer, returndatasize())
            }
            // We check that the call either returned exactly 1 (can't just be non-zero data), or had no
            // return data.
            if iszero(or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize()))) {
                mstore(0, _TRANSFER_FAILED_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
    }

    function safeApprove(IERC20 token, address to, uint256 amount) internal {
        assembly ("memory-safe") {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)) {
                returndatacopy(freeMemoryPointer, 0, returndatasize())
                revert(freeMemoryPointer, returndatasize())
            }
            // We check that the call either returned exactly 1 (can't just be non-zero data), or had no
            // return data.
            if iszero(or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize()))) {
                mstore(0, _APPROVE_FAILED_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
    }

    function safeApproveIfBelow(IERC20 token, address spender, uint256 amount) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (allowance < amount) {
            if (allowance != 0) {
                safeApprove(token, spender, 0);
            }
            safeApprove(token, spender, type(uint256).max);
        }
    }
}

// File: src/utils/CheckCall.sol

pragma solidity ^0.8.25;

library CheckCall {
    /**
     * @notice `staticcall` another contract. Check the length of the return without reading it.
     * @dev contains protections against EIP-150-induced insufficient gas griefing
     * @dev reverts iff the target is not a contract or we encounter an out-of-gas
     * @return success true iff the call succeeded and returned at least `minReturnBytes` of return
     *                 data
     * @param target the contract (reverts if non-contract) on which to make the `staticcall`
     * @param data the calldata to pass
     * @param minReturnBytes `success` is false if the call doesn't return at least this much return
     *                       data
     */
    function checkCall(address target, bytes memory data, uint256 minReturnBytes)
        internal
        view
        returns (bool success)
    {
        assembly ("memory-safe") {
            let beforeGas
            {
                let offset := add(data, 0x20)
                let length := mload(data)
                beforeGas := gas()
                success := staticcall(gas(), target, offset, length, 0x00, 0x00)
            }

            // `verbatim` can't work in inline assembly. Assignment of a value to a variable costs
            // gas (although how much is unpredictable because it depends on the Yul/IR optimizer),
            // as does the `GAS` opcode itself. Therefore, the `gas()` below returns less than the
            // actual amount of gas available for computation at the end of the call. Also
            // `beforeGas` above is exclusive of the preparing of the stack for `staticcall` as well
            // as the gas costs of the `staticcall` paid by the caller (e.g. cold account
            // access). All this makes the check below slightly too conservative. However, we do not
            // correct this because the correction would become outdated (possibly too permissive)
            // if the opcodes are repriced.
            let afterGas := gas()

            for {} 1 {} {
                if iszero(returndatasize()) {
                    // The absence of returndata means that it's possible that either we called an
                    // address without code or that the call reverted due to out-of-gas. We must
                    // check.
                    switch success
                    case 0 {
                        // Check whether the call reverted due to out-of-gas.
                        // https://eips.ethereum.org/EIPS/eip-150
                        // https://ronan.eth.limo/blog/ethereum-gas-dangers/
                        // We apply the "all but one 64th" rule twice because `target` could
                        // plausibly be a proxy. We apply it only twice because we assume only a
                        // single level of indirection.
                        let remainingGas := shr(6, beforeGas)
                        remainingGas := add(remainingGas, shr(6, sub(beforeGas, remainingGas)))
                        if iszero(lt(remainingGas, afterGas)) {
                            // The call failed due to not enough gas left. We deliberately consume
                            // all remaining gas with `invalid` (instead of `revert`) to make this
                            // failure distinguishable to our caller.
                            invalid()
                        }
                        // `success` is false because the call reverted
                    }
                    default {
                        // Check whether we called an address with no code (gas expensive).
                        if iszero(extcodesize(target)) { revert(0x00, 0x00) }
                        // We called a contract which returned no data; this is only a success if we
                        // were expecting no data.
                        success := iszero(minReturnBytes)
                    }
                    break
                }
                // The presence of returndata indicates that we definitely executed code. It also
                // means that the call didn't revert due to out-of-gas, if it reverted. We can omit
                // a bunch of checks.
                success := gt(success, lt(returndatasize(), minReturnBytes))
                break
            }
        }
    }
}

// File: src/utils/FreeMemory.sol

pragma solidity ^0.8.25;

abstract contract FreeMemory {
    modifier DANGEROUS_freeMemory() {
        uint256 freeMemPtr;
        assembly ("memory-safe") {
            freeMemPtr := mload(0x40)
        }
        _;
        assembly ("memory-safe") {
            mstore(0x40, freeMemPtr)
        }
    }
}

// File: src/allowanceholder/TransientStorageBase.sol

pragma solidity ^0.8.25;

abstract contract TransientStorageBase {
    type TSlot is bytes32;

    function _get(TSlot s) internal view virtual returns (uint256);

    function _set(TSlot s, uint256 v) internal virtual;
}

// File: src/allowanceholder/TransientStorageLayout.sol

pragma solidity ^0.8.25;



abstract contract TransientStorageLayout is TransientStorageBase {
    /// @dev The key for this ephemeral allowance is keccak256(abi.encodePacked(operator, owner, token)).
    function _ephemeralAllowance(address operator, address owner, address token) internal pure returns (TSlot r) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(0x28, token)
            mstore(0x14, owner)
            mstore(0x00, operator)
            // allowance slot is keccak256(abi.encodePacked(operator, owner, token))
            r := keccak256(0x0c, 0x3c)
            // restore dirtied free pointer
            mstore(0x40, ptr)
        }
    }
}

// File: src/allowanceholder/AllowanceHolderBase.sol

pragma solidity ^0.8.25;








/// @notice Thrown when validating the target, avoiding executing against an ERC20 directly
error ConfusedDeputy();

abstract contract AllowanceHolderBase is TransientStorageLayout, FreeMemory {
    using SafeTransferLib for IERC20;
    using CheckCall for address payable;

    function _rejectIfERC20(address payable maybeERC20, bytes calldata data) private view DANGEROUS_freeMemory {
        // We could just choose a random address for this check, but to make
        // confused deputy attacks harder for tokens that might be badly behaved
        // (e.g. tokens with blacklists), we choose to copy the first argument
        // out of `data` and mask it as an address. If there isn't enough
        // `data`, we use 0xdead instead.
        address target;
        if (data.length > 0x10) {
            target = address(uint160(bytes20(data[0x10:])));
        }
        // EIP-1352 (not adopted) specifies 0xffff as the maximum precompile
        if (target <= address(0xffff)) {
            // 0xdead is a conventional burn address; we assume that it is not treated specially
            target = address(0xdead);
        }
        bytes memory testData = abi.encodeCall(IERC20.balanceOf, target);
        if (maybeERC20.checkCall(testData, 0x20)) revert ConfusedDeputy();
    }

    function _msgSender() private view returns (address sender) {
        if ((sender = msg.sender) == address(this)) {
            assembly ("memory-safe") {
                sender := shr(0x60, calldataload(sub(calldatasize(), 0x14)))
            }
        }
    }

    /// @dev This virtual function provides the implementation for the function
    ///      of the same name in `IAllowanceHolder`. It is unimplemented in this
    ///      base contract to accommodate the customization required to support
    ///      both chains that have EIP-1153 (transient storage) and those that
    ///      don't.
    function exec(address operator, address token, uint256 amount, address payable target, bytes calldata data)
        internal
        virtual
        returns (bytes memory result);

    /// @dev This is the majority of the implementation of IAllowanceHolder.exec
    ///      . The arguments have the same meaning as documented there.
    /// @return result
    /// @return sender The (possibly forwarded) message sender that is
    ///                requesting the allowance be set. Provided to avoid
    ///                duplicated computation in customized `exec`
    /// @return allowance The slot where the ephemeral allowance is
    ///                   stored. Provided to avoid duplicated computation in
    ///                   customized `exec`
    function _exec(address operator, address token, uint256 amount, address payable target, bytes calldata data)
        internal
        returns (bytes memory result, address sender, TSlot allowance)
    {
        // This contract has no special privileges, except for the allowances it
        // holds. In order to prevent abusing those allowances, we prohibit
        // sending arbitrary calldata (doing `target.call(data)`) to any
        // contract that might be an ERC20.
        _rejectIfERC20(target, data);

        sender = _msgSender();
        allowance = _ephemeralAllowance(operator, sender, token);
        _set(allowance, amount);

        // For gas efficiency we're omitting a bunch of checks here. Notably,
        // we're omitting the check that `address(this)` has sufficient value to
        // send (we know it does), and we're omitting the check that `target`
        // contains code (we already checked in `_rejectIfERC20`).
        assembly ("memory-safe") {
            result := mload(0x40)
            calldatacopy(result, data.offset, data.length)
            // ERC-2771 style msgSender forwarding https://eips.ethereum.org/EIPS/eip-2771
            mstore(add(result, data.length), shl(0x60, sender))
            let success := call(gas(), target, callvalue(), result, add(data.length, 0x14), 0x00, 0x00)
            let ptr := add(result, 0x20)
            returndatacopy(ptr, 0x00, returndatasize())
            switch success
            case 0 { revert(ptr, returndatasize()) }
            default {
                mstore(result, returndatasize())
                mstore(0x40, add(ptr, returndatasize()))
            }
        }
    }

    /// @dev This provides the implementation of the function of the same name
    ///      in `IAllowanceHolder`.
    function transferFrom(address token, address owner, address recipient, uint256 amount) internal {
        // msg.sender is the assumed and later validated operator
        TSlot allowance = _ephemeralAllowance(msg.sender, owner, token);
        // validation of the ephemeral allowance for operator, owner, token via
        // uint underflow
        _set(allowance, _get(allowance) - amount);
        // `safeTransferFrom` does not check that `token` actually contains
        // code. It is the responsibility of integrating code to check for that
        // if vacuous success is a security concern.
        IERC20(token).safeTransferFrom(owner, recipient, amount);
    }

    fallback() external payable {
        uint256 selector;
        assembly ("memory-safe") {
            selector := shr(0xe0, calldataload(0x00))
        }
        if (selector == uint256(uint32(IAllowanceHolder.transferFrom.selector))) {
            address token;
            address owner;
            address recipient;
            uint256 amount;
            assembly ("memory-safe") {
                // We do not validate `calldatasize()`. If the calldata is short
                // enough that `amount` is null, this call is a harmless no-op.
                let err := callvalue()
                token := calldataload(0x04)
                err := or(err, shr(0xa0, token))
                owner := calldataload(0x24)
                err := or(err, shr(0xa0, owner))
                recipient := calldataload(0x44)
                err := or(err, shr(0xa0, recipient))
                if err { revert(0x00, 0x00) }
                amount := calldataload(0x64)
            }

            transferFrom(token, owner, recipient, amount);

            // return true;
            assembly ("memory-safe") {
                mstore(0x00, 0x01)
                return(0x00, 0x20)
            }
        } else if (selector == uint256(uint32(IAllowanceHolder.exec.selector))) {
            address operator;
            address token;
            uint256 amount;
            address payable target;
            bytes calldata data;
            assembly ("memory-safe") {
                // We do not validate `calldatasize()`. If the calldata is short
                // enough that `data` is null, it will alias `operator`. This
                // results in either an OOG (because `operator` encodes a
                // too-long `bytes`) or is a harmless no-op (because `operator`
                // encodes a valid length, but not an address capable of making
                // calls). If the calldata is _so_ sort that `target` is null,
                // we will revert because it contains no code.
                operator := calldataload(0x04)
                let err := shr(0xa0, operator)
                token := calldataload(0x24)
                err := or(err, shr(0xa0, token))
                amount := calldataload(0x44)
                target := calldataload(0x64)
                err := or(err, shr(0xa0, target))
                if err { revert(0x00, 0x00) }
                // We perform no validation that `data` is reasonable.
                data.offset := add(0x04, calldataload(0x84))
                data.length := calldataload(data.offset)
                data.offset := add(0x20, data.offset)
            }

            bytes memory result = exec(operator, token, amount, target, data);

            // return result;
            assembly ("memory-safe") {
                let returndata := sub(result, 0x20)
                mstore(returndata, 0x20)
                return(returndata, add(0x40, mload(result)))
            }
        } else if (selector == uint256(uint32(IERC20.balanceOf.selector))) {
            // balanceOf(address) reverts with a single byte of returndata,
            // making it more gas efficient to pass the `_rejectERC20` check
            assembly ("memory-safe") {
                revert(0x00, 0x01)
            }
        } else {
            // emulate standard Solidity behavior
            assembly ("memory-safe") {
                revert(0x00, 0x00)
            }
        }
    }
}

// File: src/allowanceholder/TransientStorage.sol

pragma solidity ^0.8.25;



abstract contract TransientStorage is TransientStorageBase {
    function _get(TSlot s) internal view override returns (uint256 r) {
        assembly ("memory-safe") {
            r := tload(s)
        }
    }

    function _set(TSlot s, uint256 v) internal override {
        assembly ("memory-safe") {
            tstore(s, v)
        }
    }
}

// File: src/allowanceholder/AllowanceHolder.sol

pragma solidity ^0.8.25;




/// @custom:security-contact security@0x.org
contract AllowanceHolder is TransientStorage, AllowanceHolderBase {
    constructor() {
        require(address(this) == 0x0000000000001fF3684f28c67538d4D072C22734 || block.chainid == 31337);
    }

    /// @inheritdoc AllowanceHolderBase
    function exec(address operator, address token, uint256 amount, address payable target, bytes calldata data)
        internal
        override
        returns (bytes memory)
    {
        (bytes memory result, address sender, TSlot allowance) = _exec(operator, token, amount, target, data);
        // EIP-3074 seems unlikely
        if (sender != tx.origin) {
            _set(allowance, 0);
        }
        return result;
    }
}

// File: lib/forge-std/src/interfaces/IERC20.sol

pragma solidity >=0.6.2;

/// @dev Interface of the ERC20 standard as defined in the EIP.
/// @dev This includes the optional name, symbol, and decimals metadata.
interface IERC20 {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set, where `value`
    /// is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    /// @notice Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Moves `amount` tokens from the caller's account to `to`.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` is allowed
    /// to spend on behalf of `owner`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev Be aware of front-running risks: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Moves `amount` tokens from `from` to `to` using the allowance mechanism.
    /// `amount` is then deducted from the caller's allowance.
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /// @notice Returns the decimals places of the token.
    function decimals() external view returns (uint8);
}

// File: src/vendor/SafeTransferLib_Solmate.sol

pragma solidity >=0.8.25;



/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    uint32 private constant _TRANSFER_FROM_FAILED_SELECTOR = 0x7939f424; // bytes4(keccak256("TransferFromFailed()"))
    uint32 private constant _TRANSFER_FAILED_SELECTOR = 0x90b8ec18; // bytes4(keccak256("TransferFailed()"))
    uint32 private constant _APPROVE_FAILED_SELECTOR = 0x3e3f8f73; // bytes4(keccak256("ApproveFailed()"))

    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address payable to, uint256 amount) internal {
        assembly ("memory-safe") {
            // Transfer the ETH and store if it succeeded or not.
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                let freeMemoryPointer := mload(0x40)
                returndatacopy(freeMemoryPointer, 0, returndatasize())
                revert(freeMemoryPointer, returndatasize())
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        assembly ("memory-safe") {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            if iszero(call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)) {
                returndatacopy(freeMemoryPointer, 0, returndatasize())
                revert(freeMemoryPointer, returndatasize())
            }
            // We check that the call either returned exactly 1 (can't just be non-zero data), or had no
            // return data.
            if iszero(or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize()))) {
                mstore(0, _TRANSFER_FROM_FAILED_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        assembly ("memory-safe") {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)) {
                returndatacopy(freeMemoryPointer, 0, returndatasize())
                revert(freeMemoryPointer, returndatasize())
            }
            // We check that the call either returned exactly 1 (can't just be non-zero data), or had no
            // return data.
            if iszero(or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize()))) {
                mstore(0, _TRANSFER_FAILED_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
    }

    function safeApprove(IERC20 token, address to, uint256 amount) internal {
        assembly ("memory-safe") {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)) {
                returndatacopy(freeMemoryPointer, 0, returndatasize())
                revert(freeMemoryPointer, returndatasize())
            }
            // We check that the call either returned exactly 1 (can't just be non-zero data), or had no
            // return data.
            if iszero(or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize()))) {
                mstore(0, _APPROVE_FAILED_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
    }

    function safeApproveIfBelow(IERC20 token, address spender, uint256 amount) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (allowance < amount) {
            if (allowance != 0) {
                safeApprove(token, spender, 0);
            }
            safeApprove(token, spender, type(uint256).max);
        }
    }
}
