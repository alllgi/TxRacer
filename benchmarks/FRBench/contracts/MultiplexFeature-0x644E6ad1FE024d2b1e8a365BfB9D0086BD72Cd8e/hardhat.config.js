/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/Users/michaelzhu/protocol/contracts/zero-ex/contracts/src/features/multiplex/MultiplexFeature.sol',
  codeHash:
    '0x9858b8eb91a5913abb63e7177eb77b0da072c17aa0a8a7900983383ad7760dce',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      remappings: [
        '@0x/contracts-utils=/Users/michaelzhu/protocol/node_modules/@0x/contracts-utils',
        '@0x/contracts-erc20=/Users/michaelzhu/protocol/contracts/zero-ex/node_modules/@0x/contracts-erc20',
      ],
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
