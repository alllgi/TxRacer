module.exports = {
  solidity: {
    version: "0.8.15",
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
            ":@openzeppelin/=lib/openzeppelin-contracts/",
            ":@uniswap/v3-core/=lib/v3-core/",
            ":@uniswap/v3-periphery/=lib/v3-periphery/",
            ":ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":v3-core/=lib/v3-core/contracts/",
            ":v3-periphery/=lib/v3-periphery/contracts/"
      ]
}
  }
};
