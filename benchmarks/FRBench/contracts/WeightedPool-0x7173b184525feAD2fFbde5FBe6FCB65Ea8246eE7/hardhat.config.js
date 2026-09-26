/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/pools/weighted/WeightedPool.sol',
  codeHash:
    '0xed4b9346017a8694c59de88671ba59a36ff34296f53576b7417a836ce7ab0cdc',
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
