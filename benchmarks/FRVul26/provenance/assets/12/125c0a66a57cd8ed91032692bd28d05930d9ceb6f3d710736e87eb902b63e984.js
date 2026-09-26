module.exports = {
  solidity: {
    version: "0.8.29",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            "@cowprotocol/=node_modules/@cowprotocol/",
            "@eth-optimism/=node_modules/@hop-protocol/sdk/node_modules/@eth-optimism/",
            "@openzeppelin/=lib/openzeppelin-contracts/",
            "@uniswap/=node_modules/@uniswap/",
            "Permit2/=lib/Permit2/",
            "celer-network/=lib/sgn-v2-contracts/",
            "create3-factory/=lib/create3-factory/src/",
            "ds-test/=lib/ds-test/src/",
            "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            "eth-gas-reporter/=node_modules/eth-gas-reporter/",
            "forge-gas-snapshot/=lib/Permit2/lib/forge-gas-snapshot/src/",
            "forge-std/=lib/forge-std/src/",
            "hardhat/=node_modules/hardhat/",
            "lifi/=src/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "openzeppelin/=lib/openzeppelin-contracts/contracts/",
            "permit2/=lib/Permit2/src/",
            "sgn-v2-contracts/=lib/sgn-v2-contracts/contracts/",
            "solady/=lib/solady/src/",
            "solmate/=lib/solmate/src/",
            "test/=test/"
      ]
}
  }
};
