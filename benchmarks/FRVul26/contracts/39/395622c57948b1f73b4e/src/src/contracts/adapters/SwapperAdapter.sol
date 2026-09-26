// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

import { ISwapperAdapter } from "src/contracts/interfaces/internal/adapters/ISwapperAdapter.sol";

contract SwapperAdapter is ISwapperAdapter {
    /// @inheritdoc ISwapperAdapter
    function swap(address target, bytes memory data) external {
        // slither-disable-start low-level-calls,unchecked-lowlevel,missing-zero-check,assembly
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returnData) = target.call(data);

        if (!success) {
            if (returnData.length > 0) {
                // Decode the revert reason and rethrow it
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returnData_size := mload(returnData)
                    revert(add(32, returnData), returnData_size)
                }
            } else {
                // Revert with a generic error if no reason is provided
                revert SwapFailedWithNoReasonError(target, data);
            }
        }

        // slither-disable-end low-level-calls,unchecked-lowlevel,missing-zero-check,assembly
    }
}
