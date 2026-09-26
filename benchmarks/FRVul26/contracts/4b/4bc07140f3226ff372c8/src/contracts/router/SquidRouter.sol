// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ISquidRouter} from "../interfaces/ISquidRouter.sol";
import {ISquidMulticall} from "../interfaces/ISquidMulticall.sol";
import {IPermit2} from "../interfaces/uniswap/IPermit2.sol";
import {IInterchainTokenService} from "../interfaces/its/IInterchainTokenService.sol";
import {ICFReceiver} from "../interfaces/chainflip/ICFReceiver.sol";
import {ICCTPTokenMessenger} from "../interfaces/cctp/ICCTPTokenMessenger.sol";
import {IAxelarGasService} from "@axelar-network/axelar-cgp-solidity/contracts/interfaces/IAxelarGasService.sol"; // Deprecated
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AxelarExpressExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/express/AxelarExpressExecutable.sol";
import {InterchainTokenExpressExecutable} from "../interfaces/its/InterchainTokenExpressExecutable.sol";
import {Upgradable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/upgradable/Upgradable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {StorageSlot} from "../libraries/StorageSlot.sol";
import {SquidPermit2} from "./SquidPermit2.sol";
import {RoledPausable} from "../libraries/RoledPausable.sol";
import {Utils} from "../libraries/Utils.sol";

contract SquidRouter is
    ISquidRouter,
    ICFReceiver,
    AxelarExpressExecutable,
    InterchainTokenExpressExecutable,
    Upgradable,
    SquidPermit2,
    RoledPausable
{
    using SafeERC20 for IERC20;
    using StorageSlot for bytes32;

    address public immutable squidMulticall;
    address public immutable chainflipVault;
    address public immutable usdc;
    address public immutable cctpTokenMessenger;
    address public immutable axelarGasService; // Deprecated

    /// @param _squidMulticall Address of the relevant Squid's SquidMulticall.sol contract deployment.
    /// @param _permit2 Address of the relevant Uniswap's Permit2.sol contract deployment
    /// Can be zero address if not available on current network.
    /// @param _axelarGateway Address of the relevant Axelar's AxelarGateway.sol contract deployment.
    /// @param _interchainTokenService Address of the relevant Axelar's InterchainTokenService.sol contract
    /// deployment.
    /// @param _chainflipVault Address of the relevant Chainflip's Vault.sol contract deployment. Can be zero
    /// address if not available on current network.
    /// @param _usdc Address of the relevant Circle's USDC contract deployment (contract name defers from one chain
    /// to another). Can be zero address if not available on current network.
    /// @param _cctpTokenMessenger Address of the relevant Circle's TokenMessenger.sol contract deployment. Can be
    /// zero address if not available on current network.
    /// @param _axelarGasService Address of the relevant Axelar's AxelarGasService.sol contract deployment. The related
    /// logic is deprecated and will be removed in a future upgrade.
    constructor(
        address _squidMulticall,
        address _permit2,
        address _axelarGateway,
        address _interchainTokenService,
        address _chainflipVault,
        address _usdc,
        address _cctpTokenMessenger,
        address _axelarGasService // Deprecated
    )
        AxelarExpressExecutable(_axelarGateway)
        InterchainTokenExpressExecutable(_interchainTokenService)
        SquidPermit2(_permit2)
    {
        if (
            _squidMulticall == address(0) ||
            _interchainTokenService == address(0) ||
            _axelarGasService == address(0) // Deprecated
        ) revert ZeroAddressProvided();

        squidMulticall = _squidMulticall;
        chainflipVault = _chainflipVault;
        usdc = _usdc;
        cctpTokenMessenger = _cctpTokenMessenger;
        axelarGasService = _axelarGasService; // Deprecated
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                        Multicall                         //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISquidRouter
    function fundAndRunMulticall(
        address token,
        uint256 amount,
        ISquidMulticall.Call[] calldata calls
    ) public payable whenNotPaused {
        // No transfer done if native token is selected as token
        if (token != Utils.nativeToken) {
            _transferFrom2(token, msg.sender, address(squidMulticall), amount);
        }

        ISquidMulticall(squidMulticall).run{value: msg.value}(calls);
    }

    /// @inheritdoc ISquidRouter
    function permitFundAndRunMulticall(
        ISquidMulticall.Call[] calldata calls,
        address from,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external payable whenNotPaused onlyIfPermit2Available {
        IPermit2.SignatureTransferDetails memory transferDetails = IPermit2
            .SignatureTransferDetails({
                to: address(squidMulticall),
                requestedAmount: permit.permitted.amount
            });

        if (from == msg.sender) {
            // If holder of the funds is sender of the transaction, call the relevant permit2 function.
            permit2.permitTransferFrom(permit, transferDetails, from, signature);
        } else {
            // If holder of the funds is not sender of the transaction, build the witness data and call the relevant
            // permit2 function.
            bytes32 hashedCalls = keccak256(abi.encode(calls));
            bytes32 witness = keccak256(
                abi.encode(FUND_AND_RUN_MULTICALL_DATA_TYPEHASH, hashedCalls)
            );
            permit2.permitWitnessTransferFrom(
                permit,
                transferDetails,
                from,
                witness,
                FUND_AND_RUN_MULTICALL_WITNESS_TYPE_STRING,
                signature
            );
        }

        ISquidMulticall(squidMulticall).run{value: msg.value}(calls);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                     CCTP endpoints                       //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISquidRouter
    function cctpBridge(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 destinationAddress,
        bytes32 destinationCaller
    ) external whenNotPaused {
        Utils.checkServiceAvailability(cctpTokenMessenger);

        if (destinationCaller == bytes32(0)) revert ZeroAddressProvided();

        _transferFrom2(usdc, msg.sender, address(this), amount);

        ICCTPTokenMessenger(cctpTokenMessenger).depositForBurnWithCaller(
            amount,
            destinationDomain,
            destinationAddress,
            usdc,
            destinationCaller
        );
    }

    /// @inheritdoc ISquidRouter
    function permitCctpBridge(
        uint32 destinationDomain,
        bytes32 destinationAddress,
        bytes32 destinationCaller,
        address from,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external whenNotPaused onlyIfPermit2Available {
        Utils.checkServiceAvailability(cctpTokenMessenger);

        if (destinationCaller == bytes32(0)) revert ZeroAddressProvided();

        IPermit2.SignatureTransferDetails memory transferDetails = IPermit2
            .SignatureTransferDetails({
                to: address(this),
                requestedAmount: permit.permitted.amount
            });

        if (from == msg.sender) {
            // If holder of the funds is sender of the transaction, call the relevant permit2 function.
            permit2.permitTransferFrom(permit, transferDetails, from, signature);
        } else {
            // If holder of the funds is not sender of the transaction, build the witness data and call the relevant
            // permit2 function.
            bytes32 witness = keccak256(
                abi.encode(
                    CCTP_BRIDGE_DATA_TYPEHASH,
                    destinationDomain,
                    destinationAddress,
                    destinationCaller
                )
            );
            permit2.permitWitnessTransferFrom(
                permit,
                transferDetails,
                from,
                witness,
                CCTP_BRIDGE_WITNESS_TYPE_STRING,
                signature
            );
        }

        ICCTPTokenMessenger(cctpTokenMessenger).depositForBurnWithCaller(
            permit.permitted.amount,
            destinationDomain,
            destinationAddress,
            usdc,
            destinationCaller
        );
    }

    /// @inheritdoc ISquidRouter
    function approveCctpTokenMessenger() external onlyOwner {
        // Unlimited approval is not security issue since the contract does not store any ERC20 token.
        IERC20(usdc).approve(cctpTokenMessenger, type(uint256).max);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                     Bridge receivers                     //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ICFReceiver
    function cfReceive(
        uint32,
        bytes calldata,
        bytes calldata payload,
        address token,
        uint256 amount
    ) external payable {
        if (msg.sender != chainflipVault) revert OnlyCfVault();
        _processDestinationCalls(payload, token, amount);
    }

    /// @notice Called by Axelar protocol when receiving ERC20 tokens on destination chain.
    /// Contains the logic that will run the payload calldata content.
    /// @param payload Value provided by Squid containing the calldata that will be ran on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt) or abi.encode(address refundRecipient, bytes32 salt) if funds need to be directly sent
    /// to destination address.
    /// @param tokenSymbol Symbol of the ERC20 token bridged.
    /// @param amount Amount of the ERC20 token bridged.
    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        address token = gateway.tokenAddresses(tokenSymbol);
        _processPayload(payload, token, amount);
    }

    /// @notice Called by Interchain Token Service when receiving tokens on destination chain.
    /// Contains the logic that will run the payload calldata content.
    /// @param payload Value provided by Squid containing the calldata that will be ran on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt) or abi.encode(address refundRecipient, bytes32 salt) if funds need to be directly sent
    /// to destination address.
    /// @param token Address of the ERC20 token bridged.
    /// @param amount Amount of the ERC20 token bridged.
    function _executeWithInterchainToken(
        bytes32,
        string calldata,
        bytes calldata,
        bytes calldata payload,
        bytes32,
        address token,
        uint256 amount
    ) internal override {
        _processPayload(payload, token, amount);
    }

    /// @notice Check size of payload and processes is accordingly. If there is no calls, send tokens
    /// directly to user. If there are calls, run them.
    /// @dev Does not work with native token.
    /// @param payload Value provided by Squid containing the calldata that will be ran on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt) or abi.encode(address refundRecipient, bytes32 salt) if funds need to be directly sent
    /// to destination address.
    /// @param token Address of the ERC20 token to be either provided to the multicall to run the calls, or
    /// sent to user.
    /// @param amount Amount of the ERC20 token used. Must match msg.value
    /// if native tokens.
    function _processPayload(bytes calldata payload, address token, uint256 amount) private {
        // If there is no call data, payload will be exactly 64 bytes (32 for padded address + 32
        // for salt)
        if (payload.length == 64) {
            (address destinationAddress, ) = abi.decode(payload, (address, bytes32));
            IERC20(token).safeTransfer(destinationAddress, amount);
        } else {
            _processDestinationCalls(payload, token, amount);
        }
    }

    /// @notice Parse payload, approve multicall and run calldata on it. In case of multicall fail,
    /// bridged ERC20 tokens are refunded to refund recipient address.
    /// @param token Address of the ERC20 token to be provided to the multicall to run the calls.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param amount Amount of ERC20 or native tokens to be provided to the multicall. Must match msg.value
    /// if native tokens.
    /// @param payload Value to be parsed to get calldata that will be ran on multicall as well as
    /// refund recipient address.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt).
    function _processDestinationCalls(
        bytes calldata payload,
        address token,
        uint256 amount
    ) private {
        (ISquidMulticall.Call[] memory calls, address payable refundRecipient, ) = abi.decode(
            payload,
            (ISquidMulticall.Call[], address, bytes32)
            // Last value is a salt that is only used to make to hash of payload vary in case of
            // identical content of 2 calls
        );

        if (token != Utils.nativeToken) {
            Utils.smartApprove(token, address(squidMulticall), amount);
        }

        try ISquidMulticall(squidMulticall).run{value: msg.value}(calls) {
            emit CrossMulticallExecuted(keccak256(payload));
        } catch (bytes memory reason) {
            // Refund tokens to refund recipient if swap fails
            Utils.smartTransfer(token, refundRecipient, amount);
            emit CrossMulticallFailed(keccak256(payload), reason, refundRecipient);
        }
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                        Utilities                         //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @notice Enable onwer of the contract to transfer tokens that have been mistakenly sent to it.
    /// There is no custody risk as this contract is not meant to hold any funds in between users calls.
    /// @dev Only owner can call.
    /// @param token Address of the ERC20 token to be transfered.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param to Address that will receive the tokens.
    /// @param amount Amount of ERC20 or native tokens to transfer.
    function rescueFunds(address token, address payable to, uint256 amount) external onlyOwner {
        Utils.smartTransfer(token, to, amount);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                    Proxy requirements                    //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @notice Return hard coded identifier for proxy check during upgrade.
    /// @return id Hardcoded id.
    function contractId() external pure override returns (bytes32 id) {
        id = keccak256("squid-router");
    }

    /// @notice Called by proxy during upgrade. Set pauser role to provided address.
    /// @param data Bytes containing pauser address. Checked for not zero address.
    /// Expected format is: abi.encode(address pauser).
    function _setup(bytes calldata data) internal override {
        address _pauser = abi.decode(data, (address));
        if (_pauser == address(0)) revert ZeroAddressProvided();
        _setPauser(_pauser);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                    Deprecated endpoints                  //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISquidRouter
    function bridgeCall(
        string calldata bridgedTokenSymbol,
        uint256 amount,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) external payable whenNotPaused {
        address bridgedTokenAddress = gateway.tokenAddresses(bridgedTokenSymbol);
        _transferFrom2(bridgedTokenAddress, msg.sender, address(this), amount);

        _bridgeCall(
            bridgedTokenSymbol,
            bridgedTokenAddress,
            destinationChain,
            destinationAddress,
            payload,
            gasRefundRecipient,
            enableExpress
        );
    }

    /// @inheritdoc ISquidRouter
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
    ) external payable whenNotPaused {
        uint256 valueToSend;
        if (token == Utils.nativeToken) {
            valueToSend = amount;
        } else {
            _transferFrom2(token, msg.sender, address(squidMulticall), amount);
        }

        ISquidMulticall(squidMulticall).run{value: valueToSend}(calls);

        address bridgedTokenAddress = gateway.tokenAddresses(bridgedTokenSymbol);
        _bridgeCall(
            bridgedTokenSymbol,
            bridgedTokenAddress,
            destinationChain,
            destinationAddress,
            payload,
            gasRefundRecipient,
            enableExpress
        );
    }

    /// @notice Helper for handling Axelar gas service funding and Axelar bridging.
    /// @param bridgedTokenSymbol Symbol of the ERC20 token that will be sent to Axelar bridge.
    /// @param bridgedTokenAddress Address of the ERC20 token that will be sent to Axelar bridge.
    /// @param destinationChain Destination chain for bridging according to Axelar's nomenclature.
    /// @param destinationAddress Address that will receive bridged ERC20 tokens on destination chain.
    /// @param payload Bytes value containing calls to be ran by the multicall on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient, bytes32 salt).
    /// @param gasRefundRecipient Address that will receive native tokens left on gas service after process is
    /// done.
    /// @param enableExpress If true is provided, Axelar's express (aka Squid's boost) feature will be used.
    function _bridgeCall(
        string calldata bridgedTokenSymbol,
        address bridgedTokenAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) private {
        uint256 bridgedTokenBalance = IERC20(bridgedTokenAddress).balanceOf(address(this));

        if (address(this).balance > 0) {
            if (enableExpress) {
                IAxelarGasService(axelarGasService).payNativeGasForExpressCallWithToken{
                    value: address(this).balance
                }(
                    address(this),
                    destinationChain,
                    destinationAddress,
                    payload,
                    bridgedTokenSymbol,
                    bridgedTokenBalance,
                    gasRefundRecipient
                );
            } else {
                IAxelarGasService(axelarGasService).payNativeGasForContractCallWithToken{
                    value: address(this).balance
                }(
                    address(this),
                    destinationChain,
                    destinationAddress,
                    payload,
                    bridgedTokenSymbol,
                    bridgedTokenBalance,
                    gasRefundRecipient
                );
            }
        }

        Utils.smartApprove(bridgedTokenAddress, address(gateway), bridgedTokenBalance);
        gateway.callContractWithToken(
            destinationChain,
            destinationAddress,
            payload,
            bridgedTokenSymbol,
            bridgedTokenBalance
        );
    }
}
