module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":UniswapX/=lib/UniswapX/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-gas-snapshot/=lib/UniswapX/lib/forge-gas-snapshot/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            ":openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":permit2/=lib/UniswapX/lib/permit2/",
            ":solmate/=lib/solmate/",
            ":uniswapx/=lib/UniswapX/"
      ]
}
  }
};
