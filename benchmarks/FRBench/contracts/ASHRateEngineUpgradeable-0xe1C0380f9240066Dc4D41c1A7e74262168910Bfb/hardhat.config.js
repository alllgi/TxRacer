/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/rates/ASHRateEngineUpgradeable.sol',
  codeHash:
    '0x477072637f573c63ba87e37b48bfcb3f6d3f8e1497442cd3db677737932d507c',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.3',
    settings: {
      optimizer: { enabled: true, runs: 1000 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
