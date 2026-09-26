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

interface IStarkgateRegistry {
    /**
      Returns the bridge that handles the given token.
    */
    function getBridge(address token) external view returns (address);

    /**
      Add a mapping between a token and the bridge handling it.
    */
    function enlistToken(address token, address bridge) external;

    /**
      Block a specific token from being used in the StarkGate.
      A blocked token cannot be deployed.
      */
    function blockToken(address token) external;

    /**
      Retrieves a list of bridge addresses that have facilitated withdrawals 
      for the specified token.
     */
    function getWithdrawalBridges(address token) external view returns (address[] memory bridges);

    /**
      Using this function a bridge removes enlisting of its token from the registry.
      The bridge must implement `isServicingToken(address token)` (see `IStarkgateService`).
     */
    function selfRemove(address token) external;
}
