module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {},
      "optimizer": {
            "runs": 4194304,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@aperture_finance/uni-v3-lib/=node_modules/@aperture_finance/uni-v3-lib/",
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":@uniswap/=node_modules/@uniswap/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":solady/=node_modules/solady/",
            ":solmate/=node_modules/solmate/",
            ":token-vesting-contracts/=lib/token-vesting-contracts/contracts/"
      ]
}
  }
};
