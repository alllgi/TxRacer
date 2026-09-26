/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Members.sol',
  codeHash:
    '0xd48f30ae9b04689e514cc6e58eb2331a6974082905f296009298682058b67958',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
