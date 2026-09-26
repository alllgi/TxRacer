module.exports = {
  solidity: {
    version: "0.8.26",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@uniswap/v2-core/=lib/v2-core/",
            ":@uniswap/v2-periphery/=lib/v2-periphery/",
            ":@uniswap/v3-core/=lib/v3-core/",
            ":@uniswap/v3-periphery/=lib/v3-periphery/",
            ":ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":v2-core/=lib/v2-core/contracts/",
            ":v2-periphery/=lib/v2-periphery/contracts/",
            ":v3-core/=lib/v3-core/contracts/",
            ":v3-periphery/=lib/v3-periphery/contracts/"
      ]
}
  }
};
