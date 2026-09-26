/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV3Router.sol',
  codeHash:
    '0x0bf0f76ac7b98ada5e46ffb7e0caf1c57bafd4ed9d0740ecd436312c6ffabc62',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.5',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
