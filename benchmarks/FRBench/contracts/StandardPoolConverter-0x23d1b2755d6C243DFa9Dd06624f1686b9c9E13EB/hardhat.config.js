/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'StandardPoolConverter.sol',
  codeHash:
    '0x1dc38c50a62d2f9588abbc9bd2889b784365a06566432e4adc305fed6a49f7b4',
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
