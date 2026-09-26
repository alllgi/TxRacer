/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '@aave/protocol-v2/contracts/protocol/tokenization/VariableDebtToken.sol',
  codeHash:
    '0x6c999d1f8ce978f56a9a2f0367a40ca70c084271cd341d274830f0d1755854fb',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
