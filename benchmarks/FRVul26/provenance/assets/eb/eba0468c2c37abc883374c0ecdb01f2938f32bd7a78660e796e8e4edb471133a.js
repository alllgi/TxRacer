module.exports = {
  solidity: {
    version: "0.8.25",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@symbiotic/burners/=lib/burners/src/",
            ":@symbiotic/core-test/=lib/core/test/",
            ":@symbiotic/core/=lib/core/src/",
            ":@symbiotic/rewards/=lib/rewards/src/",
            ":@symbioticfi/core/=lib/burners/lib/core/",
            ":burners/=lib/burners/",
            ":core/=lib/core/",
            ":ds-test/=lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":rewards/=lib/rewards/"
      ]
}
  }
};
