/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BlootGirls.sol',
  codeHash:
    '0x52e34ac5793f99d45608629e8fa5436ca2aa25c439a135593e956233459a3807',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
