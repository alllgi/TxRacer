module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 20000,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            ":@openzeppelin-upgradeable/=lib/euler-earn/lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@pendle/core-v2/=lib/euler-price-oracle/lib/pendle-core-v2-public/contracts/",
            ":@pyth/=lib/euler-price-oracle/lib/pyth-sdk-solidity/",
            ":@redstone/evm-connector/=lib/euler-price-oracle/lib/redstone-oracles-monorepo/packages/evm-connector/contracts/",
            ":@solady/=lib/euler-price-oracle/lib/solady/src/",
            ":@uniswap/v3-core/=lib/euler-price-oracle/lib/v3-core/",
            ":@uniswap/v3-periphery/=lib/euler-price-oracle/lib/v3-periphery/",
            ":ERC4626/=lib/euler-earn/lib/properties/lib/ERC4626/contracts/",
            ":crytic-properties/=lib/euler-earn/lib/properties/contracts/",
            ":ds-test/=lib/fee-flow/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            ":ethereum-vault-connector/=lib/ethereum-vault-connector/src/",
            ":euler-earn/=lib/euler-earn/src/",
            ":euler-price-oracle-test/=lib/euler-price-oracle/test/",
            ":euler-price-oracle/=lib/euler-price-oracle/src/",
            ":euler-vault-kit/=lib/euler-vault-kit/src/",
            ":evc/=lib/ethereum-vault-connector/src/",
            ":evk-test/=lib/euler-vault-kit/test/",
            ":evk/=lib/euler-vault-kit/src/",
            ":fee-flow/=lib/fee-flow/src/",
            ":forge-gas-snapshot/=lib/euler-vault-kit/lib/permit2/lib/forge-gas-snapshot/src/",
            ":forge-std/=lib/forge-std/src/",
            ":halmos-cheatcodes/=lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/",
            ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            ":openzeppelin/=lib/ethereum-vault-connector/lib/openzeppelin-contracts/contracts/",
            ":pendle-core-v2-public/=lib/euler-price-oracle/lib/pendle-core-v2-public/contracts/",
            ":permit2/=lib/euler-vault-kit/lib/permit2/",
            ":properties/=lib/euler-earn/lib/properties/contracts/",
            ":pyth-sdk-solidity/=lib/euler-price-oracle/lib/pyth-sdk-solidity/",
            ":redstone-oracles-monorepo/=lib/euler-price-oracle/lib/",
            ":reward-streams/=lib/reward-streams/src/",
            ":solady/=lib/euler-price-oracle/lib/solady/src/",
            ":solmate/=lib/fee-flow/lib/solmate/src/",
            ":v3-core/=lib/euler-price-oracle/lib/v3-core/contracts/",
            ":v3-periphery/=lib/euler-price-oracle/lib/v3-periphery/contracts/",
            "lib/euler-price-oracle:@openzeppelin/contracts/=lib/euler-price-oracle/lib/openzeppelin-contracts/contracts/"
      ]
}
  }
};
