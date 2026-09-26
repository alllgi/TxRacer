// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {StrategyBase} from "../StrategyBase.sol";
import {ErrorLib} from "../../lib/ErrorLib.sol";
import {ISavingDai} from "../../interfaces/ISavingDai.sol";

/// @title Saving Dai
/// @author @nimbora 2024
contract SavingDaiStrategy is StrategyBase {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        address _poolingManager,
        address _underlyingToken,
        address _yieldToken,
        address _bridge
    ) external initializer {
        if (ISavingDai(_yieldToken).dai() != _underlyingToken) revert ErrorLib.InvalidUnderlyingToken();
        _strategyBase__init(_poolingManager, _underlyingToken, _yieldToken, _bridge);
    }

    /// @inheritdoc	StrategyBase
    function addressToApprove() external view override returns (address) {
        return (yieldToken);
    }

    /// @inheritdoc	StrategyBase
    function depositCalldata(uint256 _amount) external view override returns (address target, bytes memory cdata) {
        target = yieldToken;
        cdata = abi.encodeWithSignature("deposit(uint256,address)", _amount, address(this));
    }

    /// @inheritdoc	StrategyBase
    function _withdraw(uint256 _amount) internal override returns (uint256) {
        uint256 yieldAmountToWithdraw = ISavingDai(yieldToken).previewWithdraw(_amount);
        uint256 strategyYieldBalance = _yieldBalance();
        if (yieldAmountToWithdraw > strategyYieldBalance) {
            return ISavingDai(yieldToken).redeem(strategyYieldBalance, poolingManager, address(this));
        } else {
            ISavingDai(yieldToken).withdraw(_amount, poolingManager, address(this));
            return (_amount);
        }
    }

    /// @inheritdoc	StrategyBase
    function _underlyingToYield(uint256 _amount) internal view override returns (uint256) {
        return ISavingDai(yieldToken).previewDeposit(_amount);
    }

    /// @inheritdoc	StrategyBase
    function _yieldToUnderlying(uint256 _amount) internal view override returns (uint256) {
        return ISavingDai(yieldToken).previewRedeem(_amount);
    }
}
