// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

library LibFeeCollector {
    bytes32 internal constant NAMESPACE = keccak256("com.binance.w3w.diamond.feecollector");

    event FeeCollected(address indexed token, address recipient, uint256 amount);

    struct Storage {
        address recipient;
    }

    function getRecipient() internal view returns (address) {
        return feeCollectorStorage().recipient;
    }

    function setRecipient(address _recipient) internal {
        require(_recipient != address(0) && _recipient != address(this), "FeeCollectFacet: INVALID_FEE_RECIPIENT");
        require(_recipient != getRecipient(), "FeeCollectFacet: FEE_RECIPIENT_SAME_AS_CURRENT");
        feeCollectorStorage().recipient = _recipient;
    }

    function feeCollectorStorage() internal pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
