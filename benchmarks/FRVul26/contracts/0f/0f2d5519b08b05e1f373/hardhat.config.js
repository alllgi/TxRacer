module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
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
      "remappings": [
            ":@openzeppelin/contracts/=lib/openzeppelin-solc-0.6/contracts/",
            ":@uniswap/v3-core/=lib/uniswap-v3-core/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-solc-0.6/=lib/openzeppelin-solc-0.6/contracts/",
            ":openzeppelin-solc-0.7/=lib/openzeppelin-solc-0.7/contracts/",
            ":openzeppelin-solc-0.8/=lib/openzeppelin-solc-0.8/contracts/",
            ":uniswap-v3-core/=lib/uniswap-v3-core/",
            ":uniswap-v3-periphery/=lib/uniswap-v3-periphery/contracts/"
      ]
}
  }
};
