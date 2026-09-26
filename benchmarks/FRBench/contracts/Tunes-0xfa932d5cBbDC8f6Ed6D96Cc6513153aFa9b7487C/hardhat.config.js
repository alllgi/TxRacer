/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Tunes.sol',
  codeHash:
    '0xbb3afe8a3538f3c168445a887b6ae0f683cfe38349cbc867cf64329ec7a8edab',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.2',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
