// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ErrorLib} from "../lib/ErrorLib.sol";
import {IStrategyBase} from "../interfaces/IStrategyBase.sol";
import {IWETH} from "../interfaces/IWETH.sol";

/// @title The PoolingManagerBase
/// @author @nimbora 2024
abstract contract PoolingManagerBase is UUPSUpgradeable, AccessControlUpgradeable {
    using SafeERC20 for IERC20;
    /// @notice The startegy action.
    enum Action {
        DEPOSIT,
        UPDATE,
        WITHDRAW
    }

    /// @notice The bridge data used to interact with L2 bridges.
    /// @param bridge the bridge address
    /// @param amount the bridge address
    struct BridgeData {
        address bridge;
        address underlying;
        uint256 amount;
    }

    /// @notice The bridge data used to interact with L2 bridges.
    /// @param l1Strategy the strategy address.
    /// @param data the data, it can be l1 net asset value (nav) or the action.
    /// @param amount the amount to deposit/withdraw from the strategy.
    /// @param processed return the status of the strategy if it was processed on L1 or not.
    struct StrategyReport {
        address l1Strategy;
        uint256 data;
        uint256 amount;
        bool processed;
    }

    struct ReportProcessingData {
        IStrategyBase strategy;
        uint256 action;
        uint256 amountIn;
        bool allowRevert;
    }

    /// @notice Emitted when a report is handled.
    /// @param epoch the report epoch.
    /// @param reports the list of  strategies updated.
    event ReportHandled(uint256 epoch, StrategyReport[] reports);

    /// @notice Emitted when a strategy is registred.
    /// @param strategy the strategy address.
    event StrategyRegistered(address strategy);

    /// @notice Relayer role.
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    /// @notice ethBridge address.
    address public ethBridge;

    /// @notice wETH address.
    address public wETH;

    /// @notice Initialize the base pooling manager.
    /// @param _admin the admin address.
    /// @param _relayer the relayer address.
    /// @param _ethBridge the eth bridge address.
    function __poolingManagerBase_init(
        address _admin,
        address _relayer,
        address _ethBridge,
        address _wETH
    ) internal initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(RELAYER_ROLE, _relayer);
        ethBridge = _ethBridge;
        wETH = _wETH;
    }

    /// @dev Verifies the L2 calldata hash to ensure it matches the expected value. This is a security measure to ensure data integrity between L1 and L2.
    function _verifyL2Calldata(uint256 _dataHash) internal virtual;

    /// @dev Sends a message to L2, including necessary data and fees. This function is part of the cross-layer communication process.
    function _sendMessageL2(uint256 _epoch, uint256 _dataHash, uint256 _fees) internal virtual;

    /// @dev Withdraws a specified token amount from a given bridge. This is a lower-level function used by '_withdrawFromBridges'.
    function _withdrawTokenFromBridgeL2(address _bridge, address _token, uint256 _amount) internal virtual;

    /// @dev Deposits a specified token amount to a given bridge, including the handling of Ether conversions if necessary.
    function _depositTokenToBridgeL2(address _bridge, address _token, uint256 _amount, uint256 _value) internal virtual;

    /// @dev Deposits a specified token amount to a given bridge, including the handling of Ether conversions if necessary.
    function getUnderlyingTokenForBridge(address underlying) public view virtual returns (address);

    /// @dev Authorizes an upgrade to a new contract implementation, ensuring that only an authorized role can perform the upgrade.
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    /// @notice List a new strategy.
    /// @param _strategy the strategy address.
    function registerStrategy(address _strategy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IStrategyBase strategy = IStrategyBase(_strategy);
        address underlying = strategy.underlyingToken();
        address bridge = strategy.bridge();
        address addressToApprove = strategy.addressToApprove();

        uint256 currentAllowance = IERC20(underlying).allowance(address(this), bridge);
        uint256 maxAllowance = type(uint256).max;

        if (currentAllowance < maxAllowance) {
            uint256 necessaryIncrease = maxAllowance - currentAllowance;
            IERC20(underlying).safeIncreaseAllowance(bridge, necessaryIncrease);
        }

        currentAllowance = IERC20(underlying).allowance(address(this), addressToApprove);
        if (currentAllowance < maxAllowance) {
            uint256 necessaryIncrease = maxAllowance - currentAllowance;
            IERC20(underlying).safeIncreaseAllowance(addressToApprove, necessaryIncrease);
        }

        if (strategy.poolingManager() != address(this)) revert ErrorLib.InvalidPoolingManager();
        emit StrategyRegistered(_strategy);
    }

    /// @notice Handle a report.
    /// @param _epoch the epoch of the report.
    /// @param _bridgeWithdrawInfo a list of {bridgeAddress,amount} to withdraw from the bridges.
    /// @param _strategyReport the strategy to apply, can be DEPOSIT, WITHDRAW, UPDATE.
    /// @param _bridgeDepositInfo a list of {bridgeAddress,amount} to deposit into the bridges, those values are computed on L2.
    /// @param _l2BridgeEthFee the fees to pay for briding tokens to L2.
    /// @param _l2MessagingEthFee the fees to pay for briding message to L2.
    /// @param _revertIfOneCallFail the fees to pay for briding message to L2.
    function handleReport(
        uint256 _epoch,
        BridgeData[] memory _bridgeWithdrawInfo,
        StrategyReport[] memory _strategyReport,
        BridgeData[] memory _bridgeDepositInfo,
        bool[] memory _allowRevert,
        uint256 _l2BridgeEthFee,
        uint256 _l2MessagingEthFee,
        bool _revertIfOneCallFail
    ) external payable onlyRole(RELAYER_ROLE) returns (bool) {
        _verifyL2Calldata(hashFromReport(_epoch, _bridgeWithdrawInfo, _strategyReport, _bridgeDepositInfo, true));
        _withdrawFromBridges(_bridgeWithdrawInfo); // @audit-info withdraw from L2s
        (bool processed, BridgeData[] memory mergedBridgeData) = _handleReport(
            _strategyReport,
            _bridgeDepositInfo,
            _allowRevert
        );
        if (_revertIfOneCallFail && processed == false) {
            revert("One call failed");
        }
        _depositToBridges(mergedBridgeData, _l2BridgeEthFee);
        BridgeData[] memory emptyBridgeInfo = new BridgeData[](0);
        _sendMessageL2(
            _epoch,
            hashFromReport(0, emptyBridgeInfo, _strategyReport, emptyBridgeInfo, false),
            _l2MessagingEthFee
        );
        emit ReportHandled(_epoch, _strategyReport);
        return processed;
    }

    /// @dev Handles the withdrawal of funds from various bridges. It iterates over bridge withdrawal info and performs each withdrawal.
    function _withdrawFromBridges(BridgeData[] memory _bridgeWithdrawalInfo) internal {
        for (uint256 i = 0; i < _bridgeWithdrawalInfo.length; ) {
            BridgeData memory bridgeDataElem = _bridgeWithdrawalInfo[i];
            _withdrawTokenFromBridgeL2(bridgeDataElem.bridge, bridgeDataElem.underlying, bridgeDataElem.amount);
            if (bridgeDataElem.bridge == ethBridge) {
                IWETH(wETH).deposit{value: bridgeDataElem.amount}();
            }
            unchecked {
                i++;
            }
        }
    }

    /// @dev Deposits funds to bridges as part of the bridging process. This function handles both Ether and token deposits.
    function _depositToBridges(BridgeData[] memory _bridgeDepositInfo, uint256 _l2BridgeEthFee) internal {
        for (uint256 i = 0; i < _bridgeDepositInfo.length; ) {
            BridgeData memory bridgeDataElem = _bridgeDepositInfo[i];
            uint256 bridgeAmount = bridgeDataElem.amount;
            if (bridgeAmount > 0) {
                bool isETH = bridgeDataElem.bridge == ethBridge;
                if (isETH) {
                    IWETH(wETH).withdraw(bridgeAmount);
                }
                uint256 value = isETH ? bridgeAmount + _l2BridgeEthFee : _l2BridgeEthFee;
                _depositTokenToBridgeL2(bridgeDataElem.bridge, bridgeDataElem.underlying, bridgeAmount, value);
            }
            unchecked {
                i++;
            }
        }
    }

    /// @dev Process strategy reports from L2, handling each report based on its type (deposit, withdrawal, etc.) and updates the state accordingly.
    function _handleReport(
        StrategyReport[] memory _report,
        BridgeData[] memory _bridgeData,
        bool[] memory _allowRevert
    ) private returns (bool, BridgeData[] memory) {
        bool allStrategiesProcessed = true;
        BridgeData[] memory newBridgeDepositInfos = new BridgeData[](_report.length);
        uint256 newBridgeDepositInfosLength = 0;

        for (uint256 i = 0; i < _report.length; i++) {
            ReportProcessingData memory data = ReportProcessingData({
                strategy: IStrategyBase(_report[i].l1Strategy),
                action: _report[i].data,
                amountIn: _report[i].amount,
                allowRevert: _allowRevert[i]
            });
            bool processed = true;
            uint256 amount = 0;

            if (data.action == uint256(Action.DEPOSIT)) {
                BridgeData memory newBridgeDataElem;
                (processed, amount, newBridgeDataElem) = _handleDeposit(data, _bridgeData, newBridgeDepositInfos);
                if (newBridgeDataElem.bridge != address(0)) {
                    newBridgeDepositInfos[newBridgeDepositInfosLength] = newBridgeDataElem;
                    newBridgeDepositInfosLength++;
                }
            }

            if (data.action == uint256(Action.WITHDRAW)) {
                (processed, amount) = _handleWithdraw(data, _bridgeData);
            }

            _updateReport(_report, i, data, amount, processed);

            if (!processed) {
                allStrategiesProcessed = false;
            }
        }

        if (newBridgeDepositInfosLength > 0) {
            BridgeData[] memory mergedBridgeData;
            uint256 bridgeDataLength = _bridgeData.length;
            mergedBridgeData = new BridgeData[](bridgeDataLength + newBridgeDepositInfosLength);
            for (uint256 j = 0; j < bridgeDataLength; j++) {
                mergedBridgeData[j] = _bridgeData[j];
            }
            for (uint256 k = 0; k < newBridgeDepositInfosLength; k++) {
                mergedBridgeData[bridgeDataLength + k] = newBridgeDepositInfos[k];
            }
            return (allStrategiesProcessed, mergedBridgeData);
        } else {
            return (allStrategiesProcessed, _bridgeData);
        }
    }

    function _handleDeposit(
        ReportProcessingData memory data,
        BridgeData[] memory _bridgeData,
        BridgeData[] memory _newBridgeData
    ) private returns (bool processed, uint256 amount, BridgeData memory newBridgeDataElem) {
        uint256 amountIn = data.amountIn;
        IStrategyBase l1Strategy = data.strategy;
        (address target, bytes memory cdata) = l1Strategy.depositCalldata(amountIn);
        (bool success, ) = target.call(cdata);
        if (!success) {
            amount = amountIn;
            if (!data.allowRevert) {
                address strategyBridge = l1Strategy.bridge();
                bool found = _updateBridgeDeposits(true, amount, strategyBridge, _bridgeData);
                if (!found) {
                    bool found2 = _updateBridgeDeposits(true, amount, strategyBridge, _newBridgeData);
                    if (!found2) {
                        newBridgeDataElem = BridgeData(
                            strategyBridge,
                            getUnderlyingTokenForBridge(l1Strategy.underlyingToken()),
                            amount
                        );
                    }
                }
            }
            return (false, amount, newBridgeDataElem);
        }
        return (true, 0, newBridgeDataElem);
    }

    function _handleWithdraw(
        ReportProcessingData memory data,
        BridgeData[] memory _bridgeData
    ) private returns (bool processed, uint256 amount) {
        uint256 amountIn = data.amountIn;
        IStrategyBase l1Strategy = data.strategy;
        try l1Strategy.withdraw(amountIn) returns (uint256 amountw) {
            amount = amountw;

            //update bridge deposit amount, if withdraw different than expected. Bridge elements are always there built from l2.
            if (amount > amountIn) {
                _updateBridgeDeposits(true, amount - amountIn, l1Strategy.bridge(), _bridgeData);
            } else {
                if (amount < amountIn) {
                    _updateBridgeDeposits(false, amountIn - amount, l1Strategy.bridge(), _bridgeData);
                }
            }
            return (true, amount);
        } catch {
            //update bridge deposit amount, if withdraw different tham expected. Bridge elements are always there built from l2.
            _updateBridgeDeposits(false, amountIn, l1Strategy.bridge(), _bridgeData);
            if (data.allowRevert) {
                amount = amountIn;
            }
            return (false, amount);
        }
    }

    function _updateReport(
        StrategyReport[] memory _report,
        uint256 index,
        ReportProcessingData memory data,
        uint256 amount,
        bool processed
    ) internal view {
        IStrategyBase l1Strategy = data.strategy;
        if (processed) {
            _report[index] = StrategyReport({
                l1Strategy: address(l1Strategy),
                data: l1Strategy.nav(),
                amount: amount,
                processed: true
            });
        } else {
            if (data.allowRevert) {
                _report[index] = StrategyReport({
                    l1Strategy: address(l1Strategy),
                    data: data.action,
                    amount: amount,
                    processed: false
                });
            } else {
                _report[index] = StrategyReport({
                    l1Strategy: address(l1Strategy),
                    data: l1Strategy.nav(),
                    amount: amount,
                    processed: true
                });
            }
        }
    }

    /// @dev When the output amount returned by a strategy is not the expected value, the bridged amount is updated.
    function _updateBridgeDeposits(
        bool _add,
        uint256 _amount,
        address _bridge,
        BridgeData[] memory _bridgeDepositInfos
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _bridgeDepositInfos.length; ) {
            BridgeData memory bridgeDepositInfoElem = _bridgeDepositInfos[i];
            if (bridgeDepositInfoElem.bridge == _bridge) {
                if (_add) {
                    _bridgeDepositInfos[i].amount = _bridgeDepositInfos[i].amount + _amount;
                } else {
                    _bridgeDepositInfos[i].amount = _bridgeDepositInfos[i].amount - _amount;
                }
                return (true);
            }
            unchecked {
                i++;
            }
        }
        return (false);
    }

    /// @dev Generates a hash from a strategy report and bridge interaction information, used for data verification and integrity checks.
    function hashFromReport(
        uint256 _epoch,
        BridgeData[] memory _bridgeWithdrawInfo,
        StrategyReport[] memory _strategyReport,
        BridgeData[] memory _bridgeDepositInfo,
        bool _includeLen
    ) public pure returns (uint256) {
        bytes memory encodedData = _epoch != 0 ? abi.encodePacked(_epoch) : abi.encodePacked();

        uint256 len = _bridgeWithdrawInfo.length;
        if (_includeLen) {
            encodedData = abi.encodePacked(encodedData, len);
        }
        for (uint256 i = 0; i < len; ) {
            encodedData = abi.encodePacked(
                encodedData,
                uint256(uint160(_bridgeWithdrawInfo[i].bridge)),
                _bridgeWithdrawInfo[i].amount
            );
            unchecked {
                i++;
            }
        }

        len = _strategyReport.length;
        if (_includeLen) {
            encodedData = abi.encodePacked(encodedData, len);
        }

        for (uint256 i = 0; i < len; ) {
            encodedData = abi.encodePacked(
                encodedData,
                uint256(uint160(_strategyReport[i].l1Strategy)),
                _strategyReport[i].data,
                _strategyReport[i].amount
            );
            encodedData = abi.encodePacked(encodedData, uint256(_strategyReport[i].processed ? 1 : 0));
            unchecked {
                i++;
            }
        }

        len = _bridgeDepositInfo.length;
        if (_includeLen) {
            encodedData = abi.encodePacked(encodedData, len);
        }
        for (uint256 i = 0; i < len; ) {
            encodedData = abi.encodePacked(
                encodedData,
                uint256(uint160(_bridgeDepositInfo[i].bridge)),
                _bridgeDepositInfo[i].amount
            );
            unchecked {
                i++;
            }
        }
        return uint256(keccak256(encodedData));
    }

    receive() external payable {}

    fallback() external payable {}
}
