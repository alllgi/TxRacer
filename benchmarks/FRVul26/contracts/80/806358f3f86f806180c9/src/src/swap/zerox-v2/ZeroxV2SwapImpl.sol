// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import "../SwapImplBase.sol";
import {Address0Provided, SwapFailed, PartialSwapsNotAllowed} from "../../errors/SocketErrors.sol";
import {ZEROX_V2} from "../../static/RouteIdentifiers.sol";

/**
 * @title ZeroX-Swap-Route Implementation
 * @notice Route implementation with functions to swap tokens via ZeroX-Swap
 * Called via SocketGateway if the routeId in the request maps to the routeId of ZeroX-Swap-Implementation
 * @author Socket dot tech.
 */
contract ZeroxV2SwapImpl is SwapImplBase {
    /// @notice SafeTransferLib - library for safe and optimised operations on ERC20 tokens
    using SafeTransferLib for ERC20;

    bytes32 public immutable ZeroXIdentifier = ZEROX_V2;

    /// @notice unique name to identify the router, used to emit event upon successful bridging
    bytes32 public immutable NAME = keccak256("Zerox-v2-Router");

    /// @notice address of zeroXAllowanceHolder to swap the tokens on Chain
    address payable public immutable zeroXAllowanceHolder;

    /// @notice socketGatewayAddress to be initialised via storage variable SwapImplBase
    /// @notice zeroXAllowanceHolder contract is payable to allow ethereum swaps
    /// @dev ensure _zeroXAllowanceHolder are set properly for the chainId in which the contract is being deployed
    constructor(
        address _zeroXAllowanceHolder,
        address _socketGateway,
        address _socketDeployFactory
    ) SwapImplBase(_socketGateway, _socketDeployFactory) {
        zeroXAllowanceHolder = payable(_zeroXAllowanceHolder);
    }

    receive() external payable {}

    fallback() external payable {}

    /**
     * @notice function to swap tokens on the chain and transfer to receiver address
     * @dev This is called only when there is a request for a swap.
     * @param fromToken token to be swapped
     * @param toToken token to which fromToken is to be swapped
     * @param amount amount to be swapped
     * @param receiverAddress address of toToken recipient
     * @param swapExtraData data required for zeroX Exchange to get the swap done
     */
    function performAction(
        address fromToken,
        address toToken,
        uint256 amount,
        address receiverAddress,
        bytes32 metadata,
        bytes calldata swapExtraData
    ) external payable override returns (uint256) {
        uint256 _initialBalanceTokenOut;
        uint256 _finalBalanceTokenOut;

        uint256 _initialBalanceTokenIn;
        uint256 _finalBalanceTokenIn;

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            ERC20(fromToken).safeTransferFrom(
                msg.sender,
                socketGateway,
                amount
            );
            ERC20(fromToken).safeApprove(zeroXAllowanceHolder, amount);
        }

        if (toToken != NATIVE_TOKEN_ADDRESS) {
            _initialBalanceTokenOut = ERC20(toToken).balanceOf(socketGateway);
        } else {
            _initialBalanceTokenOut = address(this).balance;
        }

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            _initialBalanceTokenIn = ERC20(fromToken).balanceOf(socketGateway);
        } else {
            _initialBalanceTokenIn = address(this).balance;
        }

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            // solhint-disable-next-line
            (bool success, ) = zeroXAllowanceHolder.call(swapExtraData);

            if (!success) {
                revert SwapFailed();
            }
        } else {
            (bool success, ) = zeroXAllowanceHolder.call{value: amount}(
                swapExtraData
            );
            if (!success) {
                revert SwapFailed();
            }
        }

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            _finalBalanceTokenIn = ERC20(fromToken).balanceOf(socketGateway);
        } else {
            _finalBalanceTokenIn = address(this).balance;
        }
        if (_finalBalanceTokenIn > _initialBalanceTokenIn - amount)
            revert PartialSwapsNotAllowed();

        if (toToken != NATIVE_TOKEN_ADDRESS) {
            _finalBalanceTokenOut = ERC20(toToken).balanceOf(socketGateway);
        } else {
            _finalBalanceTokenOut = address(this).balance;
        }

        uint256 returnAmount = _finalBalanceTokenOut - _initialBalanceTokenOut;

        if (toToken == NATIVE_TOKEN_ADDRESS) {
            payable(receiverAddress).transfer(returnAmount);
        } else {
            ERC20(toToken).safeTransfer(receiverAddress, returnAmount);
        }

        emit SocketSwapTokens(
            fromToken,
            toToken,
            returnAmount,
            amount,
            ZeroXIdentifier,
            receiverAddress,
            metadata
        );

        return returnAmount;
    }

    /**
     * @notice function to swapWithIn SocketGateway - swaps tokens on the chain to socketGateway as recipient
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
        uint256 _initialBalanceTokenOut;
        uint256 _finalBalanceTokenOut;

        uint256 _initialBalanceTokenIn;
        uint256 _finalBalanceTokenIn;

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            ERC20(fromToken).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
            ERC20(fromToken).safeApprove(zeroXAllowanceHolder, amount);
        }

        if (toToken != NATIVE_TOKEN_ADDRESS) {
            _initialBalanceTokenOut = ERC20(toToken).balanceOf(socketGateway);
        } else {
            _initialBalanceTokenOut = address(this).balance;
        }

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            _initialBalanceTokenIn = ERC20(fromToken).balanceOf(socketGateway);
        } else {
            _initialBalanceTokenIn = address(this).balance;
        }

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            // solhint-disable-next-line
            (bool success, ) = zeroXAllowanceHolder.call(swapExtraData);

            if (!success) {
                revert SwapFailed();
            }
        } else {
            (bool success, ) = zeroXAllowanceHolder.call{value: amount}(
                swapExtraData
            );
            if (!success) {
                revert SwapFailed();
            }
        }

        if (fromToken != NATIVE_TOKEN_ADDRESS) {
            _finalBalanceTokenIn = ERC20(fromToken).balanceOf(socketGateway);
        } else {
            _finalBalanceTokenIn = address(this).balance;
        }
        if (_finalBalanceTokenIn > _initialBalanceTokenIn - amount)
            revert PartialSwapsNotAllowed();

        if (toToken != NATIVE_TOKEN_ADDRESS) {
            _finalBalanceTokenOut = ERC20(toToken).balanceOf(socketGateway);
        } else {
            _finalBalanceTokenOut = address(this).balance;
        }

        emit SocketSwapTokens(
            fromToken,
            toToken,
            _finalBalanceTokenOut - _initialBalanceTokenOut,
            amount,
            ZeroXIdentifier,
            socketGateway,
            metadata
        );

        return (_finalBalanceTokenOut - _initialBalanceTokenOut, toToken);
    }
}
