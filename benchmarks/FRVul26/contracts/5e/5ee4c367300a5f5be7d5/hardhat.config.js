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
            ":@0x/contracts-erc20/=contracts/deps/erc20/",
            ":@0x/contracts-utils/=contracts/deps/utils/",
            ":ds-test/=contracts/deps/forge-std/lib/ds-test/src/",
            ":erc20/=contracts/deps/erc20/src/",
            ":forge-std/=contracts/deps/forge-std/src/",
            ":samplers/=contracts/test/samplers/",
            ":src/=contracts/src/",
            ":utils/=tests/utils/"
      ]
}
  }
};
