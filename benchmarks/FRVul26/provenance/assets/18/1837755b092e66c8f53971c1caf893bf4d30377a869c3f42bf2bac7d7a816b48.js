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
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/"
      ]
}
  }
};
