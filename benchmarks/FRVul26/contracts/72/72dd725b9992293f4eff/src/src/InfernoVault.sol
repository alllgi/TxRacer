// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/* == OZ == */
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/* == UTILS ==  */
import {wmul} from "@utils/Math.sol";
import {Time} from "@utils/Time.sol";

/* == CORE == */
import {AlienX} from "./AlienX.sol";
import {BaseBuyAndBurn} from "./BuyAndBurn/BaseBuyAndBurn.sol";

/* == UNIV2 == */
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/* == CONST == */
import "./const/Constants.sol";

contract InfernoVault is BaseBuyAndBurn {
    /* == IMMUTABLE == */

    ERC20Burnable private immutable inferno;
    AlienX private immutable alienX;

    /* == CONSTRUCTOR == */

    /// @notice Constructor initializes the contract
    /// @notice Constructor is payable to save gas
    constructor(
        uint32 startTimestamp,
        address _alienX,
        address _inferno,
        address _v2Router,
        address _v3Router,
        address _owner
    ) payable BaseBuyAndBurn(startTimestamp, _v2Router, _v3Router, _inferno, _owner) {
        inferno = ERC20Burnable(_inferno);
        alienX = AlienX(_alienX);
    }

    /**
     * @notice Swaps TitanX for AlienX and burns the AlienX tokens
     * @param _amountAlienXMin Minimum amount of Blaze tokens expected
     * @param _deadline The deadline for which the passes should pass
     */
    function swapInfernoForAlienXAndBurn(uint256 _amountAlienXMin, uint32 _deadline) external intervalUpdate {
        Interval storage currInterval = intervals[lastIntervalNumber];
        if (!isPermissioned[msg.sender]) revert OnlyPermissionAdresses();
        if (currInterval.amountBurned != 0) revert IntervalAlreadyBurned();

        if (currInterval.amountAllocated > swapCap) currInterval.amountAllocated = swapCap;

        currInterval.amountBurned = currInterval.amountAllocated;

        uint256 incentive = wmul(currInterval.amountAllocated, INCENTIVE);

        uint256 infernoToSwapAndBurn = currInterval.amountAllocated - incentive;

        uint256 balanceBefore = alienX.balanceOf(address(this));

        _swapInfernoForAlienX(infernoToSwapAndBurn, _amountAlienXMin, _deadline);

        uint256 balanceAfter = alienX.balanceOf(address(this));

        burnAlienX();

        lastBurnedInterval = lastIntervalNumber;

        inferno.transfer(msg.sender, incentive);

        emit BuyAndBurn(infernoToSwapAndBurn, balanceAfter - balanceBefore, msg.sender);
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
    function distributeInfernoForBurning(uint256 _amount) external {
        if (_amount == 0) revert InvalidInput();

        ///@dev - If there are some missed intervals update the accumulated allocation before depositing new titanX
        if (Time.blockTs() > startTimeStamp && Time.blockTs() - lastBurnedIntervalStartTimestamp > INTERVAL_TIME) {
            _intervalUpdate();
        }

        inferno.transferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @notice Gets the daily TitanX allocation
     * @return dailyWadAllocation The daily allocation in WAD
     */
    function getDailyTokenAllocation(uint32) public pure override returns (uint64 dailyWadAllocation) {
        return INFERNO_VAULT_DAILY_ALLOCATION;
    }

    /* == INTERNAL/PRIVATE == */

    /**
     * @notice Swaps Inferno tokens for AlienX tokens
     * @param amountInferno The amount of Inferno tokens
     * @param amountAlienXMin Minimum amount of AlienX tokens expected
     */
    function _swapInfernoForAlienX(uint256 amountInferno, uint256 amountAlienXMin, uint256 _deadline) private {
        inferno.approve(v2Router, amountInferno);

        address[] memory path = new address[](2);
        path[0] = address(inferno);
        path[1] = address(alienX);

        IUniswapV2Router02(v2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountInferno, amountAlienXMin, path, address(this), _deadline
        );
    }
}
