module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "viaIR": false,
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            "@eth-optimism/=node_modules/@hop-protocol/sdk/node_modules/@eth-optimism/",
            "@uniswap/=node_modules/@uniswap/",
            "eth-gas-reporter/=node_modules/eth-gas-reporter/",
            "@openzeppelin/=lib/openzeppelin-contracts/",
            "celer-network/=lib/sgn-v2-contracts/",
            "create3-factory/=lib/create3-factory/src/",
            "solmate/=lib/solmate/src/",
            "solady/=lib/solady/src/",
            "permit2/=lib/Permit2/src/",
            "ds-test/=lib/ds-test/src/",
            "forge-std/=lib/forge-std/src/",
            "lifi/=src/",
            "test/=test/",
            "@cowprotocol/=node_modules/@cowprotocol/",
            "Permit2/=lib/Permit2/",
            "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            "forge-gas-snapshot/=lib/Permit2/lib/forge-gas-snapshot/src/",
            "hardhat/=node_modules/hardhat/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "openzeppelin/=lib/openzeppelin-contracts/contracts/",
            "sgn-v2-contracts/=lib/sgn-v2-contracts/contracts/"
      ]
}
  }
};
