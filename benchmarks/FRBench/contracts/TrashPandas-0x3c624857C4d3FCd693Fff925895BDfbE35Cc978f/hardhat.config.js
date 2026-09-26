/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/TrashPandas.sol',
  codeHash:
    '0x2b3181fc9c029dc8ba3c5f8fa3ca85c3fc44a602ae9a1fc5f0acda381023fe19',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
