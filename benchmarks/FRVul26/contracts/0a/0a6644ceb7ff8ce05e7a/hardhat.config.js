module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "contracts/p1/mixins/BasketLib.sol": {
                  "BasketLibP1": "0xf383dc60d29a5b9ba461f40a0606870d80d1ea88"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": []
}
  }
};
