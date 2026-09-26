module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0x7b8186933ead860f49114fb10e3a7f17a11bed8a"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0xb341e4f99c73caa2136302f468ac3b75827c1736"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x5547d7d54d10c359108e36d098016c4020443fd4"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0xd948cfb92ebf175e4bd772305fdee8f39e934520"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x589f82ff8162fa96545b435435713e9d6ca79fbb"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0x0063bcd116694c21f6a94aa78e10ef4d7819a609"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0x5125bcf6380c5d5ccad4d4a88c3664df646bc6c3"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0x433c792f11d102249dccd55452ddd84c7a2ef8f2"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@aave/core-v2/=lib/aave-v3-factory/lib/aave-collector-unification/lib/protocol-v2/",
            ":@aave/core-v3/=lib/aave-v3-factory/lib/aave-address-book/lib/aave-v3-core/",
            ":@aave/periphery-v3/=lib/aave-v3-factory/lib/aave-address-book/lib/aave-v3-periphery/",
            ":aave-address-book/=lib/aave-helpers/lib/aave-address-book/src/",
            ":aave-collector-unification/=lib/aave-v3-factory/lib/aave-collector-unification/",
            ":aave-helpers/=lib/aave-helpers/src/",
            ":aave-v3-core/=lib/aave-v3-factory/src/core/",
            ":aave-v3-factory/=lib/aave-v3-factory/",
            ":aave-v3-periphery/=lib/aave-v3-factory/src/periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/aave-helpers/lib/forge-std/src/",
            ":governance-crosschain-bridges/=lib/aave-v3-factory/lib/aave-helpers/lib/governance-crosschain-bridges/",
            ":protocol-v2/=lib/aave-v3-factory/lib/aave-collector-unification/lib/protocol-v2/",
            ":solidity-utils/=lib/aave-helpers/lib/solidity-utils/src/"
      ]
}
  }
};
