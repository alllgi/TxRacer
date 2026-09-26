module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@ccip/=lib/ccip/",
            ":@ds-test/=lib/forge-std/lib/ds-test/src/",
            ":@forge-std/=lib/forge-std/src/",
            ":@openzeppelin/=lib/openzeppelin-contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@solmate/=lib/solmate/src/",
            ":LayerZero-v2/=lib/LayerZero-v2/",
            ":ccip/=lib/ccip/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":solmate/=lib/solmate/src/"
      ]
}
  }
};
