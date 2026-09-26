module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "istanbul",
      "remappings": [
            ":@aave-address-book/=lib/aave-address-book/src/",
            ":@aave-v2/=lib/protocol-v2/contracts/",
            ":@forge-std/=lib/forge-std/src/",
            ":@openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":aave-address-book/=lib/aave-address-book/src/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            ":protocol-v2/=lib/protocol-v2/"
      ]
}
  }
};
