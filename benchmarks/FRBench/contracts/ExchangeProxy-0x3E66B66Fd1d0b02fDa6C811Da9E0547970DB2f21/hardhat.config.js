/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'ExchangeProxy.sol',
  codeHash:
    '0x2e4a02217f0ea3f22bd1d54f9e83c492c1862df5a0a630decf906b1fbcec21de',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
