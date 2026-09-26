/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'sand.sol',
  codeHash:
    '0x16f860bfa2bc6bf7544b724ec869c0ec3bad0f603d786524d4e2ee63a9e84e7f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
