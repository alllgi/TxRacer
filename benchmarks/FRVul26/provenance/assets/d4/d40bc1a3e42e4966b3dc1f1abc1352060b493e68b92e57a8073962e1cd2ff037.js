module.exports = {
  solidity: {
    version: "0.2.16",
    settings: {
      "libraries": {},
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
