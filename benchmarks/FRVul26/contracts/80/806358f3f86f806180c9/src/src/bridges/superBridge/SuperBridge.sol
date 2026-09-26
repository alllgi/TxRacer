// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ISuperBridge} from "./interfaces/ISuperBridge.sol";
import "../BridgeImplBase.sol";
import {SUPER_BRIDGE} from "../../static/RouteIdentifiers.sol";

/**
 * @title SuperBridge-Route Implementation
 * @notice Route implementation with functions to bridge ERC20 and Native via SuperBridge-Bridge
 * Called via SocketGateway if the routeId in the request maps to the routeId of SuperBridgeImplementation
 * Contains function to handle bridging as post-step i.e linked to a preceding step for swap
 * RequestData is different to just bride and bridging chained with swap
 * @author Socket dot tech.
 */

contract SuperBridgeImpl is BridgeImplBase {
    /// @notice SafeTransferLib - library for safe and optimised operations on ERC20 tokens
    using SafeTransferLib for ERC20;

    /// @notice max value for uint256
    uint256 private constant UINT256_MAX = type(uint256).max;

    bytes32 public immutable bridgeIdentifier = SUPER_BRIDGE;

    /// @notice Function-selector for ERC20-token bridging on Hop-L2-Route
    /// @dev This function selector is to be used while buidling transaction-data to bridge ERC20 tokens
    bytes4
        public immutable SUPER_BRIDGE_ERC20_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeERC20To(uint256,(bytes32,address,address,uint256,uint256,address,address,bytes32,uint256,bytes,bytes))"
            )
        );

    /// @notice Function-selector for Native bridging on Hop-L2-Route
    /// @dev This function selector is to be used while building transaction-data to bridge Native tokens
    bytes4
        public immutable SUPER_BRIDGE_NATIVE_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeNativeTo(uint256,(address,address,uint256,uint256,address,bytes32,uint256,bytes,bytes))"
            )
        );

    bytes4 public immutable SUPER_BRIDGE_SWAP_BRIDGE_SELECTOR =
        bytes4(
            keccak256(
                "swapAndBridge(uint32,bytes,(address,address,uint256,uint256,address,bytes32,uint256,bytes,bytes))"
            )
        );

    struct BridgeData {
        /// @notice super bridge address
        address tokenBridgeAddress;
        /// @notice super bridge connector address
        address connector;
        /// @notice message transfer GasLimit
        uint256 msgGasLimit;
        /// @notice Bridge Fee
        uint256 bridgeFees;
        /// @notice receiver address
        address receiver;
        /// @notice token to be bridged
        address token;
        /// @notice bridge metadata
        bytes32 metadata;
        /// @notice toChainId
        uint256 toChainId;
        bytes execPayload_;
        bytes options_;
    }

    struct BridgeDataNoToken {
        /// @notice super bridge address
        address tokenBridgeAddress;
        /// @notice super bridge connector address
        address connector;
        /// @notice message tranfer GasLimit
        uint256 msgGasLimit;
        /// @notice Bridge Fee
        uint256 bridgeFees;
        /// @notice receiver address
        address receiver;
        /// @notice bridge metadata
        bytes32 metadata;
        /// @notice toChainId
        uint256 toChainId;
        bytes execPayload_;
        bytes options_;
    }

    /// @notice socketGatewayAddress to be initialised via storage variable BridgeImplBase
    /// @dev ensure liquidityPoolManager-address are set properly for the chainId in which the contract is being deployed
    constructor(
        address _socketGateway,
        address _socketDeployFactory
    ) BridgeImplBase(_socketGateway, _socketDeployFactory) {}

    /**
     * @notice function to handle ERC20 bridging to recipient via Super Bridge
     * @notice This method is payable because the caller is doing token transfer and bridging operation
     * @param amount amount to be bridged
     * @param _bridgeData additional bridging info
     */
    function bridgeERC20To(
        uint256 amount,
        BridgeData calldata _bridgeData
    ) external payable {
        ERC20(_bridgeData.token).safeTransferFrom(
            msg.sender,
            socketGateway,
            amount
        );

        if (
            amount >
            ERC20(_bridgeData.token).allowance(
                address(socketGateway),
                address(_bridgeData.tokenBridgeAddress)
            )
        ) {
            ERC20(_bridgeData.token).safeApprove(
                address(_bridgeData.tokenBridgeAddress),
                UINT256_MAX
            );
        }

        ISuperBridge(_bridgeData.tokenBridgeAddress).bridge{
            value: _bridgeData.bridgeFees
        }(
            _bridgeData.receiver,
            amount,
            _bridgeData.msgGasLimit,
            _bridgeData.connector,
            _bridgeData.execPayload_,
            _bridgeData.options_
        );

        emit SocketBridge(
            amount,
            _bridgeData.token,
            _bridgeData.toChainId,
            bridgeIdentifier,
            msg.sender,
            _bridgeData.receiver,
            _bridgeData.metadata
        );
    }

    /**
     * @notice function to handle ERC20 bridging to recipient via Super Bridge
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @param _bridgeData additional bridging info
     */
    function bridgeNativeTo(
        uint256 amount,
        BridgeDataNoToken calldata _bridgeData
    ) external payable {
        ISuperBridge(_bridgeData.tokenBridgeAddress).bridge{
            value: _bridgeData.bridgeFees + amount
        }(
            _bridgeData.receiver,
            amount,
            _bridgeData.msgGasLimit,
            _bridgeData.connector,
            _bridgeData.execPayload_,
            _bridgeData.options_
        );

        emit SocketBridge(
            amount,
            NATIVE_TOKEN_ADDRESS,
            _bridgeData.toChainId,
            bridgeIdentifier,
            msg.sender,
            _bridgeData.receiver,
            _bridgeData.metadata
        );
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from swapAndBridge, this function is called when the swap has already happened at a different place.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in GnosisNativeBridgeData struct
     * @param amount amount of tokens being bridged. this can be ERC20 or native
     * @param bridgeData encoded data for Super Bridge
     */
    function bridgeAfterSwap(
        uint256 amount,
        bytes calldata bridgeData
    ) external payable override {
        BridgeData memory _bridgeData = abi.decode(bridgeData, (BridgeData));

        if (_bridgeData.token == NATIVE_TOKEN_ADDRESS) {
            ISuperBridge(_bridgeData.tokenBridgeAddress).bridge{
                value: _bridgeData.bridgeFees + amount
            }(
                _bridgeData.receiver,
                amount,
                _bridgeData.msgGasLimit,
                _bridgeData.connector,
                _bridgeData.execPayload_,
                _bridgeData.options_
            );
        } else {
            if (
                amount >
                ERC20(_bridgeData.token).allowance(
                    address(socketGateway),
                    address(_bridgeData.tokenBridgeAddress)
                )
            ) {
                ERC20(_bridgeData.token).safeApprove(
                    address(_bridgeData.tokenBridgeAddress),
                    UINT256_MAX
                );
            }

            ISuperBridge(_bridgeData.tokenBridgeAddress).bridge{
                value: _bridgeData.bridgeFees
            }(
                _bridgeData.receiver,
                amount,
                _bridgeData.msgGasLimit,
                _bridgeData.connector,
                _bridgeData.execPayload_,
                _bridgeData.options_
            );
        }

        emit SocketBridge(
            amount,
            _bridgeData.token,
            _bridgeData.toChainId,
            bridgeIdentifier,
            msg.sender,
            _bridgeData.receiver,
            _bridgeData.metadata
        );
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from bridgeAfterSwap since this function holds the logic for swapping tokens too.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in SymbiosisBridgeData struct
     * @param swapId routeId for the swapImpl
     * @param swapData encoded data for swap
     * @param _bridgeData   additional bridge params
     */
    function swapAndBridge(
        uint32 swapId,
        bytes calldata swapData,
        BridgeDataNoToken calldata _bridgeData
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
            ISuperBridge(_bridgeData.tokenBridgeAddress).bridge{
                value: _bridgeData.bridgeFees + bridgeAmount
            }(
                _bridgeData.receiver,
                bridgeAmount,
                _bridgeData.msgGasLimit,
                _bridgeData.connector,
                _bridgeData.execPayload_,
                _bridgeData.options_
            );
        } else {
            if (
                bridgeAmount >
                ERC20(token).allowance(
                    address(this),
                    address(_bridgeData.tokenBridgeAddress)
                )
            ) {
                ERC20(token).safeApprove(
                    address(_bridgeData.tokenBridgeAddress),
                    UINT256_MAX
                );
            }

            ISuperBridge(_bridgeData.tokenBridgeAddress).bridge{
                value: _bridgeData.bridgeFees
            }(
                _bridgeData.receiver,
                bridgeAmount,
                _bridgeData.msgGasLimit,
                _bridgeData.connector,
                _bridgeData.execPayload_,
                _bridgeData.options_
            );
        }

        emit SocketBridge(
            bridgeAmount,
            token,
            _bridgeData.toChainId,
            bridgeIdentifier,
            msg.sender,
            _bridgeData.receiver,
            _bridgeData.metadata
        );
    }
}
