module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
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
            ":@eth-optimism/=node_modules/@hop-protocol/sdk/node_modules/@eth-optimism/",
            ":@openzeppelin/=lib/openzeppelin-contracts/",
            ":@uniswap/=node_modules/@uniswap/",
            ":celer-network/=lib/sgn-v2-contracts/",
            ":create3-factory/=lib/create3-factory/src/",
            ":ds-test/=lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":eth-gas-reporter/=node_modules/eth-gas-reporter/",
            ":forge-std/=lib/forge-std/src/",
            ":hardhat-deploy/=node_modules/hardhat-deploy/",
            ":hardhat/=node_modules/hardhat/",
            ":lifi/=src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":sgn-v2-contracts/=lib/sgn-v2-contracts/contracts/",
            ":solady/=lib/solady/src/",
            ":solmate/=lib/solmate/src/",
            ":test/=test/"
      ]
}
  }
};
