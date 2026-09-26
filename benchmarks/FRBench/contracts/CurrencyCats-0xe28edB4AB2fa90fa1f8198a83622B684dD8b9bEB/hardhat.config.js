/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'CurrencyCats.sol',
  codeHash:
    '0xc7c1e2e09e13620cb9c1c8357ebd972e0dfc13b7ff7e95ebd5a8087c4b44c5c4',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
