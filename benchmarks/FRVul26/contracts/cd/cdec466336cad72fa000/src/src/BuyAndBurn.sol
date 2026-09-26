// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/* == OZ == */
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/* == UTILS ==  */
import {wmul} from "@utils/Math.sol";
import {Time} from "@utils/Time.sol";

/* == CORE == */
import {BaseBuyAndBurn} from "./BuyAndBurn/BaseBuyAndBurn.sol";
import {AlienX} from "./AlienX.sol";

/* == UNIV2 == */
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/* == CONST == */
import "./const/Constants.sol";

contract AlienXBuyAndBurn is BaseBuyAndBurn {
    /* == IMMUTABLE == */

    AlienX private immutable alienX;

    IERC20 private immutable titanX;

    /* == CONSTRUCTOR == */

    /// @notice Constructor initializes the contract
    /// @notice Constructor is payable to save gas
    constructor(
        uint32 startTimestamp,
        address _titanX,
        address _alienX,
        address _v2Router,
        address _v3Router,
        address _owner
    ) payable BaseBuyAndBurn(startTimestamp, _v2Router, _v3Router, _titanX, _owner) {
        alienX = AlienX(_alienX);
        titanX = IERC20(_titanX);
    }

    /**
     * @notice Swaps TitanX for AlienX and burns the AlienX tokens
     * @param _amountAlienXMin Minimum amount of Blaze tokens expected
     * @param _deadline The deadline for which the passes should pass
     */
    function swapTitanXForAlienXAndBurn(uint256 _amountAlienXMin, uint32 _deadline) external intervalUpdate {
        Interval storage currInterval = intervals[lastIntervalNumber];
        if (!isPermissioned[msg.sender]) revert OnlyPermissionAdresses();
        if (currInterval.amountBurned != 0) revert IntervalAlreadyBurned();

        if (currInterval.amountAllocated > swapCap) currInterval.amountAllocated = swapCap;

        currInterval.amountBurned = currInterval.amountAllocated;

        uint256 incentive = wmul(currInterval.amountAllocated, INCENTIVE);

        uint256 titanXToSwapAndBurn = currInterval.amountAllocated - incentive;

        uint256 balanceBefore = alienX.balanceOf(address(this));
        _swapTitanXForAlienX(titanXToSwapAndBurn, _amountAlienXMin, _deadline);
        uint256 balanceAfter = alienX.balanceOf(address(this));

        burnAlienX();

        titanX.transfer(msg.sender, incentive);

        lastBurnedInterval = lastIntervalNumber;

        emit BuyAndBurn(titanXToSwapAndBurn, balanceAfter - balanceBefore, msg.sender);
    }

    /// @notice Burns AlienX tokens held by the contract
    function burnAlienX() public {
        uint256 alienXToBurn = alienX.balanceOf(address(this));

        totalAlienXBurnt = totalAlienXBurnt + alienXToBurn;
        alienX.burn(alienXToBurn);
    }

    /**
     * @notice Distributes TitanX tokens for burning
     * @param _amount The amount of TitanX tokens
     */
    function distributeTitanXForBurning(uint256 _amount) external {
        if (_amount == 0) revert InvalidInput();

        ///@dev - If there are some missed intervals update the accumulated allocation before depositing new titanX
        if (Time.blockTs() > startTimeStamp && Time.blockTs() - lastBurnedIntervalStartTimestamp > INTERVAL_TIME) {
            _intervalUpdate();
        }

        titanX.transferFrom(msg.sender, address(this), _amount);
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
     * @return dailyWadAllocation The daily allocation in WAD
     */
    function getDailyTokenAllocation(uint32 timestamp) public pure override returns (uint64 dailyWadAllocation) {
        uint256 weekDay = weekDayByT(timestamp);

        if (weekDay == 0 || weekDay == 1) {
            dailyWadAllocation = 0.008e18; // 0.8%
        } else if (weekDay == 2) {
            dailyWadAllocation = 0.017e18; // 1.7%
        } else if (weekDay == 3 || weekDay == 4) {
            dailyWadAllocation = 0.026e18; // 2.6%
        } else {
            dailyWadAllocation = 0.028e18; // 2.8%
        }
    }

    /* == INTERNAL/PRIVATE == */

    /**
     * @notice Swaps TitanX tokens for Blaze tokens
     * @param amountTitanX The amount of TitanX tokens
     * @param amountAlienXMin Minimum amount of AlienX tokens expected
     */
    function _swapTitanXForAlienX(uint256 amountTitanX, uint256 amountAlienXMin, uint256 _deadline) private {
        titanX.approve(v2Router, amountTitanX);

        address[] memory path = new address[](2);
        path[0] = address(titanX);
        path[1] = address(alienX);

        IUniswapV2Router02(v2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountTitanX, amountAlienXMin, path, address(this), _deadline
        );
    }
}
