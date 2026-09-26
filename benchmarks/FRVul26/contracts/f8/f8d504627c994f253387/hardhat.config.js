module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 20000,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            "openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            "ethereum-vault-connector/=lib/ethereum-vault-connector/src/",
            "evc/=lib/ethereum-vault-connector/src/",
            "evk/=lib/euler-vault-kit/src/",
            "evk-test/=lib/euler-vault-kit/test/",
            "euler-price-oracle/=lib/euler-price-oracle/src/",
            "euler-price-oracle-test/=lib/euler-price-oracle/test/",
            "fee-flow/=lib/fee-flow/src/",
            "reward-streams/=lib/reward-streams/src/",
            "@openzeppelin/contracts/utils/math/=lib/euler-price-oracle/lib/openzeppelin-contracts/contracts/utils/math/",
            "@pyth/=lib/euler-price-oracle/lib/pyth-sdk-solidity/",
            "@redstone/evm-connector/=lib/euler-price-oracle/lib/redstone-oracles-monorepo/packages/evm-connector/contracts/",
            "@solady/=lib/euler-price-oracle/lib/solady/src/",
            "@uniswap/v3-core/=lib/euler-price-oracle/lib/v3-core/",
            "@uniswap/v3-periphery/=lib/euler-price-oracle/lib/v3-periphery/",
            "ds-test/=lib/fee-flow/lib/forge-std/lib/ds-test/src/",
            "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            "euler-vault-kit/=lib/euler-vault-kit/src/",
            "forge-gas-snapshot/=lib/euler-vault-kit/lib/permit2/lib/forge-gas-snapshot/src/",
            "forge-std/=lib/forge-std/src/",
            "halmos-cheatcodes/=lib/openzeppelin-contracts/lib/halmos-cheatcodes/src/",
            "openzeppelin/=lib/ethereum-vault-connector/lib/openzeppelin-contracts/contracts/",
            "permit2/=lib/euler-vault-kit/lib/permit2/",
            "pyth-sdk-solidity/=lib/euler-price-oracle/lib/pyth-sdk-solidity/",
            "redstone-oracles-monorepo/=lib/euler-price-oracle/lib/",
            "solady/=lib/euler-price-oracle/lib/solady/src/",
            "solmate/=lib/fee-flow/lib/solmate/src/",
            "v3-core/=lib/euler-price-oracle/lib/v3-core/contracts/",
            "v3-periphery/=lib/euler-price-oracle/lib/v3-periphery/contracts/"
      ]
}
  }
};
