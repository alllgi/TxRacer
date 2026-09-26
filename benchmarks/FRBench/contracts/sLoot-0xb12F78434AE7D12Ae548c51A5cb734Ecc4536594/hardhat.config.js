/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'sLoot.sol',
  codeHash:
    '0x496c77fda968aa16a7d1ca45b8661a77d73b00015834a00e8ec3fe2ef599330c',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
