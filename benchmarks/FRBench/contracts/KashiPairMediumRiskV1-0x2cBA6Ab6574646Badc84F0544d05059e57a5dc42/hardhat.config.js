/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'KashiPairMediumRiskV1.sol',
  codeHash:
    '0x435e998e34fed9340e7a0d9f5c4dc6ca3dbff5d997b559db350e5da4c1e85a5b',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 350 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
