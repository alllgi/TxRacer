// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

interface IERC721A {
    function totalSupply() external returns (uint256);
    function ownerOf(uint256) external returns (address);
}