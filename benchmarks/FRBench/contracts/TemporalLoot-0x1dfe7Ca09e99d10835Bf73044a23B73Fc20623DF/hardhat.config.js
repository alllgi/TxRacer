/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'TemporalLoot.sol',
  codeHash:
    '0xc5b712f576ddc723b404d56a177d649969ed103daf165170cd14701b97cd3379',
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
