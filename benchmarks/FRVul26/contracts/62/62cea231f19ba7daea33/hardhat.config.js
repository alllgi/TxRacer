module.exports = {
  solidity: {
    version: "0.8.15",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1,
            "details": {
                  "cse": true,
                  "yul": true,
                  "inliner": true,
                  "peephole": true,
                  "yulDetails": {
                        "optimizerSteps": "dhfoDgvulfnTUtnIf [xa[r]scLM cCTUtTOntnfDIul Lcul Vcul [j] Tpeul xa[rul] xa[r]cL gvif CTUca[r]LsTOtfDnca[r]Iulc] jmul[jul] VcTOcul jmul",
                        "stackAllocation": true
                  },
                  "deduplicate": true,
                  "orderLiterals": true,
                  "jumpdestRemover": true,
                  "constantOptimizer": true
            }
      },
      "evmVersion": "london",
      "remappings": []
}
  }
};
