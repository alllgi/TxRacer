/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/ConvergentCurvePool.sol',
  codeHash:
    '0xef957cece3ee86b6d3e91e12e74a0938a46ebe7858026a3dd23e6454fa8ba2fc',
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
