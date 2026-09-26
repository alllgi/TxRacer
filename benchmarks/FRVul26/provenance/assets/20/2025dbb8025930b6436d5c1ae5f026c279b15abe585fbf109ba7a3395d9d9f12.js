module.exports = {
  solidity: {
    version: "0.8.22",
    settings: {
      "viaIR": true,
      "metadata": {
            "appendCBOR": true,
            "bytecodeHash": "none",
            "useLiteralContent": false
      },
      "optimizer": {
            "runs": 1000000,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            "@prb/test/=lib/prb-test/src/",
            "forge-std/=lib/forge-std/src/",
            "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            "@openzeppelin/token/=lib/openzeppelin-contracts/contracts/token/",
            "@openzeppelin/utils/=lib/openzeppelin-contracts/contracts/utils/",
            "@openzeppelin/access/=lib/openzeppelin-contracts/contracts/access/",
            "@openzeppelin/interfaces/=lib/openzeppelin-contracts/contracts/interfaces/",
            "@openzeppelin/=lib/openzeppelin-contracts/contracts/",
            "@solady/=lib/solady/src/",
            "@create3/=lib/create3-factory/src/",
            "create3-factory/=lib/create3-factory/",
            "ds-test/=lib/forge-std/lib/ds-test/src/",
            "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            "halmos-cheatcodes/=lib/openzeppelin-contracts/lib/halmos-cheatcodes/src/",
            "openzeppelin-contracts/=lib/openzeppelin-contracts/",
            "prb-test/=lib/prb-test/src/",
            "solady/=lib/solady/",
            "solmate/=lib/create3-factory/lib/solmate/src/"
      ]
}
  }
};
