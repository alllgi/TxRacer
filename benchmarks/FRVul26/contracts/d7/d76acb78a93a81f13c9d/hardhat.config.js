module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "optimizer": {
            "runs": 1000000,
            "details": {
                  "cse": true,
                  "yul": true,
                  "deduplicate": true,
                  "constantOptimizer": true
            },
            "enabled": true
      },
      "evmVersion": "istanbul",
      "remappings": [
            "@0x/contracts-utils=/home/cluracan/code/0x-protocol/node_modules/@0x/contracts-utils",
            "@0x/contracts-erc20=/home/cluracan/code/0x-protocol/node_modules/@0x/contracts-erc20"
      ]
}
  }
};
