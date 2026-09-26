/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Pool.sol',
  codeHash:
    '0xcb76f8416f3ee220cbe5c9c4332d889c8d48469b627d1ed1655393876bb82fa7',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.10',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
