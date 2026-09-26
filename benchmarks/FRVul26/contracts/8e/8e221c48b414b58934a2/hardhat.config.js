module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "istanbul",
      "remappings": [
            "@circlefin/stablecoin-evm/=lib/stablecoin-evm/",
            "@openzeppelin/=lib/openzeppelin-contracts/",
            "@openzeppelin4.2.0/=lib/openzeppelin-contracts@v4.2.0/",
            "forge-std/=lib/forge-std/src/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            "openzeppelin-contracts@v4.2.0/=lib/openzeppelin-contracts@v4.2.0/contracts/",
            "stablecoin-evm/=lib/stablecoin-evm/"
      ]
}
  }
};
