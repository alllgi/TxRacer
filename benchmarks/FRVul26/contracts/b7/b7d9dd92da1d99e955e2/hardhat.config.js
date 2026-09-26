module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "libraries": {
            "ChainlinkOracleV2.sol": {}
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "istanbul"
}
  }
};
