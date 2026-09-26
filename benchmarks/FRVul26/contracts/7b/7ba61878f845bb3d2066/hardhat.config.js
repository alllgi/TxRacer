module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "berlin",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":beacon-light-client/=lib/beacon-light-client/",
            ":create3-deploy/=lib/beacon-light-client/lib/create3-deploy/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":halmos-cheatcodes/=lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":openzeppelin-foundry-upgrades/=lib/openzeppelin-foundry-upgrades/src/",
            ":solidity-stringutils/=lib/openzeppelin-foundry-upgrades/lib/solidity-stringutils/"
      ]
}
  }
};
