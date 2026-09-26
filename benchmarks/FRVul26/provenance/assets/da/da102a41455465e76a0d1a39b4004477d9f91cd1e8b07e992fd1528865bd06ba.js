module.exports = {
  solidity: {
    version: "0.8.27",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "none",
            "useLiteralContent": false
      },
      "optimizer": {
            "runs": 1500,
            "enabled": true
      },
      "evmVersion": "prague",
      "remappings": [
            "forge-std/=lib/forge-std/src/",
            "@openzeppelin/=lib/openzeppelin-contracts/",
            "@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "@uniswap/=lib/",
            "@eigenlayer-libraries/=lib/eigenlayer-libraries/",
            "@etherfi/=src/",
            "@tests/=test/",
            "@scripts/=script/",
            "@layerzerolabs/lz-evm-oapp-v2/contracts/=lib/Etherfi-SyncPools/node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/",
            "@layerzerolabs/lz-evm-protocol-v2/contracts/=lib/Etherfi-SyncPools/node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/",
            "@layerzerolabs/lz-evm-messagelib-v2/contracts/=lib/Etherfi-SyncPools/node_modules/@layerzerolabs/lz-evm-messagelib-v2/contracts/",
            "@layerzerolabs/lz-evm-oapp-v2/contracts-upgradeable/=lib/Etherfi-SyncPools/node_modules/layerzero-v2/oapp/contracts/",
            "ds-test/=lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/",
            "eigenlayer-libraries/=lib/eigenlayer-libraries/",
            "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "solady/=lib/solady/src/",
            "v3-core/=lib/v3-core/",
            "v3-periphery/=lib/v3-periphery/contracts/"
      ]
}
  }
};
