/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '@aave/protocol-v2/contracts/protocol/tokenization/VariableDebtToken.sol',
  codeHash:
    '0xe836663d67e5f004a60b4da3c218f78f540c66f432dd4ed82bb7f851e2d3f61b',
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
