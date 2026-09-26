/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'AggregationRouterV3.sol',
  codeHash:
    '0x876969ec2c7580e2f0b04606736df97d3aa706e537b0fbaf89cede648579cc8d',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
