// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Bytes {
    function bytesToBytes32Array(bytes memory data)
        internal
        pure
        returns (bytes32[] memory dataList)
    {
        uint256 N = (data.length + 31) / 32;
        dataList = new bytes32[](N);
        for (uint256 index = 0; index < N; index++) {
            bytes32 element;
            uint256 start = 32 + index * 32;
            assembly {
                element := mload(add(data, start))
            }
            dataList[index] = element;
        }
    }
}