/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Pool/HegicCall.sol',
  codeHash:
    '0xff42284c408876acdc9d2a0faf6191237722e0f6acd15be9a34f86cefc7201a7',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      evmVersion: 'byzantium',
    },
  },
};
