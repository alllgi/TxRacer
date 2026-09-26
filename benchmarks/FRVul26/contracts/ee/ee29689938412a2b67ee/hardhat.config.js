module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "none",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 18000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            "forge-std/=src/v0.8/vendor/forge-std/src/",
            "@openzeppelin/=node_modules/@openzeppelin/",
            "@arbitrum/=node_modules/@arbitrum/",
            "hardhat/=node_modules/hardhat/",
            "@eth-optimism/=node_modules/@eth-optimism/",
            "@scroll-tech/=node_modules/@scroll-tech/"
      ]
}
  }
};
