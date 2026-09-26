// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {IDragonX} from "@interfaces/IDragonX.sol";

// Token addresses
ERC20Burnable constant TITAN_X = ERC20Burnable(0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1);

// Distribution addresses
address constant GENESIS_WALLET = 0xBeb2363cA0A7A9FEB75D88aC27A46Fc8bB75Eb6C;
address constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;
address constant OWNER = 0xeC0Db0059F749d2a97B216ffd65270E80Db46383;
address constant LIQUIDITY_BONDING_ADDR = 0x45C03d66229d01dF2645E813222b16C8B8b86894;

IDragonX constant DRAGON_X = IDragonX(0x96a5399D07896f757Bd4c6eF56461F58DB951862); // verified

// Percentages in basis points
uint64 constant INCENTIVE_FEE = 0.015e18; //1.5%

uint64 constant BUYANDBURN = 0.8e18; // 80%
uint64 constant TITAN_X_DRAGON_X = 0.04e18; // 4%
uint64 constant LIQUIDITY_BONDING = 0.08e18; // 8%
uint64 constant GENESIS = 0.08e18; // 8%

uint64 constant DISTRIBUTION_FROM_THE_VOLT = 0.2e18; // 20%
uint64 constant WAD = 1e18;

/// @dev 96 * 15 = 24 hours
uint16 constant INTERVAL_TIME = 5 minutes;
uint16 constant INTERVALS_PER_DAY = uint16(24 hours / INTERVAL_TIME);

uint24 constant POOL_FEE = 10_000; //1%
int16 constant TICK_SPACING = 200; // Uniswap's tick spacing for 1% pools is 200

///@dev The initial titan x amount needed to create liquidity pool
uint96 constant INITIAL_TITAN_X_FOR_LIQ = 7_500_000_000e18;

uint96 constant AUCTION_EMIT = 100_000_000e18;

///@dev The intial Volt that pairs with the initial TitanX
uint96 constant INITIAL_VOLT_FOR_LP = 5_000_000e18;

/* === UNIV3 === */
address constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
address constant UNISWAP_V3_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
address constant UNISWAP_V3_QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;

/* === SEPOLIA ==== */

// address constant UNISWAP_V3_ROUTER = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;
// address constant UNISWAP_V3_POSITION_MANAGER = 0x1238536071E1c677A632429e3655c799b22cDA52;
// address constant UNISWAP_V3_QUOTER = 0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3;
