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
            "runs": 10000,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-gas-snapshot/=lib/forge-gas-snapshot/src/",
            ":forge-std/=lib/forge-std/src/",
            ":permit2/=lib/permit2/",
            ":solmate/=lib/solmate/"
      ]
}
  }
};
