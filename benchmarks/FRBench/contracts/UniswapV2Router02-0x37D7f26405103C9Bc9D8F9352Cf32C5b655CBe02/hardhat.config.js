/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2Router02.sol',
  codeHash:
    '0x90158ab7c5b81d2f86b3f43a7d8449d4dc8811c4ffa2328d1092b64961941139',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.6',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
