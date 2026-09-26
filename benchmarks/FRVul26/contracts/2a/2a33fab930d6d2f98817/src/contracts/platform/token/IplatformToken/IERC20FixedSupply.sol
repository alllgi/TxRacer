// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20FixedSupply is IERC20{
    function setAntisnipeDisable() external;
    function setAntisnipeAddress(address addr) external;
}
