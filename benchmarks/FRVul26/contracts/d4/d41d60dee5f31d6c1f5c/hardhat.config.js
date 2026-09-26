module.exports = {
  solidity: {
    version: "0.8.25",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            ":openzeppelin-foundry-upgrades/=lib/openzeppelin-foundry-upgrades/src/",
            ":solidity-stringutils/=lib/openzeppelin-foundry-upgrades/lib/solidity-stringutils/",
            ":solmate/=lib/solmate/src/"
      ]
}
  }
};
