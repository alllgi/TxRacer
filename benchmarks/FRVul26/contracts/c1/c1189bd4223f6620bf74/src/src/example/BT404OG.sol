// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {BT404} from "../BT404.sol";
import {BT404NFTMinter} from "../BT404NFTMinter.sol";
import {OwnableRoles} from "solady/auth/OwnableRoles.sol";
import {UUPSUpgradeable} from "solady/utils/UUPSUpgradeable.sol";
import {LibString} from "solady/utils/LibString.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

contract BT404OG is BT404NFTMinter, OwnableRoles, UUPSUpgradeable {
    /// @dev The role that can upgrade the implementation.
    uint256 private constant _UPGRADE_MANAGER_ROLE = _ROLE_61;
    /// @dev The role that can update the metadata of the contract.
    uint256 private constant _METADATA_MANAGER_ROLE = _ROLE_91;
    /// @dev The role that can update the fee configurations of the contract.
    uint256 private constant _FEE_MANAGER_ROLE = _ROLE_101;
    /// @dev The role that can update the fee configurations of the contract.
    uint256 private constant _NFT_SKIPPING_MANAGER_ROLE = _ROLE_111;

    string private _name;
    string private _symbol;
    string private _baseURI;

    constructor() payable {
        _initializeOwner(address(1));
    }

    function _authorizeUpgrade(address) internal override onlyRoles(_UPGRADE_MANAGER_ROLE) {}

    function _guardInitializeOwner() internal pure virtual override returns (bool) {
        return true;
    }

    function initialize(string memory name_, string memory symbol_, address mirror)
        public
        payable
    {
        _initializeOwner(msg.sender);
        _initializeBT404(0, address(0), mirror);

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        result = string(abi.encodePacked(_baseURI, LibString.toString(tokenId)));
    }

    function setNameAndSymbol(string calldata name_, string calldata symbol_)
        public
        onlyRoles(_METADATA_MANAGER_ROLE)
    {
        _name = name_;
        _symbol = symbol_;
    }

    function setBaseURI(string calldata baseURI_) public onlyRoles(_METADATA_MANAGER_ROLE) {
        _baseURI = baseURI_;
    }

    function setSkipNFTFor(address account, bool state)
        public
        onlyRoles(_NFT_SKIPPING_MANAGER_ROLE)
    {
        _setSkipNFT(account, state);
    }

    function setExchangeNFTFeeRate(uint256 feeBips) public onlyRoles(_FEE_MANAGER_ROLE) {
        _setExchangeNFTFeeRate(feeBips);
    }

    function setListMarketNFTFeeRate(uint256 feeBips) public onlyRoles(_FEE_MANAGER_ROLE) {
        _setListMarketFeeRate(feeBips);
    }

    function withdraw(address token) public onlyRoles(_FEE_MANAGER_ROLE) {
        Uint256Ref storage feesRef = _getBT404Storage().accountedFees[token];
        uint256 amount = feesRef.value;
        feesRef.value = 0;
        if (token == address(0)) {
            SafeTransferLib.safeTransferETH(msg.sender, amount);
        } else {
            SafeTransferLib.safeTransfer(token, msg.sender, amount);
        }
    }
}
