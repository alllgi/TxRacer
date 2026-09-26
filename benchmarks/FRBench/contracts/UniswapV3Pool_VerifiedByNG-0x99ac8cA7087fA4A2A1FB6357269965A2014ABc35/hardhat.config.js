/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/UniswapV3Pool_VerifiedByNG.sol',
  codeHash:
    '0x05a61f398aa6975df5ff334201bf14fd9833804d5ac23813b83500e493c85e6c',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.6',
    settings: {
      optimizer: { enabled: true, runs: 800 },
      metadata: { bytecodeHash: 'none' },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
