/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'emLoot.sol',
  codeHash:
    '0x7ce368fe3839f3c526ddab438fdf7cf8bed03dc1eb431ff462d41ebd4bab7151',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
