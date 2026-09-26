/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '@aave/protocol-v2/contracts/protocol/tokenization/VariableDebtToken.sol',
  codeHash:
    '0xe9af6dbfc683dca0246a1ca5512cf29380db659b5538f7cbda7f9c7e09f3f0dc',
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
