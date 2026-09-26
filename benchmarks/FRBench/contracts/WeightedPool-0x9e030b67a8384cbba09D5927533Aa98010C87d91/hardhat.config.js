/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/pools/weighted/WeightedPool.sol',
  codeHash:
    '0x1a6f1c8f5f47204922c70641222a6795edd30439bdbe7c9c34b1fc5e17c174d5',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.1',
    settings: {
      optimizer: { enabled: true, runs: 800 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
