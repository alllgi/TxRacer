/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BlackInBackKat.sol',
  codeHash:
    '0xddf04d33da29ea833a0f340d6fef4887fc2b4d1f65a50766d462fae2fabd3855',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
