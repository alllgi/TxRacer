// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/FixedPriceOracle.sol

pragma solidity ^0.8.0;

contract FixedPriceOracle {

    int256 public immutable price;

    constructor(int256 _price) {
        require(_price > 0, "FixedPriceOracle/invalid-price");
        
        price = _price;
    }

    function latestAnswer() external view returns (int256) {
        return price;
    }

    function decimals() external pure returns (uint8) {
        return 8;
    }

}
