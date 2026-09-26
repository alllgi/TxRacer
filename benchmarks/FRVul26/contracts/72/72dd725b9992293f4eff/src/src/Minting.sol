// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/* === OZ === */
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/* == CORE == */
import {AlienX} from "./AlienX.sol";
import {AlienXBuyAndBurn} from "./BuyAndBurn.sol";
import {BuyAndBurn1} from "./BuyAndBurn1.sol";

/* == UTILS */
import {wdiv, wmul, sub, wpow} from "@utils/Math.sol";

/* == UNIV3 == */
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// import {ISwapRouter} from "../test/mocks/ISwapRouter.sol";

/* == UNIV2 == */
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

/* == CONST == */
import "./const/Constants.sol";

/* == INTERFACES == */
import {IFluxBuyAndBurn} from "./interfaces/IFluxBuyAndBurn.sol";

/**
 * @title AlienXMinting
 * @notice This contract allows users to mint AlienX tokens by depositing TITANX tokens during specific minting cycles.
 * @dev The contract enforces minting and claiming based on time-locked cycles and automatically burns part of the deposited tokens.
 */
contract AlienXMinting is Ownable {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /* == CONSTANTS ==  */

    /// @notice The duration of one mint cycle (24 hours)
    uint32 public constant MINT_CYCLE_DURATION = 24 hours;

    /// @notice The gap between mint cycles (1 week)
    uint32 public constant GAP_BETWEEN_CYCLE = 1 weeks;

    /// @notice The total number of mint cycles (8 cycles)
    uint8 public constant MAX_MINT_CYCLE = 8;

    /// @notice The starting ratio for the first mint cycle (1:1)
    uint256 constant STARTING_RATIO = 1e18;

    /* == IMMUTABLES == */

    /// @notice The TITANX token address
    IERC20 public immutable titanX;

    /// @notice The Inferno token address
    IERC20 public immutable inferno;

    /// @notice The AlienX token contract
    AlienX public immutable alienX;

    /// @notice Timestamp when the minting cycle starts
    uint32 public immutable startTimestamp;

    /// @notice Flux Buy and Burn contract
    IFluxBuyAndBurn immutable fluxBnB;

    /// @notice AlienX Buy and Burn contract
    AlienXBuyAndBurn immutable bnb;

    uint256 totalSentToLP;

    /// @notice InfernoVault contract
    BuyAndBurn1 immutable bnb1;

    /// @notice Uniswap V3 router address
    address immutable v3Router;
    address immutable v2Factory;

    address immutable infernoBnBV2;

    /// @notice Uniswap V2 router address
    address immutable v2Router;

    /* == STATE == */

    uint256 public totalTitanXBurnt;
    uint256 public totalSentToFluxBnB;

    /// @notice Tracks if liquidity has been added to the pool
    bool public addedLiquidity;

    /// @notice Total amount of TITANX deposited
    uint256 public totalTitanXDeposited;

    /// @notice Total amount of AlienX claimed
    uint256 public totalAlienXClaimed;

    /// @notice Total amount of AlienX minted
    uint256 public totalAlienXMinted;

    /// @notice Mapping to track user claims across cycles
    mapping(address user => mapping(uint32 cycleId => uint256 amount)) public amountToClaim;

    /* == ERRORS == */

    error InvalidInput();
    error CycleStillOngoing();
    error NotStartedYet();
    error CycleIsOver();
    error NoalienXToClaim();
    error InvalidStartTime();
    error NotEnoughBalanceForLp();
    error LiquidityAlreadyAdded();

    /* == EVENTS == */

    /// @notice Event emitted when a user mints AlienX tokens during a mint cycle
    /// @param user Address of the user minting AlienX
    /// @param alienXAmount The amount of AlienX minted
    /// @param mintCycleId The mint cycle ID
    event MintExecuted(address indexed user, uint256 alienXAmount, uint32 indexed mintCycleId);

    /// @notice Event emitted when a user claims AlienX tokens after a mint cycle ends
    /// @param user Address of the user claiming AlienX
    /// @param alienXAmount The amount of AlienX claimed
    /// @param mintCycleId The mint cycle ID
    event ClaimExecuted(address indexed user, uint256 alienXAmount, uint8 indexed mintCycleId);

    /* == CONSTRUCTOR == */

    /**
     * @notice Initializes the AlienXMinting contract
     * @param _titanX Address of the TitanX token
     * @param _inferno Address of the Inferno token
     * @param _v3Router Address of the Uniswap V3 router
     * @param _fluxBnB Address of the Flux buy-and-burn contract
     * @param _bnb Address of the AlienX buy-and-burn contract
     * @param _bnb1 Address of the Bnb1 contract
     * @param _alienX Address of the AlienX token contract
     * @param _v2Router Address of the Uniswap V2 router
     * @param _startTimestamp Timestamp when the first mint cycle starts
     */
    constructor(
        address _titanX,
        address _inferno,
        address _v3Router,
        address _fluxBnB,
        address _infernoBnBV2,
        address _bnb,
        address _bnb1,
        address _alienX,
        address _v2Router,
        uint32 _startTimestamp
    ) Ownable(msg.sender) {
        v3Router = _v3Router;
        v2Router = _v2Router;

        infernoBnBV2 = _infernoBnBV2;
        startTimestamp = _startTimestamp;

        bnb1 = BuyAndBurn1(_bnb1);

        bnb = AlienXBuyAndBurn(_bnb);

        fluxBnB = IFluxBuyAndBurn(_fluxBnB);
        inferno = IERC20(_inferno);
        alienX = AlienX(_alienX);
        titanX = IERC20(_titanX);
    }

    /* == EXTERNAL == */

    /**
     * @notice Mints AlienX tokens by depositing TITANX tokens during an ongoing mint cycle.
     * @param _amount The amount of TITANX tokens to deposit.
     * @dev The amount of AlienX minted is proportional to the deposited TITANX and decreases over cycles.
     */
    function mint(uint256 _amount) external {
        if (_amount == 0) revert InvalidInput();
        if (block.timestamp < startTimestamp) revert NotStartedYet();

        (uint32 currentCycle,, uint32 endsAt) = getCurrentMintCycle();
        if (block.timestamp > endsAt) revert CycleIsOver();

        titanX.safeTransferFrom(msg.sender, address(this), _amount);
        _distribute(_amount);

        uint256 alienXAmount = (_amount * getRatioForCycle(currentCycle)) / 1e18;

        amountToClaim[msg.sender][currentCycle] += alienXAmount;

        emit MintExecuted(msg.sender, alienXAmount, currentCycle);

        totalAlienXMinted = totalAlienXMinted + alienXAmount;
        totalTitanXDeposited = totalTitanXDeposited + _amount;
    }

    /**
     * @notice Claims the minted AlienX tokens after the end of the specified mint cycle.
     * @param _cycleId The ID of the mint cycle to claim tokens from.
     * @dev Users can only claim after the mint cycle has ended.
     */
    function claim(uint8 _cycleId) external {
        if (_getCycleEndTime(_cycleId) > block.timestamp) revert CycleStillOngoing();

        uint256 toClaim = amountToClaim[msg.sender][_cycleId];
        if (toClaim == 0) revert NoalienXToClaim();

        delete amountToClaim[msg.sender][_cycleId];

        emit ClaimExecuted(msg.sender, toClaim, _cycleId);

        totalAlienXClaimed = totalAlienXClaimed + toClaim;
        alienX.mint(msg.sender, toClaim);
    }

    /* == INTERNAL/PRIVATE == */

    /**
     * @notice Internal function to distribute TITANX tokens to various destinations for burning.
     * @param _amount The amount of TITANX tokens to distribute.
     */
    function _distribute(uint256 _amount) internal {
        uint256 titanXBalance = titanX.balanceOf(address(this));
        if (!addedLiquidity) {
            if (titanXBalance <= (INITIAL_TITAN_X_ALIENX_LP + INITIAL_TITANX_FOR_INF_ALX_LP) + 1) return;
            _amount = uint192(titanXBalance - (INITIAL_TITAN_X_ALIENX_LP + INITIAL_TITANX_FOR_INF_ALX_LP + 1));
        }

        if (totalSentToLP < INITIAL_TITAN_X_SENT_TO_LP) {
            uint256 amountLeft = INITIAL_TITAN_X_SENT_TO_LP - totalSentToLP;
            uint256 amountToAdd = amountLeft >= _amount ? _amount : amountLeft;
            totalSentToLP += amountToAdd;
            _amount -= amountToAdd;

            titanX.transfer(ALIENX_LP, amountToAdd);
        }

        if (_amount == 0) return;

        uint256 _toInfernoVault = wmul(_amount, TO_INFERNO_VAULT);
        uint256 _toBnb = wmul(_amount, TO_ALIENX_BNB);
        uint256 _toFluxBnB = wmul(_amount, TO_FLUX_BNB);

        titanX.approve(address(bnb1), _toInfernoVault);
        bnb1.distributeTitanXForBurning(_toInfernoVault);

        titanX.approve(address(bnb), _toBnb);
        bnb.distributeTitanXForBurning(_toBnb);

        totalTitanXBurnt += wmul(_amount, TITAN_X_BURN);
        titanX.transfer(DEAD_ADDR, wmul(_amount, TITAN_X_BURN));
        titanX.transfer(INFERNO_BNB_V2, wmul(_amount, TO_INFERNO_BNB));

        totalSentToFluxBnB += _toFluxBnB;
        titanX.approve(address(fluxBnB), _toFluxBnB);
        fluxBnB.distributeTitanXForBurning(_toFluxBnB);

        titanX.transfer(FLUX_LP, wmul(_amount, TO_FLUX_LP));
        titanX.transfer(ALIENX_LP, wmul(_amount, TO_ALIEN_X_LP));
        titanX.transfer(GENESIS_1, wmul(_amount, TO_GENESIS_1));
        titanX.transfer(GENESIS_2, wmul(_amount, TO_GENESIS_2));
    }

    /**
     * @notice Gets the current mint cycle based on the block timestamp.
     * @return currentCycle The current mint cycle ID
     * @return startsAt Timestamp when the current cycle starts
     * @return endsAt Timestamp when the current cycle ends
     */
    function getCurrentMintCycle() public view returns (uint32 currentCycle, uint32 startsAt, uint32 endsAt) {
        uint32 timeElapsedSince = uint32(block.timestamp - startTimestamp);
        currentCycle = uint8(timeElapsedSince / GAP_BETWEEN_CYCLE) + 1;

        if (currentCycle > MAX_MINT_CYCLE) currentCycle = MAX_MINT_CYCLE;

        startsAt = startTimestamp + ((currentCycle - 1) * GAP_BETWEEN_CYCLE);
        endsAt = startsAt + MINT_CYCLE_DURATION;
    }

    /**
     * @notice Gets the minting ratio for a specific cycle.
     * @param cycleId The mint cycle ID
     * @return ratio The ratio of AlienX to TITANX for the given cycle
     */
    function getRatioForCycle(uint32 cycleId) public pure returns (uint256 ratio) {
        unchecked {
            uint256 adjustedRatioDiscount = cycleId == 1 ? 0 : uint256(cycleId - 1) * 0.08e18;
            ratio = STARTING_RATIO - adjustedRatioDiscount;
        }
    }

    /**
     * @notice Gets the end time of a specific mint cycle.
     * @param cycleNumber The mint cycle number
     * @return endsAt The timestamp when the cycle ends
     */
    function _getCycleEndTime(uint8 cycleNumber) internal view returns (uint32 endsAt) {
        uint32 cycleStartTime = startTimestamp + ((cycleNumber - 1) * GAP_BETWEEN_CYCLE);
        endsAt = cycleStartTime + MINT_CYCLE_DURATION;
    }

    /**
     * @notice Swaps TITANX tokens for Inferno tokens using Uniswap V3.
     * @param amountTitanX The amount of TITANX tokens to swap
     * @param amountInfernoMin The minimum amount of Inferno tokens expected
     * @param _deadline The deadline for the swap
     * @return _infernoAmount The amount of Inferno tokens received
     */
    function _swapTitanXForInferno(uint256 amountTitanX, uint256 amountInfernoMin, uint256 _deadline)
        private
        returns (uint256 _infernoAmount)
    {
        titanX.approve(v3Router, amountTitanX);

        bytes memory path = abi.encodePacked(address(titanX), POOL_FEE, address(inferno));

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: _deadline,
            amountIn: amountTitanX,
            amountOutMinimum: amountInfernoMin
        });

        return ISwapRouter(v3Router).exactInput(params);
    }

    ////////////////////////////////
    ////////// LIQUIDITY ///////////
    ////////////////////////////////

    /**
     * @notice Creates and funds liquidity pools with AlienX, TitanX, and Inferno tokens.
     * @param _deadline The deadline for the liquidity creation transaction
     * @param _amountInfernoMin The minimum amount of Inferno tokens expected
     * @dev This function can only be called once, and only by the contract owner.
     */
    function createAndFundLPs(uint32 _deadline, uint256 _amountInfernoMin) external onlyOwner {
        if (titanX.balanceOf(address(this)) < INITIAL_TITAN_X_ALIENX_LP + INITIAL_TITANX_FOR_INF_ALX_LP + 1) {
            revert NotEnoughBalanceForLp();
        }
        if (addedLiquidity) revert LiquidityAlreadyAdded();

        IUniswapV2Router02 r = IUniswapV2Router02(v2Router);
        address titanXAlienXPool = _createPairIfNeccessary(address(alienX), address(titanX));
        address infAlienXPool = _createPairIfNeccessary(address(alienX), address(inferno));

        {
            alienX.mint(address(this), INITIAL_ALIEN_X_FOR_LP);
            alienX.approve(v2Router, INITIAL_ALIEN_X_FOR_LP);

            (uint256 pairBalance1,) = _checkPoolValidity(titanXAlienXPool);
            if (pairBalance1 > 0) _fixPool(titanXAlienXPool, pairBalance1);

            titanX.approve(address(r), INITIAL_TITAN_X_ALIENX_LP);
            r.addLiquidity(
                address(titanX),
                address(alienX),
                INITIAL_TITAN_X_ALIENX_LP,
                INITIAL_ALIEN_X_FOR_LP,
                0,
                0,
                address(this),
                _deadline
            );
        }

        uint256 _infernoAmount = _swapTitanXForInferno(INITIAL_TITANX_FOR_INF_ALX_LP, _amountInfernoMin, _deadline);
        (uint256 pairBalance,) = _checkPoolValidity(infAlienXPool);

        if (pairBalance > 0) {
            uint256 requiredAlienX;

            if (pairBalance % 2 == 1) {
                inferno.transfer(infAlienXPool, 1);

                requiredAlienX = (pairBalance + 1) / 2;
            } else {
                requiredAlienX = pairBalance / 2;
            }

            alienX.mint(infAlienXPool, requiredAlienX);
            IUniswapV2Pair(infAlienXPool).sync();

            inferno.transfer(infAlienXPool, _infernoAmount - 1);
            alienX.mint(infAlienXPool, INITIAL_ALIEN_X_FOR_LP);

            IUniswapV2Pair(infAlienXPool).mint(address(this));
        } else {
            alienX.mint(address(this), INITIAL_ALIEN_X_FOR_LP);
            inferno.approve(address(r), _infernoAmount);
            alienX.approve(address(r), INITIAL_ALIEN_X_FOR_LP);

            r.addLiquidity(
                address(inferno),
                address(alienX),
                _infernoAmount,
                INITIAL_ALIEN_X_FOR_LP,
                0,
                0,
                address(this),
                _deadline
            );
        }

        addedLiquidity = true;

        alienX.setLp(infAlienXPool, titanXAlienXPool);
    }

    function _checkPoolValidity(address pairAddress) internal returns (uint256, address) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        pair.skim(address(this));
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        if (reserve0 != 0) return (reserve0, pairAddress);
        if (reserve1 != 0) return (reserve1, pairAddress);
        return (0, pairAddress);
    }

    function _fixPool(address pairAddress, uint256 currentBalance) internal {
        uint256 requiredAlienX;

        if (currentBalance % 2 == 1) {
            titanX.transfer(pairAddress, 1);

            requiredAlienX = (currentBalance + 1) / 2;
        } else {
            requiredAlienX = currentBalance / 2;
        }

        alienX.mint(pairAddress, requiredAlienX);
        IUniswapV2Pair(pairAddress).sync();
    }

    function _createPairIfNeccessary(address tokenA, address tokenB) internal returns (address pair) {
        IUniswapV2Factory factory = IUniswapV2Factory(alienX.v2Factory());

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        pair = factory.getPair(token0, token1);

        if (pair == address(0)) pair = factory.createPair(token0, token1);
    }
}
