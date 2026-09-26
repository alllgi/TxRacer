module.exports = {
  solidity: {
    version: "0.8.26",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            ":@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":@openzeppelin/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-gas-snapshot/=lib/permit2/lib/forge-gas-snapshot/src/",
            ":forge-std/=lib/forge-std/src/",
            ":forge-std/=test/utils/forge-std/",
            ":halmos-cheatcodes/=lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/",
            ":murky/=lib/murky/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/murky/lib/openzeppelin-contracts/",
            ":permit2/=lib/permit2/src/",
            ":solady/=lib/solady/src/",
            ":solmate/=lib/permit2/lib/solmate/"
      ]
}
  }
};
