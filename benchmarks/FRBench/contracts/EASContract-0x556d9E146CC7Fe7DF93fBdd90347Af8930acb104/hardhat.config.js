/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'EASContract.sol',
  codeHash:
    '0x410c5aed34019cd44c1a55dd4317b6f23daf0ff51745f8d18ae57e1dd9d4c727',
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
