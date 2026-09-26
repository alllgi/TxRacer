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
            "runs": 1000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@prb/test/=lib/prb-math/node_modules/@prb/test/",
            ":contracts/=contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":interfaces/=contracts/interfaces/",
            ":lz/=lib/utils/lib/solidity-examples/contracts/",
            ":mock/=test/mock/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":oz-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":oz/=lib/openzeppelin-contracts/contracts/",
            ":prb-math/=lib/prb-math/src/",
            ":prb/math/=lib/prb-math/src/",
            ":solidity-examples/=lib/utils/lib/solidity-examples/contracts/",
            ":solidity-stringutils/=lib/solidity-stringutils/",
            ":stringutils/=lib/solidity-stringutils/",
            ":test/=test/",
            ":utils/=lib/utils/"
      ]
}
  }
};
