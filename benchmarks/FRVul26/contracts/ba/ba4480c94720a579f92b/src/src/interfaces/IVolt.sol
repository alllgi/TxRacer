// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {VoltAuction} from "@core/VoltAuction.sol";
import {TheVolt} from "@core/TheVolt.sol";

interface IVoltBuyAndBurn {
    function distributeTitanXForBurning(uint256 _amount) external;
}

interface IVolt is IERC20 {
    /* == ERRORS == */
    error Volt__OnlyAuction();

    /* == VIEW FUNCTIONS == */
    function auction() external view returns (VoltAuction);
    function buyAndBurn() external view returns (IVoltBuyAndBurn);
    function pool() external view returns (address);
    function theVolt() external view returns (TheVolt);

    /* == EXTERNAL FUNCTIONS == */
    function burn(uint256 amount) external;

    function emitForAuction() external returns (uint256 emitted);

    function emitForLp() external returns (uint256 emitted);
}
