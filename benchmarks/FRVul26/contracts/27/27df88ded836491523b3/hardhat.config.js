module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            "@aave/core-v3/=lib/aave-v3-core/",
            "@openzeppelin/=lib/openzeppelin-contracts/",
            "aave-address-book/=lib/aave-address-book/src/",
            "aave-helpers/=lib/aave-helpers/",
            "aave-stk-v1-5/=lib/aave-stk-v1-5/src/",
            "aave-v3-core/=lib/aave-v3-core/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "forge-std/=lib/forge-std/src/",
            "gho-core/=lib/gho-core/src/contracts/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "solidity-utils/=lib/solidity-utils/src/"
      ]
}
  }
};
