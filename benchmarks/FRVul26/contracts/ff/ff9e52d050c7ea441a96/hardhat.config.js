module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {},
      "optimizer": {
            "runs": 26000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@eth-optimism/=node_modules/@eth-optimism/",
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":ds-test/=foundry-lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=foundry-lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=foundry-lib/forge-std/src/",
            ":hardhat/=node_modules/hardhat/",
            ":openzeppelin-contracts/=foundry-lib/openzeppelin-contracts/contracts/"
      ]
}
  }
};
