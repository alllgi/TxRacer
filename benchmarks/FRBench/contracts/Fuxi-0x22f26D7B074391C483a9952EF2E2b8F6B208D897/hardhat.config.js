/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Fuxi.sol',
  codeHash:
    '0x03069fade60f7aa6084d924f053a194db8c39c13271f8b7cc292bdc5a666d57b',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
