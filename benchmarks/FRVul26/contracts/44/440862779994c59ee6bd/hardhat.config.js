module.exports = {
  solidity: {
    version: "0.8.25",
    settings: {
      "viaIR": true,
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
      "evmVersion": "cancun",
      "remappings": [
            "@openzeppelin/=lib/openzeppelin-contracts/contracts/",
            "account-abstraction/=lib/account-abstraction/contracts/",
            "solady/=lib/solady/",
            "smart-wallet/=lib/smart-wallet/",
            "magic-spend/=lib/magic-spend/",
            "multicaller/=lib/Multicaller/",
            "v2-core/=lib/v2-core/",
            "v2-periphery/=lib/v2-periphery/",
            "tstorish/=lib/tstorish/",
            "permit2-relay/=lib/permit2-relay/",
            "solmate/=lib/solmate/",
            "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            "@openzeppelin/contracts/security/=lib/magic-spend/lib/openzeppelin-contracts/contracts/utils/",
            "FreshCryptoLib/=lib/smart-wallet/lib/FreshCryptoLib/solidity/src/",
            "Multicaller/=lib/Multicaller/src/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            "forge-gas-snapshot/=lib/permit2-relay/lib/forge-gas-snapshot/src/",
            "forge-std/=lib/forge-std/src/",
            "fuzzlib/=lib/magic-spend/lib/fuzzlib/src/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "p256-verifier/=lib/smart-wallet/lib/p256-verifier/",
            "safe-singleton-deployer-sol/=lib/smart-wallet/lib/safe-singleton-deployer-sol/",
            "webauthn-sol/=lib/smart-wallet/lib/webauthn-sol/src/"
      ]
}
  }
};
