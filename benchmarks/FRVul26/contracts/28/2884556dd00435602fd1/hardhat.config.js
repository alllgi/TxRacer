module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@1inch/limit-order-protocol-contract/contracts/=lib/limit-order-protocol/contracts/",
            ":@1inch/solidity-utils/contracts/=lib/solidity-utils/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":limit-order-protocol/=lib/limit-order-protocol/contracts/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":solidity-utils/=lib/solidity-utils/contracts/"
      ]
}
  }
};
