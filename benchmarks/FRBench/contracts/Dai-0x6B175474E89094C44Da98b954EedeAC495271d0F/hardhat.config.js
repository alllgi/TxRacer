/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Dai.sol',
  codeHash:
    '0x4e36f96ee1667a663dfaac57c4d185a0e369a3a217e0079d49620f34f85d1ac7',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.12',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
