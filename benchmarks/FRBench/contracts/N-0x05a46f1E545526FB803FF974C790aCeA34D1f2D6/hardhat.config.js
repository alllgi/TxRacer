/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/N.sol',
  codeHash:
    '0x767e51cee7c55a779cc7fa8b90b2c85cbee6c64a0606026badaa87b39c0b935a',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      libraries: {},
      metadata: { bytecodeHash: 'none', useLiteralContent: true },
      optimizer: { enabled: true, runs: 800 },
      remappings: [],
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
