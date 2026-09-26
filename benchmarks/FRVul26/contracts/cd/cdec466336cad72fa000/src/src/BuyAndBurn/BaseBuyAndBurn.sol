// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/* == OZ == */
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/* == UTILS ==  */
import {wmul} from "@utils/Math.sol";
import {Time} from "@utils/Time.sol";

/* == CONST == */
import "../const/Constants.sol";

contract BaseBuyAndBurn is Ownable {
    /* == STRUCTS == */

    /// @notice Struct to represent intervals for burning
    struct Interval {
        uint128 amountAllocated;
        uint128 amountBurned;
    }

    /* == IMMUTABLE == */

    /// @notice TitanX token contract
    IERC20 internal immutable buyingToken;

    ///@notice The startTimestamp
    uint32 public immutable startTimeStamp;

    address immutable v2Router;
    address immutable v3Router;

    /* == STATE == */

    uint32 public lastSnapshotTimestamp;

    /// @notice Timestamp of the last burn call
    uint32 public lastBurnedIntervalStartTimestamp;

    /// @notice Total amount of AlienX tokens burnt
    uint256 public totalAlienXBurnt;

    mapping(address => bool) public isPermissioned;

    /// @notice Mapping from interval number to Interval struct
    mapping(uint32 interval => Interval) public intervals;

    /// @notice Last interval number
    uint32 public lastIntervalNumber;

    uint32 public lastBurnedInterval;

    /// @notice Total TitanX tokens distributed
    uint256 public totalTitanXDistributed;

    ///@notice - The maximum amount a swap can have for the BnB
    uint128 public swapCap;

    /* == EVENTS == */

    /// @notice Event emitted when tokens are bought and burnt
    event BuyAndBurn(uint256 indexed titanXAmount, uint256 indexed alienXAmount, address indexed caller);

    /* == ERRORS == */

    /// @notice Error when the contract has not started yet
    error NotStartedYet();

    error SnapshotDuration();

    error OnlyPermissionAdresses();

    /// @notice Error when some user input is considered invalid
    error InvalidInput();

    /// @notice Error when interval has already been burned
    error IntervalAlreadyBurned();

    error MustStartAt2PMUTC();

    /* == CONSTRUCTOR == */

    /// @notice Constructor initializes the contract
    /// @notice Constructor is payable to save gas
    constructor(uint32 startTimestamp, address _v2Router, address _v3Router, address _buyingToken, address _owner)
        payable
        Ownable(_owner)
    {
        // if ((startTimestamp - 14 hours) % 1 days != 0) revert MustStartAt2PMUTC();

        startTimeStamp = startTimestamp;
        buyingToken = IERC20(_buyingToken);

        v3Router = _v3Router;
        v2Router = _v2Router;

        isPermissioned[_owner] = true;

        swapCap = type(uint128).max;
    }

    /* === MODIFIERS === */

    /// @notice Updates the contract state for intervals
    modifier intervalUpdate() {
        _intervalUpdate();
        _;
    }

    /* == PUBLIC/EXTERNAL == */

    function togglePermissionedAddress(address _caller, bool _isPermissioned) external onlyOwner {
        isPermissioned[_caller] = _isPermissioned;
    }

    function changeSwapCap(uint128 _newSwapCap) external onlyOwner {
        swapCap = _newSwapCap;
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

    /* == INTERNAL/PRIVATE == */

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

        uint32 currentDay = Time.dayGap(startTimeStamp, Time.blockTs());

        uint32 dayOfLastInterval = lastBurnedIntervalStartTimestamp == 0
            ? currentDay
            : Time.dayGap(startTimeStamp, lastBurnedIntervalStartTimestamp);

        if (currentDay == dayOfLastInterval) {
            uint256 dailyAllocation = wmul(totalTitanXDistributed, getDailyTokenAllocation(Time.blockTs()));

            uint128 _amountPerInterval = uint128(dailyAllocation / INTERVALS_PER_DAY);

            uint128 additionalAmount = _amountPerInterval * missedIntervals;

            _totalAmountForInterval = _amountPerInterval + additionalAmount;
        } else {
            uint32 _lastBurnedIntervalStartTimestamp = lastBurnedIntervalStartTimestamp;

            uint32 theEndOfTheDay = Time.getDayEnd(_lastBurnedIntervalStartTimestamp);

            uint256 balanceOf = buyingToken.balanceOf(address(this));

            while (currentDay >= dayOfLastInterval) {
                uint32 end = uint32(Time.blockTs() < theEndOfTheDay ? Time.blockTs() : theEndOfTheDay - 1);

                uint32 accumulatedIntervalsForTheDay = (end - _lastBurnedIntervalStartTimestamp) / INTERVAL_TIME;

                uint256 diff = balanceOf > _totalAmountForInterval ? balanceOf - _totalAmountForInterval : 0;

                //@note - If the day we are looping over the same day as the last interval's use the cached allocation, otherwise use the current balance
                uint256 forAllocation = lastSnapshotTimestamp + 1 weeks > end
                    ? totalTitanXDistributed
                    : balanceOf >= _totalAmountForInterval + wmul(diff, getDailyTokenAllocation(end)) ? diff : 0;

                uint256 dailyAllocation = wmul(forAllocation, getDailyTokenAllocation(end));

                ///@notice ->  minus INTERVAL_TIME minutes since, at the end of the day the new epoch with new allocation
                _lastBurnedIntervalStartTimestamp = theEndOfTheDay - INTERVAL_TIME;

                ///@notice ->  plus INTERVAL_TIME minutes to flip into the next day
                theEndOfTheDay = Time.getDayEnd(_lastBurnedIntervalStartTimestamp + INTERVAL_TIME);

                if (dayOfLastInterval == currentDay) beforeCurrDay = _totalAmountForInterval;

                _totalAmountForInterval +=
                    uint128((dailyAllocation * accumulatedIntervalsForTheDay) / INTERVALS_PER_DAY);

                dayOfLastInterval++;
            }
        }

        Interval memory prevInt = intervals[lastIntervalNumber];

        //@note - If the last interval was only updated, but not burned add its allocation to the next one.
        uint128 additional = prevInt.amountBurned == 0 ? prevInt.amountAllocated : 0;

        if (_totalAmountForInterval + additional > buyingToken.balanceOf(address(this))) {
            _totalAmountForInterval = uint128(buyingToken.balanceOf(address(this)));
        } else {
            _totalAmountForInterval += additional;
        }
    }

    function getDailyTokenAllocation(uint32 from) public pure virtual returns (uint64 dailyWadAllocation) {}

    function _calculateMissedIntervals(uint256 timeElapsedSince) internal view returns (uint16 _missedIntervals) {
        _missedIntervals = uint16(timeElapsedSince / INTERVAL_TIME);

        if (lastBurnedIntervalStartTimestamp != 0) _missedIntervals--;
    }

    function _updateSnapshot(uint256 deltaAmount) internal {
        if (Time.blockTs() < startTimeStamp || lastSnapshotTimestamp + 1 weeks > Time.blockTs()) return;

        uint32 timeElapsed = uint32(Time.blockTs() - startTimeStamp);

        uint32 snapshots = timeElapsed / 1 weeks;

        uint256 balance = buyingToken.balanceOf(address(this));

        totalTitanXDistributed = deltaAmount > balance ? 0 : balance - deltaAmount;
        lastSnapshotTimestamp = startTimeStamp + (snapshots * 1 weeks);
    }

    /// @notice Updates the contract state for intervals
    function _intervalUpdate() internal {
        require(Time.blockTs() >= startTimeStamp, NotStartedYet());

        if (lastSnapshotTimestamp == 0) _updateSnapshot(0);

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
}
