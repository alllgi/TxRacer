/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapRepayAdapter.sol',
  codeHash:
    '0xe27bb38b5aa4e4fd00cc78938f0883521ea3e8b5a9e120129fb9b865ee619d87',
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
