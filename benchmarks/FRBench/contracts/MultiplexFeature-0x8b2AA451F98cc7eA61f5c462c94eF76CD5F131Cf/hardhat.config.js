/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/home/merklejerk/code/0x-protocol/contracts/zero-ex/contracts/src/features/MultiplexFeature.sol',
  codeHash:
    '0x3b65fb8a8315e0509fd8748fad690839aa7d781cc8527d610c9f5e8c8fca617f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      remappings: [
        '@0x/contracts-utils=/home/merklejerk/code/0x-protocol/node_modules/@0x/contracts-utils',
        '@0x/contracts-erc20=/home/merklejerk/code/0x-protocol/contracts/zero-ex/node_modules/@0x/contracts-erc20',
      ],
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
