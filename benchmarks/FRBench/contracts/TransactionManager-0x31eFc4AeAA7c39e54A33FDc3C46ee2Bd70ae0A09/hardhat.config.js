/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/TransactionManager.sol',
  codeHash:
    '0xff81f47c9ff11053e0e8a4339e91ec69df56598eae7d7724be4fd2ae78821d60',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      libraries: {},
      metadata: { bytecodeHash: 'ipfs', useLiteralContent: true },
      optimizer: { enabled: true, runs: 200 },
      remappings: [],
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
