// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHandlerReserve {
    function _lpToContract(address token) external returns (address);

    function _contractToLP(address token) external returns (address);
}
