module.exports = {
  solidity: {
    version: "0.8.19",
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
            ":@ensdomains/=node_modules/@ensdomains/",
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":@prb/test/=lib/prb-math/lib/prb-test/src/",
            ":@uniswap/=lib/borrow-contracts/node_modules/@uniswap/",
            ":borrow-contracts/=lib/borrow-contracts/",
            ":borrow/=lib/borrow-contracts/contracts/",
            ":contracts/=contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":interfaces/=contracts/interfaces/",
            ":mock/=test/mock/",
            ":oz-upgradeable/=node_modules/@openzeppelin/contracts-upgradeable/",
            ":oz/=node_modules/@openzeppelin/contracts/",
            ":prb-math/=lib/prb-math/src/",
            ":prb/math/=lib/prb-math/src/",
            ":solidity-stringutils/=lib/solidity-stringutils/src/",
            ":src/=lib/prb-math/src/",
            ":stringutils/=lib/solidity-stringutils/",
            ":test/=test/"
      ]
}
  }
};
