/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/home/merklejerk/code/0x-protocol/contracts/zero-ex/contracts/src/features/UniswapV3Feature.sol',
  codeHash:
    '0x43fa49fdbf9293be11471367905c0da15f6cd51af3f63f493d6e61ef167c083b',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      remappings: [
        '@0x/contracts-erc20=/home/merklejerk/code/0x-protocol/contracts/zero-ex/node_modules/@0x/contracts-erc20',
        '@0x/contracts-utils=/home/merklejerk/code/0x-protocol/node_modules/@0x/contracts-utils',
      ],
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
