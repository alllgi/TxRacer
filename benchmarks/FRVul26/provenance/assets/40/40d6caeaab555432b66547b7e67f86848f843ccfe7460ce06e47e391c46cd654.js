module.exports = {
  solidity: {
    version: "0.3.3",
    settings: {
      "libraries": {},
      "search_paths": [
            "."
      ],
      "outputSelection": {
            "BoostDelegationV2.vy": [
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
