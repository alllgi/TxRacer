module.exports = {
  solidity: {
    version: "0.8.19",
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
            ":@aave/core-v2/=lib/aave-v3-factory/lib/aave-collector-unification/lib/protocol-v2/",
            ":@aave/core-v3/=lib/aave-address-book/lib/aave-v3-core/",
            ":@aave/periphery-v3/=lib/aave-address-book/lib/aave-v3-periphery/",
            ":aave-address-book/=lib/aave-address-book/src/",
            ":aave-collector-unification/=lib/aave-v3-factory/lib/aave-collector-unification/",
            ":aave-helpers/=lib/aave-helpers/src/",
            ":aave-token-v2/=lib/aave-token-v3/lib/aave-token-v2/contracts/",
            ":aave-token-v3/=lib/aave-token-v3/src/",
            ":aave-v3-core/=lib/aave-v3-factory/src/core/",
            ":aave-v3-factory/=lib/aave-v3-factory/",
            ":aave-v3-periphery/=lib/aave-v3-factory/src/periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":governance-crosschain-bridges/=lib/aave-v3-factory/lib/aave-helpers/lib/governance-crosschain-bridges/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":protocol-v2/=lib/aave-v3-factory/lib/aave-collector-unification/lib/protocol-v2/",
            ":solidity-utils/=lib/aave-v3-factory/lib/solidity-utils/"
      ]
}
  }
};
