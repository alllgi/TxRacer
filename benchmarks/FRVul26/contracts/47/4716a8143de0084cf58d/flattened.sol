// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: contracts/oracle/interfaces/iFluidOracle.sol

pragma solidity 0.8.21;

interface IFluidOracle {
    /// @dev Deprecated. Use `getExchangeRateOperate()` and `getExchangeRateLiquidate()` instead. Only implemented for
    ///      backwards compatibility.
    function getExchangeRate() external view returns (uint256 exchangeRate_);

    /// @notice Get the `exchangeRate_` between the underlying asset and the peg asset in 1e27 for operates
    function getExchangeRateOperate() external view returns (uint256 exchangeRate_);

    /// @notice Get the `exchangeRate_` between the underlying asset and the peg asset in 1e27 for liquidations
    function getExchangeRateLiquidate() external view returns (uint256 exchangeRate_);

    /// @notice helper string to easily identify the oracle. E.g. token symbols
    function infoName() external view returns (string memory);
}

// File: contracts/oracle/errorTypes.sol

pragma solidity 0.8.21;

library ErrorTypes {
    /***********************************|
    |           FluidOracleL2           | 
    |__________________________________*/

    /// @notice thrown when sequencer on a L2 has an outage and grace period has not yet passed.
    uint256 internal constant FluidOracleL2__SequencerOutage = 60000;

    /***********************************|
    |     UniV3CheckCLRSOracle          | 
    |__________________________________*/

    /// @notice thrown when the delta between main price source and check rate source is exceeding the allowed delta
    uint256 internal constant UniV3CheckCLRSOracle__InvalidPrice = 60001;

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant UniV3CheckCLRSOracle__InvalidParams = 60002;

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant UniV3CheckCLRSOracle__ExchangeRateZero = 60003;

    /***********************************|
    |           FluidOracle             | 
    |__________________________________*/

    /// @notice thrown when an invalid info name is passed into a fluid oracle (e.g. not set or too long)
    uint256 internal constant FluidOracle__InvalidInfoName = 60010;

    /***********************************|
    |            sUSDe Oracle           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant SUSDeOracle__InvalidParams = 60102;

    /***********************************|
    |           Pendle Oracle           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant PendleOracle__InvalidParams = 60201;

    /// @notice thrown when the Pendle market Oracle has not been initialized yet
    uint256 internal constant PendleOracle__MarketNotInitialized = 60202;

    /// @notice thrown when the Pendle market does not have 18 decimals
    uint256 internal constant PendleOracle__MarketInvalidDecimals = 60203;

    /// @notice thrown when the Pendle market returns an unexpected price
    uint256 internal constant PendleOracle__InvalidPrice = 60204;

    /***********************************|
    |    CLRS2UniV3CheckCLRSOracleL2    | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant CLRS2UniV3CheckCLRSOracleL2__ExchangeRateZero = 60301;

    /***********************************|
    |    Ratio2xFallbackCLRSOracleL2    | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant Ratio2xFallbackCLRSOracleL2__ExchangeRateZero = 60311;

    /***********************************|
    |            WeETHsOracle           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant WeETHsOracle__InvalidParams = 60321;

    /***********************************|
    |          Chainlink Oracle         | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant ChainlinkOracle__InvalidParams = 61001;

    /***********************************|
    |          UniswapV3 Oracle         | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant UniV3Oracle__InvalidParams = 62001;

    /// @notice thrown when constructor is called with invalid ordered seconds agos values
    uint256 internal constant UniV3Oracle__InvalidSecondsAgos = 62002;

    /// @notice thrown when constructor is called with invalid delta values > 100%
    uint256 internal constant UniV3Oracle__InvalidDeltas = 62003;

    /***********************************|
    |            WstETh Oracle          | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant WstETHOracle__InvalidParams = 63001;

    /***********************************|
    |           Redstone Oracle         | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant RedstoneOracle__InvalidParams = 64001;

    /***********************************|
    |          Fallback Oracle          | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant FallbackOracle__InvalidParams = 65001;

    /***********************************|
    |       FallbackCLRSOracle          | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even for the fallback oracle source (if enabled)
    uint256 internal constant FallbackCLRSOracle__ExchangeRateZero = 66001;

    /***********************************|
    |         WstETHCLRSOracle          | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even for the fallback oracle source (if enabled)
    uint256 internal constant WstETHCLRSOracle__ExchangeRateZero = 67001;

    /***********************************|
    |        CLFallbackUniV3Oracle      | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even for the uniV3 rate
    uint256 internal constant CLFallbackUniV3Oracle__ExchangeRateZero = 68001;

    /***********************************|
    |  WstETHCLRS2UniV3CheckCLRSOracle  | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even for the uniV3 rate
    uint256 internal constant WstETHCLRS2UniV3CheckCLRSOracle__ExchangeRateZero = 69001;

    /***********************************|
    |             WeETh Oracle          | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant WeETHOracle__InvalidParams = 70001;
}

// File: contracts/oracle/error.sol

pragma solidity 0.8.21;

contract Error {
    error FluidOracleError(uint256 errorId_);
}

// File: contracts/oracle/fluidOracle.sol

pragma solidity 0.8.21;





/// @title   FluidOracle
/// @notice  Base contract that any Fluid Oracle must implement
abstract contract FluidOracle is IFluidOracle, OracleError {
    /// @dev short helper string to easily identify the oracle. E.g. token symbols
    //
    // using a bytes32 because string can not be immutable.
    bytes32 private immutable _infoName;

    constructor(string memory infoName_) {
        if (bytes(infoName_).length > 32 || bytes(infoName_).length == 0) {
            revert FluidOracleError(ErrorTypes.FluidOracle__InvalidInfoName);
        }

        // convert string to bytes32
        bytes32 infoNameBytes32_;
        assembly {
            infoNameBytes32_ := mload(add(infoName_, 32))
        }
        _infoName = infoNameBytes32_;
    }

    /// @inheritdoc IFluidOracle
    function infoName() external view returns (string memory) {
        // convert bytes32 to string
        uint256 length_;
        while (length_ < 32 && _infoName[length_] != 0) {
            length_++;
        }
        bytes memory infoNameBytes_ = new bytes(length_);
        for (uint256 i; i < length_; i++) {
            infoNameBytes_[i] = _infoName[i];
        }
        return string(infoNameBytes_);
    }

    /// @inheritdoc IFluidOracle
    function getExchangeRate() external view virtual returns (uint256 exchangeRate_);

    /// @inheritdoc IFluidOracle
    function getExchangeRateOperate() external view virtual returns (uint256 exchangeRate_);

    /// @inheritdoc IFluidOracle
    function getExchangeRateLiquidate() external view virtual returns (uint256 exchangeRate_);
}

// File: contracts/oracle/interfaces/external/IRedstoneOracle.sol

pragma solidity 0.8.21;

interface IRedstoneOracle {
    /// @notice Get the `exchangeRate_` between the underlying asset and the peg asset
    // @dev custom Redstone adapter for Instadapp implementation
    function getExchangeRate() external view returns (uint256 exchangeRate_);

    /**
     * @notice Returns the number of decimals for the price feed
     * @dev By default, RedStone uses 8 decimals for data feeds
     * @return decimals The number of decimals in the price feed values
     */
    // see https://github.com/redstone-finance/redstone-oracles-monorepo/blob/main/packages/on-chain-relayer/contracts/price-feeds/PriceFeedBase.sol#L51C12-L51C20
    function decimals() external view returns (uint8);
}

