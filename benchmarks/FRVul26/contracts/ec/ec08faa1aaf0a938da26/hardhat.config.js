module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      "viaIR": false,
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
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "erc20-helpers/=lib/erc20-helpers/src/",
            "forge-std/=lib/forge-std/src/",
            "sparklend-v1-core/=lib/sparklend-v1-core/contracts/",
            "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "sparklend-address-registry/=lib/sparklend-address-registry/"
      ]
}
  }
};
