/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/home/cluracan/code/0x-protocol/contracts/zero-ex/contracts/src/features/UniswapFeature.sol',
  codeHash:
    '0xba01211d10b6119b0dd1f3d468ed31f2ab17f775869cc5d8a5d9d0254d910d01',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      remappings: [
        '@0x/contracts-utils=/home/cluracan/code/0x-protocol/node_modules/@0x/contracts-utils',
        '@0x/contracts-erc20=/home/cluracan/code/0x-protocol/contracts/zero-ex/node_modules/@0x/contracts-erc20',
      ],
      optimizer: { enabled: true, runs: 1000000 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
