// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../access_controller/PlatformAccessController.sol';

import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';
import "./IplatformToken/IERC20FixedSupply.sol";

interface IAntisnipe {
    function assureCanTransfer(
        address sender,
        address from,
        address to,
        uint256 amount
    ) external;
}

/**
 * @notice ERC20 token with antisnipe functionality
 */
contract ERC20FixedSupply is ERC20, PlatformAccessController, IERC20FixedSupply {
    using SafeERC20Upgradeable for IERC20;

    IAntisnipe public antisnipe;
    bool public antisnipeDisable;

    event AntisnipeDisabled(
        uint256 timestamp
    );

    event AntisnipeUpdated(
        address _address,
        uint256 timestamp
    );

    error InvalidAddress();
    error ZeroAmount();
    error InvalidSender();
    error AntisnipeAlreadyDisabled();

    /**
     * @param adminPanel platform admin panel address
     */
    constructor(
        address adminPanel,
        address recipient,
        uint256 supply
    ) ERC20('welf', '$WELF') {
        if(adminPanel == address(0) || recipient == address(0))
            revert InvalidAddress();
        if(supply == 0)
            revert ZeroAmount();

        _initiatePlatformAccessController(adminPanel);
        _mint(recipient, supply);
    }

    /**
     * @dev Call before transfer
     * @param to address to tokens are transferring
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (from == address(0) || to == address(0)) return;
        if (!antisnipeDisable && address(antisnipe) != address(0))
            antisnipe.assureCanTransfer(msg.sender, from, to, amount);
    }

    function setAntisnipeDisable() external onlyPlatformAdmin {
        if(antisnipeDisable)
            revert AntisnipeAlreadyDisabled();
        antisnipeDisable = true;

        emit AntisnipeDisabled(block.timestamp);
    }

    function setAntisnipeAddress(address addr) external onlyPlatformAdmin {
        if(addr == address(0))
            revert InvalidAddress();
        antisnipe = IAntisnipe(addr);

        emit AntisnipeUpdated(addr, block.timestamp);
    }
}
