// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interface/IUniswapFactory.sol";
import "./interface/IUniswapV2Factory.sol";
import "./interface/IHandlerReserve.sol";
import "./interface/IEthHandler.sol";
import "./IDexSpan.sol";
import "./UniversalERC20.sol";
import "./interface/IWETH.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/Multicall.sol";
import "./interface/IAugustusSwapper.sol";
import "../interfaces/IAssetForwarder.sol";
import "./interface/IEthHandler.sol";
import { DexSpanRoot, DisableFlags } from "./DexSpanRoot.sol";
import "../interfaces/IMessageHandler.sol";

abstract contract IDexSpanView is DexSpanFlags {
    function getExpectedReturn(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        virtual
        returns (uint256 returnAmount, uint256[] memory distribution);

    function getExpectedReturnWithGas(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        virtual
        returns (
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );
}

contract DexSpanView is IDexSpanView, DexSpanRoot, AccessControl {
    using SafeMath for uint256;
    using DisableFlags for uint256;
    using SafeERC20 for IERC20Upgradeable;
    using UniversalERC20 for IERC20Upgradeable;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function getExpectedReturn(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        public
        view
        override
        returns (uint256 returnAmount, uint256[] memory distribution)
    {
        (returnAmount, , distribution) = getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            0
        );
    }

    function getExpectedReturnWithGas(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        override
        returns (
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        )
    {
        distribution = new uint256[](DEXES_COUNT_UPDATED);

        if (fromToken == destToken) {
            return (amount, 0, distribution);
        }

        function(IERC20Upgradeable, IERC20Upgradeable, uint256, uint256)
            view
            returns (uint256[] memory, uint256)[DEXES_COUNT_UPDATED]
            memory reserves = _getAllReserves(flags);

        int256[][] memory matrix = new int256[][](DEXES_COUNT_UPDATED);
        uint256[DEXES_COUNT_UPDATED] memory gases;
        bool atLeastOnePositive = false;
        for (uint256 i; i < DEXES_COUNT_UPDATED; i++) {
            uint256[] memory rets;
            (rets, gases[i]) = reserves[i](fromToken, destToken, amount, parts);

            // Prepend zero and sub gas
            int256 gas = int256(
                gases[i].mul(destTokenEthPriceTimesGasPrice).div(1e18)
            );
            matrix[i] = new int256[](parts + 1);
            for (uint256 j; j < rets.length; j++) {
                matrix[i][j + 1] = int256(rets[j]) - gas;
                atLeastOnePositive =
                    atLeastOnePositive ||
                    (matrix[i][j + 1] > 0);
            }
        }

        if (!atLeastOnePositive) {
            for (uint256 i; i < DEXES_COUNT_UPDATED; i++) {
                for (uint256 j = 1; j < parts + 1; j++) {
                    if (matrix[i][j] == 0) {
                        matrix[i][j] = VERY_NEGATIVE_VALUE;
                    }
                }
            }
        }

        (, distribution) = _findBestDistribution(parts, matrix);

        (returnAmount, estimateGasAmount) = _getReturnAndGasByDistribution(
            Args({
                fromToken: fromToken,
                destToken: destToken,
                amount: amount,
                parts: parts,
                flags: flags,
                destTokenEthPriceTimesGasPrice: destTokenEthPriceTimesGasPrice,
                distribution: distribution,
                matrix: matrix,
                gases: gases,
                reserves: reserves
            })
        );
        return (returnAmount, estimateGasAmount, distribution);
    }

    struct Args {
        IERC20Upgradeable fromToken;
        IERC20Upgradeable destToken;
        uint256 amount;
        uint256 parts;
        uint256 flags;
        uint256 destTokenEthPriceTimesGasPrice;
        uint256[] distribution;
        int256[][] matrix;
        uint256[DEXES_COUNT_UPDATED] gases;
        function(IERC20Upgradeable, IERC20Upgradeable, uint256, uint256)
            view
            returns (uint256[] memory, uint256)[DEXES_COUNT_UPDATED] reserves;
    }

    function _getReturnAndGasByDistribution(
        Args memory args
    ) internal view returns (uint256 returnAmount, uint256 estimateGasAmount) {
        bool[DEXES_COUNT_UPDATED] memory exact = [
            true //empty
        ];

        for (uint256 i; i < DEXES_COUNT_UPDATED; i++) {
            if (args.distribution[i] > 0) {
                if (
                    args.distribution[i] == args.parts ||
                    exact[i] ||
                    args.flags.check(FLAG_DISABLE_SPLIT_RECALCULATION)
                ) {
                    estimateGasAmount = estimateGasAmount.add(args.gases[i]);
                    int256 value = args.matrix[i][args.distribution[i]];
                    returnAmount = returnAmount.add(
                        uint256(
                            (value == VERY_NEGATIVE_VALUE ? int256(0) : value) +
                                int256(
                                    args
                                        .gases[i]
                                        .mul(
                                            args.destTokenEthPriceTimesGasPrice
                                        )
                                        .div(1e18)
                                )
                        )
                    );
                } else {
                    (uint256[] memory rets, uint256 gas) = args.reserves[i](
                        args.fromToken,
                        args.destToken,
                        args.amount.mul(args.distribution[i]).div(args.parts),
                        1
                    );
                    estimateGasAmount = estimateGasAmount.add(gas);
                    returnAmount = returnAmount.add(rets[0]);
                }
            }
        }
    }

    function _getAllReserves(
        uint256 flags
    )
        internal
        pure
        returns (
            function(IERC20Upgradeable, IERC20Upgradeable, uint256, uint256)
                view
                returns (uint256[] memory, uint256)[DEXES_COUNT_UPDATED]
                memory
        )
    {
        return [_calculateNoReturn];
    }

    function _calculateUniswapFormula(
        uint256 fromBalance,
        uint256 toBalance,
        uint256 amount
    ) internal pure returns (uint256) {
        if (amount == 0) {
            return 0;
        }
        return
            amount.mul(toBalance).mul(997).div(
                fromBalance.mul(1000).add(amount.mul(997))
            );
    }

    function _calculateSwap(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256[] memory amounts,
        IUniswapV2Factory exchangeInstance
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        rets = new uint256[](amounts.length);

        IERC20Upgradeable fromTokenReal = fromToken.isETH()
            ? wnativeAddress
            : fromToken;
        IERC20Upgradeable destTokenReal = destToken.isETH()
            ? wnativeAddress
            : destToken;
        IUniswapV2Exchange exchange = exchangeInstance.getPair(
            fromTokenReal,
            destTokenReal
        );
        if (exchange != IUniswapV2Exchange(address(0))) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(
                address(exchange)
            );
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(
                address(exchange)
            );
            for (uint256 i = 0; i < amounts.length; i++) {
                rets[i] = _calculateUniswapFormula(
                    fromTokenBalance,
                    destTokenBalance,
                    amounts[i]
                );
            }
            return (rets, 50_000);
        }
    }

    function _calculateNoReturn(
        IERC20Upgradeable /*fromToken*/,
        IERC20Upgradeable /*destToken*/,
        uint256 /*amount*/,
        uint256 parts
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        this;
        return (new uint256[](parts), 0);
    }
}
