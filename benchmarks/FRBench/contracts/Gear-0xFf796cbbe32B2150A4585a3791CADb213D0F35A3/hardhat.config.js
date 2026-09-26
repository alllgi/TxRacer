/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Gear.sol',
  codeHash:
    '0xaffb8f77ce4c704c3dc46eb6e8ce9914c07711fb68317e0a46e587f02bf87b2e',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
