/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/SpaceLoot.sol',
  codeHash:
    '0xf54c239602270c3e1debeb20ed2a2d6c40755e1d7cd4fb2ca98a9bb8c2a0330f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
