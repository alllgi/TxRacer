module.exports = {
  solidity: {
    version: "0.8.22",
    settings: {
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
            ":@layerzerolabs/=node_modules/@layerzerolabs/",
            ":@openzeppelin/=node_modules/@openzeppelin/",
            ":@sphinx-labs/contracts/=lib/sphinx/packages/contracts/contracts/foundry/",
            ":ds-test/=lib/forge-std/lib/ds-test/src/",
            ":forge-std/=lib/forge-std/src/",
            ":sphinx/=lib/sphinx/"
      ]
}
  }
};
