/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SumswapV2Pair.sol',
  codeHash:
    '0x25e66bfc53de78b66671124268ff36ff22ff088a7e6067f9361f237300391e69',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      evmVersion: 'byzantium',
      outputSelection: { '*': { '*': ['*'] } },
    },
  },
};
