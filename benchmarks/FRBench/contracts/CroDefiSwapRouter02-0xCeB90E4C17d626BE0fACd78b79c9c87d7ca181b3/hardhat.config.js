/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'CroDefiSwapRouter02.sol',
  codeHash:
    '0x289af9e83fe67ca4d2bc782cfe58f01fbab148c1902ddc44859deb63a9f0d4c7',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.6',
    settings: {
      optimizer: { enabled: true, runs: 999999 },
      evmVersion: 'byzantium',
      outputSelection: { '*': { '*': ['*'] } },
    },
  },
};
