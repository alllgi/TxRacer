/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'LootWeapon.sol',
  codeHash:
    '0x1a32c1d6e43448d86546e304020e1f7e531d76bde76d87d20289cd6c4d12abda',
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
