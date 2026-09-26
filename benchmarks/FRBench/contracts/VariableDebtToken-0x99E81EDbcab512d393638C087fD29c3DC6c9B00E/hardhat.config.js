/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '@aave/protocol-v2/contracts/protocol/tokenization/VariableDebtToken.sol',
  codeHash:
    '0x02b0a964551e52a09d6216139b3f57d8c9ba8cc1684b2dfa45a7b48c16842f08',
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
