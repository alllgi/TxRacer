module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": true
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "details": {
                  "cse": true,
                  "yul": false,
                  "peephole": true,
                  "deduplicate": true,
                  "orderLiterals": true,
                  "jumpdestRemover": true,
                  "constantOptimizer": true
            }
      },
      "evmVersion": "istanbul",
      "remappings": []
}
  }
};
