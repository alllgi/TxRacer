/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/smart/LiquidityBootstrappingPool.sol',
  codeHash:
    '0xbc0157c13b4d44445f2592e2c308e3e3b01d5458c5bc33133da0f38cc3089cb2',
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
