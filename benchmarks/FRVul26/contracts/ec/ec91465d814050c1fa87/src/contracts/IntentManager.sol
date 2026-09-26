// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "./common/AdminUpgradeable.sol";
import "./interfaces/IIntentManager.sol";

contract IntentManager is IIntentManager, AdminUpgradeable, UUPSUpgradeable {
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    struct HelperInfo {
        address helper;
        uint64 addedAt;
    }
    mapping(uint256 => HelperInfo) public helperOf;

    EnumerableMapUpgradeable.AddressToUintMap internal customTaxPoints;

    address public taxRecipient;
    uint16 public defaultTaxPoint; // default tax point
    uint80 public taxForceClaimThreshold;
    bytes32 public operatorRoot;
    uint64 public pausedAt;
    uint64 public unpausableAt;
    uint32 public gasDeploy;
    uint32 public gasWithdraw;
    uint32 public gasHandle;
    uint32 public gasUnwrap;

    address public newImpl;
    uint64 public newImplApplyAt;

    constructor() {
        _disableInitializers();
    }

    function _isMainnet() internal view returns (bool) {
        return block.chainid == MAINNET_CHAINID;
    }

    function aaUpgradeTo(address _newImpl) external onlyProxy onlyAdmin {
        if (_newImpl != address(0)) {
            if (_newImpl == newImpl) {
                require(
                    !_isMainnet() || block.timestamp > newImplApplyAt,
                    "IM: not time to upgrade"
                );
                _upgradeToAndCallUUPS(_newImpl, new bytes(0), false);
            } else {
                newImpl = _newImpl;
                newImplApplyAt = uint64(block.timestamp + 3 days);
                return;
            }
        }
        newImpl = address(0);
        newImplApplyAt = 0;
    }

    function _authorizeUpgrade(address) internal virtual override {
        revert("IM: not supported");
    }

    function initialize(
        address _taxRecipient,
        bytes32 _operatorRoot,
        address[] calldata _admins
    ) external initializer {
        __UUPSUpgradeable_init();
        __Admin_init(_admins);
        operatorRoot = _operatorRoot;

        taxRecipient = _taxRecipient;
        defaultTaxPoint = 100; // 1%
        taxForceClaimThreshold = 0;

        gasDeploy = 65000;
        gasWithdraw = 43000;
        gasHandle = 35000;
        gasUnwrap = 30000;
    }

    function addIntentHelper(uint256 _intentId, address _helper) external onlyAdmin {
        require(_helper != address(0), "IM: zero address");
        require(helperOf[_intentId].helper == address(0), "IM: already exists");
        helperOf[_intentId] = HelperInfo({helper: _helper, addedAt: uint64(block.timestamp)});
    }

    function removeIntentHelper(uint256 intentId) external onlyAdmin {
        require(helperOf[intentId].helper != address(0), "IM: not exists");
        delete helperOf[intentId];
    }

    function setTaxRecipient(address _recipient) external onlyAdmin {
        require(_recipient != address(0), "IM: zero address");
        taxRecipient = _recipient;
    }

    function setDefaultTaxPoint(uint16 _defaultTaxPoint) external onlyAdmin {
        require(_defaultTaxPoint <= 10000, "IM: point too large");
        defaultTaxPoint = _defaultTaxPoint;
    }

    function setCustomTaxPoints(
        address[] calldata tokenAddresses,
        uint16 taxPoint
    ) external onlyAdmin {
        require(taxPoint <= 10000, "IM: point too large");
        for (uint256 i = 0; i < tokenAddresses.length; ++i) {
            require(tokenAddresses[i] != address(0), "IM: zero token address");
            customTaxPoints.set(tokenAddresses[i], taxPoint);
        }
    }

    function clearCustomTaxPoints(address[] calldata tokenAddresses) external onlyAdmin {
        for (uint256 i = 0; i < tokenAddresses.length; ++i) {
            customTaxPoints.remove(tokenAddresses[i]);
        }
    }

    function getTaxPoints(
        address[] calldata tokenAddresses
    ) external view returns (bool[] memory isCustom, uint256[] memory taxPoints) {
        isCustom = new bool[](tokenAddresses.length);
        taxPoints = new uint256[](tokenAddresses.length);
        for (uint256 i = 0; i < tokenAddresses.length; ++i) {
            (isCustom[i], taxPoints[i]) = customTaxPoints.tryGet(tokenAddresses[i]);
            if (!isCustom[i]) {
                taxPoints[i] = defaultTaxPoint;
            }
        }
    }

    function setTaxForceClaimThreshold(uint80 _threshold) external onlyAdmin {
        taxForceClaimThreshold = _threshold;
    }

    function setOperatorRoot(bytes32 newRoot) external onlyAdmin {
        operatorRoot = newRoot;
    }

    function pause(uint64 secs) external onlyAdmin {
        if (secs > 1 days) {
            secs = 1 days;
        }
        if (pausedAt > 0) {
            require(secs >= unpausableAt - pausedAt, "IM: time too short");
        }
        pausedAt = uint64(block.timestamp);
        unpausableAt = pausedAt + secs;
    }

    function unpause() external onlyAdmin {
        require(unpausableAt <= block.timestamp, "IM: not time yet");
        pausedAt = 0;
        unpausableAt = 0;
    }

    function setGasDeploy(uint32 newGasDeploy) external onlyAdmin {
        gasDeploy = newGasDeploy;
    }

    function setGasWithdraw(uint32 newGasWithdraw) external onlyAdmin {
        gasWithdraw = newGasWithdraw;
    }

    function setGasHandle(uint32 newGasHandle) external onlyAdmin {
        gasHandle = newGasHandle;
    }

    function setGasUnwrap(uint32 newGasUnwrap) external onlyAdmin {
        gasUnwrap = newGasUnwrap;
    }

    function isAAOperator(address account, bytes32[] calldata proofs) external view returns (bool) {
        return _isAAOperator(account, proofs);
    }

    function isAdmin(
        address account
    ) public view virtual override(AdminUpgradeable, IIntentManager) returns (bool) {
        return super.isAdmin(account);
    }

    function getTaxRecipient() external view returns (address) {
        return taxRecipient;
    }

    function isValidHelper(HelperInfo memory info) public view virtual returns (bool) {
        return
            info.helper != address(0) &&
            (!_isMainnet() || block.timestamp >= info.addedAt + 1 days);
    }

    function getValidHelper(uint256 intentId) external view returns (address) {
        HelperInfo memory info = helperOf[intentId];
        require(isValidHelper(info), "IM: no helper");
        return info.helper;
    }

    function _isAAOperator(
        address account,
        bytes32[] calldata proofs
    ) internal view returns (bool) {
        return
            super.isAdmin(account) ||
            MerkleProofUpgradeable.verify(
                proofs,
                operatorRoot,
                keccak256(bytes.concat(keccak256(abi.encode(account))))
            );
    }

    function verifyForDeploy(
        address account,
        bytes32[] calldata proofs
    ) external view returns (uint32) {
        require(pausedAt == 0, "IM: paused");
        require(_isAAOperator(account, proofs), "IM: not allowed");
        return gasDeploy;
    }

    function verifyForHandle(
        uint256 id,
        address account,
        bytes32[] calldata proofs
    ) external view returns (address, uint80, address, uint32, uint32) {
        require(pausedAt == 0, "IM: paused");
        require(_isAAOperator(account, proofs), "IM: not allowed");

        HelperInfo memory info = helperOf[id];
        require(isValidHelper(info), "IM: no helper");

        return (info.helper, taxForceClaimThreshold, taxRecipient, gasHandle, gasUnwrap);
    }

    function verifyForWithdraw(
        address account,
        bytes32[] calldata proofs
    ) external view returns (address, uint32) {
        require(_isAAOperator(account, proofs), "IM: not allowed");
        return (taxRecipient, gasWithdraw);
    }
}
