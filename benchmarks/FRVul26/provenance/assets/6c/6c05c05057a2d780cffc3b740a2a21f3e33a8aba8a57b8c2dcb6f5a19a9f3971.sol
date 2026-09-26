// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../DLN/DlnSource.sol";
import "../libraries/DlnOrderLib.sol";

contract MockDlnSource is DlnSource {

    constructor(address _intentManager, IIntentManagerValidator _intentManagerRights, IDeBridgeGate _deBridgeGate, uint32 _subscriptionId) DlnSource(_intentManager, _intentManagerRights, _deBridgeGate, _subscriptionId) {
    }

    function initializeMock(
        uint80 _globalFixedNativeFee,
        uint16 _globalTransferFeeBps
    ) public initializer {
        super.initialize(_globalFixedNativeFee, _globalTransferFeeBps);
    }

    function encodeOrder(DlnOrderLib.Order memory _order)
        public
        pure
        returns (bytes memory encoded)
    {
        return DlnOrderLib.encodeOrder(_order, false);
    }
}
