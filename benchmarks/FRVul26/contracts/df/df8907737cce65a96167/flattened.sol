// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/interfaces/IRateSource.sol

pragma solidity >=0.8.0;

interface IRateSource {
    function getAPR() external view returns (uint256);
    function decimals() external view returns (uint8);
}

// File: src/PotRateSource.sol

pragma solidity ^0.8.0;



interface IPot {
    function dsr() external view returns (uint256);
}

contract PotRateSource is IRateSource {

    IPot public immutable pot;

    constructor(address _pot) {
        pot = IPot(_pot);
    }

    function getAPR() external override view returns (uint256) {
        return (pot.dsr() - 1e27) * 365 days;
    }

    function decimals() external pure returns (uint8) {
        return 27;
    }

}
