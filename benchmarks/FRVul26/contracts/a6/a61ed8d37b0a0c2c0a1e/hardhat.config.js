module.exports = {
  solidity: {
    version: "0.8.25",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            ":forge-std/=lib/forge-std/src/",
            ":solady/=lib/solady/src/",
            ":soledge/=lib/soledge/src/"
      ]
}
  }
};
