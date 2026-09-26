// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ISquidMulticall} from "./ISquidMulticall.sol";
import {IPermit2} from "../interfaces/uniswap/IPermit2.sol";

/// @title SquidRouter
/// @notice Main entry point of the protocol. It mainly provides endpoints to interact safely
/// with the multicall or CCTP, and receiver function to handle asset reception for bridges.
interface ISquidRouter {
    /// @notice Emitted when the calldata content of a payload is successfully ran on destination chain.
    /// @param payloadHash Keccak256 of the payload bytes value. Differ from one call to another in case of
    /// identical parameters value thanks to a salt value.
    event CrossMulticallExecuted(bytes32 indexed payloadHash);
    /// @notice Emitted when the calldata content of a payload failed to be ran on destination chain and
    /// ERC20 tokens are sent to refund recipient address.
    /// @param payloadHash Keccak256 hash of the payload bytes value. Differ from one call to another in case
    /// of identical parameters value thanks to a salt value.
    /// @param reason Revert data returned by contract called in failing call.
    /// @param refundRecipient Address that will receive bridged ERC20 tokens on destination chain in case
    /// of multicall failure.
    event CrossMulticallFailed(
        bytes32 indexed payloadHash,
        bytes reason,
        address indexed refundRecipient
    );

    /// @notice Thrown when address(0) is provided to a parameter that does not allow it.
    error ZeroAddressProvided();
    /// @notice Thrown when Chainflip receiver function is called by any address other that Chainflip
    /// vault contract.
    error OnlyCfVault();

    /// @notice Collect ERC20 and/or native tokens from user and send them to multicall. Then run multicall.
    /// @dev Require either ERC20 or permit2 allowance from the user to the router address.
    /// Indeed, permit2's transferFrom2 is used instead of regulat transferFrom. Meaning that if there is no
    /// regular allowance from user to the router for ERC20 token, permit2 allowance will be used if granted.
    /// @dev Native tokens can be provided on top of ERC20 tokens, both will be sent to multicall.
    /// @param token Address of the ERC20 token to be provided to the multicall to run the calls.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param amount Amount of ERC20 tokens to be provided to the multicall. If native token is selected, this
    /// value has not effect.
    /// @param calls Calls to be ran by the multicall, formatted in accordance to Call struct.
    function fundAndRunMulticall(
        address token,
        uint256 amount,
        ISquidMulticall.Call[] calldata calls
    ) external payable;

