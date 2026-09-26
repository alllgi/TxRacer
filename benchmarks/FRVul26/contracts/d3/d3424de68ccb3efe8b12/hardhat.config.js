module.exports = {
  solidity: {
    version: "0.6.8",
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
            ":@0x/contracts-erc20=/home/cluracan/code/0x-monorepo/node_modules/@0x/contracts-erc20",
            ":@0x/contracts-utils=/home/cluracan/code/0x-monorepo/node_modules/@0x/contracts-utils"
      ]
}
  }
};
