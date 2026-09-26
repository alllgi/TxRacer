/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SquidGameCard.sol',
  codeHash:
    '0x750bdba6d66df80d7959d69d94b9b6e3fca5dfadd10a43cf16b63c91d1c2ff90',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