    /// @notice Collect ERC20 tokens from user and send them to multicall thanks to a permit2 signed permit. Then run
    /// multicall.
    /// @dev Native tokens can be provided on top of ERC20 tokens by the relayer of the permit, both will be sent
    /// to multicall.
    /// @dev Transaction sender can either be the holder of the funds, or the separate relayer. In the later case,
    /// witness must be included in the data signed, according to the permit2 protocol.
    /// @dev See https://docs.uniswap.org/contracts/permit2/reference/signature-transfer for more information about
    /// permit2 protocol requirements.
    /// @dev ERC20 token and amount values to be used are provided in the permit data.
    /// @param calls Calls to be ran by the multicall, formatted in accordance to Call struct.
    /// @param from Holder of the funds to be provided. Can defer from the sender of the transaction in case of a
    /// relayed transaction.
    /// @param permit Permit data according to permit2 protocol.
    /// @param signature Signature data according to permit2 protocol.
    function permitFundAndRunMulticall(
        ISquidMulticall.Call[] memory calls,
        address from,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external payable;

    /// @notice Collect USDC tokens from user and trigger CCTP bridging.
    /// @dev This endpoint is meant to enable CCTP bridging at the end of a multicall. It also enable integrations
    /// with Squid CCTP bridging relayer infrasctructure.
    /// @dev Require either ERC20 or permit2 allowance from the user to the router address.
    /// Indeed, permit2's transferFrom2 is used instead of regulat transferFrom. Meaning that if there is no
    /// regular allowance from user to the router for ERC20 token, permit2 allowance will be used if granted.
    /// @dev CCTP's replaceDepositForBurn function is not made available for security reason. Integrators need to
    /// be careful with the parameters they provide.
    /// @dev Require owner to call `approveCctpTokenMessenger` function first.
    /// @param amount Amount of USDC tokens to be bridged.
    /// @param destinationDomain Destination chain according to CCTP's nomenclature.
    /// This param is checked for potential irrelevant values by CCTP contract.
    /// See https://developers.circle.com/stablecoins/docs/cctp-technical-reference.
    /// @param destinationAddress Address that will receive USDC tokens on destination chain.
    /// This param is checked for not zero value by CCTP contract.
    /// @param destinationCaller Address that will be able to trigger USDC tokens reception on destination chain.
    /// This param is checked for not zero value to disable anonymous actions.
    function cctpBridge(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 destinationAddress,
        bytes32 destinationCaller
    ) external;

    /// @notice Collect USDC tokens from user thanks to a permit2 signed permit and trigger CCTP bridging.
    /// @dev Transaction sender can either be the holder of the funds, or the separate relayer. In the later case,
    /// witness must be included in the data signed, according to the permit2 protocol.
    /// @dev See https://docs.uniswap.org/contracts/permit2/reference/signature-transfer for more information about
    /// permit2 protocol requirements.
    /// @dev USDC token and amount values to be used are provided in the permit data.
    /// Permit token address value is checked to match USDC token address.
    /// @dev CCTP's replaceDepositForBurn function is not made available for security reason. Integrators need to
    /// be careful with the parameters they provide.
    /// @dev Require owner to call `approveCctpTokenMessenger` function first.
    /// @param destinationDomain Destination chain according to CCTP's nomenclature.
    /// This param is checked for potential irrelevant values by CCTP contract.
    /// See https://developers.circle.com/stablecoins/docs/cctp-technical-reference.
    /// @param destinationAddress Address that will receive USDC tokens on destination chain.
    /// This param is checked for not zero value by CCTP contract.
    /// @param destinationCaller Address that will be able to trigger USDC tokens reception on destination chain.
    /// This param is checked for not zero value to disable anonymous actions.
    /// @param from Holder of the funds to be provided. Can defer from the sender of the transaction in case of a
    /// relayed transaction.
    /// @param permit Permit data according to permit2 protocol.
    /// @param signature Signature data according to permit2 protocol.
    function permitCctpBridge(
        uint32 destinationDomain,
        bytes32 destinationAddress,
        bytes32 destinationCaller,
        address from,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external;

    /// @notice Approve CCTP Token Messenger to access unlimited amount of USDC. Enables to not have to
    /// approve each time a user wants to bridge USDC. Requires to monitor CCTP Token Messenger allowance.
    /// @dev Only owner can call.
    function approveCctpTokenMessenger() external;

    /// @notice Collect ERC20 and/or native tokens from user and send them to multicall. Then bridge tokens
    /// through Axelar bridge and run multicall on destination chain. This endpoint is deprecated and will be
    /// removed in a future upgrade.
    /// @dev Require either ERC20 or permit2 allowance from the user to the router address.
    /// Indeed, permit2's transferFrom2 is used instead of regulat transferFrom. Meaning that if there is no
    /// regular allowance from user to the router for ERC20 token, permit2 allowance will be used if granted.
    /// @dev Require to provide native amount to cover gas service. The amount has to be computed off chain with
    /// Axelar SDK.
    /// @dev Native tokens provided on top of an ERC20 token will be sent to gas service. Thus you need to provide
    /// native amount to cover gas service on top of native amount for calls
    /// @dev Gas service providing is handled internally.
    /// @param bridgedTokenSymbol Symbol of the token that will be sent to Axelar bridge.
    /// @param amount Amount of ERC20 tokens to be collect for bridging.
    /// @param destinationChain Destination chain for bridging according to Axelar's nomenclature.
    /// @param destinationAddress Address that will receive bridged ERC20 tokens on destination chain.
    /// @param payload Bytes value containing calls to be ran by the multicall on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient, bytes32 salt).
    /// @param gasRefundRecipient Address that will receive native tokens left on gas service after process is
    /// done.
    /// @param enableExpress If true is provided, Axelar's express (aka Squid's boost) feature will be used.
    function bridgeCall(
        string calldata bridgedTokenSymbol,
        uint256 amount,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) external payable;

    /// @notice Collect ERC20 and/or native tokens from user and send them to multicall. Then run multicall and
    /// bridge tokens through Axelar bridge before running multicall on destination chain. This endpoint is
    /// deprecated and will be removed in a future upgrade.
    /// @dev Require either ERC20 or permit2 allowance from the user to the router address.
    /// Indeed, permit2's transferFrom2 is used instead of regulat transferFrom. Meaning that if there is no
    /// regular allowance from user to the router for ERC20 token, permit2 allowance will be used if granted.
    /// @dev Require to provide native amount to cover gas service. The amount has to be computed off chain with
    /// Axelar SDK.
    /// @dev Native tokens provided on top of an ERC20 token will be sent to gas service. If input token is native
    /// tokens, input amount will be sent to multicall and the rest to gas service. Thus you need to provide native
    /// amount to cover gas service on top of native amount for calls.
    /// @dev Gas service providing is handled internally.
    /// @param token Address of the ERC20 token to be provided to the multicall to run the calls.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param amount Amount of ERC20 or native tokens to be provided to the multicall.
    /// @param calls Calls to be ran by the multicall on source chain, formatted in accordance to Call struct.
    /// @param bridgedTokenSymbol Symbol of the token that will be sent to Axelar bridge.
    /// @param destinationChain Destination chain for bridging according to Axelar's nomenclature.
    /// @param destinationAddress Address that will receive bridged ERC20 tokens on destination chain.
    /// @param payload Bytes value containing calls to be ran by the multicall on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient, bytes32 salt).
    /// @param gasRefundRecipient Address that will receive native tokens left on gas service after process is
    /// done.
    /// @param enableExpress If true is provided, Axelar's express (aka Squid's boost) feature will be used.
    function callBridgeCall(
        address token,
        uint256 amount,
        ISquidMulticall.Call[] calldata calls,
        string calldata bridgedTokenSymbol,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) external payable;
}
