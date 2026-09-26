/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UnicSwapV2Pair.sol',
  codeHash:
    '0x3b2ec29d98e7b542492edb246ccbc7405b69736f3be7d7864d8df9ccc1d3e095',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 999999 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
