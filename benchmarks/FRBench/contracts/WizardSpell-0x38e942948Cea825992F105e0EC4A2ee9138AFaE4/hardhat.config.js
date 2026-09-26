/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'WizardSpell.sol',
  codeHash:
    '0x65a4b1fe0d031b43f443dc35a773919791462f03d5f3e8171688e9e35eb57fc1',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
