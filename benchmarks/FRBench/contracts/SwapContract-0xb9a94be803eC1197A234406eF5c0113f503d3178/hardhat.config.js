/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/C/Users/zheli/Desktop/work/SmartContracts/CrossChainSwap/contracts/SwapContract.sol',
  codeHash:
    '0x3da77f36216418e63c57c97f426e14c0a21e34fbbb50d404c1e40a35d6e1c1e0',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 550 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
