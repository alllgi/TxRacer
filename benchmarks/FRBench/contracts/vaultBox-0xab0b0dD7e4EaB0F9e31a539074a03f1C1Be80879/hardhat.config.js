/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'vaultBox.sol',
  codeHash:
    '0x601fa07484d99ec8683c43aa834972078e0b6abb4e9d566d658ac765cfbdfd1a',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
