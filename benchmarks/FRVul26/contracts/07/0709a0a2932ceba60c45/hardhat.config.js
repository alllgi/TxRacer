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
            ":@aave/=lib/gho-core/node_modules/@aave/",
            ":@aave/core-v3/=lib/aave-address-book/lib/aave-v3-core/",
            ":@aave/periphery-v3/=lib/aave-address-book/lib/aave-v3-periphery/",
            ":@openzeppelin/=lib/openzeppelin-contracts/",
            ":aave-address-book/=lib/aave-address-book/src/",
            ":aave-helpers/=lib/aave-helpers/",
            ":aave-stk-v1-5/=lib/aave-stk-v1-5/src/",
            ":aave-v3-core/=lib/aave-v3-core/",
            ":aave-v3-periphery/=lib/aave-address-book/lib/aave-v3-periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/aave-stk-v1-5/lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":eth-gas-reporter/=lib/gho-core/node_modules/eth-gas-reporter/",
            ":forge-std/=lib/forge-std/src/",
            ":gho-core/=lib/gho-core/src/contracts/",
            ":governance-crosschain-bridges/=lib/aave-helpers/lib/governance-crosschain-bridges/",
            ":hardhat-deploy/=lib/gho-core/node_modules/hardhat-deploy/",
            ":hardhat/=lib/gho-core/node_modules/hardhat/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":solidity-utils/=lib/solidity-utils/src/"
      ]
}
  }
};
