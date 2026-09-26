/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/ClipperPool.sol',
  codeHash:
    '0x902777da82fe9c596c5068cb3a13e9e53243d98ec909115c8c9fbe31fcc92a07',
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
