/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'WETH9.sol',
  codeHash:
    '0xd0a06b12ac47863b5c7be4185c2deaad1c61557033f56c7d4ea74429cbb25e23',
  paths: { sources: 'src' },
  solidity: {
    version: '0.4.19',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
