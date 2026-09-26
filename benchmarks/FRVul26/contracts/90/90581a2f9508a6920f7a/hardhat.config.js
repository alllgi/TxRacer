module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0xa58fb47be9074828215a173564c0cd10f6f249bf"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0x88f864670de467aa73cd45325f9652c578c8ab85"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x4c52fe2162200bf26c314d7bbd8611699139d553"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0x97dcbfae5372a63128f141e8c0bc2c871ca5f604"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x2b22e425c1322fba0dbf17bb1da25d71811ee7ba"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0xb32381fefff45ee9f47fd2f2cf83c832637d6ef0"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0x80d16970b31243fe67dab028115f3e4c3e3510ad"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0x3a593a622754ed9572599d33aad6d799b0899fae"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/aave-v3-origin-private/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/aave-v3-origin-private/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            ":aave-address-book/=lib/aave-helpers/lib/aave-address-book/src/",
            ":aave-helpers/=lib/aave-helpers/",
            ":aave-v3-core/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/core/",
            ":aave-v3-origin-test/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/test/",
            ":aave-v3-origin-tests/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/tests/",
            ":aave-v3-origin/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/",
            ":aave-v3-periphery/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/periphery/",
            ":ds-test/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            ":solidity-utils/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/src/"
      ]
}
  }
};
