module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 2000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@eigenlayer/=lib/eigenlayer-contracts/src/",
            ":@layerzerolabs/lz-evm-messagelib-v2/contracts/=lib/Etherfi-SyncPools/node_modules/@layerzerolabs/lz-evm-messagelib-v2/contracts/",
            ":@layerzerolabs/lz-evm-oapp-v2/contracts-upgradeable/=lib/Etherfi-SyncPools/node_modules/layerzero-v2/oapp/contracts/",
            ":@layerzerolabs/lz-evm-oapp-v2/contracts/=lib/Etherfi-SyncPools/node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/",
            ":@layerzerolabs/lz-evm-protocol-v2/contracts/=lib/Etherfi-SyncPools/node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/",
            ":@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":@openzeppelin/=lib/openzeppelin-contracts/",
            ":@uniswap/=lib/",
            ":ds-test/=lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":v3-core/=lib/v3-core/",
            ":v3-periphery/=lib/v3-periphery/contracts/"
      ]
}
  }
};
