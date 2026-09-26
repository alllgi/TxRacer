/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'LoanClosings.sol',
  codeHash:
    '0xd846000cb16555e387e13960055642137a2481673453b291d8c18a441a3a1b0e',
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
