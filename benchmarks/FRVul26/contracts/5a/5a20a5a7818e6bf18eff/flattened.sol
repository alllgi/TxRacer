// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: CommandBuilder.sol

pragma solidity 0.8.17;

library CommandBuilder {

    uint256 constant IDX_VARIABLE_LENGTH = 0x80;
    uint256 constant IDX_VALUE_MASK = 0x7f;
    uint256 constant IDX_END_OF_ARGS = 0xff;
    uint256 constant IDX_USE_STATE = 0xfe;

    function buildInputs(
        bytes[] memory state,
        bytes4 selector,
        bytes32 indices
    ) internal view returns (bytes memory ret) {
        uint256 free; // Pointer to first free byte in tail part of message
        uint256 idx;

        // Determine the length of the encoded data
        for (uint256 i; i < 32;) {
            idx = uint8(indices[i]);
            if (idx == IDX_END_OF_ARGS) break;
            unchecked{free += 32;}
            unchecked{++i;}
        }

        // Encode it
        uint256 bytesWritten;
        assembly {
            ret := mload(0x40)
            bytesWritten := add(bytesWritten, 4)
            mstore(0x40, add(ret, and(add(add(bytesWritten, 0x20), 0x1f), not(0x1f))))
            mstore(add(ret, 32), selector)
        }
        uint256 count = 0;
        bytes memory stateData; // Optionally encode the current state if the call requires it
        for (uint256 i; i < 32;) {
            idx = uint8(indices[i]);
            if (idx == IDX_END_OF_ARGS) break;

            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_USE_STATE) {
                    assembly {
                        bytesWritten := add(bytesWritten, 32)
                        mstore(0x40, add(ret, and(add(add(bytesWritten, 0x20), 0x1f), not(0x1f))))
                        mstore(add(add(ret, 36), count), free)
                    }
                    if (stateData.length == 0) {
                        stateData = abi.encode(state);
                    }
                    assembly {
                        bytesWritten := add(bytesWritten, mload(stateData))
                        mstore(0x40, add(ret, and(add(add(bytesWritten, 0x20), 0x1f), not(0x1f))))
                    }
                    memcpy(stateData, 32, ret, free + 4, stateData.length - 32);
                    free += stateData.length - 32;
                } else {
                    bytes memory stateVar = state[idx & IDX_VALUE_MASK];
                    uint256 arglen = stateVar.length;

                    // Variable length data; put a pointer in the slot and write the data at the end
                    assembly {
                        bytesWritten := add(bytesWritten, 32)
                        mstore(0x40, add(ret, and(add(add(bytesWritten, 0x20), 0x1f), not(0x1f))))
                        mstore(add(add(ret, 36), count), free)
                    }
                    assembly {
                        bytesWritten := add(bytesWritten, arglen)
                        mstore(0x40, add(ret, and(add(add(bytesWritten, 0x20), 0x1f), not(0x1f))))
                    }
                    memcpy(
                        stateVar,
                        0,
                        ret,
                        free + 4,
                        arglen
                    );
                    free += arglen;
                }
            } else {
                // Fixed length data; write it directly
                bytes memory stateVar = state[idx & IDX_VALUE_MASK];
                assembly {
                    bytesWritten := add(bytesWritten, mload(stateVar))
                    mstore(0x40, add(ret, and(add(add(bytesWritten, 0x20), 0x1f), not(0x1f))))
                    mstore(add(add(ret, 36), count), mload(add(stateVar, 32)))
                }
            }
            unchecked{count += 32;}
            unchecked{++i;}
        }
        assembly {
            mstore(ret, bytesWritten)
        }
    }

    function writeOutputs(
        bytes[] memory state,
        bytes1 index,
        bytes memory output
    ) internal pure returns (bytes[] memory) {
        uint256 idx = uint8(index);
        if (idx == IDX_END_OF_ARGS) return state;

        if (idx & IDX_VARIABLE_LENGTH != 0) {
            if (idx == IDX_USE_STATE) {
                state = abi.decode(output, (bytes[]));
            } else {
                // Check the first field is 0x20 (because we have only a single return value)
                uint256 argptr;
                assembly {
                    argptr := mload(add(output, 32))
                }
                require(
                    argptr == 32,
                    "Only one return value permitted (variable)"
                );

                assembly {
                    // Overwrite the first word of the return data with the length - 32
                    mstore(add(output, 32), sub(mload(output), 32))
                    // Insert a pointer to the return data, starting at the second word, into state
                    mstore(
                        add(add(state, 32), mul(and(idx, IDX_VALUE_MASK), 32)),
                        add(output, 32)
                    )
                }
            }
        } else {
            // Single word
            require(
                output.length == 32,
                "Only one return value permitted (static)"
            );

            state[idx & IDX_VALUE_MASK] = output;
        }

        return state;
    }

    function writeTuple(
        bytes[] memory state,
        bytes1 index,
        bytes memory output
    ) internal view {
        uint256 idx = uint256(uint8(index));
        if (idx == IDX_END_OF_ARGS) return;

        bytes memory entry = state[idx & IDX_VALUE_MASK] = new bytes(output.length + 32);

        memcpy(output, 0, entry, 32, output.length);
        assembly {
            let l := mload(output)
            mstore(add(entry, 32), l)
        }
    }

    function memcpy(
        bytes memory src,
        uint256 srcidx,
        bytes memory dest,
        uint256 destidx,
        uint256 len
    ) internal view {
        assembly {
            pop(
                staticcall(
                    gas(),
                    4,
                    add(add(src, 32), srcidx),
                    len,
                    add(add(dest, 32), destidx),
                    len
                )
            )
        }
    }
}

