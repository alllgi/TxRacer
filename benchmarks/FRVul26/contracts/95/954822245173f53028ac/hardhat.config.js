module.exports = {
  solidity: {
    version: "0.8.29",
    settings: {
      "viaIR": true,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            "@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "@openzeppelin/=lib/openzeppelin-contracts/",
            "openzeppelin-contracts/=lib/native-token-transfers/evm/lib/openzeppelin-contracts/",
            "wormhole-solidity-sdk/=lib/native-token-transfers/evm/lib/wormhole-solidity-sdk/src/",
            "wormhole-solidity-sdk/libraries/=lib/native-token-transfers/evm/lib/wormhole-solidity-sdk/src/libraries/",
            "wormhole-ntt-contracts/=lib/wormhole-ntt-contracts/",
            "create3-factory/=lib/wormhole-ntt-contracts/lib/create3-factory/",
            "ds-test/=lib/wormhole-ntt-contracts/lib/solmate/lib/ds-test/src/",
            "erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "example-messaging-executor/=lib/example-ntt-with-executor-evm/lib/",
            "example-ntt-with-executor-evm/=lib/example-ntt-with-executor-evm/",
            "forge-std/=lib/forge-std/src/",
            "halmos-cheatcodes/=lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/",
            "native-token-transfers/=lib/native-token-transfers/",
            "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "solidity-bytes-utils/=lib/native-token-transfers/evm/lib/solidity-bytes-utils/contracts/",
            "solmate/=lib/wormhole-ntt-contracts/lib/solmate/src/"
      ]
}
  }
};
