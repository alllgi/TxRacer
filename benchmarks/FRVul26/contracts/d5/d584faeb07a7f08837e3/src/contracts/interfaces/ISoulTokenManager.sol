// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ISoulZapRouter} from "./ISoulZapRouter.sol";

/**
 * @title Token manager interface
 * @author kexley, Soul
 * @notice Interface for the token manager
 */
interface ISoulTokenManager {
    /**
     * @notice Pull tokens from a user
     * @param _user Address of user to transfer tokens from
     * @param _inputs Addresses and amounts of tokens to transfer
     */
    function pullTokens(address _user, ISoulZapRouter.Input[] calldata _inputs) external;
}
