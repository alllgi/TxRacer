/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Root.sol',
  codeHash:
    '0x76bc96a1ca0d82e3b666de5f47e44d87f92ab4b78f6d5a6147a9450336591914',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 2000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
