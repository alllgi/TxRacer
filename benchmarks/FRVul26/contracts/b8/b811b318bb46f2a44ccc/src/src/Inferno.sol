// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/* === OZ === */
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/* = SYSTEM */
import {InfernoMinting} from "./InfernoMinting.sol";
import {InfernoBuyAndBurn} from "./InfernoBuyAndBurn.sol";

/* = LIBS =  */
import {FullMath} from "@uniswap/v3-core/contracts/libraries/FullMath.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/* = UNIV3 = */
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

/* = UNIV2 = */

import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import "../src/const/BuyAndBurnConst.sol";

/**
 * @title Inferno
 * @author 0xkmmm
 * @dev ERC20 token contract for INFERNO tokens.
 * @notice It can be minted by InfernoMinting during cycles
 * @notice It can be minted by InfernoBuyAndBurn when forming an LP
 */
contract Inferno is ERC20Burnable {
    using FullMath for uint256;

    /* ==== IMMUTABLES ==== */

    InfernoMinting public immutable minting;
    InfernoBuyAndBurn public immutable buyAndBurn;
    address public immutable blazeInfernoPool;

    /* ==== ERRORS ==== */

    error OnlyMinting();
    error OnlyBuyAndBurn();
    error InvalidInput();

    /* ==== CONSTRUCTOR ==== */

    /**
     * @dev Sets the minting and buy and burn contract address.
     * @param _infernoMintingStartTimestamp The start of the first mint cycle
     * @param _infernoBuyAndBurnStartTimestamp The start of the buy and burn contract
     * @param _blazeTitanXPool The BLAZE/TITANX UniswapV2 pool
     * @param _titanX The titanX token
     * @param _blaze The blaze token
     * @param _owner The owner of the buyAndBurn
     * @notice Constructor is payable to save gas
     */
    constructor(
        uint32 _infernoMintingStartTimestamp,
        uint32 _infernoBuyAndBurnStartTimestamp,
        address _blazeTitanXPool,
        address _titanX,
        address _blaze,
        address _owner
    ) payable ERC20("INFERNO", "INF") {
        blazeInfernoPool = _createBlazeInfernoPool(_blaze, _titanX, _blazeTitanXPool);

        buyAndBurn = new InfernoBuyAndBurn(_infernoBuyAndBurnStartTimestamp, _blazeTitanXPool, _titanX, _blaze, _owner);
        minting = new InfernoMinting(address(buyAndBurn), _titanX, _infernoMintingStartTimestamp);
    }

    /* == MODIFIERS == */

    /// @dev Modifier to ensure the function is called only by the minter contract.
    modifier onlyMinting() {
        _onlyMinting();
        _;
    }

    /// @dev Modifier to ensure the function is called only by the buy and burn contract.
    modifier onlyBuyAndBurn() {
        _onlyBuyAndBurn();
        _;
    }

    /* == EXTERNAL == */

    /**
     * @notice Mints INFERNO tokens to a specified address.
     * @notice This is only callable by the InfernoMinting contract
     * @param _to The address to mint the tokens to.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _to, uint256 _amount) external onlyMinting {
        _mint(_to, _amount);
    }

    /// @notice Mints inferno tokens for the initial LP creation
    function mintTokensForLP() external onlyBuyAndBurn {
        _mint(address(buyAndBurn), INITIAL_LP_MINT);
    }

    /* == INTERNAL == */

    /// @dev Private method is used instead of inlining into modifier because modifiers are copied into each method,
    ///     and the use of immutable means the address bytes are copied in every place the modifier is used.
    function _onlyBuyAndBurn() internal view {
        if (msg.sender != address(buyAndBurn)) revert OnlyBuyAndBurn();
    }

    /// @dev Private method is used instead of inlining into modifier because modifiers are copied into each method,
    ///     and the use of immutable means the address bytes are copied in every place the modifier is used.
    function _onlyMinting() internal view {
        if (msg.sender != address(minting)) revert OnlyMinting();
    }

    ///@notice - Creates the BLAZE/INFERNO Pool on uniswapV3
    ///@notice - Only called inside of the constructor and never again
    function _createBlazeInfernoPool(address _blaze, address _titanX, address _blazeTitanXPool)
        internal
        returns (address pool)
    {
        address _inferno = address(this);

        (uint112 res0, uint112 res1,) = IUniswapV2Pair(_blazeTitanXPool).getReserves();
        address token0V2 = IUniswapV2Pair(_blazeTitanXPool).token0();

        (uint112 resIn, uint112 resOut) = token0V2 == _titanX ? (res0, res1) : (res1, res0);

        uint256 blazeAmount = IUniswapV2Router02(UNISWAP_V2_ROUTER).getAmountOut(INITIAL_TITAN_X_FOR_LIQ, resIn, resOut);
        uint256 infernoAmount = INITIAL_LP_MINT;

        (address token0, address token1) = _blaze < _inferno ? (_blaze, _inferno) : (_inferno, _blaze);

        (uint256 amount0, uint256 amount1) =
            token0 == _blaze ? (blazeAmount, infernoAmount) : (infernoAmount, blazeAmount);

        uint160 sqrtPriceX96 = uint160((Math.sqrt((amount1 * 1e18) / amount0) * 2 ** 96) / 1e9);

        INonfungiblePositionManager manager = INonfungiblePositionManager(UNISWAP_V3_POSITION_MANAGER);

        pool = manager.createAndInitializePoolIfNecessary(token0, token1, POOL_FEE, sqrtPriceX96);

        IUniswapV3Pool(pool).increaseObservationCardinalityNext(uint16(100));
    }
}
