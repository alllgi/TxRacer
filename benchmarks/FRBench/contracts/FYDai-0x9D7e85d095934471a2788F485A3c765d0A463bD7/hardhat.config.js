/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'FYDai.sol',
  codeHash:
    '0xe18e2e31e3b41c9131551c5e782beb466648a0e8bd858a6f1eb987b3718ef268',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.10',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
