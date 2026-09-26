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
            ":@aave/=node_modules/@aave/",
            ":@aave/core-v3/=node_modules/@aave/core-v3/",
            ":@aave/periphery-v3/=node_modules/@aave/periphery-v3/",
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":aave-address-book/=lib/aave-stk-v1-5/lib/aave-address-book/src/",
            ":aave-helpers/=lib/aave-stk-v1-5/lib/aave-helpers/",
            ":aave-stk-v1-5/=lib/aave-stk-v1-5/",
            ":aave-v3-core/=lib/aave-stk-v1-5/lib/aave-address-book/lib/aave-v3-core/",
            ":aave-v3-periphery/=lib/aave-stk-v1-5/lib/aave-address-book/lib/aave-v3-periphery/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/aave-stk-v1-5/lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":eth-gas-reporter/=node_modules/eth-gas-reporter/",
            ":forge-std/=lib/forge-std/src/",
            ":hardhat-deploy/=node_modules/hardhat-deploy/",
            ":hardhat/=node_modules/hardhat/",
            ":openzeppelin-contracts/=lib/aave-stk-v1-5/lib/openzeppelin-contracts/",
            ":solidity-utils/=lib/aave-stk-v1-5/lib/aave-helpers/lib/solidity-utils/"
      ]
}
  }
};
