/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/farm/facets/SeasonFacet/SeasonFacet.sol',
  codeHash:
    '0x6689a017cd940faaceda0fee30b982fa00250b26b6330cfa3b7a7486b5882de5',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.6',
    settings: {
      optimizer: { enabled: true, runs: 1000 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
