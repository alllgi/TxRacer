module.exports = {
  solidity: {
    version: "0.8.21",
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
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":morpho-blue/=lib/morpho-blue/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/"
      ]
}
  }
};
