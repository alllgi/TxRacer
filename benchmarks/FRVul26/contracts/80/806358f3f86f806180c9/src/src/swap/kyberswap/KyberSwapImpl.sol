// SPDX‑License‑Identifier: MIT
pragma solidity >=0.8.0;

/**
 * Kyber Swap implementation for the Socket “swap” routes.
 *
 * ▸ The off‑chain Socket backend encodes Kyber’s router calldata
 *   (see docs.kyberswap.com → Aggregator API → /route/build).
 * ▸ That calldata comes in here via `swapExtraData`.
 * ▸ This contract simply: takes custody of the user’s tokens,
 *   approves the Kyber router, executes the low‑level call, and
 *   forwards the output to the requested receiver (or to the
 *   SocketGateway itself in the *WithIn variant).
 *
 * Design closely mirrors the audited OneInch implementation that
 * already exists in the repo.
 */

import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import "../SwapImplBase.sol";
import {Address0Provided, SwapFailed} from "../../errors/SocketErrors.sol";
import {KYBERSWAP} from "../../static/RouteIdentifiers.sol";

contract KyberSwapImpl is SwapImplBase {
    using SafeTransferLib for ERC20;

    /* --------------------------------------------------------------------- */
    /*                               CONSTANTS                               */
    /* --------------------------------------------------------------------- */

    /// Route‑ID emitted in `SocketSwapTokens`
    bytes32 public constant KyberSwapIdentifier = KYBERSWAP;

    /// Human‑readable name (hashed to save storage)
    bytes32 public constant NAME = keccak256("kyberswap-Router");

    /// KyberSwap Router / Allowance‑Target for this chain
    address payable public immutable kyberswapRouter;

    /* --------------------------------------------------------------------- */
    /*                             CONSTRUCTOR                               */
    /* --------------------------------------------------------------------- */

    constructor(
        address _kyberRouter, // router / allowance‑holder
        address _socketGateway, // SocketGateway address
        address _socketDeployFactory
    ) SwapImplBase(_socketGateway, _socketDeployFactory) {
        if (_kyberRouter == address(0)) {
            revert Address0Provided();
        }
        kyberswapRouter = payable(_kyberRouter);
    }

    /* ETH fallback (router may send leftover dust) ----------------------- */
    receive() external payable {}
    fallback() external payable {}

    /* --------------------------------------------------------------------- */
    /*                          PUBLIC SWAP FUNCTIONS                        */
    /* --------------------------------------------------------------------- */

    /**
     * @dev Swap and send output **directly to the receiver**.
     *
     * Off‑chain we already encoded Kyber’s `swap` calldata with
     * `recipient = receiverAddress`, so we only have to execute it.
     */
    function performAction(
        address fromToken,
        address toToken,
        uint256 amount,
        address receiverAddress,
        bytes32 metadata,
        bytes calldata swapExtraData // Kyber router calldata
    ) external payable override returns (uint256 returnAmount) {
        /* ------------------------- Execute swap ------------------------- */
        bool success;
        bytes memory result;

        if (fromToken == NATIVE_TOKEN_ADDRESS) {
            // Native‑in: forward `amount` ETH along with the call
            (success, result) = kyberswapRouter.call{value: amount}(
                swapExtraData
            );
        } else {
            ERC20(fromToken).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );

            // Approve kyber router
            ERC20(fromToken).safeApprove(kyberswapRouter, amount);

            // Swap using kyberswap
            (success, result) = kyberswapRouter.call(swapExtraData);

            // Clear approval to mitigate “approval‑race” attack surface
            ERC20(fromToken).safeApprove(kyberswapRouter, 0);
        }

        if (!success) {
            revert SwapFailed();
        }

        /* Router returns bytes‑encoded amountOut (uint256) ---------------- */
        returnAmount = abi.decode(result, (uint256));

        emit SocketSwapTokens(
            fromToken,
            toToken,
            returnAmount,
            amount,
            KyberSwapIdentifier,
            receiverAddress,
            metadata
        );
    }

    /**
     * @dev Variant used when the **SocketGateway** must hold the output
     *      (e.g. swap + bridge combos).  Recipient passed to Kyber is
     *      the gateway; after swap completes the gateway already owns
     *      `toToken`, so we only return the amount & token address.
     */
    function performActionWithIn(
        address fromToken,
        address toToken,
        uint256 amount,
        bytes32 metadata,
        bytes calldata swapExtraData
    ) external payable override returns (uint256, address) {
        /* 1. Execute Kyber router call ----------------------------------- */
        bool success;
        bytes memory result;

        if (fromToken == NATIVE_TOKEN_ADDRESS) {
            (success, result) = kyberswapRouter.call{value: amount}(
                swapExtraData
            );
        } else {
            /* 2. Pull tokens & approve router -------------------------------- */
            ERC20(fromToken).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
            ERC20(fromToken).safeApprove(kyberswapRouter, amount);

            (success, result) = kyberswapRouter.call(swapExtraData);
            ERC20(fromToken).safeApprove(kyberswapRouter, 0);
        }

        if (!success) revert SwapFailed();

        uint256 returnAmount = abi.decode(result, (uint256));

        emit SocketSwapTokens(
            fromToken,
            toToken,
            returnAmount,
            amount,
            KyberSwapIdentifier,
            socketGateway, // receiver == gateway
            metadata
        );

        return (returnAmount, toToken);
    }
}
