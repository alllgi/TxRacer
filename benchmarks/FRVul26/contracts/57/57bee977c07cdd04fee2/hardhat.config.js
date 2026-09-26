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
            ":@openzeppelin/contracts-upgradeable/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            ":aave-address-book/=lib/aave-address-book/src/",
            ":aave-v3-core/=lib/aave-address-book/lib/aave-v3-origin/src/core/",
            ":aave-v3-origin/=lib/aave-address-book/lib/aave-v3-origin/src/",
            ":aave-v3-periphery/=lib/aave-address-book/lib/aave-v3-origin/src/periphery/",
            ":ds-test/=lib/solidity-utils/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            ":solidity-utils/=lib/solidity-utils/src/"
      ]
}
  }
};
