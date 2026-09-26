// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Transfer {


    struct OldSingleQuote {
        bool useOldAmount;
        uint256 makerAmount;
        uint256 makerNonce;
    }

    struct OldMultiQuote {
        bool useOldAmount;
        uint256[] makerAmounts;
        uint256 makerNonce;
    }

    struct OldAggregateQuote {
        bool useOldAmount;
        uint256[][] makerAmounts;
        uint256[] makerNonces;
    }


    //-----------------------------------------
    //      Internal Helper Data Structures
    // -----------------------------------------

    enum Action {
        None,
        Wrap,
        Unwrap
    }

    struct Pending {
        address token;
        address to;
        uint256 amount;
    }

    struct NativeTokens {
        uint256 toTaker;  // accumulated amount of tokens that will be sent to the taker (receiver)
        uint256 toMakers; // accumulated amount of tokens that will be sent to the makers
    }

    struct LengthsInfo {
        uint48 pendingTransfersLen; // length of `pendingTransfers` array
        uint48 permit2Len; // length of `batchTransferDetails` array
    }

    struct IndicesInfo {
        uint48 pendingTransfersInd;
        uint48 permit2Ind;
        uint256 commandsInd;
    }
}
