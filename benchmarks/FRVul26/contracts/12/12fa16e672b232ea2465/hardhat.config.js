module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": true
      },
      "libraries": {},
      "optimizer": {
            "runs": 99999,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": []
}
  }
};
