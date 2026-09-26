/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/ClipperExchangeInterface.sol',
  codeHash:
    '0xdd53bfda3faf71616e2e7043e559fb6cf7240be7c3d28d60dd4aaef1db3ee7d2',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.5',
    settings: {
      optimizer: { enabled: true, runs: 10000 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
