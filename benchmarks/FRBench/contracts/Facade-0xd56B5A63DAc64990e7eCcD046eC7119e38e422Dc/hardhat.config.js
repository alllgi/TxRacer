/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Facade/Facade.sol',
  codeHash:
    '0xc3eb66a23a38b54ddf14b9e4fcfd4b3455768993cefef942ecba7e248d75b129',
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
