// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: IOracle.sol

pragma solidity 0.8.17;

interface IOracle {
    event TokenUpdated(address indexed token, address feed, uint256 maxDelay, bool isEthPrice);

    /// @notice returns the price in USD of symbol.
    function getUSDPrice(address token) external view returns (uint256);

    /// @notice returns if the given token is supported for pricing.
    function isTokenSupported(address token) external view returns (bool);
}

// File: ScaledMath.sol

pragma solidity 0.8.17;

library ScaledMath {
    uint256 internal constant DECIMALS = 18;
    uint256 internal constant ONE = 10 ** DECIMALS;

    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b) / ONE;
    }

    function mulDown(uint256 a, uint256 b, uint256 decimals) internal pure returns (uint256) {
        return (a * b) / (10 ** decimals);
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * ONE) / b;
    }

    function divDown(uint256 a, uint256 b, uint256 decimals) internal pure returns (uint256) {
        return (a * 10 ** decimals) / b;
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        return ((a * ONE) - 1) / b + 1;
    }

    function mulDown(int256 a, int256 b) internal pure returns (int256) {
        return (a * b) / int256(ONE);
    }

    function mulDownUint128(uint128 a, uint128 b) internal pure returns (uint128) {
        return (a * b) / uint128(ONE);
    }

    function mulDown(int256 a, int256 b, uint256 decimals) internal pure returns (int256) {
        return (a * b) / int256(10 ** decimals);
    }

    function divDown(int256 a, int256 b) internal pure returns (int256) {
        return (a * int256(ONE)) / b;
    }

    function divDownUint128(uint128 a, uint128 b) internal pure returns (uint128) {
        return (a * uint128(ONE)) / b;
    }

    function divDown(int256 a, int256 b, uint256 decimals) internal pure returns (int256) {
        return (a * int256(10 ** decimals)) / b;
    }

    function convertScale(
        uint256 a,
        uint8 fromDecimals,
        uint8 toDecimals
    ) internal pure returns (uint256) {
        if (fromDecimals == toDecimals) return a;
        if (fromDecimals > toDecimals) return downscale(a, fromDecimals, toDecimals);
        return upscale(a, fromDecimals, toDecimals);
    }

    function convertScale(
        int256 a,
        uint8 fromDecimals,
        uint8 toDecimals
    ) internal pure returns (int256) {
        if (fromDecimals == toDecimals) return a;
        if (fromDecimals > toDecimals) return downscale(a, fromDecimals, toDecimals);
        return upscale(a, fromDecimals, toDecimals);
    }

    function upscale(
        uint256 a,
        uint8 fromDecimals,
        uint8 toDecimals
    ) internal pure returns (uint256) {
        return a * (10 ** (toDecimals - fromDecimals));
    }

    function downscale(
        uint256 a,
        uint8 fromDecimals,
        uint8 toDecimals
    ) internal pure returns (uint256) {
        return a / (10 ** (fromDecimals - toDecimals));
    }

    function upscale(
        int256 a,
        uint8 fromDecimals,
        uint8 toDecimals
    ) internal pure returns (int256) {
        return a * int256(10 ** (toDecimals - fromDecimals));
    }

    function downscale(
        int256 a,
        uint8 fromDecimals,
        uint8 toDecimals
    ) internal pure returns (int256) {
        return a / int256(10 ** (fromDecimals - toDecimals));
    }

    function intPow(uint256 a, uint256 n) internal pure returns (uint256) {
        uint256 result = ONE;
        for (uint256 i; i < n; ) {
            result = mulDown(result, a);
            unchecked {
                ++i;
            }
        }
        return result;
    }

    function absSub(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a >= b ? a - b : b - a;
        }
    }
}

// File: CrvUsdOracle.sol

pragma solidity 0.8.17;




interface ICurvePriceOracle {
    function price_oracle() external view returns (uint256);
}

contract CrvUsdOracle is IOracle {
    using ScaledMath for uint256;

    // Tokens
    address internal constant _CRVUSD = address(0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E);
    address internal constant _USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address internal constant _USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address internal constant _USDP = address(0x8E870D67F660D95d5be530380D0eC0bd388289E1);

    // Curve pools
    address internal constant _CRVUSD_USDC = address(0x4DEcE678ceceb27446b35C672dC7d61F30bAD69E);
    address internal constant _CRVUSD_USDT = address(0x390f3595bCa2Df7d23783dFd126427CCeb997BF4);
    address internal constant _CRVUSD_USDP = address(0xCa978A0528116DDA3cbA9ACD3e68bc6191CA53D0);

    IOracle internal immutable _genericOracle;

    constructor(address genericOracle_) {
        _genericOracle = IOracle(genericOracle_);
    }

    function getUSDPrice(address token_) external view override returns (uint256) {
        require(isTokenSupported(token_), "token not supported");
        uint256 priceFromUsdc_ = _getCrvUsdPriceForCurvePool(_CRVUSD_USDC, _USDC);
        uint256 priceFromUsdt_ = _getCrvUsdPriceForCurvePool(_CRVUSD_USDT, _USDT);
        uint256 priceFromUsdp_ = _getCrvUsdPriceForCurvePool(_CRVUSD_USDP, _USDP);
        return _median(priceFromUsdc_, priceFromUsdt_, priceFromUsdp_);
    }

    function isTokenSupported(address token_) public pure override returns (bool) {
        return token_ == _CRVUSD;
    }

    function _getCrvUsdPriceForCurvePool(
        address curvePool_,
        address token_
    ) internal view returns (uint256) {
        uint256 tokenPrice_ = _genericOracle.getUSDPrice(token_);
        uint256 tokenPerCrvUsd_ = ICurvePriceOracle(curvePool_).price_oracle();
        return tokenPrice_.mulDown(tokenPerCrvUsd_);
    }

    function _median(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        if ((a >= b && a <= c) || (a >= c && a <= b)) return a;
        if ((b >= a && b <= c) || (b >= c && b <= a)) return b;
        return c;
    }
}
