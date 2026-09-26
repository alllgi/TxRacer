// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import "../../errors/SocketErrors.sol";
import {BridgeImplBase} from "../BridgeImplBase.sol";
import {STARGATE} from "../../static/RouteIdentifiers.sol";
import {IStargate} from "./interfaces/v2/Stargate.sol";

contract StargateImplV2 is BridgeImplBase {
    /// @notice SafeTransferLib - library for safe and optimised operations on ERC20 tokens
    using SafeTransferLib for ERC20;

    bytes32 public immutable StargateIdentifier = STARGATE;
    /// @notice max value for uint256
    uint256 private constant UINT256_MAX = type(uint256).max;

    /// @notice Function-selector for ERC20-token bridging on Stargate-V2
    /// @dev This function selector is to be used while buidling transaction-data to bridge ERC20 tokens
    bytes4
        public immutable STARGATE_V2_ERC20_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeERC20To(address,uint256,(uint32,uint256,address,bytes,bytes,(uint256,uint256),bytes32,uint256,address,bytes,uint32,bool))"
            )
        );

    /// @notice Function-selector for Native bridging on Stargate-V2
    /// @dev This function selector is to be used while building transaction-data to bridge Native tokens
    bytes4
        public immutable STARGATE_V2_NATIVE_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeNativeTo(uint256,(uint32,uint256,address,bytes,bytes,(uint256,uint256),bytes32,uint256,address,bytes,uint32,bool))"
            )
        );

    bytes4 public immutable STARGATE_V2_SWAP_BRIDGE_SELECTOR =
        bytes4(
            keccak256(
                "swapAndBridge(uint32,bytes,(uint32,uint256,address,bytes,bytes,(uint256,uint256),bytes32,uint256,address,bytes,uint32,bool))"
            )
        );

    /// @notice socketGatewayAddress to be initialised via storage variable BridgeImplBase
    /// @dev ensure router, routerEth are set properly for the chainId in which the contract is being deployed
    constructor(
        address _socketGateway,
        address _socketDeployFactory
    ) BridgeImplBase(_socketGateway, _socketDeployFactory) {}

    // /// @notice Struct to be used as a input parameter for Bridging tokens via Stargate-L2-route
    // /// @dev while building transactionData,values should be set in this sequence of properties in this struct
    struct StargateBridgeDataWithToken {
        uint32 dstEid; // Destination endpoint ID.
        uint256 minAmountLD; // Minimum amount to send in local decimals.
        address stargatePoolAddress; // src Pool id for the bridging asset
        bytes destinationPayload; // action to execute on dest chain
        bytes destinationExtraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
        IStargate.MessagingFee messagingFee; // Message fee
        bytes32 metadata; // socket metadata
        uint256 toChainId; // destination chain id
        address token; // token to be bridged
        address receiver; // recipient
        bytes swapData;
        uint32 swapId;
        bool isNativeSwapRequired;
    }

    // /// @notice Struct to be used as a input parameter for Bridging tokens via Stargate V2
    // /// @dev while building transactionData,values should be set in this sequence of properties in this struct
    struct StargateBridgeDataNoToken {
        uint32 dstEid; // Destination endpoint ID.
        uint256 minAmountLD; // Minimum amount to send in local decimals.
        address stargatePoolAddress; // src Pool id for the bridging asset
        bytes destinationPayload; // action to execute on dest chain
        bytes destinationExtraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
        IStargate.MessagingFee messagingFee; // Message fee
        bytes32 metadata; // socket metadata
        uint256 toChainId; // destination chain id
        address receiver; // recipient
        bytes swapData;
        uint32 swapId;
        bool isNativeSwapRequired;
    }

    /**
     * @notice function to handle ERC20 bridging to receipent via Stargate V2
     * @param amount amount of token being bridge
     * @param stargateBridgeData stargate bridge extradata
     */
    function bridgeERC20To(
        address token,
        uint256 amount,
        StargateBridgeDataNoToken calldata stargateBridgeData
    ) external payable {
        ERC20(token).safeTransferFrom(msg.sender, socketGateway, amount);

        if (stargateBridgeData.isNativeSwapRequired) {
            _performNativeSwap(
                stargateBridgeData.swapData,
                stargateBridgeData.swapId,
                stargateBridgeData.messagingFee.nativeFee
            );
        }

        if (
            amount >
            ERC20(token).allowance(
                address(socketGateway),
                address(stargateBridgeData.stargatePoolAddress)
            )
        ) {
            ERC20(token).safeApprove(
                address(stargateBridgeData.stargatePoolAddress),
                UINT256_MAX
            );
        }

        IStargate.SendParam memory sendParam = IStargate.SendParam({
            dstEid: stargateBridgeData.dstEid,
            to: bytes32(uint256(uint160(stargateBridgeData.receiver))),
            amountLD: amount,
            minAmountLD: stargateBridgeData.minAmountLD,
            extraOptions: stargateBridgeData.destinationExtraOptions,
            composeMsg: stargateBridgeData.destinationPayload,
            oftCmd: ""
        });

        IStargate(stargateBridgeData.stargatePoolAddress).sendToken{
            value: stargateBridgeData.messagingFee.nativeFee
        }(sendParam, stargateBridgeData.messagingFee, msg.sender);

        emit NativeBridgeFee(stargateBridgeData.messagingFee.nativeFee);

        emit SocketBridge(
            amount,
            token,
            stargateBridgeData.toChainId,
            StargateIdentifier,
            msg.sender,
            stargateBridgeData.receiver,
            stargateBridgeData.metadata
        );
    }

    /**
     * @notice function to handle ERC20 bridging to recipient via Stargate V2
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @param amount bridge amount
     * @param stargateBridgeData additional bridging info
     */

    function bridgeNativeTo(
        uint256 amount,
        StargateBridgeDataNoToken calldata stargateBridgeData
    ) external payable {
        IStargate.SendParam memory sendParam = IStargate.SendParam({
            dstEid: stargateBridgeData.dstEid,
            to: bytes32(uint256(uint160(stargateBridgeData.receiver))),
            amountLD: amount,
            minAmountLD: stargateBridgeData.minAmountLD,
            extraOptions: stargateBridgeData.destinationExtraOptions,
            composeMsg: stargateBridgeData.destinationPayload,
            oftCmd: ""
        });

        IStargate(stargateBridgeData.stargatePoolAddress).sendToken{
            value: stargateBridgeData.messagingFee.nativeFee + amount
        }(sendParam, stargateBridgeData.messagingFee, msg.sender);

        emit NativeBridgeFee(stargateBridgeData.messagingFee.nativeFee);

        emit SocketBridge(
            amount,
            NATIVE_TOKEN_ADDRESS,
            stargateBridgeData.toChainId,
            StargateIdentifier,
            msg.sender,
            stargateBridgeData.receiver,
            stargateBridgeData.metadata
        );
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from swapAndBridge, this function is called when the swap has already happened at a different place.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in StargateBridgeDataWithToken struct
     * @param amount amount of tokens being bridged. this can be ERC20 or native
     * @param bridgeData encoded data for Stargate V2
     */
    function bridgeAfterSwap(
        uint256 amount,
        bytes calldata bridgeData
    ) external payable override {
        StargateBridgeDataWithToken memory stargateBridgeData = abi.decode(
            bridgeData,
            (StargateBridgeDataWithToken)
        );

        if (stargateBridgeData.token == NATIVE_TOKEN_ADDRESS) {
            IStargate.SendParam memory sendParam = IStargate.SendParam({
                dstEid: stargateBridgeData.dstEid,
                to: bytes32(uint256(uint160(stargateBridgeData.receiver))),
                amountLD: amount,
                minAmountLD: stargateBridgeData.minAmountLD,
                extraOptions: stargateBridgeData.destinationExtraOptions,
                composeMsg: stargateBridgeData.destinationPayload,
                oftCmd: ""
            });

            IStargate(stargateBridgeData.stargatePoolAddress).sendToken{
                value: stargateBridgeData.messagingFee.nativeFee + amount
            }(sendParam, stargateBridgeData.messagingFee, msg.sender);
        } else {
            if (stargateBridgeData.isNativeSwapRequired) {
                _performNativeSwap(
                    stargateBridgeData.swapData,
                    stargateBridgeData.swapId,
                    stargateBridgeData.messagingFee.nativeFee
                );
            }

            if (
                amount >
                ERC20(stargateBridgeData.token).allowance(
                    address(socketGateway),
                    address(stargateBridgeData.stargatePoolAddress)
                )
            ) {
                ERC20(stargateBridgeData.token).safeApprove(
                    address(stargateBridgeData.stargatePoolAddress),
                    UINT256_MAX
                );
            }

            IStargate.SendParam memory sendParam = IStargate.SendParam({
                dstEid: stargateBridgeData.dstEid,
                to: bytes32(uint256(uint160(stargateBridgeData.receiver))),
                amountLD: amount,
                minAmountLD: stargateBridgeData.minAmountLD,
                extraOptions: stargateBridgeData.destinationExtraOptions,
                composeMsg: stargateBridgeData.destinationPayload,
                oftCmd: ""
            });

            IStargate(stargateBridgeData.stargatePoolAddress).sendToken{
                value: stargateBridgeData.messagingFee.nativeFee
            }(sendParam, stargateBridgeData.messagingFee, msg.sender);
        }

        emit NativeBridgeFee(stargateBridgeData.messagingFee.nativeFee);

        emit SocketBridge(
            amount,
            stargateBridgeData.token,
            stargateBridgeData.toChainId,
            StargateIdentifier,
            msg.sender,
            stargateBridgeData.receiver,
            stargateBridgeData.metadata
        );
    }

    /**
     * @notice function to bridge tokens after swapping.
     * @notice this is different from bridgeAfterSwap since this function holds the logic for swapping tokens too.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in StargateBridgeDataNoToken struct
     * @param swapId routeId for the swapImpl
     * @param swapData encoded data for swap
     * @param stargateBridgeData encoded data for StargateBridgeData
     */
    function swapAndBridge(
        uint32 swapId,
        bytes calldata swapData,
        StargateBridgeDataNoToken calldata stargateBridgeData
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
            IStargate.SendParam memory sendParam = IStargate.SendParam({
                dstEid: stargateBridgeData.dstEid,
                to: bytes32(uint256(uint160(stargateBridgeData.receiver))),
                amountLD: bridgeAmount,
                minAmountLD: stargateBridgeData.minAmountLD,
                extraOptions: stargateBridgeData.destinationExtraOptions,
                composeMsg: stargateBridgeData.destinationPayload,
                oftCmd: ""
            });

            IStargate(stargateBridgeData.stargatePoolAddress).sendToken{
                value: stargateBridgeData.messagingFee.nativeFee + bridgeAmount
            }(sendParam, stargateBridgeData.messagingFee, msg.sender);
        } else {
            if (stargateBridgeData.isNativeSwapRequired) {
                _performNativeSwap(
                    stargateBridgeData.swapData,
                    stargateBridgeData.swapId,
                    stargateBridgeData.messagingFee.nativeFee
                );
            }
            if (
                bridgeAmount >
                ERC20(token).allowance(
                    address(socketGateway),
                    address(stargateBridgeData.stargatePoolAddress)
                )
            ) {
                ERC20(token).safeApprove(
                    address(stargateBridgeData.stargatePoolAddress),
                    UINT256_MAX
                );
            }

            IStargate.SendParam memory sendParam = IStargate.SendParam({
                dstEid: stargateBridgeData.dstEid,
                to: bytes32(uint256(uint160(stargateBridgeData.receiver))),
                amountLD: bridgeAmount,
                minAmountLD: stargateBridgeData.minAmountLD,
                extraOptions: stargateBridgeData.destinationExtraOptions,
                composeMsg: stargateBridgeData.destinationPayload,
                oftCmd: ""
            });

            IStargate(stargateBridgeData.stargatePoolAddress).sendToken{
                value: stargateBridgeData.messagingFee.nativeFee
            }(sendParam, stargateBridgeData.messagingFee, msg.sender);
        }

        emit SocketBridge(
            bridgeAmount,
            token,
            stargateBridgeData.toChainId,
            StargateIdentifier,
            msg.sender,
            stargateBridgeData.receiver,
            stargateBridgeData.metadata
        );
    }

    function _performNativeSwap(
        bytes memory swapData,
        uint32 swapId,
        uint256 valueRequired
    ) private {
        (bool success, bytes memory result) = socketRoute
            .getRoute(swapId)
            .delegatecall(swapData);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }

        (uint256 valueReceived, ) = abi.decode(result, (uint256, address));

        if (valueReceived > valueRequired) {
            tx.origin.call{value: valueReceived - valueRequired}("");
        }
    }
}
