module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      "debug": {
            "revertStrings": "strip"
      },
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": true
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": []
}
  }
};
