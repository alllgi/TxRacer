// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

interface IVerifier {
    function verify(address from, address to) external returns (bool);
}