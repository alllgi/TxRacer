// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// Distribution addresses

address constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;
address constant GENESIS_WALLET = 0xf049064250e164a6C91461ebeC152Ee06e65B821;
address constant FEES_WALLET = 0x9ce5D3B8805d1a5Ab8804e04E9466D5B3807E0D5;
address constant GENESIS_2 = 0x70Fd504b410e651DDAf6aBEa2bdcA74fc48CD255;
address constant VOLT_TREASURY = 0xb638BFB7BC3B8398bee48569CFDAA6B3Bb004224;
address constant OWNER = 0x5da227386E0FD73329FE3923394913ecA3A624f7;

address constant VOLT_LIQUIDTY_BONDING = 0x45C03d66229d01dF2645E813222b16C8B8b86894;
address constant EDEN_LIQUIDITY_BONDING = 0xbC3Aff64285896EB2de2016090874e5D24826195;

// Percentages in WAD
uint64 constant INCENTIVE_FEE = 0.015e18; //1.5%

uint64 constant TO_BURN_TITAN_X = 0.04e18; // 4%
uint64 constant TO_VOLT_LIQUIDITY_BONDING = 0.04e18; // 4%
uint64 constant TO_EDEN_LIQUIDTY_BONDING = 0.08e18; // 8%
uint64 constant TO_EDEN_BUY_AND_BURN = 0.48e18; // 48%
uint64 constant TO_REWARD_POOLS = 0.28e18; // 28%
uint64 constant TO_GENESIS = 0.07e18; // 7%
uint64 constant TO_GENESIS_2 = 0.01e18; // 1%

uint256 constant FOR_VOLT_TREASURY = 0.168e18; // 16.7%

// Reward pools distribution
uint64 constant DAY8POOL_DIST = 0.35e18; // 35%
uint64 constant DAY48POOL_DIST = 0.35e18; // 35%
uint64 constant DAY88POOL_DIST = 0.25e18; // 25%
uint64 constant EDEN_BLOOM_POOL = 0.05e18; // 5%

// ERANK BONUSES
uint64 constant MINING_ERANK_30DAYS = 0.03e18; // 3%
uint64 constant MINING_ERANK_60DAYS = 0.08e18; // 8%
uint64 constant MINING_ERANK_120DAYS = 0.13e18; // 13%
uint64 constant MINING_ERANK_150DAYS = 0.18e18; // 18%

uint64 constant STAKING_ERANK_MINIMUM_BONUS = 0.05e18; // 5%
uint64 constant STAKING_ERANK_MAXIMUM_BONUS = 1e18; // 100%

// PRECISION
uint64 constant WAD = 1e18;

// INTERVALS
uint16 constant INTERVAL_TIME = 8 minutes;
uint8 constant INTERVALS_PER_DAY = uint8(24 hours / INTERVAL_TIME);

//UNIV3
uint24 constant POOL_FEE = 10_000; //1%
int16 constant TICK_SPACING = 200; // Uniswap's tick spacing for 1% pools is 200

//LIQUIDITY CONFIG

///@dev The initial titan x amount needed to create liquidity pool
uint96 constant INITIAL_TITAN_X_FOR_LIQ = 7_250_000_000e18;

///@dev The intial LOTUS that pairs with the VOLT received from the swap
uint96 constant INITIAL_EDEN_FOR_LP = 1_666_667e18;
