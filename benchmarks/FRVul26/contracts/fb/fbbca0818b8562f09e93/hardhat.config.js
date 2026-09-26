module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            "aave-v3-core/=lib/aave-v3-core/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "erc20-helpers/=lib/erc20-helpers/src/",
            "forge-std/=lib/forge-std/src/"
      ]
}
  }
};
