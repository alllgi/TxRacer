// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice interface with functions to interact with SpokePool contract of Across-Bridge
interface SpokePool {
    /**************************************
     *         DEPOSITOR FUNCTIONS        *
     **************************************/

    /**
     * @param depositor The address that made the deposit on the origin chain.
     * @param recipient The account receiving funds on the destination chain. Can be an EOA or a contract. If the output token is the wrapped native token for the chain, then the recipient will receive native token if an EOA or wrapped native token if a contract.
     * @param inputToken The token pulled from the caller's account and locked into this contract to initiate the deposit. If this is equal to the wrapped native token then the caller can optionally pass in native token as * msg.value, as long as msg.value = inputTokenAmount.
     * @param outputToken The token that the relayer will send to the recipient on the destination chain. Must be an ERC20. Note, this can be set to the zero address (0x0) in which case, fillers will replace this with the destination chain equivalent of the input token.
     * @param inputAmount The amount of input tokens to pull from the caller's account and lock into this contract. This amount will be sent to the relayer on their repayment chain of choice as a refund following an optimistic challenge window in the HubPool, less a system fee.
     * @param outputAmount The amount of output tokens that the relayer will send to the recipient on the destination.
     * @param destinationChainId The destination chain identifier. Must be enabled along with the input token as a valid deposit route from this spoke pool or this transaction will revert.
     * @param exclusiveRelayer The relayer that will be exclusively allowed to fill this deposit before the exclusivity deadline timestamp. This must be a valid, non-zero address if the exclusivity deadline is greater than the current block.timestamp. If the exclusivity deadline is < currentTime, then this must be address(0), and vice versa if this is address(0).
     * @param quoteTimestamp Timestamp of deposit. Used by relayers to compute the LP fee % for the deposit. Must be withindepositQuoteTimeBuffer() of the current time.
     * @param fillDeadline The deadline for the relayer to fill the deposit. After this destination chain timestamp, the fill will revert on the destination chain. Must be set between [currentTime, currentTime + fillDeadlineBuffer] where currentTime is block.timestamp on this chain or this transaction will revert.
     * @param exclusivityDeadline The deadline for the exclusive relayer to fill the deposit. After this destination chain timestamp, anyone can fill this deposit on the destination chain. If exclusiveRelayer is set to address(0), then this also must be set to 0, (and vice versa), otherwise this must be set >= current time.
     * @param message Data that can be passed to the recipient if it is a contract. If no message is to be sent, set this field to an empty bytes array: ""(i.e. bytes` of length 0, or the "empty string"). See Composable Bridging for examples on how messaging can be used.
     */
    function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;
}
