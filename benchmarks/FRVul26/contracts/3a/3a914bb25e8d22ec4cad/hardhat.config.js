module.exports = {
  solidity: {
    version: "0.8.25",
    settings: {
      "viaIR": true,
      "metadata": {
            "appendCBOR": false,
            "bytecodeHash": "none"
      },
      "libraries": {},
      "optimizer": {
            "runs": 2000,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            ":@forge-gas-snapshot/=lib/forge-gas-snapshot/src/",
            ":@forge-std/=lib/forge-std/src/",
            ":@permit2/=lib/permit2/src/",
            ":@solmate/=lib/solmate/src/",
            ":@uniswapv4/=lib/v4-core/src/",
            ":forge-std/src/=lib/forge-std/src/",
            ":solmate/=lib/solmate/"
      ]
}
  }
};
