/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'TFC.sol',
  codeHash:
    '0x79383b763a9908028959f7e469aa861a1595cac5e7c0f5ab7093dcf19313d0d5',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
