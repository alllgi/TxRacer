module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "": {
                  "SignatureChecker": "0x800c32eaa2a6c93cf4cb51794450ed77fbfbb172"
            }
      },
      "optimizer": {
            "runs": 10000000,
            "enabled": true
      },
      "evmVersion": "istanbul",
      "remappings": []
}
  }
};
