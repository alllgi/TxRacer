/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'EToken2.sol',
  codeHash:
    '0x378e9a30a45c1b5d76b93666e82968e22082d58cfd39925f5faafd2f7583ee2e',
  paths: { sources: 'src' },
  solidity: {
    version: '0.4.8',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
    },
  },
};
