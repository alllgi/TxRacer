/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UniBrightToken.sol',
  codeHash:
    '0x150aabd87ecc1cd5c024cad6d96ddf98b53930401b6190bb1852e5aa933d0118',
  paths: { sources: 'src' },
  solidity: {
    version: '0.4.15',
    settings: {
      optimizer: { enabled: true, runs: 10000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
