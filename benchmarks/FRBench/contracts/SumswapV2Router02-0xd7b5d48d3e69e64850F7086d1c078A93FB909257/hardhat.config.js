/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SumswapV2Router02.sol',
  codeHash:
    '0x9ee610d56338e73277f5e47daabf73549d16a78149d936a5629d839afdeebf25',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      evmVersion: 'byzantium',
      outputSelection: { '*': { '*': ['*'] } },
    },
  },
};
