/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'PoodlesNFT.sol',
  codeHash:
    '0x551542e92f265fcc63a444c31f20d567416afa564569aef11d9999129186eade',
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
