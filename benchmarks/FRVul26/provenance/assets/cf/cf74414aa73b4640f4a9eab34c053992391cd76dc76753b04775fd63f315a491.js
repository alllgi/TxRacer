module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      "libraries": {
            "contracts/p1/BasketHandler.sol": {
                  "BasketLibP1": "0x2fdd94f363644fede5106b22b1706e45d4dd9bea"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris"
}
  }
};
