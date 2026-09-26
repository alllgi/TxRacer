/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/DrawAbstract.sol',
  codeHash:
    '0xd616f1bfd690a67bd580d24d4f3bc92a93e51899f588c53cd4ce0ca03bc96d65',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.2',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
