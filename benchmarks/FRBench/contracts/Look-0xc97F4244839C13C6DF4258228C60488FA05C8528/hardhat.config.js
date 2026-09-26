/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Look.sol',
  codeHash:
    '0x69d915baf4c91678b7d97c703657d6bef30ecbc03a3fe5fb2be7b9baacf93af7',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      libraries: {
        'src/Look.sol': {
          LOOKLib: '0xc01650f856dffdc1e90f46a3dd12dce15d752934',
          LOOKLogic: '0xee0b5f24d4b2cf80e3e54e9e5ff8acb9aff1f8a4',
          LOOKSuffix: '0x196fd570d49de7cf8aab245f63330d6957a9223a',
        },
      },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