// File: VM.sol

pragma solidity 0.8.17;



abstract contract VM {
    using CommandBuilder for bytes[];

    uint256 constant FLAG_CT_DELEGATECALL = 0x00;
    uint256 constant FLAG_CT_CALL = 0x01;
    uint256 constant FLAG_CT_STATICCALL = 0x02;
    uint256 constant FLAG_CT_VALUECALL = 0x03;
    uint256 constant FLAG_CT_MASK = 0x03;
    uint256 constant FLAG_EXTENDED_COMMAND = 0x40;
    uint256 constant FLAG_TUPLE_RETURN = 0x80;

    uint256 constant SHORT_COMMAND_FILL = 0x000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    address immutable self;

    error ExecutionFailed(
        uint256 command_index,
        address target,
        string message
    );

    constructor() {
        self = address(this);
    }

    function _execute(bytes32[] calldata commands, bytes[] memory state)
      internal returns (bytes[] memory)
    {
        bytes32 command;
        uint256 flags;
        bytes32 indices;

        bool success;
        bytes memory outdata;

        uint256 commandsLength = commands.length;
        for (uint256 i; i < commandsLength;) {
            command = commands[i];
            flags = uint256(command >> 216) & 0xFF; // more efficient
            // flags = uint256(uint8(bytes1(command << 32))); // more readable

            if (flags & FLAG_EXTENDED_COMMAND != 0) {
                indices = commands[++i];
            } else {
                indices = bytes32(uint256(command << 40) | SHORT_COMMAND_FILL);
            }

            if (flags & FLAG_CT_MASK == FLAG_CT_DELEGATECALL) {
                (success, outdata) = address(uint160(uint256(command))).delegatecall( // target
                    // inputs
                    state.buildInputs(
                        //selector
                        bytes4(command),
                        indices
                    )
                );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_CALL) {
                (success, outdata) = address(uint160(uint256(command))).call( // target
                    // inputs
                    state.buildInputs(
                        //selector
                        bytes4(command),
                        indices
                    )
                );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_STATICCALL) {
                (success, outdata) = address(uint160(uint256(command))).staticcall( // target
                    // inputs
                    state.buildInputs(
                        //selector
                        bytes4(command),
                        indices
                    )
                );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_VALUECALL) {
                uint256 callEth;
                bytes memory v = state[uint8(bytes1(indices))];
                require(v.length == 32, "_execute: value call has no value indicated.");
                assembly {
                    callEth := mload(add(v, 0x20))
                }
                (success, outdata) = address(uint160(uint256(command))).call{ // target
                    value: callEth
                }(
                    // inputs
                    state.buildInputs(
                        //selector
                        bytes4(command),
                        bytes32(uint256(indices << 8) | CommandBuilder.IDX_END_OF_ARGS)
                    )
                );
            } else {
                revert("Invalid calltype");
            }

            if (!success) {
                if (outdata.length > 0) {
                    assembly {
                        outdata := add(outdata, 68)
                    }
                }
                revert ExecutionFailed({
                    command_index: 0,
                    target: address(uint160(uint256(command))),
                    message: outdata.length > 0 ? string(outdata) : "Unknown"
                });
            }

            if (flags & FLAG_TUPLE_RETURN != 0) {
                state.writeTuple(bytes1(command << 88), outdata);
            } else {
                state = state.writeOutputs(bytes1(command << 88), outdata);
            }
            unchecked{++i;}
        }
        return state;
    }
}

// File: TradeHandlerHelper.sol

pragma solidity 0.8.17;

