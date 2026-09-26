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
            "runs": 1600,
            "details": {
                  "cse": true,
                  "yul": true,
                  "inliner": true,
                  "peephole": true,
                  "yulDetails": {
                        "optimizerSteps": "dhfoDgvulfnTUtnIf[xa[r]EscLMcCTUtTOntnfDIulLculVcul [j]Tpeulxa[rul]xa[r]cLCTUca[r]LSsTFOtfDnca[r]Iulc]jmul[jul] VcTOcul jmul : fDnTOc",
                        "stackAllocation": true
                  },
                  "deduplicate": true,
                  "orderLiterals": true,
                  "jumpdestRemover": true,
                  "constantOptimizer": true,
                  "simpleCounterForLoopUncheckedIncrement": true
            }
      },
      "evmVersion": "shanghai",
      "remappings": []
}
  }
};
