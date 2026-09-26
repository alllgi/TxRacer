/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'LootPersonality.sol',
  codeHash:
    '0xfc5395f95c72a47060d46957eba6ec863297cd71bac91409c0ba8753030f1983',
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
