module.exports = {
  solidity: {
    version: "0.8.16",
    settings: {
      "viaIR": true,
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
            ":@script/chronicle-std/=lib/chronicle-std/script/",
            ":chronicle-std/=lib/chronicle-std/src/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":greenhouse/=lib/greenhouse/src/",
            "lib/chronicle-std:ds-test/=lib/chronicle-std/lib/forge-std/lib/ds-test/src/",
            "lib/chronicle-std:forge-std/=lib/chronicle-std/lib/forge-std/src/",
            "lib/chronicle-std:src/=lib/chronicle-std/src/"
      ]
}
  }
};
