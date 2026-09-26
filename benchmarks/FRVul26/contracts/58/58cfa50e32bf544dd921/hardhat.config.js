module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/",
            ":dss-interfaces/=lib/token-tests/lib/dss-test/lib/dss-interfaces/src/",
            ":dss-test/=lib/token-tests/lib/dss-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/openzeppelin-foundry-upgrades/lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            ":openzeppelin-foundry-upgrades/=lib/openzeppelin-foundry-upgrades/src/",
            ":solidity-stringutils/=lib/openzeppelin-foundry-upgrades/lib/solidity-stringutils/",
            ":token-tests/=lib/token-tests/src/"
      ]
}
  }
};
