module.exports = {
  solidity: {
    version: "0.8.21",
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
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":morpho-blue/=lib/morpho-blue/",
            ":murky/=lib/universal-rewards-distributor/lib/murky/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":openzeppelin/=lib/universal-rewards-distributor/lib/openzeppelin-contracts/contracts/",
            ":universal-rewards-distributor/=lib/universal-rewards-distributor/src/"
      ]
}
  }
};
