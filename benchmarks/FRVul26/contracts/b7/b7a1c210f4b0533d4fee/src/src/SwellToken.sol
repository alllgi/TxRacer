// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// SWELL ERC20 contract
contract SwellToken is ERC20 {
    constructor(address _receiver, uint256 _totalSupply) ERC20("Swell Governance Token", "SWELL") {
        _mint(_receiver, _totalSupply);
    }
}
