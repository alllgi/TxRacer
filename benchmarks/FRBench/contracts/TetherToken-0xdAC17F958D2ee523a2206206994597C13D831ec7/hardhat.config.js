/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'TetherToken.sol',
  codeHash:
    '0xb44fb4e949d0f78f87f79ee46428f23a2a5713ce6fc6e0beb3dda78c2ac1ea55',
  paths: { sources: 'src' },
  solidity: {
    version: '0.4.18',
    settings: {
      optimizer: { enabled: false, runs: 0 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
