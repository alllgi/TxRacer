// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

library LibReentrancyGuard {
    bytes32 private constant NAMESPACE = keccak256("com.binance.w3w.diamond.reentrancyguard");

    struct ReentrancyStorage {
        uint256 status;
    }

    error ReentrancyError();

    /// @dev fetch local storage
    function reentrancyStorage() internal pure returns (ReentrancyStorage storage data) {
        bytes32 position = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data.slot := position
        }
    }
}
