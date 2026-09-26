module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {
            "": {
                  "ReserveLogic": "0xe58575ba47a348e3c2f9b7ec3eccfbb189ccc6ec",
                  "ValidationLogic": "0x2fba77a9dd1cca8c3b54ce20191057eaa08402d6"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "istanbul",
      "remappings": [
            ":@aave/core-v3/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-core/",
            ":@aave/periphery-v3/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-periphery/",
            ":aave-address-book/=lib/aave-helpers/lib/aave-address-book/src/",
            ":aave-helpers/=lib/aave-helpers/src/",
            ":aave-v3-core/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-core/",
            ":aave-v3-periphery/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-periphery/",
            ":ds-test/=lib/aave-helpers/lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/aave-helpers/lib/forge-std/src/",
            ":governance-crosschain-bridges/=lib/aave-helpers/lib/governance-crosschain-bridges/",
            ":solidity-utils/=lib/aave-helpers/lib/solidity-utils/src/"
      ]
}
  }
};
