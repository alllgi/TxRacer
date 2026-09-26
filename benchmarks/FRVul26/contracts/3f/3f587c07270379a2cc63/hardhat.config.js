module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 999999,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":@routerprotocol/=node_modules/@routerprotocol/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":fx-portal/=lib/contracts/contracts/"
      ]
}
  }
};
