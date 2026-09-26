/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/IndexedNarwhalRouter.sol',
  codeHash:
    '0xc1412d38e3c440efd9d56610c16bc275e15abed3bb5a7465f106fa0f3892b565',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.6',
    settings: {
      libraries: {},
      metadata: { bytecodeHash: 'none', useLiteralContent: true },
      optimizer: { enabled: true, runs: 800 },
      remappings: [],
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
