/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Creatures.sol',
  codeHash:
    '0x80a1187142205797d3272138b9c7a36ad77bc050a93f77384421f4aadf7ed66b',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.1',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
