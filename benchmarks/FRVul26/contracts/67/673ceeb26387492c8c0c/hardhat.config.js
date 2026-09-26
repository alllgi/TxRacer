module.exports = {
  solidity: {
    version: "0.8.27",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 999999,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":halmos-cheatcodes/=lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/"
      ]
}
  }
};