library TradeHandlerHelper {
    function insertElement(
        bytes calldata tuple,
        uint256 index,
        bytes32 element,
        bool returnRaw
    ) public pure returns (bytes memory newTuple) {
        uint256 byteIndex;
        unchecked {
            byteIndex = index * 32;
        }
        require(byteIndex <= tuple.length);
        newTuple = bytes.concat(tuple[:byteIndex], element, tuple[byteIndex:]);
        if (returnRaw) {
            assembly {
                return(add(newTuple, 32), tuple.length)
            }
        }
    }

    function replaceElement(
        bytes calldata tuple,
        uint256 index,
        bytes32 element,
        bool returnRaw
    ) public pure returns (bytes memory newTuple) {
        uint256 byteIndex;
        unchecked {
            byteIndex = index * 32;
            require(tuple.length >= 32 && byteIndex <= tuple.length - 32);
            newTuple = bytes.concat(
                tuple[:byteIndex],
                element,
                tuple[byteIndex + 32:]
            );
        }
        if (returnRaw) {
            assembly {
                return(add(newTuple, 32), tuple.length)
            }
        }
    }

    function getElement(bytes memory tuple, uint256 index)
        public
        pure
        returns (bytes32)
    {
        assembly {
            return(add(tuple, mul(add(index, 1), 32)), 32)
        }
    }

    function power(uint256 a, uint256 b) public pure returns (uint256) {
        return a**b;
    }

    function sum(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        return a - b;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        return a / b;
    }

    /// @dev Wrapper around a call to the ERC20 function `transfer` that reverts
    /// also when the token returns `false`.
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) external {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            )
            mstore(add(freeMemoryPointer, 36), value)

            if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        require(getLastTransferResult(token), "!transfer");
    }

    /// @dev Wrapper around a call to the ERC20 function `transferFrom` that
    /// reverts also when the token returns `false`.
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) external {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(
                add(freeMemoryPointer, 4),
                and(from, 0xffffffffffffffffffffffffffffffffffffffff)
            )
            mstore(
                add(freeMemoryPointer, 36),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            )
            mstore(add(freeMemoryPointer, 68), value)

            if iszero(call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        require(getLastTransferResult(token), "!transferFrom");
    }

    /// @dev Verifies that the last return was a successful `transfer*` call.
    /// This is done by checking that the return data is either empty, or
    /// is a valid ABI encoded boolean.
    function getLastTransferResult(address token)
        private
        view
        returns (bool success)
    {
        // NOTE: Inspecting previous return data requires assembly. Note that
        // we write the return data to memory 0 in the case where the return
        // data size is 32, this is OK since the first 64 bytes of memory are
        // reserved by Solidy as a scratch space that can be used within
        // assembly blocks.
        // <https://docs.soliditylang.org/en/v0.7.6/internals/layout_in_memory.html>
        // solhint-disable-next-line no-inline-assembly
        assembly {
            /// @dev Revert with an ABI encoded Solidity error with a message
            /// that fits into 32-bytes.
            ///
            /// An ABI encoded Solidity error has the following memory layout:
            ///
            /// ------------+----------------------------------
            ///  byte range | value
            /// ------------+----------------------------------
            ///  0x00..0x04 |        selector("Error(string)")
            ///  0x04..0x24 |      string offset (always 0x20)
            ///  0x24..0x44 |                    string length
            ///  0x44..0x64 | string value, padded to 32-bytes
            function revertWithMessage(length, message) {
                mstore(0x00, "\x08\xc3\x79\xa0")
                mstore(0x04, 0x20)
                mstore(0x24, length)
                mstore(0x44, message)
                revert(0x00, 0x64)
            }

            switch returndatasize()
            // Non-standard ERC20 transfer without return.
            case 0 {
                // NOTE: When the return data size is 0, verify that there
                // is code at the address. This is done in order to maintain
                // compatibility with Solidity calling conventions.
                // <https://docs.soliditylang.org/en/v0.7.6/control-structures.html#external-function-calls>
                if iszero(extcodesize(token)) {
                    revertWithMessage(20, "!contract")
                }

                success := 1
            }
            // Standard ERC20 transfer returning boolean success value.
            case 32 {
                returndatacopy(0, 0, returndatasize())

                // NOTE: For ABI encoding v1, any non-zero value is accepted
                // as `true` for a boolean. In order to stay compatible with
                // OpenZeppelin's `SafeERC20` library which is known to work
                // with the existing ERC20 implementation we care about,
                // make sure we return success for any non-zero return value
                // from the `transfer*` call.
                success := iszero(iszero(mload(0)))
            }
            default {
                revertWithMessage(31, "malformed") // malformed transfer result
            }
        }
    }

    function safeTransferETH(address to, uint256 amount) external {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "!safeTransferETH");
    }
}

// File: TradeHandler.sol

pragma solidity 0.8.17;




