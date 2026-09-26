module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "src/vault/libs/Autopool4626.sol": {
                  "Autopool4626": "0x8709b88c5cbca830d63f726a6f6f8c6573486223"
            },
            "src/vault/libs/AutopoolDebt.sol": {
                  "AutopoolDebt": "0xd18bac6d95119237b225db48ec29155a8cd08743"
            },
            "src/vault/libs/AutopoolFees.sol": {
                  "AutopoolFees": "0x8bb2b57ab1f110c5720d54e07d87a9f6b40d9fea"
            },
            "src/strategy/WithdrawalQueue.sol": {
                  "WithdrawalQueue": "0xf19c66cb159246e00b5336b1ce4b4e8e01e4e4b4"
            },
            "src/strategy/libs/Incentives.sol": {
                  "Incentives": "0x93313cf5189847d35083d20ebac7931039a9a360"
            },
            "src/vault/libs/AutopoolToken.sol": {
                  "AutopoolToken": "0x42699e483c5baa8e9aad5f7d804127c034a0328f"
            },
            "src/strategy/libs/PriceReturn.sol": {
                  "PriceReturn": "0x247b4d9bcaef5d2a630a16b981017796eb87c1db"
            },
            "src/strategy/libs/SummaryStats.sol": {
                  "SummaryStats": "0xd71da6caba81c7d5c3314a72a5387d9a66508a4a"
            },
            "src/strategy/StructuredLinkedList.sol": {
                  "StructuredLinkedList": "0xcd29a689eb1fd7f333dbe6855dcdd38796f78567"
            },
            "src/vault/libs/AutopoolDestinations.sol": {
                  "AutopoolDestinations": "0xb8028f58e5de9cb330c544df41d9681cdf05062e"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "london",
      "remappings": [
            ":ERC4626/=lib/properties/lib/ERC4626/contracts/",
            ":crytic/properties/=lib/properties/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",
            ":prb-math/=lib/prb-math/",
            ":properties/=lib/properties/contracts/",
            ":solmate/=lib/properties/lib/solmate/src/",
            ":src/=src/",
            ":test/=test/",
            ":usingtellor/=lib/usingtellor/contracts/"
      ]
}
  }
};
