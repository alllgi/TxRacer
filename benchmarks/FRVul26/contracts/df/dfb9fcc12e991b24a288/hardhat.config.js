module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 10000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":@axelar-network/=node_modules/@axelar-network/",
            ":@connext/=node_modules/@connext/",
            ":@eth-optimism/=node_modules/@eth-optimism/",
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":@uniswap/=node_modules/@uniswap/",
            ":celer-network/=lib/sgn-v2-contracts/",
            ":create3-factory/=lib/create3-factory/src/",
            ":ds-test/=lib/ds-test/src/",
            ":eth-gas-reporter/=node_modules/eth-gas-reporter/",
            ":forge-std/=lib/forge-std/src/",
            ":hardhat-deploy/=node_modules/hardhat-deploy/",
            ":hardhat/=node_modules/hardhat/",
            ":rubic/=src/",
            ":sgn-v2-contracts/=lib/sgn-v2-contracts/contracts/",
            ":solmate/=lib/solmate/src/",
            ":test/=test/"
      ]
}
  }
};