// File: contracts/oracle/interfaces/external/IChainlinkAggregatorV3.sol

pragma solidity 0.8.21;

/// from https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
/// Copyright (c) 2018 SmartContract ChainLink, Ltd.

interface IChainlinkAggregatorV3 {
    /// @notice represents the number of decimals the aggregator responses represent.
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: contracts/oracle/libraries/oracleUtils.sol

pragma solidity 0.8.21;

/// @title Oracle utils library
/// @notice implements common utility methods for Fluid Oracles
library OracleUtils {
    /// @dev The scaler for max delta point math (100%)
    uint256 internal constant HUNDRED_PERCENT_DELTA_SCALER = 10_000;
    /// @dev output precision of rates
    uint256 internal constant RATE_OUTPUT_DECIMALS = 27;

    /// @dev checks if `mainSourceRate_` is within a `maxDeltaPercent_` of `checkSourceRate_`. Returns true if so.
    function isRateOutsideDelta(
        uint256 mainSourceRate_,
        uint256 checkSourceRate_,
        uint256 maxDeltaPercent_
    ) internal pure returns (bool) {
        uint256 offset_ = (checkSourceRate_ * maxDeltaPercent_) / HUNDRED_PERCENT_DELTA_SCALER;
        return (mainSourceRate_ > (checkSourceRate_ + offset_) || mainSourceRate_ < (checkSourceRate_ - offset_));
    }
}

// File: contracts/oracle/implementations/structs.sol

pragma solidity 0.8.21;




abstract contract ChainlinkStructs {
    struct ChainlinkFeedData {
        /// @param feed           address of Chainlink feed.
        IChainlinkAggregatorV3 feed;
        /// @param invertRate     true if rate read from price feed must be inverted.
        bool invertRate;
        /// @param token0Decimals decimals of asset 0. E.g. for a USDC/ETH feed, USDC is token0 and has 6 decimals.
        ///                       (token1Decimals are available directly via Chainlink `FEED.decimals()`)
        uint256 token0Decimals;
    }

    struct ChainlinkConstructorParams {
        /// @param param        hops count of hops, used for sanity checks. Must be 1, 2 or 3.
        uint8 hops;
        /// @param feed1        Chainlink feed 1 data. Required.
        ChainlinkFeedData feed1;
        /// @param feed2        Chainlink feed 2 data. Required if hops > 1.
        ChainlinkFeedData feed2;
        /// @param feed3        Chainlink feed 3 data. Required if hops > 2.
        ChainlinkFeedData feed3;
    }
}

abstract contract RedstoneStructs {
    struct RedstoneOracleData {
        /// @param oracle         address of Redstone oracle.
        IRedstoneOracle oracle;
        /// @param invertRate     true if rate read from price feed must be inverted.
        bool invertRate;
        /// @param token0Decimals decimals of asset 0. E.g. for a USDC/ETH feed, USDC is token0 and has 6 decimals.
        ///                       (token1Decimals are available directly via Redstone `Oracle.decimals()`)
        uint256 token0Decimals;
    }
}

// File: contracts/oracle/implementations/chainlinkOracleImpl.sol

pragma solidity 0.8.21;







/// @title   Chainlink Oracle implementation
/// @notice  This contract is used to get the exchange rate via up to 3 hops at Chainlink price feeds.
///          The rate is multiplied with the previous rate at each hop.
///          E.g. to go from wBTC to USDC (assuming rates for example):
///          1. wBTC -> BTC https://data.chain.link/ethereum/mainnet/crypto-other/wbtc-btc, rate: 0.92.
///          2. BTC -> USD https://data.chain.link/ethereum/mainnet/crypto-usd/btc-usd rate: 30,000.
///          3. USD -> USDC https://data.chain.link/ethereum/mainnet/stablecoins/usdc-usd rate: 0.98. Must invert feed: 1.02
///          finale rate would be: 0.92 * 30,000 * 1.02 = 28,152
abstract contract ChainlinkOracleImpl is OracleError, ChainlinkStructs {
    /// @notice Chainlink price feed 1 to check for the exchange rate
    IChainlinkAggregatorV3 internal immutable _CHAINLINK_FEED1;
    /// @notice Chainlink price feed 2 to check for the exchange rate
    IChainlinkAggregatorV3 internal immutable _CHAINLINK_FEED2;
    /// @notice Chainlink price feed 3 to check for the exchange rate
    IChainlinkAggregatorV3 internal immutable _CHAINLINK_FEED3;

    /// @notice Flag to invert the price or not for feed 1 (to e.g. for WETH/USDC pool return prive of USDC per 1 WETH)
    bool internal immutable _CHAINLINK_INVERT_RATE1;
    /// @notice Flag to invert the price or not for feed 2 (to e.g. for WETH/USDC pool return prive of USDC per 1 WETH)
    bool internal immutable _CHAINLINK_INVERT_RATE2;
    /// @notice Flag to invert the price or not for feed 3 (to e.g. for WETH/USDC pool return prive of USDC per 1 WETH)
    bool internal immutable _CHAINLINK_INVERT_RATE3;

    /// @notice constant value for price scaling to reduce gas usage for feed 1
    uint256 internal immutable _CHAINLINK_PRICE_SCALER_MULTIPLIER1;
    /// @notice constant value for inverting price to reduce gas usage for feed 1
    uint256 internal immutable _CHAINLINK_INVERT_PRICE_DIVIDEND1;

    /// @notice constant value for price scaling to reduce gas usage for feed 2
    uint256 internal immutable _CHAINLINK_PRICE_SCALER_MULTIPLIER2;
    /// @notice constant value for inverting price to reduce gas usage for feed 2
    uint256 internal immutable _CHAINLINK_INVERT_PRICE_DIVIDEND2;

    /// @notice constant value for price scaling to reduce gas usage for feed 3
    uint256 internal immutable _CHAINLINK_PRICE_SCALER_MULTIPLIER3;
    /// @notice constant value for inverting price to reduce gas usage for feed 3
    uint256 internal immutable _CHAINLINK_INVERT_PRICE_DIVIDEND3;

    /// @notice constructor sets the Chainlink price feed and invertRate flag for each hop.
    /// E.g. `invertRate_` should be true if for the USDC/ETH pool it's expected that the oracle returns USDC per 1 ETH
    constructor(ChainlinkConstructorParams memory params_) {
        if (
            (params_.hops < 1 || params_.hops > 3) || // hops must be 1, 2 or 3
            (address(params_.feed1.feed) == address(0) || params_.feed1.token0Decimals == 0) || // first feed must always be defined
            (params_.hops > 1 && (address(params_.feed2.feed) == address(0) || params_.feed2.token0Decimals == 0)) || // if hops > 1, feed 2 must be defined
            (params_.hops > 2 && (address(params_.feed3.feed) == address(0) || params_.feed3.token0Decimals == 0)) // if hops > 2, feed 3 must be defined
        ) {
            revert FluidOracleError(ErrorTypes.ChainlinkOracle__InvalidParams);
        }

        _CHAINLINK_FEED1 = params_.feed1.feed;
        _CHAINLINK_FEED2 = params_.feed2.feed;
        _CHAINLINK_FEED3 = params_.feed3.feed;

        _CHAINLINK_INVERT_RATE1 = params_.feed1.invertRate;
        _CHAINLINK_INVERT_RATE2 = params_.feed2.invertRate;
        _CHAINLINK_INVERT_RATE3 = params_.feed3.invertRate;

        // Actual desired output rate example USDC/ETH (6 decimals / 18 decimals).
        // Note ETH has 12 decimals more than USDC.
        //    0.000515525322211842331991619857165357691 // 39 decimals.  ETH for 1 USDC
        // 1954.190000000000433             // 15 decimals. USDC for 1 ETH

        // to get to PRICE_SCLAER_MULTIPLIER and INVERT_PRICE_DIVIDEND:
        // fetched Chainlink price is in token1Decimals per 1 token0Decimals.
        // E.g. for an USDC/ETH price feed it's in ETH 18 decimals.
        //      for an  BTC/USD price feed it's in USD  8 decimals.
        // So to scale to 1e27 we need to multiply by 1e27 - token0Decimals.
        // E.g. for USDC/ETH it would be: fetchedPrice * 1e21
        //
        // or for inverted (x token0 per 1 token1), formula would be:
        //    = 1e27 * 10**token0Decimals / fetchedPrice
        // E.g. for USDC/ETH it would be: 1e33 / fetchedPrice

        // no support for token1Decimals with more than OracleUtils.RATE_OUTPUT_DECIMALS decimals for now as extremely unlikely case
        _CHAINLINK_PRICE_SCALER_MULTIPLIER1 = 10 ** (OracleUtils.RATE_OUTPUT_DECIMALS - params_.feed1.token0Decimals);
        _CHAINLINK_INVERT_PRICE_DIVIDEND1 = 10 ** (OracleUtils.RATE_OUTPUT_DECIMALS + params_.feed1.token0Decimals);

        _CHAINLINK_PRICE_SCALER_MULTIPLIER2 = params_.hops > 1
            ? 10 ** (OracleUtils.RATE_OUTPUT_DECIMALS - params_.feed2.token0Decimals)
            : 1;
        _CHAINLINK_INVERT_PRICE_DIVIDEND2 = params_.hops > 1
            ? 10 ** (OracleUtils.RATE_OUTPUT_DECIMALS + params_.feed2.token0Decimals)
            : 1;

        _CHAINLINK_PRICE_SCALER_MULTIPLIER3 = params_.hops > 2
            ? 10 ** (OracleUtils.RATE_OUTPUT_DECIMALS - params_.feed3.token0Decimals)
            : 1;
        _CHAINLINK_INVERT_PRICE_DIVIDEND3 = params_.hops > 2
            ? 10 ** (OracleUtils.RATE_OUTPUT_DECIMALS + params_.feed3.token0Decimals)
            : 1;
    }

    /// @dev            Get the exchange rate from Chainlike oracle price feed(s)
    /// @return rate_   The exchange rate in `OracleUtils.RATE_OUTPUT_DECIMALS`
    function _getChainlinkExchangeRate() internal view returns (uint256 rate_) {
        rate_ = _readFeedRate(
            _CHAINLINK_FEED1,
            _CHAINLINK_INVERT_RATE1,
            _CHAINLINK_PRICE_SCALER_MULTIPLIER1,
            _CHAINLINK_INVERT_PRICE_DIVIDEND1
        );
        if (rate_ == 0 || address(_CHAINLINK_FEED2) == address(0)) {
            // rate 0 or only 1 hop -> return rate of price feed 1
            return rate_;
        }
        rate_ =
            (rate_ *
                _readFeedRate(
                    _CHAINLINK_FEED2,
                    _CHAINLINK_INVERT_RATE2,
                    _CHAINLINK_PRICE_SCALER_MULTIPLIER2,
                    _CHAINLINK_INVERT_PRICE_DIVIDEND2
                )) /
            (10 ** OracleUtils.RATE_OUTPUT_DECIMALS);

        if (rate_ == 0 || address(_CHAINLINK_FEED3) == address(0)) {
            // rate 0 or 2 hops -> return rate of feed 1 combined with feed 2
            return rate_;
        }

        // 3 hops -> return rate of feed 1 combined with feed 2 & feed 3
        rate_ =
            (rate_ *
                _readFeedRate(
                    _CHAINLINK_FEED3,
                    _CHAINLINK_INVERT_RATE3,
                    _CHAINLINK_PRICE_SCALER_MULTIPLIER3,
                    _CHAINLINK_INVERT_PRICE_DIVIDEND3
                )) /
            (10 ** OracleUtils.RATE_OUTPUT_DECIMALS);
    }

    /// @dev reads the exchange `rate_` from a Chainlink price `feed_` taking into account scaling and `invertRate_`
    function _readFeedRate(
        IChainlinkAggregatorV3 feed_,
        bool invertRate_,
        uint256 priceMultiplier_,
        uint256 invertDividend_
    ) private view returns (uint256 rate_) {
        try feed_.latestRoundData() returns (uint80, int256 exchangeRate_, uint256, uint256, uint80) {
            // Return the price in `OracleUtils.RATE_OUTPUT_DECIMALS`
            if (invertRate_) {
                return invertDividend_ / uint256(exchangeRate_);
            } else {
                return uint256(exchangeRate_) * priceMultiplier_;
            }
        } catch {
            return 0;
        }
    }

    /// @notice returns all Chainlink oracle related data as utility for easy off-chain use / block explorer in a single view method
    function chainlinkOracleData()
        public
        view
        returns (
            uint256 chainlinkExchangeRate_,
            IChainlinkAggregatorV3 chainlinkFeed1_,
            bool chainlinkInvertRate1_,
            uint256 chainlinkExchangeRate1_,
            IChainlinkAggregatorV3 chainlinkFeed2_,
            bool chainlinkInvertRate2_,
            uint256 chainlinkExchangeRate2_,
            IChainlinkAggregatorV3 chainlinkFeed3_,
            bool chainlinkInvertRate3_,
            uint256 chainlinkExchangeRate3_
        )
    {
        return (
            _getChainlinkExchangeRate(),
            _CHAINLINK_FEED1,
            _CHAINLINK_INVERT_RATE1,
            _readFeedRate(
                _CHAINLINK_FEED1,
                _CHAINLINK_INVERT_RATE1,
                _CHAINLINK_PRICE_SCALER_MULTIPLIER1,
                _CHAINLINK_INVERT_PRICE_DIVIDEND1
            ),
            _CHAINLINK_FEED2,
            _CHAINLINK_INVERT_RATE2,
            address(_CHAINLINK_FEED2) == address(0)
                ? 0
                : _readFeedRate(
                    _CHAINLINK_FEED2,
                    _CHAINLINK_INVERT_RATE2,
                    _CHAINLINK_PRICE_SCALER_MULTIPLIER2,
                    _CHAINLINK_INVERT_PRICE_DIVIDEND2
                ),
            _CHAINLINK_FEED3,
            _CHAINLINK_INVERT_RATE3,
            address(_CHAINLINK_FEED3) == address(0)
                ? 0
                : _readFeedRate(
                    _CHAINLINK_FEED3,
                    _CHAINLINK_INVERT_RATE3,
                    _CHAINLINK_PRICE_SCALER_MULTIPLIER3,
                    _CHAINLINK_INVERT_PRICE_DIVIDEND3
                )
        );
    }
}

// File: contracts/oracle/implementations/redstoneOracleImpl.sol

pragma solidity 0.8.21;







/// @title   Redstone Oracle implementation
/// @notice  This contract is used to get the exchange rate from a Redstone Oracle
abstract contract RedstoneOracleImpl is OracleError, RedstoneStructs {
    /// @notice Redstone price oracle to check for the exchange rate
    IRedstoneOracle internal immutable _REDSTONE_ORACLE;
    /// @notice Flag to invert the price or not (to e.g. for WETH/USDC pool return prive of USDC per 1 WETH)
    bool internal immutable _REDSTONE_INVERT_RATE;

    /// @notice constant value for price scaling to reduce gas usage
    uint256 internal immutable _REDSTONE_PRICE_SCALER_MULTIPLIER;
    /// @notice constant value for inverting price to reduce gas usage
    uint256 internal immutable _REDSTONE_INVERT_PRICE_DIVIDEND;

    address internal immutable _REDSTONE_ORACLE_NOT_SET_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    /// @notice constructor sets the Redstone oracle data
    constructor(RedstoneOracleData memory oracleData_) {
        if (address(oracleData_.oracle) == address(0) || oracleData_.token0Decimals == 0) {
            revert FluidOracleError(ErrorTypes.RedstoneOracle__InvalidParams);
        }

        _REDSTONE_ORACLE = oracleData_.oracle;
        _REDSTONE_INVERT_RATE = oracleData_.invertRate;

        // for explanation on how to get to scaler multiplier and dividend see `chainlinkOracleImpl.sol`.
        // no support for token1Decimals with more than OracleUtils.RATE_OUTPUT_DECIMALS decimals for now as extremely unlikely case
        _REDSTONE_PRICE_SCALER_MULTIPLIER = address(oracleData_.oracle) == _REDSTONE_ORACLE_NOT_SET_ADDRESS
            ? 1
            : 10 ** (OracleUtils.RATE_OUTPUT_DECIMALS - oracleData_.token0Decimals);
        _REDSTONE_INVERT_PRICE_DIVIDEND = address(oracleData_.oracle) == _REDSTONE_ORACLE_NOT_SET_ADDRESS
            ? 1
            : 10 ** (OracleUtils.RATE_OUTPUT_DECIMALS + oracleData_.token0Decimals);
    }

    /// @dev           Get the exchange rate from Redstone oracle
    /// @param rate_   The exchange rate in `OracleUtils.RATE_OUTPUT_DECIMALS`
    function _getRedstoneExchangeRate() internal view returns (uint256 rate_) {
        try _REDSTONE_ORACLE.getExchangeRate() returns (uint256 exchangeRate_) {
            if (_REDSTONE_INVERT_RATE) {
                // invert the price
                return _REDSTONE_INVERT_PRICE_DIVIDEND / exchangeRate_;
            } else {
                return exchangeRate_ * _REDSTONE_PRICE_SCALER_MULTIPLIER;
            }
        } catch {
            return 0;
        }
    }

    /// @notice returns all Redstone oracle related data as utility for easy off-chain use / block explorer in a single view method
    function redstoneOracleData()
        public
        view
        returns (uint256 redstoneExchangeRate_, IRedstoneOracle redstoneOracle_, bool redstoneInvertRate_)
    {
        return (
            address(_REDSTONE_ORACLE) == _REDSTONE_ORACLE_NOT_SET_ADDRESS ? 0 : _getRedstoneExchangeRate(),
            _REDSTONE_ORACLE,
            _REDSTONE_INVERT_RATE
        );
    }
}

// File: contracts/oracle/implementations/fallbackOracleImpl.sol

pragma solidity 0.8.21;







/// @title   Fallback Oracle implementation
/// @notice  This contract is used to get the exchange rate from a main oracle feed and a fallback oracle feed.
//
// @dev     inheriting contracts should implement a view method to expose `_FALLBACK_ORACLE_MAIN_SOURCE`
abstract contract FallbackOracleImpl is OracleError, RedstoneOracleImpl, ChainlinkOracleImpl {
    /// @dev which oracle to use as main source:
    /// - 1 = Chainlink ONLY (no fallback)
    /// - 2 = Chainlink with Redstone Fallback
    /// - 3 = Redstone with Chainlink Fallback
    uint8 internal immutable _FALLBACK_ORACLE_MAIN_SOURCE;

    /// @notice                     sets the main source, Chainlink Oracle and Redstone Oracle data.
    /// @param mainSource_          which oracle to use as main source:
    ///                                  - 1 = Chainlink ONLY (no fallback)
    ///                                  - 2 = Chainlink with Redstone Fallback
    ///                                  - 3 = Redstone with Chainlink Fallback
    /// @param chainlinkParams_     chainlink Oracle constructor params struct.
    /// @param redstoneOracle_      Redstone Oracle data. (address can be set to zero address if using Chainlink only)
    constructor(
        uint8 mainSource_,
        ChainlinkConstructorParams memory chainlinkParams_,
        RedstoneOracleData memory redstoneOracle_
    )
        ChainlinkOracleImpl(chainlinkParams_)
        RedstoneOracleImpl(
            address(redstoneOracle_.oracle) == address(0)
                ? RedstoneOracleData(IRedstoneOracle(_REDSTONE_ORACLE_NOT_SET_ADDRESS), false, 1)
                : redstoneOracle_
        )
    {
        if (mainSource_ < 1 || mainSource_ > 3) {
            revert FluidOracleError(ErrorTypes.FallbackOracle__InvalidParams);
        }
        _FALLBACK_ORACLE_MAIN_SOURCE = mainSource_;
    }

    /// @dev returns the exchange rate for the main oracle source, or the fallback source (if configured) if the main exchange rate
    /// fails to be fetched. If returned rate is 0, fetching rate failed or something went wrong.
    /// @return exchangeRate_ exchange rate
    /// @return fallback_ whether fallback was necessary or not
    function _getRateWithFallback() internal view returns (uint256 exchangeRate_, bool fallback_) {
        if (_FALLBACK_ORACLE_MAIN_SOURCE == 1) {
            // 1 = Chainlink ONLY (no fallback)
            exchangeRate_ = _getChainlinkExchangeRate();
        } else if (_FALLBACK_ORACLE_MAIN_SOURCE == 2) {
            // 2 = Chainlink with Redstone Fallback
            exchangeRate_ = _getChainlinkExchangeRate();
            if (exchangeRate_ == 0) {
                fallback_ = true;
                exchangeRate_ = _getRedstoneExchangeRate();
            }
        } else {
            // 3 = Redstone with Chainlink Fallback
            exchangeRate_ = _getRedstoneExchangeRate();
            if (exchangeRate_ == 0) {
                fallback_ = true;
                exchangeRate_ = _getChainlinkExchangeRate();
            }
        }
    }

    /// @dev returns the exchange rate for Chainlink, or Redstone if configured & Chainlink fails.
    function _getChainlinkOrRedstoneAsFallback() internal view returns (uint256 exchangeRate_) {
        exchangeRate_ = _getChainlinkExchangeRate();

        if (exchangeRate_ == 0 && _FALLBACK_ORACLE_MAIN_SOURCE != 1) {
            // Chainlink failed but Redstone is configured too -> try Redstone
            exchangeRate_ = _getRedstoneExchangeRate();
        }
    }
}

// File: contracts/oracle/oracles/fallbackCLRSOracle.sol

pragma solidity 0.8.21;





/// @title   Chainlink / Redstone Oracle (with fallback)
/// @notice  Gets the exchange rate between the underlying asset and the peg asset by using:
///          the price from a Chainlink price feed or a Redstone Oracle with one of them being used as main source and
///          the other one acting as a fallback if the main source fails for any reason. Reverts if fetched rate is 0.
contract FallbackCLRSOracle is FluidOracle, FallbackOracleImpl {
    /// @notice                     sets the main source, Chainlink Oracle and Redstone Oracle data.
    /// @param infoName_         Oracle identify helper name.
    /// @param mainSource_          which oracle to use as main source: 1 = Chainlink, 2 = Redstone (other one is fallback).
    /// @param chainlinkParams_     chainlink Oracle constructor params struct.
    /// @param redstoneOracle_      Redstone Oracle data. (address can be set to zero address if using Chainlink only)
    constructor(
        string memory infoName_,
        uint8 mainSource_,
        ChainlinkConstructorParams memory chainlinkParams_,
        RedstoneOracleData memory redstoneOracle_
    ) FallbackOracleImpl(mainSource_, chainlinkParams_, redstoneOracle_) FluidOracle(infoName_) {}

    /// @inheritdoc FluidOracle
    function getExchangeRateOperate() public view virtual override returns (uint256 exchangeRate_) {
        (exchangeRate_, ) = _getRateWithFallback();

        if (exchangeRate_ == 0) {
            revert FluidOracleError(ErrorTypes.FallbackCLRSOracle__ExchangeRateZero);
        }
    }

    /// @inheritdoc FluidOracle
    function getExchangeRateLiquidate() public view virtual override returns (uint256 exchangeRate_) {
        (exchangeRate_, ) = _getRateWithFallback();

        if (exchangeRate_ == 0) {
            revert FluidOracleError(ErrorTypes.FallbackCLRSOracle__ExchangeRateZero);
        }
    }

    /// @inheritdoc FluidOracle
    function getExchangeRate() public view virtual override returns (uint256 exchangeRate_) {
        return getExchangeRateOperate();
    }

    /// @notice which oracle to use as main source:
    ///          - 1 = Chainlink ONLY (no fallback)
    ///          - 2 = Chainlink with Redstone Fallback
    ///          - 3 = Redstone with Chainlink Fallback
    function FALLBACK_ORACLE_MAIN_SOURCE() public view returns (uint8) {
        return _FALLBACK_ORACLE_MAIN_SOURCE;
    }
}
