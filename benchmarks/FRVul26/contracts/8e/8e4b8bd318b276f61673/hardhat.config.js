module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0xb341e4f99c73caa2136302f468ac3b75827c1736"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x5547d7d54d10c359108e36d098016c4020443fd4"
            },
            "lib/aave-v3-factory/src/core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0xd948cfb92ebf175e4bd772305fdee8f39e934520"
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
