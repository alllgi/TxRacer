// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/contracts/interfaces/internal/adapters/ISwapperAdapter.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

/**
 *
 * @dev Weiroll doesn't support low-level calls, so we need to use a proxy contract to make them.
 */
interface ISwapperAdapter {
    error SwapFailedWithNoReasonError(address target, bytes data);

    function swap(address swapperAddress, bytes calldata data) external;
}

// File: src/contracts/adapters/SwapperAdapter.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



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
