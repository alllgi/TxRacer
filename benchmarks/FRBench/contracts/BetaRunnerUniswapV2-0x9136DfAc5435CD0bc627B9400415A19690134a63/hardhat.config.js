/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BetaRunnerUniswapV2.sol',
  codeHash:
    '0x015a6374393f7566bb9e58a9c2cd446adfa6d735427bd8d4a2b5c14b93e1b3b5',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
