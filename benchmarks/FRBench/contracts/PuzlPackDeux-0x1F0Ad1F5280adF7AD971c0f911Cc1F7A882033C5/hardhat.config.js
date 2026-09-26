/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/Users/ryanhickman/Documents/GIT/puzlmart/contracts/PuzlPackDeux.sol',
  codeHash:
    '0xb44e82ca2b19a6842844508ce14779fbb2e1a919df7b8456ff35930a8d0ec7d2',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 50 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
