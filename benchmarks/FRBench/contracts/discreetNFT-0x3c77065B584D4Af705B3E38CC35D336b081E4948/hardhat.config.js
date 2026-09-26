/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'discreetNFT.sol',
  codeHash:
    '0x69e3404eed158dfd8af38a296c410032938321a99beb63fdadb20706ab0e7945',
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
