/*
  Copyright 2019-2024 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;

import "starkware/solidity/libraries/Addresses.sol";
import "starkware/solidity/tokens/ERC20/IERC20.sol";

library Transfers {
    using Addresses for address;

    /*
      Transfers funds from sender to this contract.
    */
    function transferIn(
        address token,
        address sender,
        uint256 amount
    ) internal {
        if (amount == 0) return;
        IERC20 erc20Token = IERC20(token);
        uint256 balanceBefore = erc20Token.balanceOf(address(this));
        uint256 expectedAfter = balanceBefore + amount;
        require(expectedAfter >= balanceBefore, "OVERFLOW");

        bytes memory callData = abi.encodeWithSelector(
            erc20Token.transferFrom.selector,
            sender,
            address(this),
            amount
        );
        token.safeTokenContractCall(callData);

        uint256 balanceAfter = erc20Token.balanceOf(address(this));
        require(balanceAfter == expectedAfter, "INCORRECT_AMOUNT_TRANSFERRED");
    }

    /*
      Transfers funds from this contract to recipient.
    */
    function transferOut(
        address token,
        address recipient,
        uint256 amount
    ) internal {
        // Make sure we don't accidentally burn funds.
        require(recipient != address(0x0), "INVALID_RECIPIENT");
        if (amount == 0) return;
        IERC20 erc20Token = IERC20(token);
        uint256 balanceBefore = erc20Token.balanceOf(address(this));
        uint256 expectedAfter = balanceBefore - amount;
        require(expectedAfter <= balanceBefore, "UNDERFLOW");

        bytes memory callData = abi.encodeWithSelector(
            erc20Token.transfer.selector,
            recipient,
            amount
        );
        token.safeTokenContractCall(callData);

        uint256 balanceAfter = erc20Token.balanceOf(address(this));
        require(balanceAfter == expectedAfter, "INCORRECT_AMOUNT_TRANSFERRED");
    }
}
