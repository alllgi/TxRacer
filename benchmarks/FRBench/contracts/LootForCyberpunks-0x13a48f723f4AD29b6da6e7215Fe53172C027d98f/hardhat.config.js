/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/LootForCryptopunks.sol',
  codeHash:
    '0xffe8bd506d9a0f2d73fc83fc258164f954a9c6685c4ae924c4fdae48c3fa74e2',
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
