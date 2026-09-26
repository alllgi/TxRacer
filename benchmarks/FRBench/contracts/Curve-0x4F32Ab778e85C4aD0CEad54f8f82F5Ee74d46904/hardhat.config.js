/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Curve.sol',
  codeHash:
    '0x65457284ebae5b2231cdd6def618c894f11f6ffead5fca55b85ab4228043b5e3',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.0',
    settings: {
      optimizer: { enabled: true, runs: 500 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
