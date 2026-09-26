/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'ExchangeIssuance.sol',
  codeHash:
    '0x8228956cc3b173690945791d71f5b44d850099ad8e4641cff0e28b1d4fd48220',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.10',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
