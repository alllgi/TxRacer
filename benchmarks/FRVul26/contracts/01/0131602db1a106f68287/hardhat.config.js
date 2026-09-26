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
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc20-helpers/=lib/erc20-helpers/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":sparklend-address-registry/=lib/sparklend-address-registry/",
            ":sparklend-v1-core/=lib/sparklend-v1-core/contracts/"
      ]
}
  }
};
