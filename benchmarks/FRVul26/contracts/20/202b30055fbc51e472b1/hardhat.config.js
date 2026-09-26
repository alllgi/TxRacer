module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "lib/aave-v3-core/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0xd5256981e08492afc543af2a779af989e9f9f7e7"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0xeabd65827e91ac3ae5471c11a329fbc675ca46d6"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x5d834ead0a80cf3b88c06feed6e8e0fcae2daee5"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0x57572c9e795f4b6a748efbeab7e0a1b9996a0a24"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x39df4b1329d41a9ae20e17beff39aabd2f049128"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0x0a62276bfbf1ad8443f37da8630d407408085c8b"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0xe175de51f29d822b86e46a9a61246ec90631210d"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0x7406aba1aa5fe5cd71d958ce10fc28c416a33aa0"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":@aave/core-v3/=lib/aave-v3-core/",
            ":@aave/periphery-v3/=lib/aave-v3-periphery/",
            ":aave-address-book/=lib/aave-address-book/src/",
            ":aave-helpers/=lib/aave-helpers/src/",
            ":aave-v3-core/=lib/aave-v3-core/",
            ":aave-v3-periphery/=lib/aave-v3-periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":solidity-utils/=lib/aave-helpers/lib/solidity-utils/src/"
      ]
}
  }
};
