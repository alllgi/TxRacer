/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'KittyCore.sol',
  codeHash:
    '0xfa9b00013baf788bc1d494792bbee58696d7f9fd422a13fd59ee0ab478be5d84',
  paths: { sources: 'src' },
  solidity: {
    version: '0.4.18',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
