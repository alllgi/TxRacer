/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SakeSwapPair.sol',
  codeHash:
    '0x7e7907605e4c2a33f9688a9e6757bef447af6b66d2da0cb94d44730242f304c8',
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
