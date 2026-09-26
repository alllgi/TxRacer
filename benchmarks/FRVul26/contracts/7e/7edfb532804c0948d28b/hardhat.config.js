module.exports = {
  solidity: {
    version: "0.8.21",
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
            ":dss-interfaces/=lib/dss-test/lib/dss-interfaces/src/",
            ":dss-test/=lib/dss-test/src/",
            ":forge-std/=lib/dss-test/lib/forge-std/src/"
      ]
}
  }
};
