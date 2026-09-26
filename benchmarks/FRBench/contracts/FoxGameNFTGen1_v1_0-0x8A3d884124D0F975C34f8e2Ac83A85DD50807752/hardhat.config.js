/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/FoxGameNFTGen1_v1_0.sol',
  codeHash:
    '0x929cfc3f37550443dfda8ed0ecf3532de3002af9eaed35e14b49bff77d215dd7',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.10',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
