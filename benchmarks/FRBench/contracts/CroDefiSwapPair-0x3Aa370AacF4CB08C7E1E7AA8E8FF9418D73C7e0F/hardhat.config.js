/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'CroDefiSwapPair.sol',
  codeHash:
    '0x7eb38a112ba6d7614d58b369913cb45d181c2879b1d55f22da50134627d5c3f3',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.16',
    settings: {
      optimizer: { enabled: true, runs: 999999 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
