/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2Pair.sol',
  codeHash:
    '0xcd82e2d9daddbf51cbce8d5429a0996e16fc670c4056566f19cf8864ad45a746',
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
