module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "libraries": {
            "contracts/protocol/libraries/logic/ReserveLogic.sol": {
                  "ReserveLogic": "0xe58575ba47a348e3c2f9b7ec3eccfbb189ccc6ec"
            },
            "contracts/protocol/libraries/logic/ValidationLogic.sol": {
                  "ValidationLogic": "0xf5543cdd5f551635e13ebe07e47d01d0fc9cbbd5"
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
