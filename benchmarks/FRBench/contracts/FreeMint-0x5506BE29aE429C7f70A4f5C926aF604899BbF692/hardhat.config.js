/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'FreeMint.sol',
  codeHash:
    '0xac890140d10218e0f542a4069521006be51a6cc6b95395b7c8e1e41ecbd052e2',
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
