module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            "forge-std/=lib/forge-std/src/",
            "aave-address-book/=lib/aave-address-book/src/",
            "cl-synchronicity-price-adapter/=lib/cl-synchronicity-price-adapter/src/",
            "aave-v3-core/=lib/aave-address-book/lib/aave-v3-core/",
            "aave-helpers/=lib/aave-helpers/src/",
            "solidity-utils/=lib/aave-helpers/lib/solidity-utils/src/",
            "@aave/core-v3/=lib/aave-address-book/lib/aave-v3-core/",
            "@aave/periphery-v3/=lib/aave-address-book/lib/aave-v3-periphery/",
            "aave-v3-periphery/=lib/aave-address-book/lib/aave-v3-periphery/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "governance-crosschain-bridges/=lib/aave-helpers/lib/governance-crosschain-bridges/"
      ]
}
  }
};
