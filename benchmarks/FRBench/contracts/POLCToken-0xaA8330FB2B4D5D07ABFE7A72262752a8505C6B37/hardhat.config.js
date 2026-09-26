/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'POLCToken.sol',
  codeHash:
    '0x4bd5253e341dadb5935c05c0836c8737817e166d2f6e86fc584d01645644882b',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
