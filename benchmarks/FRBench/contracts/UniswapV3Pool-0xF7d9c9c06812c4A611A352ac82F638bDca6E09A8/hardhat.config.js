/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/UniswapV3Pool.sol',
  codeHash:
    '0x0de114a1914ab4498cf563147824229c728722d57eb5a3d3cbd61379d2eee841',
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
