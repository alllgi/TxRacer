// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import '../core/ICore.sol';

/// @title CoreRef interface
interface ICoreRef {
    event CoreUpdate(address indexed _core);

    function setCore(address coreAddress) external;
    function pause() external;
    function unpause() external;
    function core() external view returns (ICore);
}
