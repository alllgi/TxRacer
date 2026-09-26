/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'MemeNumbers.sol',
  codeHash:
    '0x581765b0ad6d63c6d141f2c67e8ce9c2146a7468e46ee37693ddd6a012fd5b45',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
