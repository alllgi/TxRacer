/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/UniswapV3Pool.sol',
  codeHash:
    '0xe0c3aa2cf8deaec39661ac0c4ff4dd11f785930ab5b8e4c5276555f6151e125f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.6',
    settings: {
      optimizer: { enabled: true, runs: 800 },
      metadata: { bytecodeHash: 'none' },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
