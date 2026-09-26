// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "./interface/IUniswapFactory.sol";
import "./interface/IUniswapV2Factory.sol";
import "./interface/IHandlerReserve.sol";
import "./interface/IEthHandler.sol";
import "./IDexSpan.sol";
import "./UniversalERC20.sol";
import "./interface/IWETH.sol";
import "./libraries/TransferHelper.sol";
// import "./libraries/Multicall.sol";
import "./interface/IAugustusSwapper.sol";
import "../interfaces/IAssetForwarder.sol";
import "./interface/IEthHandler.sol";

import "../interfaces/IMessageHandler.sol";

library DisableFlags {
    function check(uint256 flags, uint256 flag) internal pure returns (bool) {
        return (flags & flag) != 0;
    }
}

contract DexSpanRoot {
    using SafeMath for uint256;
    using DisableFlags for uint256;

    using UniversalERC20 for IERC20Upgradeable;
    using UniversalERC20 for IWETH;
    using UniswapV2ExchangeLib for IUniswapV2Exchange;

    uint256 internal constant DEXES_COUNT = 4;
    uint256 public constant DEXES_COUNT_UPDATED = 1;
    IERC20Upgradeable internal ZERO_ADDRESS;

    int256 internal constant VERY_NEGATIVE_VALUE = -1e72;

    IWETH public wnativeAddress;
    IERC20Upgradeable public nativeAddress;

    function _findBestDistribution(
        uint256 s, // parts
        int256[][] memory amounts // exchangesReturns
    )
        internal
        pure
        returns (int256 returnAmount, uint256[] memory distribution)
    {
        uint256 n = amounts.length;

        int256[][] memory answer = new int256[][](n); // int[n][s+1]
        uint256[][] memory parent = new uint256[][](n); // int[n][s+1]

        for (uint256 i; i < n; i++) {
            answer[i] = new int256[](s + 1);
            parent[i] = new uint256[](s + 1);
        }

        for (uint256 j; j <= s; j++) {
            answer[0][j] = amounts[0][j];
            for (uint256 i = 1; i < n; i++) {
                answer[i][j] = -1e72;
            }
            parent[0][j] = 0;
        }

        for (uint256 i = 1; i < n; i++) {
            for (uint256 j; j <= s; j++) {
                answer[i][j] = answer[i - 1][j];
                parent[i][j] = j;

                for (uint256 k = 1; k <= j; k++) {
                    if (answer[i - 1][j - k] + amounts[i][k] > answer[i][j]) {
                        answer[i][j] = answer[i - 1][j - k] + amounts[i][k];
                        parent[i][j] = j - k;
                    }
                }
            }
        }

        distribution = new uint256[](DEXES_COUNT_UPDATED);

        uint256 partsLeft = s;
        for (uint256 curExchange = n - 1; partsLeft > 0; curExchange--) {
            distribution[curExchange] =
                partsLeft -
                parent[curExchange][partsLeft];
            partsLeft = parent[curExchange][partsLeft];
        }

        returnAmount = (answer[n - 1][s] == VERY_NEGATIVE_VALUE)
            ? int256(0)
            : answer[n - 1][s];
    }

    function _linearInterpolation(
        uint256 value,
        uint256 parts
    ) internal pure returns (uint256[] memory rets) {
        rets = new uint256[](parts);
        for (uint256 i = 0; i < parts; i++) {
            rets[i] = value.mul(i + 1).div(parts);
        }
    }

    function _tokensEqual(
        IERC20Upgradeable tokenA,
        IERC20Upgradeable tokenB
    ) internal pure returns (bool) {
        return ((tokenA.isETH() && tokenB.isETH()) || tokenA == tokenB);
    }
}