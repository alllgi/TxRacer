module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      "viaIR": false,
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0xD072fF8184E873a938cb15B20f2Ad5Cc1a02D8bf"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0xC814B56BAaeE8574C169Cc0226C97466dab68c95"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x68fB4530e156ED17cB849D19102892B7AF8cbeef"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0x813C6C11ac19e7E8aA4148d5C6EDF31a4a160867"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x4c83d30CE4D0f92A867C2006B33d9b102D29F707"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0xCC3037F5aef5831730A9AcB1739D0562117314C0"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0xC0816EFC31779C697B18B3B68f1DfBeDe313e1fA"
            }
      },
      "optimizer": {
            "runs": 100000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            "@aave/core-v3/=lib/sparklend-v1-core/",
            "aave-helpers/=lib/aave-helpers/src/",
            "@uniswap/v3-core/=lib/v3-core/",
            "solidity-utils/=lib/V2-V3-migration-helpers/lib/solidity-utils/src/",
            "@aave/periphery-v3/=lib/aave-address-book/lib/aave-v3-periphery/",
            "V2-V3-migration-helpers/=lib/V2-V3-migration-helpers/",
            "aave-address-book/=lib/aave-address-book/src/",
            "aave-v3-core/=lib/aave-address-book/lib/aave-v3-core/",
            "aave-v3-periphery/=lib/aave-v3-periphery/contracts/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "dss-interfaces/=lib/dss-test/lib/dss-interfaces/src/",
            "dss-test/=lib/dss-test/src/",
            "forge-std/=lib/forge-std/src/",
            "governance-crosschain-bridges/=lib/aave-helpers/lib/governance-crosschain-bridges/",
            "sparklend-v1-core/=lib/sparklend-v1-core/"
      ]
}
  }
};
