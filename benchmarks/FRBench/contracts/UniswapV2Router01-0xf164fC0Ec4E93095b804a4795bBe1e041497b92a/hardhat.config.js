/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2Router01.sol',
  codeHash:
    '0x26a531b690d2a1ed10ca775554e708ec9f162ce9b40b545b630d6ef40352fe59',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.6',
    settings: {
      optimizer: { enabled: true, runs: 999999 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
