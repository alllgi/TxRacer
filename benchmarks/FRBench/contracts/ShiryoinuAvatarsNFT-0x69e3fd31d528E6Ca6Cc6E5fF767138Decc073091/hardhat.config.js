/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'ShiryoinuAvatarsNFT.sol',
  codeHash:
    '0xd2e1b351ecdc080d37f78772fe90a3f46b73437cc7ff6bcded6669354a2257e4',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
