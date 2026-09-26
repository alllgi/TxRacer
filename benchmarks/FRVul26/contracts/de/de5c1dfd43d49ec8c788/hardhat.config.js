module.exports = {
  solidity: {
    version: "0.8.17",
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
            ":@aave-v3/=lib/aave-v3-core/contracts/",
            ":@forge-std/=lib/forge-std/src/",
            ":@openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":aave-v3-core/=lib/aave-v3-core/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/"
      ]
}
  }
};
