module.exports = {
  solidity: {
    version: "0.8.33",
    settings: {
      "viaIR": true,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            "lib/pendle-core-v3/:@openzeppelin/contracts/=node_modules/@openzeppelin-v5/contracts/",
            "lib/pendle-core-v3/:@openzeppelin/contracts-upgradeable/=node_modules/@openzeppelin-v5/contracts-upgradeable/",
            "node_modules/@layerzerolabs/test-devtools-evm-foundry/:forge-std/=node_modules/forge-std/src/",
            "node_modules/@layerzerolabs/oapp-evm/:@openzeppelin/=node_modules/@openzeppelin/",
            "node_modules/@layerzerolabs/oft-evm/:@openzeppelin/=node_modules/@openzeppelin/",
            "node_modules/@layerzerolabs/:@openzeppelin/=node_modules/@openzeppelin-v5/",
            "@axelar-network/=node_modules/@axelar-network/",
            "@chainlink/=node_modules/@chainlink/",
            "@openzeppelin/contracts/=node_modules/@openzeppelin/contracts/",
            "@openzeppelin/contracts-upgradeable/=node_modules/@openzeppelin/contracts-upgradeable/",
            "@openzeppelin-v5/contracts/=node_modules/@openzeppelin-v5/contracts/",
            "@openzeppelin-v5/contracts-upgradeable/=node_modules/@openzeppelin-v5/contracts-upgradeable/",
            "@eth-optimism/=node_modules/@eth-optimism/",
            "@prb/test/=node_modules/@prb/test/",
            "forge-std/=node_modules/forge-std/",
            "@pendle/core-v2/=lib/pendle-core-v2/",
            "@pendle/core-v3/=lib/pendle-core-v3/",
            "@pendle/sy/=lib/pendle-sy/",
            "pendle-sy/=lib/pendle-sy/contracts/",
            "hardhat-deploy/=node_modules/hardhat-deploy/",
            "ds-test/=lib/surl/lib/forge-std/lib/ds-test/src/",
            "solidity-bytes-utils/=node_modules/solidity-bytes-utils/",
            "solidity-stringutils/=lib/surl/lib/solidity-stringutils/src/",
            "surl/=lib/surl/src/",
            "@layerzerolabs/=node_modules/@layerzerolabs/",
            "pendle-core-v2/=lib/pendle-core-v2/contracts/",
            "pendle-core-v3/=lib/pendle-core-v3/contracts/"
      ]
}
  }
};
