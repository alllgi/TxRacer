// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermit2} from "../interfaces/uniswap/IPermit2.sol";

abstract contract SquidPermit2 {
    // Type hashes required for witness encoding for permit2 in SquidRouter.
    bytes32 public constant FUND_AND_RUN_MULTICALL_DATA_TYPEHASH =
        keccak256("FundAndRunMulticallData(bytes32 hashedCalls)");
    bytes32 public constant CCTP_BRIDGE_DATA_TYPEHASH =
        keccak256(
            "CCTPBridgeData(uint32 destinationDomain,bytes32 destinationAddress,bytes32 destinationCaller)"
        );

    // Witness type strings required for witness encoding for permit2 in SquidRouter.
    string public constant FUND_AND_RUN_MULTICALL_WITNESS_TYPE_STRING =
        "FundAndRunMulticallData witness)FundAndRunMulticallData(bytes32 hashedCalls)TokenPermissions(address token,uint256 amount)";
    string public constant CCTP_BRIDGE_WITNESS_TYPE_STRING =
        "CCTPBridgeData witness)CCTPBridgeData(uint32 destinationDomain,bytes32 destinationAddress,bytes32 destinationCaller)TokenPermissions(address token,uint256 amount)";

    IPermit2 public immutable permit2;

    /// @notice Thrown when a function using permit2 protocol is called why it is not available on current network.
    error Permit2Unavailable();
    /// @notice Thrown when a transferFrom2 call does not either have regular ERC20 or permit2 allowance.
    error TransferFailed();
    /// @notice Thrown when a value greater than type(uint160).max is cast to uint160.
    error UnsafeCast();

    /// @param _permit2 Address of the relevant Uniswap's Permit2.sol contract deployment
    /// Can be zero address if permit2 is not available on current network.
    constructor(address _permit2) {
        permit2 = IPermit2(_permit2);
    }

    /// @notice Check if permit2 is available on current network and revert otherwise.
    modifier onlyIfPermit2Available() {
        if (address(permit2) == address(0)) revert Permit2Unavailable();
        _;
    }

    /// @notice Try to transferFrom tokens with regular ERC20 allowance, and falls back to permit2 allowance
    /// if not.
    /// @param token Address of the ERC20 token to be collected.
    /// @param from Address of the holder of the funds to be collected.
    /// @param to Address of the receiver of the funds to be collected.
    /// @param amount Amount of ERC20 token to be collected.
    function _transferFrom2(address token, address from, address to, uint256 amount) internal {
        // Generate calldata for a standard transferFrom call.
        bytes memory inputData = abi.encodeCall(IERC20.transferFrom, (from, to, amount));

        bool success; // Call the token contract as normal, capturing whether it succeeded.
        assembly {
            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(eq(mload(0), 1), iszero(returndatasize())),
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                // We use 0 and 32 to copy up to 32 bytes of return data into the first slot of scratch space.
                call(gas(), token, 0, add(inputData, 32), mload(inputData), 0, 32)
            )
        }

        // We'll fall back to using Permit2 if calling transferFrom on the token directly reverted.
        if (!success) {
            // Revert transfer if Permit2 is not available.
            if (address(permit2) == address(0)) revert TransferFailed();
            permit2.transferFrom(from, to, _toUint160(amount), address(token));
        }
    }

    /// @notice Safely casts uint256 to uint160.
    /// @param value The uint256 to be cast.
    /// @return Casted uint160 value.
    function _toUint160(uint256 value) private pure returns (uint160) {
        if (value > type(uint160).max) revert UnsafeCast();
        return uint160(value);
    }
}
