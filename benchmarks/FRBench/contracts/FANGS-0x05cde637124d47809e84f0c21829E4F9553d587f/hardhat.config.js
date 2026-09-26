/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'FANGS.sol',
  codeHash:
    '0x7bcc62216185c1f9e9458b9544cf39fb1d9af2bc8cf371a581130404be328f28',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.3',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
