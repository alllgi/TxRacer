/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BentoBoxV1.sol',
  codeHash:
    '0x4ad486b2dd2f7c7f3f936489571ec2a9e8e7075ebd7cd4ce0a496bc6f55468ea',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 999999 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'constantinople',
    },
  },
};
