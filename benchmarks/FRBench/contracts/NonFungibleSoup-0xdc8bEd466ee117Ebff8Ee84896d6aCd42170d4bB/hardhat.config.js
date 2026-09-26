/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/contracts/NonFungibleSoup.sol',
  codeHash:
    '0x9e3665cbe0a1482263369e6ea52ad09a42925568d4a356ea4d629ac354a00e5c',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      remappings: [],
      optimizer: { enabled: false, runs: 200 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
