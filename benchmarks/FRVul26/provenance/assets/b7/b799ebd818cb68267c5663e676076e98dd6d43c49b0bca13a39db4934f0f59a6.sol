// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../libraries/DlnOrderLib.sol";

interface IDlnSource {
    /**
     * @notice This function returns the global fixed fee in the native asset of the protocol.
     * @dev This fee is denominated in the native asset (like Ether in Ethereum).
     * @return uint88 This return value represents the global fixed fee in the native asset.
     */
    function globalFixedNativeFee() external returns (uint88);

    /**
     * @notice This function provides the global transfer fee, expressed in Basis Points (BPS).
     * @dev It retrieves a global fee which is applied to order.giveAmount. The fee is represented in Basis Points (BPS), where 1 BPS equals 0.01%.
     * @return uint16 The return value represents the global transfer fee in BPS.
     */
    function globalTransferFeeBps() external returns (uint16);

    /**
     * @dev Places a new order with pseudo-random orderId onto the DLN
     * @notice deprecated
     * @param _orderCreation a structured parameter from the DlnOrderLib.OrderCreation library, containing all the necessary information required for creating a new order.
     * @param _affiliateFee a bytes parameter specifying the affiliate fee that will be rewarded to the beneficiary. It includes the beneficiary's details and the affiliate amount.
     * @param _referralCode a 32-bit unsigned integer containing the referral code. This code is traced back to the referral source or person that facilitated this order. This code is also emitted in an event for tracking purposes.
     * @param _permitEnvelope a bytes parameter that is used to approve the spender through a signature. It contains the amount, the deadline, and the signature.
     * @return bytes32 identifier (orderId) of a newly placed order
     */
    function createOrder(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        bytes calldata _affiliateFee,
        uint32 _referralCode,
        bytes calldata _permitEnvelope
    ) external payable returns (bytes32);

    /**
     * @dev Places a new order with deterministic orderId onto the DLN
     * @param _orderCreation a structured parameter from the DlnOrderLib.OrderCreation library, containing all the necessary information required for creating a new order.
     * @param _salt an input source of randomness for getting a deterministic identifier of an order (orderId)
     * @param _affiliateFee a bytes parameter specifying the affiliate fee that will be rewarded to the beneficiary. It includes the beneficiary's details and the affiliate amount.
     * @param _referralCode a 32-bit unsigned integer containing the referral code. This code is traced back to the referral source or person that facilitated this order. This code is also emitted in an event for tracking purposes.
     * @param _permitEnvelope a bytes parameter that is used to approve the spender through a signature. It contains the amount, the deadline, and the signature.
     * @param _metadata an arbitrary data to be tied together with the order for future off-chain analysis
     * @return bytes32 identifier (orderId) of a newly placed order
     */
    function createSaltedOrder(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        uint64 _salt,
        bytes calldata _affiliateFee,
        uint32 _referralCode,
        bytes calldata _permitEnvelope,
        bytes calldata _metadata
    ) external payable returns (bytes32);

    /**
     * @dev Places a new order for intent manager with deterministic orderId onto the DLN
     * @notice This function can only be called by the intent manager and has special fee handling:
     *         - No fixed native fee is charged
     *         - Uses custom fee instead of the global fee
     *         - No affiliate fees are supported
     * @param _orderCreation a structured parameter from the DlnOrderLib.OrderCreation library, containing all the necessary information required for creating a new order.
     * @param _salt an input source of randomness for getting a deterministic identifier of an order (orderId)
     * @param _referralCode a 32-bit unsigned integer containing the referral code. This code is traced back to the referral source or person that facilitated this order.
     * @param _giveTokenFeeAmount custom fee to be charged instead of the global fee
     * @param _metadata an arbitrary data to be tied together with the order for future off-chain analysis
     * @return bytes32 identifier (orderId) of a newly placed order
     */
    function createSaltedOrderForIntent(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        uint64 _salt,
        uint32 _referralCode,
        uint256 _giveTokenFeeAmount,
        bytes calldata _metadata
    ) external payable returns (bytes32);

    /**
     * @dev Places a new order for intent manager with deterministic orderId and an explicitly specified maker.
     * @notice This function can only be called by the intent manager and has special fee handling:
     *         - No fixed native fee is charged
     *         - Uses custom fee instead of the global fee
     *         - No affiliate fees are supported
     * @param _orderCreation a structured parameter from the DlnOrderLib.OrderCreation library, containing all the necessary information required for creating a new order.
     * @param _maker address to use as the order maker
     * @param _salt an input source of randomness for getting a deterministic identifier of an order (orderId)
     * @param _referralCode a 32-bit unsigned integer containing the referral code. This code is traced back to the referral source or person that facilitated this order.
     * @param _giveTokenFeeAmount custom fee to be charged instead of the global fee
     * @param _metadata an arbitrary data to be tied together with the order for future off-chain analysis
     * @return bytes32 identifier (orderId) of a newly placed order
     */
    function createSaltedOrderForIntent(
        DlnOrderLib.OrderCreation calldata _orderCreation,
        address _maker,
        uint64 _salt,
        uint32 _referralCode,
        uint256 _giveTokenFeeAmount,
        bytes calldata _metadata
    ) external payable returns (bytes32);
}
