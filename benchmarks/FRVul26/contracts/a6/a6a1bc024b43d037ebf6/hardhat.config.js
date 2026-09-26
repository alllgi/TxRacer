module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "none",
            "useLiteralContent": false
      },
      "libraries": {
            "src/core/contracts/protocol/libraries/logic/PoolLogic.sol": {
                  "PoolLogic": "0x55D552EFbc8aEB87AffCEa8630B43a33BA24D975"
            },
            "src/core/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0x12959a64470Dd003590Bb1EcFC436dddE7608724"
            },
            "src/core/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x41717de714Db8630F02Dea8f6A39C73A5b5C7df1"
            },
            "src/core/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0xca2385754bCa5d632F5160B560352aBd12029685"
            },
            "src/core/contracts/protocol/libraries/logic/SupplyLogic.sol": {
                  "SupplyLogic": "0x9336943ecd91C201D9ED5A21562b34Aef710052f"
            },
            "src/core/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "FlashLoanLogic": "0x6DA8d7EF0625e965dafc393793C048096392d4a5"
            },
            "src/core/contracts/protocol/libraries/logic/LiquidationLogic.sol": {
                  "LiquidationLogic": "0x72c272aE914EC11AFe1e74A0016e0A91c1A6014e"
            },
            "src/core/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0x6F4964Db83CeCCDc98164796221d5259b922313C"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            "solidity-utils/=lib/solidity-utils/src/",
            "forge-std/=lib/forge-std/src/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "aave-address-book/=lib/aave-address-book/src/",
            "aave-address-book:aave-v3-core/=lib/aave-address-book/lib/aave-v3-core/",
            "lib/aave-address-book:aave-v3-core/=lib/aave-address-book/lib/aave-v3-core/",
            "lib/aave-address-book:aave-v3-periphery/=lib/aave-address-book/lib/aave-v3-periphery/",
            "aave-v3-core/=src/core/",
            "aave-v3-periphery/=src/periphery/",
            "@aave/core-v3/=lib/aave-address-book/lib/aave-v3-core/",
            "@aave/periphery-v3/=lib/aave-address-book/lib/aave-v3-periphery/"
      ]
}
  }
};
