// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/* == OZ == */
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/* == UTILS ==  */
import {Errors} from "@utils/Errors.sol";
import {wdiv, wmul, sub, sqrt} from "@utils/Math.sol";

/* == CORE == */
import {VoltAuction} from "@core/VoltAuction.sol";
import {VoltBuyAndBurn} from "@core/VoltBuyAndBurn.sol";
import {TheVolt} from "@core/TheVolt.sol";

/* == CONST == */
import "@const/Constants.sol";

/* == UNIV3 == */
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

/**
 * @title Volt
 * @author Zyntek
 * @dev ERC20 token contract for Volt tokens.
 */
contract Volt is ERC20Burnable, Ownable2Step, Errors {
    address public immutable pool;

    VoltAuction public auction;
    VoltBuyAndBurn public buyAndBurn;
    TheVolt public theVolt;

    error Volt__OnlyAuction();

    modifier onlyAuction() {
        _onlyAuction();
        _;
    }

    constructor(ERC20Burnable _titanX) ERC20("VOLT.WIN", "VOLT") Ownable(msg.sender) {
        _mint(LIQUIDITY_BONDING_ADDR, 50_000_000e18);
        pool = _createUniswapV3Pool(address(_titanX));
    }

    function setVoltAuction(address _voltAuction) external onlyOwner {
        auction = VoltAuction(_voltAuction);
        theVolt = auction.theVolt();
    }

    function setVoltBuyAndBurn(address _voltBuyAndBurn) external onlyOwner {
        buyAndBurn = VoltBuyAndBurn(_voltBuyAndBurn);
    }

    function emitForAuction() external onlyAuction returns (uint256 emitted) {
        emitted = AUCTION_EMIT;

        _mint(address(auction), emitted);
    }

    function emitForLp() external onlyAuction returns (uint256 emitted) {
        emitted = INITIAL_VOLT_FOR_LP;

        _mint(address(auction), emitted);
    }

    function _onlyAuction() internal view {
        if (msg.sender != address(auction)) revert Volt__OnlyAuction();
    }

    function _createUniswapV3Pool(address _titanX) internal returns (address _pool) {
        address _volt = address(this);

        uint256 voltAmount = INITIAL_VOLT_FOR_LP;
        uint256 titanXAmount = INITIAL_TITAN_X_FOR_LIQ;

        (address token0, address token1) = _volt < _titanX ? (_volt, _titanX) : (_titanX, _volt);
        (uint256 amount0, uint256 amount1) = token0 == _volt ? (voltAmount, titanXAmount) : (titanXAmount, voltAmount);

        uint160 sqrtPX96 = uint160((sqrt((amount1 * 1e18) / amount0) * 2 ** 96) / 1e9);

        INonfungiblePositionManager manager = INonfungiblePositionManager(UNISWAP_V3_POSITION_MANAGER);

        _pool = manager.createAndInitializePoolIfNecessary(token0, token1, POOL_FEE, sqrtPX96);

        IUniswapV3Pool(_pool).increaseObservationCardinalityNext(uint16(100));
    }
}
