// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import "../SwapImplBase.sol";
import {SwapFailed} from "../../errors/SocketErrors.sol";

/**
 * @title Socket Swap Implementation
 * @notice Route implementation with functions to swap tokens via External SwapProvider
 * Called via SocketGateway if the routeId in the request maps to the routeId of SwapProviderImplementation
 * @author Socket dot tech.
 */
contract SocketSwapImpl is SwapImplBase {
    /// @notice SafeTransferLib - library for safe and optimised operations on ERC20 tokens
    using SafeTransferLib for ERC20;

    bytes32 public immutable SwapProviderIdentifier;
    /// @notice address of SwapProviderAggregator to swap the tokens on Chain
    address public immutable SWAP_PROVIDER_CONTRACT;

    /// @notice socketGatewayAddress to be initialised via storage variable SwapImplBase
    /// @dev ensure _SwapProviderAggregator are set properly for the chainId in which the contract is being deployed
    constructor(
        address _swapProviderContract,
        bytes32 _swapProviderIdentifier,
        address _socketGateway,
        address _socketDeployFactory
    ) SwapImplBase(_socketGateway, _socketDeployFactory) {
        SWAP_PROVIDER_CONTRACT = _swapProviderContract;
        SwapProviderIdentifier = _swapProviderIdentifier;
    }

    /**
     * @notice function to swap tokens on the chain and transfer to receiver address
     *         via SwapProvider-Middleware-Aggregator
     * @param fromToken token to be swapped
     * @param toToken token to which fromToken has to be swapped
     * @param amount amount of fromToken being swapped
     * @param receiverAddress address of toToken recipient
     * @param swapExtraData encoded value of properties in the swapData Struct
     * @return swapped amount (in toToken Address)
     */
    function performAction(
        address fromToken,
        address toToken,
        uint256 amount,
        address receiverAddress,
        bytes32 metadata,
        bytes calldata swapExtraData
    ) external payable override returns (uint256) {
        uint256 returnAmount;

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            ERC20 token = ERC20(fromToken);
            token.safeTransferFrom(msg.sender, socketGateway, amount);
            token.safeApprove(SWAP_PROVIDER_CONTRACT, amount);
            {
                // additional data is generated in off-chain using the SwapProvider API which takes in
                // fromTokenAddress, toTokenAddress, amount, fromAddress, slippage, destReceiver, disableEstimate
                (bool success, bytes memory result) = SWAP_PROVIDER_CONTRACT
                    .call(swapExtraData);
                token.safeApprove(SWAP_PROVIDER_CONTRACT, 0);

                if (!success) {
                    revert SwapFailed();
                }

                returnAmount = abi.decode(result, (uint256));
            }
        } else {
            // additional data is generated in off-chain using the SwapProvider API which takes in
            // fromTokenAddress, toTokenAddress, amount, fromAddress, slippage, destReceiver, disableEstimate
            (bool success, bytes memory result) = SWAP_PROVIDER_CONTRACT.call{
                value: amount
            }(swapExtraData);
            if (!success) {
                revert SwapFailed();
            }
            returnAmount = abi.decode(result, (uint256));
        }

        emit SocketSwapTokens(
            fromToken,
            toToken,
            returnAmount,
            amount,
            SwapProviderIdentifier,
            receiverAddress,
            metadata
        );

        return returnAmount;
    }

    /**
     * @notice function to swapWithIn SocketGateway - swaps tokens on the chain to socketGateway as recipient
     *         via SwapProvider-Middleware-Aggregator
     * @param fromToken token to be swapped
     * @param toToken token to which fromToken has to be swapped
     * @param amount amount of fromToken being swapped
     * @param swapExtraData encoded value of properties in the swapData Struct
     * @return swapped amount (in toToken Address)
     */
    function performActionWithIn(
        address fromToken,
        address toToken,
        uint256 amount,
        bytes32 metadata,
        bytes calldata swapExtraData
    ) external payable override returns (uint256, address) {
        uint256 returnAmount;

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            ERC20 token = ERC20(fromToken);
            token.safeTransferFrom(msg.sender, socketGateway, amount);
            token.safeApprove(SWAP_PROVIDER_CONTRACT, amount);
            {
                // additional data is generated in off-chain using the SwapProvider API which takes in
                // fromTokenAddress, toTokenAddress, amount, fromAddress, slippage, destReceiver, disableEstimate
                (bool success, bytes memory result) = SWAP_PROVIDER_CONTRACT
                    .call(swapExtraData);
                token.safeApprove(SWAP_PROVIDER_CONTRACT, 0);

                if (!success) {
                    revert SwapFailed();
                }

                returnAmount = abi.decode(result, (uint256));
            }
        } else {
            // additional data is generated in off-chain using the SwapProvider API which takes in
            // fromTokenAddress, toTokenAddress, amount, fromAddress, slippage, destReceiver, disableEstimate
            (bool success, bytes memory result) = SWAP_PROVIDER_CONTRACT.call{
                value: amount
            }(swapExtraData);
            if (!success) {
                revert SwapFailed();
            }
            returnAmount = abi.decode(result, (uint256));
        }

        emit SocketSwapTokens(
            fromToken,
            toToken,
            returnAmount,
            amount,
            SwapProviderIdentifier,
            socketGateway,
            metadata
        );

        return (returnAmount, toToken);
    }
}
