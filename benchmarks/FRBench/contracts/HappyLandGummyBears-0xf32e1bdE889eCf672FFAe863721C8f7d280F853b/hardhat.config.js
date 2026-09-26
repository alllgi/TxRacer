/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'HappyLandGummyBears.sol',
  codeHash:
    '0x1be14556e713d58e4f9543c0d009da08f42442b027a9fa00f1356375e72da1fb',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.6',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
