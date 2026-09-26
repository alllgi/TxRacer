/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/Fewmans.sol',
  codeHash:
    '0x7a2da4e5ee43de9838b9c360b12ab4158ac54e62d4f61dc86a635ce4f030ccda',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      evmVersion: 'byzantium',
    },
  },
};
