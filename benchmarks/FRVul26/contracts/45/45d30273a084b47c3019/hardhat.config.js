module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":@chainlink/=node_modules/@chainlink/",
            ":@ensdomains/=node_modules/@ensdomains/",
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":@prb/test/=lib/prb-math/node_modules/@prb/test/",
            ":@uniswap/=node_modules/@uniswap/",
            ":base64-sol/=node_modules/base64-sol/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":eth-gas-reporter/=node_modules/eth-gas-reporter/",
            ":forge-std/=lib/forge-std/src/",
            ":hardhat-deploy/=node_modules/hardhat-deploy/",
            ":hardhat/=node_modules/hardhat/",
            ":merkle-tree-solidity/=node_modules/merkle-tree-solidity/",
            ":prb-math/=lib/prb-math/src/",
            ":prb/math/=lib/prb-math/src/",
            ":solidity-stringutils/=lib/solidity-stringutils/src/",
            ":stringutils/=lib/solidity-stringutils/"
      ]
}
  }
};
