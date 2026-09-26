/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Settlements.sol',
  codeHash:
    '0x38535cfd7ee7336d5339707d8e16d93e1e2e01f10af1187ead372da6b2a7f02f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
