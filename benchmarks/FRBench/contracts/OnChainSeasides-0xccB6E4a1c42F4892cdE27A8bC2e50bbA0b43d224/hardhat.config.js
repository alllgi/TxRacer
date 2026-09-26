/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'seasides.sol',
  codeHash:
    '0xd6f481914c2d4e6c44c7a5a021b00a46f16952f70e153abc13b90c54af2a2f14',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
