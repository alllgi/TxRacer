/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/contracts/MegaToads.sol',
  codeHash:
    '0xb626f221758bc8a5ca67d9123d990693cc9cb8d0217482f0de48027ebdedf6ad',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 200 },
      evmVersion: 'byzantium',
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
    },
  },
};
