/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/Users/jasper/Documents/GitHub/DEX/contracts/DeFiPlaza.sol',
  codeHash:
    '0x326fdd232797589c98f3c79b927d9b6375680e16f970c0536494cb2f45454787',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 100000 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
