/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'AbilityScores.sol',
  codeHash:
    '0x586cc9a84e3442a667007448354875748240ee37fdf57f9e7db5c633b241b4da',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
