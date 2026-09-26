// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

interface IArraysConverter {
    /**
     * @notice Converts two uint256 values into a uint256 array
     * @param a The first uint256 value
     * @param b The second uint256 value
     * @return values The array containing the two uint256 inputs
     */
    function toArray(uint256 a, uint256 b) external pure returns (uint256[] memory);

    /**
     * @notice Converts three uint256 values into a uint256 array
     * @param a The first uint256 value
     * @param b The second uint256 value
     * @param c The third uint256 value
     * @return values The array containing the three uint256 inputs
     */
    function toArray(uint256 a, uint256 b, uint256 c) external pure returns (uint256[] memory);

    /**
     * @notice Converts four uint256 values into a uint256 array
     * @param a The first uint256 value
     * @param b The second uint256 value
     * @param c The third uint256 value
     * @param d The fourth uint256 value
     * @return values The array containing the four uint256 inputs
     */
    function toArray(uint256 a, uint256 b, uint256 c, uint256 d) external pure returns (uint256[] memory);
}
