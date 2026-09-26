module.exports = {
  solidity: {
    version: "0.8.25",
    settings: {
      "viaIR": true,
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
            ":forge-gas-snapshot/=lib/permit2/lib/forge-gas-snapshot/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":permit2/=lib/permit2/",
            ":solmate/=lib/permit2/lib/solmate/"
      ]
}
  }
};
