module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":create3-factory/=lib/create3-factory/",
            ":ds-test/=lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":interfaces/=lib/interfaces/",
            ":libraries/=lib/libraries/",
            ":solmate/=lib/create3-factory/lib/solmate/src/",
            ":utils/=lib/utils/"
      ]
}
  }
};
