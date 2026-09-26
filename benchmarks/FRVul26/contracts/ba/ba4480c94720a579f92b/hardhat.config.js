module.exports = {
  solidity: {
    version: "0.8.26",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "src/utils/Time.sol": {
                  "Time": "0x10edbe32a8767dd345db963a124aee11909a7e2f"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@const/=src/const/",
            ":@core/=src/core/",
            ":@interfaces/=src/interfaces/",
            ":@libs/=src/libs/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@script/=script/",
            ":@uniswap/v2-core/=lib/v2-core/",
            ":@uniswap/v2-periphery/=lib/v2-periphery/",
            ":@uniswap/v3-core/=lib/v3-core/",
            ":@uniswap/v3-periphery/=lib/v3-periphery/",
            ":@utils/=src/utils/",
            ":ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":v3-core/=lib/v3-core/contracts/",
            ":v3-periphery/=lib/v3-periphery/contracts/"
      ]
}
  }
};
