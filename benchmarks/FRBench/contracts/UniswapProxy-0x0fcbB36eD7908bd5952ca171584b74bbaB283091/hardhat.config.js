/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapProxy.sol',
  codeHash:
    '0x3f74c90b7f07f2039fba3a767b55b29afa6cc544e0a4acb307f9a7de9a9ac1d3',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.5',
    settings: {
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
