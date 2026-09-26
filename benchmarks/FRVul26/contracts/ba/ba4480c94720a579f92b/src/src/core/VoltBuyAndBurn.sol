// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

/* === CORE === */
import {TheVolt} from "@core/TheVolt.sol";

/* === OZ === */
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/* === CONST === */
import "@const/Constants.sol";

/* == LIBS == */
import {OracleLibrary} from "@libs/OracleLibrary.sol";

/* == UNIV3 == */
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";

/* == UTILS == */
import {wmul, min} from "@utils/Math.sol";
import {Time} from "@utils/Time.sol";
import {Errors} from "@utils/Errors.sol";

/* == INTERFACES ==  */
import {IVolt} from "@interfaces/IVolt.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// import {ISwapRouter} from "../mocks/ISwapRouter.sol";

struct Slippage {
    uint64 slippage;
    ///@dev -> In minutes
    uint32 twapLookback;
}
/**
 * @title VoltBuyAndBurn
 * @author Zyntek
 * @notice This contract handles the buying and burning of Volt tokens using Uniswap V3 pools.
 */

contract VoltBuyAndBurn is Errors {
    using SafeERC20 for *;

    //=============STRUCTS============//

    /// @notice Struct to represent intervals for burning
    struct Interval {
        uint128 amountAllocated;
        uint128 amountBurned;
    }

    //===========IMMUTABLE===========//

    ///@notice The startTimestamp
    uint32 public immutable startTimeStamp;
    IVolt immutable volt;
    ERC20Burnable public immutable titanX;
    TheVolt public immutable theVolt;

    //===========STATE===========//

    Slippage titanXToVoltSlippage;
    address slippageAdmin;

    /// @notice Timestamp of the last burn call
    uint32 public lastBurnedIntervalStartTimestamp;

    /// @notice Total amount of Volt tokens burnt
    uint256 public totalVoltBurnt;

    /// @notice The last burned interval
    uint256 public lastBurnedInterval;

    /// @notice Maximum amount of titanX to be swapped and then burned
    uint128 swapCap;

    /// @notice Mapping from interval number to Interval struct
    mapping(uint32 interval => Interval) public intervals;

    /// @notice Last interval number
    uint32 public lastIntervalNumber;

    /// @notice Total TitanX tokens distributed
    uint256 public totalTitanXDistributed;

    /// @notice That last snapshot timestamp
    uint32 lastSnapshot;

    //===========EVENTS===========//

    /// @notice Event emitted when tokens are bought and burnt
    event BuyAndBurn(uint256 indexed titanXAmount, uint256 indexed voltBurnt, address indexed caller);

    //===========ERRORS===========//

    error NotStartedYet();
    error IntervalAlreadyBurned();
    error InvalidSlippage();
    error OnlySlippageAdmin();
    error VoltBuyAndBurn__OnlyEOA();
    error MustStartAt2PMUTC();

    //========CONSTRUCTOR========//

    constructor(uint32 _startTimestamp, ERC20Burnable _titanX, address _volt, address _owner, TheVolt _theVolt)
        notAddress0(_volt)
        notAddress0(_owner)
        notAddress0(address(_titanX))
    {
        if ((_startTimestamp - 14 hours) % 1 days != 0) revert MustStartAt2PMUTC();

        theVolt = _theVolt;
        volt = IVolt(_volt);
        titanX = _titanX;
        slippageAdmin = _owner;
        startTimeStamp = _startTimestamp;

        titanXToVoltSlippage = Slippage({slippage: WAD - 0.1e18, twapLookback: 15});

        swapCap = type(uint128).max;
    }

    //========MODIFIERS=======//

    /// @notice Updates the contract state for intervals
    modifier intervalUpdate() {
        _intervalUpdate();
        _;
    }

    modifier onlySlippageAdmin() {
        _onlySlippageAdmin();
        _;
    }

    //==========================//
    //==========PUBLIC==========//
    //==========================//

    function changeSlippageAdmin(address _new) external notAddress0(_new) onlySlippageAdmin {
        slippageAdmin = _new;
    }

    function setSwapCap(uint128 _newCap) external onlySlippageAdmin {
        swapCap = _newCap == 0 ? type(uint128).max : _newCap;
    }

    function changeTitanXToVoltSlippage(uint64 _newSlippage, uint32 _newLookback)
        external
        notAmount0(_newLookback)
        onlySlippageAdmin
    {
        if (_newSlippage > WAD) revert InvalidSlippage();

        titanXToVoltSlippage = Slippage({slippage: _newSlippage, twapLookback: _newLookback});
    }

    function getCurrentInterval()
        public
        view
        returns (
            uint32 _lastInterval,
            uint128 _amountAllocated,
            uint16 _missedIntervals,
            uint32 _lastIntervalStartTimestamp,
            uint256 beforeCurrday,
            bool updated
        )
    {
        uint32 startPoint = lastBurnedIntervalStartTimestamp == 0 ? startTimeStamp : lastBurnedIntervalStartTimestamp;
        uint32 timeElapseSinceLastBurn = Time.blockTs() - startPoint;

        if (lastBurnedIntervalStartTimestamp == 0 || timeElapseSinceLastBurn > INTERVAL_TIME) {
            (_lastInterval, _amountAllocated, _missedIntervals, beforeCurrday) =
                _calculateIntervals(timeElapseSinceLastBurn);
            _lastIntervalStartTimestamp = startPoint;
            _missedIntervals += timeElapseSinceLastBurn > INTERVAL_TIME && lastBurnedIntervalStartTimestamp != 0 ? 1 : 0;
            updated = true;
        }
    }

    /**
     * @notice Swaps TitanX for Volt and burns the Volt tokens
     * @param _deadline The deadline for which the passes should pass
     */
    function swapTitanXForVoltAndBurn(uint32 _deadline) external intervalUpdate notExpired(_deadline) {
        if (msg.sender != tx.origin) revert VoltBuyAndBurn__OnlyEOA();

        Interval storage currInterval = intervals[lastIntervalNumber];
        if (currInterval.amountBurned != 0) revert IntervalAlreadyBurned();

        if (currInterval.amountAllocated > swapCap) currInterval.amountAllocated = swapCap;

        currInterval.amountBurned = currInterval.amountAllocated;

        uint256 incentive = wmul(currInterval.amountAllocated, INCENTIVE_FEE);

        uint256 titanXToSwapAndBurn = currInterval.amountAllocated - incentive;

        uint256 voltAmount = _swapTitanXForVolt(titanXToSwapAndBurn, _deadline);

        volt.transfer(address(theVolt), wmul(voltAmount, uint256(0.5e18)));

        volt.transfer(LIQUIDITY_BONDING_ADDR, wmul(voltAmount, uint256(0.08e18)));

        burnVolt();

        titanX.safeTransfer(msg.sender, incentive);

        lastBurnedInterval = lastIntervalNumber;

        emit BuyAndBurn(titanXToSwapAndBurn, voltAmount, msg.sender);
    }

    /// @notice Burns Volt tokens held by the contract
    function burnVolt() public {
        uint256 voltToBurn = volt.balanceOf(address(this));

        totalVoltBurnt = totalVoltBurnt + voltToBurn;
        volt.burn(voltToBurn);
    }

    /**
     * @notice Distributes TitanX tokens for burning
     * @param _amount The amount of TitanX tokens
     */
    function distributeTitanXForBurning(uint256 _amount) external notAmount0(_amount) {
        ///@dev - If there are some missed intervals update the accumulated allocation before depositing new titanX

        titanX.safeTransferFrom(msg.sender, address(this), _amount);

        if (Time.blockTs() > startTimeStamp && Time.blockTs() - lastBurnedIntervalStartTimestamp > INTERVAL_TIME) {
            _intervalUpdate();
        }
    }

    //==========================//
    //=========GETTERS==========//
    //==========================//

    function daysSince(uint32 since, uint32 from) public pure returns (uint32 daysPassed) {
        assembly {
            daysPassed := div(sub(from, since), 86400)
        }
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
     * @return dailyWadAllocation The daily allocation in basis points
     */
    function getDailyTitanXAllocation(uint32 t) public view returns (uint256 dailyWadAllocation) {
        uint256 STARTING_ALOCATION = 0.42e18;
        uint256 MIN_ALOCATION = 0.15e18;
        uint256 daysSinceStart = daysSince(startTimeStamp, t);

        dailyWadAllocation = daysSinceStart >= 10 ? MIN_ALOCATION : STARTING_ALOCATION - (daysSinceStart * 0.03e18);
    }

    function getVoltQuoteForTitanX(uint256 baseAmount) public view returns (uint256 quote) {
        address poolAddress = volt.pool();

        uint32 secondsAgo = titanXToVoltSlippage.twapLookback * 60;
        uint32 oldestObservation = OracleLibrary.getOldestObservationSecondsAgo(poolAddress);

        if (oldestObservation < secondsAgo) secondsAgo = oldestObservation;

        (int24 arithmeticMeanTick,) = OracleLibrary.consult(poolAddress, secondsAgo);

        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);

        quote = OracleLibrary.getQuoteForSqrtRatioX96(sqrtPriceX96, baseAmount, address(titanX), address(volt));
    }

    //==========================//
    //=========INTERNAL=========//
    //==========================//

    /**
     * @notice Swaps TitanX tokens for Volt tokens
     * @param _titanXAmount The amount of TitanX tokens
     * @param _deadline The deadline for when the swap must be executed
     * @return _voltAmount The amount of Volt tokens received
     */
    function _swapTitanXForVolt(uint256 _titanXAmount, uint256 _deadline) internal returns (uint256 _voltAmount) {
        // wake-disable-next-line
        titanX.approve(UNISWAP_V3_ROUTER, _titanXAmount);
        // Setup the swap-path, swapp
        bytes memory path = abi.encodePacked(address(titanX), POOL_FEE, address(volt));

        uint256 expectedVoltAmount = getVoltQuoteForTitanX(_titanXAmount);

        uint256 amountOutMin = wmul(expectedVoltAmount, titanXToVoltSlippage.slippage);

        // Swap parameters
        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: _deadline,
            amountIn: _titanXAmount,
            amountOutMinimum: amountOutMin
        });

        // Execute the swap
        return ISwapRouter(UNISWAP_V3_ROUTER).exactInput(params);
    }

    function _calculateIntervals(uint256 timeElapsedSince)
        internal
        view
        returns (
            uint32 _lastIntervalNumber,
            uint128 _totalAmountForInterval,
            uint16 missedIntervals,
            uint256 beforeCurrDay
        )
    {
        missedIntervals = _calculateMissedIntervals(timeElapsedSince);

        _lastIntervalNumber = lastIntervalNumber + missedIntervals + 1;

        uint32 currentDay = Time.dayCountByT(uint32(block.timestamp));

        uint32 dayOfLastInterval =
            lastBurnedIntervalStartTimestamp == 0 ? currentDay : Time.dayCountByT(lastBurnedIntervalStartTimestamp);

        if (currentDay == dayOfLastInterval) {
            uint256 dailyAllocation = wmul(totalTitanXDistributed, getDailyTitanXAllocation(Time.blockTs()));

            uint128 _amountPerInterval = uint128(dailyAllocation / INTERVALS_PER_DAY);

            uint128 additionalAmount = _amountPerInterval * missedIntervals;

            _totalAmountForInterval = additionalAmount + _amountPerInterval;
        } else {
            uint32 _lastBurnedIntervalStartTimestamp = lastBurnedIntervalStartTimestamp;

            uint32 theEndOfTheDay = getDayEnd(_lastBurnedIntervalStartTimestamp);

            uint256 alreadyAllocated;

            uint256 balanceOf = titanX.balanceOf(address(this));

            while (currentDay >= dayOfLastInterval) {
                uint32 end = uint32(Time.blockTs() < theEndOfTheDay ? Time.blockTs() : theEndOfTheDay - 1);

                uint32 accumulatedIntervalsForTheDay = (end - _lastBurnedIntervalStartTimestamp) / INTERVAL_TIME;

                uint256 diff = balanceOf > alreadyAllocated ? balanceOf - alreadyAllocated : 0;

                //@note - If the day we are looping over the same day as the last interval's use the cached allocation, otherwise use the current balance
                uint256 forAllocation = Time.dayCountByT(lastBurnedIntervalStartTimestamp) == dayOfLastInterval
                    ? totalTitanXDistributed
                    : balanceOf >= alreadyAllocated + wmul(diff, getDailyTitanXAllocation(end)) ? diff : 0;

                uint256 dailyAllocation = wmul(forAllocation, getDailyTitanXAllocation(end));

                uint128 _amountPerInterval = uint128(dailyAllocation / INTERVALS_PER_DAY);

                _totalAmountForInterval += _amountPerInterval * accumulatedIntervalsForTheDay;

                ///@notice ->  minus 15 minutes since, at the end of the day the new epoch with new allocation
                _lastBurnedIntervalStartTimestamp = theEndOfTheDay - INTERVAL_TIME;

                ///@notice ->  plus 15 minutes to flip into the next day
                theEndOfTheDay = getDayEnd(_lastBurnedIntervalStartTimestamp + INTERVAL_TIME);

                if (dayOfLastInterval == currentDay) beforeCurrDay = alreadyAllocated;

                alreadyAllocated += dayOfLastInterval == currentDay
                    ? _amountPerInterval * accumulatedIntervalsForTheDay
                    : dailyAllocation;

                dayOfLastInterval++;
            }
        }

        Interval memory prevInt = intervals[lastIntervalNumber];

        //@note - If the last interval was only updated, but not burned add its allocation to the next one.
        uint128 additional = prevInt.amountBurned == 0 ? prevInt.amountAllocated : 0;

        if (_totalAmountForInterval + additional > titanX.balanceOf(address(this))) {
            _totalAmountForInterval = uint128(titanX.balanceOf(address(this)));
        } else {
            _totalAmountForInterval += additional;
        }
    }

    function _calculateMissedIntervals(uint256 timeElapsedSince) internal view returns (uint16 _missedIntervals) {
        _missedIntervals = uint16(timeElapsedSince / INTERVAL_TIME);

        if (lastBurnedIntervalStartTimestamp != 0) _missedIntervals--;
    }

    function _updateSnapshot(uint256 deltaAmount) internal {
        if (Time.blockTs() < startTimeStamp || lastSnapshot + 24 hours > Time.blockTs()) return;

        uint32 timeElapsed = Time.blockTs() - startTimeStamp;

        uint32 snapshots = timeElapsed / 24 hours;

        uint256 balance = titanX.balanceOf(address(this));

        totalTitanXDistributed = deltaAmount > balance ? 0 : balance - deltaAmount;
        lastSnapshot = startTimeStamp + (snapshots * 24 hours);
    }

    /// @notice Updates the contract state for intervals
    function _intervalUpdate() private {
        if (Time.blockTs() < startTimeStamp) revert NotStartedYet();

        if (lastSnapshot == 0) _updateSnapshot(0);

        (
            uint32 _lastInterval,
            uint128 _amountAllocated,
            uint16 _missedIntervals,
            uint32 _lastIntervalStartTimestamp,
            uint256 beforeCurrentDay,
            bool updated
        ) = getCurrentInterval();

        _updateSnapshot(beforeCurrentDay);

        if (updated) {
            lastBurnedIntervalStartTimestamp = _lastIntervalStartTimestamp + (uint32(_missedIntervals) * INTERVAL_TIME);
            intervals[_lastInterval] = Interval({amountAllocated: _amountAllocated, amountBurned: 0});
            lastIntervalNumber = _lastInterval;
        }
    }

    function _onlySlippageAdmin() private view {
        if (msg.sender != slippageAdmin) revert OnlySlippageAdmin();
    }
}
