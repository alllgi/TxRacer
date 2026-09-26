module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "istanbul",
      "remappings": [
            ":@0x/contracts-erc20=/Users/michaelzhu/protocol/contracts/zero-ex/node_modules/@0x/contracts-erc20",
            ":@0x/contracts-utils=/Users/michaelzhu/protocol/node_modules/@0x/contracts-utils"
      ]
}
  }
};
