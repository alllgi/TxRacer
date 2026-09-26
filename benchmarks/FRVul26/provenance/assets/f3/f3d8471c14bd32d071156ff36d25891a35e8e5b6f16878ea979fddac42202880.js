module.exports = {
  solidity: {
    version: "0.8.18",
    settings: {
      "viaIR": false,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": false
      },
      "evmVersion": "paris",
      "remappings": [
            "lib/axelar-gmp-sdk-solidity/=lib/axelar-gmp-sdk-solidity/",
            "lib/ds-test/=lib/forge-std/lib/ds-test/src/",
            "lib/erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "lib/forge-std/=lib/forge-std/",
            "lib/openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "lib/openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "lib/openzeppelin/=lib/openzeppelin-contracts-upgradeable/contracts/",
            "axelar-gmp-sdk-solidity/=lib/axelar-gmp-sdk-solidity/contracts/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "forge-std/=lib/forge-std/src/",
            "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "openzeppelin/=lib/openzeppelin-contracts-upgradeable/contracts/"
      ]
}
  }
};
