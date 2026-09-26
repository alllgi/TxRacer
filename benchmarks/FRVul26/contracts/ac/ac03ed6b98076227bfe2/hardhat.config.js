module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {
            "src/core/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0x55d552efbc8aeb87affcea8630b43a33ba24d975"
            },
            "src/core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0x12959a64470dd003590bb1ecfc436ddde7608724"
            },
            "src/core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x41717de714db8630f02dea8f6a39c73a5b5c7df1"
            },
            "src/core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0xca2385754bca5d632f5160b560352abd12029685"
            },
            "src/core/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x9336943ecd91c201d9ed5a21562b34aef710052f"
            },
            "src/core/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0x6da8d7ef0625e965dafc393793c048096392d4a5"
            },
            "src/core/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0x72c272ae914ec11afe1e74a0016e0a91c1a6014e"
            },
            "src/core/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0x6f4964db83ceccdc98164796221d5259b922313c"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":aave-address-book/=lib/aave-address-book/src/",
            ":aave-v3-core/=src/core/",
            ":aave-v3-origin/=src/",
            ":aave-v3-periphery/=src/periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":solidity-utils/=lib/solidity-utils/src/",
            "aave-address-book:aave-v3-origin/=lib/aave-address-book/lib/aave-v3-origin/src/"
      ]
}
  }
};
