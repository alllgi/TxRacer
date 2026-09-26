/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/UniswapV3Pool.sol',
  codeHash:
    '0xc65918c822e5fe4a822b9f4a005d374438eead22e06b5a256271795aafac28aa',
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
