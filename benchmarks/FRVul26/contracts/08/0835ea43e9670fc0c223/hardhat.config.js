module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0xd60e89f5b8bd0e46029fd127741da136b3a574d7"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0xa2c266cd25296a7174134b0a6d894e250c830504"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0xc3ba0a556e0813bbf0741cdad6086ca1023cd6d3"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0x345a778167524995d6788a9a0e1d0eeb7cbfe496"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x20ea931ce718b5f3bcdcfc3b7d2685f6a853a55d"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0xce53459e8734df93399a425183ee1860ca8c2d0b"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0x0c0191dd96ed7ef86d1cc319eb68f127c196a6ee"
            },
            "lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0xefac7bb7f7943df27efc108ebafc450e3812acda"
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
