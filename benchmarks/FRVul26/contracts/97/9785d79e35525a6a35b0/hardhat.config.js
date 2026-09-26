module.exports = {
  solidity: {
    version: "0.8.22",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "optimizer": {
            "runs": 20000,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            "@openzeppelin/contracts/=node_modules/@openzeppelin/contracts/",
            "@openzeppelin/contracts-upgradeable/=node_modules/@openzeppelin/contracts-upgradeable/",
            "solidity-bytes-utils/=node_modules/solidity-bytes-utils/",
            "hardhat-deploy/=node_modules/hardhat-deploy/",
            "@layerzerolabs/lz-evm-protocol-v2/=node_modules/@layerzerolabs/lz-evm-protocol-v2/",
            "@layerzerolabs/lz-evm-v1-0.7/=node_modules/@layerzerolabs/lz-evm-v1-0.7/",
            "@axelar-network/axelar-gmp-sdk-solidity/=node_modules/@axelar-network/axelar-gmp-sdk-solidity/",
            "@chainlink/contracts-ccip/=node_modules/@chainlink/contracts-ccip/",
            "forge-std/=/Users/simonperriard/Documents/Work/LayerZero-v2/lib/forge-std/src/"
      ]
}
  }
};
