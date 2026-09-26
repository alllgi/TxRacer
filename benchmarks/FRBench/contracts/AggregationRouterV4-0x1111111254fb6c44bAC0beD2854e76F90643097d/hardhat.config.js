/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'AggregationRouterV4.sol',
  codeHash:
    '0x8a2c3f4d171bbc34e3fa0c4b59b8d87b16c034f06f4764c268dffa3c1e763c35',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.6',
    settings: {
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
