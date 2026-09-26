module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
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
