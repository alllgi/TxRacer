/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Bloot.sol',
  codeHash:
    '0x4e49f73e38dcc8f8580dbaa2fbf91ee96f90b0a4b0e24508cb399b40203de53d',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
