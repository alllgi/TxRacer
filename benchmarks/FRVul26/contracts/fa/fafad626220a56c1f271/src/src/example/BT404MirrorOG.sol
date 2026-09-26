// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IERC721Metadata} from "../external/IERC721Metadata.sol";
import {BT404Mirror} from "../BT404Mirror.sol";
import {BT404MirrorWrapper} from "../BT404MirrorWrapper.sol";
import {UUPSUpgradeable} from "solady/utils/UUPSUpgradeable.sol";
import {OwnableRoles} from "solady/auth/OwnableRoles.sol";

contract BT404MirrorOG is BT404MirrorWrapper, UUPSUpgradeable {
    /// @dev The role that can upgrade the implementation.
    /// Keep it the same as the base contract.
    uint256 private constant _UPGRADE_MANAGER_ROLE = 1 << 61;

    // init with `address(1)` to prevent double-initializing
    constructor() payable BT404MirrorWrapper() {
        _initializeBT404MirrorWrapper(address(1), address(1), 0, 0);
    }

    modifier onlyUpgradeRole() {
        _checkUpgradeRole();
        _;
    }

    function _checkUpgradeRole() internal view {
        if (!OwnableRoles(baseERC20()).hasAnyRole(msg.sender, _UPGRADE_MANAGER_ROLE)) {
            revert Unauthorized();
        }
    }

    function _authorizeUpgrade(address) internal override onlyUpgradeRole {}

    function initialize(address _baseERC721, uint256 _startBaseId, uint256 _endBaseId)
        public
        payable
    {
        // if deployer was set, can not initialize again
        if (_getBT404NFTStorage().deployer != address(0)) revert Unauthorized();

        _initializeBT404MirrorWrapper(msg.sender, _baseERC721, _startBaseId, _endBaseId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        IERC721Metadata base = IERC721Metadata(baseERC721());
        try base.tokenURI(tokenId) returns (string memory res) {
            return res;
        } catch (bytes memory) {
            return super.tokenURI(tokenId);
        }
    }
}
