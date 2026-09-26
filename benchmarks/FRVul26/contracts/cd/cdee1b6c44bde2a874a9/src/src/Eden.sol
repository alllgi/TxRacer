// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@const/Constants.sol";
import {sqrt} from "@utils/Math.sol";
import {EdenStaking} from "./Staking.sol";
import {EdenMigrator} from "./Migrator.sol";
import {EdenBuyAndBurn} from "./BuyAndBurn.sol";
import {EdenMining, MiningStats} from "./Mining.sol";
import {OracleLibrary} from "@libs/OracleLibrary.sol";
import {SwapActionParams} from "./actions/SwapActions.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IQuoter} from "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import {PoolAddress} from "@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

/**
 * @title Eden
 * @dev ERC20 token contract for Eden tokens.
 */
contract Eden is ERC20Burnable, Ownable2Step {
    address public immutable pool;
    EdenMining public mining;
    EdenStaking public staking;
    EdenBuyAndBurn public buyAndBurn;
    EdenMigrator public migrator;

    error Eden__OnlyMining();
    error Eden__OnlyMigrator();

    constructor(address _v3PositionManager, address _titanX, address _volt, address _v3Quoter)
        ERC20("EDEN", "EDEN")
        Ownable(msg.sender)
    {
        _mint(EDEN_LIQUIDITY_BONDING, 33_333_340e18);
        pool = _createUniswapV3Pool(_titanX, _volt, _v3Quoter, _v3PositionManager);
    }

    //=======MODIFIERS=========//

    modifier onlyMining() {
        _onlyMining();
        _;
    }

    modifier onlyMigrator() {
        _onlyMigrator();
        _;
    }

    function setBnB(EdenBuyAndBurn _bnb) external onlyOwner {
        buyAndBurn = _bnb;
    }

    function setMigrator(EdenMigrator _migrator) external onlyOwner {
        migrator = _migrator;
    }

    function setStaking(EdenStaking _staking) external onlyOwner {
        staking = _staking;
    }

    function setMining(EdenMining _mining) external onlyOwner {
        mining = _mining;
    }

    function emitEden(address _receiver, uint256 _amount) external onlyMining {
        _mint(_receiver, _amount);
    }

    function migrate(address _receiver, uint256 _amount) external onlyMigrator {
        _mint(_receiver, _amount);
    }

    function _createUniswapV3Pool(
        address _titanX,
        address _volt,
        address UNISWAP_V3_QUOTER,
        address UNISWAP_V3_POSITION_MANAGER
    ) internal returns (address _pool) {
        address _eden = address(this);

        IQuoter quoter = IQuoter(UNISWAP_V3_QUOTER);

        bytes memory path = abi.encodePacked(address(_titanX), POOL_FEE, address(_volt));

        uint256 voltAmount = quoter.quoteExactInput(path, INITIAL_TITAN_X_FOR_LIQ);

        uint256 edenAmount = INITIAL_EDEN_FOR_LP;

        (address token0, address token1) = _eden < _volt ? (_eden, _volt) : (_volt, _eden);

        (uint256 amount0, uint256 amount1) = token0 == _volt ? (voltAmount, edenAmount) : (edenAmount, voltAmount);

        uint160 sqrtPX96 = uint160((sqrt((amount1 * 1e18) / amount0) * 2 ** 96) / 1e9);

        INonfungiblePositionManager manager = INonfungiblePositionManager(UNISWAP_V3_POSITION_MANAGER);

        _pool = manager.createAndInitializePoolIfNecessary(token0, token1, POOL_FEE, sqrtPX96);

        IUniswapV3Pool(_pool).increaseObservationCardinalityNext(uint16(100));
    }

    function _onlyMining() internal view {
        require(msg.sender == address(mining), Eden__OnlyMining());
    }

    function _onlyMigrator() internal view {
        require(msg.sender == address(migrator), Eden__OnlyMining());
    }
}
