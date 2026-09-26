/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/AMMWrapperWithPath.sol',
  codeHash:
    '0xbb03e70b3d65b0a2f8f10aade7c5b0970a0319aec1b408b015d4ba5aaa8a47d3',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 1000 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
