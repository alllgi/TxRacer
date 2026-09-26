/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/flattened/Adapter01.sol',
  codeHash:
    '0x999e0819676150e6d32e77ae75eea97a4adeff8af540f5347ce080bf686e3054',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.5',
    settings: {
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
