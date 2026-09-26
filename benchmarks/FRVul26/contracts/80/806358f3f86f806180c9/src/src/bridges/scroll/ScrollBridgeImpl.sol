// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../BridgeImplBase.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {IScrollL1GatewayRouter} from "./interfaces/IScroll.sol";
import {SCROLL_NATIVE_BRIDGE} from "../../static/RouteIdentifiers.sol";

contract ScrollImpl is BridgeImplBase {
    /// @notice SafeTransferLib - library for safe and optimised operations on ERC20 tokens
    using SafeTransferLib for ERC20;

    uint256 private immutable UINT256_MAX = type(uint256).max;

    bytes32 public immutable ScrollBridgeIdentifier = SCROLL_NATIVE_BRIDGE;

    /// @notice Function-selector for ERC20-token bridging on ScrollNativeRoute
    /// @dev This function selector is to be used while buidling transaction-data to bridge ERC20 tokens
    bytes4 public immutable SCROLL_ERC20_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeERC20To(address,address,uint256,uint256,bytes32,uint256,uint256)"
            )
        );

    /// @notice Function-selector for Native bridging on ScrollNativeRoute
    /// @dev This function selector is to be used while buidling transaction-data to bridge Native balance
    bytes4 public immutable SCROLL_NATIVE_EXTERNAL_BRIDGE_FUNCTION_SELECTOR =
        bytes4(
            keccak256(
                "bridgeNativeTo(address,uint256,uint256,bytes32,uint256,uint256)"
            )
        );

    bytes4 public immutable SCROLL_SWAP_BRIDGE_SELECTOR =
        bytes4(
            keccak256(
                "swapAndBridge(uint32,bytes,(bytes32,address,uint256,address,uint32,uint256))"
            )
        );

    IScrollL1GatewayRouter private immutable scrollL1GatewayRouter;

    /// @notice socketGatewayAddress to be initialised via storage variable BridgeImplBase
    constructor(
        address _scrollL1GatewayRouter,
        address _socketGateway,
        address _socketDeployFactory
    ) BridgeImplBase(_socketGateway, _socketDeployFactory) {
        scrollL1GatewayRouter = IScrollL1GatewayRouter(_scrollL1GatewayRouter);
    }

    struct ScrollBridgeData {
        // socket offchain created hash
        bytes32 metadata;
        // address of receiver of bridged tokens
        address receiverAddress;
        // dest chain id
        uint256 toChainId;
        /// @notice address of token being bridged
        address token;
        // Gas limit required to complete the deposit on L2.
        uint32 gasLimit;
        // L2 fees
        uint256 fees;
    }

    /**
     * @notice function to handle ERC20 bridging to receipent via ScrollNative-Bridge
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @param token address of token being bridged
     * @param receiverAddress address of receiver of bridged tokens
     * @param gasLimit Gas limit required to complete the deposit on L2.
     * @param fees L2 Fees.
     * @param metadata metadata
     * @param amount amount being bridged
     */
    function bridgeERC20To(
        address token,
        address receiverAddress,
        uint256 gasLimit,
        uint256 fees,
        bytes32 metadata,
        uint256 amount,
        uint256 toChainId
    ) external payable {
        ERC20(token).safeTransferFrom(msg.sender, socketGateway, amount);
        if (
            amount >
            ERC20(token).allowance(
                address(this),
                address(scrollL1GatewayRouter)
            )
        ) {
            ERC20(token).safeApprove(
                address(scrollL1GatewayRouter),
                UINT256_MAX
            );
        }

        // deposit into standard bridge
        scrollL1GatewayRouter.depositERC20{value: fees}(
            token,
            receiverAddress,
            amount,
            gasLimit
        );

        emit SocketBridge(
            amount,
            token,
            toChainId,
            ScrollBridgeIdentifier,
            msg.sender,
            receiverAddress,
            metadata
        );
    }

    /**
     * @notice function to handle native balance bridging to receipent via ScrollNative-Bridge
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @param receiverAddress address of receiver of bridged tokens
     * @param gasLimit Gas limit required to complete the deposit on L2.
     * @param fees L2 Fees.
     * @param amount amount being bridged
     * @param metadata metadata
     */
    function bridgeNativeTo(
        address receiverAddress,
        uint256 gasLimit,
        uint256 fees,
        bytes32 metadata,
        uint256 amount,
        uint256 toChainId
    ) external payable {
        scrollL1GatewayRouter.depositETH{value: amount + fees}(
            receiverAddress,
            amount,
            gasLimit
        );

        emit SocketBridge(
            amount,
            NATIVE_TOKEN_ADDRESS,
            toChainId,
            ScrollBridgeIdentifier,
            msg.sender,
            receiverAddress,
            metadata
        );
    }

    /**
     * @notice function to bridge tokens after swap.
     * @notice this is different from swapAndBridge, this function is called when the swap has already happened at a different place.
     * @notice This method is payable because the caller is doing token transfer and briding operation
     * @dev for usage, refer to controller implementations
     *      encodedData for bridge should follow the sequence of properties in GnosisNativeBridgeData struct
     * @param amount amount of tokens being bridged. this can be ERC20 or native
     * @param bridgeData encoded data for Gnosis Native Bridge
     */
    function bridgeAfterSwap(
        uint256 amount,
        bytes calldata bridgeData
    ) external payable override {
        ScrollBridgeData memory bridgeInfo = abi.decode(
            bridgeData,
            (ScrollBridgeData)
        );

        if (bridgeInfo.token == NATIVE_TOKEN_ADDRESS) {
            scrollL1GatewayRouter.depositETH{value: amount + bridgeInfo.fees}(
                bridgeInfo.receiverAddress,
                amount,
                bridgeInfo.gasLimit
            );
        } else {
            ERC20(bridgeInfo.token).safeTransferFrom(
                msg.sender,
                socketGateway,
                amount
            );
            if (
                amount >
                ERC20(bridgeInfo.token).allowance(
                    address(this),
                    address(scrollL1GatewayRouter)
                )
            ) {
                ERC20(bridgeInfo.token).safeApprove(
                    address(scrollL1GatewayRouter),
                    UINT256_MAX
                );
            }

            // deposit into standard bridge
            scrollL1GatewayRouter.depositERC20{value: bridgeInfo.fees}(
                bridgeInfo.token,
                bridgeInfo.receiverAddress,
                amount,
                bridgeInfo.gasLimit
            );
        }

        emit SocketBridge(
            amount,
            bridgeInfo.token,
            bridgeInfo.toChainId,
            ScrollBridgeIdentifier,
            msg.sender,
            bridgeInfo.receiverAddress,
            bridgeInfo.metadata
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
     * @param _scrollBridgeData encoded data for ScrollBridgeData
     */
    function swapAndBridge(
        uint32 swapId,
        bytes calldata swapData,
        ScrollBridgeData calldata _scrollBridgeData
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
            scrollL1GatewayRouter.depositETH{
                value: bridgeAmount + _scrollBridgeData.fees
            }(
                _scrollBridgeData.receiverAddress,
                bridgeAmount,
                _scrollBridgeData.gasLimit
            );
        } else {
            ERC20(_scrollBridgeData.token).safeTransferFrom(
                msg.sender,
                socketGateway,
                bridgeAmount
            );
            if (
                bridgeAmount >
                ERC20(_scrollBridgeData.token).allowance(
                    address(this),
                    address(scrollL1GatewayRouter)
                )
            ) {
                ERC20(_scrollBridgeData.token).safeApprove(
                    address(scrollL1GatewayRouter),
                    UINT256_MAX
                );
            }

            // deposit into standard bridge
            scrollL1GatewayRouter.depositERC20{value: _scrollBridgeData.fees}(
                _scrollBridgeData.token,
                _scrollBridgeData.receiverAddress,
                bridgeAmount,
                _scrollBridgeData.gasLimit
            );
        }

        emit SocketBridge(
            bridgeAmount,
            token,
            _scrollBridgeData.toChainId,
            ScrollBridgeIdentifier,
            msg.sender,
            _scrollBridgeData.receiverAddress,
            _scrollBridgeData.metadata
        );
    }
}
