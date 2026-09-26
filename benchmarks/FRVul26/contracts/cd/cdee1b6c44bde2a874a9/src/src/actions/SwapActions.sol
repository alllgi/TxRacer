// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@const/Constants.sol";
import {Errors} from "@utils/Errors.sol";
import {wmul, min} from "@utils/Math.sol";
import {PoolAddress} from "@libs/PoolAddress.sol";
import {OracleLibrary} from "@libs/OracleLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

/// @notice Struct representing slippage settings for a pool.
struct Slippage {
    uint224 slippage; //< Slippage in WAD (scaled by 1e18)
    uint32 twapLookback; //< TWAP lookback period in minutes (used as seconds in code)
}

struct SwapActionParams {
    address _v3Router;
    address _v3Factory;
    address _owner;
}

/**
 * @title SwapActions
 * @notice A contract that facilitates token swapping on Uniswap V3 with slippage management.
 * @dev Uses Uniswap V3 Router and Oracle libraries for swap actions and TWAP calculations.
 */
contract SwapActions is Ownable2Step, Errors {
    /// @notice Address of the Uniswap V3 Router
    address public immutable uniswapV3Router;

    /// @notice Address of the Uniswap V3 Factory
    address public immutable v3Factory;

    /// @notice Address of the admin responsible for managing slippage
    address public slippageAdmin;

    /// @notice Mapping of pool addresses to their respective slippage settings
    mapping(address pool => Slippage) public slippageConfigs;

    /// @notice Thrown when an invalid slippage is provided
    error SwapActions__InvalidSlippage();

    /// @notice Thrown when a non-admin/non-owner attempts to perform slippage actions
    error SwapActions__OnlySlippageAdmin();

    /// @notice Thrown when an invalid TWA lookback is passed
    error SwapActions__InvalidLookBack();

    event SlippageAdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event SlippageConfigChanged(address indexed pool, uint224 indexed newSlippage, uint32 indexed newLookback);

    /**
     * @dev Ensures the caller is either the slippage admin or the contract owner.
     */
    modifier onlySlippageAdminOrOwner() {
        _onlySlippageAdminOrOwner();
        _;
    }

    /**
     * @param params The aprams to initialize the SwapAcitons contract.
     */
    constructor(SwapActionParams memory params) Ownable(params._owner) {
        uniswapV3Router = params._v3Router;
        v3Factory = params._v3Factory;
        slippageAdmin = params._owner;
    }

    /**
     * @notice Change the address of the slippage admin.
     * @param _new New slippage admin address.
     * @dev Only callable by the contract owner.
     */
    function changeSlippageAdmin(address _new) external notAddress0(_new) onlyOwner {
        emit SlippageAdminChanged(slippageAdmin, _new);

        slippageAdmin = _new;
    }

    /**
     * @notice Change slippage configuration for a specific pool.
     * @param pool Address of the Uniswap V3 pool.
     * @param _newSlippage New slippage value (in WAD).
     * @param _newLookBack New TWAP lookback period (in minutes).
     * @dev Only callable by the slippage admin or the owner.
     */
    function changeSlippageConfig(address pool, uint224 _newSlippage, uint32 _newLookBack)
        external
        notAmount0(_newLookBack)
        onlySlippageAdminOrOwner
    {
        require(_newLookBack <= 20, SwapActions__InvalidLookBack());
        require(_newSlippage <= WAD, SwapActions__InvalidSlippage());

        emit SlippageConfigChanged(pool, _newSlippage, _newLookBack);

        slippageConfigs[pool] = Slippage({slippage: _newSlippage, twapLookback: _newLookBack});
    }

    /**
     * @notice Perform an exact input swap on Uniswap V3.
     * @param tokenIn Address of the input token.
     * @param tokenOut Address of the output token.
     * @param tokenInAmount Amount of the input token to swap.
     * @param minAmountOut Optional minimum amount out, if it's 0 it uses the twap
     * @param deadline Deadline timestamp for the swap.
     * @return amountReceived Amount of the output token received.
     * @dev The function uses the TWAP (Time-Weighted Average Price) to ensure the swap is performed within slippage tolerance.
     */
    function swapExactInput(
        address tokenIn,
        address tokenOut,
        uint256 tokenInAmount,
        uint256 minAmountOut,
        uint32 deadline
    ) internal returns (uint256 amountReceived) {
        IERC20(tokenIn).approve(uniswapV3Router, tokenInAmount);

        bytes memory path = abi.encodePacked(tokenIn, POOL_FEE, tokenOut);

        (uint256 twapAmount, uint224 slippage) = getTwapAmount(tokenIn, tokenOut, tokenInAmount);

        uint256 minAmount = minAmountOut == 0 ? wmul(twapAmount, slippage) : minAmountOut;

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: deadline,
            amountIn: tokenInAmount,
            amountOutMinimum: minAmount
        });

        return ISwapRouter(uniswapV3Router).exactInput(params);
    }

    /**
     * @notice Get the TWAP (Time-Weighted Average Price) and slippage for a given token pair.
     * @param tokenIn Address of the input token.
     * @param tokenOut Address of the output token.
     * @param amount Amount of the input token.
     * @return twapAmount The TWAP amount of the output token for the given input.
     * @return slippage The slippage tolerance for the pool.
     */
    function getTwapAmount(address tokenIn, address tokenOut, uint256 amount)
        public
        view
        returns (uint256 twapAmount, uint224 slippage)
    {
        address poolAddress = PoolAddress.computeAddress(v3Factory, PoolAddress.getPoolKey(tokenIn, tokenOut, POOL_FEE));

        Slippage memory slippageConfig = slippageConfigs[poolAddress];

        if (slippageConfig.twapLookback == 0 && slippageConfig.slippage == 0) {
            slippageConfig = Slippage({twapLookback: 15, slippage: WAD - 0.2e18});
        }

        uint32 secondsAgo = slippageConfig.twapLookback * 60;
        uint32 oldestObservation = OracleLibrary.getOldestObservationSecondsAgo(poolAddress);
        if (oldestObservation < secondsAgo) secondsAgo = oldestObservation;

        (int24 arithmeticMeanTick,) = OracleLibrary.consult(poolAddress, secondsAgo);
        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);

        slippage = slippageConfig.slippage;
        twapAmount = OracleLibrary.getQuoteForSqrtRatioX96(sqrtPriceX96, amount, tokenIn, tokenOut);
    }

    /**
     * @dev Internal function to check if the caller is the slippage admin or contract owner.
     */
    function _onlySlippageAdminOrOwner() private view {
        require(msg.sender == slippageAdmin || msg.sender == owner(), SwapActions__OnlySlippageAdmin());
    }
}
