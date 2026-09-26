/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'beckLoot.sol',
  codeHash:
    '0x20c5a384a0ff7b753ff5e182357a4ced3294efb4eac93552fbdc362c89a8d597',
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
