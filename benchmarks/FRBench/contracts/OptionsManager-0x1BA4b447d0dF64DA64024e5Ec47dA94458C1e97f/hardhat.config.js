/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Options/OptionsManager.sol',
  codeHash:
    '0xb5c699d560b9a3175fc0f2950e5665a4b29290e0f50e462939111b8d1ed204f5',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      evmVersion: 'byzantium',
    },
  },
};
