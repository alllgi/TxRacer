/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BancorNetwork.sol',
  codeHash:
    '0x577f090b414d0069b084a86535a46c4937cab4143c64ab9efd6c7fed8c1e7954',
  paths: { sources: 'src' },
  solidity: {
    version: '0.4.26',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
