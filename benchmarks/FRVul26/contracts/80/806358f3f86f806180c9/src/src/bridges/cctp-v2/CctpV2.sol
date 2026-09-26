// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {TokenMessengerV2} from "./interfaces/cctpV2.sol";
import "../BridgeImplBase.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {CCTP_V2} from "../../static/RouteIdentifiers.sol";

/**
 * @title CCTP-V2-Route Implementation
 * @notice Route implementation with functions to bridge ERC20 and Native via CCTP V2
 * Called via SocketGateway if the routeId in the request maps to the routeId of CctpV2Impl
 * Contains function to handle bridging as post-step i.e linked to a preceeding step for swap
 * RequestData is different to just bride and bridging chained with swap
 * @author Socket dot tech.
 */
contract CctpV2Impl is BridgeImplBase {
    /// @notice SafeTransferLib - library for safe and optimised operations on ERC20 tokens
    using SafeTransferLib for ERC20;

    bytes32 public immutable cctpV2Identifier = CCTP_V2;

    /// @notice Function-selector for ERC20-token bridging on CCTP V2
    /// @dev This function selector is to be used while buidling transaction-data to bridge ERC20 tokens

    bytes4 public immutable CCTP_V2_ERC20_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        CctpV2Impl.bridgeERC20To.selector;

    bytes4 public immutable CCTP_V2_SWAP_BRIDGE_SELECTOR =
        CctpV2Impl.swapAndBridge.selector;

    TokenMessengerV2 public immutable tokenMessenger;
    address public immutable feeCollector;

    /// @notice socketGatewayAddress to be initialised via storage variable BridgeImplBase
    constructor(
        address _tokenMessenger,
        address _feeCollector,
        address _socketGateway,
        address _socketDeployFactory
    ) BridgeImplBase(_socketGateway, _socketDeployFactory) {
        tokenMessenger = TokenMessengerV2(_tokenMessenger);
        feeCollector = _feeCollector;
    }

    /// @notice Struct to be used in decode step from input parameter - a specific case of bridging after swap.
    /// @dev the data being encoded in offchain or by caller should have values set in this sequence of properties in this struct
    struct CctpData {
        /// @notice address of token being bridged
        address token;
        /// @notice address of receiver
        address receiverAddress;
        /// @notice destination domain
        uint32 destinationDomain;
        /// @notice chainId of destination
        uint256 toChainId;
        /// @notice fee amount
        uint256 feeAmount;
        /// @notice maxFee payable for Fast Transfers
        uint256 maxFee;
        /// @notice minFinalityThreshold for attestation
        uint32 minFinalityThreshold;
        /// @notice socket offchain created hash
        bytes32 metadata;
    }

    struct CctpDataNoToken {
        address receiverAddress;
        uint32 destinationDomain;
        uint256 toChainId;
        uint256 feeAmount;
        uint256 maxFee;
        uint32 minFinalityThreshold;
        bytes32 metadata;
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from swapAndBridge, this function is called when the swap has already happened at a different place.
     * @notice This method is payable because the caller is doing token transfer and bridging operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in CctpData struct
     * @param amount amount of tokens being bridged. this can be ERC20 or native
     * @param bridgeData encoded data for CctpData
     */
    function bridgeAfterSwap(
        uint256 amount,
        bytes calldata bridgeData
    ) external payable override {
        CctpData memory cctpData = abi.decode(bridgeData, (CctpData));

        if (cctpData.token == NATIVE_TOKEN_ADDRESS) {
            revert("Native token not supported");
        } else {
            ERC20(cctpData.token).transfer(feeCollector, cctpData.feeAmount);

            // approve allowance if not enough
            if (
                amount >
                ERC20(cctpData.token).allowance(
                    address(this),
                    address(tokenMessenger)
                )
            ) {
                ERC20(cctpData.token).safeApprove(
                    address(tokenMessenger),
                    type(uint256).max
                );
            }

            tokenMessenger.depositForBurn(
                amount - cctpData.feeAmount,
                cctpData.destinationDomain,
                bytes32(uint256(uint160(cctpData.receiverAddress))),
                cctpData.token,
                bytes32(0), // allow any address to broadcast the message
                cctpData.maxFee,
                cctpData.minFinalityThreshold
            );
        }

        emit SocketBridge(
            amount,
            cctpData.token,
            cctpData.toChainId,
            cctpV2Identifier,
            msg.sender,
            cctpData.receiverAddress,
            cctpData.metadata
        );
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from bridgeAfterSwap since this function holds the logic for swapping tokens too.
     * @notice This method is payable because the caller is doing token transfer and bridging operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in CctpDataNoToken struct
     * @param swapId routeId for the swapImpl
     * @param swapData encoded data for swap
     * @param cctpData encoded data for cctpData
     */
    function swapAndBridge(
        uint32 swapId,
        bytes calldata swapData,
        CctpDataNoToken calldata cctpData
    ) external payable {
        (bool success, bytes memory result) = socketRoute
            .getRoute(swapId)
            .delegatecall(swapData);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }

        (uint256 bridgeAmount, address token) = abi.decode(
            result,
            (uint256, address)
        );
        if (token == NATIVE_TOKEN_ADDRESS) {
            revert("Native token not supported");
        } else {
            ERC20(token).transfer(feeCollector, cctpData.feeAmount);

            // approve allowance if not enough
            if (
                bridgeAmount >
                ERC20(token).allowance(address(this), address(tokenMessenger))
            ) {
                ERC20(token).safeApprove(
                    address(tokenMessenger),
                    type(uint256).max
                );
            }

            tokenMessenger.depositForBurn(
                bridgeAmount - cctpData.feeAmount,
                cctpData.destinationDomain,
                bytes32(uint256(uint160(cctpData.receiverAddress))),
                token,
                bytes32(0), // allow any address to broadcast the message
                cctpData.maxFee,
                cctpData.minFinalityThreshold
            );
        }

        emit SocketBridge(
            bridgeAmount,
            token,
            cctpData.toChainId,
            cctpV2Identifier,
            msg.sender,
            cctpData.receiverAddress,
            cctpData.metadata
        );
    }

    /**
     * @notice function to handle ERC20 bridging to recipient via CCTP V2
     * @notice This method is payable because the caller is doing token transfer and bridging operation
     * @param amount amount to be sent
     * @param receiverAddress address of the token to bridged to the destination chain.
     * @param token address of token being bridged
     * @param toChainId chainId of destination
     */
    function bridgeERC20To(
        uint256 amount,
        bytes32 metadata,
        address receiverAddress,
        address token,
        uint256 toChainId,
        uint32 destinationDomain,
        uint256 feeAmount,
        uint256 maxFee,
        uint32 minFinalityThreshold
    ) external payable {
        ERC20 tokenInstance = ERC20(token);
        tokenInstance.safeTransferFrom(msg.sender, socketGateway, amount);
        tokenInstance.transfer(feeCollector, feeAmount);

        // approve allowance if not enough
        if (
            amount >
            ERC20(token).allowance(address(this), address(tokenMessenger))
        ) {
            ERC20(token).safeApprove(
                address(tokenMessenger),
                type(uint256).max
            );
        }

        tokenMessenger.depositForBurn(
            amount - feeAmount,
            destinationDomain,
            bytes32(uint256(uint160(receiverAddress))),
            token,
            bytes32(0), // allow any address to broadcast the message
            maxFee,
            minFinalityThreshold
        );

        emit SocketBridge(
            amount,
            token,
            toChainId,
            cctpV2Identifier,
            msg.sender,
            receiverAddress,
            metadata
        );
    }
}
