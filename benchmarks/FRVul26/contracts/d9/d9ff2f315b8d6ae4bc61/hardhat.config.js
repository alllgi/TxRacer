module.exports = {
  solidity: {
    version: "0.8.22",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "none"
      },
      "libraries": {},
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@create3/=lib/create3-factory/src/",
            ":@openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@prb/test/=lib/prb-test/src/",
            ":@solady/=lib/solady/src/",
            ":create3-factory/=lib/create3-factory/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":foundry-huff/=lib/foundry-huff/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":prb-test/=lib/prb-test/src/",
            ":solady/=lib/solady/",
            ":solidity-bytes-utils/=lib/solidity-bytes-utils/contracts/",
            ":solidity-stringutils/=lib/foundry-huff/lib/solidity-stringutils/",
            ":solmate/=lib/create3-factory/lib/solmate/src/",
            ":stringutils/=lib/foundry-huff/lib/solidity-stringutils/"
      ]
}
  }
};
