// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import "../../errors/SocketErrors.sol";
import {BridgeImplBase} from "../BridgeImplBase.sol";
import {IMayanForwarderContract} from "./interfaces/IMayan.sol";

/**
 * @title Mayan Bridge Implementation
 * @notice Route implementation with functions to bridge ERC20 and Native via Mayan Bridge
 * Called via SocketGateway if the routeId in the request maps to the routeId of Mayan Bridge Implementation
 * Contains function to handle bridging as post-step i.e linked to a preceeding step for swap
 * RequestData is different to just bride and bridging chained with swap
 * @author Socket dot tech.
 */
contract MayanBridgeImpl is BridgeImplBase {
    /// @notice SafeTransferLib - library for safe and optimised operations on ERC20 tokens
    using SafeTransferLib for ERC20;

    bytes32 public immutable MayanBridgeIdentifier = keccak256("MayanBridge");
    /// @notice max value for uint256
    uint256 private constant UINT256_MAX = type(uint256).max;

    /// @notice Function-selector for ERC20-token bridging on Mayan-Route
    /// @dev This function selector is to be used while buidling transaction-data to bridge ERC20 tokens
    bytes4 public immutable MAYAN_ERC20_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeERC20To(address,uint256,(address,bytes32,uint256,bytes,address,bool,bytes32))"
            )
        );

    /// @notice Function-selector for Native bridging on Mayan-Route
    /// @dev This function selector is to be used while buidling transaction-data to bridge Native tokens
    bytes4 public immutable MAYAN_NATIVE_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeNativeTo(uint256,(address,bytes32,uint256,bytes,address,bool,bytes32))"
            )
        );

    bytes4 public immutable MAYAN_SWAP_BRIDGE_SELECTOR =
        bytes4(
            keccak256(
                "swapAndBridge(uint32,bytes,(address,bytes32,uint256,bytes,address,bool,bytes32))"
            )
        );

    IMayanForwarderContract public immutable mayanForwarderContract;

    /// @notice socketGatewayAddress to be initialised via storage variable BridgeImplBase
    /// @dev ensure router, routerEth are set properly for the chainId in which the contract is being deployed
    constructor(
        address _mayanForwarderContract,
        address _socketGateway,
        address _socketDeployFactory
    ) BridgeImplBase(_socketGateway, _socketDeployFactory) {
        mayanForwarderContract = IMayanForwarderContract(
            _mayanForwarderContract
        );
    }

    event SocketNonEvmDestBridge(
        uint256 amount,
        address token,
        uint256 toChainId,
        bytes32 bridgeName,
        address sender,
        bytes32 receiver,
        bytes32 metadata
    );

    struct BridgeDataWithToken {
        address receiver;
        bytes32 metadata;
        uint256 toChainId;
        address token;
        bytes protocolData; // Mayan protocol data
        address mayanProtocolAddress; // Final mayan contract where protocol data is excecuted
        bool isNonEvmDest;
        bytes32 nonEvmAddress;
    }

    struct BridgeDataWithNoToken {
        address receiver;
        bytes32 metadata;
        uint256 toChainId;
        bytes protocolData; // Mayan protocol data
        address mayanProtocolAddress; // Final mayan contract where protocol data is excecuted
        bool isNonEvmDest;
        bytes32 nonEvmAddress;
    }

    /**
     * @notice function to handle ERC20 bridging to receipent via mayan bridge
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @param token address of token being bridged
     * @param amount amount of token being bridge
     * @param mayanBridgeData mayan bridge extradata
     */
    function bridgeERC20To(
        address token,
        uint256 amount,
        BridgeDataWithNoToken calldata mayanBridgeData
    ) external payable {
        ERC20(token).safeTransferFrom(msg.sender, socketGateway, amount);
        if (
            amount >
            ERC20(token).allowance(
                address(this),
                address(mayanForwarderContract)
            )
        ) {
            ERC20(token).safeApprove(
                address(mayanForwarderContract),
                UINT256_MAX
            );
        }

        mayanForwarderContract.forwardERC20(
            token,
            amount,
            IMayanForwarderContract.PermitParams(0, 0, 0, 0, 0),
            mayanBridgeData.mayanProtocolAddress,
            mayanBridgeData.protocolData
        );

        if (mayanBridgeData.isNonEvmDest) {
            emit SocketNonEvmDestBridge(
                amount,
                token,
                mayanBridgeData.toChainId,
                MayanBridgeIdentifier,
                msg.sender,
                mayanBridgeData.nonEvmAddress,
                mayanBridgeData.metadata
            );
            return;
        }

        emit SocketBridge(
            amount,
            token,
            mayanBridgeData.toChainId,
            MayanBridgeIdentifier,
            msg.sender,
            mayanBridgeData.receiver,
            mayanBridgeData.metadata
        );
    }

    /**
     * @notice function to handle Native bridging to receipent via Mayan Bridge
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @param amount amount to be sent
     * @param mayanBridgeData mayan bridge extradata
     */
    function bridgeNativeTo(
        uint256 amount,
        BridgeDataWithNoToken calldata mayanBridgeData
    ) external payable {
        mayanForwarderContract.forwardEth{value: amount}(
            mayanBridgeData.mayanProtocolAddress,
            mayanBridgeData.protocolData
        );

        if (mayanBridgeData.isNonEvmDest) {
            emit SocketNonEvmDestBridge(
                amount,
                NATIVE_TOKEN_ADDRESS,
                mayanBridgeData.toChainId,
                MayanBridgeIdentifier,
                msg.sender,
                mayanBridgeData.nonEvmAddress,
                mayanBridgeData.metadata
            );
            return;
        }

        emit SocketBridge(
            amount,
            NATIVE_TOKEN_ADDRESS,
            mayanBridgeData.toChainId,
            MayanBridgeIdentifier,
            msg.sender,
            mayanBridgeData.receiver,
            mayanBridgeData.metadata
        );
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from bridgeAfterSwap since this function holds the logic for swapping tokens too.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in BridgeDataWithNoToken struct
     * @param swapId routeId for the swapImpl
     * @param swapData encoded data for swap
     * @param mayanBridgeData encoded data for MayanBridge
     */
    function swapAndBridge(
        uint32 swapId,
        bytes calldata swapData,
        BridgeDataWithNoToken calldata mayanBridgeData
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
            mayanForwarderContract.forwardEth{value: bridgeAmount}(
                mayanBridgeData.mayanProtocolAddress,
                mayanBridgeData.protocolData
            );

            if (mayanBridgeData.isNonEvmDest) {
                emit SocketNonEvmDestBridge(
                    bridgeAmount,
                    token,
                    mayanBridgeData.toChainId,
                    MayanBridgeIdentifier,
                    msg.sender,
                    mayanBridgeData.nonEvmAddress,
                    mayanBridgeData.metadata
                );
                return;
            }
            emit SocketBridge(
                bridgeAmount,
                token,
                mayanBridgeData.toChainId,
                MayanBridgeIdentifier,
                msg.sender,
                mayanBridgeData.receiver,
                mayanBridgeData.metadata
            );
        } else {
            if (
                bridgeAmount >
                ERC20(token).allowance(
                    address(this),
                    address(mayanForwarderContract)
                )
            ) {
                ERC20(token).safeApprove(
                    address(mayanForwarderContract),
                    UINT256_MAX
                );
            }

            mayanForwarderContract.forwardERC20(
                token,
                bridgeAmount,
                IMayanForwarderContract.PermitParams(0, 0, 0, 0, 0),
                mayanBridgeData.mayanProtocolAddress,
                replaceMiddleAmount(mayanBridgeData.protocolData, bridgeAmount)
            );

            if (mayanBridgeData.isNonEvmDest) {
                emit SocketNonEvmDestBridge(
                    bridgeAmount,
                    token,
                    mayanBridgeData.toChainId,
                    MayanBridgeIdentifier,
                    msg.sender,
                    mayanBridgeData.nonEvmAddress,
                    mayanBridgeData.metadata
                );
                return;
            }

            emit SocketBridge(
                bridgeAmount,
                token,
                mayanBridgeData.toChainId,
                MayanBridgeIdentifier,
                msg.sender,
                mayanBridgeData.receiver,
                mayanBridgeData.metadata
            );
        }
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from swapAndBridge, this function is called when the swap has already happened at a different place.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in BridgeDataWithToken struct
     * @param amount amount of tokens being bridged. this can be ERC20 or native
     * @param bridgeData encoded data for Mayan bridge
     */
    function bridgeAfterSwap(
        uint256 amount,
        bytes calldata bridgeData
    ) external payable override {
        BridgeDataWithToken memory mayanBridgeData = abi.decode(
            bridgeData,
            (BridgeDataWithToken)
        );

        if (mayanBridgeData.token == NATIVE_TOKEN_ADDRESS) {
            mayanForwarderContract.forwardEth{value: amount}(
                mayanBridgeData.mayanProtocolAddress,
                mayanBridgeData.protocolData
            );

            if (mayanBridgeData.isNonEvmDest) {
                emit SocketNonEvmDestBridge(
                    amount,
                    NATIVE_TOKEN_ADDRESS,
                    mayanBridgeData.toChainId,
                    MayanBridgeIdentifier,
                    msg.sender,
                    mayanBridgeData.nonEvmAddress,
                    mayanBridgeData.metadata
                );
                return;
            }

            emit SocketBridge(
                amount,
                NATIVE_TOKEN_ADDRESS,
                mayanBridgeData.toChainId,
                MayanBridgeIdentifier,
                msg.sender,
                mayanBridgeData.receiver,
                mayanBridgeData.metadata
            );
        } else {
            if (
                amount >
                ERC20(mayanBridgeData.token).allowance(
                    address(this),
                    address(mayanForwarderContract)
                )
            ) {
                ERC20(mayanBridgeData.token).safeApprove(
                    address(mayanForwarderContract),
                    UINT256_MAX
                );
            }

            mayanForwarderContract.forwardERC20(
                mayanBridgeData.token,
                amount,
                IMayanForwarderContract.PermitParams(0, 0, 0, 0, 0),
                mayanBridgeData.mayanProtocolAddress,
                replaceMiddleAmountMemory(mayanBridgeData.protocolData, amount)
            );

            if (mayanBridgeData.isNonEvmDest) {
                emit SocketNonEvmDestBridge(
                    amount,
                    mayanBridgeData.token,
                    mayanBridgeData.toChainId,
                    MayanBridgeIdentifier,
                    msg.sender,
                    mayanBridgeData.nonEvmAddress,
                    mayanBridgeData.metadata
                );
                return;
            }

            emit SocketBridge(
                amount,
                mayanBridgeData.token,
                mayanBridgeData.toChainId,
                MayanBridgeIdentifier,
                msg.sender,
                mayanBridgeData.receiver,
                mayanBridgeData.metadata
            );
        }
    }
    /**
     * @notice This contract will not use wormhole method when using mayan bridge, as the bridge amount
     * is not placed at a fixed position in the call data
     **/
    function replaceMiddleAmount(
        bytes calldata mayanData,
        uint256 middleAmount
    ) internal pure returns (bytes memory) {
        require(mayanData.length >= 68, "Mayan data too short");
        bytes memory modifiedData = new bytes(mayanData.length);

        bytes4 functionSelector = bytes4(mayanData[0]) |
            (bytes4(mayanData[1]) >> 8) |
            (bytes4(mayanData[2]) >> 16) |
            (bytes4(mayanData[3]) >> 24);

        uint256 amountIndex;
        // Only the wh swap method has the amount as last argument
        bytes4 swapSelector = 0x6111ad25;
        if (functionSelector == swapSelector) {
            amountIndex = mayanData.length - 256;
        } else {
            amountIndex = 36;
        }

        // Copy the function selector and token in
        for (uint i = 0; i < amountIndex; i++) {
            modifiedData[i] = mayanData[i];
        }

        // Encode the amount and place it into the modified call data
        // Starting from byte 36 to byte 67 (32 bytes for uint256)
        for (uint i = 0; i < 32; i++) {
            modifiedData[i + amountIndex] = abi.encode(middleAmount)[i];
        }

        // Copy the rest of the original data after the first argument
        for (uint i = 68; i < mayanData.length; i++) {
            modifiedData[i] = mayanData[i];
        }

        return modifiedData;
    }

    function replaceMiddleAmountMemory(
        bytes memory mayanData,
        uint256 middleAmount
    ) internal pure returns (bytes memory) {
        require(mayanData.length >= 68, "Mayan data too short");
        bytes memory modifiedData = new bytes(mayanData.length);

        bytes4 functionSelector = bytes4(mayanData[0]) |
            (bytes4(mayanData[1]) >> 8) |
            (bytes4(mayanData[2]) >> 16) |
            (bytes4(mayanData[3]) >> 24);

        uint256 amountIndex;
        // Only the wh swap method has the amount as last argument
        bytes4 swapSelector = 0x6111ad25;
        if (functionSelector == swapSelector) {
            amountIndex = mayanData.length - 256;
        } else {
            amountIndex = 36;
        }

        // Copy the function selector and token in
        for (uint i = 0; i < amountIndex; i++) {
            modifiedData[i] = mayanData[i];
        }

        // Encode the amount and place it into the modified call data
        // Starting from byte 36 to byte 67 (32 bytes for uint256)
        for (uint i = 0; i < 32; i++) {
            modifiedData[i + amountIndex] = abi.encode(middleAmount)[i];
        }

        // Copy the rest of the original data after the first argument
        for (uint i = 68; i < mayanData.length; i++) {
            modifiedData[i] = mayanData[i];
        }

        return modifiedData;
    }
}
