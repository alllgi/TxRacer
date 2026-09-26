/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'pLoot.sol',
  codeHash:
    '0x5c676cdc3fb19aeb8adf246b4a4a63c723997e6fa6741015ecf8be88d35eef4d',
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
