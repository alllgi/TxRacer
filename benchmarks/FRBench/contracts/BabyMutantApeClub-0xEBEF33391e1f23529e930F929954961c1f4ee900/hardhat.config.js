/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BabyMutantApeClub.sol',
  codeHash:
    '0xa74937d7d5c3c2f2d66c639e3aa2af14e514b51fcff4e684162aec7933feaa7b',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
