/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'AbilityScores.sol',
  codeHash:
    '0x1b86ff34e61125927c6156ae2a9f8c50bd4fb1fef1b9e782ea6a70c08c8b7eba',
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
