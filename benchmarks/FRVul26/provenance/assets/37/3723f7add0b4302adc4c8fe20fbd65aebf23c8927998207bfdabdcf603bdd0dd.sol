// SPDX-License-Identifier: UNLICENSED
// © Copyright XSwap.link. All Rights Reserved
pragma solidity 0.8.17;

import {IRouterClient} from "@chainlink/contracts-ccip-new/contracts/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip-new/contracts/libraries/Client.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {CCIPReceiverUpgradeable} from "./CCIPReceiverUpgradeable.sol";

abstract contract CCIPBaseUpgradeable is
    Initializable,
    UUPSUpgradeable,
    CCIPReceiverUpgradeable
{
    // Mapping to keep track of whitelisted senders. sourceChainSelector -> sender -> isWhitelisted
    mapping(uint64 => mapping(address => bool)) public whitelistedSenders;

    // Mapping to keep track of whitelisted tokens for cross chain transfers.
    mapping(address => bool) public whitelistedTokens;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;

    // Custom errors to provide more descriptive revert messages.
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance to cover the fees.
    error DestinationChainNotWhitelisted(uint64 destinationChainSelector); // Used when the destination chain has not been whitelisted by the contract owner.
    error SenderNotWhitelisted(uint64 sourceChainSelector, address sender); // Used when the sender has not been whitelisted by the contract owner.
    error TokenNotWhitelisted(address token); // Used when the token has not been whitelisted by the contract owner.
    error FailedToSendNative(); // Used when the emergency withdraw of ether fails.
    error IncorrectArrayLength(); // Used when the arrays are not the same length.

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address indexed sender, // The address of the sender
        bytes swapDestinationData, // The swap destination data.
        bytes swapOriginData, // The swap origin data.
        uint256 transferedTokenAmount // The transfered token amount of USDC.
    );

    // Event emitted when a message is received from another chain.
    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address indexed sender, // The address of the sender from the source chain.
        bytes data, // The data that was received.
        address token, // The token address that was transferred.
        uint256 tokenAmount // The token amount that was transferred.
    );

    // Event emitted when an owner executes emergency withdraw.
    event EmergencyWithdraw(
        address token, // The token address that was transferred.
        uint256 tokenAmount // The token amount that was transferred.
    );

    function __CCIPBase_init(
        address _router
    ) internal virtual onlyInitializing {
        __CCIPReceiver_init(_router);
    }

    /// @dev Modifier that checks if the address sender on chain with the given sourceChainSelector is whitelisted.
    /// @param _sender The address of the sender.
    modifier onlyWhitelistedSender(
        uint64 _sourceChainSelector,
        address _sender
    ) {
        if (!whitelistedSenders[_sourceChainSelector][_sender])
            revert SenderNotWhitelisted(_sourceChainSelector, _sender);
        _;
    }

    /// @dev Whitelists or denylists a sender.
    /// @notice This function can only be called by the owner.
    /// @param _sender The address of the sender.
    /// @param _isWhitelisted The boolean for whitelist or denylist a sender.
    function updateWhitelistSender(
        uint64 _sourceChainSelector,
        address _sender,
        bool _isWhitelisted
    ) public onlyOwner {
        whitelistedSenders[_sourceChainSelector][_sender] = _isWhitelisted;
    }

    /// @dev Whitelists or denylists senders.
    /// @notice This function can only be called by the owner.
    /// @param _sourceChainSelectors The the chain selectors of the sender.
    /// @param _senders The addresses of the senders.
    /// @param _areWhitelisted The boolean array for whitelist or denylist a sender.
    function updateWhitelistSenderMany(
        uint64[] calldata _sourceChainSelectors,
        address[] calldata _senders,
        bool[] calldata _areWhitelisted
    ) external onlyOwner {
        if (
            _sourceChainSelectors.length != _senders.length ||
            _senders.length != _areWhitelisted.length
        ) {
            revert IncorrectArrayLength();
        }

        for (uint i = 0; i < _senders.length; i++) {
            updateWhitelistSender(
                _sourceChainSelectors[i],
                _senders[i],
                _areWhitelisted[i]
            );
        }
    }

    /// @dev Whitelists or denylists a token.
    /// @notice This function can only be called by the owner.
    /// @param _token The address of the token.
    /// @param _isWhitelisted The boolean for whitelist or denylist a token.
    function updateWhitelistToken(
        address _token,
        bool _isWhitelisted
    ) external onlyOwner {
        whitelistedTokens[_token] = _isWhitelisted;
    }

    /// @notice Fallback function to allow the contract to receive Ether.
    /// @dev This function has no function body, making it a default function for receiving Ether.
    /// It is automatically called when Ether is sent to the contract without any data.
    receive() external payable {}

    /// @notice Allows the contract owner to withdraw the entire balance of Ether or any ERC20 token from the contract.
    /// @dev This function can only be called by the owner of the contract.
    /// @param _tokenToWithdraw The address of the asset to be transfered.
    /// @param _amountToWithdraw The amount of the asset to be transfered.
    function emergencyWithdraw(
        address _tokenToWithdraw,
        uint256 _amountToWithdraw
    ) public onlyOwner {
        if (_tokenToWithdraw == address(0)) {
            address payable to = payable(msg.sender);
            (bool sent, ) = to.call{value: _amountToWithdraw}("");
            if (!sent) {
                revert FailedToSendNative();
            }
        } else {
            IERC20(_tokenToWithdraw).transfer(msg.sender, _amountToWithdraw);
        }
        emit EmergencyWithdraw(_tokenToWithdraw, _amountToWithdraw);
    }
}
