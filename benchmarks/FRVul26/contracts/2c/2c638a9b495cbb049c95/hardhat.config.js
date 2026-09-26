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
            "src/contracts/protocol/libraries/logic/FlashLoanLogic.sol": {
                  "BorrowLogic": "0x1fb8f7c906cddd28b42ae6eb76abc04a91188635"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            "solidity-utils/=lib/solidity-utils/src/",
            "forge-std/=lib/forge-std/src/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "openzeppelin-contracts-upgradeable/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/",
            "openzeppelin-contracts/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
            "@openzeppelin/contracts-upgradeable/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/",
            "@openzeppelin/contracts/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
            "erc4626-tests/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
            "halmos-cheatcodes/=lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/halmos-cheatcodes/src/"
      ]
}
  }
};
