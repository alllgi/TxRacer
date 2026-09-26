module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 10000000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/erc4626-tests/",
            ":eth-gas-reporter/=node_modules/eth-gas-reporter/",
            ":forge-std/=lib/forge-std/src/",
            ":hardhat-deploy/=node_modules/hardhat-deploy/",
            ":hardhat/=node_modules/hardhat/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/src/",
            ":solmate/=lib/solmate/"
      ]
}
  }
};
