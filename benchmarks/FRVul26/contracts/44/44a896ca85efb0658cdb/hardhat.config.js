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
            "lib/aave-v3-origin/src/contracts/instances/PoolInstance.sol": {
                  "PoolLogic": "0x25ed699a052b820d772765e26ed4dd9f0a26f3e5",
                  "BorrowLogic": "0x1fb8f7c906cddd28b42ae6eb76abc04a91188635",
                  "SupplyLogic": "0x33654b16a4de97bce05d7dd06803bf1066f3123c",
                  "FlashLoanLogic": "0xe66adcf153d0bd67a74e5d23e23f90b4011024ec",
                  "LiquidationLogic": "0x8dc095f287dbebd9e15f75bb3dfbf18389bb8104"
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
            "aave-v3-origin-tests/=lib/aave-v3-origin/tests/",
            "aave-v3-origin/=lib/aave-v3-origin/src/",
            "erc4626-tests/=lib/aave-helpers/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "forge-std/=lib/forge-std/src/",
            "openzeppelin-contracts-upgradeable/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            "solidity-utils/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/src/",
            "lib/aave-helpers/:aave-address-book/=lib/aave-helpers/lib/aave-address-book/src/",
            "lib/aave-helpers/:solidity-utils/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/src/",
            "@openzeppelin/contracts-upgradeable/=lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/",
            "@openzeppelin/contracts/=lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            "ds-test/=lib/aave-v3-origin/lib/forge-std/lib/ds-test/src/",
            "halmos-cheatcodes/=lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/"
      ]
}
  }
};
