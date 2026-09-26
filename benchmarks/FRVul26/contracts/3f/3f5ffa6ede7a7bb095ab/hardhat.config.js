module.exports = {
  solidity: {
    version: "0.8.16",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 10000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":chronicle-std/=lib/chronicle-std/src/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":solmate/=lib/solmate/src/",
            ":uniswap/=lib/uniswap/"
      ]
}
  }
};
