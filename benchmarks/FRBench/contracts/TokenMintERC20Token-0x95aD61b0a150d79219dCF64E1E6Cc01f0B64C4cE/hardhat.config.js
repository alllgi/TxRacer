/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'TokenMintERC20Token.sol',
  codeHash:
    '0xd0caa0f9bc744c523933d44e6d8d07f868803d10bf16c8129e12f670296175ad',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.0',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
