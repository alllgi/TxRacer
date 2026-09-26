/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Peggy.sol',
  codeHash:
    '0x805054caac3240b6ea46ed7fe2aa99c7dc0ec8a3ac755d25c3f9a597b04c7bb1',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.2',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
