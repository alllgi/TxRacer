// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

/* === UNIV3 === */
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {OracleLibrary} from "./library/OracleLibrary.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

/* === UNIV2 ===  */
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/* === OZ === */
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/* === CONST === */
import "./const/BuyAndBurnConst.sol";

/* === SYSTEM === */
import {Inferno} from "./Inferno.sol";

/**
 * @title InfernoBuyAndBurn
 * @author 0xkmmm
 * @notice This contract handles the buying and burning of Inferno tokens using Uniswap V2 and V3 pools.
 */
contract InfernoBuyAndBurn is ReentrancyGuard, Ownable2Step {
    using TransferHelper for IERC20;
    /* == STRUCTS == */

    /// @notice Struct to represent intervals for burning
    struct Interval {
        uint128 amountAllocated;
        uint128 amountBurned;
    }

    struct LP {
        uint248 tokenId;
        bool isBlazeToken0;
    }

    /* == CONTSTANTS == */

    /// @notice Uniswap V3 position manager
    INonfungiblePositionManager public constant POSITION_MANAGER =
        INonfungiblePositionManager(UNISWAP_V3_POSITION_MANAGER);

    /* == IMMUTABLE == */

    /// @notice Uniswap V2 pool for Blaze/TitanX tokens
    IUniswapV2Pair private immutable blazeTitanXPool;

    /// @notice Blaze token contract
    ERC20Burnable private immutable blaze;

    /// @notice TitanX token contract
    IERC20 private immutable titanX;

    /// @notice Inferno token contract
    Inferno public immutable infernoToken;

    ///@notice The startTimestamp
    uint32 public immutable startTimeStamp;

    /* == STATE == */

    ///@notice The liquidity position after creating the Inferno/Blaze Pool
    LP lp;

    /// @notice Indicates if liquidity has been added to the pool
    bool public liquidityAdded;

    /// @notice Timestamp of the last burn call
    uint32 public lastBurnedIntervalStartTimestamp;

    /// @notice Total amount of Inferno tokens burnt
    uint256 public totalInfernoBurnt;

    /// @notice Mapping from interval number to Interval struct
    mapping(uint32 interval => Interval) public intervals;

    /// @notice Last interval number
    uint32 public lastIntervalNumber;

    /// @notice Total TitanX tokens distributed
    uint256 public totalTitanXDistributed;

    ///@notice The slippage for the second swap in the buy and burn in %
    uint8 blazeToInfernoSlippage = 90;

    /* == EVENTS == */

    /// @notice Event emitted when tokens are bought and burnt
    event BuyAndBurn(uint256 indexed titanXAmount, uint256 indexed infernoBurnt, address indexed caller);

    /* == ERRORS == */

    /// @notice Error when the contract has not started yet
    error NotStartedYet();

    /// @notice Error when minter is not msg.msg.sender
    error OnlyMinting();

    /// @notice Error when some user input is considered invalid
    error InvalidInput();

    /// @notice Error when we try to create liquidity pool with less than the intial amount
    error NotEnoughTitanXForLiquidity();

    /// @notice Error when liquidity has already been added
    error LiquidityAlreadyAdded();

    /// @notice Error when interval has already been burned
    error IntervalAlreadyBurned();

    ///@notice Error when caller is not the slippage admin
    error OnlySlippageAdmin();

    /* == CONSTRUCTOR == */

    /// @notice Constructor initializes the contract
    /// @notice Constructor is payable to save gas
    constructor(uint32 startTimestamp, address _blazeTitanXPool, address _titanX, address _blaze, address _owner)
        payable
        Ownable(_owner)
    {
        startTimeStamp = startTimestamp;
        titanX = IERC20(_titanX);
        infernoToken = Inferno(msg.sender);
        blaze = ERC20Burnable(_blaze);
        blazeTitanXPool = IUniswapV2Pair(_blazeTitanXPool);
    }

    /* === MODIFIERS === */

    /// @notice Updates the contract state for intervals
    modifier intervalUpdate() {
        _intervalUpdate();
        _;
    }

    /* == PUBLIC/EXTERNAL == */

    /**
     * @notice Swaps TitanX for Inferno and burns the Inferno tokens
     * @param _amountBlazeMin Minimum amount of Blaze tokens expected
     * @param _deadline The deadline for which the passes should pass
     */
    function swapTitanXForInfernoAndBurn(uint256 _amountBlazeMin, uint32 _deadline)
        external
        nonReentrant
        intervalUpdate
    {
        if (!liquidityAdded) revert NotStartedYet();
        Interval storage currInterval = intervals[lastIntervalNumber];
        if (currInterval.amountBurned != 0) revert IntervalAlreadyBurned();

        currInterval.amountBurned = currInterval.amountAllocated;

        uint256 incentive = (currInterval.amountAllocated * INCENTIVE_FEE) / BPS_DENOM;

        uint256 titanXToSwapAndBurn = currInterval.amountAllocated - incentive;

        uint256 blazeAmount = _swapTitanForBlaze(titanXToSwapAndBurn, _amountBlazeMin, _deadline);
        uint256 infernoAmount = _swapBlazeForInferno(blazeAmount, _deadline);

        burnInferno();

        TransferHelper.safeTransfer(address(titanX), msg.sender, incentive);

        emit BuyAndBurn(titanXToSwapAndBurn, infernoAmount, msg.sender);
    }

    /**
     * @notice Creates a Uniswap V3 pool and adds liquidity
     * @param _deadline The deadline for the liquidity addition
     * @param _amountBlazeMin Minimum amount of TitanX tokens expected
     */
    function addLiquidityToInfernoBlazePool(uint32 _deadline, uint256 _amountBlazeMin) external onlyOwner {
        if (liquidityAdded) revert LiquidityAlreadyAdded();
        if (titanX.balanceOf(address(this)) < INITIAL_TITAN_X_FOR_LIQ) revert NotEnoughTitanXForLiquidity();

        liquidityAdded = true;

        uint256 blazeReceived = _swapTitanForBlaze(INITIAL_TITAN_X_FOR_LIQ, _amountBlazeMin, _deadline);

        infernoToken.mintTokensForLP();

        (uint256 amount0, uint256 amount1, uint256 amount0Min, uint256 amount1Min, address token0, address token1) =
            _sortAmounts(blazeReceived, INITIAL_LP_MINT);

        TransferHelper.safeApprove(token0, address(POSITION_MANAGER), amount0);
        TransferHelper.safeApprove(token1, address(POSITION_MANAGER), amount1);

        // wake-disable-next-line
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: POOL_FEE,
            tickLower: (TickMath.MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (TickMath.MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: address(this),
            deadline: _deadline
        });

        // wake-disable-next-line
        (uint256 tokenId,,,) = POSITION_MANAGER.mint(params);

        lp = LP({tokenId: uint248(tokenId), isBlazeToken0: token0 == address(blaze)});

        totalTitanXDistributed = titanX.balanceOf(address(this));
    }

    /// @notice Burns Inferno tokens held by the contract
    function burnInferno() public {
        uint256 infernoToBurn = infernoToken.balanceOf(address(this));

        totalInfernoBurnt = totalInfernoBurnt + infernoToBurn;
        infernoToken.burn(infernoToBurn);
    }

    function setSlippageForBlazeToInferno(uint8 _newSlippage) external onlyOwner {
        if (_newSlippage > 100 || _newSlippage < 2) revert InvalidInput();

        blazeToInfernoSlippage = _newSlippage;
    }

    /**
     * @notice Distributes TitanX tokens for burning
     * @param _amount The amount of TitanX tokens
     */
    function distributeTitanXForBurning(uint256 _amount) external {
        if (_amount == 0) revert InvalidInput();
        if (msg.sender != address(infernoToken.minting())) revert OnlyMinting();

        ///@dev - If there are some missed intervals update the accumulated allocation before depositing new titanX
        if (block.timestamp > startTimeStamp && block.timestamp - lastBurnedIntervalStartTimestamp > INTERVAL_TIME) {
            _intervalUpdate();
        }

        TransferHelper.safeTransferFrom(address(titanX), msg.sender, address(this), _amount);

        totalTitanXDistributed = titanX.balanceOf(address(this));
    }

    /**
     * @notice Burns the fees collected from the Uniswap V3 position
     *
     * @return amount0 The amount of token0 collected
     * @return amount1 The amount of token1 collected
     */
    function burnFees() external returns (uint256 amount0, uint256 amount1) {
        LP memory _lp = lp;

        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: _lp.tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = POSITION_MANAGER.collect(params);

        (uint256 blazeAmount,) = _lp.isBlazeToken0 ? (amount0, amount1) : (amount1, amount0);

        blaze.transfer(GENESIS_WALLET, blazeAmount);
        burnInferno();
    }

    /* == PUBLIC-GETTERS == */

    ///@notice Gets the current week day (0=Sunday, 1=Monday etc etc) wtih a cut-off hour at 2pm UTC
    function currWeekDay() public view returns (uint8 weekDay) {
        weekDay = weekDayByT(uint32(block.timestamp));
    }

    /**
     * @notice Gets the current week day (0=Sunday, 1=Monday etc etc) wtih a cut-off hour at 2pm UTC
     * @param t The timestamp from which to get the weekDay
     */
    function weekDayByT(uint32 t) public pure returns (uint8) {
        return uint8((((t - 14 hours) / 86400) + 4) % 7);
    }

    /**
     * @notice Get the day count for a timestamp
     * @param t The timestamp from which to get the timestamp
     */
    function dayCountByT(uint32 t) public pure returns (uint32) {
        // Adjust the timestamp to the cut-off time (2 PM UTC)
        uint32 adjustedTime = t - 14 hours;

        // Calculate the number of days since Unix epoch
        return adjustedTime / 86400;
    }

    /**
     * @notice Gets the end of the day with a cut-off hour of 2 pm UTC
     * @param t The time from where to get the day end
     */
    function getDayEnd(uint32 t) public pure returns (uint32) {
        // Adjust the timestamp to the cutoff time (2 PM UTC)
        uint32 adjustedTime = t - 14 hours;

        // Calculate the number of days since Unix epoch
        uint32 daysSinceEpoch = adjustedTime / 86400;

        // Calculate the start of the next day at 2 PM UTC
        uint32 nextDayStartAt2PM = (daysSinceEpoch + 1) * 86400 + 14 hours;

        // Return the timestamp for 14:00:00 PM UTC of the given day
        return nextDayStartAt2PM;
    }

    /**
     * @notice Gets the daily TitanX allocation
     * @return dailyBPSAllocation The daily allocation in basis points
     */
    function getDailyTitanXAllocation(uint8 weekDay) public pure returns (uint32 dailyBPSAllocation) {
        dailyBPSAllocation = 400;

        if (weekDay == 5 || weekDay == 6) {
            dailyBPSAllocation = 1500;
        } else if (weekDay == 4) {
            dailyBPSAllocation = 1000;
        }
    }

    /**
     * @notice Gets a quote for Inferno tokens in exchange for Blaze tokens
     * @param baseAmount The amount of Blaze tokens
     * @return quote The amount of Inferno tokens received
     */
    function getInfernoQuoteForBlaze(uint256 baseAmount) public view returns (uint256 quote) {
        address poolAddress = infernoToken.blazeInfernoPool();
        uint32 secondsAgo = 15 * 60;
        uint32 oldestObservation = OracleLibrary.getOldestObservationSecondsAgo(poolAddress);

        if (oldestObservation < secondsAgo) secondsAgo = oldestObservation;

        (int24 arithmeticMeanTick,) = OracleLibrary.consult(poolAddress, secondsAgo);

        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);

        quote = OracleLibrary.getQuoteForSqrtRatioX96(sqrtPriceX96, baseAmount, address(blaze), address(infernoToken));
    }

    /**
     * @notice Gets a quote for Blaze tokens in exchange for TitanX tokens
     * @param titanXAmount The amount of TitanX tokens
     * @return quote The amount of Blaze tokens received
     */
    function getBlazeQuoteForTitanX(uint256 titanXAmount) external view returns (uint256 quote) {
        IUniswapV2Pair pair = blazeTitanXPool;

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        ///@dev TitanX is token0 in the TitanX/Blaze pool
        quote = (titanXAmount * reserve1) / reserve0;
    }

    /* == INTERNAL/PRIVATE == */

    /**
     * @notice Swaps TitanX tokens for Blaze tokens
     * @param amountTitan The amount of TitanX tokens
     * @param amountBlazeMin Minimum amount of Blaze tokens expected
     * @return _blazeAmount The amount of Blaze tokens received
     */
    function _swapTitanForBlaze(uint256 amountTitan, uint256 amountBlazeMin, uint256 _deadline)
        private
        returns (uint256 _blazeAmount)
    {
        TransferHelper.safeApprove(address(titanX), UNISWAP_V2_ROUTER, amountTitan);

        address[] memory path = new address[](2);
        path[0] = address(titanX);
        path[1] = address(blaze);

        uint256[] memory returnedOutputAmounts = IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            amountTitan, amountBlazeMin, path, address(this), _deadline
        );

        _blazeAmount = returnedOutputAmounts[returnedOutputAmounts.length - 1];
    }

    /**
     * @notice Swaps Blaze tokens for Inferno tokens
     * @param amountBlaze The amount of Blaze tokens
     * @param _deadline The deadline for when the swap must be executed
     * @return _titanAmount The amount of TitanX tokens received
     */
    function _swapBlazeForInferno(uint256 amountBlaze, uint256 _deadline) private returns (uint256 _titanAmount) {
        // wake-disable-next-line
        blaze.approve(UNISWAP_V3_ROUTER, amountBlaze);
        // Setup the swap-path, swapp
        bytes memory path = abi.encodePacked(address(blaze), POOL_FEE, address(infernoToken));

        uint256 expectedInfernoAmount = getInfernoQuoteForBlaze(amountBlaze);

        // Adjust for slippage (applied uniformly across both hops)
        uint256 adjustedInfernoAmount = (expectedInfernoAmount * (100 - blazeToInfernoSlippage)) / 100;

        // Swap parameters
        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: _deadline,
            amountIn: amountBlaze,
            amountOutMinimum: adjustedInfernoAmount
        });

        // Execute the swap
        return ISwapRouter(UNISWAP_V3_ROUTER).exactInput(params);
    }

    function _calculateIntervals(uint256 timeElapsedSince)
        internal
        view
        returns (uint32 _lastIntervalNumber, uint128 _totalAmountForInterval, uint16 missedIntervals)
    {
        missedIntervals = _calculateMissedIntervals(timeElapsedSince);

        _lastIntervalNumber = lastIntervalNumber + missedIntervals + 1;

        uint32 currentDay = dayCountByT(uint32(block.timestamp));

        uint32 dayOfLastInterval =
            lastBurnedIntervalStartTimestamp == 0 ? currentDay : dayCountByT(lastBurnedIntervalStartTimestamp);

        if (currentDay == dayOfLastInterval) {
            uint256 dailyAllcation = (totalTitanXDistributed * getDailyTitanXAllocation(currWeekDay())) / BPS_DENOM;

            uint128 _amountPerInterval = uint128(dailyAllcation / INTERVALS_PER_DAY);

            uint128 additionalAmount = _amountPerInterval * missedIntervals;

            _totalAmountForInterval = _amountPerInterval + additionalAmount;
        } else {
            uint32 _lastBurnedIntervalStartTimestamp = lastBurnedIntervalStartTimestamp;

            uint32 theEndOfTheDay = getDayEnd(_lastBurnedIntervalStartTimestamp);

            while (currentDay >= dayOfLastInterval) {
                uint32 end = uint32(block.timestamp < theEndOfTheDay ? block.timestamp : theEndOfTheDay - 1);

                uint32 accumulatedIntervalsForTheDay = (end - _lastBurnedIntervalStartTimestamp) / INTERVAL_TIME;

                uint256 dailyAllcation =
                    (totalTitanXDistributed * getDailyTitanXAllocation(weekDayByT(end))) / BPS_DENOM;

                uint128 _amountPerInterval = uint128(dailyAllcation / INTERVALS_PER_DAY);

                _totalAmountForInterval += _amountPerInterval * accumulatedIntervalsForTheDay;

                ///@notice ->  minus 30 minutes since, at the end of the day the new epoch with new allocation
                _lastBurnedIntervalStartTimestamp = theEndOfTheDay - 30 minutes;

                ///@notice ->  plus 30 minutes to flip into the next day
                theEndOfTheDay = getDayEnd(_lastBurnedIntervalStartTimestamp + 30 minutes);

                dayOfLastInterval++;
            }
        }

        if (_totalAmountForInterval > totalTitanXDistributed) {
            _totalAmountForInterval = uint128(totalTitanXDistributed);
        }
    }

    function _calculateMissedIntervals(uint256 timeElapsedSince) internal view returns (uint16 _missedIntervals) {
        if (lastBurnedIntervalStartTimestamp == 0) {
            /// @dev - If there is no burned interval, we do no deduct 1 since no intervals is yet claimed
            _missedIntervals = timeElapsedSince <= INTERVAL_TIME ? 0 : uint16(timeElapsedSince / INTERVAL_TIME);
        } else {
            /// @dev - If we already have, a burned interval we remove 1, since the previus interval is already burned
            _missedIntervals = timeElapsedSince <= INTERVAL_TIME ? 0 : uint16(timeElapsedSince / INTERVAL_TIME) - 1;
        }
    }

    /// @notice Updates the contract state for intervals
    function _intervalUpdate() private {
        if (block.timestamp < startTimeStamp) revert NotStartedYet();

        uint32 timeElapseSinceLastBurn = uint32(
            lastBurnedIntervalStartTimestamp == 0
                ? block.timestamp - startTimeStamp
                : block.timestamp - lastBurnedIntervalStartTimestamp
        );

        uint32 _lastInterval;
        uint128 _amountAllocated;
        uint16 _missedIntervals;
        uint32 _lastIntervalStartTimestamp;

        bool updated;

        ///@dev -> If this is the first time burning, Calculate if any intervals were missed and update update the allocated amount
        if (lastBurnedIntervalStartTimestamp == 0) {
            (_lastInterval, _amountAllocated, _missedIntervals) = _calculateIntervals(timeElapseSinceLastBurn);

            _lastIntervalStartTimestamp = startTimeStamp;

            updated = true;

            ///@dev -> If the lastBurnTimeExceeds, calculate how much intervals were skipped (if any) and calculate the amount accordingly
        } else if (timeElapseSinceLastBurn > INTERVAL_TIME) {
            (_lastInterval, _amountAllocated, _missedIntervals) = _calculateIntervals(timeElapseSinceLastBurn);

            _lastIntervalStartTimestamp = lastBurnedIntervalStartTimestamp;

            updated = true;

            _missedIntervals++;
        }

        if (updated) {
            lastBurnedIntervalStartTimestamp = _lastIntervalStartTimestamp + (_missedIntervals * INTERVAL_TIME);
            intervals[_lastInterval] = Interval({amountAllocated: _amountAllocated, amountBurned: 0});
            lastIntervalNumber = _lastInterval;
        }
    }

    /**
     * @notice Creates a Uniswap V3 pool and returns the parameters
     * @return amount0 The amount of token0
     * @return amount1 The amount of token1
     * @return amount0Min Minimum amount of token0
     * @return amount1Min Minimum amount of token1
     * @return token0 Address of token0
     * @return token1 Address of token1
     */
    function _sortAmounts(uint256 blazeAmount, uint256 infernoAmount)
        internal
        view
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 amount0Min,
            uint256 amount1Min,
            address token0,
            address token1
        )
    {
        address _blaze = address(blaze);
        address _inferno = address(infernoToken);

        (token0, token1) = _blaze < _inferno ? (_blaze, _inferno) : (_inferno, _blaze);
        (amount0, amount1) = token0 == _blaze ? (blazeAmount, infernoAmount) : (infernoAmount, blazeAmount);
        (amount0Min, amount1Min) = (_minus10Perc(amount0), _minus10Perc(amount1));
    }

    ///@notice Helper to remove 10% of an amount
    function _minus10Perc(uint256 _amount) internal pure returns (uint256 amount) {
        amount = (_amount * 9000) / BPS_DENOM;
    }
}
