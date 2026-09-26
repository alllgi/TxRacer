/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/Users/mac/Documents/EthernityV3/Marketplace/contracts/Exchange.sol',
  codeHash:
    '0xa86b429fec27bc91617478fe25a30b5a9d69d3a5a95444c95c5b11c4e56ce4cd',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 200 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
