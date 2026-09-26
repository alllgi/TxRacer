// SPDX-License-Identifier: ISC
pragma solidity 0.8.22;

interface IMakerPSM {
    function sellGem(address usr, uint256 gemAmt) external;
    function buyGem(address usr, uint256 gemAmt) external;
}
