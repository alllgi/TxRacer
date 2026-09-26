/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SushiSwapMultiExactSwapper.sol',
  codeHash:
    '0x0d121eefd1126a2c2ceab35e5ad3a0a6ca72793f75c9990cb7b59875b5329ee7',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
