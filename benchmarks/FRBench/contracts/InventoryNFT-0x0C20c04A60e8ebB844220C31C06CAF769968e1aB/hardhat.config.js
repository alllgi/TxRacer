/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'InventoryNFT.sol',
  codeHash:
    '0x143372c6056b66d9bcdae8979fc5b0ff0ddac54d7db27ff403d5ad19d61f8721',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
