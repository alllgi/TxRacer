/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'WyvernExchange.sol',
  codeHash:
    '0xa677ff05bad60ee8e3c7ed79efb6d8a50374a83c97758e9530baac277d097028',
  paths: { sources: 'src' },
  solidity: {
    version: '0.4.23',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
