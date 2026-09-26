/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/protocol/tokenization/StableDebtToken.sol',
  codeHash:
    '0x2ee75bc25c159e504cc3d11918e696720620dad6741f612417bdfb3fa1baf536',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
