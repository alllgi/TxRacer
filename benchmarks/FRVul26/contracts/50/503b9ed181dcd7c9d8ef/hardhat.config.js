module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0xd072ff8184e873a938cb15b20f2ad5cc1a02d8bf"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0xc814b56baaee8574c169cc0226c97466dab68c95"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x68fb4530e156ed17cb849d19102892b7af8cbeef"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0x813c6c11ac19e7e8aa4148d5c6edf31a4a160867"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x4c83d30ce4d0f92a867c2006b33d9b102d29f707"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0xcc3037f5aef5831730a9acb1739d0562117314c0"
            },
            "lib/sparklend-v1-core/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0xc0816efc31779c697b18b3b68f1dfbede313e1fa"
            }
      },
      "optimizer": {
            "runs": 100000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":@aave/core-v3/=lib/sparklend-v1-core/",
            ":@aave/periphery-v3/=lib/aave-address-book/lib/aave-v3-periphery/",
            ":@uniswap/v3-core/=lib/v3-core/",
            ":V2-V3-migration-helpers/=lib/V2-V3-migration-helpers/",
            ":aave-address-book/=lib/aave-address-book/src/",
            ":aave-helpers/=lib/aave-helpers/src/",
            ":aave-v3-core/=lib/aave-address-book/lib/aave-v3-core/",
            ":aave-v3-periphery/=lib/aave-v3-periphery/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":dss-interfaces/=lib/dss-test/lib/dss-interfaces/src/",
            ":dss-test/=lib/dss-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":governance-crosschain-bridges/=lib/aave-helpers/lib/governance-crosschain-bridges/",
            ":solidity-utils/=lib/V2-V3-migration-helpers/lib/solidity-utils/src/",
            ":sparklend-v1-core/=lib/sparklend-v1-core/"
      ]
}
  }
};
