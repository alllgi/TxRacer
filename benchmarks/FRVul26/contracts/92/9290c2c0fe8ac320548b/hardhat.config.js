module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "viaIR": true,
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
            ":@openzeppelin/=lib/openzeppelin-contracts/",
            ":@uniswap/v2-core/=lib/v2-core/",
            ":@uniswap/v3-core/=lib/v3-core/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-gas-snapshot/=lib/permit2/lib/forge-gas-snapshot/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":permit2/=lib/permit2/",
            ":solmate/=lib/solmate/src/",
            ":v2-core/=lib/v2-core/contracts/",
            ":v3-core/=lib/v3-core/"
      ]
}
  }
};
