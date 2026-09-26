/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'extensionLoot.sol',
  codeHash:
    '0xb18854fa18eace63b8c47fcb2f7fc136c59c75f856b5e30789e922daeec070be',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
