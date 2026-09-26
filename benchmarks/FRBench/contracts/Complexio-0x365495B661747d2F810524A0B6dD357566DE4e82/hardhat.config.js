/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Complexio.sol',
  codeHash:
    '0xd96014fe63d5945ed5f5e437b9a10e9d3b5e25088169794993a6b0cb5e93c655',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.10',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
