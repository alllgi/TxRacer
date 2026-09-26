// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IAMM {
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }
}

/**
 * @title HopAMM
 * @notice Interface to handle the token bridging to L2 chains.
 */
interface HopCctpBridge {
    /**
     * @param chainId chainId of the L2 contract
     * @param recipient receiver address
     * @param amount amount is the amount the user wants to send plus the Bonder fee
     * @param bonderFee fees
     */
    function swapAndSend(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 bonderFee,
        IAMM.ExactInputParams calldata swapParams
    ) external payable;

    function send(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 bonderFee
    ) external payable;
}
