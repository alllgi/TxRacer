// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/* == OZ == */
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/* == CORE == */
import {Volt} from "@core/Volt.sol";
import {TheVolt} from "@core/TheVolt.sol";

/* == UTILS == */
import {Time} from "@utils/Time.sol";
import {Errors} from "@utils/Errors.sol";

import {wdiv, wmul, sub, sqrt} from "@utils/Math.sol";

/* == CONST == */
import "@const/Constants.sol";

/* == UNIV3 == */
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

/* == INTERFACES == */
import {IVolt, IVoltBuyAndBurn} from "@interfaces/IVolt.sol";

struct LP {
    bool hasLP;
    bool isVoltToken0;
    uint240 tokenId;
}

struct DailyStatistic {
    uint128 voltEmitted;
    uint128 titanXDeposited;
}

/**
 * @title VoltAuction
 * @author Zyntek
 * @dev Contract to auction TitanX to earn a proportional amount of 100M Volt.
 */
contract VoltAuction is Ownable, Errors {
    using SafeERC20 for ERC20Burnable;
    using SafeERC20 for IVolt;

    //========IMMUTABLE=========//

    IVolt immutable volt;
    ERC20Burnable public immutable titanX;
    IDragonX public immutable dragonX;
    uint32 public immutable startTimestamp;

    //=========STORAGE==========//

    LP public lp;
    TheVolt public immutable theVolt;

    uint128 lpSlippage = WAD - 0.2e18;

    mapping(address => mapping(uint32 day => uint256 amount)) public depositOf;
    mapping(uint32 day => DailyStatistic) public dailyStats;

    //==========ERRORS==========//

    error VoltAuction__OnlyClaimableTheNextDay();
    error VoltAuction__LiquidityAlreadyAdded();
    error VoltAuction__NotStartedYet();
    error VoltAuction__NothingToClaim();
    error VoltAuction__InvalidSlippage();
    error VoltAuction__NotEnoughTitanXForLiquidity();
    error VoltAuction__TreasuryVoltIsEmpty();
    error MustStartAt2PMUTC();

    //=========EVENTS==========//

    event UserDeposit(address indexed user, uint256 indexed amount, uint32 indexed day);
    event UserClaimed(address indexed user, uint256 indexed voltAmount, uint32 indexed day);

    //=======CONSTRUCTOR========//

    constructor(uint32 _startTimestamp, address _volt, ERC20Burnable _titanX, address _owner, address _dragonX)
        notAddress0(_volt)
        notAddress0(address(_titanX))
        notAddress0(_owner)
        notAddress0(_dragonX)
        Ownable(_owner)
    {
        if ((_startTimestamp - 14 hours) % 1 days != 0) revert MustStartAt2PMUTC();

        volt = IVolt(_volt);
        titanX = _titanX;
        dragonX = IDragonX(_dragonX);

        theVolt = new TheVolt(address(this), address(volt));

        startTimestamp = _startTimestamp;
    }

    //==========================//
    //=====EXTERNAL/PUBLIC======//
    //==========================//

    function changeLPSlippage(uint128 _newSlippage) external onlyOwner notAmount0(_newSlippage) {
        if (_newSlippage > WAD) revert VoltAuction__InvalidSlippage();
        lpSlippage = _newSlippage;
    }

    function deposit(uint192 _amount) external notAmount0(_amount) {
        if (startTimestamp > Time.blockTs()) revert VoltAuction__NotStartedYet();

        _updateAuction();

        uint32 daySinceStart = Time.daysSince(startTimestamp) + 1;

        DailyStatistic storage stats = dailyStats[daySinceStart];

        titanX.safeTransferFrom(msg.sender, address(this), _amount);

        _distribute(_amount);

        depositOf[msg.sender][daySinceStart] += _amount;

        stats.titanXDeposited += uint128(_amount);

        emit UserDeposit(msg.sender, _amount, daySinceStart);
    }

    function claim(uint32 _day) public {
        uint32 daySinceStart = Time.daysSince(startTimestamp) + 1;
        if (_day == daySinceStart) revert VoltAuction__OnlyClaimableTheNextDay();

        uint256 toClaim = amountToClaim(msg.sender, _day);

        if (toClaim == 0) revert VoltAuction__NothingToClaim();

        emit UserClaimed(msg.sender, toClaim, _day);

        volt.safeTransfer(msg.sender, toClaim);

        depositOf[msg.sender][_day] = 0;
    }

    function batchClaim(uint32[] calldata _days) external {
        for (uint256 i; i < _days.length; ++i) {
            claim(_days[i]);
        }
    }

    function batchClaimableAmount(address _user, uint32[] calldata _days) public view returns (uint256 toClaim) {
        for (uint256 i; i < _days.length; ++i) {
            toClaim += amountToClaim(_user, _days[i]);
        }
    }

    function amountToClaim(address _user, uint32 _day) public view returns (uint256 toClaim) {
        uint256 depositAmount = depositOf[_user][_day];
        DailyStatistic memory stats = dailyStats[_day];

        return (depositAmount * stats.voltEmitted) / stats.titanXDeposited;
    }

    /**
     * @notice Creates a Uniswap V3 pool and adds liquidity
     * @param _deadline The deadline for the liquidity addition
     */
    function addLiquidityToVoltTitanxPool(uint32 _deadline) external onlyOwner notExpired(_deadline) {
        if (lp.hasLP) revert VoltAuction__LiquidityAlreadyAdded();

        if (titanX.balanceOf(address(this)) < INITIAL_TITAN_X_FOR_LIQ) {
            revert VoltAuction__NotEnoughTitanXForLiquidity();
        }

        volt.emitForLp();

        (uint256 amount0, uint256 amount1, uint256 amount0Min, uint256 amount1Min, address token0, address token1) =
            _sortAmounts(INITIAL_TITAN_X_FOR_LIQ, INITIAL_VOLT_FOR_LP);

        ERC20Burnable(token0).approve(UNISWAP_V3_POSITION_MANAGER, amount0);
        ERC20Burnable(token1).approve(UNISWAP_V3_POSITION_MANAGER, amount1);

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
        (uint256 tokenId,,,) = INonfungiblePositionManager(UNISWAP_V3_POSITION_MANAGER).mint(params);

        bool isVoltToken0 = token0 == address(volt);

        lp = LP({hasLP: true, tokenId: uint240(tokenId), isVoltToken0: isVoltToken0});

        _transferOwnership(address(0));
    }

    /**
     * @notice Sends the fees acquired from the UniswapV3 position and sends them for liqudity bonding
     * @return amount0 The amount of token0 collected
     * @return amount1 The amount of token1 collected
     */
    function collectFees() external returns (uint256 amount0, uint256 amount1) {
        LP memory _lp = lp;

        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: _lp.tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = INonfungiblePositionManager(UNISWAP_V3_POSITION_MANAGER).collect(params);

        (uint256 voltAmount, uint256 titanXAmount) = _lp.isVoltToken0 ? (amount0, amount1) : (amount1, amount0);

        titanX.transfer(LIQUIDITY_BONDING_ADDR, titanXAmount);
        volt.transfer(LIQUIDITY_BONDING_ADDR, voltAmount);
    }

    //==========================//
    //=========INTERNAL=========//
    //==========================//

    ///@notice - Distributes the tokens
    function _distribute(uint256 _amount) internal {
        uint256 titanXBalance = titanX.balanceOf(address(this));
        //@note - If there is no added liquidity, but the balance exceeds the initial for liquidity, we should distribute the difference
        if (!lp.hasLP) {
            if (titanXBalance <= INITIAL_TITAN_X_FOR_LIQ) return;

            _amount = uint192(titanXBalance - INITIAL_TITAN_X_FOR_LIQ);
        }

        uint256 toBnB = wmul(_amount, BUYANDBURN);
        uint256 toDragonX = wmul(_amount, TITAN_X_DRAGON_X);
        uint256 forLiquidityBonding = wmul(_amount, LIQUIDITY_BONDING);
        uint256 toGenesis = wmul(_amount, GENESIS);

        titanX.safeTransfer(GENESIS_WALLET, toGenesis);
        titanX.safeTransfer(LIQUIDITY_BONDING_ADDR, forLiquidityBonding);

        titanX.safeTransfer(address(dragonX), toDragonX);
        dragonX.updateVault();

        IVoltBuyAndBurn bnb = volt.buyAndBurn();

        titanX.approve(address(bnb), toBnB);
        bnb.distributeTitanXForBurning(toBnB);
    }

    ///@notice Emits the needed VOLT
    function _updateAuction() internal {
        uint32 daySinceStart = Time.daysSince(startTimestamp) + 1;

        if (dailyStats[daySinceStart].voltEmitted != 0) return;

        if (daySinceStart > 10 && volt.balanceOf(address(theVolt)) == 0) revert VoltAuction__TreasuryVoltIsEmpty();

        uint256 emitted = daySinceStart <= 10 ? volt.emitForAuction() : theVolt.emitForAuction();

        dailyStats[daySinceStart].voltEmitted = uint128(emitted);
    }

    ///@notice Sorts tokens and amounts for adding liquidity
    function _sortAmounts(uint256 _titanXAmount, uint256 _voltAmount)
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
        address _volt = address(volt);
        address _titanX = address(titanX);

        (token0, token1) = _volt < _titanX ? (_volt, _titanX) : (_titanX, _volt);
        (amount0, amount1) = token0 == _volt ? (_voltAmount, _titanXAmount) : (_titanXAmount, _voltAmount);

        (amount0Min, amount1Min) = (wmul(amount0, lpSlippage), wmul(amount1, lpSlippage));
    }
}
