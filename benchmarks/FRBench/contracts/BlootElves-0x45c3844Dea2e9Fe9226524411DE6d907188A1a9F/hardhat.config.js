/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/contracts/BlootElves.sol',
  codeHash:
    '0x3d409e1bb6276242aef5f8c64e7067802d7c202387d1be60b8bcda0c79327c8a',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.6',
    settings: {
      remappings: [],
      optimizer: { enabled: false, runs: 200 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
