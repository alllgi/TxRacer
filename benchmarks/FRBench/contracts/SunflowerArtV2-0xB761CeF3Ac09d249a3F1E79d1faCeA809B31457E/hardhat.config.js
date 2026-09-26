/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/SunflowerArtV2.sol',
  codeHash:
    '0x5790d28b26db280cabd1448aa63943db84e4f00d7c5cc240709683e592f72fe5',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
