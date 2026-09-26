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
import {InfernoVault} from "./InfernoVault.sol";

/* == UNIV2 == */
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/* == UNIV3 == */
import {OracleLibrary} from "./libraries/OracleLibrary.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// import {ISwapRouter} from "../test/mocks/ISwapRouter.sol";

/* == CONST == */
import "./const/Constants.sol";

/**
 * @title BuyAndBurn1
 * @notice This contract buys and sends inferno to the vault for it to burned later
 */
contract BuyAndBurn1 is BaseBuyAndBurn {
    /* == IMMUTABLE == */

    ERC20Burnable private immutable inferno;
    ERC20Burnable private immutable titanX;
    address private immutable titanXInfernoPool;
    InfernoVault public immutable infernoVault;

    uint256 public totalInfernoSentToVault;

    uint256 public titanXToInfernoSlippage;

    error OnlyEOA();

    /* == CONSTRUCTOR == */

    /// @notice Constructor initializes the contract
    /// @notice Constructor is payable to save gas
    constructor(
        uint32 startTimestamp,
        address _titanX,
        address _titanXInfernoPool,
        address _inferno,
        address _infernoVault,
        address _v2Router,
        address _v3Router,
        address _owner
    ) payable BaseBuyAndBurn(startTimestamp, _v2Router, _v3Router, _titanX, _owner) {
        inferno = ERC20Burnable(_inferno);
        infernoVault = InfernoVault(_infernoVault);
        titanXInfernoPool = _titanXInfernoPool;
        titanX = ERC20Burnable(_titanX);

        titanXToInfernoSlippage = 20;
    }

    function changeTitanXToInfernoSlippage(uint256 _newSlippage) external onlyOwner {
        if (_newSlippage > 100) revert InvalidInput();
        titanXToInfernoSlippage = _newSlippage;
    }

    /**
     * @notice Swaps TitanX for AlienX and burns the AlienX tokens
     * @param _deadline The deadline for which the passes should pass
     */
    function swapTitanXForInfernoAndSendToVault(uint32 _deadline) external intervalUpdate {
        require(tx.origin == msg.sender, OnlyEOA());
        Interval storage currInterval = intervals[lastIntervalNumber];
        if (currInterval.amountBurned != 0) revert IntervalAlreadyBurned();

        if (currInterval.amountAllocated > swapCap) currInterval.amountAllocated = swapCap;

        currInterval.amountBurned = currInterval.amountAllocated;

        uint256 incentive = wmul(currInterval.amountAllocated, INCENTIVE);

        uint256 titanXToSwapAndBurn = currInterval.amountAllocated - incentive;

        uint256 infernoAmount = _swapTitanXForInferno(titanXToSwapAndBurn, _deadline);

        inferno.approve(address(infernoVault), infernoAmount);
        infernoVault.distributeInfernoForBurning(infernoAmount);

        totalInfernoSentToVault += infernoAmount;

        lastBurnedInterval = lastIntervalNumber;

        titanX.transfer(msg.sender, incentive);

        emit BuyAndBurn(titanXToSwapAndBurn, infernoAmount, msg.sender);
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

    /**
     * @notice Gets the daily TitanX allocation
     * @return dailyWadAllocation The daily allocation in WAD
     */
    function getDailyTokenAllocation(uint32) public pure override returns (uint64 dailyWadAllocation) {
        return 0.1428e18;
    }

    /**
     * @notice Gets a quote for Inferno tokens in exchange for TitanX tokens
     * @param baseAmount The amount of TitanX tokens
     * @return quote The amount of Inferno tokens received
     */
    function getInfernoQuoteForTitanX(uint256 baseAmount) public view returns (uint256 quote) {
        address poolAddress = titanXInfernoPool;
        uint32 secondsAgo = 15 * 60;
        uint32 oldestObservation = OracleLibrary.getOldestObservationSecondsAgo(poolAddress);

        if (oldestObservation < secondsAgo) secondsAgo = oldestObservation;

        (int24 arithmeticMeanTick,) = OracleLibrary.consult(poolAddress, secondsAgo);

        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);

        quote = OracleLibrary.getQuoteForSqrtRatioX96(sqrtPriceX96, baseAmount, address(titanX), address(inferno));
    }

    /**
     * @notice Swaps TitanX tokens for Blaze tokens
     * @param amountTitanX The amount of TitanX tokens
     * @return _infernoAmount The amount of Blaze tokens received
     */
    function _swapTitanXForInferno(uint256 amountTitanX, uint256 _deadline) private returns (uint256 _infernoAmount) {
        titanX.approve(v3Router, amountTitanX);

        // Setup the swap-path, swapp
        bytes memory path = abi.encodePacked(address(titanX), POOL_FEE, address(inferno));

        uint256 expectedInfernoAmount = getInfernoQuoteForTitanX(amountTitanX);

        // Adjust for slippage (applied uniformly across both hops)
        uint256 adjustedInfernoAmount = (expectedInfernoAmount * (100 - titanXToInfernoSlippage)) / 100;

        // Swap parameters
        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: _deadline,
            amountIn: amountTitanX,
            amountOutMinimum: adjustedInfernoAmount
        });

        // Execute the swap
        return ISwapRouter(v3Router).exactInput(params);
    }
}
