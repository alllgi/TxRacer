module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "src/libs/SignatureVerifier.sol": {
                  "SignatureVerifier": "0x3ca829b74971035fe0b733cd6297ca7a8a39e7c0"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "istanbul",
      "remappings": []
}
  }
};
