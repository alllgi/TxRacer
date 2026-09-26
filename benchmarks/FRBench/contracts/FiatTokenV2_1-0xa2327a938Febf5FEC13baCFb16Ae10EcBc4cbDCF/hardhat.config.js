/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'FiatTokenV2_1.sol',
  codeHash:
    '0x10d68f9bb2ba9f5e9163cadc4a3446be0c6b2ab8b1b65079e79dcd94a6dc329c',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 10000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
