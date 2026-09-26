/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/ERC20.sol',
  codeHash:
    '0xebc4e928dab5cd1244c60c6e1d05b685e74231df4b0ce774088b4d1226832161',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
