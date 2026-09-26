module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 10000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": []
}
  }
};
