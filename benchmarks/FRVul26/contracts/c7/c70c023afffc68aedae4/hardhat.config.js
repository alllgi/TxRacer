module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "viaIR": false,
      "metadata": {
            "bytecodeHash": "ipfs",
            "useLiteralContent": false
      },
      "libraries": {
            "src/vault/libs/Autopool4626.sol": {
                  "Autopool4626": "0x8709b88C5cBCa830d63f726A6f6f8c6573486223"
            },
            "src/vault/libs/AutopoolDebt.sol": {
                  "AutopoolDebt": "0xd18baC6d95119237B225Db48EC29155a8cd08743"
            },
            "src/vault/libs/AutopoolFees.sol": {
                  "AutopoolFees": "0x8BB2b57aB1F110C5720d54e07d87A9f6B40d9FEA"
            },
            "src/strategy/WithdrawalQueue.sol": {
                  "WithdrawalQueue": "0xF19C66cb159246e00B5336B1Ce4B4E8E01e4E4b4"
            },
            "src/strategy/libs/Incentives.sol": {
                  "Incentives": "0x93313cF5189847d35083D20eBac7931039A9a360"
            },
            "src/vault/libs/AutopoolToken.sol": {
                  "AutopoolToken": "0x42699e483C5baA8E9aaD5f7d804127C034A0328F"
            },
            "src/strategy/libs/PriceReturn.sol": {
                  "PriceReturn": "0x247b4d9BCaEF5d2A630a16b981017796Eb87c1Db"
            },
            "src/strategy/libs/SummaryStats.sol": {
                  "SummaryStats": "0xD71Da6caBA81c7d5c3314A72A5387D9a66508A4A"
            },
            "src/strategy/StructuredLinkedList.sol": {
                  "StructuredLinkedList": "0xcd29A689Eb1fd7f333DBe6855dcDd38796f78567"
            },
            "src/vault/libs/AutopoolDestinations.sol": {
                  "AutopoolDestinations": "0xB8028F58e5dE9cB330C544dF41D9681cDf05062e"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            "forge-std/=lib/forge-std/src/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "src/=src/",
            "test/=test/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            "erc4626-tests/=lib/erc4626-tests/",
            "prb-math/=lib/prb-math/",
            "crytic/properties/=lib/properties/",
            "ERC4626/=lib/properties/lib/ERC4626/contracts/",
            "properties/=lib/properties/contracts/",
            "solmate/=lib/properties/lib/solmate/src/",
            "usingtellor/=lib/usingtellor/contracts/"
      ]
}
  }
};
