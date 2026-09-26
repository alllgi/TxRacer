module.exports = {
  solidity: {
    version: "0.8.19",
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
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/"
      ]
}
  }
};
