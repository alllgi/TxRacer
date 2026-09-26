// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

uint256 constant INCENTIVE_FEE = 150;

address constant TITAN_X_ADDRESS = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1;
address constant BLAZE_ADDRESS = 0xfcd7cceE4071aA4ecFAC1683b7CC0aFeCAF42A36;

address constant GENESIS_WALLET = 0x84C17675a19Be90788CbC7d455B2aeb7Ebf650B4;

address constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;

uint256 constant GENESIS_BPS = 200;
uint256 constant TITAN_X_BURN_BPS = 800;
uint256 constant INFERNO_SELL_TAX_BPS = 500;
uint256 constant BPS_DENOM = 10_000;

/// @dev 28 * 51 = 24 hours
uint256 constant INTERVALS_PER_DAY = 48;
uint32 constant INTERVAL_TIME = 30 minutes;

///@dev  The initial titan x amount needed to create liquidity pool
uint256 constant INITIAL_TITAN_X_FOR_LIQ = 50_000_000_000e18;

///@dev The intial Inferno that pairs with the blaze received from the swap
uint256 constant INITIAL_LP_MINT = 50_000_000_000e18;

/* === UNIV3 === */
address constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
address constant UNISWAP_V3_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

uint24 constant POOL_FEE = 10_000; //1%

int24 constant TICK_SPACING = 200; // Uniswap's tick spacing for 1% pools is 200

/* === UNIV2 === */
address constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address constant UNISWAP_V2_BLAZE_TITAN_X_POOL = 0x4D3A10d4792Dd12ececc5F3034C8e264B28485d1;

/* === SEPOLIAAA ==== */

// address constant UNISWAP_V2_FACTORY = 0x7E0987E5b3a30e3f2828572Bb659A548460a3003;
// address constant UNISWAP_V2_ROUTER = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
// address constant UNISWAP_V2_BLAZE_TITAN_X_POOL = 0x3411Ec705D7358d21249cA633DD37D031014fA1E;

// address constant UNISWAP_V3_ROUTER = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;
// address constant UNISWAP_V3_POSITION_MANAGER = 0x1238536071E1c677A632429e3655c799b22cDA52;

// address constant TITAN_X_ADDRESS = 0xa15eF43BDaF70D5dcfAAFa3b171312931CCC77f8;
// address constant BLAZE_ADDRESS = 0xaA88f021839594260cb02896213DBc969F9b4658;
