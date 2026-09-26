/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/OnceUponATime.sol',
  codeHash:
    '0x141a1e650f99f772ddecdcceee2f53d9d272770fec4245866a6f4582f7949f4a',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
