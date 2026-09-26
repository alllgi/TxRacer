// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {UUPSUpgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IStrategyBase} from "../interfaces/IStrategyBase.sol";
import {ErrorLib} from "../lib/ErrorLib.sol";

/// @title The Strategy Base
/// @author @nimbora 2024
abstract contract StrategyBase is IStrategyBase, Initializable, UUPSUpgradeable {
    address public poolingManager;
    address public underlyingToken;
    address public yieldToken;
    address public bridge;

    function _strategyBase__init(
        address _poolingManager,
        address _underlyingToken,
        address _yieldToken,
        address _bridge
    ) internal {
        poolingManager = _poolingManager;
        underlyingToken = _underlyingToken;
        yieldToken = _yieldToken;
        bridge = _bridge;
    }

    function depositCalldata(uint256 _amount) external view virtual returns (address, bytes memory);

    function addressToApprove() external view virtual returns (address);

    function _yieldToUnderlying(uint256 _amount) internal view virtual returns (uint256);

    function _underlyingToYield(uint256 _amount) internal view virtual returns (uint256);

    function _withdraw(uint256 _amount) internal virtual returns (uint256);

    /// @dev Authorizes an upgrade to a new contract implementation, ensuring that only an authorized role can perform the upgrade.
    function _authorizeUpgrade(address) internal view override {
        _assertOnlyRoleOwner();
    }

    function withdraw(uint256 _amount) external returns (uint256) {
        if (msg.sender != poolingManager) revert ErrorLib.CallerIsNotPoolingManager();
        return _withdraw(_amount);
    }

    function nav() external view returns (uint256) {
        return _nav();
    }

    function yieldToUnderlying(uint256 _amount) external view returns (uint256) {
        return _yieldToUnderlying(_amount);
    }

    function underlyingToYield(uint256 _amount) external view returns (uint256) {
        return _underlyingToYield(_amount);
    }

    function yieldBalance() external view returns (uint256) {
        return _yieldBalance();
    }

    function _assertOnlyRoleOwner() internal view {
        if (!IAccessControl(poolingManager).hasRole(0, msg.sender)) revert ErrorLib.CallerIsNotAdmin();
    }

    function _yieldBalance() internal view returns (uint256) {
        return IERC20(yieldToken).balanceOf(address(this));
    }

    function _nav() internal view returns (uint256) {
        return _yieldToUnderlying(_yieldBalance());
    }
}
