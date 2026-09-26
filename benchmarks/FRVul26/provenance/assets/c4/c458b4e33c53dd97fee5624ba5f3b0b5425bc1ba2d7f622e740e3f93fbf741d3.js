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
      "libraries": {
            "lib/aave-v3-origin-private/src/contracts/instances/PoolInstance.sol": {
                  "PoolLogic": "0xd70593841c57cbaa04957cc3eace95708e48853b",
                  "BorrowLogic": "0x52da0ce88202d1542543598d1e1e27f0d344726a",
                  "SupplyLogic": "0x584c7d8c4cb05304fe5ac7fbc97f20a10fb07564",
                  "FlashLoanLogic": "0x6d414cd0d5eaf8c43200ac0c325a7e2ad83b8be6",
                  "LiquidationLogic": "0x96d5686812e33ab509eccdb38c89d15607b2a413"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "cancun",
      "remappings": [
            "aave-address-book/=lib/aave-helpers/lib/aave-address-book/src/",
            "aave-helpers/=lib/aave-helpers/",
            "aave-v3-origin-tests/=lib/aave-v3-origin-private/tests/",
            "aave-v3-origin/=lib/aave-v3-origin-private/src/",
            "erc4626-tests/=lib/aave-helpers/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "forge-std/=lib/aave-helpers/lib/forge-std/src/",
            "openzeppelin-contracts-upgradeable/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            "solidity-utils/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/src/",
            "lib/aave-helpers/:aave-address-book/=lib/aave-helpers/lib/aave-address-book/src/",
            "lib/aave-helpers/:solidity-utils/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/src/",
            "@openzeppelin/contracts-upgradeable/=lib/aave-v3-origin-private/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/",
            "@openzeppelin/contracts/=lib/aave-v3-origin-private/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            "aave-v3-origin-private/=lib/aave-v3-origin-private/",
            "ds-test/=lib/aave-v3-origin-private/lib/forge-std/lib/ds-test/src/",
            "halmos-cheatcodes/=lib/aave-v3-origin-private/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/"
      ]
}
  }
};
