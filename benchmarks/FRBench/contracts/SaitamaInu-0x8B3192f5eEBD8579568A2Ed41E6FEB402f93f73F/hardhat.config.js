/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SaitamaInu.sol',
  codeHash:
    '0xdbb5a2d26f1893c5b2afb372ff20bf572c8917f3ac01b8abc111252a96a4ea9e',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
