/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/Users/kimbui/Code/src/swap-proxy-contract/contracts/ZeroExProxy.sol',
  codeHash:
    '0x312f9788d138fc36128c490f24af88cdff6bae91506b04646f41e713014809aa',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 1000000 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
