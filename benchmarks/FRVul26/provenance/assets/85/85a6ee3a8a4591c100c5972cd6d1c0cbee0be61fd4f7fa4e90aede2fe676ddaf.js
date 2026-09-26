module.exports = {
  solidity: {
    version: "0.3.9",
    settings: {
      "libraries": {},
      "evmVersion": "cancun",
      "search_paths": [
            "."
      ],
      "outputSelection": {
            "CurveTricryptoFactory.vy": [
                  "abi",
                  "ast",
                  "interface",
                  "ir",
                  "userdoc",
                  "devdoc",
                  "evm.bytecode.object",
                  "evm.bytecode.opcodes",
                  "evm.deployedBytecode.object",
                  "evm.deployedBytecode.opcodes",
                  "evm.deployedBytecode.sourceMap",
                  "evm.methodIdentifiers"
            ]
      }
}
  }
};
