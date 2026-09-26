/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'EtherOrcs.sol',
  codeHash:
    '0x1d799b3434a40260aff4b5230a7d608c51467e58ab54c30996b29b70bd3beb9a',
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
