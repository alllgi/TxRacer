// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/interfaces/IRateSource.sol

pragma solidity >=0.8.0;

interface IRateSource {
    function getAPR() external view returns (uint256);
    function decimals() external view returns (uint8);
}

// File: src/CappedFallbackRateSource.sol

pragma solidity ^0.8.0;



/**
 * @title  CappedFallbackRateSource
 * @notice Wraps another rate source, caps the rate and protects against reverts with a fallback value.
 */
contract CappedFallbackRateSource is IRateSource {

    IRateSource public immutable source;
    uint256     public immutable lowerBound;
    uint256     public immutable upperBound;
    uint256     public immutable defaultRate;

    constructor(
        address _source,
        uint256 _lowerBound,
        uint256 _upperBound,
        uint256 _defaultRate
    ) {
        require(_lowerBound <= _upperBound,                                 "CappedFallbackRateSource/invalid-bounds");
        require(_defaultRate >= _lowerBound && _defaultRate <= _upperBound, "CappedFallbackRateSource/invalid-default-rate");

        source      = IRateSource(_source);
        lowerBound  = _lowerBound;
        upperBound  = _upperBound;
        defaultRate = _defaultRate;
    }

    function getAPR() external override view returns (uint256) {
        try source.getAPR() returns (uint256 rate) {
            if      (rate < lowerBound) return lowerBound;
            else if (rate > upperBound) return upperBound;

            return rate;
        } catch (bytes memory err) {
            // This is a special case where you can trigger the catch in the try-catch by messing with the gas limit to
            // revert with out of gas (OOG) inside the inner loop. The refund may be enough to cover the remainder of
            // the execution so we need to check that the revert error is not empty (OOG) to prevent abuse.
            require(err.length > 0, "CappedFallbackRateSource/zero-length-error");

            return defaultRate;
        }
    }

    function decimals() external view override returns (uint8) {
        return source.decimals();
    }

}
