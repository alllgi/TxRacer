/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UnicSwapV2Router02.sol',
  codeHash:
    '0x1332f7ccb64969417e76b617d4a974e9abd44d12580626171021ef2d2336a282',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 999999 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
