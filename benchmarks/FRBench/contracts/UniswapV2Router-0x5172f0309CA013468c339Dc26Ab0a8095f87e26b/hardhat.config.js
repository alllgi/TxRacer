/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/flattened/UniswapV2Router.sol',
  codeHash:
    '0xf58d46e6493e749b85543e0cc861903d28bd7d3d6b3d58b4a92ad590a78fdc42',
  paths: { sources: 'src' },
  solidity: {
    version: '0.7.5',
    settings: {
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
