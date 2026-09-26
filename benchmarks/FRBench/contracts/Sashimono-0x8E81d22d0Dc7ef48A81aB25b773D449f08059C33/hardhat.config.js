/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Sashimono.sol',
  codeHash:
    '0xe4d25af92823a5208223d869b3bd254bb0f725d40a3329f25bda13e2fa69522e',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
