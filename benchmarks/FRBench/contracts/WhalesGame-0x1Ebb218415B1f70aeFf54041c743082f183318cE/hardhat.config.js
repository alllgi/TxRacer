/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'WhalesGame.sol',
  codeHash:
    '0x5b894d1531ced3109ba79f819666eb59c7001b151fab17c5bfce2ff931c4b846',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.10',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
