module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
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
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":morpho-blue/=lib/morpho-blue/",
            ":solmate/=lib/solmate/src/"
      ]
}
  }
};
