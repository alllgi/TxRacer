/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'FPSLOOT.sol',
  codeHash:
    '0xd29109693ff08cf1c1341170447267d120b93a86fae7236c99000f77580a1a56',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
