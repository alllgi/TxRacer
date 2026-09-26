/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/AnimeLoot.sol',
  codeHash:
    '0x5d0dd310237a2185a10ab0fddaa28892fbc9cf717796e5318b8d3347bfc80c09',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.1',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
