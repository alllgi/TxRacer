/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/Users/michaelzhu/protocol/contracts/zero-ex/contracts/src/features/UniswapV3Feature.sol',
  codeHash:
    '0xd7f2812007e51c3aead310f257eddfd8bffe7ad95c2520e27df8e4d0ba874982',
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
