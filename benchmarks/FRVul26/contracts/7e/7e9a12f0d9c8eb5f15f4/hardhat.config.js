module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "lib/aave-v3-core/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0xbc6d76108729be0e85938845b74c2f8ab88b7ea6"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0x202f310828467bb04680a8fe879a7d1814677a24"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x39fb3e784012eb3e650bf79b6909d857e0a49f0c"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0x7f3e0bbf4aaee28abc2cfbd571fc2b983662ad52"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x666835b336a3a5198b2895d94109131d1b23ad11"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0x111b4b22ee7ea68703d8e54ea49aa1bb0d158128"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0x6d0bc1defe4379d9cb86bcd8d7c005413ab0e8fb"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0x66ac02c3120b848d65231ce977af3db1f60b97f9"
            }
      },
      "optimizer": {
            "runs": 100000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":@aave/core-v3/=lib/aave-v3-core/",
            ":@uniswap/v3-core/=lib/v3-core/",
            ":aave-v3-core/=lib/aave-v3-core/",
            ":aave-v3-periphery/=lib/aave-v3-periphery/contracts/",
            ":ds-test/=lib/dss-direct-deposit/lib/dss-test/lib/forge-std/lib/ds-test/src/",
            ":dss-direct-deposit/=lib/dss-direct-deposit/",
            ":dss-interfaces/=lib/dss-direct-deposit/lib/dss-test/lib/dss-interfaces/src/",
            ":dss-test/=lib/dss-direct-deposit/lib/dss-test/src/",
            ":forge-std/=lib/dss-direct-deposit/lib/dss-test/lib/forge-std/src/",
            ":v3-core/=lib/v3-core/",
            ":v3-periphery/=lib/v3-periphery/contracts/"
      ]
}
  }
};
