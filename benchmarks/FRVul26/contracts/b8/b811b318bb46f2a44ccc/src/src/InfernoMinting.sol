// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/* === OZ === */
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/* === SYSTEM === */
import {InfernoBuyAndBurn} from "./InfernoBuyAndBurn.sol";
import {Inferno} from "./Inferno.sol";

/* === CONST === */
import "./const/BuyAndBurnConst.sol";

/**
 * @title InfernoMinting
 * @author 0xkmmm
 * @dev This contract allows users to mint Inferno tokens by depositing TITANX tokens during specific minting cycles.
 */
contract InfernoMinting {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /* == CONSTANTS ==  */

    ///@notice  The duration of 1 mint cycle
    uint32 public constant MINT_CYCLE_DURATION = 24 hours;

    ///@notice The starting ratio of the first mint cycle
    uint256 constant STARTING_RATIO = 1e18;

    ///@notice The gap between mint cycles
    uint32 public constant GAP_BETWEEN_CYCLE = 1 weeks;

    ///@notice  The final mint cycle
    uint8 public constant MAX_MINT_CYCLE = 8;

    /* == IMMUTABLES == */

    ///@notice The titanX token
    IERC20 public immutable titanX;

    uint256 public totalTitanXDeposited;
    uint256 public totalInfernoClaimed;
    uint256 public totalInfernoMinted;

    ///@notice The buy and burn contract
    InfernoBuyAndBurn public immutable buyAndBurn;

    uint32 public immutable startTimestamp;

    /* == STATE == */

    ///@notice  Inferno token
    Inferno public inferno;

    ///@notice The start of the first minting cycle

    ///@notice Mapping of the users amount to claim in a mint cycle
    mapping(address user => mapping(uint32 cycleId => uint256 amount)) public amountToClaim;

    /* == ERRORS == */

    error InvalidInput();
    error CycleStillOngoing();
    error NotStartedYet();
    error CycleIsOver();
    error NoInfernoToClaim();
    error InvalidStartTime();

    /* == EVENTS === */

    ///@notice Emits when user mints for a cycle
    event MintExecuted(address indexed user, uint256 infernoAmount, uint32 indexed mintCycleId);

    ///@notice Emits when user claims for a cycle
    event ClaimExecuted(address indexed user, uint256 infernoAmount, uint8 indexed mintCycleId);

    /* == CONSTRUCTOR == */

    /**
     * @dev Sets the addresses for the TITANX and Inferno tokens.
     * @param _buyAndBurn Address of the buy and burn contract
     * @param _titanX Adress of the TitanX token
     * @param _startTimestamp The time stamp of the first minting cycle
     * @notice Constructor is payable to save gas
     */
    constructor(address _buyAndBurn, address _titanX, uint32 _startTimestamp) payable {
        if (_buyAndBurn == address(0)) revert InvalidInput();

        // bool is2PmUTC = (_startTimestamp % 1 days) == 14 hours;
        // bool isFriday = ((block.timestamp / 1 days + 4) % 7) == 5;

        // if (!is2PmUTC || !isFriday) revert InvalidStartTime();

        startTimestamp = _startTimestamp;
        inferno = Inferno(msg.sender);
        titanX = IERC20(_titanX);
        buyAndBurn = InfernoBuyAndBurn(_buyAndBurn);
    }

    /* == EXTERNAL == */

    function getRatioForCycle(uint32 cycleId) public pure returns (uint256 ratio) {
        unchecked {
            uint256 adjustedRatioDiscount = cycleId == 1 ? 0 : uint256(cycleId - 1) * 5e16;
            ratio = STARTING_RATIO - adjustedRatioDiscount;
        }
    }

    /**
     * @notice Mints Inferno tokens by depositing TITANX tokens during an ongoing mint cycle.
     * @param _amount The amount of TITANX tokens to deposit.
     */
    function mint(uint256 _amount) external {
        if (_amount == 0) revert InvalidInput();

        if (block.timestamp < startTimestamp) revert NotStartedYet();

        (uint32 currentCycle,, uint32 endsAt) = getCurrentMintCycle();

        if (block.timestamp > endsAt) revert CycleIsOver();

        uint256 adjustedAmount = _burnAndSendToGenesis(_amount);
        uint256 infernoAmount = (_amount * getRatioForCycle(currentCycle)) / 1e18;

        amountToClaim[msg.sender][currentCycle] += infernoAmount;

        emit MintExecuted(msg.sender, infernoAmount, currentCycle);

        totalInfernoMinted = totalInfernoMinted + infernoAmount;
        totalTitanXDeposited = totalTitanXDeposited + _amount;

        _distributeToBuyAndBurn(adjustedAmount);
    }

    /**
     * @notice Claims the minted Inferno tokens after the end of the specified mint cycle.
     * @param _cycleId The ID of the mint cycle to claim tokens from.
     */
    function claim(uint8 _cycleId) external {
        if (_getCycleEndTime(_cycleId) > block.timestamp) revert CycleStillOngoing();

        uint256 toClaim = amountToClaim[msg.sender][_cycleId];

        if (toClaim == 0) revert NoInfernoToClaim();

        delete amountToClaim[msg.sender][_cycleId];

        emit ClaimExecuted(msg.sender, toClaim, _cycleId);

        totalInfernoClaimed = totalInfernoClaimed + toClaim;

        inferno.mint(msg.sender, toClaim);
    }

    /* == INTERNAL/PRIVATE == */

    function _burnAndSendToGenesis(uint256 _amount) internal returns (uint256 newAmount) {
        if (!buyAndBurn.liquidityAdded()) return _amount;

        unchecked {
            uint256 titanXForGenesis = _amount.mulDiv(GENESIS_BPS, BPS_DENOM, Math.Rounding.Ceil);
            uint256 titanXToBurn = _amount.mulDiv(TITAN_X_BURN_BPS, BPS_DENOM, Math.Rounding.Ceil);

            newAmount = _amount - titanXForGenesis - titanXToBurn;

            titanX.safeTransferFrom(msg.sender, DEAD_ADDR, titanXToBurn);
            titanX.safeTransferFrom(msg.sender, GENESIS_WALLET, titanXForGenesis);
        }
    }

    function _distributeToBuyAndBurn(uint256 _amount) internal {
        titanX.safeTransferFrom(msg.sender, address(this), _amount);
        titanX.approve(address(buyAndBurn), _amount);

        buyAndBurn.distributeTitanXForBurning(_amount);
    }

    function getCurrentMintCycle() public view returns (uint32 currentCycle, uint32 startsAt, uint32 endsAt) {
        uint32 timeElapsedSince = uint32(block.timestamp - startTimestamp);

        currentCycle = uint8(timeElapsedSince / GAP_BETWEEN_CYCLE) + 1;

        if (currentCycle > MAX_MINT_CYCLE) currentCycle = MAX_MINT_CYCLE;

        startsAt = startTimestamp + ((currentCycle - 1) * GAP_BETWEEN_CYCLE);

        endsAt = startsAt + MINT_CYCLE_DURATION;
    }

    function _getCycleEndTime(uint8 cycleNumber) internal view returns (uint32 endsAt) {
        uint32 cycleStartTime = startTimestamp + ((cycleNumber - 1) * GAP_BETWEEN_CYCLE);

        endsAt = cycleStartTime + MINT_CYCLE_DURATION;
    }
}
