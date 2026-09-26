// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

interface IDataStoreResponse {
    struct DataStoreAddressResponse {
        address locker;
        address payable proofWallet;
        address payable proofStaking;
        address proofPassNFT;
        address router;
    }

    struct DataStoreLimitsResponse {
        uint initMaxTx;
        uint swapTokensAtAmount;
        uint maxTxUpper;
        uint maxTxLower;
        uint maxWalletUpper;
        uint maxWalletLower;
        uint maxBuyFee;
        uint maxSellFee;
        uint denominator;
    }
}

interface IDataStore is IDataStoreResponse {
    function getAddresses(string[] memory addrKeys) external view returns (address[] memory);
    function getUints(string[] memory uintKeys) external view returns (uint256[] memory);
    function getPlatformAddresses() external view returns (DataStoreAddressResponse memory);
    function getLimits() external view returns (DataStoreLimitsResponse memory);
}