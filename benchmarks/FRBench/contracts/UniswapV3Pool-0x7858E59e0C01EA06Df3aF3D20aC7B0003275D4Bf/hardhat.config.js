/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/UniswapV3Pool.sol',
  codeHash:
    '0x0bbc691b71e4434c4d88d1d77323898403fa654b50ca49ad39a5000c2deac968',
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
