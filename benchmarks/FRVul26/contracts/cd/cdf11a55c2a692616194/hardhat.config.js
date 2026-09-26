module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "libraries": {
            "contracts/protocol/libraries/logic/GenericLogic.sol": {
                  "GenericLogic": "0xeae736e5d6560169f9285c62492f8a89fb4ab790"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "istanbul"
}
  }
};
