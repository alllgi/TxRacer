/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Token.sol',
  codeHash:
    '0x48c057ddd99bbc336483e58516eee09ae8d526ba4b74e4a9c79bfd1c6e99b936',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.0',
    settings: {
      optimizer: { enabled: true, runs: 500 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
