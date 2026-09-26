module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@aave/core-v2/=lib/aave-collector-unification/lib/protocol-v2/",
            ":@aave/core-v3/=lib/aave-address-book/lib/aave-v3-core/",
            ":@aave/periphery-v3/=lib/aave-address-book/lib/aave-v3-periphery/",
            ":aave-address-book/=lib/aave-address-book/src/",
            ":aave-collector-unification/=lib/aave-collector-unification/",
            ":aave-helpers/=lib/aave-helpers/src/",
            ":aave-v3-core/=src/core/",
            ":aave-v3-periphery/=src/periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":governance-crosschain-bridges/=lib/aave-helpers/lib/governance-crosschain-bridges/",
            ":protocol-v2/=lib/aave-collector-unification/lib/protocol-v2/",
            ":solidity-utils/=lib/solidity-utils/src/"
      ]
}
  }
};
