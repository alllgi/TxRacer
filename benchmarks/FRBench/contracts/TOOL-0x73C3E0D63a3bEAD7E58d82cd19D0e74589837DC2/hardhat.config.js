/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'TOOL.sol',
  codeHash:
    '0x0657d532ee067fb4e1b395216a2bed90d5fb9ff0ebb3303088cc7e175cd969b3',
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
