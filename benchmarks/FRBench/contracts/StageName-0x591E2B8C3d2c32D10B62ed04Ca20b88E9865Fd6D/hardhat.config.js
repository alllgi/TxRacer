/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'StageName.sol',
  codeHash:
    '0xf2a6a51fc0d4866ec891f4a9ab7ad475d1ed887e705f966a950156622766643f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
