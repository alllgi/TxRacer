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
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":@uniswap/=node_modules/@uniswap/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-gas-snapshot/=lib/permit2/lib/forge-gas-snapshot/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/permit2/lib/openzeppelin-contracts/",
            ":permit2/=lib/permit2/",
            ":solmate/=lib/solmate/"
      ]
}
  }
};
