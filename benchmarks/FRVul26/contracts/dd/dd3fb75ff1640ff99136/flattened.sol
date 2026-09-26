// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/contracts/interfaces/internal/helpers/IArraysConverter.sol

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

// File: src/contracts/helpers/ArraysConverter.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;



contract ArraysConverter is IArraysConverter {
    /**
     * @notice Converts two uint256 values into a uint256 array
     * @param a The first uint256 value
     * @param b The second uint256 value
     * @return values The array containing the two uint256 inputs
     */
    function toArray(uint256 a, uint256 b) public pure returns (uint256[] memory) {
        uint256[] memory values = new uint256[](2);
        values[0] = a;
        values[1] = b;
        return values;
    }

    function toArray(uint256 a, uint256 b, uint256 c) public pure returns (uint256[] memory) {
        uint256[] memory values = new uint256[](3);
        values[0] = a;
        values[1] = b;
        values[2] = c;
        return values;
    }

    function toArray(uint256 a, uint256 b, uint256 c, uint256 d) public pure returns (uint256[] memory) {
        uint256[] memory values = new uint256[](4);
        values[0] = a;
        values[1] = b;
        values[2] = c;
        values[3] = d;
        return values;
    }
}
