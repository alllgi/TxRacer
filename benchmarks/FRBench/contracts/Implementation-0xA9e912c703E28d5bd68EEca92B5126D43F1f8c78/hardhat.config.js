/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Implementation.sol',
  codeHash:
    '0x6d993226507b93ba3205d1ed0661048df94eb37c63c4652a3094322cb8d3dfdf',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.17',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
