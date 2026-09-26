/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2Router02.sol',
  codeHash:
    '0x2cd062d965df55b27a1f2d3c926212a046256dfc4191d9c32c82c5efbf3b231f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
