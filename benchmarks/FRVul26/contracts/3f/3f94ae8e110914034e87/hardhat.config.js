module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            "@aave/core-v3/=lib/aave-v3-core/",
            "@aave/periphery-v3/=lib/aave-v3-periphery/",
            "aave-address-book/=lib/aave-address-book/src/",
            "aave-helpers/=lib/aave-helpers/src/",
            "aave-v3-core/=lib/aave-v3-core/",
            "aave-v3-periphery/=lib/aave-v3-periphery/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "forge-std/=lib/forge-std/src/",
            "solidity-utils/=lib/aave-helpers/lib/solidity-utils/src/"
      ]
}
  }
};
