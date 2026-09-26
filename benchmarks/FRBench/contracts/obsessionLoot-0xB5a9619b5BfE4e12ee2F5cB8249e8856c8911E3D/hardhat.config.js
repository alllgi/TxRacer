/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'obsessionLoot.sol',
  codeHash:
    '0x696f2e82ce404e71406973efd1caf31402b4f63117c06b23453cfa2e2af5fdd8',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.5',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
