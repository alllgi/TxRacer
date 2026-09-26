/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/SMCSymbolAirdrop.sol',
  codeHash:
    '0xc6c55eabc5e2e74f2ee37dfa5682fe74e64e8e47a6c76982e56231f2964fc3a1',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
