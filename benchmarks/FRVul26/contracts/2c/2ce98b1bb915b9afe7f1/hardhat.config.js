module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "libraries": {
            "CrvUsdOracle.sol": {}
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "istanbul"
}
  }
};
