module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
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
