// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Contracts
import { AugustusFees } from "../fees/AugustusFees.sol";

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

// Utils
import { Permit2Utils } from "./Permit2Utils.sol";
import { PauseUtils } from "./PauseUtils.sol";

/// @title BalancerV2Utils
/// @notice A contract containing common utilities for BalancerV2 swaps
abstract contract BalancerV2Utils is AugustusFees, Permit2Utils, PauseUtils {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Emitted when the passed selector is invalid
    error InvalidSelector();

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev BalancerV2 vault address
    address payable public immutable BALANCER_VAULT; // solhint-disable-line var-name-mixedcase

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address payable _balancerVault) {
        BALANCER_VAULT = _balancerVault;
    }

    /*//////////////////////////////////////////////////////////////
                                 INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Decode srcToken, destToken from balancerData, beneficiary and approve flag from beneficiaryAndApproveFlag
    function _decodeBalancerV2Params(
        uint256 beneficiaryAndApproveFlag,
        bytes calldata balancerData
    )
        internal
        pure
        returns (IERC20 srcToken, IERC20 destToken, address payable beneficiary, bool approve)
    {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            // Parse beneficiaryAndApproveFlag
            beneficiary := and(beneficiaryAndApproveFlag, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            approve := shr(255, beneficiaryAndApproveFlag)
            // Load calldata without selector
            let callDataWithoutSelector := add(4, balancerData.offset)
            // Check selector
            switch calldataload(balancerData.offset)
            // If the selector is for swap(tuple singleSwap,tuple funds,uint256 limit,uint256 deadline)
            case 0x52bbbe2900000000000000000000000000000000000000000000000000000000 {
                // Load srcToken from singleSswap.assetIn
                srcToken := calldataload(add(callDataWithoutSelector, 288))
                // Load destToken from singleSswap.assetOut
                destToken := calldataload(add(callDataWithoutSelector, 320))
            }
            // If the selector is for batchSwap(uint8 kind,tuple[] swaps,address[] assets,tuple funds,int256[]
            // limits,uint256 deadline)
            case 0x945bcec900000000000000000000000000000000000000000000000000000000 {
                // Load assetOffset from balancerData
                let assetsOffset := calldataload(add(callDataWithoutSelector, 64))
                // Load assetCount at assetOffset
                let assetsCount := calldataload(add(callDataWithoutSelector, assetsOffset))
                // Get swapExactAmountIn type from first 32 bytes of balancerData
                let swapType := calldataload(callDataWithoutSelector)
                // Set fromAmount, srcToken, toAmount and destToken based on swapType
                switch eq(swapType, 1)
                case 1 {
                    // Load srcToken as the last asset in balancerData.assets
                    srcToken := calldataload(add(callDataWithoutSelector, add(assetsOffset, mul(assetsCount, 32))))
                    // Load destToken as the first asset in balancerData.assets
                    destToken := calldataload(add(callDataWithoutSelector, add(assetsOffset, 32)))
                }
                default {
                    // Load srcToken as the first asset in balancerData.assets
                    srcToken := calldataload(add(callDataWithoutSelector, add(assetsOffset, 32)))
                    // Load destToken as the last asset in balancerData.assets
                    destToken := calldataload(add(callDataWithoutSelector, add(assetsOffset, mul(assetsCount, 32))))
                }
            }
            default {
                // If the selector is invalid, revert
                mstore(0, 0x7352d91c00000000000000000000000000000000000000000000000000000000) // store the
                    // selector for error InvalidSelector();
                revert(0, 4)
            }
            // Balancer users 0x0 as ETH address so we need to convert it
            if eq(srcToken, 0) { srcToken := 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE }
            if eq(destToken, 0) { destToken := 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE }
        }
        return (srcToken, destToken, beneficiary, approve);
    }

    /// @dev Call balancerVault with data
    function _callBalancerV2(bytes calldata balancerData) internal {
        address payable targetAddress = BALANCER_VAULT;
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            // Load free memory pointer
            let ptr := mload(64)
            // Copy the balancerData to memory
            calldatacopy(ptr, balancerData.offset, balancerData.length)
            // Execute the call on balancerVault
            if iszero(call(gas(), targetAddress, callvalue(), ptr, balancerData.length, 0, 0)) {
                returndatacopy(ptr, 0, returndatasize()) // copy the revert data to memory
                revert(ptr, returndatasize()) // revert with the revert data
            }
        }
    }
}
