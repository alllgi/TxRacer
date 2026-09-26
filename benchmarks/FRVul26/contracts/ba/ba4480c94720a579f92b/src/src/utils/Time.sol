// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

library Time {
    ///@notice Gets the current timestamp
    function blockTs() internal view returns (uint32 ts) {
        assembly {
            ts := timestamp()
        }
    }

    ///@notice Gets the the day count from a timestamp
    function dayCountByT(uint32 t) internal pure returns (uint32 dayCount) {
        assembly {
            let adjustedTime := sub(t, 50400)
            dayCount := div(adjustedTime, 86400)
        }
    }

    function daysSince(uint32 t) public view returns (uint32 daysPassed) {
        assembly {
            // Get the current block timestamp
            let currentTime := timestamp()

            daysPassed := div(sub(currentTime, t), 86400)
        }
    }
}
