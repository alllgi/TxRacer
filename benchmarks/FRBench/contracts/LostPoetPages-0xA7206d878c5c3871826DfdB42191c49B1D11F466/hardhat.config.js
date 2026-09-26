/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/LostPoetPages.sol',
  codeHash:
    '0x74c8643e3a31076846866b151bf852687bf9a8d7d6fdfcb5f961752fb54e2742',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 1000 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
