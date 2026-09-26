module.exports = {
  solidity: {
    version: "0.8.13",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 2000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":@eigenlayer/=lib/eigenlayer-contracts/src/",
            ":@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":@openzeppelin-upgrades/=lib/eigenlayer-contracts/lib/openzeppelin-contracts-upgradeable/",
            ":@openzeppelin/=lib/openzeppelin-contracts/",
            ":@uniswap/=lib/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":eigenlayer-contracts/=lib/eigenlayer-contracts/",
            ":forge-std/=lib/forge-std/src/",
            ":murky/=lib/murky/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":v3-core/=lib/v3-core/",
            ":v3-periphery/=lib/v3-periphery/contracts/"
      ]
}
  }
};
