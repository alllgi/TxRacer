module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {
            "src/libraries/MachineUtils.sol": {
                  "CaliberAccountingCCQ": "0x35e4fc6f2b860a553438cf29930361f56bb8d830"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            "@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            "@wormhole/sdk/=lib/wormhole-solidity-sdk/src/",
            "@enso-weiroll/=lib/enso-weiroll/contracts/",
            "IERC20/=lib/wormhole-solidity-sdk/src/interfaces/token/",
            "SafeERC20/=lib/wormhole-solidity-sdk/src/libraries/",
            "ds-test/=lib/wormhole-solidity-sdk/lib/forge-std/lib/ds-test/src/",
            "enso-weiroll/=lib/enso-weiroll/contracts/",
            "erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "forge-std/=lib/forge-std/src/",
            "halmos-cheatcodes/=lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/",
            "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            "wormhole-sdk/=lib/wormhole-solidity-sdk/src/",
            "wormhole-solidity-sdk/=lib/wormhole-solidity-sdk/src/"
      ]
}
  }
};
