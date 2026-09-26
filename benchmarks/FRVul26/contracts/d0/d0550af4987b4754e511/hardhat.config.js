module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      "viaIR": true,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            "@ensdomains/=lib/shortcuts-contracts/node_modules/@ensdomains/",
            "@ensofinance/=lib/shortcuts-contracts/node_modules/@ensofinance/",
            "@openzeppelin/=lib/shortcuts-contracts/node_modules/@openzeppelin/",
            "@rari-capital/=lib/shortcuts-contracts/node_modules/@rari-capital/",
            "clones-with-immutable-args/=lib/shortcuts-contracts/node_modules/clones-with-immutable-args/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            "eth-gas-reporter/=lib/shortcuts-contracts/node_modules/eth-gas-reporter/",
            "forge-std/=lib/forge-std/src/",
            "hardhat-deploy/=lib/shortcuts-contracts/node_modules/hardhat-deploy/",
            "hardhat/=lib/shortcuts-contracts/node_modules/hardhat/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "openzeppelin/=lib/openzeppelin-contracts/contracts/",
            "shortcuts-contracts/=lib/shortcuts-contracts/contracts/",
            "@ethereum-waffle/=lib/shortcuts-contracts/node_modules/@ethereum-waffle/",
            "enso-weiroll/=lib/enso-weiroll/contracts/"
      ]
}
  }
};
