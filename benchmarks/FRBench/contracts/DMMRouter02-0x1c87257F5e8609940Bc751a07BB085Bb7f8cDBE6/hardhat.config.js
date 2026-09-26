/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'DMMRouter02.sol',
  codeHash:
    '0xa5cde7a3af5afe49983dc6bd04bd0db9069df42daa0fefc69fc91716d911e9f7',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 999999 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
