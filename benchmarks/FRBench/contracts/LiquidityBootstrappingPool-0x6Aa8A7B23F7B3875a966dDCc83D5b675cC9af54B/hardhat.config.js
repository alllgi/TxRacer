/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/smart/LiquidityBootstrappingPool.sol',
  codeHash:
    '0x53f2d5c12b42f3cd747548af4e3beccfebd3b5a62007b95d495d625d23e3157e',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.1',
    settings: {
      optimizer: { enabled: true, runs: 9999 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
