module.exports = {
  solidity: {
    version: "0.8.20",
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
            ":@aave/core-v3/=lib/aave-address-book/lib/aave-v3-core/",
            ":@aave/periphery-v3/=lib/aave-address-book/lib/aave-v3-periphery/",
            ":aave-address-book/=lib/aave-address-book/src/",
            ":aave-helpers/=lib/aave-helpers/src/",
            ":aave-token-v2/=lib/aave-token-v2/contracts/",
            ":aave-v3-core/=lib/aave-address-book/lib/aave-v3-core/",
            ":aave-v3-periphery/=lib/aave-address-book/lib/aave-v3-periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":governance-crosschain-bridges/=lib/aave-helpers/lib/governance-crosschain-bridges/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":solidity-utils/=lib/solidity-utils/src/"
      ]
}
  }
};
