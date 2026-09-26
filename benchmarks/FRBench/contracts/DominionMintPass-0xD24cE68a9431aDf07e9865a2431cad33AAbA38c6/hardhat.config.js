/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'DominionMintPass.sol',
  codeHash:
    '0x6634d12f570eecb5ab07f6d54189b00108e0787c15911282a89d6e8d38984abc',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
