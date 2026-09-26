module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      "viaIR": true,
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {},
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "paris",
      "remappings": [
            ":@openzeppelin/=lib/openzeppelin-contracts/contracts/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":solady/=lib/solady/src/"
      ]
}
  }
};
