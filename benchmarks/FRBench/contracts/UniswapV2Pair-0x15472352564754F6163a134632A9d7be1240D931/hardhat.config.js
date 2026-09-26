/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2Pair.sol',
  codeHash:
    '0x991fa9c47ce1eb1388216b5f888ca502dea3d39943ada97609d6857f0507e3b5',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.16',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
