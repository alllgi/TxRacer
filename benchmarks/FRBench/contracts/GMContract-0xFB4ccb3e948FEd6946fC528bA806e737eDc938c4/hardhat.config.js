/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'GMContract.sol',
  codeHash:
    '0xfa5584456ae736a65213b7cfe835c6e7fb56e510a274eb21430f9851772c3c5a',
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
