/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'PlasmaswapPair.sol',
  codeHash:
    '0x59dc9790ef696731664b76b89b238dc74d6812464e9b33142223976babf9e31f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.16',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
