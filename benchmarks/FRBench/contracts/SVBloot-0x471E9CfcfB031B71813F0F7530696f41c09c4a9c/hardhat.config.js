/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SVBloot.sol',
  codeHash:
    '0x44176ff3302425bc3f342e7aeec922550c70d139f960cf74457dd023b105a278',
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
