/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'RedPanda.sol',
  codeHash:
    '0x54d62707515ffe2fdfb074e2b2d5523a2abdb2e71e3c354a6067e0d0b82fd433',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
