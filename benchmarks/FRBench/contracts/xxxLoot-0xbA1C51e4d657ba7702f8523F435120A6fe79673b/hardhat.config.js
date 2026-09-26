/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'xxxLoot.sol',
  codeHash:
    '0x24aaeb6e3e7a3474086ba2c274487828b0e10398ac56ccc962fc50360f9af5a8',
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
