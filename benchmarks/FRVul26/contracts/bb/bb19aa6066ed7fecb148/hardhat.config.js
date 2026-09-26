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
            "src/oracles/MachineShareOracle.sol": {
                  "MachineUtils": "0x47e7c7d200e10f8070f873e8e5d6c9177fc12927"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            "@makina-core/=lib/makina-core/src/",
            "@makina-core-test/=lib/makina-core/test/",
            "@makina-core-script/=lib/makina-core/script/",
            "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            "@balancer-v2-interfaces/=lib/balancer-v2-monorepo/pkg/interfaces/contracts/",
            "@balancer-v3-interfaces/=lib/balancer-v3-monorepo/pkg/interfaces/contracts/",
            "@morpho/=lib/morpho-blue/src/",
            "@aave/=lib/aave-v3-origin/src/contracts/",
            "@balancer-labs/=lib/balancer-v2-monorepo/../../node_modules/@balancer-labs/",
            "@enso-weiroll/=lib/makina-core/lib/enso-weiroll/contracts/",
            "@wormhole/sdk/=lib/makina-core/lib/wormhole-solidity-sdk/src/",
            "IERC20/=lib/makina-core/lib/wormhole-solidity-sdk/src/interfaces/token/",
            "SafeERC20/=lib/makina-core/lib/wormhole-solidity-sdk/src/libraries/",
            "aave-v3-origin/=lib/aave-v3-origin/",
            "balancer-v2-monorepo/=lib/balancer-v2-monorepo/",
            "balancer-v3-monorepo/=lib/balancer-v3-monorepo/",
            "ds-test/=lib/aave-v3-origin/lib/forge-std/lib/ds-test/src/",
            "enso-weiroll/=lib/makina-core/lib/enso-weiroll/contracts/",
            "erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "forge-std/=lib/forge-std/src/",
            "halmos-cheatcodes/=lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/",
            "makina-core/=lib/makina-core/",
            "morpho-blue/=lib/morpho-blue/",
            "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "solidity-utils/=lib/aave-v3-origin/lib/solidity-utils/",
            "wormhole-sdk/=lib/makina-core/lib/wormhole-solidity-sdk/src/",
            "wormhole-solidity-sdk/=lib/makina-core/lib/wormhole-solidity-sdk/src/"
      ]
}
  }
};
