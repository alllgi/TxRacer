module.exports = {
  solidity: {
    version: "0.2.15",
    settings: {
      "libraries": {},
      "evmVersion": "petersburg",
      "search_paths": [
            "."
      ],
      "outputSelection": {
            "Vyper_contract.vy": [
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
