// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

///@dev  The initial titan x amount needed to create liquidity pool
uint256 constant INITIAL_ALIEN_X_FOR_LP = 2_500_000_000e18;

address constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;
address constant GENESIS_1 = 0x242CaB820Fb2c666F9DD3172fc0a35A57986bABB;
address constant GENESIS_2 = 0x0a71b0F495948C4b3C3b9D0ADa939681BfBEEf30;
address constant INFERNO_BNB_V2 = 0xa793016303Fc4E0b575e3D09173F351e11c801EC;
address constant FLUX_LP = 0x4da2EbDd129AdABc371297e4F651586B3691490B;
address constant ALIENX_LP = 0x1e5a10EE3865B1Cc723178208dD2343A13e0c203;
address constant OWNER = 0x1e5a10EE3865B1Cc723178208dD2343A13e0c203;

///@dev  The initial titan x amount needed to create liquidity pool
uint256 constant INITIAL_TITANX_FOR_INF_ALX_LP = 5_000_000_000e18;
uint256 constant INITIAL_TITAN_X_ALIENX_LP = 5_000_000_000e18;
uint256 constant INITIAL_TITAN_X_SENT_TO_LP = 20_000_000_000e18;

uint24 constant POOL_FEE = 10_000;

// ALLOC
uint64 constant TO_INFERNO_VAULT = 0.28e18; // 28%
uint64 constant TO_ALIENX_BNB = 0.28e18; // 28%
uint64 constant TITAN_X_BURN = 0.2e18; // 20%
uint64 constant TO_INFERNO_BNB = 0.08e18; //8%
uint64 constant TO_FLUX_LP = 0.04e18; //4%
uint64 constant TO_FLUX_BNB = 0.04e18; // 4%
uint64 constant TO_ALIEN_X_LP = 0.02e18; //2%
uint64 constant TO_GENESIS_1 = 0.02e18; // 2%
uint64 constant TO_GENESIS_2 = 0.04e18; // 4%

uint64 constant INFERNO_VAULT_DAILY_ALLOCATION = 0.0088e18;

uint64 constant INCENTIVE = 0.03e18;

uint32 constant INTERVAL_TIME = 8 minutes;

uint8 constant INTERVALS_PER_DAY = uint8(24 hours / INTERVAL_TIME);

uint64 constant BUY_SELL_TAX = 0.0104e18; // 1.04%

int16 constant TICK_SPACING = 200;
