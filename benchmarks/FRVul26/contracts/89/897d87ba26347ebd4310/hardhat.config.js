module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "lib/aave-v3-core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0xeAbd65827E91Ac3aE5471C11A329fbc675cA46d6"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x5d834EAD0a80CF3b88c06FeeD6e8E0Fcae2daEE5"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0x57572C9e795F4B6A748EFBeAB7E0a1B9996A0A24"
            },
            "lib/aave-v3-core/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0x7406aba1Aa5fE5cd71d958CE10fc28c416a33aA0"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            "@aave/core-v3/=lib/aave-v3-core/",
            "@aave/periphery-v3/=lib/aave-v3-periphery/",
            "aave-address-book/=lib/aave-address-book/src/",
            "aave-helpers/=lib/aave-helpers/src/",
            "aave-v3-core/=lib/aave-v3-core/",
            "aave-v3-periphery/=lib/aave-v3-periphery/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "forge-std/=lib/forge-std/src/",
            "solidity-utils/=lib/aave-helpers/lib/solidity-utils/src/"
      ]
}
  }
};
