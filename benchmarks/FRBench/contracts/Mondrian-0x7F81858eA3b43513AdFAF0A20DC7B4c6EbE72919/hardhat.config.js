/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/contracts/Mondrian.sol',
  codeHash:
    '0xd8dc0f4db439b48488a9718f6a1ce0766b2d03400d91e82745f88b6c0c3c8993',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      remappings: [],
      optimizer: { enabled: false, runs: 200 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
