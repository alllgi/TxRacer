// SPDX-License-Identifier: UNLICENSED
// © Copyright XSwap.link. All Rights Reserved
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IFeeOracle} from "./interfaces/IFeeOracle.sol";
import {IFeeCollector} from "./interfaces/IFeeCollector.sol";
import {IXSwapExecutor} from "./interfaces/IXSwapExecutor.sol";

import "./structs/XSwapFee.sol";
import "./structs/SwapDataOrigin.sol";
import "./structs/SwapDataDestination.sol";

import {CollectFeesUpgradeable} from "./CollectFeesUpgradeable.sol";
import {CCIPBaseUpgradeable} from "./CCIPBaseUpgradeable.sol";

import {IRouterClient} from "@chainlink/contracts-ccip-new/contracts/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip-new/contracts/libraries/Client.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

struct MessageFees {
    uint256 ccipFee;
    XSwapFee xSwapFee;
}

contract XSwapRouter is
    Initializable,
    UUPSUpgradeable,
    CCIPBaseUpgradeable,
    CollectFeesUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;

    mapping(uint64 => address) public chainSelectorToXSwapRouterMap;
    mapping(bytes32 => address) public messageExecutionHashToExecutorMap;
    address public xSwapExecutor;

    // EVENTS
    event ExecutorRunFailed(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address indexed sender, // The address of the sender from the source chain.
        bytes data, // The data that was received.
        address token, // The token address that was transferred.
        uint256 tokenAmount // The token amount that was transferred.
    );
    event FundsReturnedForMessageExecution(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        address indexed messageExecutor, // The address that performed message instant execute.
        bytes32 indexed executionHash, // The message execution hash.
        address token, // The token address that was transferred.
        uint256 tokenAmount // The token amount that was transferred.
    );
    event ExecutorUpdated(address newExecutor);

    // ERRORS
    error InvalidAddress();
    error NotEnoughNative();
    error MessageMustTransferOnlyOneToken();
    error MessageAlreadyExecuted(address messageExecutor);
    error NoXSwapRouterOnSelectedChain(uint64 chainId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Constructor initializes the contract.
    /// @param _ccipRouter The address of the CCIP router contract.
    /// @param _feeOracle The address of the fee Oracle contract.
    /// @param _feeCollector The address of the fee Collector contract.
    /// @param _xSwapExecutor The address of the calls executor.
    /// @param _owner The address of owner.
    function initialize(
        address _ccipRouter,
        address _feeOracle,
        address _feeCollector,
        address _xSwapExecutor,
        address _owner
    ) public initializer {
        if (_ccipRouter == address(0)) {
            revert InvalidAddress();
        }
        if (_feeOracle == address(0)) {
            revert InvalidAddress();
        }
        if (_feeCollector == address(0)) {
            revert InvalidAddress();
        }
        if (_xSwapExecutor == address(0)) {
            revert InvalidAddress();
        }

        __CCIPBase_init(_ccipRouter);
        __ReentrancyGuard_init();
        __CollectFees_init(_feeOracle, _feeCollector);

        xSwapExecutor = _xSwapExecutor;

        // transfer ownership to the owner address
        _transferOwnership(_owner);
    }

    /// @dev Sets xSwapRouter for a given chain selector.
    /// @notice This function can only be called by the owner.
    /// @param _chainSelector The selector of the destination chain.
    /// @param _xSwapRouter The address of xSwapRouter from given chain.
    function updateChainSelectorToXSwapRouterMap(
        uint64 _chainSelector,
        address _xSwapRouter
    ) public onlyOwner {
        chainSelectorToXSwapRouterMap[_chainSelector] = _xSwapRouter;
    }

    /// @dev Sets xSwapRouter for a given chain selector.
    /// @notice This function can only be called by the owner.
    /// @param _chainSelectors The selector of the destination chain.
    /// @param _xSwapRouters The address of xSwapRouter from given chain.
    function updateChainSelectorToXSwapRouterMapMany(
        uint64[] calldata _chainSelectors,
        address[] calldata _xSwapRouters
    ) external onlyOwner {
        if (_chainSelectors.length != _xSwapRouters.length) {
            revert IncorrectArrayLength();
        }

        for (uint i = 0; i < _chainSelectors.length; i++) {
            updateChainSelectorToXSwapRouterMap(
                _chainSelectors[i],
                _xSwapRouters[i]
            );
        }
    }

    /// @dev Sets the xSwapExecutor address.
    /// @notice This function can only be called by the owner.
    /// @param _xSwapExecutor The address of xSwapExecutor.
    function setXSwapExecutor(address _xSwapExecutor) external onlyOwner {
        xSwapExecutor = _xSwapExecutor;
        emit ExecutorUpdated(xSwapExecutor);
    }

    /// @dev Modifier that checks if the chain with the given chain has xSwapRouter address set.
    /// @param _destinationChainSelector The selector of the destination chain.
    modifier onlyChainWithXSwapRouter(uint64 _destinationChainSelector) {
        if (
            chainSelectorToXSwapRouterMap[_destinationChainSelector] ==
            address(0)
        ) {
            revert NoXSwapRouterOnSelectedChain(_destinationChainSelector);
        }
        _;
    }

    // @notice Function for estimating transaction fees. to estimate ccip fee with native provide zero address as _paymentToken.
    /// @param _paymentToken The address of ccip payment token. To pay native provide address zero.
    /// @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param _swapDestinationData The data to be sent.
    /// @param _token token address.
    /// @param _amount token amount.
    /// @param _gasLimit the gas limit for the destination tx
    /// @param _additionalData user additionalData
    /// @return fees estimated fees for the swap
    function getFees(
        address _paymentToken,
        uint64 _destinationChainSelector,
        SwapDataDestination calldata _swapDestinationData,
        address _token,
        uint256 _amount,
        uint256 _gasLimit,
        bool _allowOutOfOrderExecution,
        address _spender,
        bytes calldata _additionalData
    ) public view returns (MessageFees memory fees) {
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _destinationChainSelector,
            _swapDestinationData,
            _paymentToken,
            _token,
            _amount,
            _gasLimit,
            _allowOutOfOrderExecution
        );

        fees.ccipFee = IRouterClient(this.getRouter()).getFee(
            _destinationChainSelector,
            evm2AnyMessage
        );

        fees.xSwapFee = IFeeOracle(feeOracleAddress).getFee(
            _amount,
            _token,
            _spender,
            _additionalData
        );
    }

    /// @notice Sends data and transfer tokens to receiver on the destination chain.
    /// @param _paymentToken The address of payment token for ccip transfer. To pay native provide address zero.
    /// @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param _swapDestinationData The data to be sent.
    /// @param _swapOriginData data for local swap.
    /// @param _gasLimit the gas limit for the destination tx
    function swapAndSendMessage(
        address _paymentToken,
        uint64 _destinationChainSelector,
        SwapDataDestination calldata _swapDestinationData,
        SwapDataOrigin calldata _swapOriginData,
        uint256 _gasLimit,
        bool _allowOutOfOrderExecution
    )
        external
        payable
        onlyChainWithXSwapRouter(_destinationChainSelector)
        returns (bytes32 messageId)
    {
        uint256 valueForExecutor = _swapOriginData.valueForDestinationGas;

        uint256 tokenOutAmountBeforeSwap = IERC20(_swapOriginData.tokenOut)
            .balanceOf(address(this));

        if (_swapOriginData.tokenIn == address(0)) {
            if (msg.value < _swapOriginData.amountIn) {
                revert NotEnoughNative();
            }
            valueForExecutor += _swapOriginData.amountIn;
        } else {
            // Transfer funds to the router first
            IERC20(_swapOriginData.tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                _swapOriginData.amountIn
            );
        }

        // Execute calls
        if (_swapOriginData.calls.length != 0) {
            if (_swapOriginData.tokenIn != address(0)) {
                IERC20(_swapOriginData.tokenIn).forceApprove(
                    xSwapExecutor,
                    _swapOriginData.amountIn
                );
            }

            IXSwapExecutor(xSwapExecutor).run{value: valueForExecutor}(
                _swapOriginData.calls
            );
        }
        uint256 tokenOutAmount = IERC20(_swapOriginData.tokenOut).balanceOf(
            address(this)
        ) - tokenOutAmountBeforeSwap;
        // Collect XSwapRouterFee in transfer token
        _collectFees(
            tokenOutAmount,
            _swapOriginData.tokenOut,
            msg.sender,
            _swapOriginData.additionalData
        );

        tokenOutAmount =
            IERC20(_swapOriginData.tokenOut).balanceOf(address(this)) -
            tokenOutAmountBeforeSwap;

        // Optional payment for instant ccip recieve execution
        if (_swapOriginData.valueForInstantCcipRecieve > 0) {
            IFeeCollector(feeCollectorAddress).receiveNative{
                value: _swapOriginData.valueForInstantCcipRecieve
            }();
        }

        messageId = _sendMessage(
            _paymentToken,
            _destinationChainSelector,
            _swapDestinationData,
            _swapOriginData.tokenOut,
            tokenOutAmount,
            _gasLimit,
            _allowOutOfOrderExecution
        );

        // Emit an event with message details
        emit MessageSent(
            messageId,
            _destinationChainSelector,
            msg.sender,
            abi.encode(_swapDestinationData),
            abi.encode(_swapOriginData),
            tokenOutAmount
        );

        // refund unused gas to msg.sender
        address payable to = payable(msg.sender);
        (bool sent, ) = to.call{value: address(this).balance}("");
        if (!sent) {
            revert FailedToSendNative();
        }

        return messageId;
    }

    // Internal Functions ===========================================================================
    /// @notice Sends data and transfer tokens to receiver on the destination chain.
    /// @param _paymentToken The address of payment token. To pay native provide address zero.
    /// @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param _swapDestinationData The data to be sent.
    /// @param _token token address.
    /// @param _amount token amount.
    /// @param _gasLimit CCIP message gas limit.
    /// @return messageId The ID of the CCIP message that was sent.
    function _sendMessage(
        address _paymentToken,
        uint64 _destinationChainSelector,
        SwapDataDestination calldata _swapDestinationData,
        address _token,
        uint256 _amount,
        uint256 _gasLimit,
        bool _allowOutOfOrderExecution
    ) internal returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _destinationChainSelector,
            _swapDestinationData,
            _paymentToken,
            _token,
            _amount,
            _gasLimit,
            _allowOutOfOrderExecution
        );

        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());
        // Get the fee required to send the CCIP message
        uint256 ccipFeeAmount = router.getFee(
            _destinationChainSelector,
            evm2AnyMessage
        );

        // approve the Router to spend tokens on contract's behalf. It will spend the amount of the given token
        IERC20(_token).forceApprove(address(router), _amount);

        uint256 ccipFeeInNative = 0;

        if (_paymentToken != address(0)) {
            // pay with token
            IERC20(_paymentToken).safeTransferFrom(
                msg.sender,
                address(this),
                ccipFeeAmount
            );
            // approve the Router to transfer fee tokens on contract's behalf.
            IERC20(_paymentToken).forceApprove(address(router), ccipFeeAmount);
        } else {
            // pay native
            ccipFeeInNative = ccipFeeAmount;
        }

        // Send the message through the router and store the returned message ID
        messageId = router.ccipSend{value: ccipFeeInNative}(
            _destinationChainSelector,
            evm2AnyMessage
        );

        // Return the message ID
        return messageId;
    }

    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory _any2EvmMessage
    )
        internal
        override
        onlyWhitelistedSender(
            _any2EvmMessage.sourceChainSelector,
            abi.decode(_any2EvmMessage.sender, (address))
        )
    {
        // Expect one token to be transferred at once
        address receivedTokenAddress = _any2EvmMessage
            .destTokenAmounts[0]
            .token;
        uint256 receivedTokenAmount = _any2EvmMessage
            .destTokenAmounts[0]
            .amount;

        bytes32 messageExecutionHash = _getMessageExecutionHash(
            _any2EvmMessage
        );

        if (
            messageExecutionHashToExecutorMap[messageExecutionHash] !=
            address(0)
        ) {
            IERC20(receivedTokenAddress).safeTransfer(
                messageExecutionHashToExecutorMap[messageExecutionHash],
                receivedTokenAmount
            );
            emit FundsReturnedForMessageExecution(
                _any2EvmMessage.messageId,
                messageExecutionHashToExecutorMap[messageExecutionHash],
                messageExecutionHash,
                receivedTokenAddress,
                receivedTokenAmount
            );
        } else {
            _executeMessage(_any2EvmMessage);
        }
    }

    function _executeMessage(
        Client.Any2EVMMessage memory _any2EvmMessage
    ) internal {
        SwapDataDestination memory swapDataDestination = abi.decode(
            _any2EvmMessage.data,
            (SwapDataDestination)
        ); // abi-decoding of the sent path

        // Expect one token to be transferred at once
        address receivedTokenAddress = _any2EvmMessage
            .destTokenAmounts[0]
            .token;
        uint256 receivedTokenAmount = _any2EvmMessage
            .destTokenAmounts[0]
            .amount;

        if (swapDataDestination.calls.length == 0) {
            IERC20(receivedTokenAddress).safeTransfer(
                swapDataDestination.receiver,
                receivedTokenAmount
            );
        } else {
            // approve tokens to the executor
            IERC20(receivedTokenAddress).forceApprove(
                xSwapExecutor,
                receivedTokenAmount
            );

            // get balance before swap
            uint256 balanceBeforeSwap;
            if (swapDataDestination.tokenOut == address(0)) {
                balanceBeforeSwap = swapDataDestination.receiver.balance;
            } else {
                balanceBeforeSwap = IERC20(swapDataDestination.tokenOut)
                    .balanceOf(swapDataDestination.receiver);
            }

            // try to execute calls
            try IXSwapExecutor(xSwapExecutor).run(swapDataDestination.calls) {
                // update recieved token after successful swap
                receivedTokenAddress = swapDataDestination.tokenOut;
                if (swapDataDestination.tokenOut == address(0)) {
                    receivedTokenAmount =
                        swapDataDestination.receiver.balance -
                        balanceBeforeSwap;
                } else {
                    receivedTokenAmount =
                        IERC20(swapDataDestination.tokenOut).balanceOf(
                            swapDataDestination.receiver
                        ) -
                        balanceBeforeSwap;
                }
            } catch {
                IERC20(receivedTokenAddress).safeTransfer(
                    swapDataDestination.receiver,
                    receivedTokenAmount
                );
                emit ExecutorRunFailed(
                    _any2EvmMessage.messageId,
                    _any2EvmMessage.sourceChainSelector,
                    swapDataDestination.receiver,
                    _any2EvmMessage.data,
                    receivedTokenAddress,
                    receivedTokenAmount
                );
            }
        }

        bytes32 messageExecutionHash = _getMessageExecutionHash(
            _any2EvmMessage
        );
        messageExecutionHashToExecutorMap[messageExecutionHash] = msg.sender;
        emit MessageReceived(
            _any2EvmMessage.messageId,
            _any2EvmMessage.sourceChainSelector,
            swapDataDestination.receiver,
            _any2EvmMessage.data,
            receivedTokenAddress,
            receivedTokenAmount
        );
    }

    function instantCcipReceive(
        Client.Any2EVMMessage memory _any2EvmMessage
    ) external nonReentrant {
        // Expect one token to be transferred at once
        if (_any2EvmMessage.destTokenAmounts.length != 1) {
            revert MessageMustTransferOnlyOneToken();
        }

        bytes32 messageExecutionHash = _getMessageExecutionHash(
            _any2EvmMessage
        );

        if (
            messageExecutionHashToExecutorMap[messageExecutionHash] !=
            address(0)
        ) {
            revert MessageAlreadyExecuted(
                messageExecutionHashToExecutorMap[messageExecutionHash]
            );
        }

        IERC20(_any2EvmMessage.destTokenAmounts[0].token).safeTransferFrom(
            msg.sender,
            address(this),
            _any2EvmMessage.destTokenAmounts[0].amount
        );

        _executeMessage(_any2EvmMessage);
    }

    function _getMessageExecutionHash(
        Client.Any2EVMMessage memory _any2EvmMessage
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(_any2EvmMessage));
    }

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for programmable tokens transfer.
    /// @param _destinationChainSelector The chain selector.
    /// @param _swapData The data to be sent.
    /// @param _feeTokenAddress The address of the token used for fees. Set zero address for native gas.
    /// @param _token token address.
    /// @param _amount token amount.
    /// @param _gasLimit CCIP message gas limit.
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPMessage(
        uint64 _destinationChainSelector,
        SwapDataDestination calldata _swapData,
        address _feeTokenAddress,
        address _token,
        uint256 _amount,
        uint256 _gasLimit,
        bool _allowOutOfOrderExecution
    ) internal view returns (Client.EVM2AnyMessage memory) {
        // Set the token amounts
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });
        tokenAmounts[0] = tokenAmount;

        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(
                chainSelectorToXSwapRouterMap[_destinationChainSelector]
            ), // ABI-encoded receiver address
            data: abi.encode(_swapData), // ABI-encoded data
            tokenAmounts: tokenAmounts, // The amount and type of token being transferred
            extraArgs: Client._argsToBytes(
                Client.GenericExtraArgsV2({
                    gasLimit: _gasLimit,
                    allowOutOfOrderExecution: _allowOutOfOrderExecution
                }) // Additional arguments, setting gas limit
            ),
            // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
            feeToken: _feeTokenAddress
        });
        return evm2AnyMessage;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
