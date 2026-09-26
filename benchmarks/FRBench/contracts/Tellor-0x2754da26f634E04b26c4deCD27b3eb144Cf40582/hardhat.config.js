/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Tellor.sol',
  codeHash:
    '0x9136caa1ae3b3348021cec23a142e358a949b64737bb219f5d0965a6b29ba01e',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.4',
    settings: {
      optimizer: { enabled: true, runs: 300 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
