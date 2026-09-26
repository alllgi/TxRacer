/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/TroveManager.sol',
  codeHash:
    '0x33404f55d90f42f5d4684d3eb52d4afc7ee41fd86f9a0ff9c0afcf0af0a410bb',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.11',
    settings: {
      optimizer: { enabled: true, runs: 100 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
