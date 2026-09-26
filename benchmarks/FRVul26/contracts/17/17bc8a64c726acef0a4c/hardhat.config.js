module.exports = {
  solidity: {
    version: "0.8.26",
    settings: {
      "viaIR": true,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "none",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 4194304,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            "@aperture_finance/uni-v3-lib/=node_modules/@aperture_finance/uni-v3-lib/",
            "@pancakeswap/=node_modules/@pancakeswap/",
            "@openzeppelin/=node_modules/@openzeppelin/",
            "@uniswap/=node_modules/@uniswap/",
            "solady/=node_modules/solady/",
            "forge-std/=lib/forge-std/src/"
      ]
}
  }
};
