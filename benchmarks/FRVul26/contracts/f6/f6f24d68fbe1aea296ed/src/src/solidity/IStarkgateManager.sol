/*
  Copyright 2019-2023 StarkWare Industries Ltd.

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

interface IStarkgateManager {
    /**
      Returns the address of the Starkgate Registry contract.
    */
    function getRegistry() external view returns (address);

    // TODO: refactor the doc.
    /**
      Adds an existing bridge to the Starkgate system for a specific token.
     */
    function addExistingBridge(address token, address bridge) external;

    /**
      Deactivates bridging of a specific token.
      A deactivated token is blocked for deposits and cannot be re-deployed.     
      */
    function deactivateToken(address token) external;

    /**
      Block a specific token from being used in the StarkGate.
      A blocked token cannot be deployed.
      */
    function blockToken(address token) external;

    /**
      Enrolls a token bridge for a specific token.
     */
    function enrollTokenBridge(address token) external payable;
}
