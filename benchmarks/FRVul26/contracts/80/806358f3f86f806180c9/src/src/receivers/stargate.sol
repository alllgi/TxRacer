// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/security/Pausable.sol";
import "./helpers/Ownable.sol";

interface ILayerZeroComposer {
    function lzCompose(
        address _from,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable;
}

contract StargateReceiver is
    Ownable,
    Pausable,
    ReentrancyGuard,
    ILayerZeroComposer
{
    using SafeERC20 for IERC20;
    // address public stargateRouter;
    address public NATIVE_TOKEN_ADDRESS;
    uint256 defaultGas;

    mapping(address => bool) public blockList;
    mapping(address => bool) public allowedAddresses;

    event UpdateStargateRouterAddress(address indexed stargateRouterAddress);
    event PayloadExecuted(
        address indexed toAddress,
        uint256 amount,
        address token
    );
    event AddressBlocked(address indexed blockedAddress);
    event AddressUnblocked(address indexed unblockedAddress);
    event AddressAdded(address indexed account);

    constructor(
        address[] memory stargateAddresses,
        address _nativeTokenAddress,
        address _owner,
        uint256 _defaultGas
    ) Ownable(_owner) {
        // stargateRouter = _stargateRouter;
        NATIVE_TOKEN_ADDRESS = _nativeTokenAddress;
        defaultGas = _defaultGas;
        for (uint i = 0; i < stargateAddresses.length; i++) {
            allowedAddresses[stargateAddresses[i]] = true; // Setting each address to true
        }
    }

    modifier onlyStargateAddress() {
        require(allowedAddresses[msg.sender], "Address not allowed");
        _;
    }

    function addStargateAddress(address account) public onlyOwner {
        require(!allowedAddresses[account], "Address already in allow list");
        allowedAddresses[account] = true;
        emit AddressAdded(account);
    }

    modifier notBlocked(address _address) {
        require(!blockList[_address], "Address is blocked");
        _;
    }

    function blockAddress(address _address) external onlyOwner {
        blockList[_address] = true;
        emit AddressBlocked(_address);
    }

    function unblockAddress(address _address) external onlyOwner {
        blockList[_address] = false;
        emit AddressUnblocked(_address);
    }

    function setDefaultGas(uint256 _defaultGas) external onlyOwner {
        defaultGas = _defaultGas;
    }

    function setPause() public onlyOwner returns (bool) {
        _pause();
        return paused();
    }

    function setUnPause() public onlyOwner returns (bool) {
        _unpause();
        return paused();
    }

    function updateStargateRouterAddress(
        address newStargateRouter
    ) external onlyOwner {
        // stargateRouter = newStargateRouter;
        emit UpdateStargateRouterAddress(newStargateRouter);
    }

    function rescueFunds(
        address token,
        address userAddress,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).safeTransfer(userAddress, amount);
    }

    function rescueEther(
        address payable userAddress,
        uint256 amount
    ) external onlyOwner {
        userAddress.transfer(amount);
    }

    event ComposeAcknowledged(
        address indexed _from,
        bytes32 indexed _guid,
        bytes _message,
        address _executor,
        bytes _extraData
    );

    function lzCompose(
        address _from,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable override onlyStargateAddress nonReentrant whenNotPaused {
        emit ComposeAcknowledged(_from, _guid, _message, _executor, _extraData);

        uint256 amountLD = OFTComposeMsgCodec.amountLD(_message);
        bytes memory _composeMessage = OFTComposeMsgCodec.composeMsg(_message);

        (
            address payable toAddress,
            bytes memory dataPayload,
            address token
        ) = abi.decode(_composeMessage, (address, bytes, address));

        perfomAction(token, amountLD, toAddress, dataPayload);
    }

    function perfomAction(
        address token,
        uint256 amountLD,
        address payable toAddress,
        bytes memory dataPayload
    ) private notBlocked(toAddress) {
        if (token == NATIVE_TOKEN_ADDRESS) {
            (bool success, ) = toAddress.call{
                gas: gasleft() - defaultGas,
                value: amountLD
            }(dataPayload);
            require(success, "StargateReceiver: Failed to call");
        } else {
            IERC20(token).safeIncreaseAllowance(toAddress, amountLD);
            (bool success, ) = toAddress.call{gas: gasleft() - defaultGas}(
                dataPayload
            );
            IERC20(token).safeDecreaseAllowance(
                toAddress,
                IERC20(token).allowance(address(this), toAddress)
            );
            require(success, "StargateReceiver: Failed to call");
        }
        emit PayloadExecuted(toAddress, amountLD, token);
    }

    receive() external payable {}
}

library OFTComposeMsgCodec {
    uint8 private constant COMPOSE_FROM_OFFSET = 76;
    uint8 private constant SRC_EID_OFFSET = 12;
    uint8 private constant AMOUNT_LD_OFFSET = 44;
    /**
     * @dev Retrieves the amount in local decimals from the composed message.
     * @param _msg The message.
     * @return The amount in local decimals.
     */
    function amountLD(bytes calldata _msg) internal pure returns (uint256) {
        return uint256(bytes32(_msg[SRC_EID_OFFSET:AMOUNT_LD_OFFSET]));
    }

    /**
     * @dev Retrieves the composed message.
     * @param _msg The message.
     * @return The composed message.
     */
    function composeMsg(
        bytes calldata _msg
    ) internal pure returns (bytes memory) {
        return _msg[COMPOSE_FROM_OFFSET:];
    }
}
