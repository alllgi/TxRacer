module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "contracts/pendle/contracts/core/Market/OracleLib.sol": {
                  "OracleLib": "0xc6378a93725e499a20df8f00ae31d9ce9d09f1ca"
            }
      },
      "optimizer": {
            "runs": 11000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": []
}
  }
};
