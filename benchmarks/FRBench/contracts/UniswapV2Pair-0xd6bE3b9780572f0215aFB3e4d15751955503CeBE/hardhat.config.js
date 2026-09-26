/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2Pair.sol',
  codeHash:
    '0x963a6d4dae7c75c8808c3be4ae81597cd71f70f9263a7ad026587c7fbede1d66',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
