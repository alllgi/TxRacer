// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {StarknetMessaging} from "../../lib/StarknetMessaging.sol";
import {PoolingManagerBase} from "../PoolingManagerBase.sol";

/// @title Starknet Pooling manager contract.
/// @author @nimbora 2024
contract StarknetPoolingManager is StarknetMessaging, PoolingManagerBase {
    /// @notice Emitted when the func 'cancelDepositRequestBridge' is called
    /// @param bridge the bridge address.
    /// @param amount the amount to claim from the bridge.
    /// @param nonce the deposit nonce.
    event BridgeCancelDepositRequestClaimed(address bridge, uint256 amount, uint256 nonce);

    /// @notice Emitted when the func 'cancelDepositRequestBridge' is called
    /// @param bridge the bridge address.
    /// @param amount the amount to claim from the bridge.
    /// @param nonce the deposit nonce.
    event CancelDepositRequestBridgeSent(address bridge, uint256 amount, uint256 nonce);

    /// @notice The L2 Pooling manager address.
    uint256 public l2PoolingManager;

    /// @notice The L2 function selector that is called by the sequencer when the message is sent to the L2 Pooling manager.
    uint256 private constant L2_HANDLER_SELECTOR = 0x10e13e50cb99b6b3c8270ec6e16acfccbe1164a629d74b43549567a77593aff;

    address public ethSymbolBridge;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    /// @notice Initialize the Starknet pooling manager contract.
    /// @param _admin the admin address.
    /// @param _l2PoolingManager the l2 pooling manager address.
    /// @param _starknetCore the Starknet core contract, used to bridge messages.
    /// @param _relayer the relayer address.
    /// @param _ethBridge the eth bridge address.
    /// @param _wETH the weth address.
    function initialize(
        address _admin,
        uint256 _l2PoolingManager,
        address _starknetCore,
        address _relayer,
        address _ethBridge,
        address _wETH
    ) external initializer {
        __messaging_init(_starknetCore);
        __poolingManagerBase_init(_admin, _relayer, _ethBridge, _wETH);
        l2PoolingManager = _l2PoolingManager;
    }

    function setEthSymbolBridge(address _ethSymbolBridge) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ethSymbolBridge = _ethSymbolBridge;
    }

    /// @dev Cancel the deposited tokens when they get stuck. If the fees paid to bridge the tokens are not enough to incentive the sequencer
    /// it's possible that the tokens will stay blocked. By calling this function the admin can claim back the tokens.
    /// @param _bridge the bridge address.
    /// @param _amount the amount deposited.
    /// @param _nonce the nonce of the deposit.
    function cancelDepositRequestBridge(
        address _bridge,
        address _token,
        uint256 _amount,
        uint256 _nonce
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        depositCancelRequestToBridgeToken(_bridge, _token, l2PoolingManager, _amount, _nonce);
        emit CancelDepositRequestBridgeSent(_bridge, _amount, _nonce);
    }

    /// @dev After calling the 'cancelDepositRequestBridge' the tokens are available after 7days, as this time is too long
    /// the admin will send the tokens to L2 and claim back the blocked tokens when they are released by calling this func.
    /// @param _bridge the bridge address.
    /// @param _token the token address.
    /// @param _amount the amount deposited.
    /// @param _nonce the nonce of the deposit.
    function claimBridgeCancelDepositRequest(
        address _bridge,
        address _token,
        uint256 _amount,
        uint256 _nonce
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        depositReclaimToBridgeToken(_bridge, _token, l2PoolingManager, _amount, _nonce);
        if (_bridge == ethBridge) {
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(_token).transfer(msg.sender, _amount);
        }
        emit BridgeCancelDepositRequestClaimed(_bridge, _amount, _nonce);
    }

    /// @inheritdoc	PoolingManagerBase
    function _withdrawTokenFromBridgeL2(address _bridge, address _token, uint256 _amount) internal override {
        _withdrawTokenFromBridge(_bridge, _token, _amount, address(this));
    }

    /// @inheritdoc	PoolingManagerBase
    function _depositTokenToBridgeL2(
        address _bridge,
        address _token,
        uint256 _amount,
        uint256 _value
    ) internal override {
        depositToBridgeToken(_bridge, _token, l2PoolingManager, _amount, _value);
    }

    /// @inheritdoc	PoolingManagerBase
    function _verifyL2Calldata(uint256 _dataHash) internal override {
        _consumeL2Message(l2PoolingManager, _getMessagePayloadData(0, _dataHash));
    }

    function getUnderlyingTokenForBridge(address _underlying) public view override returns (address) {
        if (_underlying == wETH) {
            return (ethSymbolBridge);
        } else {
            return (_underlying);
        }
    }

    /// @inheritdoc	PoolingManagerBase
    function _sendMessageL2(uint256 _epoch, uint256 _dataHash, uint256 _fees) internal override {
        _sendMessageToL2(l2PoolingManager, L2_HANDLER_SELECTOR, _getMessagePayloadData(_epoch, _dataHash), _fees);
    }

    /// @dev hash Starknet message payload.
    function _getMessagePayloadData(uint256 _epoch, uint256 _dataHash) internal pure returns (uint256[] memory) {
        uint256[] memory data;
        (uint256 lowHash, uint256 highHash) = u256(_dataHash);
        if (_epoch == 0) {
            data = new uint256[](2);
            data[0] = lowHash;
            data[1] = highHash;
        } else {
            (uint256 lowEpoch, uint256 highEpoch) = u256(_epoch);
            data = new uint256[](4);
            data[0] = lowEpoch;
            data[1] = highEpoch;
            data[2] = lowHash;
            data[3] = highHash;
        }
        return (data);
    }
}
