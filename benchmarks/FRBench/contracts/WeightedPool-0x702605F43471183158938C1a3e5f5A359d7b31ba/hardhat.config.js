/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/pools/weighted/WeightedPool.sol',
  codeHash:
    '0x58e379ee544ed09412ddad6eb94f09a74a5b26425bb7cf770dbe8f2380f88afa',
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
