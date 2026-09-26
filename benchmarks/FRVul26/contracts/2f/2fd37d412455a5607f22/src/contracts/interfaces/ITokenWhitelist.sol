// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

import "./IDataStore.sol";

interface ITokenWhitelist is IDataStoreResponse {
    
    struct TokenInfo {
        string name;
        string symbol;
        address owner;
        address mainWallet;
        address secondaryWallet;
        uint256 totalSupply;
        uint256 percentToLP;
        uint256 lpLockDuration;
        uint256 initMaxWallet;
        FeeInfo buyFees;
        FeeInfo sellFees;
        address[] whitelist;
        uint256 whitelistDuration;
        address rewardToken;
    }

    struct FeeInfo {
        uint256 main;
        uint256 secondary;
        uint256 liquidity;
        uint256 proof;
        uint256 total;
    }

    error ExceedsMaxTxAmount();
    error ExceedsMaxWalletAmount();
    error InvalidConfiguration();
    error TradingNotEnabled();
    error NotWhitelisted();

}