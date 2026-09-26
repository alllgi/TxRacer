// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/ICctpL2.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {BridgeImplBase} from "../../BridgeImplBase.sol";
import {HOP} from "../../../static/RouteIdentifiers.sol";

/**
 * @title Hop-L2 Route Implementation
 * @notice This is the L2 implementation, so this is used when transferring from l2 to supported l2s
 * Called via SocketGateway if the routeId in the request maps to the routeId of HopL2-Implementation
 * Contains function to handle bridging as post-step i.e linked to a preceeding step for swap
 * RequestData is different to just bride and bridging chained with swap
 * @author Socket dot tech.
 */
contract HopCctpImpl is BridgeImplBase {
    /// @notice SafeTransferLib - library for safe and optimised operations on ERC20 tokens
    using SafeTransferLib for ERC20;

    bytes32 public immutable HopIdentifier = HOP;

    /// @notice max value for uint256
    uint256 private constant UINT256_MAX = type(uint256).max;

    /// @notice Function-selector for ERC20-token bridging on Hop-L2-Route
    /// @dev This function selector is to be used while buidling transaction-data to bridge ERC20 tokens
    bytes4
        public immutable HOP_CCTP_L2_ERC20_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeERC20To((uint256,address,uint256,uint256,bytes,uint256,address,bool,bytes32))"
            )
        );

    bytes4 public immutable HOP_CCTP_L2_SWAP_BRIDGE_SELECTOR =
        bytes4(
            keccak256(
                "swapAndBridge(uint32,bytes,(uint256,address,uint256,uint256,bytes,uint256,address,bool,bytes32))"
            )
        );

    HopCctpBridge private immutable hopCctpBridge;

    /// @notice socketGatewayAddress to be initialised via storage variable BridgeImplBase
    constructor(
        address _hopCctpBridge,
        address _socketGateway,
        address _socketDeployFactory
    ) BridgeImplBase(_socketGateway, _socketDeployFactory) {
        hopCctpBridge = HopCctpBridge(_hopCctpBridge);
    }

    struct HopBridgeData {
        // The chainId of the destination chain
        uint256 toChainId;
        // The address receiving funds at the destination
        address recipient;
        // amount is the amount the user wants to send plus the Bonder fee
        uint256 amount;
        // fees passed to relayer
        uint256 bonderFee;
        // route identifier for
        bytes path;
        // The minimum amount received after attempting to swap in the destination AMM market. 0 if no swap is intended.
        uint256 amountOutMin;
        /// @notice address of token being bridged
        address token;
        bool isSwapTx;
        bytes32 metadata;
    }

    /**
     * @param hopBridgeData extraData for Bridging across Hop-L2
     */
    function bridgeERC20To(
        HopBridgeData calldata hopBridgeData
    ) external payable {
        ERC20 tokenInstance = ERC20(hopBridgeData.token);
        tokenInstance.safeTransferFrom(
            msg.sender,
            socketGateway,
            hopBridgeData.amount
        );

        if (
            hopBridgeData.amount >
            ERC20(hopBridgeData.token).allowance(
                address(this),
                address(hopCctpBridge)
            )
        ) {
            ERC20(hopBridgeData.token).safeApprove(
                address(hopCctpBridge),
                UINT256_MAX
            );
        }

        if (hopBridgeData.isSwapTx == true) {
            // USDC.E bridging
            hopCctpBridge.swapAndSend(
                hopBridgeData.toChainId,
                hopBridgeData.recipient,
                hopBridgeData.amount,
                hopBridgeData.bonderFee,
                IAMM.ExactInputParams({
                    path: hopBridgeData.path,
                    recipient: address(hopCctpBridge),
                    amountIn: hopBridgeData.amount,
                    amountOutMinimum: hopBridgeData.amountOutMin
                })
            );
        } else {
            // USDC bridging
            hopCctpBridge.send(
                hopBridgeData.toChainId,
                hopBridgeData.recipient,
                hopBridgeData.amount,
                hopBridgeData.bonderFee
            );
        }

        emit SocketBridge(
            hopBridgeData.amount,
            hopBridgeData.token,
            hopBridgeData.toChainId,
            HopIdentifier,
            msg.sender,
            hopBridgeData.recipient,
            hopBridgeData.metadata
        );
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from swapAndBridge, this function is called when the swap has already happened at a different place.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in HopBridgeData struct
     * @param amount amount of tokens being bridged. this can be ERC20 or native
     * @param bridgeData encoded data for Hop-L2-Bridge
     */
    function bridgeAfterSwap(
        uint256 amount,
        bytes calldata bridgeData
    ) external payable override {
        HopBridgeData memory hopData = abi.decode(bridgeData, (HopBridgeData));

        if (
            amount >
            ERC20(hopData.token).allowance(
                address(this),
                address(hopCctpBridge)
            )
        ) {
            ERC20(hopData.token).safeApprove(
                address(hopCctpBridge),
                UINT256_MAX
            );
        }
        if (hopData.isSwapTx == true) {
            // USDC.E bridging
            hopCctpBridge.swapAndSend(
                hopData.toChainId,
                hopData.recipient,
                amount,
                hopData.bonderFee,
                IAMM.ExactInputParams({
                    path: hopData.path,
                    recipient: address(hopCctpBridge),
                    amountIn: amount,
                    amountOutMinimum: hopData.amountOutMin
                })
            );
        } else {
            // USDC bridging
            hopCctpBridge.send(
                hopData.toChainId,
                hopData.recipient,
                amount,
                hopData.bonderFee
            );
        }

        emit SocketBridge(
            amount,
            hopData.token,
            hopData.toChainId,
            HopIdentifier,
            msg.sender,
            hopData.recipient,
            hopData.metadata
        );
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from bridgeAfterSwap since this function holds the logic for swapping tokens too.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in HopBridgeData struct
     * @param swapId routeId for the swapImpl
     * @param swapData encoded data for swap
     * @param hopData encoded data for HopData
     */
    function swapAndBridge(
        uint32 swapId,
        bytes calldata swapData,
        HopBridgeData calldata hopData
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

        if (
            bridgeAmount >
            ERC20(token).allowance(address(this), address(hopCctpBridge))
        ) {
            ERC20(token).safeApprove(address(hopCctpBridge), UINT256_MAX);
        }

        if (hopData.isSwapTx == true) {
            // USDC.E bridging
            hopCctpBridge.swapAndSend(
                hopData.toChainId,
                hopData.recipient,
                bridgeAmount,
                hopData.bonderFee,
                IAMM.ExactInputParams({
                    path: hopData.path,
                    recipient: address(hopCctpBridge),
                    amountIn: bridgeAmount,
                    amountOutMinimum: hopData.amountOutMin
                })
            );
        } else {
            // USDC bridging
            hopCctpBridge.send(
                hopData.toChainId,
                hopData.recipient,
                bridgeAmount,
                hopData.bonderFee
            );
        }

        emit SocketBridge(
            bridgeAmount,
            token,
            hopData.toChainId,
            HopIdentifier,
            msg.sender,
            hopData.recipient,
            hopData.metadata
        );
    }
}
