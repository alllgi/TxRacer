module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 9999999,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            ":@forge/=lib/forge-std/src/",
            ":@solady/=lib/solady/"
      ]
}
  }
};
