/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/ASH.sol',
  codeHash:
    '0x01ac41137d47a09dd072a38db5123fadf9e496003fe110e0c72146aecf5aeedf',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.3',
    settings: {
      optimizer: { enabled: true, runs: 1000 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
