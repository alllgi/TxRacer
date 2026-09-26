module.exports = {
  solidity: {
    version: "0.8.23",
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
            ":@openzeppelin/contracts/=lib/ERC1155A/lib/openzeppelin-contracts/contracts/",
            ":ERC1155A/=lib/ERC1155A/src/",
            ":ds-test/=lib/ds-test/src/",
            ":erc4626-tests/=lib/ERC1155A/lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/ERC1155A/lib/openzeppelin-contracts/",
            ":pigeon/=lib/pigeon/src/",
            ":solady/=lib/pigeon/lib/solady/",
            ":solmate/=lib/ERC1155A/lib/solmate/src/",
            ":super-vaults/=lib/super-vaults/src/",
            ":v2-core/=lib/super-vaults/lib/v2-core/contracts/",
            ":v2-periphery/=lib/super-vaults/lib/v2-periphery/contracts/",
            ":v3-core/=lib/super-vaults/lib/v3-core/"
      ]
}
  }
};
