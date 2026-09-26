module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-gas-snapshot/=lib/forge-gas-snapshot/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":solmate/=lib/solmate/"
      ]
}
  }
};
