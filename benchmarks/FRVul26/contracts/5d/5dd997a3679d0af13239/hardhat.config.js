module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {
            "src/contracts/protocol/libraries/logic/EModeLogic.sol": {
                  "EModeLogic": "0x88f864670de467aa73cd45325f9652c578c8ab85"
            },
            "src/contracts/protocol/libraries/logic/BorrowLogic.sol": {
                  "BorrowLogic": "0x4c52fe2162200bf26c314d7bbd8611699139d553"
            },
            "src/contracts/protocol/libraries/logic/BridgeLogic.sol": {
                  "BridgeLogic": "0x97dcbfae5372a63128f141e8c0bc2c871ca5f604"
            },
            "src/contracts/protocol/libraries/logic/ConfiguratorLogic.sol": {
                  "ConfiguratorLogic": "0x3a593a622754ed9572599d33aad6d799b0899fae"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            ":aave-v3-core/=src/core/",
            ":aave-v3-periphery/=src/periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            ":solidity-utils/=lib/solidity-utils/src/"
      ]
}
  }
};
