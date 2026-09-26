module.exports = {
  solidity: {
    version: "0.8.20",
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
            ":@openzeppelin/=lib/openzeppelin-contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            ":openzeppelin-foundry-upgrades/=lib/openzeppelin-foundry-upgrades/src/",
            ":solidity-stringutils/=lib/openzeppelin-foundry-upgrades/lib/solidity-stringutils/",
            ":src/=src/",
            ":utils/=lib/utils/"
      ]
}
  }
};
