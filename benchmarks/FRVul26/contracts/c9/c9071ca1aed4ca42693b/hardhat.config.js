module.exports = {
  solidity: {
    version: "0.8.16",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            ":openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":solmate/=lib/solmate/"
      ]
}
  }
};
