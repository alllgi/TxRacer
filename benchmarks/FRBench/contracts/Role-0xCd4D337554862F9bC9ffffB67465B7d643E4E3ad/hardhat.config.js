/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Role.sol',
  codeHash:
    '0x045ef2c19f4869e8606812924bc64b51ec563af7a705378182b4f983735981fe',
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
