/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'LootResources.sol',
  codeHash:
    '0x1aab8f131fc02df4f9688191bf6860a22c4e4e8a7c36cf6232fc3299f738c1fa',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
