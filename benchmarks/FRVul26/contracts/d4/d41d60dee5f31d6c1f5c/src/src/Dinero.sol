// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {DineroERC20} from "./DineroERC20.sol";

/**
 * @title  Dinero
 * @notice Governance token contract for the Dinero ecosystem.
 * @dev    A standard ERC20 token with minting and burning, with access control.
 * @author dinero.protocol
 */
contract Dinero is DineroERC20 {
    /**
     * @notice Constructor to initialize the Dinero token.
     * @dev    Inherits from the DineroERC20 contract and sets the name, symbol, admin, and initial delay.
     * @param  _admin         address  Admin address.
     * @param  _initialDelay  uint48   Delay required to schedule the acceptance of an access control transfer started.
     */
    constructor(
        address _admin,
        uint48 _initialDelay
    ) DineroERC20("Dinero Governance Token", "DINERO", _admin, _initialDelay) {}
}
