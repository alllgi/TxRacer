/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'DXswapPair.sol',
  codeHash:
    '0x930c3f243986bca050edd99fd61e45e3ed87608f9137fa1fdcd9dd7428cedfbd',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.16',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
