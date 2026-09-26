module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "contracts/pendle/contracts/core/Market/OracleLib.sol": {
                  "OracleLib": "0x83d6fa7f8904299f4a9499fe83b6ae3f21ffba57"
            }
      },
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": []
}
  }
};
