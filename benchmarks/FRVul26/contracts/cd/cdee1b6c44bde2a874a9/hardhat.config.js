module.exports = {
  solidity: {
    version: "0.8.27",
    settings: {
      "metadata": {
            "bytecodeHash": "ipfs"
      },
      "libraries": {
            "src/utils/Time.sol": {
                  "Time": "0x454de802bd573cc5884b53bcd176ca460bd5c04e"
            }
      },
      "optimizer": {
            "runs": 200,
            "enabled": true
      },
      "evmVersion": "shanghai",
      "remappings": [
            ":@actions/=src/actions/",
            ":@chainlink/=lib/chainlink/",
            ":@const/=src/const/",
            ":@core/=src/",
            ":@interfaces/=src/interfaces/",
            ":@libs/=src/libs/",
            ":@murky/=lib/murky/src/",
            ":@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
            ":@script/=script/",
            ":@uniswap/v2-core/=lib/v2-core/",
            ":@uniswap/v2-periphery/=lib/v2-periphery/",
            ":@uniswap/v3-core/=lib/v3-core/",
            ":@uniswap/v3-periphery/=lib/v3-periphery/",
            ":@utils/=src/utils/",
            ":chainlink/=lib/chainlink/",
            ":ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/",
            ":erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
            ":forge-std/=lib/forge-std/src/",
            ":halmos-cheatcodes/=lib/openzeppelin-contracts/lib/halmos-cheatcodes/src/",
            ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
            ":v3-core/=lib/v3-core/contracts/",
            ":v3-periphery/=lib/v3-periphery/contracts/"
      ]
}
  }
};
