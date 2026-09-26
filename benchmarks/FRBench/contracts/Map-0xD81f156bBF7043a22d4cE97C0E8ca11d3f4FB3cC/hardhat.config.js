/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Map.sol',
  codeHash:
    '0x7f23064039ed6d317472e53b61e8127fdce9ec68b1202f6b8a72bf156d4b05be',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
