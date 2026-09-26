module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      "metadata": {
            "bytecodeHash": "none",
            "useLiteralContent": false
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "istanbul",
      "remappings": [
            "aave-address-book/=lib/aave-helpers/lib/aave-address-book/src/",
            "aave-helpers/=lib/aave-helpers/",
            "forge-std/=lib/aave-helpers/lib/forge-std/src/",
            "openzeppelin-contracts-upgradeable/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            "solidity-utils/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/src/",
            "aave-v3-origin/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/src/",
            "@openzeppelin/contracts-upgradeable/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/",
            "@openzeppelin/contracts/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            "aave-v3-origin-tests/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/tests/",
            "ds-test/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/forge-std/lib/ds-test/src/",
            "erc4626-tests/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "halmos-cheatcodes/=lib/aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/"
      ]
}
  }
};
