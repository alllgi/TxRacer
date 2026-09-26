/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Lore.sol',
  codeHash:
    '0xef3aeecce7316d94476af8e7a6151df5a8c069ab5dfee9fabd49478617f4ee71',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
