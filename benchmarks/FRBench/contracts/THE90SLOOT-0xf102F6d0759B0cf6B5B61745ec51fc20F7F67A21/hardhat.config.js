/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'THE90SLOOT.sol',
  codeHash:
    '0xfa0d4ea65b5ec496e6e31926975ae426ba4c7fb011bbdd747646209616495214',
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
