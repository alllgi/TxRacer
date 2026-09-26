/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'DMMPool.sol',
  codeHash:
    '0xa36cacf67b551ed3dbe1dea7ccd4039067ff339efff8c23d8f22bcd62215b000',
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
