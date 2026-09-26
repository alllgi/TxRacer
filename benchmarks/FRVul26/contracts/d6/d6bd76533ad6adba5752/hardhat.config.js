module.exports = {
  solidity: {
    version: "0.8.25",
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
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
            "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            "ds-test/=lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/",
            "erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "forge-std/=lib/forge-std/src/",
            "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "axelar-gmp-sdk-solidity/=lib/skip-go-evm-contracts/AxelarHandler/lib/axelar-gmp-sdk-solidity/contracts/",
            "skip-go-evm-contracts/=lib/skip-go-evm-contracts/"
      ]
}
  }
};
