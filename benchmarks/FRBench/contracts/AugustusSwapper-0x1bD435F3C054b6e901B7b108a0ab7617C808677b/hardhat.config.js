/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'AugustusSwapper.sol',
  codeHash:
    '0xb5325810a59d6cf15fb35b013321455bb97462b465ce96dffb513ff9987688d6',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.5',
    settings: {
      optimizer: { enabled: true, runs: 25000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
