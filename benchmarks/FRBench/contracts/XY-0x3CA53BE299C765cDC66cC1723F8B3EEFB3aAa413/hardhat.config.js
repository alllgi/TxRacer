/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/contracts/XY.sol',
  codeHash:
    '0x341c02af8c9815cc6afb4369518bf453f34673862ef19fa575683c0b2038a6b3',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 10 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
