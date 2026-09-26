// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/* == UTILS == */
import {wmul} from "@utils/Math.sol";

/* == OZ == */
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/* == INTERFACES == */
import {IVolt} from "@interfaces/IVolt.sol";

/* == CONST == */
import "@const/Constants.sol";

/**
 * @title TheVolt
 * @author Zyntek
 * @notice This contract acumulates VOLT from the buy and burn and later distributes them to the auction for recycling
 */
contract TheVolt {
    using SafeERC20 for IVolt;

    /* === IMMUTABLES === */
    IVolt immutable volt;
    address immutable auction;

    /* === ERRORS === */
    error TheVolt__OnlyAuction();

    /* === CONSTRUCTOR === */
    constructor(address _auction, address _volt) {
        auction = _auction;
        volt = IVolt(_volt);
    }

    /* === MODIFIERS === */

    modifier onlyAuction() {
        _onlyAuction();
        _;
    }

    /* === EXTERNAL === */
    function emitForAuction() external onlyAuction returns (uint256 emitted) {
        uint256 balanceOf = volt.balanceOf(address(this));

        emitted = wmul(balanceOf, DISTRIBUTION_FROM_THE_VOLT);

        volt.safeTransfer(msg.sender, emitted);
    }

    /* === INTERNAL === */
    function _onlyAuction() internal view {
        if (msg.sender != auction) revert TheVolt__OnlyAuction();
    }
}
