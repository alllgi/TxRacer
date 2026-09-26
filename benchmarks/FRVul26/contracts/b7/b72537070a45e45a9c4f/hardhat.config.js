module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 20000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@aave/core-v3/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-core/",
            ":@aave/core-v3/=lib/aave-v3-core/",
            ":@aave/periphery-v3/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-periphery/",
            ":@bgd-helpers/=lib/aave-helpers/src/",
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":aave-address-book/=lib/aave-helpers/lib/aave-address-book/src/",
            ":aave-helpers/=lib/aave-helpers/",
            ":aave-v3-core/=lib/aave-v3-core/",
            ":aave-v3-periphery/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":governance-crosschain-bridges/=lib/aave-helpers/lib/governance-crosschain-bridges/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":openzeppelin/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":solidity-utils/=lib/aave-helpers/lib/solidity-utils/src/"
      ]
}
  }
};
