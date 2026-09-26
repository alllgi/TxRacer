/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Oracle.sol',
  codeHash:
    '0x252865a297bb9bd871024a1c4317c5be6c7ae5f3f50a2634cb02aa7c6f70b0ae',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.3',
    settings: {
      optimizer: { enabled: true, runs: 300 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
