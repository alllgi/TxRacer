/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Glitch.sol',
  codeHash:
    '0xcd76356cb35964883d8c67382bfc436e497bd86212db71bfb92f8c79e31d6176',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
