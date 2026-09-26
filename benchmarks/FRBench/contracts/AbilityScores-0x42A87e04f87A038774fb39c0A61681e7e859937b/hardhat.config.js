/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'AbilityScores.sol',
  codeHash:
    '0xebbd374b2d1b96a17e753580a771de26ee3be3e5311c931c6a52d283dd6f2000',
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
