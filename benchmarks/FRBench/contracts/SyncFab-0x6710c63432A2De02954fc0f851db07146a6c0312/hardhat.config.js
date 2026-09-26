/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SyncFab.sol',
  codeHash:
    '0x2ae9a709deaa4e8afd543f30470756d55358a8821ae244f3ae54c0806f80c33a',
  paths: { sources: 'src' },
  solidity: {
    version: '0.4.15',
    settings: {
      optimizer: { enabled: true, runs: 10000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
