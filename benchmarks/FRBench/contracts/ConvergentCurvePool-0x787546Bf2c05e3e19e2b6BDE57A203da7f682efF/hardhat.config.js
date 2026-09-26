/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/ConvergentCurvePool.sol',
  codeHash:
    '0x08982ab2d1460d16188bef7c9b320eb9f30c9f3710b83477941041e07c3b7aa4',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.1',
    settings: {
      optimizer: { enabled: true, runs: 10000 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
