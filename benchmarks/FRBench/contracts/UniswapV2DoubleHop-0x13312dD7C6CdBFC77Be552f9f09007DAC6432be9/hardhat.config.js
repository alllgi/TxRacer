/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2DoubleHop.sol',
  codeHash:
    '0x2835195d623dab7b46659be23003fb4b60ea3a9a56546ed040d3d046c82fc234',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.15',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
