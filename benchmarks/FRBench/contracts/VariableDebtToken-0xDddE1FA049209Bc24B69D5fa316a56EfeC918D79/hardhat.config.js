/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '@aave/protocol-v2/contracts/protocol/tokenization/VariableDebtToken.sol',
  codeHash:
    '0x4d4d8ea1fb713c636f2176e2fb80df883107a63c315904dd817b2579d3cedcdc',
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
