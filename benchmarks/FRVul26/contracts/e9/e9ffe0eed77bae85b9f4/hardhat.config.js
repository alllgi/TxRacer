module.exports = {
  solidity: {
    version: "0.8.22",
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
            ":@chainlink/=lib/borrow-contracts/node_modules/@chainlink/",
            ":@ensdomains/=lib/borrow-contracts/node_modules/@ensdomains/",
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@prb/test/=lib/prb-math/lib/prb-test/src/",
            ":@uniswap/=lib/borrow-contracts/node_modules/@uniswap/",
            ":borrow-contracts/=lib/borrow-contracts/",
            ":borrow/=lib/borrow-contracts/contracts/",
            ":contracts/=contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":interfaces/=contracts/interfaces/",
            ":lz/=lib/utils/lib/solidity-examples/contracts/",
            ":mock/=test/mock/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":oz-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":oz/=lib/openzeppelin-contracts/contracts/",
            ":prb-math/=lib/prb-math/src/",
            ":prb-test/=lib/prb-math/lib/prb-test/src/",
            ":prb/math/=lib/prb-math/src/",
            ":solidity-examples/=lib/utils/lib/solidity-examples/contracts/",
            ":solidity-stringutils/=lib/solidity-stringutils/",
            ":src/=lib/prb-math/src/",
            ":stringutils/=lib/solidity-stringutils/",
            ":test/=test/",
            ":utils/=lib/utils/"
      ]
}
  }
};
