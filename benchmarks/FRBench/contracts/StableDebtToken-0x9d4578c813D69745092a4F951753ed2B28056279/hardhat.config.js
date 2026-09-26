/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/protocol/tokenization/StableDebtToken.sol',
  codeHash:
    '0x1568954e1fb7631f987d1f2d54af8d625cba12d1dfe486ffdeadeda912d1edbd',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
