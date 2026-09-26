module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            "forge-std/=lib/forge-std/src/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "src/=src/",
            "test/=test/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/"
      ]
}
  }
};
