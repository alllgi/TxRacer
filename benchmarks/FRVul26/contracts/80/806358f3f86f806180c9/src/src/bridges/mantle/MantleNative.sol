// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import "./interfaces/mantleNative.sol";
import {BridgeImplBase} from "../BridgeImplBase.sol";

/**
 * @title NativeMantle-Route Implementation
 * @notice Route implementation with functions to bridge ERC20 and Native via NativeMantle-Bridge
 * Tokens are bridged from Ethereum to Mantle Chain.
 * Called via SocketGateway if the routeId in the request maps to the routeId of NativeMantle-Implementation
 * Contains function to handle bridging as post-step i.e linked to a preceeding step for swap
 * RequestData is different to just bride and bridging chained with swap
 * @author Socket dot tech.
 */
contract MantleNativeStack is BridgeImplBase {
    using SafeTransferLib for ERC20;

    uint256 public constant UINT256_MAX = type(uint256).max;

    /// @notice Function-selector for ERC20-token bridging on Native-Mantle
    /// @dev This function selector is to be used while buidling transaction-data to bridge ERC20 tokens
    bytes4
        public immutable NATIVE_MANTLE_ERC20_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeERC20To(address,address,uint32,bytes32,uint256,address,uint256,bytes)"
            )
        );

    /// @notice Function-selector for Native bridging on Native-Mantle
    /// @dev This function selector is to be used while buidling transaction-data to bridge Native balance
    bytes4
        public immutable NATIVE_MANTLE_NATIVE_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeNativeTo(address,uint32,uint256,uint256,bytes32,bytes)"
            )
        );

    bytes4 public immutable NATIVE_MANTLE_SWAP_BRIDGE_SELECTOR =
        bytes4(
            keccak256(
                "swapAndBridge(uint32,bytes,(bytes32,address,uint256,uint32,address,bytes))"
            )
        );

    bytes32 public immutable bridgeHash;
    address public immutable customBridgeAddress;

    /// @notice socketGatewayAddress to be initialised via storage variable BridgeImplBase
    constructor(
        // bridge identifier
        bytes32 _bridgeHash,
        /**
         * NativeMantle that Performs the logic for deposits by informing the L2 Deposited Token
         * contract of the deposit and calling a handler to lock the L1 funds. (e.g. transferFrom)
         */
        address _customBridgeAddress,
        address _socketGateway,
        address _socketDeployFactory
    ) BridgeImplBase(_socketGateway, _socketDeployFactory) {
        bridgeHash = _bridgeHash;
        customBridgeAddress = _customBridgeAddress;
    }

    /// @notice Struct to be used in decode step from input parameter - a specific case of bridging after swap.
    /// @dev the data being encoded in offchain or by caller should have values set in this sequence of properties in this struct
    struct MantleNativeDataNoToken {
        // socket offchain created hash
        bytes32 metadata;
        // address of receiver of bridged tokens
        address receiverAddress;
        // dest chain id
        uint256 toChainId;
        // Gas limit required to complete the deposit on L2.
        uint32 l2Gas;
        // Address of the L1 respective L2 ERC20
        address l2Token;
        // additional data , for ll contracts this will be 0x data or empty data
        bytes data;
    }

    struct MantleNativeBridgeData {
        // socket offchain created hash
        bytes32 metadata;
        // address of receiver of bridged tokens
        address receiverAddress;
        // dest chain id
        uint256 toChainId;
        /// @notice address of token being bridged
        address token;
        // Gas limit required to complete the deposit on L2.
        uint32 l2Gas;
        // Address of the L1 respective L2 ERC20
        address l2Token;
        // additional data , for ll contracts this will be 0x data or empty data
        bytes data;
    }

    address public immutable MNT_TOKEN =
        address(0x3c3a81e81dc49A522A592e7622A7E711c06bf354);

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from swapAndBridge, this function is called when the swap has already happened at a different place.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in NativeMantleData struct
     * @param amount amount of tokens being bridged. this can be ERC20 or native
     * @param bridgeData encoded data for Native Mantle Bridge
     */
    function bridgeAfterSwap(
        uint256 amount,
        bytes calldata bridgeData
    ) external payable override {
        MantleNativeBridgeData memory mantleNativeData = abi.decode(
            bridgeData,
            (MantleNativeBridgeData)
        );

        emit SocketBridge(
            amount,
            mantleNativeData.token,
            mantleNativeData.toChainId,
            bridgeHash,
            msg.sender,
            mantleNativeData.receiverAddress,
            mantleNativeData.metadata
        );

        if (mantleNativeData.token == NATIVE_TOKEN_ADDRESS) {
            L1StandardBridge(customBridgeAddress).depositETHTo{value: amount}(
                mantleNativeData.receiverAddress,
                mantleNativeData.l2Gas,
                mantleNativeData.data
            );
            return;
        } else if (mantleNativeData.token == MNT_TOKEN) {
            if (
                amount >
                ERC20(mantleNativeData.token).allowance(
                    address(this),
                    customBridgeAddress
                )
            ) {
                ERC20(mantleNativeData.token).safeApprove(
                    customBridgeAddress,
                    UINT256_MAX
                );
            }

            // deposit into standard bridge
            L1StandardBridge(customBridgeAddress).depositMNTTo(
                mantleNativeData.receiverAddress,
                amount,
                mantleNativeData.l2Gas,
                mantleNativeData.data
            );
            return;
        } else {
            if (
                amount >
                ERC20(mantleNativeData.token).allowance(
                    address(this),
                    customBridgeAddress
                )
            ) {
                ERC20(mantleNativeData.token).safeApprove(
                    customBridgeAddress,
                    UINT256_MAX
                );
            }

            // deposit into standard bridge
            L1StandardBridge(customBridgeAddress).depositERC20To(
                mantleNativeData.token,
                mantleNativeData.l2Token,
                mantleNativeData.receiverAddress,
                amount,
                mantleNativeData.l2Gas,
                mantleNativeData.data
            );
        }
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from bridgeAfterSwap since this function holds the logic for swapping tokens too.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in NativeMantleData struct
     * @param swapId routeId for the swapImpl
     * @param swapData encoded data for swap
     * @param mantleNativeData encoded data for NativeMantleData
     */
    function swapAndBridge(
        uint32 swapId,
        bytes calldata swapData,
        MantleNativeDataNoToken calldata mantleNativeData
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

        emit SocketBridge(
            bridgeAmount,
            token,
            mantleNativeData.toChainId,
            bridgeHash,
            msg.sender,
            mantleNativeData.receiverAddress,
            mantleNativeData.metadata
        );
        if (token == NATIVE_TOKEN_ADDRESS) {
            L1StandardBridge(customBridgeAddress).depositETHTo{
                value: bridgeAmount
            }(
                mantleNativeData.receiverAddress,
                mantleNativeData.l2Gas,
                mantleNativeData.data
            );
            return;
        } else if (token == MNT_TOKEN) {
            if (
                bridgeAmount >
                ERC20(token).allowance(address(this), customBridgeAddress)
            ) {
                ERC20(token).safeApprove(customBridgeAddress, UINT256_MAX);
            }

            // deposit into standard bridge
            L1StandardBridge(customBridgeAddress).depositMNTTo(
                mantleNativeData.receiverAddress,
                bridgeAmount,
                mantleNativeData.l2Gas,
                mantleNativeData.data
            );
            return;
        } else {
            if (
                bridgeAmount >
                ERC20(token).allowance(address(this), customBridgeAddress)
            ) {
                ERC20(token).safeApprove(customBridgeAddress, UINT256_MAX);
            }

            // deposit into standard bridge
            L1StandardBridge(customBridgeAddress).depositERC20To(
                token,
                mantleNativeData.l2Token,
                mantleNativeData.receiverAddress,
                bridgeAmount,
                mantleNativeData.l2Gas,
                mantleNativeData.data
            );
        }
    }

    /**
     * @notice function to handle ERC20 bridging to receipent via NativeMantle-Bridge
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @param token address of token being bridged
     * @param receiverAddress address of receiver of bridged tokens
     * @param l2Gas Gas limit required to complete the deposit on L2.
     * @param metadata metadata
     * @param amount amount being bridged
     * @param l2Token Address of the L1 respective L2 ERC20
     * @param data additional data , for ll contracts this will be 0x data or empty data
     */
    function bridgeERC20To(
        address token,
        address receiverAddress,
        uint32 l2Gas,
        bytes32 metadata,
        uint256 amount,
        address l2Token,
        uint256 toChainId,
        bytes calldata data
    ) external payable {
        ERC20(token).safeTransferFrom(msg.sender, socketGateway, amount);
        if (
            amount > ERC20(token).allowance(address(this), customBridgeAddress)
        ) {
            ERC20(token).safeApprove(customBridgeAddress, UINT256_MAX);
        }

        if (token == MNT_TOKEN) {
            // deposit into MNT standard bridge
            L1StandardBridge(customBridgeAddress).depositMNTTo(
                receiverAddress,
                amount,
                l2Gas,
                data
            );
        } else {
            // deposit into standard bridge
            L1StandardBridge(customBridgeAddress).depositERC20To(
                token,
                l2Token,
                receiverAddress,
                amount,
                l2Gas,
                data
            );
        }

        emit SocketBridge(
            amount,
            token,
            toChainId,
            bridgeHash,
            msg.sender,
            receiverAddress,
            metadata
        );
    }

    /**
     * @notice function to handle native balance bridging to receipent via NativeMantle-Bridge
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @param receiverAddress address of receiver of bridged tokens
     * @param l2Gas Gas limit required to complete the deposit on L2.
     * @param amount amount being bridged
     * @param data additional data , for ll contracts this will be 0x data or empty data
     */
    function bridgeNativeTo(
        address receiverAddress,
        uint32 l2Gas,
        uint256 amount,
        uint256 toChainId,
        bytes32 metadata,
        bytes calldata data
    ) external payable {
        L1StandardBridge(customBridgeAddress).depositETHTo{value: amount}(
            receiverAddress,
            l2Gas,
            data
        );

        emit SocketBridge(
            amount,
            NATIVE_TOKEN_ADDRESS,
            toChainId,
            bridgeHash,
            msg.sender,
            receiverAddress,
            metadata
        );
    }
}
