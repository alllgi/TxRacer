/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/pools/weighted/WeightedPool2Tokens.sol',
  codeHash:
    '0x6d32d3364ff57d2ca8df7606853972bfd2625e0ba54544c4f45bc2a33a3305a9',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.1',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
