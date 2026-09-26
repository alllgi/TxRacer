/*

    Copyright 2024 31Third B.V.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.8.16;

import "../IExchangeAdapter.sol";

/**
 * @title GenericAdapter
 * @author 31Third
 *
 * Adapter for integrations without additional logic or checks for trade calldata.
 */
contract GenericAdapter is IExchangeAdapter {
  /*** ### Events ### ***/

  event GenericAdapterDeployed(
    string indexed name,
    address indexed spenderAddress,
    address indexed handlerAddress
  );

  /*** ### Custom Errors ### ***/

  error NameRequired();
  error SpenderRequired();
  error HandlerRequired();

  /*** ### State Variables ### ***/

  // ETH pseudo-token address
  address private constant ETH_ADDRESS =
    0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  // Name of the adapter (e.g. ZeroExAdapter, ParaSwapAdapter)
  string public name;

  // Address for which assets have to be approved (e.g. 0x proxy contract address, ParaSwap proxy contract address)
  address public immutable getSpender;

  // Address of the handler contract (e.g. 0x proxy contract address, ParaSwap exchange contract address)
  address public immutable handler;

  /*** ### constructor ### ***/

  constructor(string memory _name, address _spender, address _handler) {
    if (bytes(_name).length == 0) {
      revert NameRequired();
    }
    if (_spender == address(0)) {
      revert SpenderRequired();
    }
    if (_handler == address(0)) {
      revert HandlerRequired();
    }

    name = _name;
    getSpender = _spender;
    handler = _handler;

    emit GenericAdapterDeployed(_name, _spender, _handler);
  }

  /*** ### External Getter Functions ### ***/

  function getTradeCalldata(
    address _from,
    uint256 _fromAmount,
    address _to,
    uint256 _minToReceive,
    address _taker,
    uint256 _value,
    bytes calldata _data
  ) external view returns (address, uint256, bytes memory) {
    return (
      handler,
      _from == ETH_ADDRESS ? _fromAmount : 0, // call value is fromAmount if from is ETH, 0 otherwise
      _data
    );
  }
}
