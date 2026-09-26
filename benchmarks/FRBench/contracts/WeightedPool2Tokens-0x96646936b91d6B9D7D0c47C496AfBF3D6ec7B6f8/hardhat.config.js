/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/pools/weighted/WeightedPool2Tokens.sol',
  codeHash:
    '0x8a0c9548889fb5a972be40410a00244aacf21ea708960eba7ecae3de999c7d65',
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
