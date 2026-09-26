/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BlootDoggs.sol',
  codeHash:
    '0x39fbfe875b5b1019d44528d516bd3066901ce705bad833b8a17717c566025897',
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
