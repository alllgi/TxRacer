// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { TransparentUpgradeableProxy } from "./TransparentUpgradeableProxy.sol";

/// @title    InstaFluidFlashAggregatorProxy
/// @notice   Default ERC1967Proxy for InstaFlashAggregatorV2
contract InstaFluidFlashAggregatorProxy is TransparentUpgradeableProxy {
    constructor(
        address logic_,
        address admin_,
        bytes memory data_
    ) payable TransparentUpgradeableProxy(logic_, admin_, data_) {}
}
