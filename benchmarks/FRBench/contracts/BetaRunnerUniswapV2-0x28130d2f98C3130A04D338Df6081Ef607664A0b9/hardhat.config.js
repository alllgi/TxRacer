/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BetaRunnerUniswapV2.sol',
  codeHash:
    '0x81789ba8258414f701cc2c3796b53245dd2ecd93e5ae726fa5cc88eabb618d31',
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
