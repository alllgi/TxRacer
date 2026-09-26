/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2Router02.sol',
  codeHash:
    '0xa324bc7db3d091b6f1a2d526e48a9c7039e03b3cc35f7d44b15ac7a1544c11d2',
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
