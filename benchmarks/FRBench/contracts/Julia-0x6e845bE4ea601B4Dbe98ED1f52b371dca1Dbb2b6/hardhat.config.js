/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/contracts/Julia.sol',
  codeHash:
    '0x5bb60ccf749ed4e0f1385b682dc663e8c7348453760b4302fbece9450f81a2b9',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 20 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