/**
@title Trade Handler
@author yearn.finance
@notice TradeHandler is in charge of tracking which strategy wants to do certain
trade. The strategy registers what they have and what they want and wait for an
async trade. TradeHandler trades are executed by mechs through a weiroll VM.
*/

contract TradeHandler is VM {
    address payable public governance;
    address payable public pendingGovernance;

    // Treasury multisig for sweeps
    address payable public treasury;

    // COW protocol settlement contract address.
    address public settlement;

    // Mechs are addresses other than `settlement` that are authorized to
    // to call `execute()`
    mapping(address => bool) public mechs;

    // Solvers are EOAs authorised by COW protocol's settlement contract to
    // settle batches won at an auction
    mapping(address => bool) public solvers;

    event UpdatedSettlement(address settlement);

    event UpdatedTreasury(address treasury);

    event UpdatedGovernance(address governance);

    event AddedMech(address mech);
    event RemovedMech(address mech);

    event AddedSolver(address solver);
    event RemovedSolver(address solver);

    event TradeEnabled(
        address indexed seller,
        address indexed tokenIn,
        address indexed tokenOut
    );
    event TradeDisabled(
        address indexed seller,
        address indexed tokenIn,
        address indexed tokenOut
    );

    modifier onlyGovernance() {
        require(msg.sender == governance, "!governance");
        _;
    }

    // The settlement contract must be authorized to call `execute()`, but additional
    // safeguards are needed because solvers other than Seasolver are also authorized
    // to call settlement.settle().
    modifier onlyAuthorized() {
        require(
            ((msg.sender == settlement) && solvers[tx.origin]) ||
                ((msg.sender != settlement && mechs[msg.sender])),
            "!authorized"
        );
        _;
    }

    constructor(address payable _governance) {
        governance = _governance;
        treasury = _governance;
        mechs[_governance] = true;
    }

    function setGovernance(address payable _governance)
        external
        onlyGovernance
    {
        pendingGovernance = _governance;
    }

    function setTreasury(address payable _treasury) external onlyGovernance {
        treasury = _treasury;
        emit UpdatedTreasury(_treasury);
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance);
        governance = pendingGovernance;
        delete pendingGovernance;
        emit UpdatedGovernance(governance);
    }

    function setSettlement(address _settlement) external onlyGovernance {
        // Settlement can't be a mech.
        require(!mechs[_settlement]);
        settlement = _settlement;
        emit UpdatedSettlement(_settlement);
    }

    function addMech(address _mech) external onlyGovernance {
        // Settlement can't be set as mech as that would grant
        // other solvers power to execute.
        require(settlement != _mech);
        mechs[_mech] = true;
        emit AddedMech(_mech);
    }

    function removeMech(address _mech) external onlyGovernance {
        delete mechs[_mech];
        emit RemovedMech(_mech);
    }

    function addSolver(address _solver) external onlyGovernance {
        solvers[_solver] = true;
        emit AddedSolver(_solver);
    }

    function removeSolver(address _solver) external onlyGovernance {
        delete solvers[_solver];
        emit RemovedSolver(_solver);
    }

    function enable(address _tokenIn, address _tokenOut) external {
        require(_tokenIn != address(0));
        require(_tokenOut != address(0));

        emit TradeEnabled(msg.sender, _tokenIn, _tokenOut);
    }

    function disable(address _tokenIn, address _tokenOut) external {
        _disable(msg.sender, _tokenIn, _tokenOut);
    }

    function disableByAdmin(
        address _strategy,
        address _tokenIn,
        address _tokenOut
    ) external onlyGovernance {
        _disable(_strategy, _tokenIn, _tokenOut);
    }

    function _disable(
        address _strategy,
        address _tokenIn,
        address _tokenOut
    ) internal {
        emit TradeDisabled(_strategy, _tokenIn, _tokenOut);
    }

    function execute(bytes32[] calldata commands, bytes[] memory state)
        external
        onlyAuthorized
        returns (bytes[] memory)
    {
        return _execute(commands, state);
    }

    function sweep(address[] calldata _tokens, uint256[] calldata _amounts)
        external
    {
        uint256 _size = _tokens.length;
        require(_size == _amounts.length);

        for (uint256 i = 0; i < _size; i++) {
            if (_tokens[i] == address(0)) {
                // Native ETH
                TradeHandlerHelper.safeTransferETH(treasury, _amounts[i]);
            } else {
                // ERC20s
                TradeHandlerHelper.safeTransfer(
                    _tokens[i],
                    treasury,
                    _amounts[i]
                );
            }
        }
    }

    // `fallback` is called when msg.data is not empty
    fallback() external payable {}

    // `receive` is called when msg.data is empty
    receive() external payable {}
}
