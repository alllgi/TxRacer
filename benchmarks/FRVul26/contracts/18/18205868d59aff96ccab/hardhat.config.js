module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {},
      "optimizer": {
            "runs": 26000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@arbitrum/=node_modules/@arbitrum/",
            ":@chainlink/=node_modules/@chainlink/",
            ":@eth-optimism/=node_modules/@eth-optimism/",
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":@scroll-tech/=node_modules/@scroll-tech/",
            ":forge-std/=src/v0.8/vendor/forge-std/src/",
            ":hardhat/=node_modules/hardhat/"
      ]
}
  }
};
