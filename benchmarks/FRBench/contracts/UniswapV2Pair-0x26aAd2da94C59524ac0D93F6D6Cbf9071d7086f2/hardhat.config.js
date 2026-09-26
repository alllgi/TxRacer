/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniswapV2Pair.sol',
  codeHash:
    '0x5b83bdbcc56b2e630f2807bbadd2b0c21619108066b92a58de081261089e9ce5',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.16',
    settings: {
      optimizer: { enabled: true, runs: 999999 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
