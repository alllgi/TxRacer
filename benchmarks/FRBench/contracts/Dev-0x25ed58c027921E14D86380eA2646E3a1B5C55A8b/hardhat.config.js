/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Dev.sol',
  codeHash:
    '0xd21381acea192ba56734c586d7f090d41e94860a98ad8e002053190340b3a91c',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: false, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
