module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "none",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            "aave-v3-core/=src/core/",
            "aave-v3-periphery/=src/periphery/",
            "solidity-utils/=lib/solidity-utils/src/",
            "forge-std/=lib/forge-std/src/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "openzeppelin-contracts-upgradeable/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            "@openzeppelin/contracts-upgradeable/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/",
            "@openzeppelin/contracts/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            "erc4626-tests/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/"
      ]
}
  }
};
